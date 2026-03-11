class RoomModel {
  String id;
  String name;
  String hostId;
  String hostName;
  String hostAvatar;
  String category;
  String? description;
  String? announcement;
  int viewerCount;
  int maxSeats;
  List<SeatModel> seats;
  bool isPKActive;
  String? currentPKId;
  bool isPrivate;
  String? pinCode;
  DateTime createdAt;
  List<String> moderators;
  Map<String, int> giftsReceived;
}