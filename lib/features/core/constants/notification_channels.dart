import 'package:flutter/material.dart';

// Importance enum টি define করা হলো (যেহেতু Flutter-এ built-in Importance নেই)
enum Importance {
  low,
  defaultImportance,
  high,
  max,
}

class NotificationChannels {
  // Channel IDs
  static const String channelGeneral = 'general_notifications';
  static const String channelMessages = 'message_notifications';
  static const String channelGifts = 'gift_notifications';
  static const String channelCalls = 'call_notifications';
  static const String channelGames = 'game_notifications';
  static const String channelFriends = 'friend_notifications';
  static const String channelClan = 'clan_notifications';
  static const String channelPk = 'pk_notifications';
  static const String channelPromotions = 'promotion_notifications';
  static const String channelSystem = 'system_notifications';

  // Channel Names
  static const String nameGeneral = 'General Notifications';
  static const String nameMessages = 'Messages';
  static const String nameGifts = 'Gifts';
  static const String nameCalls = 'Calls';
  static const String nameGames = 'Games';
  static const String nameFriends = 'Friends';
  static const String nameClan = 'Clan';
  static const String namePk = 'PK Battles';
  static const String namePromotions = 'Promotions';
  static const String nameSystem = 'System';

  // Channel Descriptions
  static const String descGeneral = 'General app notifications';
  static const String descMessages = 'New message notifications';
  static const String descGifts = 'Gift received notifications';
  static const String descCalls = 'Incoming call notifications';
  static const String descGames = 'Game invitations and updates';
  static const String descFriends = 'Friend request notifications';
  static const String descClan = 'Clan activity notifications';
  static const String descPk = 'PK battle notifications';
  static const String descPromotions = 'Promotional offers';
  static const String descSystem = 'System announcements';

  // Channel Importance
  static const Importance importanceGeneral = Importance.high;
  static const Importance importanceMessages = Importance.high;
  static const Importance importanceGifts = Importance.defaultImportance;
  static const Importance importanceCalls = Importance.max;
  static const Importance importanceGames = Importance.defaultImportance;
  static const Importance importanceFriends = Importance.defaultImportance;
  static const Importance importanceClan = Importance.defaultImportance;
  static const Importance importancePk = Importance.high;
  static const Importance importancePromotions = Importance.low;
  static const Importance importanceSystem = Importance.high;

  // Channel Sounds
  static const String soundGeneral = 'notification.mp3';
  static const String soundMessages = 'message.mp3';
  static const String soundGifts = 'gift_sent.mp3';
  static const String soundCalls = 'call_ringtone.mp3';
  static const String soundGames = 'game_start.mp3';
  static const String soundFriends = 'notification.mp3';
  static const String soundClan = 'notification.mp3';
  static const String soundPk = 'pk_start.mp3';
  static const String soundPromotions = 'notification.mp3';
  static const String soundSystem = 'notification.mp3';

  // Channel Icons
  static const String iconGeneral = 'ic_notification';
  static const String iconMessages = 'ic_message';
  static const String iconGifts = 'ic_gift';
  static const String iconCalls = 'ic_call';
  static const String iconGames = 'ic_game';
  static const String iconFriends = 'ic_friend';
  static const String iconClan = 'ic_clan';
  static const String iconPk = 'ic_pk';
  static const String iconPromotions = 'ic_promotion';
  static const String iconSystem = 'ic_system';

  // Get channel config
  static Map<String, dynamic> getChannelConfig(String channelId) {
    switch (channelId) {
      case channelGeneral:
        return {
          'id': channelGeneral,
          'name': nameGeneral,
          'description': descGeneral,
          'importance': importanceGeneral,
          'sound': soundGeneral,
          'icon': iconGeneral,
        };
      case channelMessages:
        return {
          'id': channelMessages,
          'name': nameMessages,
          'description': descMessages,
          'importance': importanceMessages,
          'sound': soundMessages,
          'icon': iconMessages,
        };
      case channelGifts:
        return {
          'id': channelGifts,
          'name': nameGifts,
          'description': descGifts,
          'importance': importanceGifts,
          'sound': soundGifts,
          'icon': iconGifts,
        };
      case channelCalls:
        return {
          'id': channelCalls,
          'name': nameCalls,
          'description': descCalls,
          'importance': importanceCalls,
          'sound': soundCalls,
          'icon': iconCalls,
        };
      case channelGames:
        return {
          'id': channelGames,
          'name': nameGames,
          'description': descGames,
          'importance': importanceGames,
          'sound': soundGames,
          'icon': iconGames,
        };
      case channelFriends:
        return {
          'id': channelFriends,
          'name': nameFriends,
          'description': descFriends,
          'importance': importanceFriends,
          'sound': soundFriends,
          'icon': iconFriends,
        };
      case channelClan:
        return {
          'id': channelClan,
          'name': nameClan,
          'description': descClan,
          'importance': importanceClan,
          'sound': soundClan,
          'icon': iconClan,
        };
      case channelPk:
        return {
          'id': channelPk,
          'name': namePk,
          'description': descPk,
          'importance': importancePk,
          'sound': soundPk,
          'icon': iconPk,
        };
      case channelPromotions:
        return {
          'id': channelPromotions,
          'name': namePromotions,
          'description': descPromotions,
          'importance': importancePromotions,
          'sound': soundPromotions,
          'icon': iconPromotions,
        };
      case channelSystem:
        return {
          'id': channelSystem,
          'name': nameSystem,
          'description': descSystem,
          'importance': importanceSystem,
          'sound': soundSystem,
          'icon': iconSystem,
        };
      default:
        return {
          'id': channelGeneral,
          'name': nameGeneral,
          'description': descGeneral,
          'importance': importanceGeneral,
          'sound': soundGeneral,
          'icon': iconGeneral,
        };
    }
  }

  // Get all channels
  static List<Map<String, dynamic>> getAllChannels() {
    return [
      getChannelConfig(channelGeneral),
      getChannelConfig(channelMessages),
      getChannelConfig(channelGifts),
      getChannelConfig(channelCalls),
      getChannelConfig(channelGames),
      getChannelConfig(channelFriends),
      getChannelConfig(channelClan),
      getChannelConfig(channelPk),
      getChannelConfig(channelPromotions),
      getChannelConfig(channelSystem),
    ];
  }
}