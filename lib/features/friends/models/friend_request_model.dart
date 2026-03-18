import 'package:flutter/material.dart'; // Color এর জন্য এই import যোগ করুন

enum FriendRequestStatus { pending, accepted, rejected, cancelled, blocked }

class FriendRequestModel {
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
      id: json['id'] ?? '',
      senderId: json['senderId'] ?? '',
      senderName: json['senderName'] ?? '',
      senderAvatar: json['senderAvatar'],
      receiverId: json['receiverId'] ?? '',
      receiverName: json['receiverName'] ?? '',
      receiverAvatar: json['receiverAvatar'],
      status: FriendRequestStatus.values[json['status'] ?? 0],
      message: json['message'],
      sentAt: json['sentAt'] != null
          ? DateTime.parse(json['sentAt'])
          : DateTime.now(),
      respondedAt: json['respondedAt'] != null
          ? DateTime.parse(json['respondedAt'])
          : null,
      mutualFriends: json['mutualFriends'] ?? 0,
      commonInterests: List<String>.from(json['commonInterests'] ?? []),
    );
  }

  Map<String, dynamic> toJson() => {
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
  final int totalReceived;
  final int totalSent;
  final int pendingReceived;
  final int pendingSent;
  final int accepted;
  final int rejected;

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
      totalReceived: json['totalReceived'] ?? 0,
      totalSent: json['totalSent'] ?? 0,
      pendingReceived: json['pendingReceived'] ?? 0,
      pendingSent: json['pendingSent'] ?? 0,
      accepted: json['accepted'] ?? 0,
      rejected: json['rejected'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'totalReceived': totalReceived,
    'totalSent': totalSent,
    'pendingReceived': pendingReceived,
    'pendingSent': pendingSent,
    'accepted': accepted,
    'rejected': rejected,
  };
}