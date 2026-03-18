enum FriendStatus { friends, pending, sent, blocked, none }
enum OnlineStatus { online, offline, away, busy }

class FriendModel {
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

  FriendModel({
    required this.userId,
    required this.username,
    required this.onlineStatus,
    required this.friendsSince,
    required this.mutualFriends,
    this.displayName,
    this.avatar,
    this.bio,
    this.lastActive,
    this.commonInterests = const [],
    this.stats = const {},
    this.isFavorite = false,
    this.note,
    this.tags = const [],
  });

  factory FriendModel.fromJson(Map<String, dynamic> json) {
    return FriendModel(
      userId: json['userId'] ?? '',
      username: json['username'] ?? '',
      displayName: json['displayName'],
      avatar: json['avatar'],
      bio: json['bio'],
      onlineStatus: OnlineStatus.values[json['onlineStatus'] ?? 0],
      lastActive: json['lastActive'] != null
          ? DateTime.parse(json['lastActive'])
          : null,
      friendsSince: json['friendsSince'] != null
          ? DateTime.parse(json['friendsSince'])
          : DateTime.now(),
      mutualFriends: json['mutualFriends'] ?? 0,
      commonInterests: List<String>.from(json['commonInterests'] ?? []),
      stats: json['stats'] ?? {},
      isFavorite: json['isFavorite'] ?? false,
      note: json['note'],
      tags: List<String>.from(json['tags'] ?? []),
    );
  }

  Map<String, dynamic> toJson() => {
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
  final String requestId;
  final String userId;
  final String username;
  final String? avatar;
  final DateTime timestamp;
  final String? message;
  final int mutualFriends;
  final List<String> commonInterests;

  FriendRequestModel({
    required this.requestId,
    required this.userId,
    required this.username,
    required this.timestamp,
    required this.mutualFriends,
    this.avatar,
    this.message,
    this.commonInterests = const [],
  });

  factory FriendRequestModel.fromJson(Map<String, dynamic> json) {
    return FriendRequestModel(
      requestId: json['requestId'] ?? '',
      userId: json['userId'] ?? '',
      username: json['username'] ?? '',
      avatar: json['avatar'],
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
      message: json['message'],
      mutualFriends: json['mutualFriends'] ?? 0,
      commonInterests: List<String>.from(json['commonInterests'] ?? []),
    );
  }

  Map<String, dynamic> toJson() => {
    'requestId': requestId,
    'userId': userId,
    'username': username,
    'avatar': avatar,
    'timestamp': timestamp.toIso8601String(),
    'message': message,
    'mutualFriends': mutualFriends,
    'commonInterests': commonInterests,
  };
}

class FriendSuggestionModel {
  final String userId;
  final String username;
  final String? displayName;
  final String? avatar;
  final int mutualFriends;
  final List<String> commonInterests;
  final String? reason;
  final double score;

  FriendSuggestionModel({
    required this.userId,
    required this.username,
    required this.mutualFriends,
    required this.score,
    this.displayName,
    this.avatar,
    this.commonInterests = const [],
    this.reason,
  });

  factory FriendSuggestionModel.fromJson(Map<String, dynamic> json) {
    return FriendSuggestionModel(
      userId: json['userId'] ?? '',
      username: json['username'] ?? '',
      displayName: json['displayName'],
      avatar: json['avatar'],
      mutualFriends: json['mutualFriends'] ?? 0,
      score: (json['score'] ?? 0).toDouble(),
      commonInterests: List<String>.from(json['commonInterests'] ?? []),
      reason: json['reason'],
    );
  }

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'username': username,
    'displayName': displayName,
    'avatar': avatar,
    'mutualFriends': mutualFriends,
    'score': score,
    'commonInterests': commonInterests,
    'reason': reason,
  };

  String get displayNameOrUsername => displayName ?? username;
}