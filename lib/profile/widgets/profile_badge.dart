import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../core/models/badge_model.dart';

class ProfileBadge extends StatelessWidget {
  final BadgeModel badge;
  final VoidCallback? onTap;
  final VoidCallback? onEquip;
  final double size;

  const ProfileBadge({
    super.key,
    required this.badge,
    this.onTap,
    this.onEquip,
    this.size = 80,
  });

  @override
  Widget build(BuildContext context) {
    final bool isAcquired = badge.acquiredAt != null;
    final bool isEquipped = badge.isEquipped;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: isAcquired ? badge.rarityColor.withOpacity(0.1) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: isEquipped
              ? Border.all(color: badge.rarityColor, width: 2)
              : null,
        ),
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Badge Icon
                Container(
                  width: size * 0.5,
                  height: size * 0.5,
                  decoration: BoxDecoration(
                    color: isAcquired ? badge.rarityColor.withOpacity(0.2) : Colors.grey.shade200,
                    shape: BoxShape.circle,
                  ),
                  child: badge.svgPath.isNotEmpty
                      ? Image.asset(
                    badge.svgPath,
                    width: size * 0.3,
                    height: size * 0.3,
                    color: isAcquired ? null : Colors.grey,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        _getBadgeIcon(badge.type),
                        size: size * 0.3,
                        color: isAcquired ? badge.rarityColor : Colors.grey,
                      );
                    },
                  )
                      : Icon(
                    _getBadgeIcon(badge.type),
                    size: size * 0.3,
                    color: isAcquired ? badge.rarityColor : Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),

                // Badge Name
                Text(
                  badge.name,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isAcquired ? Colors.black87 : Colors.grey,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),

                // Badge Description
                Text(
                  badge.description,
                  style: TextStyle(
                    fontSize: 7,
                    color: isAcquired ? Colors.grey.shade600 : Colors.grey.shade400,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ],
            ),

            // Equipped Indicator
            if (isEquipped)
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 10,
                  ),
                ),
              ),

            // Locked Overlay
            if (!isAcquired)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.lock,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),

            // Equip Button
            if (onEquip != null && isAcquired && !isEquipped)
              Positioned(
                bottom: 4,
                right: 4,
                child: GestureDetector(
                  onTap: onEquip,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: badge.rarityColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.stars,
                      color: Colors.white,
                      size: 12,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  IconData _getBadgeIcon(BadgeType type) {
    switch (type) {
      case BadgeType.vip:
        return Icons.star;
      case BadgeType.svip:
        return Icons.diamond;
      case BadgeType.fan:
        return Icons.favorite;
      case BadgeType.event:
        return Icons.event;
      case BadgeType.official:
        return Icons.verified;
      case BadgeType.agency:
        return Icons.business_center;
      case BadgeType.host:
        return Icons.mic;
      case BadgeType.moderator:
        return Icons.security;
      case BadgeType.streamer:
        return Icons.live_tv;
    }
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<BadgeModel>('badge', badge));
    properties.add(ObjectFlagProperty<VoidCallback?>.has('onTap', onTap));
    properties.add(ObjectFlagProperty<VoidCallback?>.has('onEquip', onEquip));
    properties.add(DoubleProperty('size', size));
  }
}

class ProfileBadgeList extends StatelessWidget {
  final List<BadgeModel> badges;
  final Function(BadgeModel)? onBadgeTap;
  final Function(BadgeModel)? onBadgeEquip;
  final int crossAxisCount;
  final double spacing;

  const ProfileBadgeList({
    super.key,
    required this.badges,
    this.onBadgeTap,
    this.onBadgeEquip,
    this.crossAxisCount = 3,
    this.spacing = 8,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 0.9,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
      ),
      itemCount: badges.length,
      itemBuilder: (context, index) {
        final badge = badges[index];
        return ProfileBadge(
          badge: badge,
          onTap: () => onBadgeTap?.call(badge),
          onEquip: badge.isAcquired ? () => onBadgeEquip?.call(badge) : null,
        );
      },
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IterableProperty<BadgeModel>('badges', badges));
    properties.add(IntProperty('crossAxisCount', crossAxisCount));
    properties.add(DoubleProperty('spacing', spacing));
  }
}

class ProfileBadgeCard extends StatelessWidget {
  final BadgeModel badge;
  final VoidCallback? onTap;
  final VoidCallback? onEquip;
  final bool showDetails;

  const ProfileBadgeCard({
    super.key,
    required this.badge,
    this.onTap,
    this.onEquip,
    this.showDetails = true,
  });

  @override
  Widget build(BuildContext context) {
    final bool isAcquired = badge.acquiredAt != null;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: badge.isEquipped
            ? BorderSide(color: badge.rarityColor, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Badge Icon
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: isAcquired ? badge.rarityColor.withOpacity(0.2) : Colors.grey.shade200,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getBadgeIcon(badge.type),
                  size: 30,
                  color: isAcquired ? badge.rarityColor : Colors.grey,
                ),
              ),
              const SizedBox(width: 12),

              // Badge Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            badge.name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isAcquired ? Colors.black87 : Colors.grey,
                            ),
                          ),
                        ),
                        if (badge.isEquipped)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Equipped',
                              style: TextStyle(
                                color: Colors.green,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    if (showDetails) ...[
                      const SizedBox(height: 4),
                      Text(
                        badge.description,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: badge.rarityColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              badge.tierName,
                              style: TextStyle(
                                fontSize: 10,
                                color: badge.rarityColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isAcquired ? 'Acquired' : 'Locked',
                            style: TextStyle(
                              fontSize: 10,
                              color: isAcquired ? Colors.green : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // Equip Button
              if (onEquip != null && isAcquired && !badge.isEquipped)
                IconButton(
                  onPressed: onEquip,
                  icon: Icon(
                    Icons.stars,
                    color: badge.rarityColor,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getBadgeIcon(BadgeType type) {
    switch (type) {
      case BadgeType.vip:
        return Icons.star;
      case BadgeType.svip:
        return Icons.diamond;
      case BadgeType.fan:
        return Icons.favorite;
      case BadgeType.event:
        return Icons.event;
      case BadgeType.official:
        return Icons.verified;
      case BadgeType.agency:
        return Icons.business_center;
      case BadgeType.host:
        return Icons.mic;
      case BadgeType.moderator:
        return Icons.security;
      case BadgeType.streamer:
        return Icons.live_tv;
    }
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<BadgeModel>('badge', badge));
    properties.add(DiagnosticsProperty<bool>('showDetails', showDetails));
  }
}