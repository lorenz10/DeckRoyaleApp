import 'dart:convert';
import 'package:deck_royale_app/build_deck_page.dart';
import 'package:deck_royale_app/model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {

  Widget buildTestableWidget(Widget widget) {
    return MediaQuery(data: MediaQueryData(), child: MaterialApp(home: widget));
  }

  //total Widget tests: 6

  //DeckCard Widget, 2 tests
  group("DeckCard Widget test", () {
    testWidgets('transparent card test', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(DeckCard(id: -1, isVisible: true, inDeck: false)));
      expect(find.byType(Image), findsOneWidget);
      expect(find.byType(Stack), findsNothing);
    });

    testWidgets('actual card test', (WidgetTester tester) async {
      String contents = '{"items": [{"name":"Ice Spirit","id":26000030,"maxLevel":13,"asset":"icespirit.png","cost":1,"rarity":1,"arena":8,"category":2,"dspro":"IceSpirit"}]}';
      Map cardsMap = jsonDecode(contents);
      App.gameCards = GameCards.fromJson(cardsMap);
      await tester.pumpWidget(buildTestableWidget(DeckCard(id: 26000030, isVisible: true, inDeck: false)));
      expect(find.byType(Image), findsWidgets);
      expect(find.byType(Stack), findsWidgets);
    });
  });

  //DeckListRow Widget, 1 test
  group("DeckListRow Widget test", () {
    testWidgets('build test', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(DeckListRow(cards: [DeckCard(id: -1, isVisible: true, inDeck: false)])));
      expect(find.byType(GridView), findsOneWidget);
      expect(find.byType(Container), findsWidgets);
    });
  });

  //DeckWidget, 1 test
  group("DeckWidget test", () {
    List cards = [
      DeckCard(id: -1, isVisible: true, inDeck: false),
      DeckCard(id: -1, isVisible: true, inDeck: false),
      DeckCard(id: -1, isVisible: true, inDeck: false),
      DeckCard(id: -1, isVisible: true, inDeck: false),
      DeckCard(id: -1, isVisible: true, inDeck: false),
      DeckCard(id: -1, isVisible: true, inDeck: false),
      DeckCard(id: -1, isVisible: true, inDeck: false),
      DeckCard(id: -1, isVisible: true, inDeck: false),
    ];
    testWidgets('build test', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(DeckWidget(cards: cards, width: 100,)));
      expect(find.byType(Row), findsNWidgets(2));
      expect(find.byType(Column), findsNWidgets(9));
    });
  });

  //DeckRow Widget, 1 test
  group("DeckRow Widget test", () {
    testWidgets('build test', (WidgetTester tester) async {
      List cards = [
        DeckCard(id: -1, isVisible: true, inDeck: false),
        DeckCard(id: -1, isVisible: true, inDeck: false),
        DeckCard(id: -1, isVisible: true, inDeck: false),
        DeckCard(id: -1, isVisible: true, inDeck: false),
        DeckCard(id: -1, isVisible: true, inDeck: false),
        DeckCard(id: -1, isVisible: true, inDeck: false),
        DeckCard(id: -1, isVisible: true, inDeck: false),
        DeckCard(id: -1, isVisible: true, inDeck: false),
      ];
      await tester.pumpWidget(buildTestableWidget(DeckRow(cards: cards)));
      expect(find.byType(Row), findsWidgets);
      expect(find.text("Build your new deck"), findsOneWidget);
    });
  });

  //BuildDeckWidget, 1 test
  group("BuildDeckWidget test", () {
    testWidgets('build test', (WidgetTester tester) async {
      String contents = '{"items": [{"name":"Ice Spirit","id":26000030,"maxLevel":13,"asset":"icespirit.png","cost":1,"rarity":1,"arena":8,"category":2,"dspro":"IceSpirit"}]}';
      Map cardsMap = jsonDecode(contents);
      App.gameCards = GameCards.fromJson(cardsMap);
      App.account.sortType = 0;
      await tester.pumpWidget(buildTestableWidget(BuildDeckWidget()));
      expect(find.byType(Row), findsWidgets);
      expect(find.byType(Column), findsWidgets);
      expect(find.text("Build your new deck"), findsOneWidget);
      expect(find.text("Evaluate deck"), findsNothing);
    });
  });
}