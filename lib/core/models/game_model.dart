class GameModel {
  String id;
  String name;                  // Roulette, 3 Patti, Ludo etc.
  GameType type;
  int minBet;
  int maxBet;
  double winRate;
  Map<String, dynamic> rules;
  String? animationPath;
}