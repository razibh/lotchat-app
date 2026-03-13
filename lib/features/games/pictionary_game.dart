import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/gradient_background.dart';
import '../../core/widgets/neumorphic_button.dart';

class PictionaryGame extends StatefulWidget {

  const PictionaryGame({
    Key? key,
    required this.gameId,
    this.gameData,
  }) : super(key: key);
  final String gameId;
  final Map<String, dynamic>? gameData;

  @override
  State<PictionaryGame> createState() => _PictionaryGameState();
}

class _PictionaryGameState extends State<PictionaryGame> {
  bool isDrawing = true;
  Color selectedColor = Colors.black;
  double strokeWidth = 3;
  List<DrawingPoint> points = <DrawingPoint>[];
  List<String> words = <String>['House', 'Cat', 'Tree', 'Car', 'Sun', 'Flower'];
  String currentWord = 'House';
  int timeLeft = 60;
  int score = 0;

  @override
  void initState() {
    super.initState();
    _startTimer();
    _selectRandomWord();
  }

  void _startTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && timeLeft > 0) {
        setState(() {
          timeLeft--;
        });
        _startTimer();
      } else if (timeLeft == 0) {
        setState(() {
          isDrawing = false;
        });
      }
    });
  }

  void _selectRandomWord() {
    setState(() {
      currentWord = words[DateTime.now().millisecond % words.length];
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
              _buildGameInfo(),
              Expanded(
                child: _buildDrawingCanvas(),
              ),
              if (isDrawing) _buildDrawingTools(),
              _buildGameControls(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <>[
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          Text(
            'Pictionary',
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

  Widget _buildGameInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <>[
          Column(
            children: <>[
              const Text('Score', style: TextStyle(color: Colors.white70)),
              Text(
                '$score',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Column(
            children: <>[
              const Text('Time', style: TextStyle(color: Colors.white70)),
              Text(
                '$timeLeft',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          if (isDrawing)
            Column(
              children: <>[
                const Text('Draw', style: TextStyle(color: Colors.white70)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    currentWord,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildDrawingCanvas() {
    return GestureDetector(
      onPanStart: (details) {
        if (!isDrawing) return;
        final renderBox = context.findRenderObject() as RenderBox?;
        if (renderBox != null) {
          final localPosition = renderBox.globalToLocal(details.globalPosition);
          setState(() {
            points.add(DrawingPoint(
              offset: localPosition,
              color: selectedColor,
              strokeWidth: strokeWidth,
            ));
          });
        }
      },
      onPanUpdate: (details) {
        if (!isDrawing) return;
        final renderBox = context.findRenderObject() as RenderBox?;
        if (renderBox != null) {
          final localPosition = renderBox.globalToLocal(details.globalPosition);
          setState(() {
            points.add(DrawingPoint(
              offset: localPosition,
              color: selectedColor,
              strokeWidth: strokeWidth,
            ));
          });
        }
      },
      child: Container(
        margin: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: <>[
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: CustomPaint(
          painter: DrawingPainter(points: points),
          size: Size.infinite,
        ),
      ),
    );
  }

  Widget _buildDrawingTools() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        children: <>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <>[
              _buildColorButton(Colors.black),
              _buildColorButton(Colors.red),
              _buildColorButton(Colors.blue),
              _buildColorButton(Colors.green),
              _buildColorButton(Colors.yellow),
              _buildColorButton(Colors.purple),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <>[
              _buildStrokeButton(2, 'S'),
              _buildStrokeButton(5, 'M'),
              _buildStrokeButton(8, 'L'),
              NeumorphicButton(
                onPressed: () {
                  setState(() {
                    points.clear();
                  });
                },
                child: const Icon(Icons.clear, color: Colors.white, size: 20),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildColorButton(Color color) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedColor = color;
        });
      },
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: selectedColor == color ? Colors.white : Colors.transparent,
            width: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildStrokeButton(double width, String label) {
    return GestureDetector(
      onTap: () {
        setState(() {
          strokeWidth = width;
        });
      },
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: strokeWidth == width ? Colors.white : Colors.white.withOpacity(0.3),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: strokeWidth == width ? Colors.black : Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGameControls() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <>[
          NeumorphicButton(
            onPressed: isDrawing
                ? () {
                    setState(() {
                      isDrawing = false;
                    });
                  }
                : null,
            child: const Icon(Icons.check, color: Colors.white),
          ),
          NeumorphicButton(
            onPressed: () {
              setState(() {
                points.clear();
                _selectRandomWord();
                timeLeft = 60;
                isDrawing = true;
              });
            },
            child: const Icon(Icons.refresh, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class DrawingPoint {

  DrawingPoint({
    required this.offset,
    required this.color,
    required this.strokeWidth,
  });
  final Offset offset;
  final Color color;
  final double strokeWidth;
}

class DrawingPainter extends CustomPainter {

  DrawingPainter({required this.points});
  final List<DrawingPoint> points;

  @override
  void paint(Canvas canvas, Size size) {
    for (var i = 0; i < points.length - 1; i++) {
      if (points[i + 1] != null) {
        final paint = Paint()
          ..color = points[i].color
          ..strokeWidth = points[i].strokeWidth
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke;

        canvas.drawLine(points[i].offset, points[i + 1].offset, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant DrawingPainter oldDelegate) {
    return oldDelegate.points != points;
  }
}