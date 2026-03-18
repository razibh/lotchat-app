// lib/chat/models/message_model.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart'; // Color এর জন্য (optional)

enum MessageType {
  text,
  gift,
  system,
  image,
  video,
  audio,
  file,
  location,
  contact,
  sticker,
  call,
}

enum MessageStatus {
  sending,
  sent,
  delivered,
  read,
  failed,
}

class MessageModel {
  final String id;
  final String roomId;
  final String senderId;
  final String senderName;
  final String? senderAvatar;
  final MessageType type;
  final String content;
  final String? giftId;
  final int? giftAmount;
  final String? giftName; // 🟢 giftName যোগ করা হয়েছে
  final DateTime timestamp;
  final List<String> mentions;

  // Additional fields
  final MessageStatus status;
  final String? mediaUrl;
  final String? thumbnailUrl;
  final String? fileName;
  final int? fileSize;
  final double? duration;
  final bool isEdited;
  final bool isDeleted;
  final DateTime? editedAt;
  final DateTime? deletedAt;
  final String? replyToId;
  final MessageModel? replyTo;
  final List<String> readBy;
  final List<MessageReaction> reactions;
  final Map<String, dynamic>? metadata;

  MessageModel({
    required this.id,
    required this.roomId,
    required this.senderId,
    required this.senderName,
    this.senderAvatar,
    required this.type,
    required this.content,
    this.giftId,
    this.giftAmount,
    this.giftName, // 🟢 giftName যোগ করা হয়েছে
    required this.timestamp,
    this.mentions = const [],
    this.status = MessageStatus.sent,
    this.mediaUrl,
    this.thumbnailUrl,
    this.fileName,
    this.fileSize,
    this.duration,
    this.isEdited = false,
    this.isDeleted = false,
    this.editedAt,
    this.deletedAt,
    this.replyToId,
    this.replyTo,
    this.readBy = const [],
    this.reactions = const [],
    this.metadata,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] ?? '',
      roomId: json['roomId'] ?? '',
      senderId: json['senderId'] ?? '',
      senderName: json['senderName'] ?? '',
      senderAvatar: json['senderAvatar'],
      type: _parseMessageType(json['type']),
      content: json['content'] ?? '',
      giftId: json['giftId'],
      giftAmount: json['giftAmount'],
      giftName: json['giftName'], // 🟢 giftName যোগ করা হয়েছে
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
      mentions: List<String>.from(json['mentions'] ?? []),
      status: _parseMessageStatus(json['status']),
      mediaUrl: json['mediaUrl'],
      thumbnailUrl: json['thumbnailUrl'],
      fileName: json['fileName'],
      fileSize: json['fileSize'],
      duration: json['duration']?.toDouble(),
      isEdited: json['isEdited'] ?? false,
      isDeleted: json['isDeleted'] ?? false,
      editedAt: json['editedAt'] != null
          ? DateTime.parse(json['editedAt'])
          : null,
      deletedAt: json['deletedAt'] != null
          ? DateTime.parse(json['deletedAt'])
          : null,
      replyToId: json['replyToId'],
      replyTo: json['replyTo'] != null
          ? MessageModel.fromJson(json['replyTo'])
          : null,
      readBy: List<String>.from(json['readBy'] ?? []),
      reactions: (json['reactions'] as List? ?? [])
          .map((r) => MessageReaction.fromJson(r))
          .toList(),
      metadata: json['metadata'],
    );
  }

  static MessageType _parseMessageType(String? type) {
    if (type == null) return MessageType.text;
    switch (type.toLowerCase()) {
      case 'text':
        return MessageType.text;
      case 'gift':
        return MessageType.gift;
      case 'system':
        return MessageType.system;
      case 'image':
        return MessageType.image;
      case 'video':
        return MessageType.video;
      case 'audio':
        return MessageType.audio;
      case 'file':
        return MessageType.file;
      case 'location':
        return MessageType.location;
      case 'contact':
        return MessageType.contact;
      case 'sticker':
        return MessageType.sticker;
      case 'call':
        return MessageType.call;
      default:
        return MessageType.text;
    }
  }

  static MessageStatus _parseMessageStatus(String? status) {
    if (status == null) return MessageStatus.sent;
    switch (status.toLowerCase()) {
      case 'sending':
        return MessageStatus.sending;
      case 'sent':
        return MessageStatus.sent;
      case 'delivered':
        return MessageStatus.delivered;
      case 'read':
        return MessageStatus.read;
      case 'failed':
        return MessageStatus.failed;
      default:
        return MessageStatus.sent;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'roomId': roomId,
      'senderId': senderId,
      'senderName': senderName,
      'senderAvatar': senderAvatar,
      'type': type.toString().split('.').last,
      'content': content,
      'giftId': giftId,
      'giftAmount': giftAmount,
      'giftName': giftName, // 🟢 giftName যোগ করা হয়েছে
      'timestamp': timestamp.toIso8601String(),
      'mentions': mentions,
      'status': status.toString().split('.').last,
      'mediaUrl': mediaUrl,
      'thumbnailUrl': thumbnailUrl,
      'fileName': fileName,
      'fileSize': fileSize,
      'duration': duration,
      'isEdited': isEdited,
      'isDeleted': isDeleted,
      'editedAt': editedAt?.toIso8601String(),
      'deletedAt': deletedAt?.toIso8601String(),
      'replyToId': replyToId,
      'replyTo': replyTo?.toJson(),
      'readBy': readBy,
      'reactions': reactions.map((r) => r.toJson()).toList(),
      'metadata': metadata,
    };
  }

  MessageModel copyWith({
    String? id,
    String? roomId,
    String? senderId,
    String? senderName,
    String? senderAvatar,
    MessageType? type,
    String? content,
    String? giftId,
    int? giftAmount,
    String? giftName, // 🟢 giftName যোগ করা হয়েছে
    DateTime? timestamp,
    List<String>? mentions,
    MessageStatus? status,
    String? mediaUrl,
    String? thumbnailUrl,
    String? fileName,
    int? fileSize,
    double? duration,
    bool? isEdited,
    bool? isDeleted,
    DateTime? editedAt,
    DateTime? deletedAt,
    String? replyToId,
    MessageModel? replyTo,
    List<String>? readBy,
    List<MessageReaction>? reactions,
    Map<String, dynamic>? metadata,
  }) {
    return MessageModel(
      id: id ?? this.id,
      roomId: roomId ?? this.roomId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderAvatar: senderAvatar ?? this.senderAvatar,
      type: type ?? this.type,
      content: content ?? this.content,
      giftId: giftId ?? this.giftId,
      giftAmount: giftAmount ?? this.giftAmount,
      giftName: giftName ?? this.giftName, // 🟢 giftName যোগ করা হয়েছে
      timestamp: timestamp ?? this.timestamp,
      mentions: mentions ?? this.mentions,
      status: status ?? this.status,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      fileName: fileName ?? this.fileName,
      fileSize: fileSize ?? this.fileSize,
      duration: duration ?? this.duration,
      isEdited: isEdited ?? this.isEdited,
      isDeleted: isDeleted ?? this.isDeleted,
      editedAt: editedAt ?? this.editedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      replyToId: replyToId ?? this.replyToId,
      replyTo: replyTo ?? this.replyTo,
      readBy: readBy ?? this.readBy,
      reactions: reactions ?? this.reactions,
      metadata: metadata ?? this.metadata,
    );
  }

  // Helper getters
  bool get isGift => type == MessageType.gift;
  bool get isSystem => type == MessageType.system;
  bool get isMedia => type == MessageType.image ||
      type == MessageType.video ||
      type == MessageType.audio ||
      type == MessageType.file;

  bool get hasMentions => mentions.isNotEmpty;
  bool get hasReactions => reactions.isNotEmpty;
  bool get hasReply => replyToId != null;

  String get displayContent {
    if (isDeleted) return 'This message was deleted';
    if (isGift && giftName != null) return 'Sent a gift: $giftName'; // 🟢 এখন giftName কাজ করবে
    return content;
  }

  // Status helpers
  bool get isSent => status == MessageStatus.sent;
  bool get isDelivered => status == MessageStatus.delivered;
  bool get isRead => status == MessageStatus.read;
  bool get isFailed => status == MessageStatus.failed;
  bool get isSending => status == MessageStatus.sending;

  // Time formatting
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) return 'Now';
    if (difference.inHours < 1) return '${difference.inMinutes}m';
    if (difference.inDays < 1) return '${difference.inHours}h';
    if (difference.inDays < 7) return '${difference.inDays}d';
    return '${timestamp.day}/${timestamp.month}';
  }

  @override
  String toString() {
    return 'MessageModel(id: $id, sender: $senderName, type: $type)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MessageModel &&
        other.id == id &&
        other.roomId == roomId &&
        other.timestamp == timestamp;
  }

  @override
  int get hashCode => Object.hash(id, roomId, timestamp);
}

class MessageReaction {
  final String userId;
  final String reaction;
  final DateTime timestamp;

  MessageReaction({
    required this.userId,
    required this.reaction,
    required this.timestamp,
  });

  factory MessageReaction.fromJson(Map<String, dynamic> json) {
    return MessageReaction(
      userId: json['userId'] ?? '',
      reaction: json['reaction'] ?? '',
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'reaction': reaction,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  MessageReaction copyWith({
    String? userId,
    String? reaction,
    DateTime? timestamp,
  }) {
    return MessageReaction(
      userId: userId ?? this.userId,
      reaction: reaction ?? this.reaction,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}