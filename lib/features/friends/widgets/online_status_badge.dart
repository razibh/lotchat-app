import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../models/friend_model.dart'; // OnlineStatus enum এর জন্য

class OnlineStatusBadge extends StatelessWidget {
  final Widget child;
  final bool isOnline;
  final double size;

  const OnlineStatusBadge({
    required this.child,
    required this.isOnline,
    this.size = 12,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
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

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<bool>('isOnline', isOnline));
    properties.add(DoubleProperty('size', size));
  }
}

class OnlineStatusIndicator extends StatelessWidget {
  final OnlineStatus status;
  final double size;

  const OnlineStatusIndicator({
    required this.status,
    this.size = 12,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case OnlineStatus.online:
        color = Colors.green;
        break;
      case OnlineStatus.away:
        color = Colors.orange;
        break;
      case OnlineStatus.busy:
        color = Colors.red;
        break;
      case OnlineStatus.offline:
        color = Colors.grey;
        break;
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

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<OnlineStatus>('status', status));
    properties.add(DoubleProperty('size', size));
  }
}