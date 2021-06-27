import 'dart:async';

import 'package:deck_royale_app/colors.dart';
import 'package:deck_royale_app/login_page.dart';
import 'package:deck_royale_app/root_page.dart';
import 'package:deck_royale_app/simulate_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:deck_royale_app/search_page.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:connectivity/connectivity.dart';

import 'account_page.dart';
import 'build_deck_page.dart';
import 'controller.dart';
import 'dialogs.dart';
import 'custom_navbar.dart';
import 'custom_navbar_item.dart';

class DeckRoyaleHomePage extends StatefulWidget {
  @override
  _DeckRoyaleHomePageState createState() => _DeckRoyaleHomePageState();
}

class _DeckRoyaleHomePageState extends StateMVC<DeckRoyaleHomePage> {
  _DeckRoyaleHomePageState():super(HomeCtrl());
  Function sortCardListener;
  StreamSubscription _onConnectivityChanged;
  List<Widget> _pages;

  @override
  void initState() {
    _pages = [
      BuildDeckWidget(provideSortListener: addSortListener),
      SearchWidget(),
      RootView(),
      SimulateWidget(),
      AccountView(),
    ];
    _onConnectivityChanged = Connectivity().onConnectivityChanged.listen(_onChanged);
    super.initState();
  }

  @override
  void dispose() {
    _onConnectivityChanged.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return HomeCtrl.me.logged?Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
            title: Image.asset(
              'resources/images/logo_extended.png',
              fit: BoxFit.fitHeight,
              width: 170,
            ),
            centerTitle: true,
            shadowColor: Colors.black,
            backgroundColor: DRColors.black,
            brightness: Brightness.dark,
            actions: HomeCtrl.me.tab==DRTabs.build?
            (<Widget>[
              Builder(builder: (context) {
                return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: IconButton(
                        tooltip: "Sort cards",
                        icon: Icon(
                          Icons.sort_rounded,
                          color: DRColors.white2,
                          size: 30,
                        ),
                        onPressed: (){_sortCards(context);}
                    )
                );
              })
            ])
                :
            (HomeCtrl.me.tab == DRTabs.home && RootCtrl.me.isFireLogged && HomeCtrl.me.isConnected) ?
            (<Widget>[
              Builder(builder: (context) {
                return Container(
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: RootCtrl.me.isModifiable? DRColors.black2:Colors.transparent
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: IconButton(
                      tooltip: "Edit folders",
                      icon: Icon(
                        Icons.edit_rounded,
                        color: DRColors.white2,
                        size: 30,
                      ),
                      onPressed: (){ RootCtrl.me.setModifiable(); }
                  ),
                );
              })
            ])
                :
            (HomeCtrl.me.tab == DRTabs.search && HomeCtrl.me.isConnected)?
            (<Widget>[
              Builder(builder: (context) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: IconButton(
                      tooltip: "Info",
                      icon: Icon(
                        Icons.info,
                        color: DRColors.white2,
                        size: 30,
                      ),
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => InfoTagWidget()))
                  ),
                );
              })
            ])
                :
            (null)
        ),
        body: Container(
            child: (HomeCtrl.me.isConnected ?
            _pages[HomeCtrl.me.tab] :
            (HomeCtrl.me.tab==DRTabs.home||HomeCtrl.me.tab==DRTabs.search ||HomeCtrl.me.tab==DRTabs.settings?
              EmptyWidget() :
              _pages[HomeCtrl.me.tab]
            )),
        ),
        bottomNavigationBar: CustomNavbar(
          onTap: HomeCtrl.me.setTab,
          currentIndex: HomeCtrl.me.tab,
          items: [
            CustomNavbarItem(icon: CupertinoIcons.square_stack_3d_down_right, title: "Build"),
            CustomNavbarItem(icon: CupertinoIcons.search, title: "Search"),
            CustomNavbarItem(icon: CupertinoIcons.rectangle_grid_1x2, title: "Home"),
            CustomNavbarItem(icon: CupertinoIcons.game_controller, title: "Simulator"),
            CustomNavbarItem(icon: CupertinoIcons.person, title: "Account"),
          ],
          iconSize: 22,
          fontSize: 10,
          margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
          borderRadius: 0,
          itemBorderRadius: 6,
          selectedItemColor: Colors.white54,
          unselectedItemColor: Colors.white54,
          backgroundColor: DRColors.black,
          selectedBackgroundColor: Color(0xFF1A1A1A),
        ),
        floatingActionButton: Visibility(
            visible: HomeCtrl.me.floatingButton && HomeCtrl.me.isConnected,
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
                  key: Key("add folder button"),
                  backgroundColor: DRColors.orange,
                  icon: Icon(
                    CupertinoIcons.add_circled_solid,
                    size: MediaQuery.of(context).orientation == Orientation.portrait ? 26 : 35,
                    color: DRColors.black2,
                  ),
                  label: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 4, 0, 0),
                    child: Text(
                      "Create Folder",
                      key: Key("create folder text"),
                      style: TextStyle(
                        color: DRColors.black2,
                        fontSize: MediaQuery.of(context).orientation == Orientation.portrait ? 13 : 16,
                      ),
                    ),
                  ),
                  onPressed: (){
                    showDialog(
                        context: context,
                        builder: (BuildContext context){
                          return AddFolderDialog(add: this.addFolder, isTaken: this.validateName);
                        }
                    );},
                )
            )
        )
    ):LoginPage();
  }

  void _sortCards(context) {
    HomeCtrl.me.nextSort();
    sortCardListener(HomeCtrl.me.currentSort);
    Scaffold.of(context).showSnackBar(SnackBar(
      duration: Duration(milliseconds: 800),
      content: Text(DRSorts.sortMessages[HomeCtrl.me.currentSort],
      ),
    ));
  }

  void addSortListener(Function f){ sortCardListener = f; }

  void addFolder(String name){ RootCtrl.me.addFolder(name); }
  bool validateName(String name){ return RootCtrl.me.isFolderNameTaken(name); }

  void _onChanged(ConnectivityResult event){
    HomeCtrl.me.checkConnectivityEvent(event);
  }
}

class ErrorWidgetCustom extends StatelessWidget{

  final String error;

  ErrorWidgetCustom(this.error);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).orientation == Orientation.portrait?400:800,
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage('resources/images/deckBuildBackground.png'),
              fit: BoxFit.fitWidth,
              colorFilter: ColorFilter.mode(Color(0xDD111111), BlendMode.srcOver)
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("resources/images/error.png", width: MediaQuery.of(context).size.width/1.6,),
            SizedBox(height: 20,),
            Text(
              "Something went wrong...",
              style: TextStyle(
                  fontSize: 18,
                  color: DRColors.white
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20,),
            Text(
              error,
              style: TextStyle(
                  fontSize: 16,
                  color: DRColors.white
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

}

class EmptyWidget extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          decoration: BoxDecoration(image: DRColors.background,),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              BigTextWidget('Turn on your internet connection and then'),

              Padding(
                padding: const EdgeInsets.only(top:5),
                child: FlatButton(
                  height: 18,
                  padding: const EdgeInsets.all(0),
                  child: Text(
                    'Reload page',
                    style: TextStyle(fontSize: 18,color: DRColors.orange),
                  ),
                  onPressed: () { HomeCtrl.me.checkConnectivity(); },
                ),
              ),
            ],
          ),
          alignment: Alignment.center,
        )
    );
  }
}


