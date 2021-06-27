import 'dart:convert';
import 'package:deck_royale_app/colors.dart';
import 'package:deck_royale_app/model.dart';
import 'package:flutter_test/flutter_test.dart';

void main(){

  //tot tests: 34

  //App class, 3 tests
  group("class 'App' test", () {
    test("Root instance", () {
      expect(App.root is Root, true);
    });
    test("GameCards instance", () {
      expect(App.gameCards is GameCards, true);
    });
    test("Account instance", () {
      expect(App.account is Account, true);
    });
  });

  //Root class, 4 tests
  group("class 'Root' test", () {
    test("Root with folders constructor test", () {
      List<Folder> folders = [new Folder("TestFolder", 0, [])];
      expect(Root(null).folders, null);
      expect(Root(folders).folders, folders);
    });
    test("Root.empty() constructor", () {
      expect(Root.empty().folders, []);
    });
    test("Root.fromJson(json) factory constructor", () {
      String folders = '{"folders":[{"name": "TestFolder", "decks": [], "image": 1}]}';
      Map<String, dynamic> jsonFolders = json.decode(folders);
      expect(Root.fromJson(jsonFolders) is Root, true);
      expect(Root.fromJson(jsonFolders).folders is List<Folder>, true);
    });
    test("Root.toJson() method", () {
      List<Folder> folders = [new Folder("TestFolder", 0, [])];
      expect(Root(folders).toJson().toString(), "{folders: [{name: TestFolder, image: 0, decks: []}]}");
    });
  });

  //Folder class, 3 tests
  group("class 'Folder' test", () {
    test("Folder constructor test", () {
      expect(Folder("TestFolder", 0, []).name, "TestFolder");
      expect(Folder("TestFolder", 0, []).image, 0);
      expect(Folder("TestFolder", 0, []).decks, []);
    });
    test("Folder.fromJson(json) factory constructor", () {
      String folder = '{"name": "TestFolder", "decks": [], "image": 1}';
      Map<String, dynamic> jsonFolder = json.decode(folder);
      expect(Folder.fromJson(jsonFolder) is Folder, true);
    });
    test("Folder.toJson() method", () {
      Folder folder = new Folder("TestFolder", 0, []);
      expect(folder.toJson().toString(), '{name: TestFolder, image: 0, decks: []}');
    });
  });

  //Deck class, 4 tests
  group("class 'Deck' test", () {
    test("Deck constructor test", () {
      expect(Deck([], 1).cards, []);
      expect(Deck([], 1).avgElixir, 1);
    });
    test("Deck.fromJson(json) factory constructor", () {
      String deck = '{"cards": [26000008, 26000004, 26000016, 26000021, 26000019, 26000006, 26000001, 26000009], "avgElixir": 4.875}';
      Map<String, dynamic> jsonDeck = json.decode(deck);
      expect(Deck.fromJson(jsonDeck) is Deck, true);
    });
    test("Deck.toJson() method", () {
      Deck deck = new Deck([26000008, 26000004, 26000016, 26000021, 26000019, 26000006, 26000001, 26000009], 1);
      expect(deck.toJson().toString(), '{cards: [26000008, 26000004, 26000016, 26000021, 26000019, 26000006, 26000001, 26000009], avgElixir: 1.0}');
    });
    test("getCopy method", () {
      Deck deck = new Deck([26000008, 26000004, 26000016, 26000021, 26000019, 26000006, 26000001, 26000009], 1);
      expect(deck.getCopy.cards, deck.cards);
      expect(deck.getCopy.avgElixir, deck.avgElixir);
    });
  });

  //GameCards class, 5 tests
  group("class 'GameCards' test", () {
    test("GameCards with items constructor test", () {
      List<SingleCard> items = [];
      expect(GameCards(null).items, null);
      expect(GameCards(items).items, []);
    });
    test("GameCards.empty() constructor", () {
      expect(GameCards.empty().items, null);
    });
    test("GameCards.fromJson(json) factory constructor", () {
      String gameCards = '{"items": [], "sortedItems": [], "sortType": 0}';
      Map<String, dynamic> jsonGameCards = json.decode(gameCards);
      expect(GameCards.fromJson(jsonGameCards) is GameCards, true);
    });
    test("getCardByID(id) method", () {
      List<SingleCard> items = [new SingleCard("testCard", 1, 1, "asset", 1, 1, 1, 1, "testCard",true)];
      GameCards gameCards = new GameCards(items);
      expect(gameCards.items[0] is SingleCard, true);
    });
  });

  //SingleCard class, 8 tests
  group("class 'SingleCard' test", () {
    test("SingleCard constructor test", () {
      SingleCard card = new SingleCard("testCard", 1, 1, "asset", 1, 1, 1, 1, "dspro",true);
      expect(card.name, "testCard");
      expect(card.id, 1);
      expect(card.maxLevel, 1);
      expect(card.asset, "asset");
      expect(card.cost, 1);
      expect(card.rarity, 1);
      expect(card.arena, 1);
      expect(card.category, 1);
      expect(card.dspro, "dspro");
      expect(card.sim, true);
    });
    test("GameCards.forFavCard(name) constructor", () {
      expect(SingleCard.forFavCard(name: "testCard").name, "testCard");
    });
    test("GameCards.fromJson(json) factory constructor", () {
      String singleCard = '{"name":"Knight","id":26000000,"maxLevel":13,"asset":"knight.png","cost":3,"rarity":1,"arena":0,"category":2,"dspro":"Knight","sim":true}';
      Map<String, dynamic> jsonSingleCard = json.decode(singleCard);
      expect(SingleCard.fromJson(jsonSingleCard) is SingleCard, true);
    });
    test("Deck.toJson() method", () {
      String singleCard = '{"name":"Knight","id":26000000,"maxLevel":13,"asset":"knight.png","cost":3,"rarity":1,"arena":0,"category":2,"dspro":"Knight","sim":true}';
      Map<String, dynamic> jsonSingleCard = json.decode(singleCard);
      expect(SingleCard.fromJson(jsonSingleCard).toJson().toString(), '{"name":"Knight","id":26000000,"maxLevel":13,"asset":"knight.png","cost":3,"rarity":1,"arena":0,"category":2,"dspro":"Knight","sim":true}');
    });
    test("getRarityString() method", () {
      SingleCard card1 = new SingleCard("testCard", 1, 1, "asset", 1, 1, 1, 1, "dspro",true);
      SingleCard card2 = new SingleCard("testCard", 1, 1, "asset", 1, 2, 1, 1, "dspro",true);
      SingleCard card3 = new SingleCard("testCard", 1, 1, "asset", 1, 3, 1, 1, "dspro",false);
      SingleCard card4 = new SingleCard("testCard", 1, 1, "asset", 1, 4, 1, 1, "dspro",false);
      expect(card1.getRarityString(), "Common");
      expect(card2.getRarityString(), "Rare");
      expect(card3.getRarityString(), "Epic");
      expect(card4.getRarityString(), "Legendary");
    });
    test("getCategoryString() method", () {
      SingleCard card1 = new SingleCard("testCard", 1, 1, "asset", 1, 1, 1, 1, "dspro",true);
      SingleCard card2 = new SingleCard("testCard", 1, 1, "asset", 1, 1, 2, 2, "dspro",true);
      SingleCard card3 = new SingleCard("testCard", 1, 1, "asset", 1, 1, 3, 3, "dspro",false);
      SingleCard card4 = new SingleCard("testCard", 1, 1, "asset", 1, 1, 4, 4, "dspro",false);
      SingleCard card5 = new SingleCard("testCard", 1, 1, "asset", 1, 1, 4, 5, "dspro",false);
      expect(card1.getCategoryString(), "Win conditions");
      expect(card2.getCategoryString(), "Troops");
      expect(card3.getCategoryString(), "Spells");
      expect(card4.getCategoryString(), "Buildings");
      expect(card5.getCategoryString(), "Spicy");
    });
    test("getCategoryString() method", () {
      SingleCard card1 = new SingleCard("testCard", 1, 1, "asset", 1, 1, 1, 1, "dspro",true);
      SingleCard card2 = new SingleCard("testCard", 1, 1, "asset", 0, 1, 2, 2, "dspro",true);
      expect(card1.getCostString, "1");
      expect(card2.getCostString, "?");
    });
    test("getLevelIndependence() method", () {
      expect(SingleCard.getLevelIndependence(26000030), 0);
      expect(SingleCard.getLevelIndependence(26000024), 1);
      expect(SingleCard.getLevelIndependence(26000002), 2);
      expect(SingleCard.getLevelIndependence(12345678), -1);
    });
  });

  //Account class, 2 tests
  group("class 'Account' test", () {
    test("Account constructor test", () {
      Account account = new Account(Account.link, 'ggg', 'kkk', 'pino@gino.it', true, 'tag1', DRSorts.byArenaCost);
      expect(account.loginType, Account.link);
      expect(account.userId, 'ggg');
      expect(account.userEmail, 'pino@gino.it');
      expect(account.deviceKey, 'kkk');
      expect(account.isTagLogged, true);
      expect(account.userTag, 'tag1');
      expect(account.sortType, DRSorts.byArenaCost);
    });
    test("Account.empty() constructor", () {
      Account account = new Account.neverLogged();
      expect(account.loginType, Account.none);
      expect(account.userId, '');
      expect(account.userEmail, '');
      expect(account.deviceKey, null);
      expect(account.isTagLogged, false);
      expect(account.userTag, '');
      expect(account.sortType, DRSorts.standard);
    });
  });

  //++++++++++++++++++++++++++++++++++++++++++++++

  //DeckStatistics class, 1 test
  group("class 'DeckStatistics' test", () {
    test("DeckStatistics constructor test", () {
      DeckStatistics deckStatistics = new DeckStatistics(1, 2, 3, 4, null, null, null);
      expect(deckStatistics is DeckStatistics, true);
      expect(deckStatistics.defense, 1);
      expect(deckStatistics.attack, 2);
      expect(deckStatistics.versatility, 3);
      expect(deckStatistics.synergy, 4);
      expect(deckStatistics.problems, null);
      expect(deckStatistics.warnings, null);
      expect(deckStatistics.infos, null);
    });
  });

  //Info class, 1 test
  group("class 'Info' test", () {
    test("Info constructor test", () {
      Info info = new Info("infoTest", "infoContentTest");
      expect(info is Info, true);
      expect(info.title, "infoTest");
      expect(info.content, "infoContentTest");
    });
  });

  //Warning class, 1 test
  group("class 'Warning' test", () {
    test("Warning constructor test", () {
      Warning warning = new Warning("WarningTest", "WarningContentTest");
      expect(warning is Warning, true);
      expect(warning.title, "WarningTest");
      expect(warning.content, "WarningContentTest");
    });
  });

  //Problem class, 1 test
  group("class 'Problem' test", () {
    test("Problem constructor test", () {
      Problem problem = new Problem("ProblemTest", "ProblemContentTest");
      expect(problem is Problem, true);
      expect(problem.title, "ProblemTest");
      expect(problem.content, "ProblemContentTest");
    });
  });

  //PlayerData class, 1 test
  group("class 'PlayerData' test", () {
    test("isNull() method", () {
      expect(PlayerData.empty().isNull(), true);
      expect(PlayerData(new Player.empty(), null, null).isNull(), false);
    });
  });
}