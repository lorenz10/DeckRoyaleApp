import 'dart:async';

import 'package:deck_royale_app/folder_page.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:reorderables/reorderables.dart';

import 'colors.dart';
import 'controller.dart';
import 'folder_page.dart';
import 'dialogs.dart';

class RootView extends StatefulWidget{
  RootView();
  @override
  _RootViewState createState() => _RootViewState();
}

class _RootViewState extends StateMVC<RootView> with TickerProviderStateMixin{
  _RootViewState():super(RootCtrl());
  ScrollController _scrollController;
  int _oldNum;
  Widget rootView;
  StreamSubscription _onRootChanged;

  @override
  void initState() {
    _oldNum = 0;
    RootCtrl.me.updateRoot();
    if(RootCtrl.me.isFireLogged){
      _onRootChanged = RootCtrl.me.database.child('users')
        .child(RootCtrl.me.getUserId).onChildChanged.listen(_onRemoteChanged);
    }
    super.initState();
  }

  @override
  void dispose() {
    if(RootCtrl.me.isFireLogged){
      _onRootChanged.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    void _onReorder(int oldIndex, int newIndex) {
      RootCtrl.me.moveFolder(oldIndex, newIndex);
    }

    if (!RootCtrl.me.isFireLogged) {
      //1 - Ask user to register to save the folders

      rootView = Center(
        child: Stack(
          children: [
            Container(
              alignment: Alignment.center,
              child: BigTextWidget('Login with your email in the Account page to save decks',),
            ),
            Row(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width - (MediaQuery.of(context).orientation == Orientation.portrait?50:140),
                  child: Image.asset("resources/images/arrow.png", fit: BoxFit.cover, scale: 5),
                  alignment: Alignment.bottomRight,
                ),
                SizedBox(width: (MediaQuery.of(context).orientation == Orientation.portrait?50:140),)
              ],
            )
          ],
        )
      );
    } else {
      //2 - If there are no folders tell him to create one

      if (RootCtrl.me.getNumFolders() == 0) {
        rootView = Center(
          child: BigTextWidget('Create a new folder to keep your decks organized',),
        );
      } else {
        //3 - Provide the folders
        _scrollController =
            PrimaryScrollController.of(context) ?? ScrollController();
        _checkNewFolder(RootCtrl.me.getNumFolders());
        _oldNum = RootCtrl.me.getNumFolders();

        rootView = ReorderableWrap(
          footer: Container(height: 80),
          controller: _scrollController,
          children: List.generate(RootCtrl.me.getNumFolders(), (index) {
            return FolderItem(
              key: UniqueKey(),
              index: index,
              removeFolder: removeFolder,
              changeName: changeName,
              validateName: validateName,
            );
          }),
          onReorder: _onReorder,
        );
      }
    }

    return Container(
      decoration: BoxDecoration(image: DRColors.background),
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: rootView,
    );
  }

  void changeName(int index, String name){ RootCtrl.me.renameFolder(index, name); }

  bool validateName(String name){ return RootCtrl.me.isFolderNameTaken(name); }

  void removeFolder(int index){ RootCtrl.me.removeFolder(index); }

  void _checkNewFolder(int currentNum){
    if(currentNum > _oldNum && _oldNum != 0) {
      Future.delayed(const Duration(milliseconds: 600), ()
      {
        _scrollController.animateTo(
            (MediaQuery.of(context).size.width / 4.5) * currentNum,
            duration: Duration(seconds: 2),
            curve: Curves.decelerate
        );
      });
    }
  }

  void _onRemoteChanged(Event event) async {
    print(event.snapshot.key+' = '+event.snapshot.value);
    if(event.snapshot.key=='active' && event.snapshot.value=='false'){
      AccountCtrl.me.deleteLocalFirebaseAccount();
    }else{
      RootCtrl.me.updateRoot();
    }
  }
}

class FolderItem extends StatefulWidget {
  final int index;
  final Function removeFolder;
  final Function validateName;
  final Function changeName;

  FolderItem(
      {Key key,
      this.index,
      this.removeFolder,
      this.changeName,
      this.validateName})
      : super(key: key);

  @override
  _FolderItemState createState() => _FolderItemState();
}

class _FolderItemState extends State<FolderItem> with TickerProviderStateMixin {
  double _width;
  double _height;
  bool _neverTapped;

  @override
  void initState() {
    _neverTapped = true;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    EdgeInsetsGeometry margin = EdgeInsets.fromLTRB(5, 10, 5, 0);
    if (MediaQuery.of(context).orientation == Orientation.landscape){
      margin = EdgeInsets.fromLTRB(5, 5, 0, 0);
    }
    if (_neverTapped){
      _width = MediaQuery.of(context).size.width;
      _height = MediaQuery.of(context).size.width / 3.8;
      if (MediaQuery.of(context).orientation == Orientation.landscape){
        _width = _width/2;
      }
    }
    return AnimatedSize(
        duration: Duration(seconds: 3),
        vsync: this,
        curve: Curves.decelerate,
        child: GestureDetector(
          onTap: () {
            Navigator.push( context, MaterialPageRoute(
                builder: (context) => FolderView(widget.index)),
            );
          },
          child: Listener(
            onPointerDown: (PointerDownEvent p) {
              setState(() {
                _neverTapped = false;
                _width = MediaQuery.of(context).size.width - 10.0;
                if (MediaQuery.of(context).orientation == Orientation.landscape){
                  _width = _width/2;
                }
              });
            },
            onPointerUp: (PointerUpEvent p) {
              setState(() {
                _width = _width + 10.0;
                if (MediaQuery.of(context).orientation == Orientation.landscape){
                  _width = _width - 5.0;
                }
              });
            },
            onPointerCancel: (PointerCancelEvent p) {
              setState(() {
                _width = _width + 10.0;
                if (MediaQuery.of(context).orientation == Orientation.landscape){
                  _width = _width - 5.0;
                }
              });
            },
            child: Container(
                width: _width - 10,
                height: _height - 5,
                margin: margin,
                decoration: BoxDecoration(
                  color: DRColors.black2,
                  borderRadius: BorderRadius.circular(16),
                  image: DecorationImage(
                    image: AssetImage('resources/images/Folder_${RootCtrl.me.getFolderImage(widget.index)}.png'),
                    colorFilter: ColorFilter.mode(Color(0xFF000000), BlendMode.color),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                    width: _width - 10,
                    height: _height - 5,
                    padding: const EdgeInsets.fromLTRB(16, 10, 12, 10),
                    decoration: BoxDecoration(
                      //color: DRColors.black2,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                      color: DRColors.black.withOpacity(0.2),
                      width: 6,
                      ),
                      image: DecorationImage(
                        image: AssetImage('resources/images/opacity.png'),
                        colorFilter: ColorFilter.mode(Color(0xFF999999).withOpacity(0.4), BlendMode.color),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Stack(
                    children: [
                      Center(
                          child: Row(
                            children: [
                              Container(
                                  width: MediaQuery.of(context).size.width/6,
                                  height: MediaQuery.of(context).size.width/6*0.9,
                                  child: Image.asset('resources/images/folder.png')
                              ),
                              SizedBox(width: 20,),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.fromLTRB(0, 4, 0, 10),
                                    child: Text(
                                      RootCtrl.me.getFolderName(widget.index),
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
                                  Container(
                                    child: Center(
                                      child: Text(
                                        RootCtrl.me.getNumDecks(widget.index) == 1?
                                        '${RootCtrl.me.getNumDecks(widget.index)} deck':
                                        '${RootCtrl.me.getNumDecks(widget.index)} decks',
                                        style: TextStyle(
                                          color: DRColors.grey,
                                          fontSize: MediaQuery.of(context).orientation == Orientation.portrait ? 14 : 18,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            ],
                          )
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [

                            Visibility(
                              visible: RootCtrl.me.isModifiable,
                              child: IconButton(
                                constraints: BoxConstraints(minHeight: 0, minWidth: 45,),
                                icon: Icon(Icons.build_circle, color: DRColors.white),
                                padding: EdgeInsets.zero,
                                iconSize: MediaQuery.of(context).orientation == Orientation.portrait ? 32 : 40,
                                tooltip: 'Rename',
                                onPressed: () {
                                  Future.delayed(const Duration(milliseconds: 200), () {
                                    showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return RenameFolderDialog(
                                              index: widget.index,
                                              oldName: RootCtrl.me.getFolderName(widget.index),
                                              changeName: widget.changeName,
                                              isTaken: widget.validateName);
                                        });
                                  });
                                },
                              ),
                            ),

                            Visibility(
                              visible: RootCtrl.me.isModifiable,
                              child: IconButton(
                                constraints: BoxConstraints(minHeight: 0, minWidth: 65,),
                                icon: Icon(CupertinoIcons.xmark_circle_fill, color: DRColors.red),
                                iconSize: MediaQuery.of(context).orientation == Orientation.portrait ? 32 : 40,
                                padding: EdgeInsets.zero,
                                tooltip: 'Delete',
                                onPressed: () {
                                  Future.delayed(const Duration(milliseconds: 200), () {
                                    showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AreYouSureDialog(
                                              index: widget.index,
                                              action: widget.removeFolder);
                                        });
                                  });
                                },
                              ),
                            ),

                          ],
                        ),
                      ),
                    ]
                )
            ),
          ),
        )
        )
    );
  }

  @override
  void setState(fn) { //To avoid some exceptions
    if(mounted) {
      super.setState(fn);
    }
  }
}





