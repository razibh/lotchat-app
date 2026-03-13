class ChatModel {
  final String id;
  final String type;
  final String? groupName;
  final String? groupAvatar;
  final List<String> participants;
  final DateTime? lastMessageTime;
  final String? lastMessage;

  ChatModel({
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
      id: json['id'] ?? '',
      type: json['type'] ?? 'private',
      groupName: json['groupName'],
      groupAvatar: json['groupAvatar'],
      participants: List<String>.from(json['participants'] ?? []),
      lastMessageTime: json['lastMessageTime'] != null
          ? DateTime.parse(json['lastMessageTime'])
          : null,
      lastMessage: json['lastMessage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'groupName': groupName,
      'groupAvatar': groupAvatar,
      'participants': participants,
      'lastMessageTime': lastMessageTime?.toIso8601String(),
      'lastMessage': lastMessage,
    };
  }
}