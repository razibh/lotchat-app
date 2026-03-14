import 'package:flutter/material.dart';
import '../models/frame_model.dart';

class ProfileFrame extends StatelessWidget {

  const ProfileFrame({
    required this.frame, required this.isOwned, required this.isEquipped, required this.canAfford, super.key,
    this.onTap,
    this.onEquip,
    this.onPurchase,
  });
  final FrameModel frame;
  final bool isOwned;
  final bool isEquipped;
  final bool canAfford;
  final VoidCallback? onTap;
  final VoidCallback? onEquip;
  final VoidCallback? onPurchase;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: isOwned ? frame.rarityColor.withOpacity(0.1) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: isEquipped
              ? Border.all(color: frame.rarityColor, width: 2)
              : null,
        ),
        child: Stack(
          children: <>[
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <>[
                // Frame Preview
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(frame.imageUrl),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ),

                // Frame Name
                Padding(
                  padding: const EdgeInsets.all(4),
                  child: Text(
                    frame.name,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isOwned ? null : Colors.grey,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                // Price
                if (!isOwned)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <>[
                      const Icon(
                        Icons.monetization_on,
                        size: 12,
                        color: Colors.amber,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '${frame.price}',
                        style: TextStyle(
                          fontSize: 10,
                          color: canAfford ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
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

            // Locked Overlay (if not owned)
            if (!isOwned)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.lock,
                      color: Colors.white.withValues(alpha: 0.7),
                      size: 24,
                    ),
                  ),
                ),
              ),

            // Purchase/Equip Button
            if (onPurchase != null || onEquip != null)
              Positioned(
                bottom: 4,
                right: 4,
                child: GestureDetector(
                  onTap: isOwned ? onEquip : onPurchase,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: isOwned ? Colors.blue : (canAfford ? Colors.green : Colors.grey),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isOwned ? Icons.stars : Icons.shopping_cart,
                      color: Colors.white,
                      size: 14,
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
    properties.add(DiagnosticsProperty<FrameModel>('frame', frame));
    properties.add(DiagnosticsProperty<bool>('isOwned', isOwned));
    properties.add(DiagnosticsProperty<bool>('isEquipped', isEquipped));
    properties.add(DiagnosticsProperty<bool>('canAfford', canAfford));
    properties.add(ObjectFlagProperty<VoidCallback?>.has('onTap', onTap));
    properties.add(ObjectFlagProperty<VoidCallback?>.has('onEquip', onEquip));
    properties.add(ObjectFlagProperty<VoidCallback?>.has('onPurchase', onPurchase));
  }
}