import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/game_model.dart';
import '../models/user_models.dart' as app;
import '../di/service_locator.dart';

class GameService {
  late final SupabaseClient _supabase;

  GameService() {
    _supabase = getService<SupabaseClient>();
  }

  // Game types
  static final Map<String, GameConfig> gameConfigs = {
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

  // ==================== HELPER METHODS ====================

  String? get _currentUserId => _supabase.auth.currentSession?.user.id;

  Future<app.User?> _getUser(String userId) async {
    try {
      final response = await _supabase
          .from('users')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (response != null) {
        return app.User.fromJson(response);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting user: $e');
      return null;
    }
  }

  // Helper to safely convert to int
  int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is String) return int.tryParse(value) ?? 0;
    if (value is num) return value.toInt();
    return 0;
  }

  // Helper to safely convert to double
  double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    if (value is num) return value.toDouble();
    return 0.0;
  }

  // ==================== ROULETTE ====================
  RouletteResult playRoulette({
    required int betAmount,
    required String betType,
    int? betNumber,
  }) {
    final Random random = Random();
    final int winningNumber = random.nextInt(37);

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
    const List<int> redNumbers = [1, 3, 5, 7, 9, 12, 14, 16, 18, 19, 21, 23, 25, 27, 30, 32, 34, 36];
    return redNumbers.contains(number);
  }

  bool _isBlack(int number) {
    if (number == 0) return false;
    return !_isRed(number);
  }

  // ==================== 3 PATTI ====================
  ThreePattiResult playThreePatti({
    required int betAmount,
    required List<int> playerCards,
    required List<int> opponentCards,
  }) {
    final ThreePattiRank playerRank = _getThreePattiRank(playerCards);
    final ThreePattiRank opponentRank = _getThreePattiRank(opponentCards);

    int comparison = _compareThreePattiRanks(playerRank, opponentRank);
    bool won = comparison > 0;
    final bool draw = comparison == 0;

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
      winAmount = betAmount;
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
    cards.sort();

    if (cards[0] ~/ 4 == cards[1] ~/ 4 && cards[1] ~/ 4 == cards[2] ~/ 4) {
      return ThreePattiRank(type: 'trail', value: cards[0] ~/ 4);
    }

    final bool sameSuit = cards[0] % 4 == cards[1] % 4 && cards[1] % 4 == cards[2] % 4;
    final bool sequence = (cards[1] - cards[0] == 1) && (cards[2] - cards[1] == 1);

    if (sameSuit && sequence) {
      return ThreePattiRank(type: 'pureSequence', value: cards[2] ~/ 4);
    }

    if (sequence) {
      return ThreePattiRank(type: 'sequence', value: cards[2] ~/ 4);
    }

    if (sameSuit) {
      return ThreePattiRank(type: 'color', value: cards[2] ~/ 4);
    }

    if (cards[0] ~/ 4 == cards[1] ~/ 4 || cards[1] ~/ 4 == cards[2] ~/ 4) {
      return ThreePattiRank(type: 'pair', value: cards[1] ~/ 4);
    }

    return ThreePattiRank(type: 'highCard', value: cards[2] ~/ 4);
  }

  int _compareThreePattiRanks(ThreePattiRank a, ThreePattiRank b) {
    const List<String> typeOrder = ['trail', 'pureSequence', 'sequence', 'color', 'pair', 'highCard'];

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
    const int homePosition = 57;

    int newPlayerPosition = playerPosition + diceRoll;
    if (newPlayerPosition > homePosition) {
      newPlayerPosition = homePosition - (newPlayerPosition - homePosition);
    }

    final bool won = newPlayerPosition >= homePosition;

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
    int score = 0;
    for (var piece in pocketed) {
      if (piece == 'queen') {
        score += 50;
      } else if (piece == 'red') {
        score += 25;
      } else {
        score += 10;
      }
    }

    final bool won = score > 100;

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
    final int winningBox = random.nextInt(10) + 1;

    final bool won = selectedBox == winningBox;
    int winAmount = 0;
    String prize = '';

    if (won) {
      if (selectedBox == 5) {
        winAmount = betAmount * 50;
        prize = 'JACKPOT';
      } else if (selectedBox % 2 == 0) {
        winAmount = betAmount * 10;
        prize = 'BONUS';
      } else {
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
    final int villagerCount = players.length - werewolfCount - 1;

    List<String> roles = List.filled(werewolfCount, 'werewolf');
    roles.addAll(List.filled(villagerCount, 'villager'));
    roles.add('seer');
    roles.shuffle();

    final Map<String, String> playerRoles = {};
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
      if (game.roles[player] == 'werewolf' && action == 'kill') {
        game.kill(target!);
      } else if (game.roles[player] == 'seer' && action == 'check') {
        game.seerCheck(target!);
      }

      if (game.nightActionsDone()) {
        game.phase = 'day';
      }
    } else {
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
    ];
  }

  TriviaResult playTrivia({
    required List<int> answers,
    required List<TriviaQuestion> questions,
  }) {
    int score = 0;
    for (var i = 0; i < answers.length; i++) {
      if (answers[i] == questions[i].correctAnswer) {
        score += questions[i].points;
      }
    }

    int totalPossible = questions.fold(0, (int sum, TriviaQuestion q) => sum + q.points);
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
    final List<String> words = [
      'cat', 'dog', 'house', 'car', 'tree', 'sun', 'moon', 'star',
      'apple', 'banana', 'book', 'chair', 'table', 'phone', 'computer',
      'happy', 'sad', 'angry', 'scared', 'excited', 'tired',
      'running', 'jumping', 'eating', 'sleeping', 'driving',
    ];

    final Random random = Random();
    return PictionaryWord(
      word: words[random.nextInt(words.length)],
      difficulty: random.nextInt(3),
    );
  }

  // ==================== TRUTH OR DARE ====================
  TruthOrDareQuestion getRandomQuestion(String type) {
    final List<TruthOrDareQuestion> questions = [
      TruthOrDareQuestion(type: 'truth', text: 'What is your biggest fear?', difficulty: 1),
      TruthOrDareQuestion(type: 'truth', text: 'Have you ever lied to your best friend?', difficulty: 2),
      TruthOrDareQuestion(type: 'truth', text: 'Who is your secret crush?', difficulty: 3),
      TruthOrDareQuestion(type: 'dare', text: 'Sing a song loudly', difficulty: 1),
      TruthOrDareQuestion(type: 'dare', text: 'Do 10 pushups right now', difficulty: 2),
      TruthOrDareQuestion(type: 'dare', text: 'Call a random contact and say I love you', difficulty: 3),
    ];

    final List<TruthOrDareQuestion> filtered = questions.where((q) => q.type == type).toList();
    final Random random = Random();
    return filtered[random.nextInt(filtered.length)];
  }

  // ==================== GAME RESULT PROCESSING - FIXED ====================

  Future<GamePlayResult> processGameResult({
    required String userId,
    required String gameType,
    required int betAmount,
    required bool won,
    required int winAmount,
    Map<String, dynamic>? gameData,
  }) async {
    final app.User? user = await _getUser(userId);
    if (user == null) throw Exception('User not found');

    int finalCoins = user.coins;
    final int finalDiamonds = user.diamonds;
    int coinsChange = 0;

    Map<String, dynamic> stats = {};
    if (user.stats != null) {
      stats = Map<String, dynamic>.from(user.stats!.toJson());
    }

    if (won) {
      finalCoins += winAmount;
      coinsChange = winAmount;
      stats['games_won'] = (stats['games_won'] ?? 0) + 1;
      stats['total_winnings'] = (stats['total_winnings'] ?? 0) + winAmount;
    } else {
      finalCoins -= betAmount;
      coinsChange = -betAmount;
      stats['games_lost'] = (stats['games_lost'] ?? 0) + 1;
      stats['total_losses'] = (stats['total_losses'] ?? 0) + betAmount;
    }

    stats['games_played'] = (stats['games_played'] ?? 0) + 1;

    // FIXED: Update user in Supabase
    try {
      final updateQuery = _supabase.from('users').update({
        'coins': finalCoins,
        'diamonds': finalDiamonds,
        'stats': stats,
        'updated_at': DateTime.now().toIso8601String(),
      });

      await updateQuery.eq('id', userId);

      debugPrint('✅ User updated successfully');
    } catch (e) {
      debugPrint('❌ Error updating user: $e');
      throw Exception('Failed to update user');
    }

    // Record coin transaction
    await _addCoinTransaction(
      userId: userId,
      amount: coinsChange.abs(),
      type: won ? 'win' : 'bet',
      description: won ? 'Game winning' : 'Game bet',
      gameType: gameType,
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

  Future<void> _addCoinTransaction({
    required String userId,
    required int amount,
    required String type,
    required String description,
    String? gameType,
  }) async {
    try {
      await _supabase.from('coin_transactions').insert({
        'user_id': userId,
        'amount': amount,
        'type': type,
        'description': description,
        'game_type': gameType,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('Error adding coin transaction: $e');
    }
  }

  Future<void> _saveGameHistory({
    required String userId,
    required String gameType,
    required int betAmount,
    required bool won,
    required int winAmount,
    Map<String, dynamic>? gameData,
  }) async {
    try {
      await _supabase.from('game_history').insert({
        'user_id': userId,
        'game_type': gameType,
        'bet_amount': betAmount,
        'won': won,
        'win_amount': winAmount,
        'game_data': gameData ?? {},
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('Error saving game history: $e');
    }
  }

  // ==================== GAME HISTORY - FIXED ====================

  /// Get user's game history - FIXED
  Future<List<Map<String, dynamic>>> getUserGameHistory({
    String? gameType,
    int limit = 50,
  }) async {
    final userId = _currentUserId;
    if (userId == null) return [];

    try {
      // বেস কোয়েরি
      var query = _supabase
          .from('game_history')
          .select()
          .eq('user_id', userId);

      // gameType থাকলে যোগ করুন
      if (gameType != null) {
        query = query.eq('game_type', gameType);
      }

      // order এবং limit যোগ করে execute
      final response = await query
          .order('created_at', ascending: false)
          .limit(limit);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error getting game history: $e');
      return [];
    }
  }

  /// Stream user's game history - FIXED
  Stream<List<Map<String, dynamic>>> streamUserGameHistory({String? gameType}) {
    final userId = _currentUserId;
    if (userId == null) return Stream.value([]);

    try {
      // Get stream without filters first
      final stream = _supabase
          .from('game_history')
          .stream(primaryKey: ['id']);

      // Apply manual filtering
      return stream.map((data) {
        // First filter by user_id
        var filtered = data.where((item) => item['user_id'] == userId).toList();

        // Then filter by gameType if provided
        if (gameType != null) {
          filtered = filtered.where((item) => item['game_type'] == gameType).toList();
        }

        // Sort manually
        filtered.sort((a, b) {
          final aTime = DateTime.parse(a['created_at'] ?? DateTime.now().toIso8601String());
          final bTime = DateTime.parse(b['created_at'] ?? DateTime.now().toIso8601String());
          return bTime.compareTo(aTime);
        });

        return filtered.map((item) => Map<String, dynamic>.from(item)).toList();
      });
    } catch (e) {
      debugPrint('Error streaming game history: $e');
      return Stream.value([]);
    }
  }

  // ==================== LEADERBOARD - FIXED ====================

  /// Get leaderboard for a specific game
  Stream<List<GameLeaderboardEntry>> getLeaderboard(String gameType) {
    try {
      // Get users with game stats
      final stream = _supabase
          .from('users')
          .stream(primaryKey: ['id']);

      return stream.map((data) {
        // Filter users with game stats and sort manually
        final usersWithStats = data.where((user) {
          final stats = user['stats'] as Map<String, dynamic>?;
          return stats != null && stats['games_played'] != null && stats['games_played'] > 0;
        }).toList();

        // Sort by total_winnings
        usersWithStats.sort((a, b) {
          final aStats = a['stats'] as Map<String, dynamic>? ?? {};
          final bStats = b['stats'] as Map<String, dynamic>? ?? {};
          final aWinnings = _toInt(aStats['total_winnings']);
          final bWinnings = _toInt(bStats['total_winnings']);
          return bWinnings.compareTo(aWinnings);
        });

        return usersWithStats.map((userData) {
          final stats = userData['stats'] as Map<String, dynamic>? ?? {};
          return GameLeaderboardEntry(
            userId: userData['id'] ?? '',
            username: userData['username'] ?? 'Unknown',
            photoURL: userData['avatar_url'],
            totalWinnings: _toInt(stats['total_winnings']),
            gamesPlayed: _toInt(stats['games_played']),
          );
        }).toList();
      });
    } catch (e) {
      debugPrint('Error getting leaderboard: $e');
      return Stream.value([]);
    }
  }

  /// Get overall game stats - FIXED
  Future<Map<String, dynamic>> getGameStats(String userId) async {
    try {
      // Get user's game history
      final response = await _supabase
          .from('game_history')
          .select()
          .eq('user_id', userId);

      final history = List<Map<String, dynamic>>.from(response);

      final totalGames = history.length;
      int wins = 0;
      int losses = 0;
      int totalBet = 0;
      int totalWin = 0;

      for (var game in history) {
        final won = game['won'] as bool? ?? false;
        final betAmount = _toInt(game['bet_amount']);
        final winAmount = _toInt(game['win_amount']);

        if (won) {
          wins++;
          totalWin += winAmount;
        } else {
          losses++;
        }
        totalBet += betAmount;
      }

      // Get stats by game type
      final Map<String, Map<String, dynamic>> gameTypeStats = {};
      for (var game in history) {
        final gameType = game['game_type'] ?? 'unknown';
        final won = game['won'] as bool? ?? false;
        final betAmount = _toInt(game['bet_amount']);
        final winAmount = _toInt(game['win_amount']);

        if (!gameTypeStats.containsKey(gameType)) {
          gameTypeStats[gameType] = {
            'games': 0,
            'wins': 0,
            'totalBet': 0,
            'totalWin': 0,
          };
        }
        gameTypeStats[gameType]!['games'] = (gameTypeStats[gameType]!['games'] as int) + 1;
        gameTypeStats[gameType]!['totalBet'] = (gameTypeStats[gameType]!['totalBet'] as int) + betAmount;
        if (won) {
          gameTypeStats[gameType]!['wins'] = (gameTypeStats[gameType]!['wins'] as int) + 1;
          gameTypeStats[gameType]!['totalWin'] = (gameTypeStats[gameType]!['totalWin'] as int) + winAmount;
        }
      }

      return {
        'totalGames': totalGames,
        'wins': wins,
        'losses': losses,
        'winRate': totalGames > 0 ? (wins / totalGames) : 0,
        'totalBet': totalBet,
        'totalWin': totalWin,
        'netProfit': totalWin - totalBet,
        'gameTypeStats': gameTypeStats,
      };
    } catch (e) {
      debugPrint('Error getting game stats: $e');
      return {};
    }
  }

  // ==================== ACTIVE GAMES - FIXED ====================

  /// Create a multiplayer game
  Future<String> createMultiplayerGame({
    required String gameType,
    required int betAmount,
    required int maxPlayers,
    Map<String, dynamic>? gameSettings,
  }) async {
    final userId = _currentUserId;
    if (userId == null) throw Exception('User not logged in');

    try {
      final gameData = {
        'game_type': gameType,
        'bet_amount': betAmount,
        'max_players': maxPlayers,
        'current_players': [userId],
        'status': 'waiting',
        'game_settings': gameSettings ?? {},
        'created_by': userId,
        'created_at': DateTime.now().toIso8601String(),
      };

      final response = await _supabase
          .from('active_games')
          .insert(gameData)
          .select()
          .single();

      return response['id'].toString();
    } catch (e) {
      debugPrint('Error creating multiplayer game: $e');
      throw Exception('Failed to create game');
    }
  }

  /// Join a multiplayer game - FIXED
  Future<bool> joinMultiplayerGame(String gameId) async {
    final userId = _currentUserId;
    if (userId == null) throw Exception('User not logged in');

    try {
      final game = await _supabase
          .from('active_games')
          .select()
          .eq('id', gameId)
          .single();

      if (game == null) throw Exception('Game not found');

      final currentPlayers = List<String>.from(game['current_players'] ?? []);
      if (currentPlayers.contains(userId)) {
        return true; // Already joined
      }

      if (currentPlayers.length >= (game['max_players'] ?? 2)) {
        throw Exception('Game is full');
      }

      currentPlayers.add(userId);

      // FIXED: আলাদাভাবে update
      final updateQuery = _supabase
          .from('active_games')
          .update({
        'current_players': currentPlayers,
        'updated_at': DateTime.now().toIso8601String(),
      });

      await updateQuery.eq('id', gameId);

      return true;
    } catch (e) {
      debugPrint('Error joining multiplayer game: $e');
      return false;
    }
  }

  /// Get available multiplayer games - FIXED
  Stream<List<Map<String, dynamic>>> getAvailableGames(String gameType) {
    try {
      final stream = _supabase
          .from('active_games')
          .stream(primaryKey: ['id']);

      return stream.map((data) {
        // Manual filtering
        final filtered = data.where((game) =>
        game['game_type'] == gameType &&
            game['status'] == 'waiting'
        ).toList();

        // Manual sorting
        filtered.sort((a, b) {
          final aTime = DateTime.parse(a['created_at'] ?? DateTime.now().toIso8601String());
          final bTime = DateTime.parse(b['created_at'] ?? DateTime.now().toIso8601String());
          return bTime.compareTo(aTime);
        });

        return filtered.map((game) => Map<String, dynamic>.from(game)).toList();
      });
    } catch (e) {
      debugPrint('Error getting available games: $e');
      return Stream.value([]);
    }
  }

  /// Start game - FIXED
  Future<bool> startGame(String gameId) async {
    try {
      final updateQuery = _supabase
          .from('active_games')
          .update({
        'status': 'playing',
        'started_at': DateTime.now().toIso8601String(),
      });

      await updateQuery.eq('id', gameId);

      return true;
    } catch (e) {
      debugPrint('Error starting game: $e');
      return false;
    }
  }

  /// End game - FIXED
  Future<bool> endGame(String gameId, Map<String, dynamic> result) async {
    try {
      final updateQuery = _supabase
          .from('active_games')
          .update({
        'status': 'ended',
        'ended_at': DateTime.now().toIso8601String(),
        'result': result,
      });

      await updateQuery.eq('id', gameId);

      return true;
    } catch (e) {
      debugPrint('Error ending game: $e');
      return false;
    }
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

  void seerCheck(String player) {}

  void vote(String player) {
    votes[player] = (votes[player] ?? 0) + 1;
  }

  bool nightActionsDone() {
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
    required this.totalWinnings,
    required this.gamesPlayed,
    this.photoURL,
  });
}