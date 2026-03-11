class TransactionModel {
  String id;
  String userId;
  String? sellerId;
  TransactionType type;         // purchase, gift_sent, gift_received, game
  int amount;
  int coinsBefore;
  int coinsAfter;
  String? description;
  DateTime timestamp;
  Map<String, dynamic> metadata; // giftId, gameId etc.
}