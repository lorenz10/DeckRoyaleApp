import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

//total integration tests: 4
///NOTE: in order to be runnable, this integration test
///needs the cards.json load to be commented, otherwise it gets stuck
///and does not run.

void main() {
  group('DeckRoyale App', () {
    final createFolderTextFinder = find.byValueKey('create folder text');
    final addFolderButtonFinder = find.byValueKey('add folder button');
    final textFormFieldFinder = find.byValueKey('text form field');
    final confirmButtonFinder = find.byValueKey('confirm button');
    final confirmButtonTextFinder = find.byValueKey('confirm button text');
    final folderTestFinder = find.text("folder test");

    FlutterDriver driver;

    setUpAll(() async {
      driver = await FlutterDriver.connect();
      await driver.waitUntilFirstFrameRasterized();
    });

    tearDownAll(() async {
      if (driver != null) {
        driver.close();
      }
    });

    group("Add folder to root page", () {
      test('starts in home page', () async {
        expect(await driver.getText(createFolderTextFinder), "Create Folder");
      });

      test('tap create folder button', () async {
        await driver.tap(addFolderButtonFinder);
        expect(await driver.getText(confirmButtonTextFinder), "Add");
      });

      test('create folder', () async {
        await driver.tap(textFormFieldFinder);
        await driver.enterText("folder test");
        await driver.tap(confirmButtonFinder);
        expect(await driver.getText(createFolderTextFinder), "Create Folder");
      });

      test('open folder', () async {
        await driver.tap(folderTestFinder);
        expect(await driver.getText(folderTestFinder), "folder test");
      });
    });
  });
}