enum FriendStatus { friends, pending, sent, blocked, none }
enum OnlineStatus { online, offline, away, busy }

class FriendModel {

  FriendModel({
    required this.userId,
    required this.username,
    this.displayName,
    this.avatar,
    this.bio,
    required this.onlineStatus,
    this.lastActive,
    required this.friendsSince,
    required this.mutualFriends,
    this.commonInterests = const [],
    this.stats = const {},
    this.isFavorite = false,
    this.note,
    this.tags = const [],
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
      commonInterests: List<String>.from(json['commonInterests'] ?? []),
      stats: json['stats'] ?? {},
      isFavorite: json['isFavorite'] ?? false,
      note: json['note'],
      tags: List<String>.from(json['tags'] ?? []),
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
    this.avatar,
    required this.timestamp,
    this.message,
    required this.mutualFriends,
    this.commonInterests = const [],
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
      commonInterests: List<String>.from(json['commonInterests'] ?? []),
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
    this.displayName,
    this.avatar,
    required this.mutualFriends,
    this.commonInterests = const [],
    this.reason,
    required this.score,
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