// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Root _$RootFromJson(Map<String, dynamic> json) {
  return Root(
    (json['folders'] as List)
        ?.map((e) =>
            e == null ? null : Folder.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$RootToJson(Root instance) => <String, dynamic>{
      'folders': instance.folders?.map((e) => e?.toJson())?.toList(),
    };

Folder _$FolderFromJson(Map<String, dynamic> json) {
  return Folder(
    json['name'] as String,
    json['image'] as int,
    (json['decks'] as List)
        ?.map(
            (e) => e == null ? null : Deck.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$FolderToJson(Folder instance) => <String, dynamic>{
      'name': instance.name,
      'image': instance.image,
      'decks': instance.decks?.map((e) => e?.toJson())?.toList(),
    };

Deck _$DeckFromJson(Map<String, dynamic> json) {
  return Deck(
    (json['cards'] as List)?.map((e) => e as int)?.toList(),
    (json['avgElixir'] as num)?.toDouble(),
  );
}

Map<String, dynamic> _$DeckToJson(Deck instance) => <String, dynamic>{
      'cards': instance.cards,
      'avgElixir': instance.avgElixir,
    };

GameCards _$GameCardsFromJson(Map<String, dynamic> json) {
  return GameCards(
    (json['items'] as List)
        ?.map((e) =>
            e == null ? null : SingleCard.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

SingleCard _$SingleCardFromJson(Map<String, dynamic> json) {
  return SingleCard(
    json['name'] as String,
    json['id'] as int,
    json['maxLevel'] as int,
    json['asset'] as String,
    json['cost'] as int,
    json['rarity'] as int,
    json['arena'] as int,
    json['category'] as int,
    json['dspro'] as String,
    json['sim'] as bool,
  );
}

Map<String, dynamic> _$SingleCardToJson(SingleCard instance) =>
    <String, dynamic>{
      'name': instance.name,
      'id': instance.id,
      'maxLevel': instance.maxLevel,
      'asset': instance.asset,
      'cost': instance.cost,
      'rarity': instance.rarity,
      'arena': instance.arena,
      'category': instance.category,
      'dspro': instance.dspro,
      'sim': instance.sim,
    };

Account _$AccountFromJson(Map<String, dynamic> json) {
  return Account(
    json['loginType'] as int,
    json['userId'] as String,
    json['deviceKey'] as String,
    json['userEmail'] as String,
    json['isTagLogged'] as bool,
    json['userTag'] as String,
    json['sortType'] as int,
  );
}

Map<String, dynamic> _$AccountToJson(Account instance) => <String, dynamic>{
      'loginType': instance.loginType,
      'userId': instance.userId,
      'deviceKey':instance.deviceKey,
      'userEmail': instance.userEmail,
      'isTagLogged': instance.isTagLogged,
      'userTag': instance.userTag,
      'sortType': instance.sortType,
    };

PlayerData _$PlayerDataFromJson(Map<String, dynamic> json) {
  return PlayerData(
    json['player'] == null
        ? null
        : Player.fromJson(json['player'] as Map<String, dynamic>),
    (json['items'] as List)
        ?.map(
            (e) => e == null ? null : Chest.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    (json['log'] as List)
        ?.map((e) =>
            e == null ? null : BattleSmall.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$PlayerDataToJson(PlayerData instance) =>
    <String, dynamic>{
      'player': instance.player?.toJson(),
      'items': instance.items?.map((e) => e?.toJson())?.toList(),
      'log': instance.log?.map((e) => e?.toJson())?.toList(),
    };

Player _$PlayerFromJson(Map<String, dynamic> json) {
  return Player(
    json['playerName'] as String,
    json['playerExperienceLevel'] as int,
    json['currentTrophies'] as int,
    json['bestTrophies'] as int,
    json['playerWins'] as int,
    json['playerLosses'] as int,
    json['battleCount'] as int,
    json['donations'] as int,
    json['threeCrownWins'] as int,
    json['maxChallengeWins'] as int,
    json['currentArena'] == null
        ? null
        : Arena.fromJson(json['currentArena'] as Map<String, dynamic>),
    json['playerClan'] == null
        ? null
        : ClanSmall.fromJson(json['playerClan'] as Map<String, dynamic>),
    json['favCard'] == null
        ? null
        : FavCard.fromJson(json['favCard'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$PlayerToJson(Player instance) => <String, dynamic>{
      'playerName': instance.playerName,
      'playerExperienceLevel': instance.playerExperienceLevel,
      'currentTrophies': instance.currentTrophies,
      'bestTrophies': instance.bestTrophies,
      'playerWins': instance.playerWins,
      'playerLosses': instance.playerLosses,
      'battleCount': instance.battleCount,
      'donations': instance.donations,
      'threeCrownWins': instance.threeCrownWins,
      'maxChallengeWins': instance.maxChallengeWins,
      'currentArena': instance.currentArena?.toJson(),
      'playerClan': instance.playerClan?.toJson(),
      'favCard': instance.favCard?.toJson(),
    };

Chest _$ChestFromJson(Map<String, dynamic> json) {
  return Chest(
    json['index'] as int,
    json['name'] as String,
  );
}

Map<String, dynamic> _$ChestToJson(Chest instance) => <String, dynamic>{
      'index': instance.index,
      'name': instance.name,
    };

BattleSmall _$BattleSmallFromJson(Map<String, dynamic> json) {
  return BattleSmall(
    json['battleType'] as String,
    json['finalTrophies'] as int,
    json['gainedCrowns'] as int,
    json['isVictory'] as bool,
  );
}

Map<String, dynamic> _$BattleSmallToJson(BattleSmall instance) =>
    <String, dynamic>{
      'battleType': instance.battleType,
      'finalTrophies': instance.finalTrophies,
      'gainedCrowns': instance.gainedCrowns,
      'isVictory': instance.isVictory,
    };

BattlePlayer _$BattlePlayerFromJson(Map<String, dynamic> json) {
  return BattlePlayer(
    json['finalTrophies'] as int,
    json['crowns'] as int,
    json['isVictory'] as bool,
  );
}

Map<String, dynamic> _$BattlePlayerToJson(BattlePlayer instance) =>
    <String, dynamic>{
      'finalTrophies': instance.finalTrophies,
      'crowns': instance.crowns,
      'isVictory': instance.isVictory,
    };

Arena _$ArenaFromJson(Map<String, dynamic> json) {
  return Arena(
    json['name'] as String,
  );
}

Map<String, dynamic> _$ArenaToJson(Arena instance) => <String, dynamic>{
      'name': instance.name,
    };

ClanSmall _$ClanSmallFromJson(Map<String, dynamic> json) {
  return ClanSmall(
    json['tag'] as String,
    json['name'] as String,
  );
}

Map<String, dynamic> _$ClanSmallToJson(ClanSmall instance) => <String, dynamic>{
      'tag': instance.tag,
      'name': instance.name,
    };

Clan _$ClanFromJson(Map<String, dynamic> json) {
  return Clan(
    json['name'] as String,
    json['location'] == null
        ? null
        : Location.fromJson(json['location'] as Map<String, dynamic>),
    json['members'] as int,
    json['clanScore'] as int,
    json['requiredTrophies'] as int,
    json['donationsPerWeek'] as int,
    json['clanWarTrophies'] as int,
    (json['memberList'] as List)
        ?.map((e) =>
            e == null ? null : ClanMember.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$ClanToJson(Clan instance) => <String, dynamic>{
      'name': instance.name,
      'location': instance.location?.toJson(),
      'members': instance.members,
      'clanScore': instance.clanScore,
      'requiredTrophies': instance.requiredTrophies,
      'donationsPerWeek': instance.donationsPerWeek,
      'clanWarTrophies': instance.clanWarTrophies,
      'memberList': instance.memberList?.map((e) => e?.toJson())?.toList(),
    };

ClanMember _$ClanMemberFromJson(Map<String, dynamic> json) {
  return ClanMember(
    json['name'] as String,
    json['tag'] as String,
    json['role'] as String,
    json['trophies'] as int,
  );
}

Map<String, dynamic> _$ClanMemberToJson(ClanMember instance) =>
    <String, dynamic>{
      'name': instance.name,
      'tag': instance.tag,
      'role': instance.role,
      'trophies': instance.trophies,
    };

Location _$LocationFromJson(Map<String, dynamic> json) {
  return Location(
    json['name'] as String,
  );
}

Map<String, dynamic> _$LocationToJson(Location instance) => <String, dynamic>{
      'name': instance.name,
    };

FavCard _$FavCardFromJson(Map<String, dynamic> json) {
  return FavCard(
    json['name'] as String,
  );
}

Map<String, dynamic> _$FavCardToJson(FavCard instance) => <String, dynamic>{
      'name': instance.name,
    };
