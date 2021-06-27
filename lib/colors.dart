import 'package:flutter/material.dart';

class DRColors{
  DRColors._();
  static const Color black = Color(0xFF111111);
  static const Color black2 = Color(0xFF222222);
  static const Color black3 = Color(0xFF333333);
  static const Color blue = Color(0xFF2B50AA);
  static const Color lightBlue = Color(0xFF6C8BDA);
  static const Color violet = Color(0xFF635380);
  static const Color elixir = Color(0xFFFE58E8);
  static const Color green = Color(0xFF4F9D69);
  static const Color lightGreen = Color(0xFF9BE824);
  static const Color yellowGreen = Color(0xFFD4E824);
  static const Color yellow = Color(0xFFFFEB3B);
  static const Color orange = Color(0xFFF5921E);
  static const Color redOrange = Color(0xFFFF7140);
  static const Color red = Color(0xFFFF5252);
  static const Color brown = Color(0xFF786452);
  static const Color darkGrey = Color(0xFF666666);
  static const Color grey = Color(0xFFAAAAAA);
  static const Color grey2 = Color(0xFFBBBBBB);
  static const Color white2 = Color(0xFFDDDDDD);
  static const Color white = Color(0xFFEEEEEE);

  static const LinearGradient whiteGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0x0DDDDDDD), Color(0x0DDDDDDD)],
    tileMode: TileMode.repeated,
  );

  static const LinearGradient blackGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xA9222222), Color(0xF1222222)],
    tileMode: TileMode.repeated,
  );

  static const DecorationImage background = DecorationImage(
      image: AssetImage('resources/images/deckBuildBackground.png'),
      fit: BoxFit.cover,
      colorFilter: ColorFilter.mode(Color(0xCC060606), BlendMode.srcOver)
  );
  static const BoxDecoration tile = BoxDecoration(
    //color: DRColors.black2,
    borderRadius: BorderRadius.all(Radius.circular(16)),
    gradient: DRColors.blackGradient,
  );
  static const Color value = Color(0x8F111111);

  static Color getScoreColor(int scoreValue){
    switch(scoreValue){
      case 0: {
        return DRColors.red;
      }
      case 1: {
        return DRColors.redOrange;
      }
      case 2: {
        return DRColors.orange;
      }
      case 3: {
        return DRColors.yellow;
      }
      case 4: {
        return DRColors.lightGreen;
      }
      case 5: {
        return DRColors.green;
      }
    }
    return null;
  }

  static const InputBorder formBorders = OutlineInputBorder(
    borderRadius: const BorderRadius.all(Radius.circular(36)),
    borderSide: const BorderSide(
      width: 0,
      color: Colors.transparent,
    ),
  );
}

class DRTabs{
  DRTabs._();
  static const int build = 0;
  static const int search = 1;
  static const int home = 2;
  static const int simulator = 3;
  static const int settings = 4;
}

class DRSorts{
  DRSorts._();
  static const int standard = 0;
  static const int byCost = 1;
  static const int byArenaCost = 2;
  static const int byRarityCost = 3;
  static const int byRarityCostInverse = 4;
  static const int MAX = 4;

  static const List<String> sortMessages = [
    "Standard",
    "Sort by cost",
    "Sort by Arena",
    "Sort by lowest Rarity",
    "Sort by highest Rarity"
  ];
}

class BigTextWidget extends StatelessWidget {
  final String text;
  BigTextWidget(this.text);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30,horizontal: 20),
      child: Text(
        text,
        style: TextStyle(
          color: DRColors.grey,
          fontSize: MediaQuery.of(context).orientation == Orientation.portrait ? 18 : 22,
          fontFamily: 'Supercell',
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}