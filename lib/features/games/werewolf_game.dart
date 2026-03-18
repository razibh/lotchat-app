import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../../core/constants/app_colors.dart';
import '../../core/widgets/gradient_background.dart';
import '../../core/widgets/neumorphic_button.dart';

class WerewolfGame extends StatefulWidget {
  final String gameId;
  final Map<String, dynamic>? gameData;

  const WerewolfGame({
    required this.gameId,
    this.gameData,
    super.key,
  });

  @override
  State<WerewolfGame> createState() => _WerewolfGameState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('gameId', gameId));
    properties.add(DiagnosticsProperty<Map<String, dynamic>?>('gameData', gameData));
  }
}

class _WerewolfGameState extends State<WerewolfGame> {
  GamePhase currentPhase = GamePhase.night;
  String playerRole = 'Villager';
  List<Player> players = [];
  bool isAlive = true;
  int nightCount = 0;

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  void _initializeGame() {
    // Simulate game initialization
    players = [
      Player(name: 'You', role: 'Villager', isAlive: true, isWerewolf: false),
      Player(name: 'Player 2', role: 'Werewolf', isAlive: true, isWerewolf: true),
      Player(name: 'Player 3', role: 'Seer', isAlive: true, isWerewolf: false),
      Player(name: 'Player 4', role: 'Villager', isAlive: true, isWerewolf: false),
      Player(name: 'Player 5', role: 'Witch', isAlive: true, isWerewolf: false),
      Player(name: 'Player 6', role: 'Villager', isAlive: true, isWerewolf: false),
      Player(name: 'Player 7', role: 'Werewolf', isAlive: true, isWerewolf: true),
      Player(name: 'Player 8', role: 'Villager', isAlive: true, isWerewolf: false),
    ];

    // Set player role randomly
    playerRole = ['Villager', 'Werewolf', 'Seer', 'Witch'][DateTime.now().millisecond % 4];
  }

  void _nextPhase() {
    setState(() {
      if (currentPhase == GamePhase.night) {
        currentPhase = GamePhase.discussion;
        nightCount++;
      } else if (currentPhase == GamePhase.discussion) {
        currentPhase = GamePhase.voting;
      } else if (currentPhase == GamePhase.voting) {
        currentPhase = GamePhase.night;
        _simulateNightKill();
      }
    });
  }

  void _simulateNightKill() {
    // Simulate a random player being killed at night
    final alivePlayers = players.where((p) => p.isAlive).toList();
    if (alivePlayers.length > 1) {
      final killedIndex = DateTime.now().millisecond % alivePlayers.length;
      final killedPlayer = alivePlayers[killedIndex];

      if (killedPlayer.name == 'You') {
        setState(() {
          isAlive = false;
        });
      }

      setState(() {
        final playerIndex = players.indexWhere((p) => p.name == killedPlayer.name);
        if (playerIndex != -1) {
          players[playerIndex] = players[playerIndex].copyWith(isAlive: false);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildGameStatus(),
              _buildPlayerInfo(),
              Expanded(
                child: _buildPlayersList(),
              ),
              _buildPhaseInfo(),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          Text(
            'Werewolf',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildGameStatus() {
    Color phaseColor;
    String phaseText;

    switch (currentPhase) {
      case GamePhase.night:
        phaseColor = Colors.deepPurple;
        phaseText = '🌙 Night ${nightCount + 1}';
        break;
      case GamePhase.discussion:
        phaseColor = Colors.orange;
        phaseText = '💬 Discussion';
        break;
      case GamePhase.voting:
        phaseColor = Colors.red;
        phaseText = '🗳️ Voting';
        break;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: phaseColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: phaseColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            phaseText,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: isAlive ? Colors.green : Colors.red,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              isAlive ? 'Alive' : 'Dead',
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerInfo() {
    final aliveCount = players.where((p) => p.isAlive).length;
    final werewolfCount = players.where((p) => p.isWerewolf && p.isAlive).length;

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              const Text('Your Role', style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: _getRoleColor(playerRole),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  playerRole,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          Column(
            children: [
              const Text('Alive', style: TextStyle(color: Colors.white70)),
              Text(
                '$aliveCount/${players.length}',
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Column(
            children: [
              const Text('Werewolves', style: TextStyle(color: Colors.white70)),
              Text(
                '$werewolfCount',
                style: const TextStyle(color: Colors.red, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'Werewolf':
        return Colors.red;
      case 'Seer':
        return Colors.blue;
      case 'Witch':
        return Colors.purple;
      default:
        return Colors.green;
    }
  }

  Widget _buildPlayersList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: players.length,
      itemBuilder: (context, index) {
        final player = players[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: player.isAlive
                ? Colors.white.withOpacity(0.1)
                : Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: player.name == 'You'
                  ? AppColors.accentPurple
                  : Colors.transparent,
              width: 2,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _getRoleColor(player.role).withOpacity(0.3),
                ),
                child: Center(
                  child: Text(
                    player.name[0],
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      player.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (player.name == 'You' || !player.isAlive)
                      Text(
                        player.role,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),
              if (!player.isAlive)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'DEAD',
                    style: TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPhaseInfo() {
    String phaseDescription;
    IconData phaseIcon;

    switch (currentPhase) {
      case GamePhase.night:
        phaseDescription = 'Werewolves choose a victim';
        phaseIcon = Icons.nightlight_round;
        break;
      case GamePhase.discussion:
        phaseDescription = 'Discuss and find the werewolves';
        phaseIcon = Icons.chat;
        break;
      case GamePhase.voting:
        phaseDescription = 'Vote for who to eliminate';
        phaseIcon = Icons.how_to_vote;
        break;
    }

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(phaseIcon, color: Colors.white70, size: 20),
          const SizedBox(width: 8),
          Text(
            phaseDescription,
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: NeumorphicButton(
              onPressed: isAlive ? _nextPhase : null,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: Text(
                    _getButtonText(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getButtonText() {
    if (!isAlive) return 'You are dead';

    switch (currentPhase) {
      case GamePhase.night:
        return 'End Night';
      case GamePhase.discussion:
        return 'End Discussion';
      case GamePhase.voting:
        return 'Vote';
    }
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(EnumProperty<GamePhase>('currentPhase', currentPhase));
    properties.add(StringProperty('playerRole', playerRole));
    properties.add(IterableProperty<Player>('players', players));
    properties.add(DiagnosticsProperty<bool>('isAlive', isAlive));
    properties.add(IntProperty('nightCount', nightCount));
  }
}

enum GamePhase {
  night,
  discussion,
  voting,
}

class Player {
  final String name;
  final String role;
  final bool isAlive;
  final bool isWerewolf;

  Player({
    required this.name,
    required this.role,
    required this.isAlive,
    required this.isWerewolf,
  });

  Player copyWith({
    String? name,
    String? role,
    bool? isAlive,
    bool? isWerewolf,
  }) {
    return Player(
      name: name ?? this.name,
      role: role ?? this.role,
      isAlive: isAlive ?? this.isAlive,
      isWerewolf: isWerewolf ?? this.isWerewolf,
    );
  }
}