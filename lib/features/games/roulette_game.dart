import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:math';

class RouletteGame extends StatefulWidget {
  final int betAmount;

  const RouletteGame({required this.betAmount, super.key});

  @override
  State<RouletteGame> createState() => _RouletteGameState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IntProperty('betAmount', betAmount));
  }
}

class _RouletteGameState extends State<RouletteGame>
    with TickerProviderStateMixin {
  late AnimationController _spinController;
  late Animation<double> _spinAnimation;
  bool isSpinning = false;
  int result = 0;
  int? winningNumber;
  String selectedColor = 'red';
  int userCoins = 10000;

  final List<int> numbers = List.generate(37, (index) => index);
  final Map<String, List<int>> colors = {
    'red': [1, 3, 5, 7, 9, 12, 14, 16, 18, 19, 21, 23, 25, 27, 30, 32, 34, 36],
    'black': [
      2, 4, 6, 8, 10, 11, 13, 15, 17, 20, 22, 24, 26, 28, 29, 31, 33, 35,
    ],
    'green': [0],
  };

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _spinAnimation = Tween<double>(begin: 0, end: 360 * 10).animate(
      CurvedAnimation(
        parent: _spinController,
        curve: Curves.easeOutCubic,
      ),
    );

    _spinController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          isSpinning = false;
          _checkWin();
        });
      }
    });
  }

  void _spin() {
    if (isSpinning) return;

    setState(() {
      isSpinning = true;
      result = Random().nextInt(37);
      winningNumber = result;
    });

    _spinController.forward(from: 0);
  }

  void _checkWin() {
    final bool won = selectedColor == 'red' && colors['red']!.contains(result) ||
        selectedColor == 'black' && colors['black']!.contains(result) ||
        selectedColor == 'green' && result == 0;

    if (won) {
      final multiplier = selectedColor == 'green' ? 35 : 2;
      final winnings = widget.betAmount * multiplier;
      setState(() {
        userCoins += winnings;
      });

      _showResultDialog(true, winnings);
    } else {
      setState(() {
        userCoins -= widget.betAmount;
      });
      _showResultDialog(false, 0);
    }
  }

  void _showResultDialog(bool won, int amount) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(won ? '🎉 You Won!' : '😢 You Lost'),
          content: Text(
            won
                ? 'You won $amount coins!\nWinning number: $result'
                : 'Better luck next time!\nWinning number: $result',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context, userCoins);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Roulette'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1a1a2e), Color(0xFF16213e)],
          ),
        ),
        child: Column(
          children: [
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
                children: [
                  const Text(
                    'Your Coins:',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  Text(
                    '$userCoins',
                    style: const TextStyle(
                      color: Colors.green,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Roulette Wheel
            Container(
              width: 300,
              height: 300,
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const RadialGradient(
                  colors: [Colors.purple, Colors.pink],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.purple.withOpacity(0.5),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: AnimatedBuilder(
                animation: _spinAnimation,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _spinAnimation.value * pi / 180,
                    child: CustomPaint(
                      painter: RouletteWheelPainter(winningNumber: result),
                    ),
                  );
                },
              ),
            ),

            // Result Display
            if (!isSpinning && winningNumber != null)
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Text(
                      'Result: $result',
                      style: TextStyle(
                        color: colors['red']!.contains(result)
                            ? Colors.red
                            : colors['black']!.contains(result)
                            ? Colors.white
                            : Colors.green,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      colors['red']!.contains(result)
                          ? 'RED'
                          : colors['black']!.contains(result)
                          ? 'BLACK'
                          : 'GREEN',
                      style: TextStyle(
                        color: colors['red']!.contains(result)
                            ? Colors.red
                            : colors['black']!.contains(result)
                            ? Colors.white
                            : Colors.green,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ),

            // Bet Options
            Container(
              margin: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text(
                    'Place your bet on:',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildBetOption('RED', Colors.red, selectedColor == 'red'),
                      _buildBetOption('BLACK', Colors.white, selectedColor == 'black'),
                      _buildBetOption('GREEN', Colors.green, selectedColor == 'green'),
                    ],
                  ),
                ],
              ),
            ),

            // Spin Button
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isSpinning ? null : _spin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    isSpinning
                        ? 'Spinning...'
                        : 'SPIN (${widget.betAmount} coins)',
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBetOption(String label, Color color, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedColor = label.toLowerCase();
        });
      },
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.white : color,
            width: 3,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _spinController.dispose();
    super.dispose();
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<bool>('isSpinning', isSpinning));
    properties.add(IntProperty('result', result));
    properties.add(IntProperty('winningNumber', winningNumber));
    properties.add(StringProperty('selectedColor', selectedColor));
    properties.add(IntProperty('userCoins', userCoins));
    properties.add(IterableProperty<int>('numbers', numbers));
    properties.add(DiagnosticsProperty<Map<String, List<int>>>('colors', colors));
  }
}

class RouletteWheelPainter extends CustomPainter {
  final int? winningNumber;

  RouletteWheelPainter({this.winningNumber});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final double radius = size.width / 2;

    final redPaint = Paint()..color = Colors.red;
    final blackPaint = Paint()..color = Colors.black;
    final greenPaint = Paint()..color = Colors.green;

    // Draw 37 segments
    for (var i = 0; i < 37; i++) {
      final double startAngle = (2 * pi / 37) * i;
      const double sweepAngle = 2 * pi / 37;

      final paint = i == 0
          ? greenPaint
          : [1, 3, 5, 7, 9, 12, 14, 16, 18, 19, 21, 23, 25, 27, 30, 32, 34, 36]
          .contains(i)
          ? redPaint
          : blackPaint;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      // Draw number
      final textPainter = TextPainter(
        text: TextSpan(
          text: '$i',
          style: const TextStyle(color: Colors.white, fontSize: 10),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();

      final double angle = startAngle + sweepAngle / 2;
      final textOffset = Offset(
        center.dx + (radius * 0.7) * cos(angle),
        center.dy + (radius * 0.7) * sin(angle),
      );

      textPainter.paint(
        canvas,
        textOffset - Offset(textPainter.width / 2, textPainter.height / 2),
      );
    }

    // Draw center circle
    canvas.drawCircle(
      center,
      radius * 0.2,
      Paint()..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}