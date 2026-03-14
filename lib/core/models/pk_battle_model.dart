class PKBattleModel {
  String id;
  String room1Id;
  String room2Id;
  int room1Score;
  int room2Score;
  DateTime startTime;
  DateTime endTime;
  bool isActive;
  String? winnerId;
  Map<String, int> topGifters;
}