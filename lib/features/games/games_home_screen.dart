import 'package:flutter/material.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/animation/fade_animation.dart';
import '../../core/constants/color_constants.dart';

class GamesHomeScreen extends StatelessWidget {
  const GamesHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Games'),
        backgroundColor: AppColors.primary,
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(16),
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.9,
        children: [
          _buildGameCard(
            context,
            'Roulette',
            '🎰',
            Colors.red,
            () => Navigator.pushNamed(context, '/game/roulette'),
          ),
          _buildGameCard(
            context,
            '3 Patti',
            '🃏',
            Colors.green,
            () => Navigator.pushNamed(context, '/game/three-patti'),
          ),
          _buildGameCard(
            context,
            'Ludo',
            '🎲',
            Colors.blue,
            () => Navigator.pushNamed(context, '/game/ludo'),
          ),
          _buildGameCard(
            context,
            'Carrom',
            '🎯',
            Colors.orange,
            () => Navigator.pushNamed(context, '/game/carrom'),
          ),
          _buildGameCard(
            context,
            'Greedy Cat',
            '🐱',
            Colors.purple,
            () => Navigator.pushNamed(context, '/game/greedy-cat'),
          ),
          _buildGameCard(
            context,
            'Werewolf',
            '🐺',
            Colors.brown,
            () => Navigator.pushNamed(context, '/game/werewolf'),
          ),
          _buildGameCard(
            context,
            'Trivia',
            '❓',
            Colors.teal,
            () => Navigator.pushNamed(context, '/game/trivia'),
          ),
          _buildGameCard(
            context,
            'Pictionary',
            '🎨',
            Colors.pink,
            () => Navigator.pushNamed(context, '/game/pictionary'),
          ),
          _buildGameCard(
            context,
            'Chess',
            '♟️',
            Colors.indigo,
            () => Navigator.pushNamed(context, '/game/chess'),
          ),
          _buildGameCard(
            context,
            'Truth or Dare',
            '🎭',
            Colors.amber,
            () => Navigator.pushNamed(context, '/game/truth-or-dare'),
          ),
        ],
      ),
    );
  }

  Widget _buildGameCard(
    BuildContext context,
    String title,
    String emoji,
    Color color,
    VoidCallback onTap,
  ) {
    return FadeAnimation(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color, color.withOpacity(0.7)],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                emoji,
                style: const TextStyle(fontSize: 50),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}