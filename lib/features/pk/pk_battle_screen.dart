import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../core/models/room_model.dart';

class PKBattleScreen extends StatefulWidget {
  final String roomId;
  final String opponentRoomId;

  const PKBattleScreen({
    super.key,
    required this.roomId,
    required this.opponentRoomId,
  });

  @override
  State<PKBattleScreen> createState() => _PKBattleScreenState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('roomId', roomId));
    properties.add(StringProperty('opponentRoomId', opponentRoomId));
  }
}

class _PKBattleScreenState extends State<PKBattleScreen> {
  int _myScore = 0;
  int _opponentScore = 0;
  bool _isBattleActive = true;
  String _battleStatus = 'ongoing'; // ongoing, completed, cancelled

  @override
  void initState() {
    super.initState();
    _initializeBattle();
  }

  void _initializeBattle() {
    // Initialize battle logic here
    debugPrint('PK Battle started between ${widget.roomId} and ${widget.opponentRoomId}');
  }

  void _updateScore(bool isMyScore) {
    setState(() {
      if (isMyScore) {
        _myScore++;
      } else {
        _opponentScore++;
      }
    });
  }

  void _endBattle() {
    setState(() {
      _isBattleActive = false;
      _battleStatus = 'completed';
    });

    // Show battle results
    _showBattleResults();
  }

  void _showBattleResults() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Battle Results'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Your Score: $_myScore'),
            Text('Opponent Score: $_opponentScore'),
            const SizedBox(height: 16),
            Text(
              _myScore > _opponentScore
                  ? '🎉 You Won! 🎉'
                  : _myScore < _opponentScore
                  ? '😢 You Lost!'
                  : '🤝 It\'s a Draw!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _myScore > _opponentScore
                    ? Colors.green
                    : _myScore < _opponentScore
                    ? Colors.red
                    : Colors.orange,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back
            },
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PK Battle'),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        actions: [
          if (_isBattleActive)
            IconButton(
              icon: const Icon(Icons.stop),
              onPressed: _endBattle,
            ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.deepPurple, Colors.purple],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Battle Status
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: _isBattleActive ? Colors.green : Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _battleStatus.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Score Board
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // My Score
                    Column(
                      children: [
                        const CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.blue,
                          child: Icon(
                            Icons.person,
                            size: 30,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'You',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$_myScore',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    // VS
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Text(
                          'VS',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    // Opponent Score
                    Column(
                      children: [
                        const CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.red,
                          child: Icon(
                            Icons.person_outline,
                            size: 30,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Room ${widget.opponentRoomId.substring(0, 4)}...',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$_opponentScore',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Battle Arena
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  padding: const EdgeInsets.all(16),
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    _buildBattleCard(
                      'Gift Battle',
                      Icons.card_giftcard,
                          () => _updateScore(true),
                    ),
                    _buildBattleCard(
                      'Chat Battle',
                      Icons.chat,
                          () => _updateScore(true),
                    ),
                    _buildBattleCard(
                      'Game Battle',
                      Icons.games,
                          () => _updateScore(true),
                    ),
                    _buildBattleCard(
                      'Voice Battle',
                      Icons.mic,
                          () => _updateScore(true),
                    ),
                  ],
                ),
              ),

              // Battle Timer (if active)
              if (_isBattleActive)
                Container(
                  padding: const EdgeInsets.all(16),
                  child: const LinearProgressIndicator(
                    value: 0.7,
                    backgroundColor: Colors.white24,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBattleCard(String title, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: _isBattleActive ? onTap : null,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(_isBattleActive ? 0.15 : 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withOpacity(_isBattleActive ? 0.3 : 0.1),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 40,
              color: Colors.white.withOpacity(_isBattleActive ? 1 : 0.5),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                color: Colors.white.withOpacity(_isBattleActive ? 1 : 0.5),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}