import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../core/models/gift_model.dart';

class GiftAnimationOverlay extends StatefulWidget {

  const GiftAnimationOverlay({
    Key? key,
    required this.gift,
    required this.senderName,
    required this.receiverName,
    required this.multiplier,
    required this.onComplete,
  }) : super(key: key);
  final GiftModel gift;
  final String senderName;
  final String receiverName;
  final int multiplier;
  final VoidCallback onComplete;

  @override
  State<GiftAnimationOverlay> createState() => _GiftAnimationOverlayState();
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

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <>[
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
                children: <>[
                  // Gift icon/animation
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      color: widget.gift.color.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: widget.gift.animationPath != null
                        ? Lottie.asset(
                            widget.gift.animationPath!,
                            width: 150,
                            height: 150,
                          )
                        : Icon(
                            widget.gift.icon,
                            color: widget.gift.color,
                            size: 100,
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
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <>[
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