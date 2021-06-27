import 'package:deck_royale_app/evaluate_deck_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'colors.dart';
import 'controller_passive.dart';
import 'model.dart';

class BuildDeckWidget extends StatefulWidget {
  final Function(Function) provideSortListener;
  BuildDeckWidget({Key key, this.provideSortListener}) : super(key: key);

  @override
  BuildDeckPage createState() => BuildDeckPage();
}

class BuildDeckPage extends State<BuildDeckWidget> {

  static List<DeckCard> selectedDeckCards = [
    DeckCard(id: -1, isVisible: true, inDeck: true),
    DeckCard(id: -1, isVisible: true, inDeck: true),
    DeckCard(id: -1, isVisible: true, inDeck: true),
    DeckCard(id: -1, isVisible: true, inDeck: true),
    DeckCard(id: -1, isVisible: true, inDeck: true),
    DeckCard(id: -1, isVisible: true, inDeck: true),
    DeckCard(id: -1, isVisible: true, inDeck: true),
    DeckCard(id: -1, isVisible: true, inDeck: true),
  ];
  static int cardIndex = 0;
  List<DeckCard> cards = [];

  @override
  void initState() {
    updateCards(MemoryCtrl.getSortType());
    if (widget.provideSortListener!=null) {
      widget.provideSortListener(this.updateCards);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget child;
    if (MediaQuery.of(context).orientation == Orientation.portrait){
      child = Column(
        children: [
          Flexible(
            flex: 6,
            child: Row(
              children: [
                Flexible(
                    child: DeckRow(cards: selectedDeckCards, wipeDeck: wipeDeck)
                )
              ],
            ),
          ),
          Flexible(
              flex: 8,
              child: Row(
                children: [
                  Flexible(
                      child: new DeckListRow(onTapped: updateDeck, cards: cards)
                  )
                ],
              )
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
                Flexible(
                    child: DeckRow(cards: selectedDeckCards, wipeDeck: wipeDeck)
                )
              ],
            ),
          ),
          Flexible(
              flex: 6,
              child: Column(
                children: [
                  Flexible(
                      child: new DeckListRow(onTapped: updateDeck, cards: cards)
                  )
                ],
              )
          )
        ],
      );
    }

    return Scaffold(
      body: Container(
          decoration: new BoxDecoration(
            image: new DecorationImage(
                image: new AssetImage('resources/images/deckBuildBackground.png'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(Color(0xCC060606), BlendMode.srcOver)
            ),
          ),
          child: child
      ),
      floatingActionButton: Visibility(
        visible: cardIndex==8,
        child: Container(
          height: 50,
          width: MediaQuery.of(context).size.width/2,
          decoration: BoxDecoration(
            color: DRColors.orange.withOpacity(0.5),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: DRColors.orange.withOpacity(0.6),
              width: 4,
            ),
          ),
          child: FloatingActionButton.extended(
            elevation: 0.0,
            backgroundColor: DRColors.orange,
            icon: Icon(
              Icons.show_chart_rounded,
              size: MediaQuery.of(context).orientation == Orientation.portrait ? 30 : 45,
              color: DRColors.black2,
            ),
            label: Text(
              "Evaluate deck",
              style: TextStyle(
                color: DRColors.black2,
                fontSize: MediaQuery.of(context).orientation == Orientation.portrait ? 13 : 16,
              ),
            ),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EvaluateDeckPage(cards: selectedDeckCards,optionButtons: true,))
              );
            },
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  void updateCards(int sortIndex){
    int j;

    MemoryCtrl.sortCards(sortIndex);
    setState(() {
      cards.clear();
      for(int i=0;i<MemoryCtrl.getNumCards();i++) {
        j = MemoryCtrl.getSortedCardByPos(i).id;
        if(alreadySelectedCard(j)){
          cards.add(DeckCard(
              key: UniqueKey(),
              id: j,
              isVisible: true,
              inDeck: false,
              onTapped: this.updateDeck));
        }else{
          cards.add(DeckCard(
              key: UniqueKey(),
              id: j,
              isVisible: false,
              inDeck: false,
              onTapped: this.updateDeck));
        }
      }
    });
  }

  void wipeDeck(){
    selectedDeckCards = [
      DeckCard(id: -1, isVisible: true, inDeck: true),
      DeckCard(id: -1, isVisible: true, inDeck: true),
      DeckCard(id: -1, isVisible: true, inDeck: true),
      DeckCard(id: -1, isVisible: true, inDeck: true),
      DeckCard(id: -1, isVisible: true, inDeck: true),
      DeckCard(id: -1, isVisible: true, inDeck: true),
      DeckCard(id: -1, isVisible: true, inDeck: true),
      DeckCard(id: -1, isVisible: true, inDeck: true),
    ];
    cardIndex = 0;
    updateCards(MemoryCtrl.getSortType());
  }

  static void setDeck(List<int> deck){
    selectedDeckCards = [
      DeckCard(id: deck[0], isVisible: true, inDeck: true),
      DeckCard(id: deck[1], isVisible: true, inDeck: true),
      DeckCard(id: deck[2], isVisible: true, inDeck: true),
      DeckCard(id: deck[3], isVisible: true, inDeck: true),
      DeckCard(id: deck[4], isVisible: true, inDeck: true),
      DeckCard(id: deck[5], isVisible: true, inDeck: true),
      DeckCard(id: deck[6], isVisible: true, inDeck: true),
      DeckCard(id: deck[7], isVisible: true, inDeck: true),
    ];
    cardIndex = 8;
  }

  bool updateDeck(int cardCode){
    if(alreadySelectedCard(cardCode)){
      removeCard(cardCode);
    }
    else {
      if (cardIndex >= 8) {return false;}
      addCard(cardCode);
    }
    return true;
  }

  bool alreadySelectedCard(int cardCode) {
    for(DeckCard card in selectedDeckCards){
      if(card.id == cardCode){
        return true;
      }
    }
    return false;
  }

  void removeCard(int cardCode) {
    bool isRemoved = false;
    DeckCard temp;
    for(int i = 0; i < 8; i++){
      if(selectedDeckCards[i].id == cardCode && !isRemoved){
        setState(() {
          selectedDeckCards[i] = DeckCard(id: -1, isVisible: true, inDeck: true);
        });
        isRemoved = true;
      }
      if(isRemoved){
        if(i == 7){
          break;
        }
        temp = selectedDeckCards[i];
        selectedDeckCards[i] = selectedDeckCards[i+1];
        selectedDeckCards[i+1] = temp;
      }
    }
    cardIndex--;
  }

  void addCard(int cardCode) {
    setState(() {
      selectedDeckCards[cardIndex] = DeckCard(id: cardCode, isVisible: true, inDeck: true);
    });
    cardIndex++;
  }

}

class DeckRow extends StatefulWidget{

  final void Function() wipeDeck;
  final List cards;

  DeckRow({
    this.wipeDeck,
    this.cards
  });

  @override
  State<StatefulWidget> createState() => _DeckRow();
}

class _DeckRow extends State<DeckRow>{

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    if (MediaQuery.of(context).orientation == Orientation.landscape){
      width = width/10*4;
    }
    return Center(
      child: Container(
        child: Row(
          children: [
            Align(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                      ),
                      Container(
                        color: Color(0x0),
                        width: width - 100,
                        child: Text(
                          'Build your new deck',
                          style: TextStyle(
                            color: DRColors.grey,
                            fontSize: MediaQuery.of(context).orientation == Orientation.portrait ? 18 : 22,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Container(
                          width: 50,
                          height: 50,
                          child: BuildDeckPage.cardIndex!=0 ?
                          RawMaterialButton(
                            onPressed: () { wipeDeck(); },
                            child: Icon(
                              CupertinoIcons.xmark_circle_fill,
                              color: DRColors.grey,
                              size: MediaQuery.of(context).orientation == Orientation.portrait ? 30 : 40,
                            ),
                            shape: CircleBorder(),
                          )
                              :
                          RawMaterialButton(
                            onPressed: () {},
                            child: Icon(
                              CupertinoIcons.xmark_circle_fill,
                              color: DRColors.grey.withOpacity(0.3),
                              size: MediaQuery.of(context).orientation == Orientation.portrait ? 30 : 40,
                            ),
                            shape: CircleBorder(),
                          ),
                      )
                    ],
                  ),
                  Row(
                    children: [
                      DeckWidget(cards: BuildDeckPage.selectedDeckCards, width: width)
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void wipeDeck() {
    widget.wipeDeck();
  }
}

class DeckWidget extends StatefulWidget{

  final List cards;
  final double width;

  DeckWidget({
    this.cards,
    this.width
  });

  @override
  State<StatefulWidget> createState() => _DeckWidget();
}

class _DeckWidget extends State<DeckWidget> {

  @override
  Widget build(BuildContext context) {
    int factor;
    factor = MediaQuery.of(context).orientation == Orientation.portrait? 6 : 12;
    return Container(
        padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: widget.width *1/factor),
        color: Color(0x0),
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

class DeckListRow extends StatefulWidget {

  final bool Function(int) onTapped;
  final List cards;

  DeckListRow({
    this.onTapped,
    this.cards
  });

  @override
  _DeckListRowState createState() => _DeckListRowState();
}

class _DeckListRowState extends State<DeckListRow> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 8.0),
      color: Colors.transparent,
      child: ScrollConfiguration(
        behavior: ScrollBehavior(),
        child: GlowingOverscrollIndicator(
            axisDirection: AxisDirection.down,
            color: Colors.black,
            child: AnimationLimiter(
                child: GridView.count(
                  cacheExtent: 5000,
                  crossAxisCount: MediaQuery.of(context).orientation == Orientation.portrait? 6 : 9,
                  childAspectRatio: 1/1.17,
                  children: List.generate(widget.cards.length, (index) {
                    return AnimationConfiguration.staggeredGrid(
                      position: index,
                      duration: const Duration(milliseconds: 375),
                      columnCount: MediaQuery.of(context).orientation == Orientation.portrait? 6 : 9,
                      child: ScaleAnimation(
                        duration: Duration(milliseconds: 500),
                        scale: 0.9,
                        child: FadeInAnimation(
                          duration: Duration(milliseconds: 500),
                          child: widget.cards.elementAt(index),
                        ),
                      ),
                    );}
                  ),
                  padding: EdgeInsets.fromLTRB(0, 0, 0, MediaQuery.of(context).size.width / 7 * 1.1),
                )
            )
        ),
      ),
    );
  }
}

class DeckCard extends StatefulWidget {

  final int id;
  final bool inDeck;
  final bool isVisible;
  final bool Function(int) onTapped;

  DeckCard({
    Key key,
    this.id,
    this.isVisible,
    this.inDeck,
    this.onTapped
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _DeckCardState();
}

class _DeckCardState extends State<DeckCard> with TickerProviderStateMixin {

  double _width;
  double _height;
  bool neverTapped = true;
  int orientationMode;
  bool _light;

  @override
  void initState() {
    _light = widget.isVisible;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SingleCard card;
    if(widget.id != -1){
      card = MemoryCtrl.getCard(widget.id);
    }

    orientationMode = MediaQuery.of(context).orientation == Orientation.portrait? 6 : 12;
    if (neverTapped){
      _width = MediaQuery.of(context).size.width / orientationMode;
      _height = MediaQuery.of(context).size.width / orientationMode * 1.2;
    }
    return AnimatedSize(
        duration: Duration(seconds: 1),
        vsync: this,
        curve: Curves.decelerate,
        child: GestureDetector(
          child: Container(
              decoration: BoxDecoration(
                  border: Border.all(
                    color: Color(0xAA111111),
                    width: 2.5,
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(3))
              ),
              width: _width,
              height: _height,
              padding: const EdgeInsets.all(0.5),
              child: Container(
                width: _width,
                height: _height,
                color: Color(0x5A000000),
                alignment: Alignment.center,
                child: ColorFiltered(
                    colorFilter:
                    _light?
                    ColorFilter.mode(Colors.transparent, BlendMode.srcOver)
                        :
                    ColorFilter.mode(Color(0xAA111111), BlendMode.srcATop),
                    child: card!=null?
                    (Stack(
                      children: [
                        Container(
                            width: _width,
                            height: _height,
                            child: Image.asset("resources/images/${card.asset}")
                        ),
                        Container(
                            alignment: Alignment.topLeft,
                            width: MediaQuery.of(context).size.width / (4*orientationMode),
                            height: MediaQuery.of(context).size.width / (4*orientationMode) * 1.2,
                            child: Stack(
                              children: [
                                Image.asset("resources/images/elixir.png",),
                                Container(
                                    alignment: Alignment.center,
                                    child: Text(
                                      card.getCostString,
                                      style: TextStyle(
                                        fontSize: MediaQuery.of(context).orientation == Orientation.portrait ? 12 : MediaQuery.of(context).size.height/40,
                                        color: DRColors.white2,
                                        shadows: <Shadow>[
                                          Shadow(
                                            offset: Offset(0.5, 0.5),
                                            blurRadius: 1.5,
                                            color: Color.fromARGB(255, 0, 0, 0),
                                          )
                                        ],
                                      ),
                                    )
                                )
                              ],
                            )
                        )
                      ],
                    ))
                        :
                    (Image.asset("resources/images/transparent.png")
                    )
                ),
              )
          ),
          onTap: () => onTappedCard(),
          onTapDown: (TapDownDetails details) {
            setState(() {
              neverTapped = false;
              _width = MediaQuery.of(context).size.width / orientationMode - 2.0;
              _height = MediaQuery.of(context).size.width / orientationMode * 1.2 - 2.0;
            });
          },
          onTapUp: (TapUpDetails details) {
            setState(() {
              _width = _width + 2.0;
              _height = _height + 2.0;
            });
          },
          onTapCancel: () {
            setState(() {
              _width = _width + 2.0;
              _height = _height + 2.0;
            });
          },
        )
    );
  }

  onTappedCard() {
    if(!widget.inDeck) {
      setState(() {
        if(widget.onTapped(widget.id)){
          _light = !_light;
        }
      });
    }
  }
}