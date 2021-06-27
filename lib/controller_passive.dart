import 'dart:io';
import 'dart:convert';

import 'package:deck_royale_app/colors.dart';
import 'package:deck_royale_app/model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:spritewidget/spritewidget.dart';

class MemoryCtrl {
  static const _accountFile = '/account.json';

  static Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  //Load data
  static Future<void> loadAccount() async {
    final String path = await _localPath;
    File file;

    if (await File(path+_accountFile).exists()) {
      file = File(path+_accountFile);
      String contents = await file.readAsString();
      if(contents.isNotEmpty) {
        Map userMap = jsonDecode(contents);
        App.account = Account.fromJson(userMap);
      }
    }else{
      App.account = Account.neverLogged();
      file = await File(path+_accountFile).create();
      await file.writeAsString(jsonEncode(App.account));
    }
  }

  static Future<void> loadRoot() async {
    String path;
    File file;

    if (App.account.isFireLogged) {
      path = await _localPath;
      file = File(path+'/${App.account.userId}.json');

      if (await file.exists()) {
        String contents = await file.readAsString();
        if(contents.isNotEmpty) {
          Map userMap = jsonDecode(contents);
          App.root = Root.fromJson(userMap);
          print('DataCtrl.loadRoot() -> BUILD REMOTE JSON: done');
        }
      }
    }
  }

  static Future<void> deleteRoot() async {
    String path;
    File file;

    if (App.account.isFireLogged) {
      path = await _localPath;
      file = File(path+'/${App.account.userId}.json');
      if (await file.exists()) { await file.delete(); }
      App.root = Root.empty();
    }
  }

  static Future<void> loadGameCards() async {
    String contents = await rootBundle.loadString('resources/files/cards.json');
    Map cardsMap = jsonDecode(contents);
    App.gameCards = GameCards.fromJson(cardsMap);
  }

  static Future<void> loadSimulateAssets() async {
    await App.simulateImages.load(<String>[
      'resources/images/simulateContainer.png',
      'resources/images/simulatebg.jpg',
      'resources/images/deckwood.png',
      'resources/images/opacity.png',
      'resources/images/elixirbar.png',
      'resources/images/elixircolor.png',
      'resources/images/button.png',
      'resources/images/button_down.png',
      'resources/images/exitbutton.png',
      'resources/images/exitbutton_down.png',
      'resources/images/elixir1.png',
      'resources/images/elixir2.png',
      'resources/images/elixir3.png',
      'resources/images/elixir4.png',
      'resources/images/elixir5.png',
      'resources/images/elixir6.png',
      'resources/images/elixir7.png',
      'resources/images/elixir8.png',
      'resources/images/elixir9.png',
      'resources/images/drag.png',
      'resources/images/spritesheet_cards-0.png',
      'resources/images/spritesheet_cards-1.png',
      'resources/images/spritesheet_cards-2.png',
    ]);
    String json = await rootBundle.loadString('resources/files/spritesheet_cards-0.json');
    App.spriteCards0 = SpriteSheet(App.simulateImages['resources/images/spritesheet_cards-0.png'], json);
    json = await rootBundle.loadString('resources/files/spritesheet_cards-1.json');
    App.spriteCards1 = SpriteSheet(App.simulateImages['resources/images/spritesheet_cards-1.png'], json);
    json = await rootBundle.loadString('resources/files/spritesheet_cards-2.json');
    App.spriteCards2 = SpriteSheet(App.simulateImages['resources/images/spritesheet_cards-2.png'], json);
  }

  //Store data
  static Future<void> saveAccount() async {
    final String path = await _localPath;
    final File file = File(path+_accountFile);
    await file.writeAsString(jsonEncode(App.account));
  }

  static Future<void> saveRoot() async {
    String path;
    File file;

    if (App.account.isFireLogged) {
      path = await _localPath;
      file = File(path+'/${App.account.userId}.json');

      if (! await file.exists()) { file = await file.create(); }
      await file.writeAsString(jsonEncode(App.root));
      await InternetCtrl.updateRemoteRoot();
    }

  }
  
  static void initCards(){
    App.gameCards.sortedItems = List.from(App.gameCards.items);
    sortCards(App.account.sortType);
  }

  static void sortCards(int sort) {
    switch (sort) {
      case DRSorts.byRarityCostInverse:
        {
          {
            App.gameCards.sortedItems.sort((a, b) {
              return b.rarity.compareTo(a.rarity) == 0
                  ? a.cost.compareTo(b.cost)
                  : b.rarity.compareTo(a.rarity);
            });
          }
        }
        break;
      case DRSorts.byCost:
        {
          App.gameCards.sortedItems.sort((a, b) => a.cost.compareTo(b.cost));
          App.account.sortType = DRSorts.byCost;
        }
        break;
      case DRSorts.byArenaCost:
        {
          App.gameCards.sortedItems.sort((a, b) {
            return a.arena.compareTo(b.arena) == 0
                ? a.cost.compareTo(b.cost)
                : a.arena.compareTo(b.arena);
          });
          App.account.sortType = DRSorts.byArenaCost;
        }
        break;
      case DRSorts.byRarityCost:
        {
          App.gameCards.sortedItems.sort((a, b) {
            return a.rarity.compareTo(b.rarity) == 0
                ? a.cost.compareTo(b.cost)
                : a.rarity.compareTo(b.rarity);
          });
          App.account.sortType = DRSorts.byRarityCost;
        }
        break;
      default:
        {
          //Sort by id ascendant like the cards.json file
          App.gameCards.sortedItems.clear();
          App.gameCards.sortedItems = List.from(App.gameCards.items);
          App.account.sortType = DRSorts.standard;
        }
        break;
    }
  }

  static SingleCard getCard(int id){
    return App.gameCards.items.firstWhere((element) => element.id==id);
  }
  static SingleCard getSortedCardByPos(int pos){
    return App.gameCards.sortedItems[pos];
  }
  static int getNumCards(){
    return App.gameCards.items.length;
  }
  static int getSortType(){
    return App.account.sortType;
  }

  
}

class InternetCtrl{

  static Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  //Initialization
  static Future<void> initFirebase() async {
    App.firebaseApp = await FirebaseApp.configure(
      name: 'DR Realtime Database app',
      options: const FirebaseOptions(
          googleAppID: '...',
          gcmSenderID: '...',
          apiKey: '...',
          projectID: '...',
          databaseURL: '...'
      ),
    );
    App.firebaseDatabase = FirebaseDatabase(app: App.firebaseApp, databaseURL: '...');
    App.realtimeDatabase = App.firebaseDatabase.reference();
    App.storage = FirebaseStorage.instance;
    App.auth = FirebaseAuth.instance;
  }

  //Firebase Storage
  static Future<void> deleteRemoteRoot() async {
    await FirebaseStorage.instance.ref().child('${App.account.userId}.json').delete();
  }

  static Future<void> updateLocalRoot(bool reloadRootMemCtrl) async {
    String path;
    File file;
    StorageFileDownloadTask task;

    if (App.account.isFireLogged) {
      path = await _localPath;
      file = File(path+'/${App.account.userId}.json');
      try {
        task = App.storage.ref().child('${App.account.userId}.json').writeToFile(file);
        await task.future.whenComplete(complete);
      }catch(e){
        error();
      }
    }
    if(reloadRootMemCtrl){ await MemoryCtrl.loadRoot(); }
  }
  static void complete(){
    print('InternetCtrl.downloadRemoteRoot() -> ${App.account.userId}.json');
  }
  static void error(){
    print('InternetCtrl.downloadRemoteRoot() -> failed');
  }

  static Future<void> updateRemoteRoot() async {
    String path;
    File file;
    StorageUploadTask task;
    Map<String,String> message;

    if (App.account.isFireLogged) {
      path = await _localPath;
      file = File(path+'/${App.account.userId}.json');
      try {
        task = App.storage.ref().child('${App.account.userId}.json').putFile(file);
        await task.onComplete;
        message = {
          'deviceKey':App.account.deviceKey,
          'timestamp':DateTime.now().toString(),
          'active':'true'
        };
        await App.realtimeDatabase.child('users').child(App.account.userId).set(message);
        complete2();
      }catch(e){
        error2();
      }
    }
  }
  static void complete2(){
    print('InternetCtrl.uploadRemoteRoot() -> ${App.account.userId}.json');
  }
  static void error2(){
    print('InternetCtrl.uploadRemoteRoot() -> failed');
  }

  //Firebase Realtime Database
  static Future<String> generateDeviceKey() async {
    final DatabaseReference ref = App.realtimeDatabase.child('keys').push();
    await ref.set('on');
    return ref.key;
  }

  static Future<bool> isAccountExistent(String userId) async{
    DataSnapshot data = await App.realtimeDatabase.child('users').child(userId).once();
    print(data.value!=null?'...remote JSON already exists!':'...remote JSON does not exists!');
    return data.value!=null;
  }

  static Future<void> deactivateFirebaseAccount() async {
    await App.realtimeDatabase.child('users').child(App.account.userId)
        .set({'active':'false'});
  }
  static Future<bool> isFirebaseAccountDeleted() async {
    final DataSnapshot data = await App.realtimeDatabase.child('users')
        .child(App.account.userId).child('active').once();
    return data!=null && data.value.toString() == 'false';
  }

  static Future<String> getRemoteDeviceKey() async {
    final DataSnapshot data = await App.realtimeDatabase.child('users')
        .child(App.account.userId).child('deviceKey').once();
    return data.value.toString();
  }

  //Firebase Authentication
  static Future<void> sendSignInWithEmailLink(String email) async {
    await App.auth.sendSignInWithEmailLink(
      email: email,
      url: 'https://deckroyale.page.link/',
      handleCodeInApp: true,
      iOSBundleID: 'com.google.firebase.flutterauth',
      androidPackageName: 'dima.deck_royale_app',
      androidInstallIfNotAvailable: true,
      androidMinimumVersion: "1",
    );
  }

  static Future<bool> isLinkValid(String link) async {
    return await App.auth.isSignInWithEmailLink(link);
  }

  static Future<FirebaseUser> signInWithEmailAndLink(String email, String link) async {
    return (await App.auth.signInWithEmailAndLink(
      email: email,
      link: link,
    )).user;
  }

  static Future<FirebaseUser> createUserWithEmailAndPassword(String email, String pass) async {
    return (await App.auth.createUserWithEmailAndPassword(
      email: email,
      password: pass,
    )).user;
  }

  static Future<FirebaseUser> signInWithEmailAndPassword(String email, String pass) async {
    return (await App.auth.signInWithEmailAndPassword(
      email: email,
      password: pass,
    )).user;
  }
}
