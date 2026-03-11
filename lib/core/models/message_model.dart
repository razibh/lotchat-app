
class MessageModel {
  String id;
  String roomId;
  String senderId;
  String senderName;
  String? senderAvatar;
  MessageType type;             // text, gift, system
  String content;
  String? giftId;
  int? giftAmount;
  DateTime timestamp;
  List<String> mentions;
}