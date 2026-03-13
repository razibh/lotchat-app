enum FriendRequestStatus { pending, accepted, rejected, cancelled, blocked }

class FriendRequestModel {

  FriendRequestModel({
    required this.id,
    required this.senderId,
    required this.senderName,
    this.senderAvatar,
    required this.receiverId,
    required this.receiverName,
    this.receiverAvatar,
    required this.status,
    this.message,
    required this.sentAt,
    this.respondedAt,
    required this.mutualFriends,
    this.commonInterests = const [],
  });

  factory FriendRequestModel.fromJson(Map<String, dynamic> json) {
    return FriendRequestModel(
      id: json['id'],
      senderId: json['senderId'],
      senderName: json['senderName'],
      senderAvatar: json['senderAvatar'],
      receiverId: json['receiverId'],
      receiverName: json['receiverName'],
      receiverAvatar: json['receiverAvatar'],
      status: FriendRequestStatus.values[json['status']],
      message: json['message'],
      sentAt: DateTime.parse(json['sentAt']),
      respondedAt: json['respondedAt'] != null 
          ? DateTime.parse(json['respondedAt']) 
          : null,
      mutualFriends: json['mutualFriends'] ?? 0,
      commonInterests: List<String>.from(json['commonInterests'] ?? []),
    );
  }
  final String id;
  final String senderId;
  final String senderName;
  final String? senderAvatar;
  final String receiverId;
  final String receiverName;
  final String? receiverAvatar;
  final FriendRequestStatus status;
  final String? message;
  final DateTime sentAt;
  final DateTime? respondedAt;
  final int mutualFriends;
  final List<String> commonInterests;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'senderId': senderId,
    'senderName': senderName,
    'senderAvatar': senderAvatar,
    'receiverId': receiverId,
    'receiverName': receiverName,
    'receiverAvatar': receiverAvatar,
    'status': status.index,
    'message': message,
    'sentAt': sentAt.toIso8601String(),
    'respondedAt': respondedAt?.toIso8601String(),
    'mutualFriends': mutualFriends,
    'commonInterests': commonInterests,
  };

  bool get isPending => status == FriendRequestStatus.pending;
  bool get isAccepted => status == FriendRequestStatus.accepted;
  bool get isRejected => status == FriendRequestStatus.rejected;
  bool get isCancelled => status == FriendRequestStatus.cancelled;
}

class FriendSuggestion { // recommendation score

  FriendSuggestion({
    required this.userId,
    required this.name,
    this.avatar,
    required this.mutualFriends,
    required this.commonInterests,
    required this.score,
  });

  factory FriendSuggestion.fromJson(Map<String, dynamic> json) {
    return FriendSuggestion(
      userId: json['userId'],
      name: json['name'],
      avatar: json['avatar'],
      mutualFriends: json['mutualFriends'],
      commonInterests: List<String>.from(json['commonInterests'] ?? []),
      score: json['score'],
    );
  }
  final String userId;
  final String name;
  final String? avatar;
  final int mutualFriends;
  final List<String> commonInterests;
  final double score;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'userId': userId,
    'name': name,
    'avatar': avatar,
    'mutualFriends': mutualFriends,
    'commonInterests': commonInterests,
    'score': score,
  };
}

class FriendStats {

  FriendStats({
    required this.totalFriends,
    required this.onlineFriends,
    required this.pendingRequests,
    required this.sentRequests,
    required this.blockedUsers,
    required this.mutualFriends,
    required this.friendsThisWeek,
    required this.friendsThisMonth,
  });

  factory FriendStats.fromJson(Map<String, dynamic> json) {
    return FriendStats(
      totalFriends: json['totalFriends'],
      onlineFriends: json['onlineFriends'],
      pendingRequests: json['pendingRequests'],
      sentRequests: json['sentRequests'],
      blockedUsers: json['blockedUsers'],
      mutualFriends: json['mutualFriends'],
      friendsThisWeek: json['friendsThisWeek'],
      friendsThisMonth: json['friendsThisMonth'],
    );
  }
  final int totalFriends;
  final int onlineFriends;
  final int pendingRequests;
  final int sentRequests;
  final int blockedUsers;
  final int mutualFriends;
  final int friendsThisWeek;
  final int friendsThisMonth;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'totalFriends': totalFriends,
    'onlineFriends': onlineFriends,
    'pendingRequests': pendingRequests,
    'sentRequests': sentRequests,
    'blockedUsers': blockedUsers,
    'mutualFriends': mutualFriends,
    'friendsThisWeek': friendsThisWeek,
    'friendsThisMonth': friendsThisMonth,
  };
}