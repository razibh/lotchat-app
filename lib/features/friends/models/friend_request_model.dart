enum FriendRequestStatus { pending, accepted, rejected, cancelled, blocked }

class FriendRequestModel {

  FriendRequestModel({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.receiverId, required this.receiverName, required this.status, required this.sentAt, required this.mutualFriends, this.senderAvatar,
    this.receiverAvatar,
    this.message,
    this.respondedAt,
    this.commonInterests = const <String>[],
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
      commonInterests: List<String>.from(json['commonInterests'] ?? <dynamic>[]),
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
  bool get isBlocked => status == FriendRequestStatus.blocked;

  String get statusText {
    switch (status) {
      case FriendRequestStatus.pending:
        return 'Pending';
      case FriendRequestStatus.accepted:
        return 'Accepted';
      case FriendRequestStatus.rejected:
        return 'Rejected';
      case FriendRequestStatus.cancelled:
        return 'Cancelled';
      case FriendRequestStatus.blocked:
        return 'Blocked';
    }
  }

  Color get statusColor {
    switch (status) {
      case FriendRequestStatus.pending:
        return Colors.orange;
      case FriendRequestStatus.accepted:
        return Colors.green;
      case FriendRequestStatus.rejected:
        return Colors.red;
      case FriendRequestStatus.cancelled:
        return Colors.grey;
      case FriendRequestStatus.blocked:
        return Colors.red;
    }
  }
}

class FriendRequestStats {

  FriendRequestStats({
    required this.totalReceived,
    required this.totalSent,
    required this.pendingReceived,
    required this.pendingSent,
    required this.accepted,
    required this.rejected,
  });

  factory FriendRequestStats.fromJson(Map<String, dynamic> json) {
    return FriendRequestStats(
      totalReceived: json['totalReceived'],
      totalSent: json['totalSent'],
      pendingReceived: json['pendingReceived'],
      pendingSent: json['pendingSent'],
      accepted: json['accepted'],
      rejected: json['rejected'],
    );
  }
  final int totalReceived;
  final int totalSent;
  final int pendingReceived;
  final int pendingSent;
  final int accepted;
  final int rejected;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'totalReceived': totalReceived,
    'totalSent': totalSent,
    'pendingReceived': pendingReceived,
    'pendingSent': pendingSent,
    'accepted': accepted,
    'rejected': rejected,
  };
}