import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../../core/constants/app_colors.dart';
import '../../core/widgets/gradient_background.dart';
import '../../core/widgets/neumorphic_button.dart';

class TruthOrDareGame extends StatefulWidget {
  final String gameId;
  final Map<String, dynamic>? gameData;

  const TruthOrDareGame({
    required this.gameId,
    this.gameData,
    super.key,
  });

  @override
  State<TruthOrDareGame> createState() => _TruthOrDareGameState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('gameId', gameId));
    properties.add(DiagnosticsProperty<Map<String, dynamic>?>('gameData', gameData));
  }
}

class _TruthOrDareGameState extends State<TruthOrDareGame> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;

  String currentPlayer = 'Player 1';
  String currentQuestion = 'Spin the bottle to start!';
  bool isSpinning = false;
  final List<String> players = ['You', 'Opponent 1', 'Opponent 2', 'Opponent 3'];

  final List<String> truths = [
    'What is your biggest fear?',
    'Have you ever lied to your best friend?',
    "What is the most embarrassing thing you've done?",
    'Who is your crush?',
    'What is your biggest secret?',
    'Have you ever stolen anything?',
    "What is the worst date you've been on?",
    'Have you ever cheated on a test?',
  ];

  final List<String> dares = [
    'Do 20 push-ups',
    'Sing a song loudly',
    'Call a random contact and sing Happy Birthday',
    'Dance for 30 seconds without music',
    'Speak in an accent for the next 3 rounds',
    'Do an impression of someone in the room',
    'Post an embarrassing photo on social media',
    'Let someone write on your face with a marker',
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _rotationAnimation = Tween<double>(begin: 0, end: 8 * 3.14159).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          isSpinning = false;
          _selectRandomPlayer();
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _spinBottle() {
    if (isSpinning) return;

    setState(() {
      isSpinning = true;
      currentQuestion = 'Spinning...';
    });

    _animationController.forward(from: 0);
  }

  void _selectRandomPlayer() {
    final randomIndex = DateTime.now().millisecond % players.length;
    setState(() {
      currentPlayer = players[randomIndex];
    });
  }

  void _selectTruth() {
    if (isSpinning) return;
    final randomIndex = DateTime.now().millisecond % truths.length;
    setState(() {
      currentQuestion = truths[randomIndex];
    });
  }

  void _selectDare() {
    if (isSpinning) return;
    final randomIndex = DateTime.now().millisecond % dares.length;
    setState(() {
      currentQuestion = dares[randomIndex];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildCurrentPlayer(),
              Expanded(
                child: _buildBottleAndQuestion(),
              ),
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
            'Truth or Dare',
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

  Widget _buildCurrentPlayer() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.accentPurple.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.accentPurple),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.person, color: Colors.white),
          const SizedBox(width: 10),
          Text(
            currentPlayer,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottleAndQuestion() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Bottle
        AnimatedBuilder(
          animation: _rotationAnimation,
          builder: (context, child) {
            return Transform.rotate(
              angle: _rotationAnimation.value,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    Icons.sports_esports,
                    size: 60,
                    color: isSpinning ? AppColors.accentPurple : Colors.white,
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 40),
        // Question Card
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 30),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Text(
            currentQuestion,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          NeumorphicButton(
            onPressed: _spinBottle,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: const Center(
                child: Text(
                  'SPIN BOTTLE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: NeumorphicButton(
                  onPressed: _selectTruth,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: const Column(
                      children: [
                        Icon(Icons.psychology, color: Colors.white),
                        SizedBox(height: 4),
                        Text(
                          'TRUTH',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: NeumorphicButton(
                  onPressed: _selectDare,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: const Column(
                      children: [
                        Icon(Icons.sports_mma, color: Colors.white),
                        SizedBox(height: 4),
                        Text(
                          'DARE',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('currentPlayer', currentPlayer));
    properties.add(StringProperty('currentQuestion', currentQuestion));
    properties.add(DiagnosticsProperty<bool>('isSpinning', isSpinning));
    properties.add(IterableProperty<String>('players', players));
    properties.add(IterableProperty<String>('truths', truths));
    properties.add(IterableProperty<String>('dares', dares));
  }
}