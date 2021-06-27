import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'controller.dart';
import 'model.dart';
import 'colors.dart';

class AreYouSureDialog extends StatefulWidget {
  final Function action;
  final int index;
  AreYouSureDialog({this.index,this.action});

  @override
  _AreYouSureDialogState createState() => _AreYouSureDialogState();
}

class _AreYouSureDialogState extends State<AreYouSureDialog> {
  bool _done;
  @override
  void initState() {
    _done = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
          height: 150,
          width: MediaQuery.of(context).orientation == Orientation.portrait ? MediaQuery.of(context).size.width/1.3 : MediaQuery.of(context).size.width/2.7,
          padding: const EdgeInsets.only(left:20,right:20),
          child: !_done ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children:  [
                DialogTitle(title:'Are you sure?'),
                ButtonBar(
                  alignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    FlatButton(
                      child: Text(
                        'No',
                        style: TextStyle(fontSize: 17, color: DRColors.white,),
                      ),
                      onPressed: (){Navigator.pop(context);},
                    ),
                    FlatButton(
                      child: Text(
                        'Yes',
                        style: TextStyle(fontSize: 17, color: DRColors.white,),
                      ),
                      onPressed: (){
                        widget.action(widget.index);
                        setState(() { _done = true; });
                        Future.delayed(const Duration(milliseconds: 900), ()
                        { Navigator.pop(context); });
                      },
                    ),
                  ],
                )
              ]
          ) : DialogMessage(
            icon: Icon(
              CupertinoIcons.trash_circle_fill,
              color: DRColors.red,
              size: 50,
            ),
            message: 'Element deleted',
          )
      ),
    );
  }
}

class AreYouSureDialog2 extends StatefulWidget {
  final Function action;
  final String message;
  final IconData icon;
  AreYouSureDialog2({this.action,this.message,this.icon});

  @override
  _AreYouSureDialog2State createState() => _AreYouSureDialog2State();
}

class _AreYouSureDialog2State extends State<AreYouSureDialog2> {
  bool _done;
  @override
  void initState() {
    _done = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
          height: 150,
          width: MediaQuery.of(context).orientation == Orientation.portrait ? MediaQuery.of(context).size.width/1.3 : MediaQuery.of(context).size.width/2.7,
          padding: const EdgeInsets.only(left:20,right:20),
          child: !_done ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children:  [
                DialogTitle(title:'Are you sure?'),
                ButtonBar(
                  alignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    FlatButton(
                      child: Text(
                        'No',
                        style: TextStyle(fontSize: 17, color: DRColors.white,),
                      ),
                      onPressed: (){Navigator.pop(context);},
                    ),
                    FlatButton(
                      child: Text(
                        'Yes',
                        style: TextStyle(fontSize: 17, color: DRColors.white,),
                      ),
                      onPressed: (){
                        widget.action();
                        setState(() { _done = true; });
                        Future.delayed(const Duration(milliseconds: 900), ()
                        { Navigator.pop(context); });
                      },
                    ),
                  ],
                )
              ]
          ) : DialogMessage(
            icon: Icon(
              widget.icon,
              color: DRColors.red,
              size: 50,
            ),
            message: widget.message,
          )
      ),
    );
  }
}

class AddFolderDialog extends StatefulWidget {
  final Function(String name) add;
  final Function(String n) isTaken;
  AddFolderDialog({this.add,this.isTaken});
  @override
  _AddFolderDialogState createState() => _AddFolderDialogState();
}

class _AddFolderDialogState extends State<AddFolderDialog> {
  TextEditingController _tc;
  var _formKey;
  bool _done;

  @override
  void initState() {
    _tc = TextEditingController();
    _formKey = GlobalKey<FormState>();
    _done = false;
    super.initState();
  }

  @override
  void dispose() {
    _tc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        height: 220,
        width: MediaQuery.of(context).orientation == Orientation.portrait ? MediaQuery.of(context).size.width/1.3 : MediaQuery.of(context).size.width/2.7,
        padding: const EdgeInsets.only(left:20,right:20),
        child: RootCtrl.me.isFireLogged ? (!_done? Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              DialogTitle(title:'New Folder'),

              TextFormField(
                keyboardType: TextInputType.text,
                cursorColor: DRColors.orange,
                controller: _tc,
                maxLength: 20,
                style: TextStyle(
                  fontSize: MediaQuery.of(context).orientation ==
                      Orientation.portrait ? 15 : 18,
                  color: DRColors.orange,
                ),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.all(20),
                  labelStyle: TextStyle(
                    fontSize: MediaQuery.of(context).orientation ==
                        Orientation.portrait ? 15 : 18,
                    color: DRColors.grey,
                  ),
                  hintText: 'Folder name',
                  floatingLabelBehavior: FloatingLabelBehavior.never,
                  suffixIcon: IconButton(
                    icon: Center(child: Icon(CupertinoIcons.xmark_circle_fill)),
                    iconSize: MediaQuery.of(context).orientation == Orientation.portrait ? 25 : 30,
                    color: DRColors.grey,
                    onPressed: (){setState(() { _tc.clear(); });},
                  ),
                  counterStyle: TextStyle(
                    fontSize: MediaQuery.of(context).orientation == Orientation.portrait ? 14 : 18,
                    fontFamily: 'Roboto',
                  ),
                  errorStyle: TextStyle(
                    fontSize: MediaQuery.of(context).orientation == Orientation.portrait ? 14 : 18,
                    color: DRColors.redOrange,
                    fontFamily: 'Roboto',
                  ),
                  filled: true,
                  border: DRColors.formBorders,
                  disabledBorder: DRColors.formBorders,
                  errorBorder: DRColors.formBorders,
                  enabledBorder: DRColors.formBorders,
                  focusedBorder: DRColors.formBorders,
                  focusedErrorBorder: DRColors.formBorders,
                ),
                validator: (value) {
                  if(widget.isTaken(value))
                    return 'Name already taken';
                  if(value.length>20)
                    return 'Name too long';
                  if(value.length==0)
                    return 'Field is mandatory';
                  return null;
                },
              ),

              ButtonBar(
                alignment: MainAxisAlignment.spaceEvenly,
                children: [

                  FlatButton(
                    child: Text(
                      'Cancel',
                      style: TextStyle(fontSize: 17),
                    ),
                    onPressed: (){Navigator.pop(context);},
                    textColor: DRColors.white,
                  ),

                  FlatButton(
                    key: Key("confirm button"),
                    child: Text(
                      'Add',
                      key: Key("confirm button text"),
                      style: TextStyle(fontSize: 17),
                    ),
                    onPressed: (){
                      if (_formKey.currentState.validate()) {
                        widget.add(_tc.text);
                        setState(() { _done = true; });
                        Future.delayed(const Duration(milliseconds: 900), ()
                        { Navigator.pop(context); });
                      }
                    },
                    textColor: DRColors.white,
                  ),
                ],
              )
            ],
          ),
        )
            :
        DialogMessage(
          icon: Icon(
            CupertinoIcons.check_mark_circled_solid,
            color: DRColors.green,
            size: 50,
          ),
          message: '"${_tc.text}" added',
        )
        )
            :
        DialogMessage(
          icon: Icon(
            CupertinoIcons.exclamationmark_octagon_fill,
            color: DRColors.red,
            size: 50,
          ),
          message: 'You must Log In.',
        )
      ),
    );
  }
}

class RenameFolderDialog extends StatefulWidget {
  final Function(int i, String n) changeName;
  final Function(String n) isTaken;
  final int index;
  final String oldName;
  RenameFolderDialog({this.index,this.oldName,this.changeName,this.isTaken});

  @override
  _RenameFolderDialogState createState() => _RenameFolderDialogState();
}

class _RenameFolderDialogState extends State<RenameFolderDialog> {
  TextEditingController _tc;
  GlobalKey<FormState> _formKey;

  @override
  void initState() {
    _tc = TextEditingController();
    _formKey = GlobalKey<FormState>();
    _tc.text = widget.oldName;
    super.initState();
  }

  @override
  void dispose() {
    _tc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Dialog(
      child: Container(
        height: 220,
        width: MediaQuery.of(context).orientation == Orientation.portrait ? MediaQuery.of(context).size.width/1.3 : MediaQuery.of(context).size.width/2.7,
        padding: const EdgeInsets.only(left:20,right:20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              DialogTitle(title:'Rename Folder'),

              TextFormField(
                keyboardType: TextInputType.text,
                cursorColor: DRColors.orange,
                controller: _tc,
                maxLength: 20,
                style: TextStyle(
                  fontSize: MediaQuery.of(context).orientation == Orientation.portrait ? 18 : 22,
                  color: DRColors.orange,
                ),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.all(20),
                  labelStyle: TextStyle(
                    fontSize: MediaQuery.of(context).orientation == Orientation.portrait ? 18 : 22,
                    color: DRColors.grey,
                  ),
                  hintText: 'Folder name',
                  floatingLabelBehavior: FloatingLabelBehavior.never,
                  suffixIcon: IconButton(
                    icon: Center(child: Icon(CupertinoIcons.xmark_circle_fill)),
                    iconSize: MediaQuery.of(context).orientation == Orientation.portrait ? 25 : 30,
                    color: DRColors.grey,
                    onPressed: (){setState(() { _tc.clear(); });},
                  ),
                  counterStyle: TextStyle(
                    fontSize: MediaQuery.of(context).orientation == Orientation.portrait ? 14 : 18,
                    fontFamily: 'Roboto',
                  ),
                  errorStyle: TextStyle(
                    fontSize: MediaQuery.of(context).orientation == Orientation.portrait ? 14 : 18,
                    color: DRColors.redOrange,
                    fontFamily: 'Roboto',
                  ),
                  filled: true,
                  border: DRColors.formBorders,
                  disabledBorder: DRColors.formBorders,
                  errorBorder: DRColors.formBorders,
                  enabledBorder: DRColors.formBorders,
                  focusedBorder: DRColors.formBorders,
                  focusedErrorBorder: DRColors.formBorders,
                ),
                validator: (value) {
                  if(widget.isTaken(value))
                    return 'Name already taken';
                  if(value.length>20)
                    return 'Name too long';
                  if(value.length==0)
                    return 'Field is mandatory';
                  return null;
                },
              ),

              ButtonBar(
                alignment: MainAxisAlignment.spaceEvenly,
                children: [

                  FlatButton(
                    child: Text(
                      'Cancel',
                      style: TextStyle(fontSize: 17),
                    ),
                    onPressed: (){Navigator.pop(context);},
                    textColor: DRColors.white,
                  ),

                  FlatButton(
                    child: Text(
                      'Confirm',
                      style: TextStyle(fontSize: 17),
                    ),
                    onPressed: (){
                      if (_formKey.currentState.validate()) {
                        widget.changeName(widget.index, _tc.text);
                        Navigator.pop(context);
                      }
                    },
                    textColor: DRColors.white,
                  ),
                ],
              )

            ],
          ),
        ),
      ),
    );
  }
}

class AddDeckDialog extends StatefulWidget{
  final Deck deck;
  AddDeckDialog(this.deck);
  @override
  _AddDeckDialogState createState() => _AddDeckDialogState();
}

class _AddDeckDialogState extends State<AddDeckDialog> {
  bool _done;
  int _numFolders;
  int _selectedFolder;

  @override
  void initState() {
    _done = false;
    _numFolders = DialogCtrl.me.getNumFolders();
    _selectedFolder = 0;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget view;
    List<String> _list;
    if(_numFolders>0){
      if (_numFolders>1) {
        _list= List.from(DialogCtrl.me.getFolderNames());
        view = !_done ? Column(
          children: [

            DialogTitle(title:'Choose Folder'),

            Container(
              color: Colors.black54,
              height: 150,
              child: ListWheelScrollView.useDelegate(
                itemExtent: 50.0,
                useMagnifier: true,
                magnification: 1,
                overAndUnderCenterOpacity: 0.5,
                physics: FixedExtentScrollPhysics(),
                diameterRatio: 4,
                childDelegate: ListWheelChildBuilderDelegate(
                  builder: (BuildContext context, int index) {
                    return Text(_list[index],
                        style: TextStyle(
                          fontSize: 20,
                          color: DRColors.orange,
                        ));
                  },
                  childCount: _list.length,
                ),
                onSelectedItemChanged: _onSelection,
              ),
            ),

            ButtonBar(
              alignment: MainAxisAlignment.spaceEvenly,
              children: [

                FlatButton(
                  child: Text(
                    'Cancel',
                    style: TextStyle(fontSize: 17),
                  ),
                  onPressed: (){Navigator.pop(context);},
                  textColor: DRColors.white,
                ),

                FlatButton(
                  child: Text(
                    'Confirm',
                    style: TextStyle(fontSize: 17),
                  ),
                  onPressed: (){
                    DialogCtrl.me.addDeck(_selectedFolder, widget.deck);
                    setState(() { _done = true; });
                    Future.delayed(const Duration(milliseconds: 900), ()
                    { Navigator.pop(context); });
                  },
                  textColor: DRColors.white,
                ),
              ],
            )

          ],
        )
            :
        DialogMessage(
          icon: Icon(
            CupertinoIcons.check_mark_circled_solid,
            color: DRColors.green,
            size: 50,
          ),
          message: 'Deck added to "${DialogCtrl.me.getFolderName(_selectedFolder)}"',
        );
      }else{
        DialogCtrl.me.addDeck(_selectedFolder, widget.deck);
        view = DialogMessage(
          icon: Icon(
            CupertinoIcons.check_mark_circled_solid,
            color: DRColors.green,
            size: 50,
          ),
          message: 'Deck added to "${DialogCtrl.me.getFolderName(_selectedFolder)}"',
        );
        Future.delayed(const Duration(milliseconds: 900), ()
        { Navigator.pop(context); });
      }
    }else{
      view = DialogMessage(
        icon: Icon(
          CupertinoIcons.exclamationmark_circle_fill,
          color: DRColors.red,
          size: 50,
        ),
        message: 'No folder found',
      );
      Future.delayed(const Duration(milliseconds: 900), ()
      { Navigator.pop(context); });
    }

    return Dialog(
      child: Container(
        height: 280,
        width: MediaQuery.of(context).orientation == Orientation.portrait ? MediaQuery.of(context).size.width/1.3 : MediaQuery.of(context).size.width/2.7,
        child: view,
      ),
    );
  }

  void _onSelection(int index){ _selectedFolder = index; }
}

class CopyDeckDialog extends StatefulWidget {
  final int originalFolderIndex;
  final int originalDeckIndex;
  final Function removeOldCopy;
  CopyDeckDialog({this.originalFolderIndex,this.originalDeckIndex,this.removeOldCopy});
  @override
  _CopyDeckDialogState createState() => _CopyDeckDialogState();
}

class _CopyDeckDialogState extends State<CopyDeckDialog> {
  int _selectedFolder;
  bool _paste;
  int _numFolders;

  @override
  void initState() {
    _selectedFolder = 0;
    _paste = false;
    _numFolders = DialogCtrl.me.getNumFolders();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget view;
    List<String> _list;

    if (_numFolders>1) {
      _list = List.from(DialogCtrl.me.getFolderNames());
      _list.removeAt(widget.originalFolderIndex);
      view = Column(
        children: [

          DialogTitle(title: 'Copy deck'),

          Container(
            color: Colors.black54,
            height: 110,
            child: ListWheelScrollView.useDelegate(
              itemExtent: 50.0,
              useMagnifier: true,
              magnification: 1,
              overAndUnderCenterOpacity: 0.5,
              physics: FixedExtentScrollPhysics(),
              diameterRatio: 4,
              childDelegate: ListWheelChildBuilderDelegate(
                builder: (BuildContext context, int index) {
                  return Text(_list[index],
                      style: TextStyle(
                        fontSize: 20,
                        color: DRColors.orange,
                      ));
                },
                childCount: _list.length,
              ),
              onSelectedItemChanged: _onSelection,
            ),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Checkbox(
                value: this._paste,
                onChanged: (value) {
                  setState(() { this._paste = value; });
                },
                checkColor: DRColors.black,
                activeColor: DRColors.orange,
                focusColor: DRColors.darkGrey,
                hoverColor: DRColors.white,
              ),
              Text(
                'Delete local copy',
                style: TextStyle(
                  color: DRColors.grey,
                  fontSize: 14,
                ),
              ),
            ],
          ),

          ButtonBar(
            alignment: MainAxisAlignment.spaceEvenly,
            children: [

              FlatButton(
                child: Text(
                  'Cancel',
                  style: TextStyle(fontSize: 17),
                ),
                onPressed: (){Navigator.pop(context);},
                textColor: DRColors.white,
              ),

              FlatButton(
                child: Text(
                  'Confirm',
                  style: TextStyle(fontSize: 17),
                ),
                onPressed: (){
                  if(_selectedFolder < widget.originalFolderIndex){
                    DialogCtrl.me.addDeck(
                        _selectedFolder,
                        DialogCtrl.me.getDeckCopy(widget.originalFolderIndex, widget.originalDeckIndex)
                    );
                  }else{
                    DialogCtrl.me.addDeck(
                        _selectedFolder+1,
                        DialogCtrl.me.getDeckCopy(widget.originalFolderIndex, widget.originalDeckIndex)
                    );
                  }
                  if(this._paste) widget.removeOldCopy(widget.originalDeckIndex);
                  Navigator.pop(context);
                },
                textColor: DRColors.white,
              ),
            ],
          )

        ],
      );
    }else{
      view = DialogMessage(
        icon: Icon(
          CupertinoIcons.exclamationmark_circle_fill,
          color: DRColors.red,
          size: 50,
        ),
        message: 'Only one folder found.',
      );
      Future.delayed(const Duration(milliseconds: 900), ()
      { Navigator.pop(context); });
    }

    return Dialog(
        child: Container(
            height: 280,
          width: MediaQuery.of(context).orientation == Orientation.portrait ? MediaQuery.of(context).size.width/1.3 : MediaQuery.of(context).size.width/2.7,
            child: view,
        )
    );
  }

  void _onSelection(int index){ _selectedFolder = index; }
}

class DialogTitle extends StatelessWidget {
  final String title;
  DialogTitle({this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom:20,top:20),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          color: DRColors.grey,
        ),
      ),
    );
  }

}

class DialogMessage extends StatelessWidget {
  final String message;
  final Icon icon;
  DialogMessage({this.message,this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

            Container(
              height: 60,
              width: 60,
              child: icon,
            ),
            Padding(
              padding: const EdgeInsets.only(top:5),
              child: Text(
                message,
                style: TextStyle(
                  fontSize: 16,
                  color: DRColors.white,
                ),
              ),
            )

        ],
      );
  }

}