import 'package:flutter/material.dart';
import '../../core/di/service_locator.dart';
import '../../core/services/game_service.dart';
import '../../mixins/loading_mixin.dart';
import '../../mixins/toast_mixin.dart';
import '../../mixins/dialog_mixin.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/animation/pulse_animation.dart';

class GreedyCatGame extends StatefulWidget {
  const GreedyCatGame({super.key});

  @override
  State<GreedyCatGame> createState() => _GreedyCatGameState();
}

class _GreedyCatGameState extends State<GreedyCatGame> 
    with LoadingMixin, ToastMixin, DialogMixin {
  
  final GameService _gameService = ServiceLocator().get<GameService>();
  
  int _betAmount = 100;
  int? _selectedBox;
  int? _winningBox;
  bool _gameStarted = false;
  int _playerCoins = 10000;
  bool _isRevealing = false;

  final List<Color> _boxColors = List.generate(10, (_) => Colors.orange);

  @override
  void initState() {
    super.initState();
    _loadUserCoins();
  }

  Future<void> _loadUserCoins() async {
    // Load user coins from service
  }

  void _startGame() {
    if (_playerCoins < _betAmount) {
      showError('Insufficient coins');
      return;
    }

    setState(() {
      _gameStarted = true;
      _selectedBox = null;
      _winningBox = null;
      _isRevealing = false;
      for (var i = 0; i < 10; i++) {
        _boxColors[i] = Colors.orange;
      }
    });
  }

  Future<void> _selectBox(int index) async {
    if (_isRevealing || _selectedBox != null) return;

    setState(() {
      _selectedBox = index;
    });

    await runWithLoading(() async {
      setState(() {
        _isRevealing = true;
      });

      // Simulate thinking
      await Future.delayed(const Duration(seconds: 1));

      final GreedyCatResult result = _gameService.playGreedyCat(
        betAmount: _betAmount,
        selectedBox: index + 1,
      );

      setState(() {
        _winningBox = result.winningBox - 1;
        _isRevealing = false;
        
        // Reveal all boxes
        for (var i = 0; i < 10; i++) {
          if (i == _winningBox) {
            _boxColors[i] = Colors.green;
          } else if (i == index && !result.won) {
            _boxColors[i] = Colors.red;
          } else {
            _boxColors[i] = Colors.grey;
          }
        }

        if (result.won) {
          _playerCoins += result.winAmount;
        } else {
          _playerCoins -= _betAmount;
        }
      });

      // Show result dialog
      await showResultDialog(result);
    });
  }

  Future<void> showResultDialog(dynamic result) async {
    String message;
    if (result.won) {
      message = 'You won ${result.winAmount} coins!\nPrize: ${result.prize}';
    } else {
      message = 'Better luck next time!\nWinning box was ${result.winningBox}';
    }

    showInfoDialog(
      context,
      title: result.won ? '🎉 You Won!' : '😢 You Lost',
      message: message,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Greedy Cat'),
        backgroundColor: Colors.orange,
      ),
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <>[Colors.orange.shade900, Colors.orange.shade700],
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
                  color: Colors.white.withValues(alpha: 0.1),
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

              // Cat Image
              const SizedBox(height: 20),
              const Text(
                '😺',
                style: TextStyle(fontSize: 80),
              ),
              const Text(
                'Feed the Greedy Cat!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

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
                          children: <int>[100, 500, 1000, 5000].map((int amount) {
                            return FilterChip(
                              label: Text('$amount'),
                              selected: _betAmount == amount,
                              onSelected: (bool selected) {
                                setState(() {
                                  _betAmount = amount;
                                });
                              },
                              backgroundColor: Colors.white.withValues(alpha: 0.1),
                              selectedColor: Colors.orange,
                              labelStyle: const TextStyle(color: Colors.white),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 30),
                        CustomButton(
                          text: 'Start Game',
                          onPressed: _startGame,
                          color: Colors.orange,
                        ),
                      ],
                    ),
                  ),
                ),
              ] else ...<>[
                // Game Grid
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 5,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: 10,
                    itemBuilder: (BuildContext context, int index) {
                      return _buildBox(index);
                    },
                  ),
                ),

                // Play Again Button
                if (_selectedBox != null)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: CustomButton(
                      text: 'Play Again',
                      onPressed: _startGame,
                      color: Colors.orange,
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBox(int index) {
    final var isSelected = _selectedBox == index;
    final bool isWinning = _winningBox == index;

    return GestureDetector(
      onTap: _isRevealing || _selectedBox != null 
          ? null 
          : () => _selectBox(index),
      child: PulseAnimation(
        animate: isSelected && !_isRevealing,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            color: _boxColors[index],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected && !_isRevealing ? Colors.white : Colors.transparent,
              width: 3,
            ),
          ),
          child: Center(
            child: _isRevealing && isSelected
                ? const SizedBox(
                    width: 30,
                    height: 30,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : (_selectedBox != null
                    ? Text(
                        '${index + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : const Icon(
                        Icons.question_mark,
                        color: Colors.white,
                        size: 30,
                      )),
          ),
        ),
      ),
    );
  }
}