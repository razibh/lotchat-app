import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/gradient_background.dart';
import '../../core/widgets/neumorphic_button.dart';
import 'dart:math' as math;

class CarromGame extends StatefulWidget {

  const CarromGame({
    required this.gameId, super.key,
    this.gameData,
  });
  final String gameId;
  final Map<String, dynamic>? gameData;

  @override
  State<CarromGame> createState() => _CarromGameState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('gameId', gameId));
    properties.add(DiagnosticsProperty<Map<String, dynamic>?>('gameData', gameData));
  }
}

class _CarromGameState extends State<CarromGame> with TickerProviderStateMixin {
  late AnimationController _strikerController;
  late Animation<double> _strikerAnimation;
  
  bool isPlayerTurn = true;
  double strikerPosition = 0;
  int playerScore = 0;
  int opponentScore = 0;

  @override
  void initState() {
    super.initState();
    _strikerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    
    _strikerAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _strikerController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _strikerController.dispose();
    super.dispose();
  }

  void _shootStriker() {
    if (!isPlayerTurn) return;
    
    _strikerController.forward().then((_) {
      setState(() {
        isPlayerTurn = false;
        playerScore += math.Random().nextInt(3); // Simulate score
      });
      _strikerController.reset();
      
      // Simulate opponent turn
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            isPlayerTurn = true;
            opponentScore += math.Random().nextInt(3);
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: <>[
              _buildHeader(),
              Expanded(
                child: Stack(
                  children: <>[
                    _buildGameBoard(),
                    _buildStriker(),
                  ],
                ),
              ),
              _buildScoreBoard(),
              _buildControls(),
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
        children: <>[
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          Text(
            'Carrom',
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

  Widget _buildGameBoard() {
    return Center(
      child: Container(
        width: 300,
        height: 300,
        decoration: BoxDecoration(
          color: AppColors.backgroundDark,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.brown.shade800, width: 4),
          boxShadow: <>[
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: CustomPaint(
          painter: CarromBoardPainter(),
        ),
      ),
    );
  }

  Widget _buildStriker() {
    return AnimatedBuilder(
      animation: _strikerAnimation,
      builder: (BuildContext context, Widget? child) {
        return Positioned(
          left: 150 - 15,
          bottom: 20 + (50 * _strikerAnimation.value),
          child: Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: <>[
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.5),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildScoreBoard() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <>[
          _buildScoreCard('You', playerScore),
          Container(
            width: 2,
            height: 40,
            color: Colors.white.withValues(alpha: 0.3),
          ),
          _buildScoreCard('Opponent', opponentScore),
        ],
      ),
    );
  }

  Widget _buildScoreCard(String label, int score) {
    return Column(
      children: <>[
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        const SizedBox(height: 4),
        Text(
          score.toString(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildControls() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <>[
          NeumorphicButton(
            onPressed: isPlayerTurn ? _shootStriker : null,
            child: const Icon(Icons.sports_handball, color: Colors.white),
          ),
          NeumorphicButton(
            onPressed: isPlayerTurn ? () {} : null,
            child: const Icon(Icons.settings_overscan, color: Colors.white),
          ),
        ],
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<bool>('isPlayerTurn', isPlayerTurn));
    properties.add(DoubleProperty('strikerPosition', strikerPosition));
    properties.add(IntProperty('playerScore', playerScore));
    properties.add(IntProperty('opponentScore', opponentScore));
  }
}

class CarromBoardPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.brown.shade600
      ..style = PaintingStyle.fill;

    // Draw board
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // Draw circles
    paint.color = Colors.white.withValues(alpha: 0.1);
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2;

    // Center circle
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width / 4,
      paint,
    );

    // Four corner circles
    final double cornerRadius = size.width / 8;
    canvas.drawCircle(Offset(cornerRadius, cornerRadius), cornerRadius / 2, paint);
    canvas.drawCircle(Offset(size.width - cornerRadius, cornerRadius), cornerRadius / 2, paint);
    canvas.drawCircle(Offset(cornerRadius, size.height - cornerRadius), cornerRadius / 2, paint);
    canvas.drawCircle(Offset(size.width - cornerRadius, size.height - cornerRadius), cornerRadius / 2, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}