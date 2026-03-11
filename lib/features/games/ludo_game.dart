import 'package:flutter/material.dart';
import '../../core/di/service_locator.dart';
import '../../core/services/game_service.dart';
import '../../mixins/loading_mixin.dart';
import '../../mixins/toast_mixin.dart';
import '../../widgets/common/custom_button.dart';

class LudoGame extends StatefulWidget {
  const LudoGame({Key? key}) : super(key: key);

  @override
  State<LudoGame> createState() => _LudoGameState();
}

class _LudoGameState extends State<LudoGame> with LoadingMixin, ToastMixin {
  
  final _gameService = ServiceLocator().get<GameService>();
  
  int _betAmount = 100;
  int _playerCoins = 10000;
  bool _gameStarted = false;
  int _diceRoll = 0;
  int _playerPosition = 0;
  int _opponentPosition = 0;
  bool _isPlayerTurn = true;
  List<Map<String, dynamic>> _playerPieces = [];
  List<Map<String, dynamic>> _opponentPieces = [];

  @override
  void initState() {
    super.initState();
    _initGame();
  }

  void _initGame() {
    _playerPieces = List.generate(4, (index) => {
      'position': -1, // -1 means not started
      'isHome': false,
      'id': index,
    });
    
    _opponentPieces = List.generate(4, (index) => {
      'position': -1,
      'isHome': false,
      'id': index,
    });
  }

  void _startGame() {
    if (_playerCoins < _betAmount) {
      showError('Insufficient coins');
      return;
    }

    setState(() {
      _gameStarted = true;
      _initGame();
      _isPlayerTurn = true;
    });
  }

  void _rollDice() {
    setState(() {
      _diceRoll = 1 + (DateTime.now().millisecondsSinceEpoch % 6).toInt();
    });

    // Check if can move any piece
    bool canMove = false;
    for (var piece in _playerPieces) {
      if (piece['position'] == -1 && _diceRoll == 6) {
        canMove = true;
        break;
      } else if (piece['position'] >= 0 && !piece['isHome']) {
        canMove = true;
        break;
      }
    }

    if (!canMove) {
      // Switch turn
      setState(() {
        _isPlayerTurn = false;
      });
      _opponentTurn();
    }
  }

  void _movePiece(int pieceIndex) {
    if (!_isPlayerTurn) return;

    var piece = _playerPieces[pieceIndex];
    
    if (piece['position'] == -1) {
      // Start piece
      if (_diceRoll == 6) {
        setState(() {
          _playerPieces[pieceIndex]['position'] = 0;
          _diceRoll = 0;
        });
      }
    } else if (!piece['isHome']) {
      // Move piece
      int newPos = piece['position'] + _diceRoll;
      
      if (newPos >= 57) {
        // Reached home
        setState(() {
          _playerPieces[pieceIndex]['isHome'] = true;
          _playerPieces[pieceIndex]['position'] = 57;
          _diceRoll = 0;
        });
      } else {
        setState(() {
          _playerPieces[pieceIndex]['position'] = newPos;
          _diceRoll = 0;
        });
      }

      // Check win condition
      if (_playerPieces.every((p) => p['isHome'])) {
        _gameWon();
      }
    }

    // Switch turn if no extra turn
    if (_diceRoll != 6) {
      setState(() {
        _isPlayerTurn = false;
      });
      _opponentTurn();
    }
  }

  Future<void> _opponentTurn() async {
    await Future.delayed(const Duration(seconds: 1));
    
    if (!mounted) return;

    setState(() {
      _diceRoll = 1 + (DateTime.now().millisecondsSinceEpoch % 6).toInt();
    });

    // Simple AI for opponent
    if (_diceRoll == 6) {
      // Start a piece if possible
      for (int i = 0; i < _opponentPieces.length; i++) {
        if (_opponentPieces[i]['position'] == -1) {
          setState(() {
            _opponentPieces[i]['position'] = 0;
          });
          break;
        }
      }
    } else {
      // Move a random piece
      var movablePieces = _opponentPieces.where((p) => 
          p['position'] >= 0 && !p['isHome']).toList();
      
      if (movablePieces.isNotEmpty) {
        var piece = movablePieces[DateTime.now().millisecondsSinceEpoch % movablePieces.length];
        int index = _opponentPieces.indexOf(piece);
        
        int newPos = piece['position'] + _diceRoll;
        if (newPos >= 57) {
          setState(() {
            _opponentPieces[index]['isHome'] = true;
            _opponentPieces[index]['position'] = 57;
          });
        } else {
          setState(() {
            _opponentPieces[index]['position'] = newPos;
          });
        }
      }
    }

    setState(() {
      _isPlayerTurn = true;
      _diceRoll = 0;
    });
  }

  void _gameWon() {
    showInfoDialog(
      context,
      title: '🎉 You Won!',
      message: 'Congratulations! You won $_betAmount coins!',
    );
    
    setState(() {
      _playerCoins += _betAmount * 2;
      _gameStarted = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ludo'),
        backgroundColor: Colors.blue,
      ),
      body: Container(
        color: Colors.amber.shade100,
        child: SafeArea(
          child: Column(
            children: [
              // Game Info
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.blue,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Your Coins:',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    Text(
                      '$_playerCoins',
                      style: const TextStyle(
                        color: Colors.yellow,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Bet: $_betAmount',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),

              // Ludo Board
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Opponent Home
                      Container(
                        height: 60,
                        color: Colors.red.shade100,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: _opponentPieces.map((piece) {
                            return Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: piece['isHome'] ? Colors.green : Colors.red,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                            );
                          }).toList(),
                        ),
                      ),

                      // Board Center
                      Expanded(
                        child: Container(
                          color: Colors.amber.shade50,
                          child: Center(
                            child: _diceRoll > 0
                                ? Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          blurRadius: 5,
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Text(
                                        '$_diceRoll',
                                        style: const TextStyle(
                                          fontSize: 40,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  )
                                : const Text('LUDO'),
                          ),
                        ),
                      ),

                      // Player Home
                      Container(
                        height: 60,
                        color: Colors.green.shade100,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: _playerPieces.map((piece) {
                            return GestureDetector(
                              onTap: _isPlayerTurn && _diceRoll > 0
                                  ? () => _movePiece(_playerPieces.indexOf(piece))
                                  : null,
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: piece['isHome'] ? Colors.green : Colors.blue,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: piece['position'] >= 0 && !piece['isHome']
                                        ? Colors.yellow
                                        : Colors.white,
                                    width: 2,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Controls
              if (!_gameStarted)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Wrap(
                        spacing: 10,
                        children: [100, 500, 1000].map((amount) {
                          return FilterChip(
                            label: Text('$amount'),
                            selected: _betAmount == amount,
                            onSelected: (selected) {
                              setState(() {
                                _betAmount = amount;
                              });
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                      CustomButton(
                        text: 'Start Game',
                        onPressed: _startGame,
                        color: Colors.blue,
                      ),
                    ],
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          text: _isPlayerTurn ? 'Roll Dice' : 'Opponent\'s Turn',
                          onPressed: _isPlayerTurn ? _rollDice : null,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}