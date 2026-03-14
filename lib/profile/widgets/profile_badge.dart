import 'package:flutter/material.dart';
import '../models/badge_model.dart';

class ProfileBadge extends StatelessWidget {

  const ProfileBadge({
    required this.badge, super.key,
    this.onTap,
    this.onEquip,
  });
  final BadgeModel badge;
  final VoidCallback? onTap;
  final VoidCallback? onEquip;

  @override
  Widget build(BuildContext context) {
    final bool isAcquired = badge.isAcquired;

    return GestureDetector(
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: isAcquired ? badge.rarityColor.withOpacity(0.1) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: badge.isEquipped
              ? Border.all(color: badge.rarityColor, width: 2)
              : null,
        ),
        child: Stack(
          children: <>[
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <>[
                // Badge Icon
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: isAcquired ? badge.rarityColor.withOpacity(0.2) : Colors.grey.shade200,
                    shape: BoxShape.circle,
                  ),
                  child: Image.network(
                    badge.iconUrl,
                    width: 30,
                    height: 30,
                    color: isAcquired ? null : Colors.grey,
                    errorBuilder: (BuildContext context, Object error, StackTrace? stack) {
                      return Icon(
                        Icons.emoji_events,
                        size: 30,
                        color: isAcquired ? badge.rarityColor : Colors.grey,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),

                // Badge Name
                Text(
                  badge.name,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isAcquired ? null : Colors.grey,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                // Badge Description
                Text(
                  badge.description,
                  style: TextStyle(
                    fontSize: 8,
                    color: isAcquired ? Colors.grey.shade600 : Colors.grey.shade400,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ],
            ),

            // Equipped Indicator
            if (badge.isEquipped)
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
                    color: Colors.black.withValues(alpha: 0.5),
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
            if (onEquip != null)
              Positioned(
                bottom: 4,
                right: 4,
                child: GestureDetector(
                  onTap: onEquip,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.blue,
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

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<BadgeModel>('badge', badge));
    properties.add(ObjectFlagProperty<VoidCallback?>.has('onTap', onTap));
    properties.add(ObjectFlagProperty<VoidCallback?>.has('onEquip', onEquip));
  }
}