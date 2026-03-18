import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

// Game screens
import 'roulette_game.dart';
import 'three_patti_game.dart';
import 'ludo_game.dart';
import 'carrom_game.dart';
import 'greedy_cat_game.dart';
import 'werewolf_game.dart';
import 'trivia_game.dart';
import 'pictionary_game.dart';
import 'chess_game.dart';
import 'truth_or_dare_game.dart';

class GamesScreen extends StatefulWidget {
  const GamesScreen({super.key});

  @override
  State<GamesScreen> createState() => _GamesScreenState();
}

class _GamesScreenState extends State<GamesScreen> {
  final List<Map<String, dynamic>> _games = [
    {
      'id': 'roulette',
      'name': 'Roulette',
      'icon': Icons.casino,
      'color': Colors.red,
      'players': 1250,
      'minBet': 10,
      'description': 'Spin the wheel and win big!',
      'route': '/game/roulette',
    },
    {
      'id': 'three_patti',
      'name': 'Three Patti',
      'icon': Icons.style,
      'color': Colors.green,
      'players': 980,
      'minBet': 20,
      'description': 'Popular card game',
      'route': '/game/three-patti',
    },
    {
      'id': 'ludo',
      'name': 'Ludo',
      'icon': Icons.sports_esports,
      'color': Colors.blue,
      'players': 750,
      'minBet': 5,
      'description': 'Classic board game',
      'route': '/game/ludo',
    },
    {
      'id': 'carrom',
      'name': 'Carrom',
      'icon': Icons.games,
      'color': Colors.orange,
      'players': 540,
      'minBet': 15,
      'description': 'Strike and score!',
      'route': '/game/carrom',
    },
    {
      'id': 'greedy_cat',
      'name': 'Greedy Cat',
      'icon': Icons.pets,
      'color': Colors.purple,
      'players': 320,
      'minBet': 25,
      'description': 'Feed the cat!',
      'route': '/game/greedy-cat',
    },
    {
      'id': 'werewolf',
      'name': 'Werewolf',
      'icon': Icons.whatshot,
      'color': Colors.teal,
      'players': 210,
      'minBet': 30,
      'description': 'Find the werewolf',
      'route': '/game/werewolf',
    },
    {
      'id': 'trivia',
      'name': 'Trivia',
      'icon': Icons.quiz,
      'color': Colors.amber,
      'players': 180,
      'minBet': 15,
      'description': 'Test your knowledge',
      'route': '/game/trivia',
    },
    {
      'id': 'pictionary',
      'name': 'Pictionary',
      'icon': Icons.brush,
      'color': Colors.pink,
      'players': 150,
      'minBet': 20,
      'description': 'Draw and guess',
      'route': '/game/pictionary',
    },
    {
      'id': 'chess',
      'name': 'Chess',
      'icon': Icons.psychology,
      'color': Colors.brown,
      'players': 120,
      'minBet': 25,
      'description': 'Strategic chess game',
      'route': '/game/chess',
    },
    {
      'id': 'truth_or_dare',
      'name': 'Truth or Dare',
      'icon': Icons.help,
      'color': Colors.indigo,
      'players': 200,
      'minBet': 10,
      'description': 'Fun party game',
      'route': '/game/truth-or-dare',
    },
  ];

  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> get _filteredGames {
    if (_searchQuery.isEmpty) return _games;
    return _games.where((game) =>
    game['name'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
        game['description'].toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Games'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: _filteredGames.isEmpty
                ? _buildEmptyState()
                : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.8,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: _filteredGames.length,
              itemBuilder: (context, index) {
                final game = _filteredGames[index];
                return _buildGameCard(game);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: const InputDecoration(
                hintText: 'Search games...',
                border: InputBorder.none,
              ),
            ),
          ),
          if (_searchQuery.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear, color: Colors.grey),
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _searchQuery = '';
                });
              },
            ),
        ],
      ),
    );
  }

  Widget _buildGameCard(Map<String, dynamic> game) {
    return GestureDetector(
      onTap: () {
        _navigateToGame(context, game);
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              (game['color'] as Color).withOpacity(0.8),
              (game['color'] as Color).withOpacity(0.4),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: (game['color'] as Color).withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              game['icon'],
              size: 50,
              color: Colors.white,
            ),
            const SizedBox(height: 12),
            Text(
              game['name'],
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${game['players']} playing',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Min: ₹${game['minBet']}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.games_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No games found',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try a different search term',
            style: TextStyle(
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToGame(BuildContext context, Map<String, dynamic> game) {
    final String route = game['route'] as String;
    final int minBet = game['minBet'] as int;
    final String gameId = game['id'] as String;

    // Navigate with appropriate parameters based on game type
    switch (game['id']) {
      case 'roulette':
        Navigator.pushNamed(
          context,
          route,
          arguments: {
            'betAmount': minBet,
          },
        );
        break;

      case 'three_patti':
      case 'ludo':
      case 'carrom':
      case 'greedy_cat':
      case 'werewolf':
      case 'trivia':
      case 'pictionary':
      case 'chess':
      case 'truth_or_dare':
        Navigator.pushNamed(
          context,
          route,
          arguments: {
            'gameId': gameId,
          },
        );
        break;

      default:
        Navigator.pushNamed(context, route);
    }
  }
}