import 'package:flutter/material.dart';
import '../services/game_service.dart';
import '../services/payment_service.dart';

class GameProvider extends ChangeNotifier {
  final GameService _gameService = GameService();
  final PaymentService _paymentService = PaymentService();
  
  Map<String, dynamic> _gameState = {};
  bool _isPlaying = false;
  int _score = 0;
  String? _error;

  Map<String, dynamic> get gameState => _gameState;
  bool get isPlaying => _isPlaying;
  int get score => _score;
  String? get error => _error;

  void startGame(String gameType, int betAmount) {
    _gameState = {
      'type': gameType,
      'bet': betAmount,
      'status': 'started',
      'startTime': DateTime.now(),
    };
    _isPlaying = true;
    _score = 0;
    notifyListeners();
  }

  void updateGameState(Map<String, dynamic> state) {
    _gameState.addAll(state);
    notifyListeners();
  }

  Future<Map<String, dynamic>> playRoulette({
    required String userId,
    required int betAmount,
    required String betType,
    int? betNumber,
  }) async {
    try {
      // Check balance
      final hasBalance = await _paymentService.checkBalance(userId, betAmount);
      if (!hasBalance) throw Exception('Insufficient balance');

      // Play game
      final result = _gameService.playRoulette(
        betAmount: betAmount,
        betType: betType,
        betNumber: betNumber,
      );

      // Process result
      final processed = await _gameService.processGameResult(
        userId: userId,
        gameType: 'roulette',
        betAmount: betAmount,
        won: result.won,
        winAmount: result.winAmount,
        gameData: {
          'winningNumber': result.winningNumber,
          'betType': betType,
        },
      );

      if (result.won) {
        _score += result.winAmount;
      }

      notifyListeners();
      return {
        'result': result,
        'processed': processed,
      };
    } catch (e) {
      _error = e.toString();
      rethrow;
    }
  }

  Future<Map<String, dynamic>> playThreePatti({
    required String userId,
    required int betAmount,
    required List<int> playerCards,
    required List<int> opponentCards,
  }) async {
    try {
      final hasBalance = await _paymentService.checkBalance(userId, betAmount);
      if (!hasBalance) throw Exception('Insufficient balance');

      final result = _gameService.playThreePatti(
        betAmount: betAmount,
        playerCards: playerCards,
        opponentCards: opponentCards,
      );

      final processed = await _gameService.processGameResult(
        userId: userId,
        gameType: 'three_patti',
        betAmount: betAmount,
        won: result.won,
        winAmount: result.winAmount,
        gameData: {
          'playerRank': result.playerRank.type,
          'opponentRank': result.opponentRank.type,
        },
      );

      if (result.won) {
        _score += result.winAmount;
      }

      notifyListeners();
      return {
        'result': result,
        'processed': processed,
      };
    } catch (e) {
      _error = e.toString();
      rethrow;
    }
  }

  Future<Map<String, dynamic>> playGreedyCat({
    required String userId,
    required int betAmount,
    required int selectedBox,
  }) async {
    try {
      final hasBalance = await _paymentService.checkBalance(userId, betAmount);
      if (!hasBalance) throw Exception('Insufficient balance');

      final result = _gameService.playGreedyCat(
        betAmount: betAmount,
        selectedBox: selectedBox,
      );

      final processed = await _gameService.processGameResult(
        userId: userId,
        gameType: 'greedy_cat',
        betAmount: betAmount,
        won: result.won,
        winAmount: result.winAmount,
        gameData: {
          'winningBox': result.winningBox,
          'prize': result.prize,
        },
      );

      if (result.won) {
        _score += result.winAmount;
      }

      notifyListeners();
      return {
        'result': result,
        'processed': processed,
      };
    } catch (e) {
      _error = e.toString();
      rethrow;
    }
  }

  void endGame() {
    _gameState = {};
    _isPlaying = false;
    notifyListeners();
  }
}