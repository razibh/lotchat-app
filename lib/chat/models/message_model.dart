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
  final String? mediaUrl;
  final String? thumbnailUrl;
  final String? fileName;
  final int? fileSize;
  final double? duration; // for audio/video
  final double? latitude;
  final double? longitude;
  final String? placeName;
  final String? contactName;
  final String? contactPhone;
  final String? giftId;
  final String? giftName;
  final int? giftPrice;
  final String? callType;
  final int? callDuration;
  final DateTime timestamp;
  final DateTime? editedAt;
  final DateTime? deletedAt;
  final List<String> readBy;
  final List<MessageReaction> reactions;
  final MessageModel? replyTo;
  final bool isForwarded;
  final String? forwardedFrom;
  final Map<String, dynamic>? metadata;

  MessageModel({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.senderName,
    this.senderAvatar,
    required this.type,
    required this.status,
    required this.content,
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
    this.callType,
    this.callDuration,
    required this.timestamp,
    this.editedAt,
    this.deletedAt,
    this.readBy = const [],
    this.reactions = const [],
    this.replyTo,
    this.isForwarded = false,
    this.forwardedFrom,
    this.metadata,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'],
      chatId: json['chatId'],
      senderId: json['senderId'],
      senderName: json['senderName'],
      senderAvatar: json['senderAvatar'],
      type: MessageType.values[json['type']],
      status: MessageStatus.values[json['status']],
      content: json['content'],
      mediaUrl: json['mediaUrl'],
      thumbnailUrl: json['thumbnailUrl'],
      fileName: json['fileName'],
      fileSize: json['fileSize'],
      duration: json['duration'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      placeName: json['placeName'],
      contactName: json['contactName'],
      contactPhone: json['contactPhone'],
      giftId: json['giftId'],
      giftName: json['giftName'],
      giftPrice: json['giftPrice'],
      callType: json['callType'],
      callDuration: json['callDuration'],
      timestamp: DateTime.parse(json['timestamp']),
      editedAt: json['editedAt'] != null 
          ? DateTime.parse(json['editedAt']) 
          : null,
      deletedAt: json['deletedAt'] != null 
          ? DateTime.parse(json['deletedAt']) 
          : null,
      readBy: List<String>.from(json['readBy'] ?? []),
      reactions: (json['reactions'] as List?)
          ?.map((r) => MessageReaction.fromJson(r))
          .toList() ?? [],
      replyTo: json['replyTo'] != null 
          ? MessageModel.fromJson(json['replyTo']) 
          : null,
      isForwarded: json['isForwarded'] ?? false,
      forwardedFrom: json['forwardedFrom'],
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'chatId': chatId,
    'senderId': senderId,
    'senderName': senderName,
    'senderAvatar': senderAvatar,
    'type': type.index,
    'status': status.index,
    'content': content,
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
    'callType': callType,
    'callDuration': callDuration,
    'timestamp': timestamp.toIso8601String(),
    'editedAt': editedAt?.toIso8601String(),
    'deletedAt': deletedAt?.toIso8601String(),
    'readBy': readBy,
    'reactions': reactions.map((r) => r.toJson()).toList(),
    'replyTo': replyTo?.toJson(),
    'isForwarded': isForwarded,
    'forwardedFrom': forwardedFrom,
    'metadata': metadata,
  };
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
      userId: json['userId'],
      reaction: json['reaction'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'reaction': reaction,
    'timestamp': timestamp.toIso8601String(),
  };
}