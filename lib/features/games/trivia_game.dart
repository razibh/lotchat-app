import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../../core/constants/app_colors.dart';
import '../../core/widgets/gradient_background.dart';
import '../../core/widgets/neumorphic_button.dart';

class TriviaGame extends StatefulWidget {
  final String gameId;
  final Map<String, dynamic>? gameData;

  const TriviaGame({
    required this.gameId,
    this.gameData,
    super.key,
  });

  @override
  State<TriviaGame> createState() => _TriviaGameState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('gameId', gameId));
    properties.add(DiagnosticsProperty<Map<String, dynamic>?>('gameData', gameData));
  }
}

class _TriviaGameState extends State<TriviaGame> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;

  int currentQuestionIndex = 0;
  int score = 0;
  int timeLeft = 15;
  bool isAnswered = false;
  int? selectedAnswer;

  final List<TriviaQuestion> questions = [
    TriviaQuestion(
      question: 'What is the capital of France?',
      options: ['London', 'Berlin', 'Paris', 'Madrid'],
      correctAnswer: 2,
    ),
    TriviaQuestion(
      question: 'Which planet is known as the Red Planet?',
      options: ['Venus', 'Mars', 'Jupiter', 'Saturn'],
      correctAnswer: 1,
    ),
    TriviaQuestion(
      question: 'Who painted the Mona Lisa?',
      options: ['Van Gogh', 'Picasso', 'Da Vinci', 'Rembrandt'],
      correctAnswer: 2,
    ),
    TriviaQuestion(
      question: 'What is the largest ocean on Earth?',
      options: ['Atlantic', 'Indian', 'Arctic', 'Pacific'],
      correctAnswer: 3,
    ),
    TriviaQuestion(
      question: 'In which year did World War II end?',
      options: ['1943', '1944', '1945', '1946'],
      correctAnswer: 2,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    );

    _progressAnimation = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.linear),
    );

    _animationController.forward();
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed && !isAnswered) {
        _nextQuestion();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _selectAnswer(int index) {
    if (isAnswered) return;

    setState(() {
      isAnswered = true;
      selectedAnswer = index;
      if (index == questions[currentQuestionIndex].correctAnswer) {
        score += 10;
      }
    });

    _animationController.stop();

    Future.delayed(const Duration(seconds: 2), _nextQuestion);
  }

  void _nextQuestion() {
    if (currentQuestionIndex < questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
        isAnswered = false;
        selectedAnswer = null;
        timeLeft = 15;
      });
      _animationController.reset();
      _animationController.forward();
    } else {
      _showGameOverDialog();
    }
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        title: const Text('Game Over!', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Your Score: $score',
              style: const TextStyle(color: Colors.white, fontSize: 24),
            ),
            const SizedBox(height: 10),
            Text(
              'Correct Answers: $score/50',
              style: const TextStyle(color: Colors.white70),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Exit', style: TextStyle(color: Colors.white)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                currentQuestionIndex = 0;
                score = 0;
                isAnswered = false;
                selectedAnswer = null;
              });
              _animationController.reset();
              _animationController.forward();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentPurple,
            ),
            child: const Text('Play Again'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final question = questions[currentQuestionIndex];

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildProgressBar(),
              _buildScoreAndTimer(),
              Expanded(
                child: _buildQuestionCard(question),
              ),
              _buildOptions(question),
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
            'Trivia',
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

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Text(
            '${currentQuestionIndex + 1}/${questions.length}',
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: (currentQuestionIndex + 1) / questions.length,
                backgroundColor: Colors.white.withOpacity(0.1),
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accentPurple),
                minHeight: 8,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreAndTimer() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.star, color: Colors.yellow, size: 20),
                const SizedBox(width: 8),
                Text(
                  '$score',
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
              ],
            ),
          ),
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: _progressAnimation.value < 0.3
                      ? Colors.red.withOpacity(0.3)
                      : Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.timer,
                      color: _progressAnimation.value < 0.3
                          ? Colors.red
                          : Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${(_progressAnimation.value * 15).toInt()}s',
                      style: TextStyle(
                        color: _progressAnimation.value < 0.3
                            ? Colors.red
                            : Colors.white,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(TriviaQuestion question) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Center(
        child: Text(
          question.question,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildOptions(TriviaQuestion question) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: List.generate(4, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _buildOptionButton(index, question),
          );
        }),
      ),
    );
  }

  Widget _buildOptionButton(int index, TriviaQuestion question) {
    final isCorrect = isAnswered && index == question.correctAnswer;
    final isWrong = isAnswered && selectedAnswer == index && index != question.correctAnswer;

    Color backgroundColor = Colors.white.withOpacity(0.1);
    if (isCorrect) {
      backgroundColor = Colors.green.withOpacity(0.3);
    } else if (isWrong) {
      backgroundColor = Colors.red.withOpacity(0.3);
    }

    return NeumorphicButton(
      onPressed: isAnswered ? null : () => _selectAnswer(index),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const SizedBox(width: 20),
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isAnswered
                    ? (isCorrect || isWrong ? Colors.white : Colors.white.withOpacity(0.3))
                    : Colors.white.withOpacity(0.3),
              ),
              child: Center(
                child: Text(
                  String.fromCharCode(65 + index),
                  style: TextStyle(
                    color: isAnswered && (isCorrect || isWrong) ? Colors.black : Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                question.options[index],
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
            if (isCorrect)
              const Padding(
                padding: EdgeInsets.only(right: 20),
                child: Icon(Icons.check_circle, color: Colors.green),
              ),
            if (isWrong)
              const Padding(
                padding: EdgeInsets.only(right: 20),
                child: Icon(Icons.cancel, color: Colors.red),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IntProperty('currentQuestionIndex', currentQuestionIndex));
    properties.add(IntProperty('score', score));
    properties.add(IntProperty('timeLeft', timeLeft));
    properties.add(DiagnosticsProperty<bool>('isAnswered', isAnswered));
    properties.add(IntProperty('selectedAnswer', selectedAnswer));
    properties.add(IterableProperty<TriviaQuestion>('questions', questions));
  }
}

class TriviaQuestion {
  final String question;
  final List<String> options;
  final int correctAnswer;

  TriviaQuestion({
    required this.question,
    required this.options,
    required this.correctAnswer,
  });
}