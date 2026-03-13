import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/game_model.dart';
import '../models/user_model.dart';
import 'database_service.dart';

class GameService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DatabaseService _databaseService = DatabaseService();

  // Game types
  static const Map<String, GameConfig> gameConfigs = <String, GameConfig>{
    'roulette': GameConfig(
      minBet: 100,
      maxBet: 10000,
      winMultiplier: <String, int>{'red': 2, 'black': 2, 'green': 35},
    ),
    'threePatti': GameConfig(
      minBet: 500,
      maxBet: 50000,
      winMultiplier: <String, int>{'trail': 100, 'pureSequence': 50, 'sequence': 20, 'color': 10, 'pair': 5, 'highCard': 1},
    ),
    'ludo': GameConfig(
      minBet: 200,
      maxBet: 20000,
      winMultiplier: 2,
    ),
    'carrom': GameConfig(
      minBet: 200,
      maxBet: 20000,
      winMultiplier: 2,
    ),
    'greedyCat': GameConfig(
      minBet: 100,
      maxBet: 5000,
      winMultiplier: <String, int>{'jackpot': 50, 'bonus': 10, 'small': 2},
    ),
  };

  // ==================== ROULETTE ====================
  RouletteResult playRoulette({
    required int betAmount,
    required String betType, // 'red', 'black', 'green', or number 0-36
    required int? betNumber,
  }) {
    final Random random = Random();
    final int winningNumber = random.nextInt(37); // 0-36
    
    var won = false;
    var winAmount = 0;
    
    if (betType == 'number' && betNumber != null) {
      won = winningNumber == betNumber;
      winAmount = won ? betAmount * 35 : 0;
    } else {
      switch (betType) {
        case 'red':
          won = _isRed(winningNumber);
          winAmount = won ? betAmount * 2 : 0;
        case 'black':
          won = _isBlack(winningNumber);
          winAmount = won ? betAmount * 2 : 0;
        case 'green':
          won = winningNumber == 0;
          winAmount = won ? betAmount * 35 : 0;
      }
    }
    
    return RouletteResult(
      winningNumber: winningNumber,
      won: won,
      winAmount: winAmount,
      betType: betType,
    );
  }

  bool _isRed(int number) {
    final List<int> redNumbers = <int>[1, 3, 5, 7, 9, 12, 14, 16, 18, 19, 21, 23, 25, 27, 30, 32, 34, 36];
    return redNumbers.contains(number);
  }

  bool _isBlack(int number) {
    if (number == 0) return false;
    return !_isRed(number);
  }

  // ==================== 3 PATTI (TEEN PATTI) ====================
  ThreePattiResult playThreePatti({
    required int betAmount,
    required List<int> playerCards,
    required List<int> opponentCards,
  }) {
    final ThreePattiRank playerRank = _getThreePattiRank(playerCards);
    final ThreePattiRank opponentRank = _getThreePattiRank(opponentCards);
    
    var comparison = _compareThreePattiRanks(playerRank, opponentRank);
    var won = comparison > 0;
    var draw = comparison == 0;
    
    var winAmount = 0;
    if (won) {
      switch (playerRank.type) {
        case 'trail':
          winAmount = betAmount * 100;
        case 'pureSequence':
          winAmount = betAmount * 50;
        case 'sequence':
          winAmount = betAmount * 20;
        case 'color':
          winAmount = betAmount * 10;
        case 'pair':
          winAmount = betAmount * 5;
        default:
          winAmount = betAmount * 2;
      }
    } else if (draw) {
      winAmount = betAmount; // Return bet
    }
    
    return ThreePattiResult(
      playerRank: playerRank,
      opponentRank: opponentRank,
      won: won,
      draw: draw,
      winAmount: winAmount,
    );
  }

  ThreePattiRank _getThreePattiRank(List<int> cards) {
    // Sort cards
    cards.sort();
    
    // Check for trail (three of same rank)
    if (cards[0] ~/ 4 == cards[1] ~/ 4 && cards[1] ~/ 4 == cards[2] ~/ 4) {
      return ThreePattiRank(type: 'trail', value: cards[0] ~/ 4);
    }
    
    // Check for pure sequence (straight flush)
    var sameSuit = cards[0] % 4 == cards[1] % 4 && cards[1] % 4 == cards[2] % 4;
    var sequence = (cards[1] - cards[0] == 1) && (cards[2] - cards[1] == 1);
    
    if (sameSuit && sequence) {
      return ThreePattiRank(type: 'pureSequence', value: cards[2] ~/ 4);
    }
    
    // Check for sequence
    if (sequence) {
      return ThreePattiRank(type: 'sequence', value: cards[2] ~/ 4);
    }
    
    // Check for color (same suit)
    if (sameSuit) {
      return ThreePattiRank(type: 'color', value: cards[2] ~/ 4);
    }
    
    // Check for pair
    if (cards[0] ~/ 4 == cards[1] ~/ 4 || cards[1] ~/ 4 == cards[2] ~/ 4) {
      return ThreePattiRank(type: 'pair', value: cards[1] ~/ 4);
    }
    
    // High card
    return ThreePattiRank(type: 'highCard', value: cards[2] ~/ 4);
  }

  int _compareThreePattiRanks(ThreePattiRank a, ThreePattiRank b) {
    final List<String> typeOrder = <String>['trail', 'pureSequence', 'sequence', 'color', 'pair', 'highCard'];
    
    if (a.type != b.type) {
      return typeOrder.indexOf(a.type).compareTo(typeOrder.indexOf(b.type));
    }
    
    return a.value.compareTo(b.value);
  }

  // ==================== LUDO ====================
  LudoResult playLudo({
    required int betAmount,
    required int playerPosition,
    required int opponentPosition,
    required int diceRoll,
  }) {
    // Simple Ludo logic - first to reach home wins
    const int homePosition = 57;
    
    var newPlayerPosition = playerPosition + diceRoll;
    if (newPlayerPosition > homePosition) {
      newPlayerPosition = homePosition - (newPlayerPosition - homePosition);
    }
    
    final var won = newPlayerPosition >= homePosition;
    
    return LudoResult(
      newPosition: newPlayerPosition,
      diceRoll: diceRoll,
      won: won,
      winAmount: won ? betAmount * 2 : 0,
    );
  }

  // ==================== CARROM ====================
  CarromResult playCarrom({
    required int betAmount,
    required List<String> pocketed,
    required String striker,
  }) {
    // Simple Carrom scoring
    var score = 0;
    for (var piece in pocketed) {
      if (piece == 'queen') {
        score += 50;
      } else if (piece == 'red') score += 25;
      else score += 10;
    }
    
    final var won = score > 100;
    
    return CarromResult(
      score: score,
      striker: striker,
      won: won,
      winAmount: won ? betAmount * 2 : 0,
    );
  }

  // ==================== GREEDY CAT ====================
  GreedyCatResult playGreedyCat({
    required int betAmount,
    required int selectedBox,
  }) {
    final Random random = Random();
    final int winningBox = random.nextInt(10) + 1; // 1-10
    
    final var won = selectedBox == winningBox;
    var winAmount = 0;
    var prize = '';
    
    if (won) {
      // Jackpot or small prize
      if (selectedBox == 5) { // Middle box = jackpot
        winAmount = betAmount * 50;
        prize = 'JACKPOT';
      } else if (selectedBox % 2 == 0) { // Even boxes = bonus
        winAmount = betAmount * 10;
        prize = 'BONUS';
      } else { // Odd boxes = small
        winAmount = betAmount * 2;
        prize = 'SMALL';
      }
    }
    
    return GreedyCatResult(
      winningBox: winningBox,
      won: won,
      winAmount: winAmount,
      prize: prize,
    );
  }

  // ==================== WEREWOLF ====================
  WerewolfGame createWerewolfGame(List<String> players) {
    if (players.length < 6) throw Exception('Need at least 6 players');
    
    var werewolfCount = (players.length ~/ 4).clamp(2, 4);
    var villagerCount = players.length - werewolfCount - 1; // 1 for seer
    
    // Assign roles
    var roles = List<String>.filled(werewolfCount, 'werewolf');
    roles.addAll(List.filled(villagerCount, 'villager'));
    roles.add('seer');
    roles.shuffle();
    
    var playerRoles = <String, String><String, String>{};
    for (var i = 0; i < players.length; i++) {
      playerRoles[players[i]] = roles[i];
    }
    
    return WerewolfGame(
      players: players,
      roles: playerRoles,
      phase: 'night',
      dayCount: 1,
      alive: List.from(players),
    );
  }

  WerewolfGame werewolfAction({
    required WerewolfGame game,
    required String player,
    required String action,
    String? target,
  }) {
    if (game.phase == 'night') {
      // Night phase actions
      if (game.roles[player] == 'werewolf' && action == 'kill') {
        game.kill(target!);
      } else if (game.roles[player] == 'seer' && action == 'check') {
        game.seerCheck(target!);
      }
      
      // Check if all actions done
      if (game.nightActionsDone()) {
        game.phase = 'day';
      }
    } else {
      // Day phase - voting
      if (action == 'vote') {
        game.vote(target!);
      }
    }
    
    return game;
  }

  // ==================== TRIVIA ====================
  List<TriviaQuestion> getTriviaQuestions() {
    return <TriviaQuestion>[
      TriviaQuestion(
        question: 'What is the capital of France?',
        options: <String>['London', 'Berlin', 'Paris', 'Madrid'],
        correctAnswer: 2,
        points: 100,
      ),
      TriviaQuestion(
        question: 'Which planet is known as the Red Planet?',
        options: <String>['Venus', 'Mars', 'Jupiter', 'Saturn'],
        correctAnswer: 1,
        points: 100,
      ),
      TriviaQuestion(
        question: 'Who painted the Mona Lisa?',
        options: <String>['Van Gogh', 'Picasso', 'Da Vinci', 'Rembrandt'],
        correctAnswer: 2,
        points: 100,
      ),
      // Add more questions
    ];
  }

  TriviaResult playTrivia({
    required List<int> answers,
    required List<TriviaQuestion> questions,
  }) {
    var score = 0;
    for (var i = 0; i < answers.length; i++) {
      if (answers[i] == questions[i].correctAnswer) {
        score += questions[i].points;
      }
    }
    
    var totalPossible = questions.fold(0, (int sum, TriviaQuestion q) => sum + q.points);
    var percentage = score / totalPossible;
    
    return TriviaResult(
      score: score,
      totalPossible: totalPossible,
      percentage: percentage,
      passed: percentage >= 0.6,
    );
  }

  // ==================== PICTIONARY ====================
  PictionaryWord getRandomWord() {
    var words = <String><String>[
      'cat', 'dog', 'house', 'car', 'tree', 'sun', 'moon', 'star',
      'apple', 'banana', 'book', 'chair', 'table', 'phone', 'computer',
      'happy', 'sad', 'angry', 'scared', 'excited', 'tired',
      'running', 'jumping', 'eating', 'sleeping', 'driving',
    ];
    
    final Random random = Random();
    return PictionaryWord(
      word: words[random.nextInt(words.length)],
      difficulty: random.nextInt(3), // 0=easy, 1=medium, 2=hard
    );
  }

  // ==================== TRUTH OR DARE ====================
  TruthOrDareQuestion getRandomQuestion(String type) {
    var questions = <TruthOrDareQuestion><TruthOrDareQuestion>[
      // Truth questions
      TruthOrDareQuestion(
        type: 'truth',
        text: 'What is your biggest fear?',
        difficulty: 1,
      ),
      TruthOrDareQuestion(
        type: 'truth',
        text: 'Have you ever lied to your best friend?',
        difficulty: 2,
      ),
      TruthOrDareQuestion(
        type: 'truth',
        text: 'Who is your secret crush?',
        difficulty: 3,
      ),
      
      // Dare questions
      TruthOrDareQuestion(
        type: 'dare',
        text: 'Sing a song loudly',
        difficulty: 1,
      ),
      TruthOrDareQuestion(
        type: 'dare',
        text: 'Do 10 pushups right now',
        difficulty: 2,
      ),
      TruthOrDareQuestion(
        type: 'dare',
        text: 'Call a random contact and say I love you',
        difficulty: 3,
      ),
    ];
    
    final List<TruthOrDareQuestion> filtered = questions.where((TruthOrDareQuestion q) => q.type == type).toList();
    final Random random = Random();
    return filtered[random.nextInt(filtered.length)];
  }

  // ==================== GAME RESULT PROCESSING ====================
  Future<GamePlayResult> processGameResult({
    required String userId,
    required String gameType,
    required int betAmount,
    required bool won,
    required int winAmount,
    Map<String, dynamic>? gameData,
  }) async {
    final UserModel? user = await _databaseService.getUser(userId);
    if (user == null) throw Exception('User not found');

    var finalCoins = user.coins;
    var finalDiamonds = user.diamonds;
    var coinsChange = 0;

    if (won) {
      // Add winnings
      finalCoins += winAmount;
      coinsChange = winAmount;
      
      // Update game stats
      user.stats['games_won'] = (user.stats['games_won'] ?? 0) + 1;
      user.stats['total_winnings'] = (user.stats['total_winnings'] ?? 0) + winAmount;
    } else {
      // Deduct bet
      finalCoins -= betAmount;
      coinsChange = -betAmount;
      
      // Update game stats
      user.stats['games_lost'] = (user.stats['games_lost'] ?? 0) + 1;
      user.stats['total_losses'] = (user.stats['total_losses'] ?? 0) + betAmount;
    }

    user.stats['games_played'] = (user.stats['games_played'] ?? 0) + 1;
    user.coins = finalCoins;

    // Update user
    await _databaseService.updateUser(userId, <String, dynamic>{
      'coins': finalCoins,
      'diamonds': finalDiamonds,
      'stats': user.stats,
    });

    // Record transaction
    await _databaseService.addCoins(
      userId,
      coinsChange.abs(),
      won ? 'Game winning' : 'Game bet',
    );

    // Save game history
    await _saveGameHistory(
      userId: userId,
      gameType: gameType,
      betAmount: betAmount,
      won: won,
      winAmount: winAmount,
      gameData: gameData,
    );

    return GamePlayResult(
      won: won,
      betAmount: betAmount,
      winAmount: winAmount,
      finalCoins: finalCoins,
      finalDiamonds: finalDiamonds,
    );
  }

  Future<void> _saveGameHistory({
    required String userId,
    required String gameType,
    required int betAmount,
    required bool won,
    required int winAmount,
    Map<String, dynamic>? gameData,
  }) async {
    await _firestore.collection('game_history').add(<String, >{
      'userId': userId,
      'gameType': gameType,
      'betAmount': betAmount,
      'won': won,
      'winAmount': winAmount,
      'gameData': gameData,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // Get leaderboard
  Stream<List<GameLeaderboardEntry>> getLeaderboard(String gameType) {
    return _firestore
        .collection('users')
        .orderBy('stats.total_winnings', descending: true)
        .limit(100)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) {
              final data = doc.data();
              return GameLeaderboardEntry(
                userId: doc.id,
                username: data['username'] ?? 'Unknown',
                photoURL: data['photoURL'],
                totalWinnings: data['stats']?['total_winnings'] ?? 0,
                gamesPlayed: data['stats']?['games_played'] ?? 0,
              );
            })
            .toList());
  }
}

// ==================== MODEL CLASSES ====================

class GameConfig {
  
  GameConfig({
    required this.minBet,
    required this.maxBet,
    required this.winMultiplier,
  });
  final int minBet;
  final int maxBet;
  final dynamic winMultiplier;
}

class RouletteResult {
  
  RouletteResult({
    required this.winningNumber,
    required this.won,
    required this.winAmount,
    required this.betType,
  });
  final int winningNumber;
  final bool won;
  final int winAmount;
  final String betType;
}

class ThreePattiRank {
  
  ThreePattiRank({required this.type, required this.value});
  final String type;
  final int value;
}

class ThreePattiResult {
  
  ThreePattiResult({
    required this.playerRank,
    required this.opponentRank,
    required this.won,
    required this.draw,
    required this.winAmount,
  });
  final ThreePattiRank playerRank;
  final ThreePattiRank opponentRank;
  final bool won;
  final bool draw;
  final int winAmount;
}

class LudoResult {
  
  LudoResult({
    required this.newPosition,
    required this.diceRoll,
    required this.won,
    required this.winAmount,
  });
  final int newPosition;
  final int diceRoll;
  final bool won;
  final int winAmount;
}

class CarromResult {
  
  CarromResult({
    required this.score,
    required this.striker,
    required this.won,
    required this.winAmount,
  });
  final int score;
  final String striker;
  final bool won;
  final int winAmount;
}

class GreedyCatResult {
  
  GreedyCatResult({
    required this.winningBox,
    required this.won,
    required this.winAmount,
    required this.prize,
  });
  final int winningBox;
  final bool won;
  final int winAmount;
  final String prize;
}

class WerewolfGame {
  
  WerewolfGame({
    required this.players,
    required this.roles,
    required this.phase,
    required this.dayCount,
    required this.alive,
  });
  List<String> players;
  Map<String, String> roles;
  String phase;
  int dayCount;
  List<String> alive;
  Map<String, int> votes = <String, int>{};
  List<String> killed = <String>[];
  
  void kill(String player) {
    killed.add(player);
    alive.remove(player);
  }
  
  void seerCheck(String player) {
    // Seer sees role
  }
  
  void vote(String player) {
    votes[player] = (votes[player] ?? 0) + 1;
  }
  
  bool nightActionsDone() {
    // Check if all werewolves have acted
    return true;
  }
}

class TriviaQuestion {
  
  TriviaQuestion({
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.points,
  });
  final String question;
  final List<String> options;
  final int correctAnswer;
  final int points;
}

class TriviaResult {
  
  TriviaResult({
    required this.score,
    required this.totalPossible,
    required this.percentage,
    required this.passed,
  });
  final int score;
  final int totalPossible;
  final double percentage;
  final bool passed;
}

class PictionaryWord {
  
  PictionaryWord({required this.word, required this.difficulty});
  final String word;
  final int difficulty;
}

class TruthOrDareQuestion {
  
  TruthOrDareQuestion({
    required this.type,
    required this.text,
    required this.difficulty,
  });
  final String type;
  final String text;
  final int difficulty;
}

class GamePlayResult {
  
  GamePlayResult({
    required this.won,
    required this.betAmount,
    required this.winAmount,
    required this.finalCoins,
    required this.finalDiamonds,
  });
  final bool won;
  final int betAmount;
  final int winAmount;
  final int finalCoins;
  final int finalDiamonds;
}

class GameLeaderboardEntry {
  
  GameLeaderboardEntry({
    required this.userId,
    required this.username,
    this.photoURL,
    required this.totalWinnings,
    required this.gamesPlayed,
  });
  final String userId;
  final String username;
  final String? photoURL;
  final int totalWinnings;
  final int gamesPlayed;
}