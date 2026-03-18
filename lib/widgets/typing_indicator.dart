import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:async'; // Timer এর জন্য

class TypingIndicator extends StatefulWidget {
  final List<String> typingUsers;
  final Color color;
  final double size;
  final Duration animationDuration;

  const TypingIndicator({
    super.key,
    required this.typingUsers,
    this.color = Colors.blue,
    this.size = 24,
    this.animationDuration = const Duration(milliseconds: 500),
  });

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IterableProperty<String>('typingUsers', typingUsers));
    properties.add(ColorProperty('color', color));
    properties.add(DoubleProperty('size', size));
    properties.add(DiagnosticsProperty<Duration>('animationDuration', animationDuration));
  }
}

class _TypingIndicatorState extends State<TypingIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _dotAnimations;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    )..repeat(reverse: true);

    _dotAnimations = List.generate(3, (index) {
      return Tween<double>(begin: 0.5, end: 1.0).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(
            index * 0.15,
            0.5 + index * 0.15,
            curve: Curves.easeInOut,
          ),
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String get _typingText {
    if (widget.typingUsers.isEmpty) return '';
    if (widget.typingUsers.length == 1) {
      return '${widget.typingUsers.first} is typing';
    } else if (widget.typingUsers.length == 2) {
      return '${widget.typingUsers.first} and ${widget.typingUsers.last} are typing';
    } else {
      return '${widget.typingUsers.first} and ${widget.typingUsers.length - 1} others are typing';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.typingUsers.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Typing dots animation
          SizedBox(
            width: widget.size * 2,
            height: widget.size,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) {
                return AnimatedBuilder(
                  animation: _dotAnimations[index],
                  builder: (context, child) {
                    return Container(
                      width: widget.size * 0.25,
                      height: widget.size * 0.25 * _dotAnimations[index].value,
                      margin: EdgeInsets.symmetric(horizontal: widget.size * 0.1),
                      decoration: BoxDecoration(
                        color: widget.color,
                        shape: BoxShape.circle,
                      ),
                    );
                  },
                );
              }),
            ),
          ),
          const SizedBox(width: 8),

          // Typing text
          Text(
            _typingText,
            style: TextStyle(
              color: widget.color.withOpacity(0.7),
              fontSize: widget.size * 0.5,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

// Simplified typing indicator (just dots)
class TypingDots extends StatefulWidget {
  final Color color;
  final double size;
  final Duration animationDuration;

  const TypingDots({
    super.key,
    this.color = Colors.blue,
    this.size = 24,
    this.animationDuration = const Duration(milliseconds: 500),
  });

  @override
  State<TypingDots> createState() => _TypingDotsState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(ColorProperty('color', color));
    properties.add(DoubleProperty('size', size));
    properties.add(DiagnosticsProperty<Duration>('animationDuration', animationDuration));
  }
}

class _TypingDotsState extends State<TypingDots> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _dotAnimations;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    )..repeat(reverse: true);

    _dotAnimations = List.generate(3, (index) {
      return Tween<double>(begin: 0.5, end: 1.0).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(
            index * 0.15,
            0.5 + index * 0.15,
            curve: Curves.easeInOut,
          ),
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size * 2,
      height: widget.size,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(3, (index) {
          return AnimatedBuilder(
            animation: _dotAnimations[index],
            builder: (context, child) {
              return Container(
                width: widget.size * 0.25,
                height: widget.size * 0.25 * _dotAnimations[index].value,
                margin: EdgeInsets.symmetric(horizontal: widget.size * 0.1),
                decoration: BoxDecoration(
                  color: widget.color,
                  shape: BoxShape.circle,
                ),
              );
            },
          );
        }),
      ),
    );
  }
}

// Wave typing indicator
class TypingWave extends StatefulWidget {
  final Color color;
  final double size;
  final Duration animationDuration;

  const TypingWave({
    super.key,
    this.color = Colors.blue,
    this.size = 24,
    this.animationDuration = const Duration(milliseconds: 800),
  });

  @override
  State<TypingWave> createState() => _TypingWaveState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(ColorProperty('color', color));
    properties.add(DoubleProperty('size', size));
    properties.add(DiagnosticsProperty<Duration>('animationDuration', animationDuration));
  }
}

class _TypingWaveState extends State<TypingWave> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _waveAnimations;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    )..repeat();

    _waveAnimations = List.generate(3, (index) {
      return Tween<double>(begin: 0.3, end: 1.0).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(
            index * 0.2,
            0.6 + index * 0.2,
            curve: Curves.easeInOut,
          ),
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size * 2.5,
      height: widget.size,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(3, (index) {
          return AnimatedBuilder(
            animation: _waveAnimations[index],
            builder: (context, child) {
              return Container(
                width: widget.size * 0.2,
                height: widget.size * 0.5 * _waveAnimations[index].value,
                margin: EdgeInsets.symmetric(horizontal: widget.size * 0.1),
                decoration: BoxDecoration(
                  color: widget.color,
                  borderRadius: BorderRadius.circular(widget.size * 0.1),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}

// Bubble typing indicator (like iMessage)
class TypingBubble extends StatefulWidget {
  final Color color;
  final double size;
  final Duration animationDuration;

  const TypingBubble({
    super.key,
    this.color = Colors.grey,
    this.size = 24,
    this.animationDuration = const Duration(milliseconds: 600),
  });

  @override
  State<TypingBubble> createState() => _TypingBubbleState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(ColorProperty('color', color));
    properties.add(DoubleProperty('size', size));
    properties.add(DiagnosticsProperty<Duration>('animationDuration', animationDuration));
  }
}

class _TypingBubbleState extends State<TypingBubble> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _bubbleAnimations;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    )..repeat(reverse: true);

    _bubbleAnimations = List.generate(3, (index) {
      return Tween<double>(begin: 0.6, end: 1.0).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(
            index * 0.15,
            0.5 + index * 0.15,
            curve: Curves.elasticInOut,
          ),
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: widget.color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (index) {
          return AnimatedBuilder(
            animation: _bubbleAnimations[index],
            builder: (context, child) {
              return Container(
                width: widget.size * 0.3,
                height: widget.size * 0.3 * _bubbleAnimations[index].value,
                margin: EdgeInsets.symmetric(horizontal: widget.size * 0.1),
                decoration: BoxDecoration(
                  color: widget.color,
                  shape: BoxShape.circle,
                ),
              );
            },
          );
        }),
      ),
    );
  }
}

// Provider class for managing typing users
class TypingManager extends ChangeNotifier {
  final Map<String, Timer> _typingTimers = {};
  final Set<String> _typingUsers = {};

  Set<String> get typingUsers => Set.unmodifiable(_typingUsers);

  void userStartedTyping(String userId) {
    _typingTimers[userId]?.cancel();
    _typingUsers.add(userId);
    notifyListeners();

    // Auto-remove after 3 seconds of no typing
    _typingTimers[userId] = Timer(const Duration(seconds: 3), () {
      userStoppedTyping(userId);
    });
  }

  void userStoppedTyping(String userId) {
    _typingTimers[userId]?.cancel();
    _typingTimers.remove(userId);
    _typingUsers.remove(userId);
    notifyListeners();
  }

  void clearAll() {
    for (final timer in _typingTimers.values) {
      timer.cancel();
    }
    _typingTimers.clear();
    _typingUsers.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    clearAll();
    super.dispose();
  }
}