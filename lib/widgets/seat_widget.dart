import 'package:flutter/material.dart';
import '../core/models/seat_model.dart';
import 'animation/pulse_animation.dart';
import 'badge_widget.dart';

class SeatWidget extends StatelessWidget {

  const SeatWidget({
    required this.seat, super.key,
    this.isCurrentUser = false,
    this.onTap,
    this.onLongPress,
  });
  final SeatModel seat;
  final bool isCurrentUser;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    if (seat.isEmpty) {
      return _buildEmptySeat();
    }

    return _buildOccupiedSeat();
  }

  Widget _buildEmptySeat() {
    return GestureDetector(
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.grey.shade800.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey.shade600,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <>[
            Icon(
              Icons.mic_off,
              color: Colors.grey.shade500,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              'Seat ${seat.seatNumber}',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOccupiedSeat() {
    final bool isSpeaking = seat.isSpeaking && !seat.isMuted;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: _getSeatGradient(),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _getBorderColor(),
            width: isCurrentUser ? 3 : 2,
          ),
          boxShadow: isSpeaking
              ? <>[
                  BoxShadow(
                    color: Colors.green.withValues(alpha: 0.5),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: Stack(
          children: <>[
            // Avatar and Info
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <>[
                // Avatar
                Stack(
                  children: <>[
                    CircleAvatar(
                      radius: 24,
                      backgroundImage: seat.userAvatar != null
                          ? NetworkImage(seat.userAvatar!)
                          : null,
                      child: seat.userAvatar == null
                          ? Text(
                              seat.userName![0].toUpperCase(),
                              style: const TextStyle(fontSize: 20),
                            )
                          : null,
                    ),
                    if (isSpeaking)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: PulseAnimation(
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),

                // Username
                Text(
                  _getDisplayName(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),

                // Seat Number
                Text(
                  'Seat ${seat.seatNumber}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 10,
                  ),
                ),
              ],
            ),

            // Mic Indicator
            if (seat.isMuted)
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.mic_off,
                    color: Colors.white,
                    size: 12,
                  ),
                ),
              ),

            // Current User Indicator
            if (isCurrentUser)
              Positioned(
                top: 4,
                left: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'You',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                    ),
                  ),
                ),
              ),

            // VIP/SVIP Badge
            if (seat.userTier != null && seat.userTier != UserTier.normal)
              Positioned(
                bottom: 4,
                right: 4,
                child: BadgeWidget(
                  tier: seat.userTier!,
                  size: 16,
                  showTooltip: false,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Gradient _getSeatGradient() {
    if (seat.isSpeaking && !seat.isMuted) {
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <>[
          Colors.green.shade700,
          Colors.green.shade500,
        ],
      );
    }

    if (isCurrentUser) {
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <>[
          Colors.blue.shade700,
          Colors.blue.shade500,
        ],
      );
    }

    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: <>[
        Colors.purple.shade700,
        Colors.purple.shade500,
      ],
    );
  }

  Color _getBorderColor() {
    if (seat.isSpeaking && !seat.isMuted) {
      return Colors.green;
    }
    if (isCurrentUser) {
      return Colors.blue;
    }
    return Colors.white54;
  }

  String _getDisplayName() {
    if (seat.userName!.length > 8) {
      return '${seat.userName!.substring(0, 6)}...';
    }
    return seat.userName!;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<SeatModel>('seat', seat));
    properties.add(DiagnosticsProperty<bool>('isCurrentUser', isCurrentUser));
    properties.add(ObjectFlagProperty<VoidCallback?>.has('onTap', onTap));
    properties.add(ObjectFlagProperty<VoidCallback?>.has('onLongPress', onLongPress));
  }
}

class SeatsGrid extends StatelessWidget {

  const SeatsGrid({
    required this.seats, super.key,
    this.currentUserId,
    this.onSeatTap,
    this.onSeatLongPress,
  });
  final List<SeatModel> seats;
  final String? currentUserId;
  final Function(int)? onSeatTap;
  final Function(int)? onSeatLongPress;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.9,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: seats.length,
      itemBuilder: (BuildContext context, int index) {
        final seat = seats[index];
        final bool isCurrentUser = seat.userId == currentUserId;

        return SeatWidget(
          seat: seat,
          isCurrentUser: isCurrentUser,
          onTap: () => onSeatTap?.call(seat.seatNumber),
          onLongPress: () => onSeatLongPress?.call(seat.seatNumber),
        );
      },
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IterableProperty<>('seats', seats));
    properties.add(StringProperty('currentUserId', currentUserId));
    properties.add(ObjectFlagProperty<Function(int)?>.has('onSeatTap', onSeatTap));
    properties.add(ObjectFlagProperty<Function(int)?>.has('onSeatLongPress', onSeatLongPress));
  }
}