import 'dart:async';

import 'package:deck_royale_app/controller.dart';
import 'package:deck_royale_app/simulate_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:reorderables/reorderables.dart';
import 'package:url_launcher/url_launcher.dart';

import 'build_deck_page.dart';
import 'colors.dart';
import 'controller_passive.dart';
import 'evaluate_deck_page.dart';
import 'model.dart';
import 'dialogs.dart';

class FolderView extends StatefulWidget {
  final int folderIndex;
  FolderView(this.folderIndex);

  @override
  _FolderViewState createState() => _FolderViewState();
}

class _FolderViewState extends StateMVC<FolderView> {
  _FolderViewState():super(FolderCtrl());

  @override
  Widget build(BuildContext context) {
    void _onReorder(int oldIndex, int newIndex) {
      FolderCtrl.me.moveDeck(widget.folderIndex, oldIndex, newIndex);
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        shadowColor: Colors.black,
        backgroundColor: DRColors.black,
        title: Text(
          FolderCtrl.me.getFolderName(widget.folderIndex),
          style: TextStyle(
            color: DRColors.white,
            fontSize: MediaQuery.of(context).orientation == Orientation.portrait ? 18 : 22,
          ),
        ),
      ),
      body: Container(
        color: DRColors.black,
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: FolderCtrl.me.getNumDecks(widget.folderIndex)!=0 ? ReorderableWrap(
          footer: Container(height:15),
          children: List.generate(FolderCtrl.me.getNumDecks(widget.folderIndex), (index) {
            return DeckItem(
              key: UniqueKey(),
              folderIndex: widget.folderIndex,
              deckIndex: index,
              removeDeck: removeDeck,
            );
          },),
          onReorder: _onReorder,
        ):
        Center(
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Text(
              'To start, create a new deck in the "Build" page...',
              style: TextStyle(
                color: DRColors.grey,
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  void removeDeck(int deckIndex){
    FolderCtrl.me.removeDeck(widget.folderIndex, deckIndex);
  }
}

class DeckItem extends StatefulWidget {
  final int folderIndex;
  final int deckIndex;
  final Function removeDeck;

  DeckItem({Key key, this.folderIndex, this.deckIndex, this.removeDeck})
      : super(key: key);

  @override
  _DeckItemState createState() => _DeckItemState();
}

class _DeckItemState extends State<DeckItem> {
  List<CardView> _list;
  List<DeckCard> _list2;
  List<Widget> _cards;
  double _cardWidth;
  double _elixirWidth;
  double _width;
  double _icon;
  bool _selected;
  bool _buttons;
  bool _first;

  @override
  void initState() {
    _list = [];
    _list2 = [];
    _selected = false;
    _buttons = false;
    _first = true;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if(_first) {
      _icon = MediaQuery.of(context).orientation == Orientation.portrait ? 22 : 26;
      _cardWidth = MediaQuery.of(context).size.width / 6;
      _elixirWidth = MediaQuery.of(context).size.width / 21;
      _width = MediaQuery.of(context).size.width;
      if (MediaQuery.of(context).orientation == Orientation.landscape) {
        _cardWidth = _cardWidth / 2;
        _elixirWidth = _elixirWidth / 2;
      }
      for (int i = 0; i < 8; i++) {
        _list.add(CardView(
          cardCode:
          FolderCtrl.me.getDeckCard(widget.folderIndex, widget.deckIndex, i),
          cardWidth: _cardWidth,
          elixirWidth: _elixirWidth,
        ));
      }
      if (MediaQuery.of(context).orientation == Orientation.portrait) {
        _cards = [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: _list.sublist(0, 4),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: _list.sublist(4, 8),
          ),
        ];
      } else {
        _cards = [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: _list,
          ),
        ];
      }
    }

    return GestureDetector(
      onTap: (){setState(() {
        if(!_selected){
          _first = false;
          setState(() {
            _selected = true;
          });
          Future.delayed(const Duration(milliseconds: 400), () {
            setState(() {
              _buttons = true;
            });
          });
        }else{
          _first = false;
          setState(() {
            _selected = false;
            _buttons = false;
          });
        }
      });},
      child: Container(
        margin: const EdgeInsets.fromLTRB(15, 15, 15, 0),
        padding: const EdgeInsets.fromLTRB(15, 15, 15, 10),
        width: _width - 10,
        decoration: DRColors.tile,
        child: Center(
          child: Column(
            children: [
              Column(
                children: _cards,
              ),
              Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 20),
                        child: Text(
                          "Avg elixir",
                          style: TextStyle(
                            fontSize: 12,
                            color: DRColors.grey,
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: DRColors.value,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        height: MediaQuery.of(context).orientation ==
                                Orientation.portrait ? 25 : 30,
                        width: 60,
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        alignment: Alignment.center,
                        child: Text(
                          '${FolderCtrl.me.getDeckElixir(widget.folderIndex, widget.deckIndex).toStringAsFixed(1)}',
                          style: TextStyle(
                            color: DRColors.elixir,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ]),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      height: _selected?35:3,
                      width: 340,
                      decoration: BoxDecoration(
                        color: DRColors.value,
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                      ),
                      child: _buttons? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(
                            padding: const EdgeInsets.all(0),
                            icon: Icon(CupertinoIcons.chart_pie_fill,
                                color: DRColors.white),
                            iconSize: _icon,
                            tooltip: 'Stats',
                            constraints: BoxConstraints(
                              minHeight: 0,
                              minWidth: 0,
                            ),
                            onPressed: () {
                              if (_list2.isEmpty) {
                                for (int i = 0; i < 8; i++) {
                                  _list2.add(DeckCard(
                                    id: FolderCtrl.me.getDeckCard(widget.folderIndex, widget.deckIndex, i),
                                    inDeck: true,
                                    isVisible: true,
                                  ));
                                }
                              }
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => EvaluateDeckPage(
                                          cards: _list2,
                                          optionButtons: false,
                                        )),
                              );
                            },
                          ),
                          IconButton(
                            padding: const EdgeInsets.all(0),
                            icon: Icon(CupertinoIcons.wrench_fill,
                                color: DRColors.white),
                            iconSize: _icon,
                            tooltip: 'Edit',
                            constraints: BoxConstraints(
                              minHeight: 0,
                              minWidth: 0,
                            ),
                            onPressed: () {
                              BuildDeckPage.setDeck(FolderCtrl.me.getDeckCards(
                                  widget.folderIndex, widget.deckIndex));
                              HomeCtrl.me.setTab(DRTabs.build);
                              Future.delayed(const Duration(milliseconds: 100),
                                  () { Navigator.pop(context); });
                            },
                          ),
                          IconButton(
                            padding: const EdgeInsets.all(0),
                            icon: Icon(CupertinoIcons.trash_fill,
                                color: DRColors.white),
                            iconSize: _icon,
                            tooltip: 'Delete',
                            constraints: BoxConstraints(
                              minHeight: 0,
                              minWidth: 0,
                            ),
                            onPressed: () {
                              Future.delayed(const Duration(milliseconds: 200),
                                  () {
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AreYouSureDialog(
                                          index: widget.deckIndex,
                                          action: widget.removeDeck);
                                    });
                              });
                            },
                          ),
                          IconButton(
                            padding: const EdgeInsets.all(0),
                            icon: Icon(CupertinoIcons.doc_on_doc_fill,
                                color: DRColors.white),
                            iconSize: _icon,
                            tooltip: 'Copy',
                            constraints: BoxConstraints(
                              minHeight: 0,
                              minWidth: 0,
                            ),
                            onPressed: () {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return CopyDeckDialog(
                                      originalFolderIndex: widget.folderIndex,
                                      originalDeckIndex: widget.deckIndex,
                                      removeOldCopy: widget.removeDeck,
                                    );
                                  });
                            },
                          ),
                          IconButton(
                            padding: const EdgeInsets.all(0),
                            icon: Icon(CupertinoIcons.game_controller_solid,
                                color: DRColors.white),
                            iconSize: _icon,
                            tooltip: 'Simulate',
                            constraints: BoxConstraints(
                              minHeight: 0,
                              minWidth: 0,
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                              HomeCtrl.me.setTab(DRTabs.simulator);
                              SimulateCtrl.me.simulateDeck(
                                  List.from(FolderCtrl.me.getDeckCards(
                                      widget.folderIndex, widget.deckIndex)),
                                  _cardWidth/2 + 16,
                                  _elixirWidth/2 + 3);
                              Navigator.push( context, MaterialPageRoute(
                                  builder: (context) => GameSimulatorWidget(isRandomDeck: false)),
                              );
                            },
                          ),
                          IconButton(
                            padding: const EdgeInsets.all(0),
                            icon: Icon(CupertinoIcons.arrow_right_circle_fill,
                                color: DRColors.white),
                            iconSize: _icon,
                            tooltip: 'Try',
                            constraints: BoxConstraints(
                              minHeight: 0,
                              minWidth: 0,
                            ),
                            onPressed: () {
                              _tryDeck();
                            },
                          ),
                        ],
                      ):Row(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _tryDeck() async {
    String url = "https://link.clashroyale.com/deck/en?deck=";
    for(int i=0; i<8; i++){
      url = url + FolderCtrl.me.getDeckCard(widget.folderIndex, widget.deckIndex, i).toString();
    }
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}


class CardView extends StatelessWidget {
  final int cardCode;
  final double cardWidth;
  final double elixirWidth;
  CardView({this.cardCode,this.cardWidth,this.elixirWidth});

  @override
  Widget build(BuildContext context) {
    final SingleCard card = MemoryCtrl.getCard(this.cardCode);
    final cardHeight = cardWidth * 1.2;
    final elixirHeight = elixirWidth * 1.2;
    final fontSize = elixirHeight/1.4;

    return Container(
        width: cardWidth,
        height: cardHeight,
        decoration: BoxDecoration(
            border: Border.all(
              color: Color(0xAA111111),
              width: 2.5,
            ),
            borderRadius: BorderRadius.all(Radius.circular(3))
        ),
        padding: const EdgeInsets.all(0.5),
        child: Container(
          width: cardWidth,
          height: cardHeight,
          color: Color(0x5A000000),
          alignment: Alignment.center,
          child: Stack(
            children: [
              Container(
                  width: cardWidth,
                  height: cardHeight,
                  child: Image.asset('resources/images/${card.asset}')
              ),
              Container(
                  alignment: Alignment.topLeft,
                  width: elixirWidth,
                  height: elixirHeight,
                  child: Stack(
                    children: [
                      Image.asset("resources/images/elixir.png",),
                      Container(
                          alignment: Alignment.center,
                          child: Text(
                            card.getCostString,
                            style: TextStyle(
                              fontSize: fontSize,
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
          ),
        )
    );
  }

}
