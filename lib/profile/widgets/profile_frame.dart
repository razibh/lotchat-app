import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../core/models/frame_model.dart';

class ProfileFrame extends StatelessWidget {
  final FrameModel frame;
  final bool isOwned;
  final bool isEquipped;
  final bool canAfford;
  final VoidCallback? onTap;
  final VoidCallback? onEquip;
  final VoidCallback? onPurchase;
  final double size;

  const ProfileFrame({
    super.key,
    required this.frame,
    required this.isOwned,
    required this.isEquipped,
    required this.canAfford,
    this.onTap,
    this.onEquip,
    this.onPurchase,
    this.size = 100,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: isOwned ? frame.rarityColor.withOpacity(0.1) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: isEquipped
              ? Border.all(color: frame.rarityColor, width: 2)
              : null,
        ),
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Frame Preview
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Container(
                      decoration: BoxDecoration(
                        image: frame.imageUrl.isNotEmpty
                            ? DecorationImage(
                          image: NetworkImage(frame.imageUrl),
                          fit: BoxFit.contain,
                        )
                            : null,
                        color: Colors.grey.shade200,
                      ),
                      child: frame.imageUrl.isEmpty
                          ? Icon(
                        _getFrameIcon(frame.type),
                        size: size * 0.3,
                        color: Colors.grey.shade400,
                      )
                          : null,
                    ),
                  ),
                ),

                // Frame Name
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    frame.name,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isOwned ? Colors.black87 : Colors.grey,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),

                // Price/Rarity
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: _buildPriceInfo(),
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
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.lock,
                      color: Colors.white.withOpacity(0.7),
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
                      color: isOwned
                          ? Colors.blue
                          : (canAfford ? Colors.green : Colors.grey),
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

  Widget _buildPriceInfo() {
    if (isOwned) {
      return Text(
        frame.rarity.toString().split('.').last,
        style: TextStyle(
          fontSize: 8,
          color: frame.rarityColor,
          fontWeight: FontWeight.bold,
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.monetization_on,
          size: 10,
          color: Colors.amber,
        ),
        const SizedBox(width: 2),
        Text(
          '${frame.price}',
          style: TextStyle(
            fontSize: 9,
            color: canAfford ? Colors.green : Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  IconData _getFrameIcon(FrameType type) {
    switch (type) {
      case FrameType.basic:
        return Icons.photo; // photo_frame এর পরিবর্তে photo
      case FrameType.vip:
        return Icons.star;
      case FrameType.svip:
        return Icons.diamond;
      case FrameType.event:
        return Icons.event;
      case FrameType.animated:
        return Icons.animation;
    }
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
    properties.add(DoubleProperty('size', size));
  }
}

class ProfileFrameGrid extends StatelessWidget {
  final List<FrameModel> frames;
  final List<String> ownedFrameIds;
  final String? equippedFrameId;
  final int userCoins;
  final Function(FrameModel)? onFrameTap;
  final Function(FrameModel)? onFrameEquip;
  final Function(FrameModel)? onFramePurchase;
  final int crossAxisCount;

  const ProfileFrameGrid({
    super.key,
    required this.frames,
    required this.ownedFrameIds,
    this.equippedFrameId,
    required this.userCoins,
    this.onFrameTap,
    this.onFrameEquip,
    this.onFramePurchase,
    this.crossAxisCount = 3,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 0.9,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: frames.length,
      itemBuilder: (context, index) {
        final frame = frames[index];
        final isOwned = ownedFrameIds.contains(frame.id);
        final isEquipped = frame.id == equippedFrameId;
        final canAfford = userCoins >= frame.price;

        return ProfileFrame(
          frame: frame,
          isOwned: isOwned,
          isEquipped: isEquipped,
          canAfford: canAfford,
          onTap: () => onFrameTap?.call(frame),
          onEquip: isOwned && !isEquipped ? () => onFrameEquip?.call(frame) : null,
          onPurchase: !isOwned && canAfford ? () => onFramePurchase?.call(frame) : null,
        );
      },
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IterableProperty<FrameModel>('frames', frames));
    properties.add(IterableProperty<String>('ownedFrameIds', ownedFrameIds));
    properties.add(StringProperty('equippedFrameId', equippedFrameId));
    properties.add(IntProperty('userCoins', userCoins));
    properties.add(IntProperty('crossAxisCount', crossAxisCount));
  }
}

class ProfileFrameCarousel extends StatelessWidget {
  final List<FrameModel> frames;
  final List<String> ownedFrameIds;
  final String? equippedFrameId;
  final int userCoins;
  final Function(FrameModel)? onFrameTap;
  final Function(FrameModel)? onFrameEquip;
  final Function(FrameModel)? onFramePurchase;

  const ProfileFrameCarousel({
    super.key,
    required this.frames,
    required this.ownedFrameIds,
    this.equippedFrameId,
    required this.userCoins,
    this.onFrameTap,
    this.onFrameEquip,
    this.onFramePurchase,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: frames.length,
        itemBuilder: (context, index) {
          final frame = frames[index];
          final isOwned = ownedFrameIds.contains(frame.id);
          final isEquipped = frame.id == equippedFrameId;
          final canAfford = userCoins >= frame.price;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ProfileFrame(
              frame: frame,
              isOwned: isOwned,
              isEquipped: isEquipped,
              canAfford: canAfford,
              size: 100,
              onTap: () => onFrameTap?.call(frame),
              onEquip: isOwned && !isEquipped ? () => onFrameEquip?.call(frame) : null,
              onPurchase: !isOwned && canAfford ? () => onFramePurchase?.call(frame) : null,
            ),
          );
        },
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IterableProperty<FrameModel>('frames', frames));
    properties.add(IterableProperty<String>('ownedFrameIds', ownedFrameIds));
    properties.add(StringProperty('equippedFrameId', equippedFrameId));
    properties.add(IntProperty('userCoins', userCoins));
  }
}