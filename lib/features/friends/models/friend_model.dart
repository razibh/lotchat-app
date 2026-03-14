enum FriendStatus { friends, pending, sent, blocked, none }
enum OnlineStatus { online, offline, away, busy }

class FriendModel {

  FriendModel({
    required this.userId,
    required this.username,
    required this.onlineStatus, required this.friendsSince, required this.mutualFriends, this.displayName,
    this.avatar,
    this.bio,
    this.lastActive,
    this.commonInterests = const <String>[],
    this.stats = const <String, dynamic>{},
    this.isFavorite = false,
    this.note,
    this.tags = const <String>[],
  });

  factory FriendModel.fromJson(Map<String, dynamic> json) {
    return FriendModel(
      userId: json['userId'],
      username: json['username'],
      displayName: json['displayName'],
      avatar: json['avatar'],
      bio: json['bio'],
      onlineStatus: OnlineStatus.values[json['onlineStatus'] ?? 0],
      lastActive: json['lastActive'] != null
          ? DateTime.parse(json['lastActive'])
          : null,
      friendsSince: DateTime.parse(json['friendsSince']),
      mutualFriends: json['mutualFriends'] ?? 0,
      commonInterests: List<String>.from(json['commonInterests'] ?? <dynamic>[]),
      stats: json['stats'] ?? <String, dynamic>{},
      isFavorite: json['isFavorite'] ?? false,
      note: json['note'],
      tags: List<String>.from(json['tags'] ?? <dynamic>[]),
    );
  }
  final String userId;
  final String username;
  final String? displayName;
  final String? avatar;
  final String? bio;
  final OnlineStatus onlineStatus;
  final DateTime? lastActive;
  final DateTime friendsSince;
  final int mutualFriends;
  final List<String> commonInterests;
  final Map<String, dynamic> stats;
  final bool isFavorite;
  final String? note;
  final List<String> tags;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'userId': userId,
    'username': username,
    'displayName': displayName,
    'avatar': avatar,
    'bio': bio,
    'onlineStatus': onlineStatus.index,
    'lastActive': lastActive?.toIso8601String(),
    'friendsSince': friendsSince.toIso8601String(),
    'mutualFriends': mutualFriends,
    'commonInterests': commonInterests,
    'stats': stats,
    'isFavorite': isFavorite,
    'note': note,
    'tags': tags,
  };

  bool get isOnline => onlineStatus == OnlineStatus.online;
  String get displayNameOrUsername => displayName ?? username;
}

class FriendRequestModel {

  FriendRequestModel({
    required this.requestId,
    required this.userId,
    required this.username,
    required this.timestamp, required this.mutualFriends, this.avatar,
    this.message,
    this.commonInterests = const <String>[],
  });

  factory FriendRequestModel.fromJson(Map<String, dynamic> json) {
    return FriendRequestModel(
      requestId: json['requestId'],
      userId: json['userId'],
      username: json['username'],
      avatar: json['avatar'],
      timestamp: DateTime.parse(json['timestamp']),
      message: json['message'],
      mutualFriends: json['mutualFriends'] ?? 0,
      commonInterests: List<String>.from(json['commonInterests'] ?? <dynamic>[]),
    );
  }
  final String requestId;
  final String userId;
  final String username;
  final String? avatar;
  final DateTime timestamp;
  final String? message;
  final int mutualFriends;
  final List<String> commonInterests;
}

class FriendSuggestionModel {

  FriendSuggestionModel({
    required this.userId,
    required this.username,
    required this.mutualFriends, required this.score, this.displayName,
    this.avatar,
    this.commonInterests = const <String>[],
    this.reason,
  });
  final String userId;
  final String username;
  final String? displayName;
  final String? avatar;
  final int mutualFriends;
  final List<String> commonInterests;
  final String? reason;
  final double score;

  String get displayNameOrUsername => displayName ?? username;
}