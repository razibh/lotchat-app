// lib/chat/models/message_model.dart

import 'package:flutter/foundation.dart';

enum MessageType {
  text,
  image,
  video,
  audio,
  file,
  location,
  contact,
  sticker,
  gift,
  call,
  system
}

enum MessageStatus {
  sending,
  sent,
  delivered,
  read,
  failed
}

class MessageModel {
  final String id;
  final String chatId;
  final String senderId;
  final String senderName;
  final String? senderAvatar;
  final MessageType type;
  final MessageStatus status;
  final String content;
  final DateTime timestamp;
  final DateTime? editedAt;
  final DateTime? deletedAt;
  final List<String> readBy;
  final List<MessageReaction> reactions;
  final MessageModel? replyTo;

  // Media fields
  final String? mediaUrl;
  final String? thumbnailUrl;
  final String? fileName;
  final int? fileSize;
  final double? duration;

  // Location fields
  final double? latitude;
  final double? longitude;
  final String? placeName;

  // Contact fields
  final String? contactName;
  final String? contactPhone;

  // Gift fields
  final String? giftId;
  final String? giftName;
  final int? giftPrice;

  MessageModel({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.senderName,
    this.senderAvatar,
    required this.type,
    required this.status,
    required this.content,
    required this.timestamp,
    this.editedAt,
    this.deletedAt,
    this.readBy = const [],
    this.reactions = const [],
    this.replyTo,
    this.mediaUrl,
    this.thumbnailUrl,
    this.fileName,
    this.fileSize,
    this.duration,
    this.latitude,
    this.longitude,
    this.placeName,
    this.contactName,
    this.contactPhone,
    this.giftId,
    this.giftName,
    this.giftPrice,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] ?? '',
      chatId: json['chatId'] ?? '',
      senderId: json['senderId'] ?? '',
      senderName: json['senderName'] ?? '',
      senderAvatar: json['senderAvatar'],
      type: _parseMessageType(json['type']),
      status: _parseMessageStatus(json['status']),
      content: json['content'] ?? '',
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
      editedAt: json['editedAt'] != null
          ? DateTime.parse(json['editedAt'])
          : null,
      deletedAt: json['deletedAt'] != null
          ? DateTime.parse(json['deletedAt'])
          : null,
      readBy: List<String>.from(json['readBy'] ?? []),
      reactions: (json['reactions'] as List? ?? [])
          .map((r) => MessageReaction.fromJson(r))
          .toList(),
      replyTo: json['replyTo'] != null
          ? MessageModel.fromJson(json['replyTo'])
          : null,
      mediaUrl: json['mediaUrl'],
      thumbnailUrl: json['thumbnailUrl'],
      fileName: json['fileName'],
      fileSize: json['fileSize'],
      duration: json['duration']?.toDouble(),
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      placeName: json['placeName'],
      contactName: json['contactName'],
      contactPhone: json['contactPhone'],
      giftId: json['giftId'],
      giftName: json['giftName'],
      giftPrice: json['giftPrice'],
    );
  }

  static MessageType _parseMessageType(String? type) {
    if (type == null) return MessageType.text;
    switch (type.toLowerCase()) {
      case 'image': return MessageType.image;
      case 'video': return MessageType.video;
      case 'audio': return MessageType.audio;
      case 'file': return MessageType.file;
      case 'location': return MessageType.location;
      case 'contact': return MessageType.contact;
      case 'sticker': return MessageType.sticker;
      case 'gift': return MessageType.gift;
      case 'call': return MessageType.call;
      case 'system': return MessageType.system;
      default: return MessageType.text;
    }
  }

  static MessageStatus _parseMessageStatus(String? status) {
    if (status == null) return MessageStatus.sent;
    switch (status.toLowerCase()) {
      case 'sending': return MessageStatus.sending;
      case 'sent': return MessageStatus.sent;
      case 'delivered': return MessageStatus.delivered;
      case 'read': return MessageStatus.read;
      case 'failed': return MessageStatus.failed;
      default: return MessageStatus.sent;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chatId': chatId,
      'senderId': senderId,
      'senderName': senderName,
      'senderAvatar': senderAvatar,
      'type': type.toString().split('.').last,
      'status': status.toString().split('.').last,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'editedAt': editedAt?.toIso8601String(),
      'deletedAt': deletedAt?.toIso8601String(),
      'readBy': readBy,
      'reactions': reactions.map((r) => r.toJson()).toList(),
      'replyTo': replyTo?.toJson(),
      'mediaUrl': mediaUrl,
      'thumbnailUrl': thumbnailUrl,
      'fileName': fileName,
      'fileSize': fileSize,
      'duration': duration,
      'latitude': latitude,
      'longitude': longitude,
      'placeName': placeName,
      'contactName': contactName,
      'contactPhone': contactPhone,
      'giftId': giftId,
      'giftName': giftName,
      'giftPrice': giftPrice,
    };
  }

  // 🟢 copyWith method - এইটা নিশ্চিত করুন যে আছে
  MessageModel copyWith({
    String? id,
    String? chatId,
    String? senderId,
    String? senderName,
    String? senderAvatar,
    MessageType? type,
    MessageStatus? status,
    String? content,
    DateTime? timestamp,
    DateTime? editedAt,
    DateTime? deletedAt,
    List<String>? readBy,
    List<MessageReaction>? reactions,
    MessageModel? replyTo,
    String? mediaUrl,
    String? thumbnailUrl,
    String? fileName,
    int? fileSize,
    double? duration,
    double? latitude,
    double? longitude,
    String? placeName,
    String? contactName,
    String? contactPhone,
    String? giftId,
    String? giftName,
    int? giftPrice,
  }) {
    return MessageModel(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderAvatar: senderAvatar ?? this.senderAvatar,
      type: type ?? this.type,
      status: status ?? this.status,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      editedAt: editedAt ?? this.editedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      readBy: readBy ?? this.readBy,
      reactions: reactions ?? this.reactions,
      replyTo: replyTo ?? this.replyTo,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      fileName: fileName ?? this.fileName,
      fileSize: fileSize ?? this.fileSize,
      duration: duration ?? this.duration,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      placeName: placeName ?? this.placeName,
      contactName: contactName ?? this.contactName,
      contactPhone: contactPhone ?? this.contactPhone,
      giftId: giftId ?? this.giftId,
      giftName: giftName ?? this.giftName,
      giftPrice: giftPrice ?? this.giftPrice,
    );
  }
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
}