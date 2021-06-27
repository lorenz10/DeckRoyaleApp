import 'package:deck_royale_app/controller.dart';
import 'package:deck_royale_app/controller_passive.dart';
import 'package:deck_royale_app/simulate_page.dart';
import 'package:html/dom.dart' as dom;
import 'package:http/http.dart' as http;
import 'package:html/parser.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'build_deck_page.dart';
import 'colors.dart';
import 'dialogs.dart';
import 'home_page.dart';
import 'model.dart';

class EvaluateDeckPage extends StatelessWidget {
  final List<DeckCard> cards;
  final bool optionButtons;
  EvaluateDeckPage({this.cards,this.optionButtons});

  @override
  Widget build(BuildContext context) {
    Widget child;
    if (MediaQuery.of(context).orientation == Orientation.portrait){
      child = ListView(
        children: [
          SizedBox(height: 10,),
          Container(
            child: Row(
              children: [EvaluateDeckRow(cards: cards,buttons: optionButtons)],
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            child: StatsWidget(cards: cards),
          )
        ],
      );
    }
    else{
      child = Row(
        children: [
          Flexible(
            flex: 4,
            child: Column(
              children: [
                EvaluateDeckRow(cards: cards,buttons: optionButtons)
              ],
            ),
          ),
          Flexible(
            flex: 6,
            child: ListView(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  child: StatsWidget(cards: cards),
                )
              ],
            ),
          )
        ],
      );
    }
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFF121212),
          centerTitle: true,
          title: Text(
            optionButtons? 'Your new deck' : 'Problems and tips',
            style: TextStyle(
                fontSize: MediaQuery.of(context).orientation == Orientation.portrait ? 18 : 22,
                color: DRColors.white,
            ),
          ),
        ),
        body: Container(
            decoration: new BoxDecoration(
                color: DRColors.black
            ),
            child: child
        )
    );
  }
}

class StatsWidget extends StatefulWidget {

  final List<DeckCard> cards;
  StatsWidget({this.cards});

  @override
  State<StatefulWidget> createState() => _StatsWidgetState();
}

class _StatsWidgetState extends State<StatsWidget> {
  int fastestCycleCost;
  String htmlFile;

  @override
  void initState() {
    super.initState();
    fastestCycleCost = 0;
  }

  @override
  Widget build(BuildContext context) {
    Widget child;
    return Container(
        decoration: new BoxDecoration(color: DRColors.black),
        child: FutureBuilder<String>(
            future: getHtmlFile(),
            builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
              if (snapshot.hasData) {
                child = buildStatsPage(parseDeckPage(snapshot.data));
              } else if (snapshot.hasError) {
                child = ErrorWidgetCustom("Deck statistics not available.\nCheck your internet connection!");
              } else {
                child = Container(
                    alignment: Alignment.center,
                    height: 300,
                    child: SizedBox(
                      child: CircularProgressIndicator(),
                      width: 50,
                      height: 50,
                    )
                );
              }
              return Center(
                  child: child
              );
            }
        )
    );
  }

  Future<String> getHtmlFile() async {
    String deck = '';
    for(DeckCard card in widget.cards){
      if (MemoryCtrl.getCard(card.id) != null) {
        deck = deck + MemoryCtrl.getCard(card.id).dspro + "-";
      }
    }
    deck = deck.substring(0, deck.length - 1);
    print(deck);
    final response = await http.get('https://www.deckshop.pro/check/?deck=$deck');
    if(response.statusCode == 200){
      return response.body;
    }
    return null;
  }

  DeckStatistics parseDeckPage(String data) {
    String scoreClass = "w-full mb-3";
    String problemsAndWarningsClass = "mb-10 p-2";
    var document = parse(data);
    int d, a, v, s;
    a = getIntegerValueFromTextScore(document.getElementsByClassName(scoreClass)[0].getElementsByTagName("div")[0].getElementsByTagName("div")[1].text);
    d = getIntegerValueFromTextScore(document.getElementsByClassName(scoreClass)[0].getElementsByTagName("div")[3].getElementsByTagName("div")[1].text);
    v = getIntegerValueFromTextScore(document.getElementsByClassName(scoreClass)[0].getElementsByTagName("div")[6].getElementsByTagName("div")[1].text);
    s = getIntegerValueFromTextScore(document.getElementsByClassName(scoreClass)[0].getElementsByTagName("div")[9].getElementsByTagName("div")[1].text);
    print(a.toString() + d.toString() + v.toString() + s.toString());
    List<Problem> problems = [];
    List<Warning> warnings = [];
    List<Info> infos = [];
    for (dom.Element e in document.getElementsByClassName(problemsAndWarningsClass)[0].getElementsByTagName("tr")){
      if(e.getElementsByTagName("th")[0].text == "PROBLEM"){
        problems.add(new Problem(e.getElementsByTagName("td")[0].text.split("\n")[1], e.getElementsByTagName("td")[0].getElementsByTagName("div")[0].text.split("\n")[2]));
      }
      if(e.getElementsByTagName("th")[0].text == "Warning"){
        warnings.add(new Warning(e.getElementsByTagName("td")[0].text.split("\n")[1], e.getElementsByTagName("td")[0].getElementsByTagName("div")[0].text.split("\n")[2]));
      }
      if(e.getElementsByTagName("th")[0].text == "Info"){
        infos.add(new Info(e.getElementsByTagName("td")[0].text.split("\n")[1], e.getElementsByTagName("td")[0].getElementsByTagName("div")[0].text.split("\n")[2]));
      }
    }
    return new DeckStatistics(d, a, v, s, problems, warnings, infos);
  }

  int getIntegerValueFromTextScore(String textScore){
    switch(textScore){
      case "RIP": {
        return 0;
      }
      case "Bad": {
        return 1;
      }
      case "Mediocre": {
        return 2;
      }
      case "Good": {
        return 3;
      }
      case "Great!": {
        return 4;
      }
      case "Godly!": {
        return 5;
      }

      default: {
        return -1;
      }
    }
  }

  Widget buildStatsPage(DeckStatistics stats) {
    double width = MediaQuery.of(context).size.width;
    if (MediaQuery.of(context).orientation == Orientation.landscape){
      width = width/10*6;
    }
    List<Widget> children = [];
    children.add(Container(
        decoration: new BoxDecoration(
            image: new DecorationImage(
                image: new AssetImage('resources/images/deckBuildBackground.png'),
                fit: BoxFit.fitWidth,
                colorFilter:
                ColorFilter.mode(Color(0xBB070400), BlendMode.srcOver)),
            borderRadius: BorderRadius.circular(16)),
        height: 320,
        width: width - 20,
        margin: const EdgeInsets.fromLTRB(10, 10, 10, 0),
        child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  height: 4,
                ),
                Container(
                  child: Text("Deck Rating", style: TextStyle(fontSize: 18, color: Color(0xFFCCCCCC)),),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: 10,
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      padding: const EdgeInsets.fromLTRB(0, 3, 0, 0),
                      width: width / 2 - 20,
                      child: Text(
                        "Defense",
                        style: TextStyle(
                          color: DRColors.grey2,
                          fontSize: 22,
                        ),
                        textAlign: TextAlign.start,
                      ),
                      height: 30,
                    ),
                    Container(
                      decoration: new BoxDecoration(
                          color: Color(0xFF1E1C16),
                          borderRadius: BorderRadius.circular(30)),
                      height: 40,
                      width: 120,
                      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                      alignment: Alignment.center,
                      child: Text(
                        stats.defense.toString() + "/5",
                        style: TextStyle(
                          color: DRColors.getScoreColor(stats.defense),
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: 10,
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      padding: const EdgeInsets.fromLTRB(0, 3, 0, 0),
                      width: width / 2 - 20,
                      child: Text(
                        "Attack",
                        style: TextStyle(
                            color: DRColors.grey2,
                            fontSize: 22
                        ),
                        textAlign: TextAlign.start,
                      ),
                      height: 30,
                    ),
                    Container(
                      decoration: new BoxDecoration(
                          color: Color(0xFF1E1C16),
                          borderRadius: BorderRadius.circular(30)),
                      height: 40,
                      width: 120,
                      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                      alignment: Alignment.center,
                      child: Text(
                        stats.attack.toString() + "/5",
                        style: TextStyle(
                            color: DRColors.getScoreColor(stats.attack),
                            fontSize: 20
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: 10,
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      padding: const EdgeInsets.fromLTRB(0, 3, 0, 0),
                      width: width / 2 - 20,
                      child: Text(
                        "Versatility",
                        style: TextStyle(
                            color: DRColors.grey2,
                            fontSize: 22
                        ),
                        textAlign: TextAlign.start,
                      ),
                      height: 30,
                    ),
                    Container(
                      decoration: new BoxDecoration(
                          color: Color(0xFF1E1C16),
                          borderRadius: BorderRadius.circular(30)),
                      height: 40,
                      width: 120,
                      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                      alignment: Alignment.center,
                      child: Text(
                        stats.versatility.toString() + "/5",
                        style: TextStyle(
                            color: DRColors.getScoreColor(stats.versatility),
                            fontSize: 20
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: 10,
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      padding: const EdgeInsets.fromLTRB(0, 3, 0, 0),
                      width: width / 2 - 20,
                      child: Text(
                        "Synergy",
                        style: TextStyle(
                            color: DRColors.grey2,
                            fontSize: 22
                        ),
                        textAlign: TextAlign.start,
                      ),
                      height: 30,
                    ),
                    Container(
                      decoration: new BoxDecoration(
                          color: Color(0xFF1E1C16),
                          borderRadius: BorderRadius.circular(30)),
                      height: 40,
                      width: 120,
                      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                      alignment: Alignment.center,
                      child: Text(
                        stats.synergy.toString() + "/5",
                        style: TextStyle(
                            color: DRColors.getScoreColor(stats.synergy),
                            fontSize: 20
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: 10,
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      padding: const EdgeInsets.fromLTRB(0, 3, 0, 0),
                      width: width / 2 - 20,
                      child: Text(
                        "Overall",
                        style: TextStyle(
                            color: DRColors.grey2,
                            fontSize: 22
                        ),
                        textAlign: TextAlign.start,
                      ),
                      height: 30,
                    ),
                    Container(
                      decoration: new BoxDecoration(
                          color: Color(0xFF1E1C16),
                          borderRadius: BorderRadius.circular(30)),
                      height: 40,
                      width: 120,
                      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                      alignment: Alignment.center,
                      child: Text(
                        ((stats.defense+stats.attack+stats.versatility+stats.synergy)~/4).toString() + "/5",
                        style: TextStyle(
                            color: DRColors.getScoreColor(((stats.defense+stats.attack+stats.versatility+stats.synergy)~/4)),
                            fontSize: 20
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            )
        )
    ),);
    if(stats.problems.isEmpty){
      children.add(Container(
          decoration: new BoxDecoration(
              image: new DecorationImage(
                  image: new AssetImage('resources/images/deckBuildBackground.png'),
                  fit: BoxFit.fitWidth,
                  colorFilter:
                  ColorFilter.mode(Color(0xBB020700), BlendMode.srcOver)),
              borderRadius: BorderRadius.circular(16)),
          //height: 160,
          width: width - 20,
          margin: const EdgeInsets.fromLTRB(10, 10, 10, 0),
          child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.fromLTRB(0, 14, 0, 0),
                    child: Text("Well Done!", style: TextStyle(fontSize: 18, color: DRColors.lightGreen),),
                  ),
                  Container(
                    padding: const EdgeInsets.all(20),
                    child: Text("Your deck doesn't have significant problems!", style: TextStyle(color: DRColors.white, fontSize: 16), textAlign: TextAlign.center,),
                  ),
                ],
              )
          )
      ),);
    }
    for(Problem p in stats.problems){
      children.add(Container(
          decoration: new BoxDecoration(
              image: new DecorationImage(
                  image: new AssetImage('resources/images/deckBuildBackground.png'),
                  fit: BoxFit.fitWidth,
                  colorFilter:
                  ColorFilter.mode(Color(0xBB070400), BlendMode.srcOver)),
              borderRadius: BorderRadius.circular(16)),
          //height: 160,
          width: width - 20,
          margin: const EdgeInsets.fromLTRB(10, 10, 10, 0),
          child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.fromLTRB(0, 14, 0, 0),
                    child: Text("Problem", style: TextStyle(fontSize: 18, color: DRColors.red),),
                  ),
                  Container(
                    padding: const EdgeInsets.all(20),
                    child: Text(p.title, style: TextStyle(color: DRColors.white, fontSize: 16)),
                  ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
                    child: Text(p.content, style: TextStyle(color: DRColors.white.withOpacity(0.8))),
                  )
                ],
              )
          )
      ),);
    }
    for(Warning w in stats.warnings){
      children.add(Container(
          decoration: new BoxDecoration(
              image: new DecorationImage(
                  image: new AssetImage('resources/images/deckBuildBackground.png'),
                  fit: BoxFit.fitWidth,
                  colorFilter:
                  ColorFilter.mode(Color(0xBB070400), BlendMode.srcOver)),
              borderRadius: BorderRadius.circular(16)),
          //height: 160,
          width: width - 20,
          margin: const EdgeInsets.fromLTRB(10, 10, 10, 0),
          child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.fromLTRB(0, 14, 0, 0),
                    child: Text("Warning", style: TextStyle(fontSize: 18, color: DRColors.yellow),),
                  ),
                  Container(
                    padding: const EdgeInsets.all(20),
                    child: Text(w.title, style: TextStyle(color: DRColors.white, fontSize: 16)),
                  ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
                    child: Text(w.content, style: TextStyle(color: DRColors.white.withOpacity(0.8))),
                  )
                ],
              )
          )
      ),);
    }
    for(Info i in stats.infos){
      children.add(Container(
          decoration: new BoxDecoration(
              image: new DecorationImage(
                  image: new AssetImage('resources/images/deckBuildBackground.png'),
                  fit: BoxFit.fitWidth,
                  colorFilter:
                  ColorFilter.mode(Color(0xBB070400), BlendMode.srcOver)),
              borderRadius: BorderRadius.circular(16)),
          //height: 160,
          width: width - 20,
          margin: const EdgeInsets.fromLTRB(10, 10, 10, 0),
          child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.fromLTRB(0, 14, 0, 0),
                    child: Text("Info", style: TextStyle(fontSize: 18, color: DRColors.lightBlue),),
                  ),
                  Container(
                    padding: const EdgeInsets.all(20),
                    child: Text(i.title, style: TextStyle(color: DRColors.white, fontSize: 16)),
                  ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
                    child: Text(i.content, style: TextStyle(color: DRColors.white.withOpacity(0.8))),
                  )
                ],
              )
          )
      ));
    }
    children.add(Container(
        decoration: new BoxDecoration(
            image: new DecorationImage(
                image: new AssetImage('resources/images/deckBuildBackground.png'),
                fit: BoxFit.fitWidth,
                colorFilter:
                ColorFilter.mode(Color(0xBB070400), BlendMode.srcOver)),
            borderRadius: BorderRadius.circular(16)),
        //height: 160,
        width: width - 20,
        margin: const EdgeInsets.fromLTRB(10, 10, 10, 0),
        child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(0, 14, 0, 0),
                  child: Text("Fastest deck cycle", style: TextStyle(fontSize: 18, color: DRColors.white),),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: getFastestCycle(),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 20),
                  child: Text("Total cost: " + fastestCycleCost.toString(), style: TextStyle(color: DRColors.white.withOpacity(0.8))),
                )
              ],
            )
        )
    ));
    List<DeckCard> levelIndependent = [];
    List<DeckCard> stronger = [];
    List<DeckCard> weaker = [];
    for(DeckCard d in widget.cards){
      if(SingleCard.getLevelIndependence(d.id) == 0){
        levelIndependent.add(d);
      }
      if(SingleCard.getLevelIndependence(d.id) == 1){
        stronger.add(d);
      }
      if(SingleCard.getLevelIndependence(d.id) == 2){
        weaker.add(d);
      }
    }
    double landscapeScale = 1;
    if (MediaQuery.of(context).orientation == Orientation.landscape){
      landscapeScale = 1.2;
    }
    if(levelIndependent.isNotEmpty){
      children.add(Container(
          decoration: new BoxDecoration(
              image: new DecorationImage(
                  image: new AssetImage('resources/images/deckBuildBackground.png'),
                  fit: BoxFit.fitWidth,
                  colorFilter:
                  ColorFilter.mode(Color(0xBB070400), BlendMode.srcOver)),
              borderRadius: BorderRadius.circular(16)),
          //height: 160,
          width: width - 20,
          margin: const EdgeInsets.fromLTRB(10, 10, 10, 0),
          child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.fromLTRB(0, 14, 0, 0),
                    child: Text("Level independent cards", style: TextStyle(fontSize: 18, color: DRColors.white),),
                  ),
                  Container(
                      padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width/7, vertical: 20),
                      height: (132 + 90*((levelIndependent.length-1)~/4).toDouble()) * landscapeScale,
                      child: IgnorePointer(
                        child: GridView.count(
                          children: levelIndependent,
                          crossAxisCount: 4,
                          childAspectRatio: 1/1.2,
                        ),
                      )
                  ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
                    child: Text("Cards that are good even on lower level. Their key stats are not influenced by the level too much and no key interactions are level-dependent.", style: TextStyle(color: DRColors.white.withOpacity(0.8))),
                  )
                ],
              )
          )
      ));
    }
    if(stronger.isNotEmpty){
      children.add(Container(
          decoration: new BoxDecoration(
              image: new DecorationImage(
                  image: new AssetImage('resources/images/deckBuildBackground.png'),
                  fit: BoxFit.fitWidth,
                  colorFilter:
                  ColorFilter.mode(Color(0xBB070400), BlendMode.srcOver)),
              borderRadius: BorderRadius.circular(16)),
          //height: 160,
          width: width - 20,
          margin: const EdgeInsets.fromLTRB(10, 10, 10, 0),
          child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.fromLTRB(0, 14, 0, 0),
                    child: Text("Strong when over-leveled", style: TextStyle(fontSize: 18, color: DRColors.white),),
                  ),
                  Container(
                      padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width/7, vertical: 20),
                      height: (132 + 90*((levelIndependent.length-1)~/4).toDouble()) * landscapeScale,
                      child: IgnorePointer(
                        child: GridView.count(
                          children: stronger,
                          crossAxisCount: 4,
                          childAspectRatio: 1/1.2,
                        ),
                      )
                  ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
                    child: Text("Cards that are particularly strong if you have them on higher level. Their key interactions with some cards are changed when they are level or two above the other card.", style: TextStyle(color: DRColors.white.withOpacity(0.8))),
                  )
                ],
              )
          )
      ));
    }
    if(weaker.isNotEmpty){
      children.add(Container(
          decoration: new BoxDecoration(
              image: new DecorationImage(
                  image: new AssetImage('resources/images/deckBuildBackground.png'),
                  fit: BoxFit.fitWidth,
                  colorFilter:
                  ColorFilter.mode(Color(0xBB070400), BlendMode.srcOver)),
              borderRadius: BorderRadius.circular(16)),
          //height: 160,
          width: width - 20,
          margin: const EdgeInsets.fromLTRB(10, 10, 10, 0),
          child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.fromLTRB(0, 14, 0, 0),
                    child: Text("Weak when under-leveled", style: TextStyle(fontSize: 18, color: DRColors.white),),
                  ),
                  Container(
                      padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width/7, vertical: 20),
                      height: (132 + 90*((weaker.length-1)~/4).toDouble()) * landscapeScale,
                      child: IgnorePointer(
                        child: GridView.count(
                          children: weaker,
                          crossAxisCount: 4,
                          childAspectRatio: 1/1.2,
                        ),
                      )
                  ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
                    child: Text("Cards that are particularly weak if you have them on lower level. Their key interactions with some cards are changed when they are level or two below the other card.", style: TextStyle(color: DRColors.white.withOpacity(0.8))),
                  )
                ],
              )
          )
      ));
    }
    children.add(SizedBox(height: 10,));
    return Column(
        children: children
    );
  }

  List<DeckCard> getFastestCycle() {
    List<SingleCard> fastestCycle = [];
    List<DeckCard> fastestCycleReturn = [];
    for(DeckCard d in widget.cards){
      for(SingleCard card in App.gameCards.items){
        if (card.id == d.id){
          fastestCycle.add(card);
        }
      }
    }
    fastestCycle.sort((a, b) => a.cost.compareTo(b.cost));
    int c = 0;
    fastestCycleCost = 0;
    for(SingleCard s in fastestCycle){
      for(DeckCard d in widget.cards){
        if(d.id == s.id && s.cost != 0){
          fastestCycleReturn.add(d);
          fastestCycleCost += s.cost;
          c++;
        }
        if(c > 3) break;
      }
      if(c > 3) break;
    }
    return fastestCycleReturn;
  }
}


class EvaluateDeckRow extends StatefulWidget{
  final List cards;
  final bool buttons; //True if showed in Evaluate Deck page

  EvaluateDeckRow({this.cards, this.buttons});

  @override
  State<StatefulWidget> createState() => _EvaluateDeckRow();
}

class _EvaluateDeckRow extends State<EvaluateDeckRow>{
  List<Widget> children;
  double _cardWidth;
  double _elixirWidth;

  @override
  Widget build(BuildContext context) {
    _cardWidth = MediaQuery.of(context).size.width / 10.6;
    _elixirWidth = MediaQuery.of(context).size.width / 40;
    double width = MediaQuery.of(context).size.width;
    if (MediaQuery.of(context).orientation == Orientation.landscape){
      width = width/10*4;
    }
    width = width - 20;

    if(widget.buttons){
      children = [
        Row(
          children: [
            EvaluateDeck(cards: widget.cards, width: width)
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const  EdgeInsets.only(right: 20),
              child: Text(
                "Avg elixir",
                style: TextStyle(
                  fontSize: 16,
                  color: DRColors.grey,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: DRColors.value,
                borderRadius: BorderRadius.circular(16),
              ),
              height: MediaQuery.of(context).orientation == Orientation.portrait ? 30 : 35,
              width: 60,
              margin: const EdgeInsets.symmetric(vertical: 5),
              alignment: Alignment.center,
              child: Text(
                avgElixir(),
                style: TextStyle(
                  color: DRColors.elixir,
                  fontSize: 22,
                ),
              ),
            ),
          ]
        ),
        SizedBox(height: MediaQuery.of(context).orientation == Orientation.portrait? 10 : MediaQuery.of(context).size.height/6,),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
              margin: const EdgeInsets.fromLTRB(8, 0, 4, 0),
              height: MediaQuery.of(context).size.height / 20,
              width: MediaQuery.of(context).size.width/2 - 24,
              decoration: BoxDecoration(
                color: DRColors.orange.withOpacity(0.5),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(
                  color: DRColors.orange.withOpacity(0.6),
                  width: 4,
                ),
              ),
              child:
              ButtonTheme(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(30.0))),
                minWidth: width / 2 - 24,
                height: MediaQuery.of(context).size.height / 15,
                child: RaisedButton(
                  elevation: 0.0,
                  onPressed: () {Navigator.pop(context);},
                  color: DRColors.orange,
                  child: Text(
                    "Modify Deck",
                    style: TextStyle(
                        color: DRColors.black2,
                        fontSize: 14
                    ),
                  ),
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.fromLTRB(8, 0, 4, 0),
              height: MediaQuery.of(context).size.height / 20,
              width: MediaQuery.of(context).size.width/2 - 24,
              decoration: BoxDecoration(
                color: DRColors.orange.withOpacity(0.5),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(
                  color: DRColors.orange.withOpacity(0.6),
                  width: 4,
                ),
              ),
              child:
              ButtonTheme(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(30.0))),
                minWidth: width / 2 - 24,
                height: MediaQuery.of(context).size.height / 15,
                child: RaisedButton(
                  elevation: 0.0,
                  onPressed: () {_tryDeck();},
                  color: DRColors.orange,
                  child: Text(
                    "Try Deck",
                    style: TextStyle(
                        color: DRColors.black2,
                        fontSize: 14
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
        SizedBox(height:8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
              margin: const EdgeInsets.fromLTRB(8, 0, 4, 0),
              height: MediaQuery.of(context).size.height / 20,
              width: MediaQuery.of(context).size.width/2 - 24,
              decoration: BoxDecoration(
                color: DRColors.orange.withOpacity(0.5),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(
                  color: DRColors.orange.withOpacity(0.6),
                  width: 4,
                ),
              ),
              child:
              ButtonTheme(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(30.0))),
                minWidth: width / 2 - 24,
                height: MediaQuery.of(context).size.height / 15,
                child: RaisedButton(
                  elevation: 0.0,
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (BuildContext context){
                          return AddDeckDialog(
                              Deck(
                                  List.from(getIntIDs()),
                                  getAvgCost()
                              )
                          );
                        });
                  },
                  color: DRColors.orange,
                  child: Text(
                    "Add to Folder",
                    style: TextStyle(
                        color: DRColors.black2,
                        fontSize: 14
                    ),
                  ),
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.fromLTRB(8, 0, 4, 0),
              height: MediaQuery.of(context).size.height / 20,
              width: MediaQuery.of(context).size.width/2 - 24,
              decoration: BoxDecoration(
                color: DRColors.orange.withOpacity(0.5),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(
                  color: DRColors.orange.withOpacity(0.6),
                  width: 4,
                ),
              ),
              child:
              ButtonTheme(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(30.0))),
                minWidth: width / 2 - 24,
                height: MediaQuery.of(context).size.height / 15,
                child: RaisedButton(
                  elevation: 0.0,
                  onPressed: () {
                    Navigator.pop(context);
                    HomeCtrl.me.setTab(DRTabs.simulator);
                    SimulateCtrl.me.simulateDeck(List.from(getIntIDs()),_cardWidth + 16,_elixirWidth+3);
                    Navigator.push( context, MaterialPageRoute(
                        builder: (context) => GameSimulatorWidget(isRandomDeck: false)),
                    );
                  },
                  color: DRColors.orange,
                  child: Text(
                    "Simulate Deck",
                    style: TextStyle(
                        color: DRColors.black2,
                        fontSize: 14
                    ),
                  ),
                ),
              ),
            )
          ],
        )
      ];
      if (MediaQuery.of(context).orientation == Orientation.landscape){
        children = [
          Row(
            children: [
              EvaluateDeck(cards: widget.cards, width: width)
            ],
          ),
          SizedBox(height: MediaQuery.of(context).orientation == Orientation.portrait? 10 : MediaQuery.of(context).size.height/6,),
          Column(
            children: [
              ButtonTheme(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(30.0))),
                minWidth: width / 2 + 50,
                height: MediaQuery.of(context).size.height / 19,
                child: RaisedButton(
                  onPressed: () {Navigator.pop(context);},
                  color: DRColors.orange,
                  child: Text(
                    "Modify Deck",
                    style: TextStyle(
                        color: DRColors.black2,
                        fontSize: 14
                    ),
                  ),
                ),
              ),
              ButtonTheme(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(30.0))),
                minWidth: width / 2 + 50,
                height: MediaQuery.of(context).size.height / 19,
                child: RaisedButton(
                  onPressed: () {_tryDeck();},
                  color: DRColors.orange,
                  child: Text(
                    "Try Deck",
                    style: TextStyle(
                        color: DRColors.black2,
                        fontSize: 14
                    ),
                  ),
                ),
              ),
              ButtonTheme(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(30.0))),
                minWidth: width / 2 + 50,
                height: MediaQuery.of(context).size.height / 19,
                child: RaisedButton(
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (BuildContext context){
                          return AddDeckDialog(
                              Deck(
                                  List.from(getIntIDs()),
                                  getAvgCost()
                              )
                          );
                        });
                  },
                  color: DRColors.orange,
                  child: Text(
                    "Add to Folder",
                    style: TextStyle(
                        color: DRColors.black2,
                        fontSize: 14
                    ),
                  ),
                ),
              ),
              ButtonTheme(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(30.0))),
                minWidth: width / 2 + 50,
                height: MediaQuery.of(context).size.height / 19,
                child: RaisedButton(
                  onPressed: () {Navigator.pop(context);},
                  color: DRColors.orange,
                  child: Text(
                    "Simulate Deck",
                    style: TextStyle(
                        color: DRColors.black2,
                        fontSize: 14
                    ),
                  ),
                ),
              ),
            ],
          ),
        ];
      }
    }else{
      children = [
        Row(
          children: [
            SizedBox(
              //height: MediaQuery.of(context).size.height/3,
              child: EvaluateDeck(cards: widget.cards, width: width)
            )
          ],
        ),
        Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const  EdgeInsets.only(right: 20),
                child: Text(
                  "Avg elixir",
                  style: TextStyle(
                    fontSize: 16,
                    color: DRColors.grey,
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: DRColors.value,
                  borderRadius: BorderRadius.circular(16),
                ),
                height: MediaQuery.of(context).orientation == Orientation.portrait ? 30 : 35,
                width: 60,
                margin: const EdgeInsets.symmetric(vertical: 5),
                alignment: Alignment.center,
                child: Text(
                  avgElixir(),
                  style: TextStyle(
                    color: DRColors.elixir,
                    fontSize: 22,
                  ),
                ),
              ),
            ]
        ),
        SizedBox(height: 6,)
      ];
    }

    return Center(
      child: Container(
        decoration: new BoxDecoration(
            image: new DecorationImage(
                image: new AssetImage('resources/images/deckBuildBackground.png'),
                fit: BoxFit.fitWidth,
                colorFilter:
                ColorFilter.mode(Color(0xBB070400), BlendMode.srcOver)),
            borderRadius: BorderRadius.circular(16)),
        width: width,
        margin: const EdgeInsets.symmetric(horizontal: 10),
        //height: MediaQuery.of(context).orientation == Orientation.portrait? (widget.buttons?320:190) : MediaQuery.of(context).size.height - 80,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: children,
        ),
      ),
    );
  }

  void _tryDeck() async {
    String url = "https://link.clashroyale.com/deck/en?deck=" + getIDs();
    await launch(url);
  }

  String getIDs() {
    String ids = '';
    for (DeckCard card in widget.cards){
      ids = ids + card.id.toString() + ";";
    }
    return ids.substring(0, ids.length - 1);
  }
  List<int> getIntIDs() {
    List<int> list = [];
    for (DeckCard card in widget.cards){
      list.add(card.id);
    }
    return list;
  }
  double getAvgCost() {
    int avg = 0;
    for (DeckCard card in widget.cards){
      avg = avg + MemoryCtrl.getCard(card.id).cost;
    }
    return avg/8;
  }

  String avgElixir() {
    double avgElixir = 0;
    for(DeckCard card in widget.cards){
      avgElixir += MemoryCtrl.getCard(card.id).cost.toDouble();
    }
    return (avgElixir/8).toStringAsFixed(1);
  }

}

class EvaluateDeck extends StatefulWidget{

  final List cards;
  final double width;

  EvaluateDeck({
    this.cards,
    this.width
  });

  @override
  State<StatefulWidget> createState() => _EvaluateDeck();
}

class _EvaluateDeck extends State<EvaluateDeck> {

  @override
  Widget build(BuildContext context) {
    int factor;
    factor = MediaQuery.of(context).orientation == Orientation.portrait? 6 : 12;
    return Container(
        padding: EdgeInsets.symmetric(vertical: 7.0, horizontal: widget.width *1/factor - 10),
        child: Hero(
          tag: 'bd',
          child: Column(
            children: [
              Row(
                children: [
                  Column(children: [widget.cards[0]]),
                  Column(children: [widget.cards[1]]),
                  Column(children: [widget.cards[2]]),
                  Column(children: [widget.cards[3]]),
                ],
              ),
              Row(
                children: [
                  Column(children: [widget.cards[4]]),
                  Column(children: [widget.cards[5]]),
                  Column(children: [widget.cards[6]]),
                  Column(children: [widget.cards[7]]),
                ],
              ),
            ],
          ),
        )
    );
  }
}