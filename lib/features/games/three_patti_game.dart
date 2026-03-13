import 'package:flutter/material.dart';
import '../../core/di/service_locator.dart';
import '../../core/services/game_service.dart';
import '../../core/services/payment_service.dart';
import '../../mixins/loading_mixin.dart';
import '../../mixins/toast_mixin.dart';
import '../../mixins/dialog_mixin.dart';
import '../../widgets/common/custom_button.dart';

class ThreePattiGame extends StatefulWidget {
  const ThreePattiGame({Key? key}) : super(key: key);

  @override
  State<ThreePattiGame> createState() => _ThreePattiGameState();
}

class _ThreePattiGameState extends State<ThreePattiGame> 
    with LoadingMixin, ToastMixin, DialogMixin {
  
  final GameService _gameService = ServiceLocator().get<GameService>();
  final PaymentService _paymentService = ServiceLocator().get<PaymentService>();
  
  int _betAmount = 100;
  List<int> _playerCards = <int>[];
  List<int> _opponentCards = <int>[];
  bool _gameStarted = false;
  bool _gameEnded = false;
  int _playerCoins = 10000;

  @override
  void initState() {
    super.initState();
    _loadUserCoins();
  }

  Future<void> _loadUserCoins() async {
    // Load user coins from service
  }

  Future<void> _startGame() async {
    if (_playerCoins < _betAmount) {
      showError('Insufficient coins');
      return;
    }

    setState(() {
      _gameStarted = true;
      _gameEnded = false;
      _playerCards = _generateCards();
      _opponentCards = _generateCards();
    });
  }

  List<int> _generateCards() {
    // Generate 3 random cards (0-51)
    var cards = <int><int>[];
    for (var i = 0; i < 3; i++) {
      cards.add(cards.toSet().length); // Simplified - should be unique
    }
    return cards;
  }

  Future<void> _playGame() async {
    await runWithLoading(() async {
      final ThreePattiResult result = _gameService.playThreePatti(
        betAmount: _betAmount,
        playerCards: _playerCards,
        opponentCards: _opponentCards,
      );

      setState(() {
        _gameEnded = true;
        if (result.won) {
          _playerCoins += result.winAmount;
          showSuccess('You won ${result.winAmount} coins!');
        } else if (!result.draw) {
          _playerCoins -= _betAmount;
          showError('You lost $_betAmount coins');
        } else {
          showInfo("It's a draw!");
        }
      });

      // Show result dialog
      await showResultDialog(result);
    });
  }

  Future<void> showResultDialog(dynamic result) async {
    showInfoDialog(
      context,
      title: result.won ? '🎉 You Won!' : '😢 You Lost',
      message: result.won 
          ? 'You won ${result.winAmount} coins!\n\n${_getRankDescription(result.playerRank)}'
          : 'Better luck next time!\n\nYour hand: ${_getRankDescription(result.playerRank)}\nOpponent hand: ${_getRankDescription(result.opponentRank)}',
    );
  }

  String _getRankDescription(dynamic rank) {
    switch (rank.type) {
      case 'trail': return 'Trail (Three of a kind)';
      case 'pureSequence': return 'Pure Sequence';
      case 'sequence': return 'Sequence';
      case 'color': return 'Color (Same suit)';
      case 'pair': return 'Pair';
      default: return 'High Card';
    }
  }

  String _getCardSymbol(int card) {
    final List<String> suits = <String>['♠️', '♥️', '♦️', '♣️'];
    final List<String> ranks = <String>['A', '2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K'];
    return '${ranks[card ~/ 4]}${suits[card % 4]}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('3 Patti'),
        backgroundColor: Colors.green,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <>[Colors.green.shade900, Colors.green.shade700],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: <>[
              // Coins Display
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <>[
                    const Text(
                      'Your Coins:',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    Text(
                      '$_playerCoins',
                      style: const TextStyle(
                        color: Colors.yellow,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              if (!_gameStarted) ...<>[
                // Bet Selection
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <>[
                        const Text(
                          'Select Bet Amount',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Wrap(
                          spacing: 10,
                          children: <int>[100, 500, 1000, 5000, 10000].map((int amount) {
                            return FilterChip(
                              label: Text('$amount'),
                              selected: _betAmount == amount,
                              onSelected: (selected) {
                                setState(() {
                                  _betAmount = amount;
                                });
                              },
                              backgroundColor: Colors.white.withOpacity(0.1),
                              selectedColor: Colors.green,
                              labelStyle: const TextStyle(color: Colors.white),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 30),
                        CustomButton(
                          text: 'Start Game',
                          onPressed: _startGame,
                          color: Colors.green,
                        ),
                      ],
                    ),
                  ),
                ),
              ] else ...<>[
                // Game Area
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <>[
                      // Opponent Cards
                      Column(
                        children: <>[
                          const Text(
                            'Opponent',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: _opponentCards.map((int card) {
                              return Container(
                                width: 80,
                                height: 100,
                                margin: const EdgeInsets.symmetric(horizontal: 5),
                                decoration: BoxDecoration(
                                  color: _gameEnded ? Colors.white : Colors.blue,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.white),
                                ),
                                child: Center(
                                  child: _gameEnded
                                      ? Text(
                                          _getCardSymbol(card),
                                          style: TextStyle(
                                            fontSize: 20,
                                            color: card % 4 == 1 || card % 4 == 2 
                                                ? Colors.red 
                                                : Colors.black,
                                          ),
                                        )
                                      : const Icon(
                                          Icons.help,
                                          color: Colors.white,
                                          size: 40,
                                        ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),

                      // VS
                      const Text(
                        'VS',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      // Player Cards
                      Column(
                        children: <>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: _playerCards.map((int card) {
                              return Container(
                                width: 80,
                                height: 100,
                                margin: const EdgeInsets.symmetric(horizontal: 5),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.white),
                                ),
                                child: Center(
                                  child: Text(
                                    _getCardSymbol(card),
                                    style: TextStyle(
                                      fontSize: 20,
                                      color: card % 4 == 1 || card % 4 == 2 
                                          ? Colors.red 
                                          : Colors.black,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'You',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),

                      if (!_gameEnded)
                        CustomButton(
                          text: 'Play!',
                          onPressed: _playGame,
                          color: Colors.green,
                        )
                      else
                        CustomButton(
                          text: 'Play Again',
                          onPressed: _startGame,
                          color: Colors.green,
                        ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}