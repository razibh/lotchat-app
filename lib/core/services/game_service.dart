import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/game_model.dart';
import '../models/user_model.dart';
import 'database_service.dart';

class GameService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DatabaseService _databaseService = DatabaseService();

  // Game types
  static const Map<String, GameConfig> gameConfigs = {
    'roulette': GameConfig(
      minBet: 100,
      maxBet: 10000,
      winMultiplier: {'red': 2, 'black': 2, 'green': 35},
    ),
    'threePatti': GameConfig(
      minBet: 500,
      maxBet: 50000,
      winMultiplier: {'trail': 100, 'pureSequence': 50, 'sequence': 20, 'color': 10, 'pair': 5, 'highCard': 1},
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
      winMultiplier: {'jackpot': 50, 'bonus': 10, 'small': 2},
    ),
  };

  // ==================== ROULETTE ====================
  RouletteResult playRoulette({
    required int betAmount,
    required String betType, // 'red', 'black', 'green', or number 0-36
    required int? betNumber,
  }) {
    final random = Random();
    final winningNumber = random.nextInt(37); // 0-36
    
    bool won = false;
    int winAmount = 0;
    
    if (betType == 'number' && betNumber != null) {
      won = winningNumber == betNumber;
      winAmount = won ? betAmount * 35 : 0;
    } else {
      switch (betType) {
        case 'red':
          won = _isRed(winningNumber);
          winAmount = won ? betAmount * 2 : 0;
          break;
        case 'black':
          won = _isBlack(winningNumber);
          winAmount = won ? betAmount * 2 : 0;
          break;
        case 'green':
          won = winningNumber == 0;
          winAmount = won ? betAmount * 35 : 0;
          break;
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
    final redNumbers = [1, 3, 5, 7, 9, 12, 14, 16, 18, 19, 21, 23, 25, 27, 30, 32, 34, 36];
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
    final playerRank = _getThreePattiRank(playerCards);
    final opponentRank = _getThreePattiRank(opponentCards);
    
    int comparison = _compareThreePattiRanks(playerRank, opponentRank);
    bool won = comparison > 0;
    bool draw = comparison == 0;
    
    int winAmount = 0;
    if (won) {
      switch (playerRank.type) {
        case 'trail':
          winAmount = betAmount * 100;
          break;
        case 'pureSequence':
          winAmount = betAmount * 50;
          break;
        case 'sequence':
          winAmount = betAmount * 20;
          break;
        case 'color':
          winAmount = betAmount * 10;
          break;
        case 'pair':
          winAmount = betAmount * 5;
          break;
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
    bool sameSuit = cards[0] % 4 == cards[1] % 4 && cards[1] % 4 == cards[2] % 4;
    bool sequence = (cards[1] - cards[0] == 1) && (cards[2] - cards[1] == 1);
    
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
    final typeOrder = ['trail', 'pureSequence', 'sequence', 'color', 'pair', 'highCard'];
    
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
    const homePosition = 57;
    
    int newPlayerPosition = playerPosition + diceRoll;
    if (newPlayerPosition > homePosition) {
      newPlayerPosition = homePosition - (newPlayerPosition - homePosition);
    }
    
    bool won = newPlayerPosition >= homePosition;
    
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
    int score = 0;
    for (String piece in pocketed) {
      if (piece == 'queen') score += 50;
      else if (piece == 'red') score += 25;
      else score += 10;
    }
    
    bool won = score > 100;
    
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
    final random = Random();
    final winningBox = random.nextInt(10) + 1; // 1-10
    
    bool won = selectedBox == winningBox;
    int winAmount = 0;
    String prize = '';
    
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
    
    int werewolfCount = (players.length ~/ 4).clamp(2, 4);
    int villagerCount = players.length - werewolfCount - 1; // 1 for seer
    
    // Assign roles
    List<String> roles = List.filled(werewolfCount, 'werewolf');
    roles.addAll(List.filled(villagerCount, 'villager'));
    roles.add('seer');
    roles.shuffle();
    
    Map<String, String> playerRoles = {};
    for (int i = 0; i < players.length; i++) {
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
    return [
      TriviaQuestion(
        question: 'What is the capital of France?',
        options: ['London', 'Berlin', 'Paris', 'Madrid'],
        correctAnswer: 2,
        points: 100,
      ),
      TriviaQuestion(
        question: 'Which planet is known as the Red Planet?',
        options: ['Venus', 'Mars', 'Jupiter', 'Saturn'],
        correctAnswer: 1,
        points: 100,
      ),
      TriviaQuestion(
        question: 'Who painted the Mona Lisa?',
        options: ['Van Gogh', 'Picasso', 'Da Vinci', 'Rembrandt'],
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
    int score = 0;
    for (int i = 0; i < answers.length; i++) {
      if (answers[i] == questions[i].correctAnswer) {
        score += questions[i].points;
      }
    }
    
    int totalPossible = questions.fold(0, (sum, q) => sum + q.points);
    double percentage = score / totalPossible;
    
    return TriviaResult(
      score: score,
      totalPossible: totalPossible,
      percentage: percentage,
      passed: percentage >= 0.6,
    );
  }

  // ==================== PICTIONARY ====================
  PictionaryWord getRandomWord() {
    List<String> words = [
      'cat', 'dog', 'house', 'car', 'tree', 'sun', 'moon', 'star',
      'apple', 'banana', 'book', 'chair', 'table', 'phone', 'computer',
      'happy', 'sad', 'angry', 'scared', 'excited', 'tired',
      'running', 'jumping', 'eating', 'sleeping', 'driving',
    ];
    
    final random = Random();
    return PictionaryWord(
      word: words[random.nextInt(words.length)],
      difficulty: random.nextInt(3), // 0=easy, 1=medium, 2=hard
    );
  }

  // ==================== TRUTH OR DARE ====================
  TruthOrDareQuestion getRandomQuestion(String type) {
    List<TruthOrDareQuestion> questions = [
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
    
    final filtered = questions.where((q) => q.type == type).toList();
    final random = Random();
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
    final user = await _databaseService.getUser(userId);
    if (user == null) throw Exception('User not found');

    int finalCoins = user.coins;
    int finalDiamonds = user.diamonds;
    int coinsChange = 0;

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
    await _databaseService.updateUser(userId, {
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
    await _firestore.collection('game_history').add({
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
  final int minBet;
  final int maxBet;
  final dynamic winMultiplier;
  
  GameConfig({
    required this.minBet,
    required this.maxBet,
    required this.winMultiplier,
  });
}

class RouletteResult {
  final int winningNumber;
  final bool won;
  final int winAmount;
  final String betType;
  
  RouletteResult({
    required this.winningNumber,
    required this.won,
    required this.winAmount,
    required this.betType,
  });
}

class ThreePattiRank {
  final String type;
  final int value;
  
  ThreePattiRank({required this.type, required this.value});
}

class ThreePattiResult {
  final ThreePattiRank playerRank;
  final ThreePattiRank opponentRank;
  final bool won;
  final bool draw;
  final int winAmount;
  
  ThreePattiResult({
    required this.playerRank,
    required this.opponentRank,
    required this.won,
    required this.draw,
    required this.winAmount,
  });
}

class LudoResult {
  final int newPosition;
  final int diceRoll;
  final bool won;
  final int winAmount;
  
  LudoResult({
    required this.newPosition,
    required this.diceRoll,
    required this.won,
    required this.winAmount,
  });
}

class CarromResult {
  final int score;
  final String striker;
  final bool won;
  final int winAmount;
  
  CarromResult({
    required this.score,
    required this.striker,
    required this.won,
    required this.winAmount,
  });
}

class GreedyCatResult {
  final int winningBox;
  final bool won;
  final int winAmount;
  final String prize;
  
  GreedyCatResult({
    required this.winningBox,
    required this.won,
    required this.winAmount,
    required this.prize,
  });
}

class WerewolfGame {
  List<String> players;
  Map<String, String> roles;
  String phase;
  int dayCount;
  List<String> alive;
  Map<String, int> votes = {};
  List<String> killed = [];
  
  WerewolfGame({
    required this.players,
    required this.roles,
    required this.phase,
    required this.dayCount,
    required this.alive,
  });
  
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
  final String question;
  final List<String> options;
  final int correctAnswer;
  final int points;
  
  TriviaQuestion({
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.points,
  });
}

class TriviaResult {
  final int score;
  final int totalPossible;
  final double percentage;
  final bool passed;
  
  TriviaResult({
    required this.score,
    required this.totalPossible,
    required this.percentage,
    required this.passed,
  });
}

class PictionaryWord {
  final String word;
  final int difficulty;
  
  PictionaryWord({required this.word, required this.difficulty});
}

class TruthOrDareQuestion {
  final String type;
  final String text;
  final int difficulty;
  
  TruthOrDareQuestion({
    required this.type,
    required this.text,
    required this.difficulty,
  });
}

class GamePlayResult {
  final bool won;
  final int betAmount;
  final int winAmount;
  final int finalCoins;
  final int finalDiamonds;
  
  GamePlayResult({
    required this.won,
    required this.betAmount,
    required this.winAmount,
    required this.finalCoins,
    required this.finalDiamonds,
  });
}

class GameLeaderboardEntry {
  final String userId;
  final String username;
  final String? photoURL;
  final int totalWinnings;
  final int gamesPlayed;
  
  GameLeaderboardEntry({
    required this.userId,
    required this.username,
    this.photoURL,
    required this.totalWinnings,
    required this.gamesPlayed,
  });
}