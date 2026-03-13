import 'package:flutter/material.dart';

class OnlineStatusBadge extends StatelessWidget {

  const OnlineStatusBadge({
    Key? key,
    required this.child,
    required this.isOnline,
    this.size = 12,
  }) : super(key: key);
  final Widget child;
  final bool isOnline;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: <>[
        child,
        if (isOnline)
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class OnlineStatusIndicator extends StatelessWidget {

  const OnlineStatusIndicator({
    Key? key,
    required this.status,
    this.size = 12,
  }) : super(key: key);
  final OnlineStatus status;
  final double size;

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case OnlineStatus.online:
        color = Colors.green;
      case OnlineStatus.away:
        color = Colors.orange;
      case OnlineStatus.busy:
        color = Colors.red;
      case OnlineStatus.offline:
        color = Colors.grey;
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}