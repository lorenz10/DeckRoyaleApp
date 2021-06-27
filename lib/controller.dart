import 'dart:io';
import 'dart:convert';
import 'dart:math';

import 'package:deck_royale_app/colors.dart';
import 'package:deck_royale_app/model.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:spritewidget/spritewidget.dart';
import 'package:connectivity/connectivity.dart';

import 'controller_passive.dart';
import 'folder_page.dart';


/* -the ControllerMVC updates the last StateMVC (view) to which is associated
*  -it is encouraged to use one ControllerMVC for multiple views
* https://medium.com/follow-flutter/bazaar-in-mvc-41e1c960b5c5
* */

class HomeCtrl extends ControllerMVC {
  factory HomeCtrl() {
    if (_iddu == null) {
      _iddu = HomeCtrl._constr();
    }
    return _iddu;
  }
  static HomeCtrl _iddu;
  HomeCtrl._constr(){
    _currentIndex = DRTabs.home;
    _isFloatingButton = App.account.isFireLogged;
  }
  static HomeCtrl get me => _iddu;

  //Bottom bar tabs management
  int _currentIndex;
  bool _isFloatingButton;

  int get tab => _currentIndex;
  bool get floatingButton => _isFloatingButton;

  void setTab(int index) {
    setState(() {
      _currentIndex = index;
      _isFloatingButton = (_currentIndex == DRTabs.home && RootCtrl.me.isFireLogged);
    });
  }

  //Changing card sorts in BuildDeckPage
  int get currentSort => App.account.sortType;

  void nextSort(){
    if(App.account.sortType<DRSorts.MAX){
      App.account.sortType++;
    }else{
      App.account.sortType=DRSorts.standard;
    }
    MemoryCtrl.saveAccount();
  }

  //Checking internet connection
  bool _connected;
  bool get isConnected => _connected;

  Future<void> checkInitialConnectivity() async {
    final ConnectivityResult res = await (Connectivity().checkConnectivity());
    _connected = (res==ConnectivityResult.mobile || res==ConnectivityResult.wifi);
  }
  Future<void> checkConnectivityEvent(ConnectivityResult res) async {
    final bool actualConnection = (res==ConnectivityResult.mobile || res==ConnectivityResult.wifi);
    if (!_connected && actualConnection) {
      await InternetCtrl.updateLocalRoot(true);
      setState(() { _connected = true; });
    }else if(_connected && !actualConnection){
      setState(() { _connected = false; });
    }
  }
  Future<void> checkConnectivity() async {
    final ConnectivityResult res = await (Connectivity().checkConnectivity());
    final bool actualConnection = (res==ConnectivityResult.mobile || res==ConnectivityResult.wifi);
    if (!_connected && actualConnection) {
      await InternetCtrl.updateLocalRoot(true);
      setState(() { _connected = true; });
    }else if(_connected && !actualConnection){
      setState(() { _connected = false; });
    }
  }

  //Showing login page when needed
  bool logged = App.account.isFireLogged;
  bool skip = !App.account.isFireLogged;
  setLogged(){ setState((){ logged = true; skip=false; }); }
  setNotLogged(){ setState((){ logged = false; }); }
}

class SearchCtrl extends ControllerMVC {

  String lastSearch;
  final token = '...';

  Future<PlayerData> getPlayer(String tag) async {
    tag = tag.toUpperCase();
    try{
      final playerResponse = await http.get('https://proxy.royaleapi.dev/v1/players/%23$tag',
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          }
      );
      final chestsResponse = await http.get('https://proxy.royaleapi.dev/v1/players/%23$tag/upcomingchests',
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          }
      );
      final battlesResponse = await http.get('https://proxy.royaleapi.dev/v1/players/%23$tag/battlelog',
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          }
      );
      if (playerResponse.statusCode == 200 && chestsResponse.statusCode == 200 && battlesResponse.statusCode == 200) {
        return retrievePlayer(playerResponse.body, chestsResponse.body, battlesResponse.body);
      }
    }catch(e, stacktrace){
      print(stacktrace);
      print(e);
      throw e;
    }
    return PlayerData.empty();
  }

  Future<PlayerData> retrievePlayer(String playerBody, String chestsBody, String battlesBody) async {
    final playerJsonResponse = json.decode(playerBody);
    final chestsJsonResponse = json.decode(chestsBody);
    final Iterable battlesJsonResponse = json.decode(battlesBody);
    return new PlayerData.fromRemote(playerJsonResponse, chestsJsonResponse, battlesJsonResponse);
  }

  Future<Clan> retrieveClan(String clanBody) async {
    final clanJsonResponse = json.decode(clanBody);
    return new Clan.fromJson(clanJsonResponse);
  }

  Future<Clan> getClan(String tag) async {
    tag = tag.toUpperCase();
    try{
      final clanResponse = await http.get('https://proxy.royaleapi.dev/v1/clans/%23$tag',
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          }
      );
      if (clanResponse.statusCode == 200) {
        return retrieveClan(clanResponse.body);
      }
    }catch(e, stacktrace){
      print(stacktrace);
      print(e);
      throw e;
    }
    return Clan.empty();
  }

}

class RootCtrl extends ControllerMVC {

  factory RootCtrl(){
    if(_iddu==null) {_iddu=RootCtrl._constr();}
    return _iddu;
  }
  static RootCtrl _iddu;
  RootCtrl._constr();
  static RootCtrl get me => _iddu;

  //Internal
  List<Folder> _folders(){
    if(App.root.folders==null)App.root.folders=[];
    return App.root.folders;
  }

  //Getters
  int getNumFolders() => _folders()!=null ? _folders().length : 0;
  String getFolderName(int index) => _folders()[index].name;
  int getFolderImage(int index) => _folders()[index].image;
  int getNumDecks(int index){
    if(_folders()[index].decks==null) _folders()[index].decks = [];
    return _folders()[index].decks.length;
  }
  bool isFolderNameTaken(String n){
    bool exist = false;
    _folders().forEach((element) { if(element.name==n) exist=true; });
    return exist;
  }

  //Setters
  void addFolder(String name){
    int imgNum = _folders().length%6;
    setState((){
      _folders().add(Folder(name, imgNum, []));
    });
    MemoryCtrl.saveRoot();
  }
  void removeFolder(int index){
    setState(() {
      _folders().removeAt(index);
    });
    MemoryCtrl.saveRoot();
  }
  void renameFolder(int index, String name){
    setState(() {
      _folders()[index].name = name;
    });
    MemoryCtrl.saveRoot();
  }
  void moveFolder(int index, int newPos){
    if(newPos>=0 && newPos<getNumFolders()-1)
      setState(() {
        _folders().insert(newPos, _folders().removeAt(index));
      });
    else {
      setState(() {
        _folders().add(_folders().removeAt(index));
      });
    }
    MemoryCtrl.saveRoot();
  }

  //Show/hide action buttons on FolderItems
  bool _modifiable = false;
  bool get isModifiable => _modifiable;
  void setModifiable(){
    setState(() { _modifiable = !_modifiable; });
  }

  //Firebase
  bool get isFireLogged =>
      App.account.isFireLogged != null ? App.account.isFireLogged : false;
  String get getUserId => App.account.userId;
  String get getUserEmail => App.account.userEmail;
  DatabaseReference get database => App.realtimeDatabase;
  String get getDeviceKey => App.account.deviceKey;

  Future<void> updateRoot() async {
    Directory directory;
    File file;
    String contents;
    String key;

    if (App.account.isFireLogged) {
      key = await InternetCtrl.getRemoteDeviceKey();

      if(key!=App.account.deviceKey){
        directory = await getApplicationDocumentsDirectory();
        file = File(directory.path+'/${App.account.userId}.json');

        await InternetCtrl.updateLocalRoot(false);

        contents = await file.readAsString();
        if(contents.isNotEmpty) {
          Map userMap = jsonDecode(contents);
          setState(() { App.root = Root.fromJson(userMap); });
          print('RootCtrl.updateRoot() -> BUILD MODEL: ${App.account.userId}.json');
        }
      }
    }
  }
}

class FolderCtrl extends ControllerMVC {

  static FolderCtrl _iddu;
  static FolderCtrl get me => _iddu;
  FolderCtrl._constr();

  factory FolderCtrl() {
    if (_iddu == null) {
      _iddu = FolderCtrl._constr();
    }
    return _iddu;
  }

  //Internal
  Folder _folder(int folderIndex) => App.root.folders[folderIndex];
  Deck _deck(int folderIndex, int deckIndex) => App.root.folders[folderIndex].decks[deckIndex];

  //Getters
  String getFolderName(int folderIndex) => _folder(folderIndex).name;
  int getNumDecks(int index) => _folder(index).decks!=null ? _folder(index).decks.length : 0;
  double getDeckElixir(int folderIndex, int deckIndex) =>
      _deck(folderIndex, deckIndex).avgElixir;
  int getDeckCard(int folderIndex, int deckIndex, int cardIndex) {
    return _deck(folderIndex, deckIndex).cards[cardIndex];
  }
  List<int> getDeckCards(int folderIndex, int deckIndex) {
    return _deck(folderIndex, deckIndex).cards;
  }

  //Setters
  void addDeck(int folderIndex, Deck nu) {
    if (nu.cards.length != 8) throw ('Wrong number of cards in the new deck');
    setState(() {
      _folder(folderIndex).decks.add(nu);
    });
    MemoryCtrl.saveRoot();
  }
  void removeDeck(int folderIndex, int deckIndex) {
    setState(() {
      _folder(folderIndex).decks.removeAt(deckIndex);
    });
    MemoryCtrl.saveRoot();
  }
  void moveDeck(int folderIndex, int deckIndex, int newPos) {
    if (newPos >= 0 && newPos < getNumDecks(folderIndex) - 1)
      setState(() {
        _folder(folderIndex).decks
            .insert(newPos, _folder(folderIndex).decks.removeAt(deckIndex));
      });
    else
      setState(() {
        _folder(folderIndex).decks.add(_folder(folderIndex).decks.removeAt(deckIndex));
      });
    MemoryCtrl.saveRoot();
  }
}

class DialogCtrl {

  static DialogCtrl _iddu;
  static DialogCtrl get me => _iddu;
  DialogCtrl._constr();

  factory DialogCtrl(){
    if(_iddu==null) {_iddu=DialogCtrl._constr();}
    return _iddu;
  }

  //Internal
  Deck _deck(int folderIndex, int deckIndex) =>
      App.root.folders[folderIndex].decks[deckIndex];

  //Getters
  int getNumFolders() => App.root.folders!=null? App.root.folders.length : 0;
  List<String> getFolderNames(){
    List<String> temp = [];
    App.root.folders.forEach((element) {temp.add(element.name);});
    return temp;
  }
  String getFolderName(int folderIndex) => App.root.folders[folderIndex].name;
  Deck getDeckCopy(int folderIndex, int deckIndex) =>
      _deck(folderIndex, deckIndex).getCopy;

  //Setter
  void addDeck(int folderIndex, Deck deck){
    if(deck.cards.length!=8)
      throw('There must be 8 cards in the deck');
    App.root.folders[folderIndex].decks.add( deck );
    MemoryCtrl.saveRoot();
  }
}

class SimulateCtrl extends ControllerMVC {

  factory SimulateCtrl(){
    if(_iddu==null) {_iddu=SimulateCtrl._constr();}
    return _iddu;
  }
  static SimulateCtrl _iddu;
  SimulateCtrl._constr();
  static SimulateCtrl get me => _iddu;

  List<SingleCard> list = [];
  List<CardView> viewList = [];

  //Simulation with existing deck
  void simulateDeck(List<int> cards, double cw, double ew){
    list.clear();
    viewList.clear();
    for(int i=0; i<8; i++){
      viewList.add(CardView(
        cardCode: cards[i],
        cardWidth: cw,
        elixirWidth: ew,
      ));
      list.add(MemoryCtrl.getCard(cards[i]));
    }
  }

  //Random simulation
  List<SingleCard> getPlayerRandomDeck(){
    int rand;
    List<SingleCard> randomDeck = [];
    Random random = Random();
    for(int i = 0; i < 8; i++){
      rand = random.nextInt(App.gameCards.items.length);
      while(randomDeck.contains(App.gameCards.items.elementAt(rand)) || App.gameCards.items.elementAt(rand).name == "Mirror"){
        rand = random.nextInt(App.gameCards.items.length);
      }
      randomDeck.add(App.gameCards.items.elementAt(rand));
    }
    return randomDeck;
  }

  List<SingleCard> getOpponentRandomDeck(){
    int rand;
    List<SingleCard> randomDeck = [];
    Random random = Random();
    for(int i = 0; i < 8; i++){
      rand = random.nextInt(App.gameCards.items.length);
      while(randomDeck.contains(App.gameCards.items.elementAt(rand)) ||
          !App.gameCards.items.elementAt(rand).sim || App.gameCards.items.elementAt(rand).name == "Mirror"){
        rand = random.nextInt(App.gameCards.items.length);
      }
      randomDeck.add(App.gameCards.items.elementAt(rand));
    }
    return randomDeck;
  }

  static SpriteTexture getSpriteImage(String imageName) {
    if(App.spriteCards0[imageName] != null){
      return App.spriteCards0[imageName];
    }
    else if(App.spriteCards1[imageName] != null){
      return App.spriteCards1[imageName];
    }
    else if(App.spriteCards2[imageName] != null){
      return App.spriteCards2[imageName];
    }
    return null;
  }

  static int getAlphabeticalIndex(List<SingleCard> playerDeck) {
    int index = 0, currentIndex = 0;
    String currentName = "";
    for(SingleCard card in playerDeck){
      if(currentName == "") {
        currentName = card.name;
        currentIndex = 1;
        continue;
      }
      List<String> _myBranchListName= [currentName, card.name];
      _myBranchListName.sort();
      if(_myBranchListName[0] != currentName) {
        index = currentIndex;
        currentName = card.name;
      }
      currentIndex += 1;
      if(currentIndex == 4) {
        break;
      }
    }
    print(index);
    return index;
  }
}

class AccountCtrl extends ControllerMVC {
  static AccountCtrl _iddu;
  static AccountCtrl get me => _iddu;
  AccountCtrl._constr();

  factory AccountCtrl() {
    if (_iddu == null) {
      _iddu = AccountCtrl._constr();
    }
    return _iddu;
  }

  //Clash Royale tag
  bool get isLogged =>
      App.account.isTagLogged != null ? App.account.isTagLogged : false;
  String getUserTag() =>
      App.account.isTagLogged ? App.account.userTag : throw ('no user found');
  PlayerData get playerStatistics => App.playerData;

  void addTag(String tag){
    App.account.userTag = tag;
    setState(() {
      App.account.isTagLogged = true;
    });
    MemoryCtrl.saveAccount();
  }
  void deleteTag(){
    setState(() {
      App.account.isTagLogged = false;
      App.playerData = null;
    });
    MemoryCtrl.saveAccount();
  }
  void updatePlayerData(PlayerData data) {
    App.playerData = data;
  }

  //Firebase
  bool get isFireLogged =>
      App.account.isFireLogged != null ? App.account.isFireLogged : false;
  int get loginMethod => App.account.loginType;
  String get getUserId => App.account.userId;
  String get getUserEmail => App.account.userEmail;

  Future<void> loginFirebaseAccount(String email, String userId,
      {bool isPasswordBased = false, bool isSignUpRequest = false}) async {

    App.account.loginType = isPasswordBased?Account.pass:Account.link;
    App.account.userEmail = email;
    App.account.userId = userId;
    if(App.account.deviceKey==null){
      App.account.deviceKey = await InternetCtrl.generateDeviceKey();
    }

    if(isPasswordBased){
      if(isSignUpRequest){
        await MemoryCtrl.saveRoot();
      }else{
        await InternetCtrl.updateLocalRoot(true);
      }
    }else{ //isLinkBased
      if (!await InternetCtrl.isAccountExistent(userId)) {
        await MemoryCtrl.saveRoot();
      }else{
        await InternetCtrl.updateLocalRoot(true);
      }
    }

    MemoryCtrl.saveAccount();
    print('AccountCtrl.loginFirebaseAccount() -> mail: '+email+' userId: '+userId+' deviceKey: '+App.account.deviceKey);
  }

  void logoutFirebaseAccount(){
    setState(() {
      App.account = Account.fromElimination(App.account);
    });
    App.root = Root.empty();
    MemoryCtrl.saveAccount();
    print('AccountCtrl.logoutFirebaseAccount() -> User logged out');
  }

  Future<void> deleteFirebaseAccount() async {
    await InternetCtrl.deactivateFirebaseAccount();
    await InternetCtrl.deleteRemoteRoot();
    await MemoryCtrl.deleteRoot();
    setState(() {
      App.account = Account.fromElimination(App.account);
    });
    MemoryCtrl.saveAccount();
    print('AccountCtrl.deleteFirebaseAccount() -> Account deleted');
  }

  void deleteLocalFirebaseAccount() {
    App.account = Account.fromElimination(App.account);
    App.root = Root.empty();
    MemoryCtrl.saveAccount();
  }

}

