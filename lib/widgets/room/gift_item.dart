import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../core/models/gift_model.dart';

class GiftItem extends StatelessWidget {
  final GiftModel gift;
  final bool isSelected;
  final VoidCallback onTap;
  final double size;

  const GiftItem({
    super.key,
    required this.gift,
    required this.isSelected,
    required this.onTap,
    this.size = 80,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: isSelected ? _getGiftColor().withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? _getGiftColor() : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Gift icon with animation indicator
            Stack(
              children: [
                Container(
                  width: size * 0.5,
                  height: size * 0.5,
                  decoration: BoxDecoration(
                    color: _getGiftColor().withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getGiftIcon(),
                    color: _getGiftColor(),
                    size: size * 0.3,
                  ),
                ),
                if (_isGiftAnimated())
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.amber,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.animation,
                        color: Colors.white,
                        size: 10,
                      ),
                    ),
                  ),
                if (_isGiftVip())
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.purple,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.star,
                        color: Colors.white,
                        size: 10,
                      ),
                    ),
                  ),
                if (_isGiftSvip())
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.purple, Colors.pink],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.diamond,
                        color: Colors.white,
                        size: 10,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 4),

            // Gift name
            Text(
              gift.name,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),

            // Gift price
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.monetization_on,
                  size: 10,
                  color: Colors.amber,
                ),
                const SizedBox(width: 2),
                Text(
                  '${gift.price}',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper methods to get gift properties based on GiftModel fields
  Color _getGiftColor() {
    // GiftModel এ color ফিল্ড না থাকলে, ক্যাটাগরি অনুযায়ী কালার দিন
    switch (gift.category.toLowerCase()) {
      case 'cute':
        return Colors.pink;
      case 'luxury':
        return Colors.amber;
      case 'vip':
        return Colors.purple;
      case 'svip':
        return Colors.deepPurple;
      case 'special':
        return Colors.red;
      case 'limited':
        return Colors.orange;
      case 'flowers':
        return Colors.pink.shade300;
      case 'jewelry':
        return Colors.amber.shade700;
      case 'cars':
        return Colors.blue;
      case 'pets':
        return Colors.brown;
      case 'food':
        return Colors.green;
      case 'drinks':
        return Colors.teal;
      case 'travel':
        return Colors.indigo;
      case 'fashion':
        return Colors.purple.shade400;
      case 'tech':
        return Colors.cyan;
      case 'sports':
        return Colors.lime;
      default:
        return Colors.blue;
    }
  }

  IconData _getGiftIcon() {
    // GiftModel এ icon ফিল্ড না থাকলে, ক্যাটাগরি অনুযায়ী আইকন দিন
    switch (gift.category.toLowerCase()) {
      case 'cute':
        return Icons.favorite;
      case 'luxury':
        return Icons.diamond;
      case 'vip':
        return Icons.star;
      case 'svip':
        return Icons.auto_awesome;
      case 'special':
        return Icons.card_giftcard;
      case 'limited':
        return Icons.timer;
      case 'flowers':
        return Icons.local_florist;
      case 'jewelry':
        return Icons.ring_volume;
      case 'cars':
        return Icons.directions_car;
      case 'pets':
        return Icons.pets;
      case 'food':
        return Icons.fastfood;
      case 'drinks':
        return Icons.local_drink;
      case 'travel':
        return Icons.flight;
      case 'fashion':
        return Icons.checkroom;
      case 'tech':
        return Icons.computer;
      case 'sports':
        return Icons.sports_esports;
      default:
        return Icons.card_giftcard;
    }
  }

  bool _isGiftAnimated() {
    // GiftModel এ isAnimated ফিল্ড না থাকলে, অ্যানিমেশন পাথ চেক করুন
    return gift.animationPath != null && gift.animationPath!.isNotEmpty;
  }

  bool _isGiftVip() {
    // GiftModel এ isVip ফিল্ড না থাকলে, ক্যাটাগরি চেক করুন
    return gift.category.toLowerCase() == 'vip';
  }

  bool _isGiftSvip() {
    // GiftModel এ isSvip ফিল্ড না থাকলে, ক্যাটাগরি চেক করুন
    return gift.category.toLowerCase() == 'svip';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<GiftModel>('gift', gift));
    properties.add(DiagnosticsProperty<bool>('isSelected', isSelected));
    properties.add(ObjectFlagProperty<VoidCallback>.has('onTap', onTap));
    properties.add(DoubleProperty('size', size));
  }
}

// Gift item with quantity display
class GiftItemWithQuantity extends StatelessWidget {
  final GiftModel gift;
  final int quantity;
  final bool isSelected;
  final VoidCallback onTap;

  const GiftItemWithQuantity({
    super.key,
    required this.gift,
    required this.quantity,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GiftItem(
          gift: gift,
          isSelected: isSelected,
          onTap: onTap,
        ),
        if (quantity > 1)
          Positioned(
            top: 4,
            right: 4,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: Text(
                '$quantity',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
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
    properties.add(IntProperty('quantity', quantity));
  }
}

// Gift item with discount badge
class GiftItemWithDiscount extends StatelessWidget {
  final GiftModel gift;
  final double discountPercentage;
  final bool isSelected;
  final VoidCallback onTap;

  const GiftItemWithDiscount({
    super.key,
    required this.gift,
    required this.discountPercentage,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final discountedPrice = gift.price * (1 - discountPercentage / 100);

    return Stack(
      children: [
        GiftItem(
          gift: gift,
          isSelected: isSelected,
          onTap: onTap,
        ),
        if (discountPercentage > 0)
          Positioned(
            top: 4,
            left: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '-${discountPercentage.toInt()}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        if (discountPercentage > 0)
          Positioned(
            bottom: 4,
            right: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '${discountedPrice.toInt()}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
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
    properties.add(DoubleProperty('discountPercentage', discountPercentage));
  }
}