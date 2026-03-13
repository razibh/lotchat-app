import 'package:flutter/material.dart';
import '../core/models/user_model.dart';

class BadgeWidget extends StatelessWidget {

  const BadgeWidget({
    Key? key,
    required this.tier,
    this.size = 24,
    this.showTooltip = true,
  }) : super(key: key);
  final UserTier tier;
  final double size;
  final bool showTooltip;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: showTooltip ? () => _showBadgeInfo(context) : null,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: _getGradient(),
          border: Border.all(
            color: Colors.white,
            width: size * 0.1,
          ),
          boxShadow: <>[
            BoxShadow(
              color: _getColor().withOpacity(0.5),
              blurRadius: size * 0.2,
              spreadRadius: size * 0.05,
            ),
          ],
        ),
        child: Center(
          child: Icon(
            _getIcon(),
            color: Colors.white,
            size: size * 0.5,
          ),
        ),
      ),
    );
  }

  void _showBadgeInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_getTitle()),
        content: Text(_getDescription()),
        actions: <>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Gradient _getGradient() {
    switch (tier) {
      case UserTier.vip1:
      case UserTier.vip2:
      case UserTier.vip3:
      case UserTier.vip4:
      case UserTier.vip5:
      case UserTier.vip6:
      case UserTier.vip7:
      case UserTier.vip8:
      case UserTier.vip9:
      case UserTier.vip10:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <>[Color(0xFF8B5CF6), Color(0xFF6D28D9)],
        );
      case UserTier.svip1:
      case UserTier.svip2:
      case UserTier.svip3:
      case UserTier.svip4:
      case UserTier.svip5:
      case UserTier.svip6:
      case UserTier.svip7:
      case UserTier.svip8:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <>[Color(0xFFEC4899), Color(0xFF8B5CF6), Color(0xFFF59E0B)],
        );
      default:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <>[Colors.grey, Colors.grey],
        );
    }
  }

  Color _getColor() {
    switch (tier) {
      case UserTier.vip1:
      case UserTier.vip2:
      case UserTier.vip3:
      case UserTier.vip4:
      case UserTier.vip5:
      case UserTier.vip6:
      case UserTier.vip7:
      case UserTier.vip8:
      case UserTier.vip9:
      case UserTier.vip10:
        return const Color(0xFF8B5CF6);
      case UserTier.svip1:
      case UserTier.svip2:
      case UserTier.svip3:
      case UserTier.svip4:
      case UserTier.svip5:
      case UserTier.svip6:
      case UserTier.svip7:
      case UserTier.svip8:
        return const Color(0xFFEC4899);
      default:
        return Colors.grey;
    }
  }

  IconData _getIcon() {
    switch (tier) {
      case UserTier.vip1:
      case UserTier.vip2:
      case UserTier.vip3:
      case UserTier.vip4:
      case UserTier.vip5:
      case UserTier.vip6:
      case UserTier.vip7:
      case UserTier.vip8:
      case UserTier.vip9:
      case UserTier.vip10:
        return Icons.star;
      case UserTier.svip1:
      case UserTier.svip2:
      case UserTier.svip3:
      case UserTier.svip4:
      case UserTier.svip5:
      case UserTier.svip6:
      case UserTier.svip7:
      case UserTier.svip8:
        return Icons.diamond;
      default:
        return Icons.circle;
    }
  }

  String _getTitle() {
    switch (tier) {
      case UserTier.vip1:
        return 'VIP Level 1';
      case UserTier.vip2:
        return 'VIP Level 2';
      case UserTier.vip3:
        return 'VIP Level 3';
      case UserTier.vip4:
        return 'VIP Level 4';
      case UserTier.vip5:
        return 'VIP Level 5';
      case UserTier.vip6:
        return 'VIP Level 6';
      case UserTier.vip7:
        return 'VIP Level 7';
      case UserTier.vip8:
        return 'VIP Level 8';
      case UserTier.vip9:
        return 'VIP Level 9';
      case UserTier.vip10:
        return 'VIP Level 10';
      case UserTier.svip1:
        return 'SVIP Level 1';
      case UserTier.svip2:
        return 'SVIP Level 2';
      case UserTier.svip3:
        return 'SVIP Level 3';
      case UserTier.svip4:
        return 'SVIP Level 4';
      case UserTier.svip5:
        return 'SVIP Level 5';
      case UserTier.svip6:
        return 'SVIP Level 6';
      case UserTier.svip7:
        return 'SVIP Level 7';
      case UserTier.svip8:
        return 'SVIP Level 8';
      default:
        return 'User';
    }
  }

  String _getDescription() {
    switch (tier) {
      case UserTier.vip1:
        return 'VIP Level 1 member. Unlock exclusive features and benefits.';
      case UserTier.vip2:
        return 'VIP Level 2 member. Enjoy enhanced privileges and rewards.';
      case UserTier.vip3:
        return 'VIP Level 3 member. Access premium content and features.';
      case UserTier.vip4:
        return 'VIP Level 4 member. Get priority support and exclusive gifts.';
      case UserTier.vip5:
        return 'VIP Level 5 member. Unlock special badges and frames.';
      case UserTier.vip6:
        return 'VIP Level 6 member. Enjoy higher gift limits and bonuses.';
      case UserTier.vip7:
        return 'VIP Level 7 member. Access VIP-only rooms and events.';
      case UserTier.vip8:
        return 'VIP Level 8 member. Get exclusive discounts and offers.';
      case UserTier.vip9:
        return 'VIP Level 9 member. Unlock legendary status benefits.';
      case UserTier.vip10:
        return 'VIP Level 10 member. Ultimate VIP experience and rewards.';
      case UserTier.svip1:
        return 'SVIP Level 1 - The beginning of ultimate luxury.';
      case UserTier.svip2:
        return 'SVIP Level 2 - Enhanced privileges and recognition.';
      case UserTier.svip3:
        return 'SVIP Level 3 - Exclusive access to premium features.';
      case UserTier.svip4:
        return 'SVIP Level 4 - Priority in everything you do.';
      case UserTier.svip5:
        return 'SVIP Level 5 - Unlock mythical rewards and benefits.';
      case UserTier.svip6:
        return 'SVIP Level 6 - Legendary status and recognition.';
      case UserTier.svip7:
        return 'SVIP Level 7 - Almost at the top of luxury.';
      case UserTier.svip8:
        return 'SVIP Level 8 - The pinnacle of achievement and luxury.';
      default:
        return 'Regular user. Upgrade to VIP/SVIP for more features.';
    }
  }
}

class BadgeCollection extends StatelessWidget {

  const BadgeCollection({
    Key? key,
    required this.badges,
    this.size = 20,
    this.maxDisplay = 3,
  }) : super(key: key);
  final List<UserTier> badges;
  final double size;
  final int maxDisplay;

  @override
  Widget build(BuildContext context) {
    final List<UserTier> displayBadges = badges.take(maxDisplay).toList();
    final int remaining = badges.length - maxDisplay;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <>[
        ...displayBadges.map((UserTier badge) => Padding(
          padding: const EdgeInsets.only(right: 2),
          child: BadgeWidget(
            tier: badge,
            size: size,
          ),
        )),
        if (remaining > 0)
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '+$remaining',
                style: TextStyle(
                  fontSize: size * 0.4,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
          ),
      ],
    );
  }
}