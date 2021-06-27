import 'dart:io';

import 'package:bubble_tab_indicator/bubble_tab_indicator.dart';
import 'package:deck_royale_app/controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:path_provider/path_provider.dart';

import 'colors.dart';
import 'home_page.dart';
import 'model.dart';

Future<String> get _localPath async {
  final directory = await getApplicationDocumentsDirectory();
  return directory.path;
}

Future<File> get _starredFile async {
  final path = await _localPath;
  if (!await File('$path/starred_searches.txt').exists()) {
    return new File('$path/starred_searches.txt').create();
  }
  return File('$path/starred_searches.txt');
}

Future<File> get _historyFile async {
  final path = await _localPath;
  if (!await File('$path/last_searches.txt').exists()) {
    return new File('$path/last_searches.txt').create();
  }
  return File('$path/last_searches.txt');
}

Future writeSearchPersistent(Search search, bool starred) async {
  File file = starred? await _starredFile : await _historyFile;
  String content = await file.readAsString();
  List contents = content.split('\n');
  content = '';
  for(int i = 0; i < contents.length-1; i++){
    if(contents[i].split(',')[1].compareTo(search.tag) == 0) {
      if (starred) {
        _SearchWidgetState.starredSearchesList.removeWhere((element) => element.tag == search.tag);
      }
      else {
        _SearchWidgetState.lastSearchesList.removeWhere((element) => element.tag == search.tag);
      }
    }
    else{
      content = content+contents[i]+'\n';
    }
  }
  file.writeAsString(search.name+','+search.tag+'\n'+content);
}

Future removeSearchPersistent(Search search, bool starred) async {
  final file = starred? await _starredFile : await _historyFile;
  String content = await file.readAsString();
  List contents = content.split('\n');
  content = '';
  for(int i = 0; i < contents.length-1; i++){
    if(contents[i].split(',')[1].compareTo(search.tag) == 0){
      if (starred) {
        _SearchWidgetState.starredSearchesList.removeWhere((element) => element.tag == search.tag);
      }
      else {
        _SearchWidgetState.lastSearchesList.removeWhere((element) => element.tag == search.tag);
      }
    }
    else{
      content = content+contents[i]+'\n';
    }
  }
  file.writeAsString(content);
}

Future<int> readSearchPersistent(bool starred) async {
  try {
    final file = starred? await _starredFile : await _historyFile;
    //file.writeAsString('');
    String content = await file.readAsString();
    List<String> contents = content.split('\n');
    if (!starred) {
      _SearchWidgetState.lastSearchesList = [];
      for(String c in contents){
        _SearchWidgetState.lastSearchesList.add(new Search(c.split(',')[0], c.split(',')[1]));
      }
      return 0;
    }
    else {
      _SearchWidgetState.starredSearchesList = [];
      for(String c in contents){
        _SearchWidgetState.starredSearchesList.add(new Search(c.split(',')[0], c.split(',')[1]));
      }
      return 0;
    }
  } catch (e, stacktrace) {
    print(e);
    print(stacktrace);
    return 1;
  }
}

class Search {
  String name;
  String tag;

  Search(this.name, this.tag);
}

class SearchWidget extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> with SingleTickerProviderStateMixin {

  static List<Search> lastSearchesList = [];
  static List<Search> starredSearchesList = [];
  TabController _tabController;

  @override
  void initState() {
    _tabController = new TabController(length: 2, vsync: this);
    super.initState();
  }

  void updateView(String tag) async {
    await Navigator.push(context, MaterialPageRoute(builder: (context) => ResultPage(tag))).then((value) {setState(() {}); return true;} );
  }

  @override
  Widget build(BuildContext context) {
    Widget child;
    return Container(
      decoration: new BoxDecoration(
        image: DRColors.background,
      ),
      child: Column(children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
          child: SearchBar(updateView),
        ),
        SizedBox(height: 10,),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 5),
          child: TabBar(
            tabs: [
              Tab(
                child: Text(
                  "History",
                  style: TextStyle(
                      fontSize: MediaQuery.of(context).orientation == Orientation.portrait ? 15 : 19,
                      color: DRColors.white2),
                ),
              ),
              Tab(
                child: Text(
                  "Starred",
                  style: TextStyle(
                      fontSize: MediaQuery.of(context).orientation == Orientation.portrait ? 15 : 19,
                      color: DRColors.orange),
                ),
              ),
            ],
            controller: _tabController,
            indicatorSize: TabBarIndicatorSize.tab,
            indicator: new BubbleTabIndicator(
              indicatorHeight: 46.0,
              indicatorColor: DRColors.black2,
              tabBarIndicatorSize: TabBarIndicatorSize.tab,
            ),
          ),
        ),
        SizedBox(height: 10,),
        Flexible(
          child: TabBarView(
            children: [
              Container(
                  child: FutureBuilder<int>(
                      future: readSearchPersistent(false),
                      builder:
                          (BuildContext context, AsyncSnapshot<int> snapshot) {
                        if (snapshot.hasData) {
                          if (lastSearchesList == null || lastSearchesList.length == 0) {
                            child = Center(
                              child: BigTextWidget('Here you will find your most recent searches.',),
                            );
                          }
                          else {
                            child = ListView(
                                children: List.generate(lastSearchesList.length, (i) {
                                  return GestureDetector(
                                    child: Container(
                                      margin: const EdgeInsets.fromLTRB(10, 0, 10, 7),
                                      height: 60,
                                      width: MediaQuery.of(context).size.width,
                                      decoration: BoxDecoration(
                                        color: Color(0xBB333333),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: DRColors.grey.withOpacity(0.2),
                                          width: 4,
                                        ),
                                      ),
                                      child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                                          children: [
                                            SizedBox(width: 10),
                                            Container(
                                              width: MediaQuery.of(context).size.width/2.5,
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                lastSearchesList[i].name,
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    color: DRColors.white2),
                                              ),
                                            ),
                                            Container(
                                              decoration: new BoxDecoration(
                                                  color: Color(0x77333333),
                                                  borderRadius: BorderRadius.circular(16)),
                                              height: 34,
                                              width: MediaQuery.of(context).size.width/3,
                                              margin: const EdgeInsets.symmetric(vertical: 5),
                                              alignment: Alignment.center,
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Container(
                                                    margin: const EdgeInsets.symmetric(horizontal: 5),
                                                    padding: const EdgeInsets.fromLTRB(0, 3, 0, 0),
                                                    alignment: Alignment.center,
                                                    child: Stack(
                                                      children: [
                                                        Text(
                                                          ("#"+lastSearchesList[i].tag).toUpperCase(),
                                                          style: TextStyle(
                                                            foreground: Paint()
                                                              ..style = PaintingStyle.stroke
                                                              ..strokeWidth = 3
                                                              ..color = Color(0xFF444444),
                                                          ),
                                                        ),
                                                        Text(
                                                          ("#"+lastSearchesList[i].tag).toUpperCase(),
                                                          style: TextStyle(color: Color(0xFFD3D3D3),),
                                                        ),
                                                      ],
                                                    ),
                                                    height: 34,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Container(
                                                width: 40,
                                                height: 40,
                                                padding: const EdgeInsets.fromLTRB(0, 0, 0, 3),
                                                child: RawMaterialButton(
                                                  onPressed: () {
                                                    removeSearchPersistent(lastSearchesList[i], false);
                                                    Future.delayed(Duration(milliseconds: 10), () {setState(() {});});
                                                  },
                                                  child: Icon(
                                                    CupertinoIcons.xmark_circle_fill,
                                                    color: Color(0x55DDDDDD),
                                                    size: 27,
                                                  ),
                                                  shape: CircleBorder(),
                                                )
                                            )
                                          ]
                                      ),
                                    ),
                                    onTap: () {updateView(lastSearchesList[i].tag);},
                                  );
                                })
                            );
                          }
                        } else if (snapshot.hasError) {
                          child = Text(snapshot.error.toString());
                        } else {
                          child = SizedBox(
                            child: CircularProgressIndicator(),
                            width: 50,
                            height: 50,
                          );
                        }
                        return Container(
                          alignment: Alignment.center,
                          child: child
                        );
                      }
                  )
              ),
              Container(
                  child: FutureBuilder<int>(
                      future: readSearchPersistent(true),
                      builder:
                          (BuildContext context, AsyncSnapshot<int> snapshot) {
                        if (snapshot.hasData) {
                          if (starredSearchesList == null || starredSearchesList.length == 0) {
                            child = Center(
                              child: BigTextWidget(
                                'Here you will find your favourite players. Tap the star in the player profile to save it.',
                              ),
                            );
                          }
                          else {
                            child = ListView(
                                children: List.generate(starredSearchesList.length, (i) {
                                  return GestureDetector(
                                    child: Container(
                                      margin: const EdgeInsets.fromLTRB(10, 0, 10, 7),
                                      height: 60,
                                      width: MediaQuery.of(context).size.width,
                                      decoration: BoxDecoration(
                                        color: Color(0xBB222222),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: DRColors.orange.withOpacity(0.4),
                                          width: 4,
                                        ),
                                      ),
                                      child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                                          children: [
                                            SizedBox(width: 10),
                                            Container(
                                              width: MediaQuery.of(context).size.width/2.5,
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                starredSearchesList[i].name,
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    color: DRColors.white2),
                                              ),
                                            ),
                                            Container(
                                              decoration: new BoxDecoration(
                                                  color: Color(0x77333333),
                                                  borderRadius: BorderRadius.circular(16)),
                                              height: 34,
                                              width: MediaQuery.of(context).size.width/3,
                                              margin: const EdgeInsets.symmetric(vertical: 5),
                                              alignment: Alignment.center,
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Container(
                                                    margin: const EdgeInsets.symmetric(horizontal: 5),
                                                    padding: const EdgeInsets.fromLTRB(0, 3, 0, 0),
                                                    alignment: Alignment.center,
                                                    child: Stack(
                                                      children: [
                                                        Text(
                                                          ("#"+starredSearchesList[i].tag).toUpperCase(),
                                                          style: TextStyle(
                                                            foreground: Paint()
                                                              ..style = PaintingStyle.stroke
                                                              ..strokeWidth = 3
                                                              ..color = Color(0xFF444444),
                                                          ),
                                                        ),
                                                        Text(
                                                          ("#"+starredSearchesList[i].tag).toUpperCase(),
                                                          style: TextStyle(
                                                            color: Color(0xFFD3D3D3),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    height: 34,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Container(
                                                width: 40,
                                                height: 40,
                                                padding: const EdgeInsets.fromLTRB(0, 0, 0, 3),
                                                child: RawMaterialButton(
                                                  onPressed: () {
                                                    removeSearchPersistent(starredSearchesList[i], true);
                                                    Future.delayed(Duration(milliseconds: 10), () {setState(() {});});
                                                  },
                                                  child: Icon(
                                                    CupertinoIcons.xmark_circle_fill,
                                                    color: Color(0x55DDDDDD),
                                                    size: 27,
                                                  ),
                                                  shape: CircleBorder(),
                                                )
                                            )
                                          ]
                                      ),
                                    ),
                                    onTap: () {updateView(starredSearchesList[i].tag);},
                                  );
                                })
                            );
                          }
                        } else if (snapshot.hasError) {
                          child = Text(snapshot.error.toString());
                        } else {
                          child = SizedBox(
                            child: CircularProgressIndicator(),
                            width: 50,
                            height: 50,
                          );
                        }
                        return Container(
                            alignment: Alignment.center,
                            child: child
                        );
                      }
                  )
              ),
            ],
            controller: _tabController,
          ),
        )
      ]),
    );
  }
}

class SearchBar extends StatefulWidget {

  final Function updateParent;
  SearchBar(this.updateParent);

  @override
  State<StatefulWidget> createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  final List<String> hintText = [
    "Insert Player Tag",
    "Tag is 6 or more characters long!"
  ];
  int i = 0;
  final TextEditingController textController = TextEditingController();
  TextField textField;

  @override
  Widget build(BuildContext context) {
    textField = TextField(
      controller: textController,
      style: TextStyle(
          color: DRColors.white2, fontSize: 20),
      decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hintText[i],
          hintStyle: TextStyle(
              color: Color(0xFF777777), fontSize: 14)),
      cursorColor: Colors.orange,
      keyboardAppearance: Brightness.dark,
      onSubmitted: (text) {
        checkTag(context);
      },
    );
    return Center(
        child: Container(
            decoration: new BoxDecoration(
              color: DRColors.black2,
              borderRadius: BorderRadius.circular(30),
            ),
            height: 54,
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      "  #",
                      style: TextStyle(fontSize: 32, color: DRColors.orange),
                    ),
                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: SizedBox(
                            width: MediaQuery.of(context).size.width - 132,
                            child: textField)),
                    Container(
                        width: 42,
                        height: 54,
                        child: RawMaterialButton(
                          onPressed: () async {checkTag(context);},
                          fillColor: Color(0xFF303030),
                          child: Icon(
                            CupertinoIcons.search,
                            color: DRColors.white2,
                            size: 22,
                          ),
                          shape: CircleBorder(),
                        ))
                  ],
                )
              ],
            )));
  }

  void checkTag(BuildContext context) async {
    if (textController.text.length < 6) {
      textController.text = '';
      HapticFeedback.vibrate();
      i = 1;
      setState(() {
        FocusScope.of(context).unfocus();
        Scaffold.of(context).showSnackBar(SnackBar(
          duration: Duration(milliseconds: 2000),
          content: Text("Invalid Tag",
            style: TextStyle(color: DRColors.white2),
          ),
          backgroundColor: DRColors.black,
        ));
      });
    } else {
      setState(() {
        i = 0;
        widget.updateParent(textController.text);
        textController.text = '';
      });
    }
  }
}

class ResultPage extends StatefulWidget {
  final String tag;
  final SearchCtrl searchController = new SearchCtrl();

  ResultPage(this.tag);

  @override
  State<StatefulWidget> createState() => ResultPageState();
}

class ResultPageState extends State<ResultPage> {

  @override
  Widget build(BuildContext context) {
    IconData starIcon = !_SearchWidgetState.starredSearchesList.any((element) => element.tag == widget.tag)? CupertinoIcons.star : CupertinoIcons.star_fill;
    List<Widget> children = [];
    String playerName;
    Widget scaffold =  Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFF141414),
          centerTitle: true,
          title: Text(
            "#${widget.tag}".toUpperCase(),
            style: TextStyle(
                fontSize: MediaQuery.of(context).orientation == Orientation.portrait ? 18 : 22,
                color: DRColors.white),
          ),
          actions: [
            Builder(builder: (context) {
              return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: IconButton(
                      tooltip: "Save player",
                      icon: Icon(
                        starIcon,
                        color: DRColors.orange,
                        size: 30,
                      ),
                      onPressed: (){
                        if(playerName != null){
                          starSearch(new Search(playerName, widget.tag), context);
                          setState(() {
                            starIcon = !_SearchWidgetState.starredSearchesList.any((element) => element.tag == widget.tag)? CupertinoIcons.star : CupertinoIcons.star_fill;
                          });
                        }
                      }
                  )
              );
            })
          ],
        ),
        backgroundColor: DRColors.black,
        body: Container(
            decoration: new BoxDecoration(color: Color(0xFF131313)),
            child: FutureBuilder<PlayerData>(
                future: widget.searchController.getPlayer(widget.tag),
                builder:
                    (BuildContext context, AsyncSnapshot<PlayerData> snapshot) {
                  if (snapshot.hasData) {
                    children = <Widget>[PlayerView(data: snapshot.data)];
                    if(snapshot.data.player != null) {
                      playerName = snapshot.data.player.playerName;
                      writeSearchPersistent(new Search(snapshot.data.player.playerName, widget.tag), false);
                    }
                  } else if (snapshot.hasError) {
                    children = <Widget>[ErrorWidgetCustom("Check your internet connection!")];
                  } else {
                    children = <Widget>[
                      SizedBox(
                        child: CircularProgressIndicator(),
                        width: 50,
                        height: 50,
                      )
                    ];
                  }
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: children,
                    ),
                  );
                })));
    return scaffold;
  }

  void starSearch(Search search, BuildContext context) {
    if(!_SearchWidgetState.starredSearchesList.any((element) => element.tag == widget.tag)){
      Scaffold.of(context).showSnackBar(SnackBar(content: Text("Added ${search.name} to favourites!"), duration: Duration(seconds: 1),));
      _SearchWidgetState.starredSearchesList.add(search);
      writeSearchPersistent(search, true);
    }
    else{
      Scaffold.of(context).showSnackBar(SnackBar(content: Text("Removed ${search.name} from favourites"), duration: Duration(seconds: 1),));
      _SearchWidgetState.starredSearchesList.removeWhere((element) => element.tag == widget.tag);
      removeSearchPersistent(search, true);
    }
  }

}

class PlayerView extends StatelessWidget {
  final PlayerData data;

  PlayerView({this.data});

  @override
  Widget build(BuildContext context) {
    if(data.player != null){
      double height = MediaQuery.of(context).orientation == Orientation.portrait? 6 : 16;
      Widget thirdRow;
      Widget fourthRow;
      if (MediaQuery.of(context).orientation == Orientation.portrait){
        thirdRow = Column(
          children: [
            Row(
              children: [
                statsRow(context),
              ],
            ),
          SizedBox(height: height,)
          ]
        );
        fourthRow = Column(
          children: [
            Row(
              children: [
                favCardRow(context),
              ],
            ),
            SizedBox(height: height,)
          ]
        );
      }
      else{
        thirdRow = Row(
          children: [
            Row(
              children: [
                statsRow(context),
                favCardRow(context),
              ],
            ),
          ]
        );
        fourthRow = Row(
          children: [
            SizedBox(height: height,)
          ]
        );
      }
      if (data.player.playerName.compareTo('') != 0) {
        return Flexible(
            child: Container(
                child: ListView(
                  children: [
                    Row(
                      children: [
                        mainPlayerRow(context),
                      ],
                    ),
                    SizedBox(height: height,),
                    Row(
                      children: [
                        clanRow(context),
                      ],
                    ),
                    SizedBox(height: height,),
                    thirdRow,
                    fourthRow,
                    Row(
                      children: [
                        lastBattlesRow(context),
                      ],
                    ),
                    SizedBox(height: height,),
                    Row(
                      children: [
                        chestsRow(context),
                      ],
                    ),
                    SizedBox(height: 10,),
                  ],
                )
            )
        );
      }
    }
    return ErrorWidgetCustom("The player doesn't exist, did you insert the correct tag?");
  }

  Widget mainPlayerRow(BuildContext context) {
    return Container(
      decoration: new BoxDecoration(
          image: new DecorationImage(
              image: new AssetImage('resources/images/pbg.png'),
              fit: BoxFit.fitWidth,
              colorFilter:
                  ColorFilter.mode(Color(0xCC111111), BlendMode.srcOver)),
          borderRadius: BorderRadius.circular(16)),
      height: 150,
      width: MediaQuery.of(context).size.width - 20,
      margin: const EdgeInsets.fromLTRB(10, 10, 10, 0),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Flexible(
                flex: 16,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(
                      height: 16,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 12,
                        ),
                        Stack(children: [
                          SizedBox(
                              width: 40,
                              height: 40,
                              child: Image.asset("resources/images/level.png")),
                          Container(
                              width: 40,
                              height: 40,
                              alignment: Alignment.center,
                              child: Text(
                                data.player.playerExperienceLevel.toString(),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: DRColors.white2,
                                  shadows: <Shadow>[
                                    Shadow(
                                      offset: Offset(0.5, 0.5),
                                      blurRadius: 1.5,
                                      color: Color.fromARGB(255, 0, 0, 0),
                                    )
                                  ],
                                ),
                              )),
                        ]),
                        Container(
                          margin: const EdgeInsets.fromLTRB(10, 0, 5, 0),
                          padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                          alignment: Alignment.center,
                          child: Text(
                            data.player.playerName,
                            style: TextStyle(
                                fontSize: 18,
                                color: DRColors.white2),
                          ),
                          height: 40,
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 12,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 12,
                        ),
                        Container(
                          padding: const EdgeInsets.fromLTRB(0, 3, 0, 0),
                          alignment: Alignment.center,
                          child: Column(
                            children: [
                              Text(
                                "current",
                                style: TextStyle(color: DRColors.grey2),
                              ),
                              Container(
                                decoration: new BoxDecoration(
                                    color: Color(0xFF1E1C16),
                                    borderRadius: BorderRadius.circular(16)),
                                height: 30,
                                width: 100,
                                margin: const EdgeInsets.symmetric(vertical: 5),
                                alignment: Alignment.center,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: Image.asset(
                                            "resources/images/trophies.png")),
                                    Container(
                                      margin:
                                          const EdgeInsets.symmetric(horizontal: 5),
                                      padding: const EdgeInsets.fromLTRB(0, 3, 0, 0),
                                      alignment: Alignment.center,
                                      child: Text(
                                        data.player.currentTrophies.toString(),
                                        style: TextStyle(color: DRColors.white2),
                                      ),
                                      height: 30,
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                          height: 60,
                        ),
                        SizedBox(
                          width: 12,
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 5),
                          padding: const EdgeInsets.fromLTRB(0, 3, 0, 0),
                          alignment: Alignment.center,
                          child: Column(
                            children: [
                              Stack(
                                children: [
                                  Text(
                                    "best",
                                    style: TextStyle(
                                      foreground: Paint()
                                        ..style = PaintingStyle.stroke
                                        ..strokeWidth = 3
                                        ..color = Color(0xFF6F5400),
                                    ),
                                  ),
                                  Text(
                                    "best",
                                    style: TextStyle(color: Color(0xCCFFD700),),
                                  ),
                                ],
                              ),
                              Container(
                                decoration: new BoxDecoration(
                                    color: Color(0xFF1E1C16),
                                    borderRadius: BorderRadius.circular(16)),
                                height: 30,
                                width: 100,
                                margin: const EdgeInsets.symmetric(vertical: 5),
                                alignment: Alignment.center,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: Image.asset(
                                            "resources/images/trophies.png")),
                                    Container(
                                      margin: const EdgeInsets.symmetric(horizontal: 5),
                                      padding: const EdgeInsets.fromLTRB(0, 3, 0, 0),
                                      alignment: Alignment.center,
                                      child: Text(
                                        data.player.bestTrophies.toString(),
                                        style: TextStyle(color: DRColors.white2),
                                      ),
                                      height: 30,
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                          height: 60,
                        ),
                        SizedBox(
                          width: 6,
                        )
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    )
                  ],
                )),
            Flexible(
                flex: 6,
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.fromLTRB(0, 6, 16, 0),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                      ),
                      height: 110,
                      child: Image.asset("resources/images/${data.player.currentArena.name}.png")
                    ),
                    Container(
                      margin: const EdgeInsets.fromLTRB(0, 0, 16, 0),
                      alignment: Alignment.center,
                      child: Text(
                        data.player.currentArena.name,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: DRColors.white2,
                            fontSize: 11
                        ),
                      ),
                      height: 30,
                    ),
                  ],
                ))
          ],
        ),
      ),
    );
  }

  Widget clanRow(BuildContext context) {
    String clanTag = "NO_CLAN";
    String clanName = "No Clan";
    if(data.player.playerClan != null){
      clanTag = data.player.playerClan.tag;
      clanName = data.player.playerClan.name;
    }
    return Container(
        decoration: new BoxDecoration(
            color: Color(0xFF1E1C16), borderRadius: BorderRadius.circular(16)),
        height: 50,
        width: MediaQuery.of(context).size.width - 20,
        margin: const EdgeInsets.fromLTRB(10, 10, 10, 0),
        child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.fromLTRB(20, 3, 0, 0),
                      alignment: Alignment.center,
                      child: Image.asset("resources/images/clanBadge.png"),
                      height: 36,
                    ),
                    Container(
                      padding: const EdgeInsets.fromLTRB(6, 3, 0, 0),
                      alignment: Alignment.center,
                      child: Text(
                        clanName,
                        style: TextStyle(
                            color: DRColors.white2,
                            fontSize: 15
                        ),
                      ),
                      height: 30,
                    ),
                  ],
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.fromLTRB(0, 3, 0, 0),
                      alignment: Alignment.center,
                      child: Stack(
                        children: [
                          Text(
                            "#$clanTag",
                            style: TextStyle(
                              foreground: Paint()
                                ..style = PaintingStyle.stroke
                                ..strokeWidth = 3
                                ..color = Color(0xFF444444),
                            ),
                          ),
                          Text(
                            "#$clanTag",
                            style: TextStyle(color: Color(0xFFD3D3D3),),
                          ),
                        ],
                      ),
                      height: 30,
                    ),
                    Container(
                        width: 52,
                        height: 34,
                        child: RawMaterialButton(
                          onPressed: () {
                            if (clanTag.compareTo("NO_CLAN") == 0){
                              Scaffold.of(context).showSnackBar(SnackBar(content: Text("Player has no Clan!"), duration: Duration(seconds: 1),));
                              return;
                            }
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ClanPage(clanTag)));
                          },
                          fillColor: Color(0x10FFFFFF),
                          child: Icon(
                            CupertinoIcons.arrow_right,
                            color: DRColors.white2,
                            size: 22,
                          ),
                          shape: CircleBorder(),
                        )
                    )
                  ],
                )
              ],
            )
        )
    );
  }

  Widget statsRow(BuildContext context) {
    double ratio = data.player.playerWins/data.player.playerLosses;
    double width = MediaQuery.of(context).size.width - 20;
    if (MediaQuery.of(context).orientation == Orientation.landscape){
      width = width/2 - 10;
    }
    return Container(
        decoration: new BoxDecoration(
            image: new DecorationImage(
                image: new AssetImage('resources/images/arenabg.png'),
                fit: BoxFit.cover,
                colorFilter:
                    ColorFilter.mode(Color(0xC2161616), BlendMode.srcOver)),
            borderRadius: BorderRadius.circular(16)),
        height: 280,
        width: width,
        margin: const EdgeInsets.fromLTRB(10, 10, 10, 0),
        child: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
              child: Text("Ladder", style: TextStyle(fontSize: 16, color: DRColors.white2),),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  padding: const EdgeInsets.fromLTRB(0, 3, 0, 0),
                  width: width / 3 - 20,
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      Text(
                        "wins",
                        style: TextStyle(color: DRColors.white2),
                      ),
                      Container(
                        decoration: new BoxDecoration(
                            color: Color(0xFF1E1C16),
                            borderRadius: BorderRadius.circular(16)),
                        height: 30,
                        width: 100,
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        alignment: Alignment.center,
                        child: Text(
                          data.player.playerWins.toString(),
                          style: TextStyle(color: Color(0xFF98BB22)),
                        ),
                      )
                    ],
                  ),
                  height: 60,
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  padding: const EdgeInsets.fromLTRB(0, 3, 0, 0),
                  width: width / 3 - 20,
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      Text(
                        "losses",
                        style: TextStyle(color: DRColors.white2),
                      ),
                      Container(
                        decoration: new BoxDecoration(
                            color: Color(0xFF1E1C16),
                            borderRadius: BorderRadius.circular(16)),
                        height: 30,
                        width: 100,
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        alignment: Alignment.center,
                        child: Text(
                          data.player.playerLosses.toString(),
                          style: TextStyle(color: Color(0xFFDD5151)),
                        ),
                      )
                    ],
                  ),
                  height: 60,
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  padding: const EdgeInsets.fromLTRB(0, 3, 0, 0),
                  width: width / 3 - 20,
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "3",
                            style: TextStyle(color: DRColors.white2),
                          ),
                          Container(
                            height: 14,
                            child: Image.asset("resources/images/crown.png"),
                          ),
                          Text(
                            " wins",
                            style: TextStyle(color: DRColors.white2),
                          ),
                        ],
                      ),
                      Container(
                        decoration: new BoxDecoration(
                            color: Color(0xFF1E1C16),
                            borderRadius: BorderRadius.circular(16)),
                        height: 30,
                        width: 100,
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        alignment: Alignment.center,
                        child: Text(
                          data.player.threeCrownWins.toString(),
                          style: TextStyle(color: DRColors.white2),
                        ),
                      )
                    ],
                  ),
                  height: 60,
                ),
              ],
            ),
            Container(
              child: Text("Overall", style: TextStyle(fontSize: 16, color: DRColors.white2),),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  padding: const EdgeInsets.fromLTRB(0, 3, 0, 0),
                  width: width / 2 - 20,
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      Text(
                        "w/l ratio",
                        style: TextStyle(color: DRColors.white2),
                      ),
                      Container(
                        decoration: new BoxDecoration(
                          color: Color(0xFF1E1C16),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Color(0xBBFFD700),
                            width: 2,
                          ),
                        ),
                        height: 30,
                        width: 100,
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        alignment: Alignment.center,
                        child: Text(
                          ratio.toStringAsFixed(2),
                          style: TextStyle(color: DRColors.white2),
                        ),
                      )
                    ],
                  ),
                  height: 60,
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  padding: const EdgeInsets.fromLTRB(0, 3, 0, 0),
                  width: width / 2 - 20,
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      Text(
                        "total battles",
                        style: TextStyle(color: DRColors.white2),
                      ),
                      Container(
                        decoration: new BoxDecoration(
                            color: Color(0xFF1E1C16),
                            borderRadius: BorderRadius.circular(16)),
                        height: 30,
                        width: 100,
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        alignment: Alignment.center,
                        child: Text(
                          data.player.battleCount.toString(),
                          style: TextStyle(color: DRColors.white2),
                        ),
                      )
                    ],
                  ),
                  height: 60,
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  padding: const EdgeInsets.fromLTRB(0, 3, 0, 0),
                  width: width / 2 - 20,
                  alignment: Alignment.center,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "max challenge wins",
                        style: TextStyle(color: DRColors.white2),
                      ),
                      Container(
                        decoration: new BoxDecoration(
                            color: Color(0xFF1E1C16),
                            borderRadius: BorderRadius.circular(16)),
                        height: 30,
                        width: 100,
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        alignment: Alignment.center,
                        child: Text(
                          data.player.maxChallengeWins.toString(),
                          style: TextStyle(color: DRColors.white2),
                        ),
                      )
                    ],
                  ),
                  height: 60,
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  padding: const EdgeInsets.fromLTRB(0, 3, 0, 0),
                  width: width / 2 - 20,
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      Text(
                        "total donations",
                        style: TextStyle(color: DRColors.white2),
                      ),
                      Container(
                        decoration: new BoxDecoration(
                            color: Color(0xFF1E1C16),
                            borderRadius: BorderRadius.circular(16)),
                        height: 30,
                        width: 100,
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        alignment: Alignment.center,
                        child: Text(
                          data.player.donations.toString(),
                          style: TextStyle(color: DRColors.white2),
                        ),
                      )
                    ],
                  ),
                  height: 60,
                ),
              ],
            ),
          ],
        )));
  }

  Widget favCardRow(BuildContext context) {
    double width = MediaQuery.of(context).size.width - 20;
    double height = 200;
    if (MediaQuery.of(context).orientation == Orientation.landscape){
      width = width/2 - 10;
      height = 280;
    }
    return Container(
        decoration: new BoxDecoration(
            image: new DecorationImage(
                image: new AssetImage('resources/images/playerBG2.png'),
                fit: BoxFit.cover,),
            borderRadius: BorderRadius.circular(16)),
        height: height,
        width: width,
        margin: const EdgeInsets.fromLTRB(10, 10, 10, 0),
        child: Stack(
          children: [
            Container(
              width: MediaQuery.of(context).size.width - 30,
              //padding: const EdgeInsets.fromLTRB(0, 0, 0, 1),
              child: Image.asset(
                "resources/images/"+data.player.favCard.name.toLowerCase().replaceAll(new RegExp(r"\s+"), "_").replaceAll(".", "")+"2.png",
                alignment: Alignment.bottomRight,
                fit: BoxFit.fitHeight,
              ),
            ),
            Container(
              decoration: new BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Color(0x99000000),
              ),
              width: MediaQuery.of(context).size.width - 20,
              height: height,
            ),
            Container(
                child: Row(
              //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Flexible(
                    flex: 2,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 200,
                          height: 100 * 1.2,
                          alignment: Alignment.center,
                          child: Image.asset(
                            "resources/images/"+data.player.favCard.name.toLowerCase().replaceAll(new RegExp(r"\s+"), "").replaceAll(".", "")+".png",
                            alignment: Alignment.center,
                            fit: BoxFit.fitHeight,
                          ),
                        )
                      ],
                    )),
                Flexible(
                    flex: 3,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 210,
                          height: 120 * 1.2,
                          alignment: Alignment.center,
                          child: Column(
                            children: [
                              SizedBox(
                                height: 30,
                              ),
                              Text(
                                "Favourite card",
                                style: TextStyle(
                                    color: DRColors.white2,
                                    fontSize: 22
                                ),
                              ),
                              SizedBox(
                                height: 16,
                              ),
                              Stack(
                                children: [
                                  Text(
                                    data.player.favCard.name,
                                    style: TextStyle(
                                      fontSize: 16,
                                      foreground: Paint()
                                        ..style = PaintingStyle.stroke
                                        ..strokeWidth = 3
                                        ..color = Color(0xFF5F4400),
                                    ),
                                  ),
                                  Text(
                                    data.player.favCard.name,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Color(0xDDFFA700),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )
                      ],
                    ))
              ],
            )),
          ],
        ));
  }

  Widget lastBattlesRow(BuildContext context) {
    int lastWins = 0;
    int lastLosses = 0;
    double avgCrowns = 0;
    for (int i = 0; i < data.log.length; i++){
      data.log[i].isVictory? lastWins++ : lastLosses++;
      avgCrowns = avgCrowns + data.log[i].gainedCrowns;

    }
    if (data.log.isNotEmpty){
      avgCrowns = avgCrowns/data.log.length;
    }
    else{
      return Container();
    }
    return Container(
      decoration: new BoxDecoration(
          image: new DecorationImage(
              image: new AssetImage('resources/images/playerBG.png'),
              fit: BoxFit.cover,
              colorFilter:
                  ColorFilter.mode(Color(0xDD111111), BlendMode.srcOver)),
          borderRadius: BorderRadius.circular(16)),
      height: 362,
      width: MediaQuery.of(context).size.width - 20,
      margin: const EdgeInsets.fromLTRB(10, 10, 10, 0),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(0, 16, 0, 0),
            child: Text("Last "+data.log.length.toString()+" ladder battles", style: TextStyle(fontSize: 16, color: DRColors.white2),),
          ),
          Align(
              alignment: Alignment.center,
              child: Container(
                  height: 260,
                  width: MediaQuery.of(context).size.width - 10,
                  margin: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                  child: StackedAreaLineChart.withData(data.log)
              )
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.fromLTRB(5, 10, 5, 0),
                padding: const EdgeInsets.fromLTRB(0, 3, 0, 0),
                width: MediaQuery.of(context).size.width / 3 - 20,
                alignment: Alignment.center,
                child: Column(
                  children: [
                    Text(
                      "wins",
                      style: TextStyle(color: DRColors.grey2),
                    ),
                    Container(
                      decoration: new BoxDecoration(
                          color: Color(0xFF1E1C16),
                          borderRadius: BorderRadius.circular(16)),
                      height: 30,
                      width: 100,
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      alignment: Alignment.center,
                      child: Text(
                        lastWins.toString(),
                        style: TextStyle(color: Color(0xFF98BB22)),
                      ),
                    )
                  ],
                ),
                height: 60,
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(5, 10, 5, 0),
                padding: const EdgeInsets.fromLTRB(0, 3, 0, 0),
                width: MediaQuery.of(context).size.width / 3 - 20,
                alignment: Alignment.center,
                child: Column(
                  children: [
                    Text(
                      "losses",
                      style: TextStyle(color: DRColors.grey2),
                    ),
                    Container(
                      decoration: new BoxDecoration(
                          color: Color(0xFF1E1C16),
                          borderRadius: BorderRadius.circular(16)),
                      height: 30,
                      width: 100,
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      alignment: Alignment.center,
                      child: Text(
                        lastLosses.toString(),
                        style: TextStyle(color: Color(0xFFDD5151)),
                      ),
                    )
                  ],
                ),
                height: 60,
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(5, 10, 5, 0),
                padding: const EdgeInsets.fromLTRB(0, 3, 0, 0),
                width: MediaQuery.of(context).size.width / 3 - 20,
                alignment: Alignment.center,
                child: Column(
                  children: [
                    Text(
                      "avg. crowns",
                      style: TextStyle(color: DRColors.grey2),
                    ),
                    Container(
                      decoration: new BoxDecoration(
                          color: Color(0xFF1E1C16),
                          borderRadius: BorderRadius.circular(16)),
                      height: 30,
                      width: 100,
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      alignment: Alignment.center,
                      child: Text(
                        avgCrowns.toStringAsFixed(2),
                        style: TextStyle(color: DRColors.white2),
                      ),
                    )
                  ],
                ),
                height: 60,
              ),
            ],
          ),
        ],
      )
    );
  }

  Widget chestsRow(BuildContext context) {
    return Container(
    width: MediaQuery.of(context).size.width - 20,
    margin: const EdgeInsets.fromLTRB(10, 10, 10, 0),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Container(
          child: Text("Upcoming chests", style: TextStyle(fontSize: 16, color: DRColors.white2),),
        ),
        SizedBox(height: 16,),
        Container(
          child: IgnorePointer(
            child: GridView.count(
              crossAxisCount: MediaQuery.of(context).orientation == Orientation.portrait? 3 : 7,
              childAspectRatio: 1/1.3,
              shrinkWrap: true,
              children: List.generate(data.items.length, (index) {
                return Container(
                    decoration: new BoxDecoration(
                      image: new DecorationImage(
                          image: new AssetImage('resources/images/playerBG.png'),
                          fit: BoxFit.fitHeight,
                          colorFilter: ColorFilter.mode(Color(0x99000000), BlendMode.srcOver)
                      ),
                      borderRadius: BorderRadius.circular(16)
                    ),
                    margin: const EdgeInsets.all(4),
                    child: Stack(
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(height: 4,),
                            Container(padding: const EdgeInsets.all(14), child: Image.asset('resources/images/'+data.items[index].name+'.png'),),
                            Container(
                              child: Text(data.items[index].name,
                                style: TextStyle(fontSize: 11, color: DRColors.white2),
                                textAlign: TextAlign.center,
                              ),
                              alignment: Alignment.center,),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Text(data.items[index].index == 0? "Next" : "+"+data.items[index].index.toString(),
                            style: TextStyle(fontSize: 15, color: DRColors.white2),),
                          alignment: Alignment.topCenter,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            // color: Colors.orange
                          ),
                        ),
                      ],
                    )
                );
              }),
            ),
          )
        )

      ],
    )
    );
  }
}

//Last 25 battles chart
class StackedAreaLineChart extends StatelessWidget {
  final List<charts.Series> seriesList;
  final bool animate;

  StackedAreaLineChart(this.seriesList, {this.animate});

  factory StackedAreaLineChart.withData(List<BattleSmall> lastPvPBattles) {
    return new StackedAreaLineChart(
      _createData(lastPvPBattles),
      // Disable animations for image tests.
      animate: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return new charts.LineChart(seriesList,
        defaultRenderer: new charts.LineRendererConfig(
          includeArea: true,
          stacked: true,
        ),
        selectionModels: [
          new charts.SelectionModelConfig(
              changedListener: (charts.SelectionModel model) {
                Scaffold.of(context).showSnackBar(SnackBar(content: Text(model.selectedSeries[0].measureFn(model.selectedDatum[0].index).toString()),
                duration: Duration(milliseconds: 500),));
                }
          )
        ],
        animate: false,
        primaryMeasureAxis: new charts.NumericAxisSpec(
            tickProviderSpec:
                new charts.BasicNumericTickProviderSpec(zeroBound: false)));
  }

  static List<charts.Series<LinearBattles, int>> _createData(List<BattleSmall> lastPvPBattles) {
    final List<LinearBattles> lastBattles = List.generate(lastPvPBattles.length, (index) {
      return LinearBattles(index, lastPvPBattles[lastPvPBattles.length - index - 1].finalTrophies);
    });

    return [
      new charts.Series<LinearBattles, int>(
        id: 'Last PvP Battles',
        colorFn: (_, __) => charts.MaterialPalette.deepOrange.shadeDefault,
        domainFn: (LinearBattles battles, _) => battles.lastNBattle,
        measureFn: (LinearBattles battles, _) => battles.trophies,
        data: lastBattles,
      )
    ];
  }
}

class LinearBattles {
  final int lastNBattle;
  final int trophies;

  LinearBattles(this.lastNBattle, this.trophies);
}


class ClanPage extends StatelessWidget {
  final String tag;
  final SearchCtrl searchController = new SearchCtrl();

  ClanPage(this.tag);


  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    Widget scaffold =  Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFF141414),
          centerTitle: true,
          title: Text(
            "#$tag".toUpperCase(),
            style: TextStyle(
                fontSize: 16,
                color: DRColors.white),
          ),
        ),
        backgroundColor: DRColors.black,
        body: Container(
            decoration: new BoxDecoration(color: Color(0xFF131313)),
            child: FutureBuilder<Clan>(
                future: searchController.getClan(tag),
                builder:
                    (BuildContext context, AsyncSnapshot<Clan> snapshot) {
                  if (snapshot.hasData) {
                    children = <Widget>[ClanView(clan: snapshot.data)];
                  } else if (snapshot.hasError) {
                    children = <Widget>[Text(snapshot.error.toString())];
                  } else {
                    children = <Widget>[
                      SizedBox(
                        child: CircularProgressIndicator(),
                        width: 50,
                        height: 50,
                      )
                    ];
                  }
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: children,
                    ),
                  );
                })));
    return scaffold;
  }
}

class ClanView extends StatelessWidget {
  final Clan clan;

  ClanView({this.clan});

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).orientation == Orientation.portrait? 6 : 16;
    return Flexible(
        child: Container(
            child: ListView(
              children: [
                Row(
                  children: [
                    mainClanRow(context),
                  ],
                ),
                Row(
                  children: [
                    membersRow(context),
                  ],
                ),
                SizedBox(height: height,),
              ],
            )
        )
    );
  }

  Widget mainClanRow(BuildContext context) {
    return Container(
        decoration: new BoxDecoration(
            image: new DecorationImage(
                image: new AssetImage('resources/images/clan.png'),
                fit: BoxFit.fitWidth,
                colorFilter:
                ColorFilter.mode(Color(0xCC111111), BlendMode.srcOver)),
            borderRadius: BorderRadius.circular(16)),
        height: 180,
        width: MediaQuery.of(context).size.width - 20,
        margin: const EdgeInsets.fromLTRB(10, 10, 10, 0),
        child: Center(
            child: Stack(
              children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(width: 12,),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.fromLTRB(0, 3, 0, 0),
                                  alignment: Alignment.center,
                                  child: Image.asset("resources/images/clanBadge.png"),
                                  height: 36,
                                ),
                                Container(
                                  margin: const EdgeInsets.fromLTRB(10, 0, 5, 0),
                                  padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
                                  alignment: Alignment.center,
                                  child: Text(
                                    clan.name,
                                    style: TextStyle(
                                        fontSize: 20,
                                        color: DRColors.white2
                                    ),
                                  ),
                                  height: 60,
                                ),
                              ]
                          ),
                          Container(
                            margin: const EdgeInsets.fromLTRB(10, 0, 5, 0),
                            padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                            alignment: Alignment.center,
                            child: Text(
                              clan.location.name,
                              style: TextStyle(
                                  fontSize: 13,
                                  color: DRColors.grey2
                              ),
                            ),
                            height: 30,
                          ),
                          Container(
                            margin: const EdgeInsets.fromLTRB(10, 0, 5, 0),
                            padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                            alignment: Alignment.center,
                            child: Text(
                              clan.members.toString() + "/50",
                              style: TextStyle(
                                  fontSize: 14,
                                  color: DRColors.grey2
                              ),
                            ),
                            height: 20,
                          ),
                        ],
                      )
                    ]
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.fromLTRB(0, 3, 0, 0),
                          alignment: Alignment.center,
                          child: Column(
                            children: [
                              Text(
                                "clan score",
                                style: TextStyle(color: DRColors.grey2),
                              ),
                              Container(
                                decoration: new BoxDecoration(
                                    color: Color(0xFF1E1C16),
                                    borderRadius: BorderRadius.circular(16)),
                                height: 30,
                                width: 100,
                                margin: const EdgeInsets.symmetric(vertical: 5),
                                alignment: Alignment.center,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: Image.asset(
                                            "resources/images/trophies.png")),
                                    Container(
                                      margin:
                                      const EdgeInsets.symmetric(horizontal: 5),
                                      padding: const EdgeInsets.fromLTRB(0, 3, 0, 0),
                                      alignment: Alignment.center,
                                      child: Text(
                                        clan.clanScore.toString(),
                                        style: TextStyle(color: DRColors.white2),
                                      ),
                                      height: 30,
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                          height: 60,
                        ),
                        SizedBox(width: 12,),
                        Container(
                          padding: const EdgeInsets.fromLTRB(0, 3, 0, 0),
                          alignment: Alignment.center,
                          child: Column(
                            children: [
                              Text(
                                "required",
                                style: TextStyle(color: DRColors.grey2),
                              ),
                              Container(
                                decoration: new BoxDecoration(
                                    color: Color(0xFF1E1C16),
                                    borderRadius: BorderRadius.circular(16)),
                                height: 30,
                                width: 100,
                                margin: const EdgeInsets.symmetric(vertical: 5),
                                alignment: Alignment.center,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: Image.asset(
                                            "resources/images/trophies.png")),
                                    Container(
                                      margin:
                                      const EdgeInsets.symmetric(horizontal: 5),
                                      padding: const EdgeInsets.fromLTRB(0, 3, 0, 0),
                                      alignment: Alignment.center,
                                      child: Text(
                                        clan.requiredTrophies.toString(),
                                        style: TextStyle(color: DRColors.white2),
                                      ),
                                      height: 30,
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                          height: 60,
                        ),
                        SizedBox(width: 12,),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.fromLTRB(0, 3, 0, 0),
                          alignment: Alignment.center,
                          child: Column(
                            children: [
                              Text(
                                "donations",
                                style: TextStyle(color: DRColors.grey2),
                              ),
                              Container(
                                decoration: new BoxDecoration(
                                    color: Color(0xFF1E1C16),
                                    borderRadius: BorderRadius.circular(16)),
                                height: 30,
                                width: 100,
                                margin: const EdgeInsets.symmetric(vertical: 5),
                                alignment: Alignment.center,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      margin:
                                      const EdgeInsets.symmetric(horizontal: 5),
                                      padding: const EdgeInsets.fromLTRB(0, 3, 0, 0),
                                      alignment: Alignment.center,
                                      child: Text(
                                        clan.donationsPerWeek.toString(),
                                        style: TextStyle(color: DRColors.white2),
                                      ),
                                      height: 30,
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                          height: 60,
                        ),
                        SizedBox(width: 12,),
                        Container(
                          padding: const EdgeInsets.fromLTRB(0, 3, 0, 0),
                          alignment: Alignment.center,
                          child: Column(
                            children: [
                              Text(
                                "clan war",
                                style: TextStyle(color: DRColors.grey2),
                              ),
                              Container(
                                decoration: new BoxDecoration(
                                    color: Color(0xFF1E1C16),
                                    borderRadius: BorderRadius.circular(16)),
                                height: 30,
                                width: 100,
                                margin: const EdgeInsets.symmetric(vertical: 5),
                                alignment: Alignment.center,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: Image.asset(
                                            "resources/images/clanTrophies.png")),
                                    Container(
                                      margin:
                                      const EdgeInsets.symmetric(horizontal: 5),
                                      padding: const EdgeInsets.fromLTRB(0, 3, 0, 0),
                                      alignment: Alignment.center,
                                      child: Text(
                                        clan.clanWarTrophies.toString(),
                                        style: TextStyle(color: DRColors.white2),
                                      ),
                                      height: 30,
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                          height: 60,
                        ),
                        SizedBox(width: 12,),
                      ],
                    )
                  ]
                )
              ],
            )
        )
    );
  }

  Widget membersRow(BuildContext context) {
    List<Widget> players = [];
    for (ClanMember clanPlayer in clan.memberList){
      players.add(Container(
          margin: const EdgeInsets.fromLTRB(0, 0, 0, 10),
          height: 90,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            image: new DecorationImage(
              image: new AssetImage('resources/images/playerBG2.png'),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(Color(0xDD111111), BlendMode.srcOver),
          ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    alignment: Alignment.centerLeft,
                    margin: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                    child: Text(
                      clanPlayer.name,
                      style: TextStyle(
                          fontSize: 16,
                          color: DRColors.white2
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        decoration: new BoxDecoration(
                            color: Color(0x77333333),
                            borderRadius: BorderRadius.circular(16)),
                        height: 34,
                        width: 130,
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              margin: const EdgeInsets.symmetric(horizontal: 5),
                              padding: const EdgeInsets.fromLTRB(0, 3, 0, 0),
                              alignment: Alignment.center,
                              child: Stack(
                                children: [
                                  Text(
                                    (clanPlayer.tag).toUpperCase(),
                                    style: TextStyle(
                                      foreground: Paint()
                                        ..style = PaintingStyle.stroke
                                        ..strokeWidth = 3
                                        ..color = Color(0xFF444444),
                                    ),
                                  ),
                                  Text(
                                    (clanPlayer.tag).toUpperCase(),
                                    style: TextStyle(color: Color(0xFFD3D3D3),
                                    ),
                                  ),
                                ],
                              ),
                              height: 34,
                            ),
                          ],
                        ),
                      ),
                      Container(
                          width: 42,
                          margin: const EdgeInsets.symmetric(horizontal: 5),
                          child: RawMaterialButton(
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => ResultPage(clanPlayer.tag.substring(1))));
                            },
                            fillColor: Color(0x10FFFFFF),
                            child: Icon(
                              CupertinoIcons.arrow_right,
                              color: DRColors.white2,
                              size: 20,
                            ),
                            shape: CircleBorder(),
                          )
                      ),
                    ],
                  )
                ]
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    margin: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                    padding: const EdgeInsets.fromLTRB(0, 3, 0, 0),
                    alignment: Alignment.center,
                    child: Text(
                      clanPlayer.role,
                      style: TextStyle(color: Color(0xBBDDDDDD)),
                    ),
                    height: 30,
                  ),
                  Container(
                    decoration: new BoxDecoration(
                        color: Color(0xFF1E1C16),
                        borderRadius: BorderRadius.circular(16)),
                    height: 30,
                    width: 100,
                    margin: const EdgeInsets.fromLTRB(0, 5, 66, 5),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                            width: 20,
                            height: 20,
                            child: Image.asset(
                                "resources/images/trophies.png")),
                        Container(
                          margin:
                          const EdgeInsets.symmetric(horizontal: 5),
                          padding: const EdgeInsets.fromLTRB(0, 3, 0, 0),
                          alignment: Alignment.center,
                          child: Text(
                            clanPlayer.trophies.toString(),
                            style: TextStyle(color: DRColors.white2),
                          ),
                          height: 30,
                        ),
                      ],
                    ),
                  ),
                ]
              )
            ],
          )
        ),
      );
    }
    return Container(
        decoration: new BoxDecoration(
            image: new DecorationImage(
                image: new AssetImage('resources/images/transparent.png'),
                fit: BoxFit.fitWidth,
                colorFilter:
                ColorFilter.mode(Color(0xCC111111), BlendMode.srcOver)),
            borderRadius: BorderRadius.circular(16)),
        width: MediaQuery.of(context).size.width - 20,
        margin: const EdgeInsets.fromLTRB(10, 10, 10, 0),
        child: Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    margin: const EdgeInsets.fromLTRB(0, 10, 0, 16),
                    child: Text("Players", style: TextStyle(fontSize: 16, color: DRColors.white2),),
                  ),
                  Column(
                    children: players,
                  )
                ]
            )
        )
    );
  }
}

class InfoTagWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            "Where to find Player Tag",
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          backgroundColor: DRColors.black,
        ),
        backgroundColor: Colors.transparent,
        body: Container(
            decoration: new BoxDecoration(
                color: Color(0xFF161616),
            ),
          child:
          Container(
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage('resources/images/deckBuildBackground.png'),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(Color(0xAA000000), BlendMode.srcOver)
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                width: MediaQuery.of(context).size.width - 20,
                margin: const EdgeInsets.all(10),
                padding: const EdgeInsets.all(10),
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 40,
                    ),
                    Text(
                      "Where can you find the \nPlayer Tag?",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Container(
                        padding: const EdgeInsets.all(30),
                        decoration: new BoxDecoration(
                            borderRadius: BorderRadius.circular(32)),
                        child: Container(
                            decoration: new BoxDecoration(
                                borderRadius: BorderRadius.circular(32)),
                            child: Image.asset(
                                "resources/images/infotag.png"
                            )
                        ),
                    ),
                    SizedBox(
                      height: 40,
                    ),
                    Text(
                      "Find the player you want to search...",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                      height: 40,
                    ),
                    Text(
                      "Click the Tag and copy it.\nThere you go!",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
          )
        )
    );
  }

}