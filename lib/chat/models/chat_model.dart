// lib/chat/models/chat_model.dart

class ChatModel {

  const ChatModel({
    required this.id,
    required this.type,
    this.groupName,
    this.groupAvatar,
    required this.participants,
    this.lastMessageTime,
    this.lastMessage,
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      id: json['id'] as String? ?? '',
      type: json['type'] as String? ?? 'private',
      groupName: json['groupName'] as String?,
      groupAvatar: json['groupAvatar'] as String?,
      participants: json['participants'] != null
          ? List<String>.from(json['participants'] as List)
          : [],
      lastMessageTime: json['lastMessageTime'] != null
          ? DateTime.tryParse(json['lastMessageTime'] as String)
          : null,
      lastMessage: json['lastMessage'] as String?,
    );
  }
  final String id;
  final String type;
  final String? groupName;
  final String? groupAvatar;
  final List<String> participants;
  final DateTime? lastMessageTime;
  final String? lastMessage;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'type': type,
      'groupName': groupName,
      'groupAvatar': groupAvatar,
      'participants': participants,
      'lastMessageTime': lastMessageTime?.toIso8601String(),
      'lastMessage': lastMessage,
    };
  }

  // CopyWith method for easy updates
  ChatModel copyWith({
    String? id,
    String? type,
    String? groupName,
    String? groupAvatar,
    List<String>? participants,
    DateTime? lastMessageTime,
    String? lastMessage,
  }) {
    return ChatModel(
      id: id ?? this.id,
      type: type ?? this.type,
      groupName: groupName ?? this.groupName,
      groupAvatar: groupAvatar ?? this.groupAvatar,
      participants: participants ?? this.participants,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      lastMessage: lastMessage ?? this.lastMessage,
    );
  }

  // Helper method to get chat title
  String get displayTitle {
    if (type == 'private') {
      return participants.isNotEmpty ? participants.first : 'Chat';
    } else {
      return groupName ?? 'Group Chat';
    }
  }

  // Helper method to get chat avatar
  String? get displayAvatar {
    return groupAvatar;
  }

  @override
  String toString() {
    return 'ChatModel(id: $id, type: $type, groupName: $groupName, participants: $participants)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChatModel &&
        other.id == id &&
        other.type == type &&
        other.groupName == groupName &&
        other.groupAvatar == groupAvatar &&
        other.participants == participants &&
        other.lastMessageTime == lastMessageTime &&
        other.lastMessage == lastMessage;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      type,
      groupName,
      groupAvatar,
      participants,
      lastMessageTime,
      lastMessage,
    );
  }
}