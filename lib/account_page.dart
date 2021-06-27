import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:flutter/cupertino.dart';

import 'colors.dart';
import 'controller.dart';
import 'dialogs.dart';
import 'model.dart';
import 'search_page.dart';

class AccountView extends StatefulWidget {
  @override
  _AccountViewState createState() => _AccountViewState();
}

class _AccountViewState extends StateMVC<AccountView> {
  _AccountViewState():super(AccountCtrl());
  double _width;
  double _height;
  SearchCtrl _searchController;
  Widget _accountView;

  @override
  void initState() {
    _searchController = SearchCtrl();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _width = MediaQuery.of(context).size.width;
    _height = MediaQuery.of(context).size.height;
    List<Widget> children = [];


    if (AccountCtrl.me.isLogged){ //Tag provided

      _accountView = FutureBuilder<PlayerData>(
          future: _searchController.getPlayer(AccountCtrl.me.getUserTag()),
          builder:
              (BuildContext context, AsyncSnapshot<PlayerData> snapshot) {
            if (AccountCtrl.me.playerStatistics!=null) {
              children = <Widget>[PlayerResume(data: AccountCtrl.me.playerStatistics)];
            } else if (snapshot.hasData) {
              children = <Widget>[PlayerResume(data: snapshot.data)];
            } else if (snapshot.hasError) {
              children = <Widget>[
                ErrorWidgetCustom2(
                  errorMessage: 'Check your internet connection and try again',
                )
              ];
            } else {
              children = <Widget>[
                SizedBox(
                  child: CircularProgressIndicator(),
                  width: 50,
                  height: 50,
                )
              ];
            }
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: children,
              ),
            );
          });

    }else{ //Tag not provided

      if (MediaQuery.of(context).orientation == Orientation.portrait) {
        _accountView = ListView(
          children: [

            TagLoginHandler(),

            AccountCtrl.me.isFireLogged?
            FirebaseAccountView():
            FirebaseLoginHandler(),

            AppInfoView(),
            SizedBox(height: 15,),

          ],
        );
      }else{
        _accountView = ListView(
          children: [

            Row(
              children: [
                AccountCtrl.me.isFireLogged?
                FirebaseAccountView():
                FirebaseLoginHandler(),

                TagLoginHandler(),
              ],
            ),

            AppInfoView(),
            SizedBox(height: 15,),

          ],
        );
      }
    }

    return Container(
      decoration: BoxDecoration(image: DRColors.background),
      width: _width,
      height: _height,
      child: _accountView,
    );
  }
}

//Player tag "account"
class PlayerResume extends StatelessWidget {
  final PlayerData data;
  PlayerResume({this.data});

  @override
  Widget build(BuildContext context) {
    List<Widget> list;

    if (data.player != null) {
      if (data.player.playerName.compareTo('') != 0) {
        if (MediaQuery.of(context).orientation == Orientation.portrait) {
          list = [
            mainPlayerRow(context),
            clanRow(context),
            statsRow(context),
            favCardRow(context),
            lastBattlesRow(context),
            chestsRow(context),
            ResetTagView(),
            AccountCtrl.me.isFireLogged
                ? FirebaseAccountView()
                : FirebaseLoginHandler(),
            AppInfoView(),
            SizedBox(
              height: 15,
            ),
          ];
        } else {
          list = [
            Row(children: [
              AccountCtrl.me.isFireLogged
                  ? FirebaseAccountView()
                  : FirebaseLoginHandler(),
              Column(children: [
                mainPlayerRow(context),
                clanRow(context),
                chestsRow(context),
              ]),
            ]),
            Row(children: [
              statsRow(context),
              favCardRow(context),
            ]),
            lastBattlesRow(context),
            Row(children: [
              ResetTagView(),
              AppInfoView(),
            ]),
            SizedBox(
              height: 15,
            ),
          ];
        }

        AccountCtrl.me.updatePlayerData(data);
        return Flexible(
            child: Container(
                child: ListView(
                  children: list,
                )
            )
        );
      }
    }
    return ErrorWidgetCustom2(
      errorMessage: "Player #${AccountCtrl.me.getUserTag()} not found, "
              "did you insert the correct tag?",
    );
  }

  Widget mainPlayerRow(BuildContext context) {
    return Container(
      decoration: DRColors.tile,
      height: MediaQuery.of(context).orientation == Orientation.portrait?150:220,
      width: MediaQuery.of(context).orientation == Orientation.portrait?MediaQuery.of(context).size.width:(MediaQuery.of(context).size.width/2)-20,
      margin: const EdgeInsets.fromLTRB(10, 15, 10, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Flexible(
              flex: 16,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    height: 16,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 12,
                      ),
                      Stack(children: [
                        SizedBox(
                            width: 40,
                            height: 40,
                            child: Image.asset("resources/images/level.png")),
                        Container(
                            width: 40,
                            height: 40,
                            alignment: Alignment.center,
                            child: Text(
                              data.player.playerExperienceLevel.toString(),
                              style: TextStyle(
                                fontSize: 14,
                                
                                color: DRColors.white2,
                                shadows: <Shadow>[
                                  Shadow(
                                    offset: Offset(0.5, 0.5),
                                    blurRadius: 1.5,
                                    color: Color.fromARGB(255, 0, 0, 0),
                                  )
                                ],
                              ),
                            )),
                      ]),
                      Container(
                        margin: const EdgeInsets.fromLTRB(10, 0, 5, 0),
                        padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                        alignment: Alignment.center,
                        child: Text(
                          data.player.playerName,
                          style: TextStyle(
                              fontSize: 18,
                              color: DRColors.white2),
                        ),
                        height: 40,
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 12,
                      ),
                      Container(
                        padding: const EdgeInsets.fromLTRB(0, 3, 0, 0),
                        alignment: Alignment.center,
                        child: Column(
                          children: [
                            Text(
                              "current",
                              style: TextStyle(color: DRColors.grey2),
                            ),
                            Container(
                              decoration: new BoxDecoration(
                                  color: DRColors.value,
                                  borderRadius: BorderRadius.circular(16)),
                              height: 30,
                              width: 100,
                              margin: const EdgeInsets.symmetric(vertical: 5),
                              alignment: Alignment.center,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: Image.asset(
                                          "resources/images/trophies.png")),
                                  Container(
                                    margin:
                                    const EdgeInsets.symmetric(horizontal: 5),
                                    padding: const EdgeInsets.fromLTRB(0, 3, 0, 0),
                                    alignment: Alignment.center,
                                    child: Text(
                                      data.player.currentTrophies.toString(),
                                      style: TextStyle(color: DRColors.white2),
                                    ),
                                    height: 30,
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                        height: 60,
                      ),
                      SizedBox(
                        width: 12,
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        padding: const EdgeInsets.fromLTRB(0, 3, 0, 0),
                        alignment: Alignment.center,
                        child: Column(
                          children: [
                            Stack(
                              children: [
                                Text(
                                  "best",
                                  style: TextStyle(
                                    foreground: Paint()
                                      ..style = PaintingStyle.stroke
                                      ..strokeWidth = 3
                                      ..color = Color(0xFF6F5400),
                                  ),
                                ),
                                Text(
                                  "best",
                                  style: TextStyle(color: Color(0xCCFFD700),),
                                ),
                              ],
                            ),
                            Container(
                              decoration: new BoxDecoration(
                                  color: DRColors.value,
                                  borderRadius: BorderRadius.circular(16)),
                              height: 30,
                              width: 100,
                              margin: const EdgeInsets.symmetric(vertical: 5),
                              alignment: Alignment.center,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: Image.asset(
                                          "resources/images/trophies.png")),
                                  Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 5),
                                    padding: const EdgeInsets.fromLTRB(0, 3, 0, 0),
                                    alignment: Alignment.center,
                                    child: Text(
                                      data.player.bestTrophies.toString(),
                                      style: TextStyle(color: DRColors.white2),
                                    ),
                                    height: 30,
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                        height: 60,
                      ),
                      SizedBox(
                        width: 6,
                      )
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  )
                ],
              )),
          Flexible(
              flex: 6,
              child: Column(
                children: [
                  Container(
                      margin: const EdgeInsets.fromLTRB(0, 6, 16, 0),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                      ),
                      height: 110,
                      child: Image.asset("resources/images/${data.player.currentArena.name}.png")
                  ),
                  Container(
                    margin: const EdgeInsets.fromLTRB(0, 0, 16, 0),
                    alignment: Alignment.center,
                    child: Text(
                      data.player.currentArena.name,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: DRColors.white2,
                          fontSize: 11
                      ),
                    ),
                    height: 30,
                  ),
                ],
              ))
        ],
      ),
    );
  }

  Widget clanRow(BuildContext context) {
    String clanTag = "NO_CLAN";
    String clanName = "No Clan";
    if(data.player.playerClan != null){
      clanTag = data.player.playerClan.tag;
      clanName = data.player.playerClan.name;
    }
    return Container(
        decoration: DRColors.tile,
        height: 50,
        width: MediaQuery.of(context).orientation == Orientation.portrait?MediaQuery.of(context).size.width:(MediaQuery.of(context).size.width/2)-20,
        margin: const EdgeInsets.fromLTRB(10, 15, 10, 0),
        child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.fromLTRB(20, 3, 0, 0),
                      alignment: Alignment.center,
                      child: Image.asset("resources/images/clanBadge.png"),
                      height: 36,
                    ),
                    Container(
                      padding: const EdgeInsets.fromLTRB(6, 3, 0, 0),
                      alignment: Alignment.center,
                      child: Text(
                        clanName,
                        style: TextStyle(
                            color: DRColors.white2,
                            fontSize: 15
                        ),
                      ),
                      height: 30,
                    ),
                  ],
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.fromLTRB(0, 3, 0, 0),
                      alignment: Alignment.center,
                      child: Stack(
                        children: [
                          Text(
                            "#$clanTag",
                            style: TextStyle(
                              foreground: Paint()
                                ..style = PaintingStyle.stroke
                                ..strokeWidth = 3
                                ..color = Color(0xFF444444),
                            ),
                          ),
                          Text(
                            "#$clanTag",
                            style: TextStyle(color: Color(0xFFD3D3D3),),
                          ),
                        ],
                      ),
                      height: 30,
                    ),
                    Container(
                        width: 20
                    )
                  ],
                )
              ],
            )
        )
    );
  }

  Widget statsRow(BuildContext context) {
    double ratio = data.player.playerWins/data.player.playerLosses;
    double width = MediaQuery.of(context).size.width - 20;
    if (MediaQuery.of(context).orientation == Orientation.landscape){
      width = width/2 - 10;
    }
    return Container(
        decoration: DRColors.tile,
        height: 280,
        width: width,
        margin: const EdgeInsets.fromLTRB(10, 15, 10, 0),
        padding: const EdgeInsets.only(top:5),
        child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  child: Text("Ladder", style: TextStyle(fontSize: 16, color: Color(0xFFCCCCCC)),),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      padding: const EdgeInsets.fromLTRB(0, 3, 0, 0),
                      width: width / 3 - 20,
                      alignment: Alignment.center,
                      child: Column(
                        children: [
                          Text(
                            "wins",
                            style: TextStyle(color: DRColors.grey2),
                          ),
                          Container(
                            decoration: new BoxDecoration(
                                color: DRColors.value,
                                borderRadius: BorderRadius.circular(16)),
                            height: 30,
                            width: 100,
                            margin: const EdgeInsets.symmetric(vertical: 5),
                            alignment: Alignment.center,
                            child: Text(
                              data.player.playerWins.toString(),
                              style: TextStyle(color: Color(0xFF98BB22)),
                            ),
                          )
                        ],
                      ),
                      height: 60,
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      padding: const EdgeInsets.fromLTRB(0, 3, 0, 0),
                      width: width / 3 - 20,
                      alignment: Alignment.center,
                      child: Column(
                        children: [
                          Text(
                            "losses",
                            style: TextStyle(color: DRColors.grey2),
                          ),
                          Container(
                            decoration: new BoxDecoration(
                                color: DRColors.value,
                                borderRadius: BorderRadius.circular(16)),
                            height: 30,
                            width: 100,
                            margin: const EdgeInsets.symmetric(vertical: 5),
                            alignment: Alignment.center,
                            child: Text(
                              data.player.playerLosses.toString(),
                              style: TextStyle(color: Color(0xFFDD5151)),
                            ),
                          )
                        ],
                      ),
                      height: 60,
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      padding: const EdgeInsets.fromLTRB(0, 3, 0, 0),
                      width: width / 3 - 20,
                      alignment: Alignment.center,
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "3",
                                style: TextStyle(color: DRColors.grey2),
                              ),
                              Container(
                                height: 14,
                                child: Image.asset("resources/images/crown.png"),
                              ),
                              Text(
                                " wins",
                                style: TextStyle(color: DRColors.grey2),
                              ),
                            ],
                          ),
                          Container(
                            decoration: new BoxDecoration(
                                color: DRColors.value,
                                borderRadius: BorderRadius.circular(16)),
                            height: 30,
                            width: 100,
                            margin: const EdgeInsets.symmetric(vertical: 5),
                            alignment: Alignment.center,
                            child: Text(
                              data.player.threeCrownWins.toString(),
                              style: TextStyle(color: DRColors.white2),
                            ),
                          )
                        ],
                      ),
                      height: 60,
                    ),
                  ],
                ),
                Container(
                  child: Text("Overall", style: TextStyle(fontSize: 16, color: Color(0xFFCCCCCC)),),
                  padding: const EdgeInsets.only(top:5),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      padding: const EdgeInsets.fromLTRB(0, 3, 0, 0),
                      width: width / 2 - 20,
                      alignment: Alignment.center,
                      child: Column(
                        children: [
                          Text(
                            "w/l ratio",
                            style: TextStyle(color: DRColors.grey2),
                          ),
                          Container(
                            decoration: new BoxDecoration(
                              color: DRColors.value,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Color(0xBBFFD700),
                                width: 2,
                              ),
                            ),
                            height: 30,
                            width: 100,
                            margin: const EdgeInsets.symmetric(vertical: 5),
                            alignment: Alignment.center,
                            child: Text(
                              ratio.toStringAsFixed(2),
                              style: TextStyle(color: DRColors.white2),
                            ),
                          )
                        ],
                      ),
                      height: 60,
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      padding: const EdgeInsets.fromLTRB(0, 3, 0, 0),
                      width: width / 2 - 20,
                      alignment: Alignment.center,
                      child: Column(
                        children: [
                          Text(
                            "total battles",
                            style: TextStyle(color: DRColors.grey2),
                          ),
                          Container(
                            decoration: new BoxDecoration(
                                color: DRColors.value,
                                borderRadius: BorderRadius.circular(16)),
                            height: 30,
                            width: 100,
                            margin: const EdgeInsets.symmetric(vertical: 5),
                            alignment: Alignment.center,
                            child: Text(
                              data.player.battleCount.toString(),
                              style: TextStyle(color: DRColors.white2),
                            ),
                          )
                        ],
                      ),
                      height: 60,
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      padding: const EdgeInsets.fromLTRB(0, 3, 0, 0),
                      width: width / 2 - 20,
                      alignment: Alignment.center,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "max challenge wins",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: DRColors.grey2),
                          ),
                          Container(
                            decoration: new BoxDecoration(
                                color: DRColors.value,
                                borderRadius: BorderRadius.circular(16)),
                            height: 30,
                            width: 100,
                            margin: const EdgeInsets.symmetric(vertical: 5),
                            alignment: Alignment.center,
                            child: Text(
                              data.player.maxChallengeWins.toString(),
                              style: TextStyle(color: DRColors.white2),
                            ),
                          )
                        ],
                      ),
                      height: 60,
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      padding: const EdgeInsets.fromLTRB(0, 3, 0, 0),
                      width: width / 2 - 20,
                      alignment: Alignment.center,
                      child: Column(
                        children: [
                          Text(
                            "total donations",
                            style: TextStyle(color: DRColors.grey2),
                          ),
                          Container(
                            decoration: new BoxDecoration(
                                color: DRColors.value,
                                borderRadius: BorderRadius.circular(16)),
                            height: 30,
                            width: 100,
                            margin: const EdgeInsets.symmetric(vertical: 5),
                            alignment: Alignment.center,
                            child: Text(
                              data.player.donations.toString(),
                              style: TextStyle(color: DRColors.white2),
                            ),
                          )
                        ],
                      ),
                      height: 60,
                    ),
                  ],
                ),
              ],
            )));
  }

  Widget favCardRow(BuildContext context) {
    double width = MediaQuery.of(context).size.width - 20;
    if (MediaQuery.of(context).orientation == Orientation.landscape){
      width = width/2 - 10;
    }
    return Container(
        decoration: DRColors.tile,
        height: MediaQuery.of(context).orientation == Orientation.portrait ? 200 : 280,
        width: width,
        margin: const EdgeInsets.fromLTRB(10, 15, 10, 0),
        child: Column(
          children: [

            Flexible(
              flex:5,
              child: Container(
                width: MediaQuery.of(context).size.width - 50,
                child: Image.asset(
                  "resources/images/"+data.player.favCard.name.toLowerCase().replaceAll(new RegExp(r"\s+"), "_")+"2.png",
                  fit: BoxFit.fitHeight,
                ),
              ),
            ),

            Flexible(
              flex:2,
              child: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        //width: 210,
                        //height: 100,
                        //alignment: Alignment.center,
                        child: Column(
                          children: [
                            Text(
                              "Favourite card",
                              style: TextStyle(
                                  color: DRColors.grey2,
                                  fontSize: 22),
                            ),
                            Stack(
                              children: [
                                Text(
                                  data.player.favCard.name,
                                  style: TextStyle(
                                    fontSize: 16,
                                    foreground: Paint()
                                      ..style = PaintingStyle.stroke
                                      ..strokeWidth = 3
                                      ..color = Color(0xFF5F4400),
                                  ),
                                ),
                                Text(
                                  data.player.favCard.name,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Color(0xDDFFA700),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      )
                    ],
                  )),
            ),
          ],
        ));
  }

  Widget lastBattlesRow(BuildContext context) {
    int lastWins = 0;
    int lastLosses = 0;
    double avgCrowns = 0;
    for (int i = 0; i < data.log.length; i++){
      data.log[i].isVictory? lastWins++ : lastLosses++;
      avgCrowns = avgCrowns + data.log[i].gainedCrowns;

    }
    if (data.log.isNotEmpty){
      avgCrowns = avgCrowns/data.log.length;
    }
    else{
      return Container();
    }
    return Container(
        decoration: DRColors.tile,
        height: 362,
        width: MediaQuery.of(context).size.width - 20,
        margin: const EdgeInsets.fromLTRB(10, 15, 10, 0),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.fromLTRB(0, 16, 0, 0),
              child: Text("Last "+data.log.length.toString()+" ladder battles", style: TextStyle(fontSize: 16, color: DRColors.white2),),
            ),
            Align(
                alignment: Alignment.center,
                child: Container(
                    height: 260,
                    width: MediaQuery.of(context).size.width - 10,
                    margin: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                    child: StackedAreaLineChart.withData(data.log)
                )
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  margin: const EdgeInsets.fromLTRB(5, 10, 5, 0),
                  padding: const EdgeInsets.fromLTRB(0, 3, 0, 0),
                  width: MediaQuery.of(context).size.width / 3 - 20,
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      Text(
                        "wins",
                        style: TextStyle(color: DRColors.grey2),
                      ),
                      Container(
                        decoration: new BoxDecoration(
                            color: DRColors.value,
                            borderRadius: BorderRadius.circular(16)),
                        height: 30,
                        width: 100,
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        alignment: Alignment.center,
                        child: Text(
                          lastWins.toString(),
                          style: TextStyle(color: Color(0xFF98BB22)),
                        ),
                      )
                    ],
                  ),
                  height: 60,
                ),
                Container(
                  margin: const EdgeInsets.fromLTRB(5, 10, 5, 0),
                  padding: const EdgeInsets.fromLTRB(0, 3, 0, 0),
                  width: MediaQuery.of(context).size.width / 3 - 20,
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      Text(
                        "losses",
                        style: TextStyle(color: DRColors.grey2),
                      ),
                      Container(
                        decoration: new BoxDecoration(
                            color: DRColors.value,
                            borderRadius: BorderRadius.circular(16)),
                        height: 30,
                        width: 100,
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        alignment: Alignment.center,
                        child: Text(
                          lastLosses.toString(),
                          style: TextStyle(color: Color(0xFFDD5151)),
                        ),
                      )
                    ],
                  ),
                  height: 60,
                ),
                Container(
                  margin: const EdgeInsets.fromLTRB(5, 10, 5, 0),
                  padding: const EdgeInsets.fromLTRB(0, 3, 0, 0),
                  width: MediaQuery.of(context).size.width / 3 - 20,
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      Text(
                        "avg. crowns",
                        style: TextStyle(color: DRColors.grey2),
                      ),
                      Container(
                        decoration: new BoxDecoration(
                            color: DRColors.value,
                            borderRadius: BorderRadius.circular(16)),
                        height: 30,
                        width: 100,
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        alignment: Alignment.center,
                        child: Text(
                          avgCrowns.toStringAsFixed(2),
                          style: TextStyle(color: DRColors.white2),
                        ),
                      )
                    ],
                  ),
                  height: 60,
                ),
              ],
            ),
          ],
        )
    );
  }

  Widget chestsRow(BuildContext context) {
    return Container(
        decoration: DRColors.tile,
        height: 50,
        width: MediaQuery.of(context).orientation == Orientation.portrait?MediaQuery.of(context).size.width:(MediaQuery.of(context).size.width/2)-20,
        margin: const EdgeInsets.fromLTRB(10, 15, 10, 0),
        child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.fromLTRB(20, 3, 0, 0),
                      alignment: Alignment.center,
                      child: Image.asset("resources/images/Silver Chest.png"),
                      height: 36,
                    ),
                    Container(
                      padding: const EdgeInsets.fromLTRB(6, 3, 0, 0),
                      alignment: Alignment.center,
                      child: Text(
                        "Upcoming chests",
                        style: TextStyle(
                            color: DRColors.white2,
                            fontSize: 15
                        ),
                      ),
                      height: 30,
                    ),
                  ],
                ),
                Row(
                  children: [
                    Container(
                        width: 52,
                        height: 34,
                        child: RawMaterialButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ChestsView(data: data,)));
                          },
                          fillColor: Color(0x10FFFFFF),
                          child: Icon(
                            CupertinoIcons.arrow_right,
                            color: DRColors.white2,
                            size: 22,
                          ),
                          shape: CircleBorder(),
                        )
                    )
                  ],
                )
              ],
            )
        )
    );
  }

}

class ChestsView extends StatelessWidget{
  final PlayerData data;
  ChestsView({this.data});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        backgroundColor: DRColors.black,
        title: Padding(
          padding: const EdgeInsets.only(left:10),
          child: Text(
            "Upcoming chests",
            style: TextStyle(
              color: DRColors.white,
              fontSize: 16,
            ),
          ),
        ),
      ),
      body: Container(
        color:DRColors.black,
        child: ListView(
            children: [
              Container(
                  width: MediaQuery.of(context).size.width - 20,
                  margin: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SizedBox(height: 16,),
                      Container(
                          child: IgnorePointer(
                            child: GridView.count(
                              crossAxisCount: MediaQuery.of(context).orientation == Orientation.portrait? 3 : 7,
                              childAspectRatio: 1/1.3,
                              shrinkWrap: true,
                              children: List.generate(data.items.length, (index) {
                                return Container(
                                    decoration: new BoxDecoration(
                                        image: new DecorationImage(
                                            image: new AssetImage('resources/images/playerBG.png'),
                                            fit: BoxFit.fitHeight,
                                            colorFilter: ColorFilter.mode(Color(0x99000000), BlendMode.srcOver)
                                        ),
                                        borderRadius: BorderRadius.circular(16)
                                    ),
                                    margin: const EdgeInsets.all(4),
                                    child: Stack(
                                      children: [
                                        Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            SizedBox(height: 4,),
                                            Container(padding: const EdgeInsets.all(14), child: Image.asset('resources/images/'+data.items[index].name+'.png'),),
                                            Container(
                                              child: Text(data.items[index].name,
                                                style: TextStyle(fontSize: 11, color: DRColors.white2),
                                                textAlign: TextAlign.center,
                                              ),
                                              alignment: Alignment.center,),
                                          ],
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(vertical: 10),
                                          child: Text(data.items[index].index == 0? "Next" : "+"+data.items[index].index.toString(),
                                            style: TextStyle(fontSize: 15, color: DRColors.white2),),
                                          alignment: Alignment.topCenter,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(16),
                                            // color: Colors.orange
                                          ),
                                        ),
                                      ],
                                    )
                                );
                              }),
                            ),
                          )
                      )

                    ],
                  )
              ),
            ]
        ),
      ),
    );


  }

}

class TagLoginHandler extends StatefulWidget {
  @override
  _TagLoginHandlerState createState() => _TagLoginHandlerState();
}

class _TagLoginHandlerState extends State<TagLoginHandler> {
  TextEditingController _tc;
  GlobalKey<FormState> _formKey;

  @override
  void initState() {
    _tc = TextEditingController();
    _formKey = GlobalKey<FormState>();
    super.initState();
  }

  @override
  void dispose() {
    _tc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AccountContainer(
      heightDivider: MediaQuery.of(context).orientation == Orientation.portrait?3.2:2.3,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          AccountTitle(text: 'User Tag',),

          SizedBox(height: 15,),
          AccountText(
            text:'If you want to check your stats: favourite card, trophies, total wins and many more',
          ),

          SizedBox(height: 20),
          Form(
            key: _formKey,
            child: FractionallySizedBox(
              widthFactor: MediaQuery.of(context).orientation == Orientation.portrait?0.7:0.6,
              child: TextFormField(
                  keyboardType: TextInputType.text,
                  maxLength: 9,
                  textCapitalization: TextCapitalization.characters,
                  cursorColor: DRColors.orange,
                  controller: _tc,
                  style: TextStyle(
                   fontSize: MediaQuery.of(context).orientation ==
                       Orientation.portrait ? 17 : 20,
                    color: DRColors.orange,
                  ),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal:20),
                    labelStyle: TextStyle(
                      fontSize: MediaQuery.of(context).orientation ==
                          Orientation.portrait ? 17 : 20,
                      color: DRColors.grey,
                    ),
                    hintText: 'Tag',
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                    suffixIcon: IconButton(
                      icon: Icon(CupertinoIcons.arrow_right_circle_fill),
                      iconSize: MediaQuery.of(context).orientation == Orientation.portrait ? 30 : 35,
                      color: DRColors.orange,
                      onPressed: (){
                        if(_formKey.currentState.validate()){
                          AccountCtrl.me.addTag(_tc.text.toUpperCase());
                        }
                      },
                    ),
                    counterStyle: TextStyle(
                      fontSize: MediaQuery.of(context).orientation == Orientation.portrait ? 12 : 15,
                      fontFamily: 'Roboto',
                    ),
                    errorStyle: TextStyle(
                      fontSize: MediaQuery.of(context).orientation == Orientation.portrait ? 12 : 15,
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
                    if(value.length<6)
                      return 'Tag too short';
                    if(value.length>9)
                      return 'Tag too long';
                    return null;
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class ResetTagView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AccountContainer(
      heightDivider: 4,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            AccountTitle(
              text:'Current tag: #${AccountCtrl.me.getUserTag()}',
            ),

            SizedBox(height: min(MediaQuery.of(context).size.height*0.016,16)),
            AccountText(
              text:'You will not lose any of your decks or your folders, but it will not be possible to see the statistics associated with this tag.',
            ),

            SizedBox(height: min(MediaQuery.of(context).size.height*0.016,16)),
            FractionallySizedBox(
              widthFactor: 0.55,
              child: Container(
                height: MediaQuery.of(context).size.height / 20,
                width: MediaQuery.of(context).size.width/2 - 20,
                decoration: BoxDecoration(
                  color: DRColors.red.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(
                    color: DRColors.red.withOpacity(0.9),
                    width: 4,
                  ),
                ),
                child: ButtonTheme(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(30.0))),
                  minWidth: MediaQuery.of(context).size.width/ 2 - 24,
                  height: MediaQuery.of(context).size.height/19,
                  child: RaisedButton(
                    elevation: 0.0,
                    onPressed: () {
                      Future.delayed(const Duration(milliseconds: 900), () {
                        showDialog(
                            context: context,
                            builder: (BuildContext context){
                              return AreYouSureDialog2(
                                action: this.deleteTag,
                                message: 'Tag deleted',
                                icon: CupertinoIcons.trash_circle_fill,
                              );
                            }
                        );
                      });
                    },
                    color: DRColors.red.withOpacity(0.6),
                    child: Text(
                      'Reset Tag',
                      style: TextStyle(
                          color: DRColors.white,
                          fontSize: 16
                      ),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void deleteTag(){AccountCtrl.me.deleteTag();}
}

class AppInfoView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AccountContainer(
      heightDivider: MediaQuery.of(context).orientation == Orientation.portrait?5:4,
      child: Center(
        child: Text(
          'Deck Royale © : designed and developed by Lorenzo and Davide.\n\n\nIf you want to support us please send us cheering messages!',
          style: TextStyle(
            fontSize: MediaQuery.of(context).orientation == Orientation.portrait ? 15 : 19,
            color: DRColors.grey,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}


//Firebase account
class FirebaseAccountView extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    return AccountContainer(
        heightDivider: MediaQuery.of(context).orientation == Orientation.portrait?2.4:2.3,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            AccountTitle(text:AccountCtrl.me.getUserEmail),

            Padding(
              padding: EdgeInsets.only(top: min(MediaQuery.of(context).size.height*0.016,16)),
              child: AccountText(
                text: 'A backup of your folders and decks will be stored on our servers, '
                    'so that multiple devices can be synchronized with your data.',
              ),
            ),

            Padding(
              padding: EdgeInsets.only(top:min(MediaQuery.of(context).size.height*0.010,10)),
              child: AccountText(
                text:'Using those buttons you can log out from the current user or delete your account.',
              ),
            ),

            Padding(
              padding: EdgeInsets.only(top: min(MediaQuery.of(context).size.height*0.016,16)),
              child: FractionallySizedBox(
                widthFactor: 0.55,
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  height: MediaQuery.of(context).size.height / 20,
                  width: MediaQuery.of(context).size.width/2 - 20,
                  decoration: BoxDecoration(
                    color: DRColors.red.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(
                      color: DRColors.red.withOpacity(0.9),
                      width: 4,
                    ),
                  ),
                  child: ButtonTheme(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(30.0))),
                    minWidth: MediaQuery.of(context).size.width/ 2 - 24,
                    height: MediaQuery.of(context).size.height / 19,
                    child: RaisedButton(
                      elevation: 0.0,
                      onPressed: () {
                        Future.delayed(const Duration(milliseconds: 900), () {
                          showDialog(
                              context: context,
                              builder: (BuildContext context){
                                return AreYouSureDialog2(
                                  action: this.logoutAccount,
                                  message: 'Logged out',
                                  icon: CupertinoIcons.person_circle_fill,
                                );
                              }
                          );
                        });
                      },
                      color: DRColors.red.withOpacity(0.6),
                      child: Text(
                        'Log Out',
                        style: TextStyle(color: DRColors.white, fontSize: 16),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: MediaQuery.of(context).orientation == Orientation.portrait?const EdgeInsets.only(top:1):const EdgeInsets.only(top:10),
              child: FractionallySizedBox(
                widthFactor: 0.6,
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  height: MediaQuery.of(context).size.height / 20,
                  width: MediaQuery.of(context).size.width/2 - 20,
                  decoration: BoxDecoration(
                    color: DRColors.black.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(
                      color: DRColors.black.withOpacity(0.7),
                      width: 4,
                    ),
                  ),
                  child: ButtonTheme(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(30.0))),
                    minWidth: MediaQuery.of(context).size.width / 2 - 24,
                    height: MediaQuery.of(context).size.height / 19,
                    child: RaisedButton(
                      elevation: 0.0,
                      onPressed: () {
                        Future.delayed(const Duration(milliseconds: 900), () {
                          showDialog(
                              context: context,
                              builder: (BuildContext context){
                                return AreYouSureDialog2(
                                  action: this.deleteAccount,
                                  message: 'Account removed',
                                  icon: CupertinoIcons.delete,
                                );
                              }
                          );
                        });
                      },
                      color: DRColors.black2.withOpacity(0.3),
                      child: Text(
                        'Delete Account',
                        style: TextStyle(color: DRColors.white, fontSize: 16),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        )
    );
  }

  void logoutAccount(){AccountCtrl.me.logoutFirebaseAccount();}
  void deleteAccount(){AccountCtrl.me.deleteFirebaseAccount();}
}

class FirebaseLoginHandler extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return AccountContainer(
      heightDivider: 2.3,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          AccountTitle(text: 'Login',),

          SizedBox(height: 20,),
          FractionallySizedBox(
            widthFactor: MediaQuery.of(context).orientation == Orientation.portrait?0.9:1,
            child: AccountText(
              text: 'Login if you want to create folders and save your decks. You only need to confirm your email address.\n',
            ),
          ),

          SizedBox(height: MediaQuery.of(context).orientation == Orientation.portrait?10:30,),

          FractionallySizedBox(
              widthFactor: 0.55,
              child: Container(
                  height: MediaQuery.of(context).size.height / 20,
                  width: MediaQuery.of(context).size.width/2 - 20,
                  decoration: BoxDecoration(
                    color: DRColors.orange.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(
                      color: DRColors.orange.withOpacity(0.6),
                      width: 4,
                    ),
                  ),
                  child: ButtonTheme(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(30.0))),
                      minWidth: MediaQuery.of(context).size.width/ 2 - 24,
                      height: MediaQuery.of(context).size.height/19,
                      child: RaisedButton(
                        elevation: 0.0,
                        onPressed: () {
                          HomeCtrl.me.setNotLogged();
                        },
                        color: DRColors.orange,
                        child: Text(
                          'Login',
                          style: TextStyle(color: DRColors.black2, fontSize: 16),
                        ),
                      )
                  )
              )
          )
        ],
      ),
    );
  }


}


//Utility
class AccountContainer extends StatelessWidget {
  final double heightDivider;
  final Widget child;
  AccountContainer({this.child,this.heightDivider});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height/heightDivider,
      width: MediaQuery.of(context).orientation == Orientation.portrait?MediaQuery.of(context).size.width-20:(MediaQuery.of(context).size.width/2)-20,
      decoration: DRColors.tile,
      margin: const EdgeInsets.fromLTRB(10, 15, 10, 0),
      padding: MediaQuery.of(context).orientation == Orientation.portrait? const EdgeInsets.all(15):const EdgeInsets.symmetric(vertical:15,horizontal: 40),
      child: child,
    );
  }
}

class AccountTitle extends StatelessWidget {
  final String text;
  AccountTitle({this.text});
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: MediaQuery.of(context).orientation == Orientation.portrait ? 18 : 21,
        color: DRColors.white,
      ),
      textAlign: TextAlign.center,
    );
  }
}

class AccountText extends StatelessWidget {
  final String text;
  AccountText({this.text});
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: MediaQuery.of(context).orientation == Orientation.portrait ? 12 : 15,
        
        color: DRColors.grey,
      ),
      textAlign: TextAlign.center,
    );
  }
}

class ErrorWidgetCustom2 extends StatelessWidget{
  final String errorMessage;
  ErrorWidgetCustom2({this.errorMessage});

  @override
  Widget build(BuildContext context) {
    return AccountContainer(
      heightDivider: 1.5,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            "resources/images/error.png",
            height: 200,
            width: 200,
          ),
          Padding(
            padding: const EdgeInsets.only(top:20),
            child: AccountTitle(text:"Something went wrong...",),
          ),
          Padding(
            padding: const EdgeInsets.only(top:20),
            child: AccountText(text:errorMessage,),
          ),
          Padding(
            padding: const EdgeInsets.only(top:20),
            child: FractionallySizedBox(
              widthFactor: 0.55,
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 5),
                height: MediaQuery.of(context).size.height / 15,
                width: MediaQuery.of(context).size.width/2 - 20,
                decoration: BoxDecoration(
                  color: DRColors.blue.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(
                    color: DRColors.blue.withOpacity(0.6),
                    width: 4,
                  ),
                ),
                child: ButtonTheme(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(30.0))),
                  minWidth: MediaQuery.of(context).size.width/ 2 - 24,
                  height: MediaQuery.of(context).size.height / 19,
                  child: RaisedButton(
                    elevation: 0.0,
                    onPressed: () { AccountCtrl.me.deleteTag(); },
                    color: DRColors.blue,
                    child: Text(
                      'Try again',
                      style: TextStyle(color: DRColors.white, fontSize: 16),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}