import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:spritewidget/spritewidget.dart';

import 'colors.dart';

part 'model.g.dart';

class App{
  static Root root = Root.empty();
  static GameCards gameCards = GameCards.empty();
  static Account account = Account.neverLogged();
  static PlayerData playerData;

  //Simulation
  static ImageMap simulateImages = new ImageMap(rootBundle);
  static SpriteSheet spriteCards0;
  static SpriteSheet spriteCards1;
  static SpriteSheet spriteCards2;

  //Firebase
  static FirebaseApp firebaseApp;
  static FirebaseDatabase firebaseDatabase;
  static DatabaseReference realtimeDatabase;
  static FirebaseStorage storage;
  static FirebaseAuth auth;
}

@JsonSerializable(explicitToJson: true)
class Root{
  List<Folder> folders;

  Root(this.folders);
  Root.empty(){this.folders=[];}

  factory Root.fromJson(Map<String, dynamic> json) => _$RootFromJson(json);
  Map<String, dynamic> toJson() => _$RootToJson(this);
}

@JsonSerializable(explicitToJson: true)
class Folder{
  String name;
  int image;
  List<Deck> decks;

  Folder(this.name,this.image,this.decks);

  factory Folder.fromJson(Map<String, dynamic> json) {
    return _$FolderFromJson(json);}
  Map<String, dynamic> toJson() => _$FolderToJson(this);
}

@JsonSerializable(explicitToJson: true)
class Deck{
  List<int> cards;
  double avgElixir;

  Deck(this.cards,this.avgElixir);

  factory Deck.fromJson(Map<String, dynamic> json) => _$DeckFromJson(json);
  Map<String, dynamic> toJson() => _$DeckToJson(this);

  Deck get getCopy => Deck(new List.from(cards), this.avgElixir);
}

@JsonSerializable(explicitToJson: true)
class GameCards{
  List<SingleCard> items;
  List<SingleCard> sortedItems = []; //Remove from script
  GameCards(this.items);
  GameCards.empty();

  factory GameCards.fromJson(Map<String, dynamic> json) => _$GameCardsFromJson(json);
}

@JsonSerializable(explicitToJson: true)
class SingleCard{
  String name;
  int id;
  int maxLevel;
  String asset;
  int cost;
  int rarity;
  int arena;
  int category;
  String dspro;
  bool sim;
  SingleCard(this.name,this.id,this.maxLevel,this.asset,this.cost,
      this.rarity, this.arena,this.category,this.dspro,this.sim);
  SingleCard.forFavCard({this.name});

  //Json
  factory SingleCard.fromJson(Map<String, dynamic> json) => _$SingleCardFromJson(json);
  Map<String, dynamic> toJson() => _$SingleCardToJson(this);

  //Getters
  String getRarityString(){
    switch(rarity){
      case 1: { return 'Common';} break;
      case 2: { return 'Rare';} break;
      case 3: { return 'Epic';} break;
      case 4: { return 'Legendary';} break;
    }
    throw 'Error occurred in card $name -> rarity value not valid';
  }
  String getCategoryString(){
    switch(category){
      case 1: { return 'Win conditions';} break;
      case 2: { return 'Troops';} break;
      case 3: { return 'Spells';} break;
      case 4: { return 'Buildings';} break;
      case 5: { return 'Spicy';} break;
    }
    throw 'Error occurred in card $name -> category value not valid';
  }
  String get getCostString => cost>0? cost.toString() : '?' ;

  static int getLevelIndependence(int id){
    List<int> levelIndependent = [26000030,26000031,26000000,26000004,26000084,26000019,26000049,28000001,26000056,
                                  28000018,26000047,28000016,26000038,27000009,26000039,26000067,26000018,26000011,
                                  26000036,26000068,27000003,28000003,27000007,28000002,26000012,28000012,26000025,
                                  28000013,26000015,28000009,26000027,26000016,28000005,26000034,26000045,26000020,
                                  26000009,26000085,26000032,26000026,26000023,26000050,26000048,26000037,26000083,
                                  26000055,26000033];
    List<int> stronger = [26000024,26000043,26000012,28000004,26000026,28000010];
    List<int> weaker = [26000002,26000005,26000041,26000022,26000040,26000028,26000014,27000010,26000017,28000004,
                        26000007,26000042,26000029];
    if(levelIndependent.contains(id)){
      return 0;
    }
    if(stronger.contains(id)){
      return 1;
    }
    if(weaker.contains(id)){
      return 2;
    }
    return -1;
  }

}

@JsonSerializable(explicitToJson: true)
class Account{
  //Firebase
  int loginType = Account.none;
  String userId;
  String deviceKey;
  //Firebase with link
  String userEmail;

  //Clash Royale tag for statistics
  bool isTagLogged;
  String userTag;

  //Sorting preferences
  int sortType;

  Account(this.loginType,this.userId,this.deviceKey,this.userEmail
      ,this.isTagLogged,this.userTag,this.sortType);
  Account.neverLogged(){
    this.loginType = Account.none;
    this.userId = '';
    //this.deviceKey = ''; is null
    this.userEmail = '';
    this.isTagLogged = false;
    this.userTag = '';
    this.sortType = DRSorts.standard;
  }
  Account.fromElimination(Account old){
    this.loginType = Account.none;
    this.userId = '';
    this.deviceKey = old.deviceKey;
    this.userEmail = '';
    this.isTagLogged = old.isTagLogged;
    this.userTag = old.userTag;
    this.sortType = old.sortType;
  }
  factory Account.fromJson(Map<String, dynamic> json) => _$AccountFromJson(json);
  Map<String, dynamic> toJson() => _$AccountToJson(this);

  static const int none = 0;
  static const int link = 1;
  static const int pass = 2;

  bool get isFireLogged => loginType != Account.none;
}

class DeckStatistics{
  int defense;
  int attack;
  int versatility;
  int synergy;
  List<Problem> problems;
  List<Warning> warnings;
  List<Info> infos;

  DeckStatistics(this.defense, this.attack, this.versatility, this.synergy, this.problems, this.warnings, this.infos);
}

class Info {
  String title;
  String content;

  Info(this.title, this.content);
}

class Warning {
  String title;
  String content;

  Warning(this.title, this.content);
}

class Problem {
  String title;
  String content;

  Problem(this.title, this.content);
}
@JsonSerializable(explicitToJson: true)
class PlayerData{
  Player player;
  List<Chest> items; //UpcomingChests
  List<BattleSmall> log; //LastPvpBattles
  PlayerData(this.player,this.items,this.log);
  PlayerData.empty();

  factory PlayerData.fromJson(Map<String, dynamic> json) => _$PlayerDataFromJson(json);
  Map<String, dynamic> toJson() => _$PlayerDataToJson(this);
  bool isNull() => player==null? true:false;
  factory PlayerData.fromRemote(Map<String, dynamic> playerJson, Map<String, dynamic> chestsJson, Iterable battlesJson){
    List<BattleSmall> lastBattles = List<BattleSmall>.from(battlesJson.map((i) => BattleSmall.fromRemote(i)));
    lastBattles.removeWhere((value) => value == null);
    return PlayerData(
      Player.fromRemote(playerJson),
      chestsJson['items'].map((data) => Chest.fromJson(data)).toList().cast<Chest>(),
      lastBattles
    );
  }
}

@JsonSerializable(explicitToJson: true)
class Player{
  String playerName;
  int playerExperienceLevel;
  int currentTrophies;
  int bestTrophies;
  int playerWins;
  int playerLosses;
  int battleCount;
  int donations;
  int threeCrownWins;
  int maxChallengeWins;
  Arena currentArena;
  ClanSmall playerClan;
  FavCard favCard;

  Player(this.playerName, this.playerExperienceLevel, this.currentTrophies, this.bestTrophies, this.playerWins,
    this.playerLosses, this.battleCount, this.donations, this.threeCrownWins,
    this.maxChallengeWins, this.currentArena, this.playerClan, this.favCard);

  Player.empty();

  factory Player.fromJson(Map<String, dynamic> json) => _$PlayerFromJson(json);
  Map<String, dynamic> toJson() => _$PlayerToJson(this);

  factory Player.fromRemote(Map<String, dynamic> playerJson){
    bool nullClan = playerJson['clan'] == null;
    return Player(
        playerJson['name'],
        playerJson['expLevel'],
        playerJson['trophies'],
        playerJson['bestTrophies'],
        playerJson['wins'],
        playerJson['losses'],
        playerJson['battleCount'],
        playerJson['totalDonations'],
        playerJson['threeCrownWins'],
        playerJson['challengeMaxWins'],
        Arena.fromJson(playerJson['arena']),
        nullClan? null : ClanSmall.fromRemote(playerJson['clan']),
        FavCard.fromJson(playerJson['currentFavouriteCard'])
    );
  }
}

@JsonSerializable(explicitToJson: true)
class Chest {
  int index;
  String name;
  Chest(this.index, this.name);
  factory Chest.fromJson(Map<String, dynamic> json) => _$ChestFromJson(json);
  Map<String, dynamic> toJson() => _$ChestToJson(this);
}

@JsonSerializable(explicitToJson: true)
class BattleSmall {
  String battleType;
  int finalTrophies;
  int gainedCrowns;
  bool isVictory;

  BattleSmall(this.battleType, this.finalTrophies, this.gainedCrowns, this.isVictory);

  factory BattleSmall.fromJson(Map<String, dynamic> json) => _$BattleSmallFromJson(json);
  Map<String, dynamic> toJson() => _$BattleSmallToJson(this);

  factory BattleSmall.fromRemote(Map<String, dynamic> parsedJson) {
    if (parsedJson['type'] != "PvP"){
      return null;
    }
    BattlePlayer bp = parsedJson['team'].map((data) => BattlePlayer.fromRemote(data)).toList()[0];
    return BattleSmall(
      "PvP",
      bp.finalTrophies,
      bp.crowns,
      bp.isVictory,
    );
  }
}

@JsonSerializable(explicitToJson: true)
class BattlePlayer {
  int finalTrophies;
  int crowns;
  bool isVictory;
  BattlePlayer(this.finalTrophies, this.crowns, this.isVictory);

  factory BattlePlayer.fromJson(Map<String, dynamic> json) => _$BattlePlayerFromJson(json);
  Map<String, dynamic> toJson() => _$BattlePlayerToJson(this);

  factory BattlePlayer.fromRemote(Map<String, dynamic> parsedJson) {
    return BattlePlayer(
        parsedJson['trophyChange'] == null? parsedJson['startingTrophies'] : parsedJson['startingTrophies'] + parsedJson['trophyChange'],
        parsedJson['crowns'],
        parsedJson['trophyChange'] == null? true : (parsedJson['trophyChange']>0)? true:false
    );
  }
}

@JsonSerializable(explicitToJson: true)
class Arena {
  String name;
  Arena(this.name);
  factory Arena.fromJson(Map<String, dynamic> json) => _$ArenaFromJson(json);
  Map<String, dynamic> toJson() => _$ArenaToJson(this);
}

@JsonSerializable(explicitToJson: true)
class ClanSmall {
  String tag;
  String name;
  ClanSmall(this.tag, this.name);

  factory ClanSmall.fromJson(Map<String, dynamic> json) => _$ClanSmallFromJson(json);
  Map<String, dynamic> toJson() => _$ClanSmallToJson(this);

  factory ClanSmall.fromRemote(Map<String, dynamic> parsedJson){
    return ClanSmall(
      parsedJson['tag'].toString().substring(1),
      parsedJson['name'],
    );
  }
}

@JsonSerializable(explicitToJson: true)
class Clan {
  String name;
  Location location;
  int members;
  int clanScore;
  int requiredTrophies;
  int donationsPerWeek;
  int clanWarTrophies;
  List<ClanMember> memberList;

  Clan(this.name, this.location, this.members, this.clanScore,
      this.requiredTrophies, this.donationsPerWeek,
    this.clanWarTrophies, this.memberList);
  Clan.empty();
  bool isNull() => location==null? true:false;
  factory Clan.fromJson(Map<String, dynamic> json) => _$ClanFromJson(json);
  Map<String, dynamic> toJson() => _$ClanToJson(this);

  factory Clan.fromRemote(Map<String, dynamic> parsedJson){
    return Clan(
        parsedJson['name'],
        Location.fromJson(parsedJson['location']),
        parsedJson['members'],
        parsedJson['clanScore'],
        parsedJson['requiredTrophies'],
        parsedJson['donationsPerWeek'],
        parsedJson['clanWarTrophies'],
        parsedJson['memberList'].map((data) => ClanMember.fromJson(data)).toList().cast<ClanMember>()
    );
  }
}

@JsonSerializable(explicitToJson: true)
class ClanMember {
  String name;
  String tag;
  String role;
  int trophies;
  ClanMember(this.name, this.tag, this.role, this.trophies);
  factory ClanMember.fromJson(Map<String, dynamic> json) => _$ClanMemberFromJson(json);
  Map<String, dynamic> toJson() => _$ClanMemberToJson(this);
}

@JsonSerializable(explicitToJson: true)
class Location {
  String name;
  Location(this.name);
  factory Location.fromJson(Map<String, dynamic> json) => _$LocationFromJson(json);
  Map<String, dynamic> toJson() => _$LocationToJson(this);
}

@JsonSerializable(explicitToJson: true)
class FavCard{
  String name;
  FavCard(this.name);
  factory FavCard.fromJson(Map<String, dynamic> json) => _$FavCardFromJson(json);
  Map<String, dynamic> toJson() => _$FavCardToJson(this);
}

