import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'colors.dart';
import 'package:spritewidget/spritewidget.dart';
import 'model.dart';
import 'package:deck_royale_app/controller.dart';
import 'dart:math';
import 'dart:async';

class SimulateWidget extends StatefulWidget {
  @override
  _SimulateWidgetState createState() => _SimulateWidgetState();
}

class _SimulateWidgetState extends StateMVC<SimulateWidget> {
  _SimulateWidgetState():super(SimulateCtrl());

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(image: DRColors.background),
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: Column(
        children: [
          SimulateItem(key: UniqueKey(), index: 0, text: "Personal Deck"),
          SimulateItem(key: UniqueKey(), index: 1, text: "Random Deck"),
          SizedBox(height: 10,)
        ]
      ),
    );
  }
}

class SimulateItem extends StatefulWidget {
  final int index;
  final String text;
  SimulateItem({Key key, this.index, this.text});

  @override
  State<StatefulWidget> createState() => SimulateItemState();
}

class SimulateItemState extends StateMVC<SimulateItem> with TickerProviderStateMixin {
  double _width;
  bool _neverTapped;

  @override
  void initState() {
    _neverTapped = true;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    EdgeInsetsGeometry margin = EdgeInsets.fromLTRB(10, 10, 10, 0);
    if (MediaQuery.of(context).orientation == Orientation.landscape){
      margin = EdgeInsets.fromLTRB(10, 10, 0, 0);
    }
    if (_neverTapped){
      _width = MediaQuery.of(context).size.width;
    }
    return Expanded(
        child: AnimatedSize(
            duration: Duration(seconds: 3),
            vsync: this,
            curve: Curves.decelerate,
            child: GestureDetector(
              onTap: () {
                if (!(widget.index==0 && SimulateCtrl.me.list.length!=8 && SimulateCtrl.me.viewList.length!=8)) {
                  Navigator.push( context, MaterialPageRoute(
                      builder: (context) => GameSimulatorWidget(isRandomDeck: widget.index == 1 ? true:false)),
                  );
                }
                if (SimulateCtrl.me.list.length!=8 && widget.index==0){
                  Scaffold.of(context).showSnackBar(SnackBar(content: Text("Choose your deck from the build page or pick one from your folders!"), duration: Duration(seconds: 1),));
                }
              },
              child: Listener(
                onPointerDown: (PointerDownEvent p) {
                  setState(() {
                    _neverTapped = false;
                    _width = MediaQuery.of(context).size.width - 20.0;
                  });
                },
                onPointerUp: (PointerUpEvent p) {
                  setState(() {
                    _width = _width + 20.0;
                  });
                },
                onPointerCancel: (PointerCancelEvent p) {
                  setState(() {
                    _width = _width + 20.0;
                  });
                },
                child: Container(
                    width: _width - 10,
                    margin: margin,
                    decoration: BoxDecoration(
                      color: DRColors.black2,
                      borderRadius: BorderRadius.circular(16),
                      image: DecorationImage(
                        image: AssetImage('resources/images/Folder_${widget.index}${widget.index}.png'),
                        colorFilter: ColorFilter.mode(Color(0xFF000000), BlendMode.color),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Container(
                        width: _width - 10,
                        padding: const EdgeInsets.fromLTRB(16, 10, 12, 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: DRColors.black.withOpacity(0.3),
                            width: 6,
                          ),
                          image: DecorationImage(
                            image: AssetImage('resources/images/opacity.png'),
                            colorFilter: ColorFilter.mode(Color(0xFF7A7A7A).withOpacity(0.6), BlendMode.color),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Stack(
                            children: [
                              Center(
                                  child: Row(
                                    children: [
                                      SizedBox(width: 20,),
                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.fromLTRB(0, 4, 0, 10),
                                            child: Text(
                                              widget.text,
                                              textAlign: TextAlign.center,
                                              maxLines: 2,
                                              style: TextStyle(
                                                color: DRColors.white2,
                                                fontSize: MediaQuery.of(context).orientation == Orientation.portrait ? 20 : 24,
                                                shadows: <Shadow>[
                                                  Shadow(
                                                    color: Colors.black54,
                                                    offset: const Offset(2.0, 2.0),
                                                    blurRadius: 4.0,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: 10,),
                                          widget.index == 0 && SimulateCtrl.me.viewList.isNotEmpty?
                                          Column(
                                            children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: SimulateCtrl.me.viewList.sublist(0,4),
                                              ),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: SimulateCtrl.me.viewList.sublist(4,8),
                                              ),
                                            ],
                                          )
                                              :
                                          widget.index==0?
                                          Text(
                                            "Choose your deck from the\nbuild page or pick one from\nyour folders!",
                                            maxLines: 3,
                                            style: TextStyle(
                                              color: DRColors.white2,
                                              fontSize: MediaQuery.of(context).orientation == Orientation.portrait ? 16 : 20,
                                              shadows: <Shadow>[
                                                Shadow(
                                                  color: Colors.black54,
                                                  offset: const Offset(2.0, 2.0),
                                                  blurRadius: 4.0,
                                                ),
                                              ],
                                            ),
                                          )
                                              :
                                          Text(
                                            "Are you skilled enough to\nplay with a random deck?\nLet's find out!",
                                            maxLines: 3,
                                            style: TextStyle(
                                              color: DRColors.white2,
                                              fontSize: MediaQuery.of(context).orientation == Orientation.portrait ? 16 : 20,
                                              shadows: <Shadow>[
                                                Shadow(
                                                  color: Colors.black54,
                                                  offset: const Offset(2.0, 2.0),
                                                  blurRadius: 4.0,
                                                ),
                                              ],
                                            ),
                                          )
                                        ],
                                      )
                                    ],
                                  )
                              ),
                            ]
                        )
                    )
                ),
              ),
            )
        )
    );
  }
}

class GameSimulatorWidget extends StatefulWidget {

  final bool isRandomDeck;

  const GameSimulatorWidget({Key key, this.isRandomDeck}) : super(key: key);

  @override
  GameSimulatorWidgetState createState() => new GameSimulatorWidgetState();
}

class GameSimulatorWidgetState extends State<GameSimulatorWidget> {
  NodeWithSize rootNode;
  static double width;
  static double height;
  static double currentElixir;
  AudioPlayer musicPlayer;
  int turn;
  Sprite containerImage;
  Sprite backgroundImage;
  Sprite playerDeckWoodImage;
  Sprite opponentDeckWoodImage;
  Sprite opacityImage;
  Sprite elixirBar;
  Sprite elixirColor;
  Sprite dragText;
  List<Sprite> playerDeckSprites;
  static List<CardSprite> playerDeckRotationSprites;
  static List<Sprite> playerDeckRotationElixirSprites;
  List<Sprite> opponentDeckSprites;
  List<SingleCard> opponentDeck;
  List<SingleCard> playerDeck;
  Timer timer;

  Random random;
  List<int> generator;

  int finishedTurn = 0; //0 not finished, 1 finished ok, 2 finished wrong
  int rightCards = 0;
  int wrongCards = 0;
  int rightCardIndex = -1;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown
    ]);
    turn = 0;
    currentElixir = 6;
    playerDeckSprites = [];
    opponentDeckSprites = [];
    playerDeckRotationSprites = [];
    playerDeckRotationElixirSprites = [];
    opponentDeck = SimulateCtrl.me.getOpponentRandomDeck();
    if(widget.isRandomDeck){
      playerDeck = SimulateCtrl.me.getPlayerRandomDeck();
    }else{
      playerDeck = SimulateCtrl.me.list;
    }
    loadMusic();
    random = Random(1234);
    generator = List.generate(8, (index) => index);
    generator.shuffle(random);
    rightCardIndex = SimulateCtrl.getAlphabeticalIndex(playerDeck);
  }

  Future loadMusic() async {
    musicPlayer = await AudioCache(prefix: "").loop("resources/audio/simulate.ogg");
  }

  @override
  void dispose() {
    musicPlayer.stop();
    musicPlayer = null;
    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom, SystemUiOverlay.top]);
    var shortestSide = MediaQueryData.fromWindow(WidgetsBinding.instance.window).size.shortestSide;
    final bool useMobileLayout = shortestSide < 600;
    if(useMobileLayout){
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown
      ]);
    }
    else{
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeRight,
        DeviceOrientation.landscapeLeft
      ]);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    MotionTween swipeDownMyDeck = new MotionTween<Offset> (
          (a) => playerDeckWoodImage.position = a,
      Offset(MediaQuery.of(context).size.width/2, MediaQuery.of(context).size.width*16/9 - 39),
      Offset(MediaQuery.of(context).size.width/2, MediaQuery.of(context).size.width*16/9 + 70),
      6.0,
      Curves.bounceOut,
    );

    MotionTween swipeUpOpponentDeck = new MotionTween<Offset> (
          (a) => opponentDeckWoodImage.position = a,
      Offset(MediaQuery.of(context).size.width/2, 39),
      Offset(MediaQuery.of(context).size.width/2, - 70),
      6.0,
      Curves.bounceOut,
    );

    MotionTween rescaleBackground = new MotionTween<double> (
            (a) => backgroundImage.scale = a,
        MediaQuery.of(context).size.width/750,
        MediaQuery.of(context).size.width/936,
        3.0,
        Curves.decelerate
    );

    MotionTween removeOpacity = new MotionTween<double> (
            (a) => opacityImage.opacity = a,
        1.0,
        0.0,
        3.0
    );

    MotionTween rescaleCard0 = new MotionTween<double> (
            (a) => playerDeckRotationSprites.elementAt(0).scale = a,
        MediaQuery.of(context).size.width/1280,
        MediaQuery.of(context).size.width/1600,
        3.0,
        Curves.decelerate
    );
    MotionTween rescaleCard1 = new MotionTween<double> (
            (a) => playerDeckRotationSprites.elementAt(1).scale = a,
        MediaQuery.of(context).size.width/1280,
        MediaQuery.of(context).size.width/1600,
        3.0,
        Curves.decelerate
    );
    MotionTween rescaleCard2 = new MotionTween<double> (
            (a) => playerDeckRotationSprites.elementAt(2).scale = a,
        MediaQuery.of(context).size.width/1280,
        MediaQuery.of(context).size.width/1600,
        3.0,
        Curves.decelerate
    );
    MotionTween rescaleCard3 = new MotionTween<double> (
            (a) => playerDeckRotationSprites.elementAt(3).scale = a,
        MediaQuery.of(context).size.width/1280,
        MediaQuery.of(context).size.width/1600,
        3.0,
        Curves.decelerate
    );

    MotionTween swipeUpCard0 = new MotionTween<Offset> (
            (a) => playerDeckRotationSprites.elementAt(0).position = a,
        Offset(MediaQuery.of(context).size.width/3.65 + MediaQuery.of(context).size.width/4.1*0, MediaQuery.of(context).size.width*16/9-6),
        Offset(MediaQuery.of(context).size.width/3.16 + MediaQuery.of(context).size.width/5.26*0, MediaQuery.of(context).size.width*16/9 - MediaQuery.of(context).size.width/5.353),
        3.0,
        Curves.decelerate
    );
    MotionTween swipeUpCard1 = new MotionTween<Offset> (
            (a) => playerDeckRotationSprites.elementAt(1).position = a,
        Offset(MediaQuery.of(context).size.width/3.65 + MediaQuery.of(context).size.width/4.2*1, MediaQuery.of(context).size.width*16/9-6),
        Offset(MediaQuery.of(context).size.width/3.16 + MediaQuery.of(context).size.width/5.26*1, MediaQuery.of(context).size.width*16/9 - MediaQuery.of(context).size.width/5.353),
        3.0,
        Curves.decelerate
    );
    MotionTween swipeUpCard2 = new MotionTween<Offset> (
            (a) => playerDeckRotationSprites.elementAt(2).position = a,
        Offset(MediaQuery.of(context).size.width/3.75 + MediaQuery.of(context).size.width/4.2*2, MediaQuery.of(context).size.width*16/9-6),
        Offset(MediaQuery.of(context).size.width/3.16 + MediaQuery.of(context).size.width/5.26*2, MediaQuery.of(context).size.width*16/9 - MediaQuery.of(context).size.width/5.353),
        3.0,
        Curves.decelerate
    );
    MotionTween swipeUpCard3 = new MotionTween<Offset> (
            (a) => playerDeckRotationSprites.elementAt(3).position = a,
        Offset(MediaQuery.of(context).size.width/3.75 + MediaQuery.of(context).size.width/4.2*3, MediaQuery.of(context).size.width*16/9-6),
        Offset(MediaQuery.of(context).size.width/3.16 + MediaQuery.of(context).size.width/5.26*3, MediaQuery.of(context).size.width*16/9 - MediaQuery.of(context).size.width/5.353),
        3.0,
        Curves.decelerate
    );

    MotionTween elixirGrow = new MotionTween<double> (
            (a) => elixirColor.scaleX = a,
        1.075*currentElixir, //every elixir unit circa 1,075 scale of x
        10.5,
        2.7*(10.0 - currentElixir)
    );

    MotionTween elixirMove = new MotionTween<Offset> (
            (a) => elixirColor.position = a,
        Offset(244 + 34*currentElixir, 1623), //every elixir unit 34 offset of x
        Offset(584, 1623),
        2.7*(10.0 - currentElixir)
    );

    MotionTween showDragText = new MotionTween<double> (
            (a) => dragText.opacity = a,
        0.0,
        1.0,
        2.0
    );

    MotionTween hideDragText = new MotionTween<double> (
            (a) => dragText.opacity = a,
        1.0,
        0.0,
        0.3
    );

    MotionTween showOpacity = new MotionTween<double> (
            (a) => opacityImage.opacity = a,
        0.0,
        1.0,
        0.5
    );

    if(turn==0){
      loadSprites();
    }else if(turn==1){ //First turn
      Timer.periodic(Duration(milliseconds: 70), (t)
      {
        currentElixir += 0.1;
        if(!(currentElixir < 10)){
          t.cancel();
        }
      });
      turn++;
      playerDeckWoodImage.motions.run(swipeDownMyDeck);
      opponentDeckWoodImage.motions.run(swipeUpOpponentDeck);
      backgroundImage.motions.run(rescaleBackground);
      opacityImage.motions.run(removeOpacity);
      playerDeckRotationSprites.elementAt(0).motions.run(rescaleCard0);
      playerDeckRotationSprites.elementAt(1).motions.run(rescaleCard1);
      playerDeckRotationSprites.elementAt(2).motions.run(rescaleCard2);
      playerDeckRotationSprites.elementAt(3).motions.run(rescaleCard3);
      playerDeckRotationSprites.elementAt(0).motions.run(swipeUpCard0);
      playerDeckRotationSprites.elementAt(1).motions.run(swipeUpCard1);
      playerDeckRotationSprites.elementAt(2).motions.run(swipeUpCard2);
      playerDeckRotationSprites.elementAt(3).motions.run(swipeUpCard3);
      elixirColor.motions.run(elixirGrow);
      elixirColor.motions.run(elixirMove);

      Future.delayed(const Duration(seconds: 3), () {
        opponentDeckWoodImage.removeAllChildren();
        dragText.motions.run(showDragText);
        rootNode.removeChild(opponentDeckWoodImage);
        rootNode.addChild(opponentDeckSprites[generator[1]]);
        opponentMove(opponentDeckSprites[generator[1]]);
      });
    }else if(turn>1 && turn<9){ //All the other turns
      Future.delayed(Duration(milliseconds: 1), () {
        rootNode.removeChild(opponentDeckSprites[generator[turn-2]]);
        rootNode.addChild(opponentDeckSprites[generator[turn-1]]);
        opponentMove(opponentDeckSprites[generator[turn-1]]);
      });
    }
    else{
      Future.delayed(Duration(milliseconds: 10), () {
        rootNode.removeChild(opponentDeckSprites[generator[turn-2]]);
        opacityImage.motions.run(showOpacity);
        dragText.motions.run(hideDragText);
      });
    }

    Widget child;
    if(turn>0 && turn<9){
      if(finishedTurn == 0){
        child = Stack(children: [
          SpriteWidget(rootNode, SpriteBoxTransformMode.scaleToFit),
        ]);
      }
      else if(finishedTurn == 1){
        child = Stack(children: [
          SpriteWidget(rootNode, SpriteBoxTransformMode.scaleToFit),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 40,),
              Container(
                width: MediaQuery.of(context).size.width,
                child: Text(
                  'Well Done!',
                  style: TextStyle(
                      fontSize: 28,
                      color: DRColors.green
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 20,),
              Text(
                'You chose the right card,\nready for the next one?',
                style: TextStyle(
                    fontSize: 18,
                    color: DRColors.white
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ]);
      }
      else{
        child = Stack(children: [
          SpriteWidget(rootNode, SpriteBoxTransformMode.scaleToFit),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 40,),
              Container(
                width: MediaQuery.of(context).size.width,
                child: Text(
                  'Wrong Card...',
                  style: TextStyle(
                      fontSize: 28,
                      color: DRColors.red
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 20,),
              Text(
                'Try again, choose the right card!',
                style: TextStyle(
                    fontSize: 18,
                    color: DRColors.white
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ]);
      }
    }
    else if (turn == 0) {
      child = Stack(
          children: [
            SpriteWidget(rootNode, SpriteBoxTransformMode.scaleToFit),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Contrast the opponent moves with the best of your cards!',
                  style: TextStyle(
                      fontSize: 18,
                      color: DRColors.white
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 140,),
                TextureButton(
                  width: MediaQuery.of(context).size.width/2.5,
                  height: (MediaQuery.of(context).size.width/2.5)*(App.simulateImages["resources/images/button.png"].height.toDouble()/App.simulateImages["resources/images/button.png"].width.toDouble()),
                  texture: SpriteTexture(App.simulateImages["resources/images/button.png"]),
                  textureDown: SpriteTexture(App.simulateImages["resources/images/button_down.png"]),
                  onPressed: () async {
                    musicPlayer = await AudioCache(prefix: "").play("resources/audio/start_battle.ogg", volume: 0.5).then((value) async {
                      musicPlayer.stop();
                      Future.delayed(Duration(milliseconds: 3200), () async => musicPlayer = await AudioCache(prefix: "").loop("resources/audio/battle.ogg"));
                      return musicPlayer;
                    });
                    setState(() { turn=1; });
                  },
                ),
              ],
            ),
          ]
      );
    }
    else { //turn == 9
      child = Stack(
          children: [
            SpriteWidget(rootNode, SpriteBoxTransformMode.scaleToFit),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 120,),
                Container(
                  width: MediaQuery.of(context).size.width,
                  child: Text(
                    'Well Done!',
                    style: TextStyle(
                        fontSize: 28,
                        color: DRColors.lightGreen
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 20,),
                Text(
                  wrongCards==0?'You have finished the simulation without errors!'
                      :
                  'You have finished the simulation.\n\n\nCommitted errors: ' + wrongCards.toString() + '\nYou can do better!',
                  style: TextStyle(
                      fontSize: 22,
                      color: DRColors.white
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 140,),
                TextureButton(
                  width: MediaQuery.of(context).size.width/2.5,
                  height: (MediaQuery.of(context).size.width/2.5)*(App.simulateImages["resources/images/exitbutton.png"].height.toDouble()/App.simulateImages["resources/images/exitbutton.png"].width.toDouble()),
                  texture: SpriteTexture(App.simulateImages["resources/images/exitbutton.png"]),
                  textureDown: SpriteTexture(App.simulateImages["resources/images/exitbutton_down.png"]),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ]
      );
    }

    return Material(
      child: child
    );
  }

  void loadSprites() {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.width*16/9;
    //rootNode
    rootNode = new NodeWithSize(Size(width, height));
    //images
    containerImage = new Sprite.fromImage(App.simulateImages["resources/images/simulateContainer.png"]);
    backgroundImage = new Sprite.fromImage(App.simulateImages["resources/images/simulatebg.jpg"]);
    playerDeckWoodImage = new Sprite.fromImage(App.simulateImages["resources/images/deckwood.png"]);
    opponentDeckWoodImage = new Sprite.fromImage(App.simulateImages["resources/images/deckwood.png"]);
    opacityImage = new Sprite.fromImage(App.simulateImages["resources/images/opacity.png"]);
    elixirBar = new Sprite.fromImage(App.simulateImages["resources/images/elixirbar.png"]);
    elixirColor = new Sprite.fromImage(App.simulateImages["resources/images/elixircolor.png"]);
    dragText = new Sprite.fromImage(App.simulateImages["resources/images/drag.png"]);
    //deck cards
    opponentDeckSprites.clear();
    playerDeckSprites.clear();
    playerDeckRotationSprites.clear();
    for(int i = 0; i < 8; i++){
      opponentDeckSprites.insert(i, new Sprite(SimulateCtrl.getSpriteImage(opponentDeck.elementAt(i).asset)));
      opponentDeckSprites.elementAt(i).scale = 0.53;
      opponentDeckSprites.elementAt(i).position = Offset(90.0 + i*148.65, 101);
      opponentDeckWoodImage.addChild(opponentDeckSprites.elementAt(i));
    }
    for (int i = 0; i < 8; i++) {
      playerDeckSprites.insert(
          i,
          new Sprite(
              SimulateCtrl.getSpriteImage(playerDeck.elementAt(i).asset)));
      playerDeckSprites.elementAt(i).scale = 0.53;
      playerDeckSprites.elementAt(i).position = Offset(90.0 + i * 148.65, 101);
      playerDeckWoodImage.addChild(playerDeckSprites.elementAt(i));

      playerDeckRotationSprites.insert(i, new CardSprite(SimulateCtrl.getSpriteImage(playerDeck.elementAt(i).asset), playerDeck.elementAt(i).cost, this));
      playerDeckRotationSprites.elementAt(i).scale = MediaQuery.of(context).size.width / 1280;
      playerDeckRotationElixirSprites.insert(i, new Sprite.fromImage(App.simulateImages['resources/images/elixir' + playerDeck.elementAt(i).cost.toString() + '.png']));
      playerDeckRotationElixirSprites.elementAt(i).scale = MediaQuery.of(context).size.width / 360;
      playerDeckRotationElixirSprites.elementAt(i).position = Offset(132, 290);
      playerDeckRotationSprites.elementAt(i).addChild(playerDeckRotationElixirSprites.elementAt(i));
    }
    //scaling and position
    containerImage.scale = MediaQuery.of(context).size.width/320;
    backgroundImage.scale = MediaQuery.of(context).size.width/730;
    playerDeckWoodImage.scale = MediaQuery.of(context).size.width/1218;
    opponentDeckWoodImage.scale = MediaQuery.of(context).size.width/1218;
    opacityImage.scale = 10;
    dragText.scale = MediaQuery.of(context).size.width/2300;
    elixirBar.scale = 1.02;
    elixirColor.scale = 0.76;
    elixirColor.scaleX = 6.2;
    containerImage.position = Offset(MediaQuery.of(context).size.width/2, MediaQuery.of(context).size.width*16/9/2);
    backgroundImage.position = Offset(MediaQuery.of(context).size.width/2, MediaQuery.of(context).size.width*16/9/2);
    dragText.position = Offset(MediaQuery.of(context).size.width/2, MediaQuery.of(context).size.width*16/9/2+20);
    dragText.opacity = 0;
    opponentDeckWoodImage.position = Offset(MediaQuery.of(context).size.width/2, 39);
    playerDeckWoodImage.position = Offset(MediaQuery.of(context).size.width/2, MediaQuery.of(context).size.width*16/9 - 39);
    elixirBar.position = Offset(560, 1622);
    elixirColor.position = Offset(448, 1623);
    //sprites tree
    rootNode.addChild(backgroundImage);
    rootNode.addChild(dragText);
    //playerDeckRotationSprites.shuffle();
    for(int i = 0; i < 4; i++){
      playerDeckRotationSprites.elementAt(i).position = Offset(MediaQuery.of(context).size.width/3.65 + MediaQuery.of(context).size.width/4.2*i, MediaQuery.of(context).size.width*16/9);
      rootNode.addChild(playerDeckRotationSprites.elementAt(i));
    }
    playerDeckRotationSprites.elementAt(4).position = Offset(94, 1586);
    playerDeckRotationSprites.elementAt(4).scale = 0.42;
    backgroundImage.addChild(playerDeckRotationSprites.elementAt(4));
    backgroundImage.addChild(elixirColor);
    backgroundImage.addChild(elixirBar);
    rootNode.addChild(opacityImage);
    rootNode.addChild(playerDeckWoodImage);
    rootNode.addChild(opponentDeckWoodImage);
    rootNode.addChild(containerImage);
  }

  void opponentMove(Sprite element){
    element.motions.run(dropFromTop(element));
  }

  MotionGroup dropFromTop(Sprite object) {
    return MotionGroup(<MotionTween>[
      MotionTween<Offset>(
        (a) => object.position = a,
        Offset(MediaQuery.of(context).size.width / 2, object.position.dy),
        Offset(
          MediaQuery.of(context).size.width / 2,
          MediaQuery.of(context).size.height / 6 * 1.56/(MediaQuery.of(context).size.height / MediaQuery.of(context).size.width - 1),
        ),
        1.0,
        Curves.decelerate,
      ),
      MotionTween<double>(
        (a) => object.scale = a,
        MediaQuery.of(context).size.width/1280,
        MediaQuery.of(context).size.width/1600,
        1.0,
        Curves.decelerate,
      ),
    ]);
  }

  void updateElixir() {
    timer?.cancel();
    elixirColor.motions.stopAll();
    print(currentElixir);
    currentElixir -= playerDeckRotationSprites.elementAt(7).cost.toDouble();
    print(playerDeckRotationSprites.elementAt(7).cost);
    print("-> "+currentElixir.toString());
    MotionTween elixirGrow = new MotionTween<double> (
            (a) => elixirColor.scaleX = a,
        1.075*currentElixir, //every elixir unit circa 1,075 scale of x
        10.5,
        2.7*(10.0 - currentElixir)
    );

    MotionTween elixirMove = new MotionTween<Offset> (
            (a) => elixirColor.position = a,
        Offset(244 + 34*currentElixir, 1623), //every elixir unit 34 offset of x
        Offset(584, 1623),
        2.7*(10.0 - currentElixir)
    );
    elixirColor.motions.run(elixirGrow);
    elixirColor.motions.run(elixirMove);
    timer = Timer.periodic(Duration(milliseconds: 70), (t)
    {
      currentElixir += 0.1;
      if(!(currentElixir < 10)){
        t.cancel();
      }
    });
  }

  bool checkUsedCard(int index) {
    MotionTween hideDragText = new MotionTween<double> (
            (a) => dragText.opacity = a,
        1.0,
        0.0,
        0.3
    );
    MotionTween showOpacity = new MotionTween<double> (
            (a) => opacityImage.opacity = a,
        0.0,
        1.0,
        0.3
    );
    MotionTween showDragText = new MotionTween<double> (
            (a) => dragText.opacity = a,
        0.0,
        1.0,
        0.5
    );
    MotionTween hideOpacity = new MotionTween<double> (
            (a) => opacityImage.opacity = a,
        1.0,
        0.0,
        0.5
    );
    dragText.motions.stopAll();
    opacityImage.motions.stopAll();
    dragText.motions.run(hideDragText);
    opacityImage.motions.run(showOpacity);
    if(index == rightCardIndex){
      rightCards++;
      SingleCard correctCard = playerDeck.elementAt(index);
      for (SingleCard card in playerDeck){
        print(card.name);
      }
      print("");
      playerDeck.removeAt(index);
      playerDeck.add(correctCard);
      correctCard = playerDeck.elementAt(3);
      playerDeck.removeAt(3);
      playerDeck.insert(index, correctCard);
      for (SingleCard card in playerDeck){
        print(card.name);
      }
      rightCardIndex = SimulateCtrl.getAlphabeticalIndex(playerDeck);
      finishedTurn = 1;
      setState(() {});
      Future.delayed(Duration(seconds: 1), (){setState(() {
        turn++;
        finishedTurn = 0;
        if(turn<9){
          dragText.motions.run(showDragText);
          opacityImage.motions.run(hideOpacity);
        }
      });});
      return true;
    }
    else {
      wrongCards++;
      finishedTurn = 2;
      setState(() {});
      Future.delayed(Duration(seconds: 1), (){setState(() {
        finishedTurn = 0;
        dragText.motions.run(showDragText);
        opacityImage.motions.run(hideOpacity);
      });});
      return false;
    }
  }
}

class TextureButton extends StatefulWidget {
  TextureButton({
    Key key,
    this.onPressed,
    this.texture,
    this.textureDown,
    this.width,
    this.height,
    this.label,
    this.textStyle,
    this.textAlign: TextAlign.center,
    this.labelOffset: Offset.zero
  }) : super(key: key);

  final VoidCallback onPressed;
  final SpriteTexture texture;
  final SpriteTexture textureDown;
  final TextStyle textStyle;
  final TextAlign textAlign;
  final String label;
  final double width;
  final double height;
  final Offset labelOffset;

  TextureButtonState createState() => new TextureButtonState();
}

class TextureButtonState extends State<TextureButton> {
  bool _highlight = false;

  Widget build(BuildContext context) {
    return new GestureDetector(
        child: new Container(
            width: widget.width,
            height: widget.height,
            child: new CustomPaint(
                painter: new TextureButtonPainter(widget, _highlight)
            )
        ),
        onTapDown: (_) {
          setState(() {
            _highlight = true;
          });
        },
        onTap: () {
          setState(() {
            _highlight = false;
          });
          if (widget.onPressed != null)
            widget.onPressed();
        },
        onTapCancel: () {
          setState(() {
            _highlight = false;
          });
        }
    );
  }
}

class TextureButtonPainter extends CustomPainter {
  TextureButtonPainter(this.config, this.highlight);

  final TextureButton config;
  final bool highlight;

  void paint(Canvas canvas, Size size) {
    if (config.texture != null) {
      canvas.save();
      if (highlight) {
        // Draw down state
        if (config.textureDown != null) {
          canvas.scale(size.width / config.textureDown.size.width, size.height / config.textureDown.size.height);
          config.textureDown.drawTexture(canvas, Offset.zero, new Paint());
        } else {
          canvas.scale(size.width / config.texture.size.width, size.height / config.texture.size.height);
          config.texture.drawTexture(
              canvas,
              Offset.zero,
              new Paint()..colorFilter = new ColorFilter.mode(new Color(0x66000000), BlendMode.srcATop)
          );
        }
      } else {
        // Draw up state
        canvas.scale(size.width / config.texture.size.width, size.height / config.texture.size.height);
        config.texture.drawTexture(canvas, Offset.zero, new Paint());
      }
      canvas.restore();
    }

    if (config.label != null) {
      TextStyle style;
      if (config.textStyle == null)
        style = new TextStyle(fontSize: 24.0, fontWeight: FontWeight.w700);
      else
        style = config.textStyle;

      TextSpan textSpan = new TextSpan(style: style, text: config.label);
      TextPainter painter = new TextPainter(
        text: textSpan,
        textAlign: config.textAlign,
        textDirection: TextDirection.ltr,
      );

      painter.layout(minWidth: size.width, maxWidth: size.width);
      painter.paint(canvas, new Offset(0.0, size.height / 2.0 - painter.height / 2.0 ) + config.labelOffset);
    }
  }

  bool shouldRepaint(TextureButtonPainter oldPainter) {
    return oldPainter.highlight != highlight
        || oldPainter.config.texture != config.texture
        || oldPainter.config.textureDown != config.textureDown
        || oldPainter.config.textStyle != config.textStyle
        || oldPainter.config.label != config.label
        || oldPainter.config.width != config.width
        || oldPainter.config.height != config.height;
  }
}

class CardSprite extends Sprite {

  SpriteTexture texture;
  int cost;
  GameSimulatorWidgetState gameSimulator;

  CardSprite([this.texture, this.cost, this.gameSimulator]) : super(texture) {
    userInteractionEnabled = true;
    if (texture != null) {
      size = texture.size;
      pivot = texture.pivot;
    } else {
      pivot = new Offset(0.5, 0.5);
    }
  }

  @override
  handleEvent(SpriteBoxEvent event) {
    if(gameSimulator.turn >= 9)
      return true;
    if (event.type == PointerDownEvent) {
      opacity = 0.7;
      size = size*0.95;
    }
    else if (event.type == PointerMoveEvent) {
      position = event.boxPosition;
    }
    else if (event.type == PointerUpEvent) {
      opacity = 1;
      size = size/0.95;
      int i = GameSimulatorWidgetState.playerDeckRotationSprites.indexOf(this);
      print(i);
      double width = GameSimulatorWidgetState.width;
      double height = GameSimulatorWidgetState.height;
      updateView(gameSimulator.checkUsedCard(i));
      position = Offset(width/3.16 + width/5.26*i, height - width/5.353);
    }
    return true;
  }

  void updateView(bool updateCards) {
    if(GameSimulatorWidgetState.currentElixir - cost > 0 && updateCards) {
      SpriteTexture tempTexture = texture;
      texture = GameSimulatorWidgetState.playerDeckRotationSprites.elementAt(4).texture;
      GameSimulatorWidgetState.playerDeckRotationSprites.elementAt(4).texture = GameSimulatorWidgetState.playerDeckRotationSprites.elementAt(5).texture;
      GameSimulatorWidgetState.playerDeckRotationSprites.elementAt(5).texture = GameSimulatorWidgetState.playerDeckRotationSprites.elementAt(6).texture;
      GameSimulatorWidgetState.playerDeckRotationSprites.elementAt(6).texture = GameSimulatorWidgetState.playerDeckRotationSprites.elementAt(7).texture;
      GameSimulatorWidgetState.playerDeckRotationSprites.elementAt(7).texture = tempTexture;
      int tempCost = cost;
      cost = GameSimulatorWidgetState.playerDeckRotationSprites.elementAt(4).cost;
      GameSimulatorWidgetState.playerDeckRotationSprites.elementAt(4).cost = GameSimulatorWidgetState.playerDeckRotationSprites.elementAt(5).cost;
      GameSimulatorWidgetState.playerDeckRotationSprites.elementAt(5).cost = GameSimulatorWidgetState.playerDeckRotationSprites.elementAt(6).cost;
      GameSimulatorWidgetState.playerDeckRotationSprites.elementAt(6).cost = GameSimulatorWidgetState.playerDeckRotationSprites.elementAt(7).cost;
      GameSimulatorWidgetState.playerDeckRotationSprites.elementAt(7).cost = tempCost;
      Sprite tempSprite = this.children[0];
      this.children[0] = GameSimulatorWidgetState.playerDeckRotationSprites.elementAt(4).children[0];
      GameSimulatorWidgetState.playerDeckRotationSprites.elementAt(4).children[0] = GameSimulatorWidgetState.playerDeckRotationSprites.elementAt(5).children[0];
      GameSimulatorWidgetState.playerDeckRotationSprites.elementAt(5).children[0] = GameSimulatorWidgetState.playerDeckRotationSprites.elementAt(6).children[0];
      GameSimulatorWidgetState.playerDeckRotationSprites.elementAt(6).children[0] = GameSimulatorWidgetState.playerDeckRotationSprites.elementAt(7).children[0];
      GameSimulatorWidgetState.playerDeckRotationSprites.elementAt(7).children[0] = tempSprite;
      updateElixir();
    }
  }

  void updateElixir() {
    gameSimulator.updateElixir();
  }
}