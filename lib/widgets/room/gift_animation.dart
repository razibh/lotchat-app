import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:lottie/lottie.dart';
import '../../core/models/gift_model.dart';

class GiftAnimationOverlay extends StatefulWidget {
  final GiftModel gift;
  final String senderName;
  final String receiverName;
  final int multiplier;
  final VoidCallback onComplete;

  const GiftAnimationOverlay({
    super.key,
    required this.gift,
    required this.senderName,
    required this.receiverName,
    required this.multiplier,
    required this.onComplete,
  });

  @override
  State<GiftAnimationOverlay> createState() => _GiftAnimationOverlayState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<GiftModel>('gift', gift));
    properties.add(StringProperty('senderName', senderName));
    properties.add(StringProperty('receiverName', receiverName));
    properties.add(IntProperty('multiplier', multiplier));
    properties.add(ObjectFlagProperty<VoidCallback>.has('onComplete', onComplete));
  }
}

class _GiftAnimationOverlayState extends State<GiftAnimationOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));

    _controller.forward().then((_) {
      Future.delayed(const Duration(seconds: 2), widget.onComplete);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getGiftColor() {
    // GiftModel এ color ফিল্ড না থাকলে ডিফল্ট কালার ব্যবহার করুন
    // আপনার GiftModel এ কোন ফিল্ড আছে তার উপর নির্ভর করে পরিবর্তন করুন
    return Colors.purple; // ডিফল্ট কালার
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Semi-transparent background
        Container(
          color: Colors.black.withOpacity(0.5),
        ),

        // Animation
        Center(
          child: SlideTransition(
            position: _slideAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Gift icon/animation
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      color: _getGiftColor().withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: widget.gift.animationPath != null
                        ? Lottie.asset(
                      widget.gift.animationPath!,
                      width: 150,
                      height: 150,
                    )
                        : Icon(
                      Icons.card_giftcard,
                      size: 80,
                      color: _getGiftColor(),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Gift info
                  Text(
                    '${widget.senderName} sent ${widget.multiplier}x ${widget.gift.name}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'to ${widget.receiverName}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Price
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.amber.withOpacity(0.3),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.monetization_on,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${widget.gift.price * widget.multiplier}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Multiple gifts animation
class MultipleGiftsAnimation extends StatefulWidget {
  final List<GiftAnimationData> gifts;
  final VoidCallback onComplete;

  const MultipleGiftsAnimation({
    super.key,
    required this.gifts,
    required this.onComplete,
  });

  @override
  State<MultipleGiftsAnimation> createState() => _MultipleGiftsAnimationState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IterableProperty<GiftAnimationData>('gifts', gifts));
    properties.add(ObjectFlagProperty<VoidCallback>.has('onComplete', onComplete));
  }
}

class _MultipleGiftsAnimationState extends State<MultipleGiftsAnimation>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(widget.gifts.length, (index) {
      return AnimationController(
        vsync: this,
        duration: Duration(seconds: 2 + index),
      );
    });

    _animations = _controllers.map((controller) {
      return CurvedAnimation(
        parent: controller,
        curve: Curves.elasticOut,
      );
    }).toList();

    _startNextAnimation();
  }

  void _startNextAnimation() {
    if (_currentIndex < _controllers.length) {
      _controllers[_currentIndex].forward().then((_) {
        Future.delayed(const Duration(seconds: 1), () {
          setState(() {
            _currentIndex++;
          });
          _startNextAnimation();
        });
      });
    } else {
      Future.delayed(const Duration(seconds: 2), widget.onComplete);
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Color _getGiftColor(GiftModel gift) {
    // GiftModel এ color ফিল্ড না থাকলে ডিফল্ট কালার ব্যবহার করুন
    return Colors.purple; // ডিফল্ট কালার
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Semi-transparent background
        Container(
          color: Colors.black.withOpacity(0.7),
        ),

        // Animations
        ...List.generate(widget.gifts.length, (index) {
          if (index > _currentIndex) return const SizedBox.shrink();

          final gift = widget.gifts[index];
          return Center(
            child: ScaleTransition(
              scale: _animations[index],
              child: Opacity(
                opacity: index == _currentIndex ? 1.0 : 0.5,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        color: _getGiftColor(gift.gift).withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: gift.gift.animationPath != null
                          ? Lottie.asset(
                        gift.gift.animationPath!,
                        width: 100,
                        height: 100,
                      )
                          : Icon(
                        Icons.card_giftcard,
                        size: 50,
                        color: _getGiftColor(gift.gift),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${gift.senderName} sent ${gift.multiplier}x ${gift.gift.name}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}

class GiftAnimationData {
  final GiftModel gift;
  final String senderName;
  final int multiplier;

  GiftAnimationData({
    required this.gift,
    required this.senderName,
    required this.multiplier,
  });
}

// Floating gift animation
class FloatingGiftAnimation extends StatefulWidget {
  final GiftModel gift;
  final Offset startPosition;
  final Offset endPosition;
  final VoidCallback onComplete;

  const FloatingGiftAnimation({
    super.key,
    required this.gift,
    required this.startPosition,
    required this.endPosition,
    required this.onComplete,
  });

  @override
  State<FloatingGiftAnimation> createState() => _FloatingGiftAnimationState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<GiftModel>('gift', gift));
    properties.add(DiagnosticsProperty<Offset>('startPosition', startPosition));
    properties.add(DiagnosticsProperty<Offset>('endPosition', endPosition));
    properties.add(ObjectFlagProperty<VoidCallback>.has('onComplete', onComplete));
  }
}

class _FloatingGiftAnimationState extends State<FloatingGiftAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _positionAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _positionAnimation = Tween<Offset>(
      begin: widget.startPosition,
      end: widget.endPosition,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.5,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));

    _controller.forward().then((_) {
      widget.onComplete();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getGiftColor() {
    return Colors.purple; // ডিফল্ট কালার
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned(
          left: _positionAnimation.value.dx,
          top: _positionAnimation.value.dy,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: _getGiftColor().withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.card_giftcard,
                color: _getGiftColor(),
                size: 30,
              ),
            ),
          ),
        );
      },
    );
  }
}