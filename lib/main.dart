import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'controller.dart';
import 'controller_passive.dart';
import 'home_page.dart';
import 'colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await InternetCtrl.initFirebase();

  await MemoryCtrl.loadAccount();
  await MemoryCtrl.loadGameCards();
  await MemoryCtrl.loadSimulateAssets();

  AccountCtrl();
  HomeCtrl();
  RootCtrl();
  FolderCtrl();
  DialogCtrl();
  SimulateCtrl();
  await HomeCtrl.me.checkInitialConnectivity();

  MemoryCtrl.initCards();

  if (HomeCtrl.me.isConnected) {
    if (! await InternetCtrl.isFirebaseAccountDeleted()) {
      await InternetCtrl.updateLocalRoot(true);
    }else{
      AccountCtrl.me.deleteLocalFirebaseAccount();
    }
  }

  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: DRColors.black,
    systemNavigationBarColor: DRColors.black,
  ));
  runApp(DeckRoyaleApp());
}

class DeckRoyaleApp extends AppMVC {

  @override
  Widget build(BuildContext context) {

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
    precacheImage(AssetImage('resources/images/deckBuildBackground.png'), context);

    return MaterialApp(
      color: DRColors.black2,
      home: DeckRoyaleHomePage(),
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        fontFamily: 'Supercell',
        brightness: Brightness.dark,
        accentColor: DRColors.orange,
        cardColor: Colors.transparent, //To avoid bad effects on drag n drops
        scaffoldBackgroundColor: Color(0xFF1A1A1A),
        backgroundColor: DRColors.black,

        textSelectionColor: DRColors.orange,
        textSelectionHandleColor: DRColors.orange,

        textSelectionTheme: TextSelectionThemeData(
          selectionColor: DRColors.orange,
        ),

        dialogTheme: DialogTheme(
          backgroundColor: DRColors.black3,
          elevation: 60,
          shape: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),

        cardTheme: CardTheme(
          elevation: 20.0,
        ),

        snackBarTheme: SnackBarThemeData(
          backgroundColor: DRColors.blue,
          contentTextStyle: TextStyle(
            fontSize: 13,
            fontFamily:'Supercell',
            color: DRColors.white,
          ),
        ),

        buttonBarTheme: ButtonBarThemeData(
          alignment: MainAxisAlignment.center,
        ),

      ),

    );
  }
}