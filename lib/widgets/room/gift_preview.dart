import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../core/models/gift_model.dart';

class GiftPreviewDialog extends StatelessWidget {
  final GiftModel gift;

  const GiftPreviewDialog({
    super.key,
    required this.gift,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Gift animation
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: _getGiftColor().withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: gift.animationPath.isNotEmpty
                  ? Image.asset(
                gift.animationPath,
                width: 80,
                height: 80,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    _getGiftIcon(),
                    color: _getGiftColor(),
                    size: 80,
                  );
                },
              )
                  : Icon(
                _getGiftIcon(),
                color: _getGiftColor(),
                size: 80,
              ),
            ),

            const SizedBox(height: 16),

            // Gift name
            Text(
              gift.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            // Gift description
            Text(
              _getGiftDescription(),
              style: const TextStyle(
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 16),

            // Price
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.monetization_on,
                    color: Colors.amber,
                    size: 20,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${gift.price} coins',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Limited badge if applicable (based on category)
            if (_isGiftLimited()) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.timer,
                      color: Colors.red,
                      size: 14,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Limited Edition',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 20),

            // Close button
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: _getGiftColor(),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 45),
              ),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to check if gift is limited
  bool _isGiftLimited() {
    return gift.category.toLowerCase() == 'limited' ||
        gift.category.toLowerCase() == 'vip' ||
        gift.category.toLowerCase() == 'svip';
  }

  // Helper methods to get gift properties based on GiftModel fields
  Color _getGiftColor() {
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
        return Colors.purple;
    }
  }

  IconData _getGiftIcon() {
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

  String _getGiftDescription() {
    switch (gift.category.toLowerCase()) {
      case 'cute':
        return 'A cute gift to show your love!';
      case 'luxury':
        return 'Luxury gift for special occasions';
      case 'vip':
        return 'VIP exclusive gift';
      case 'svip':
        return 'SVIP premium gift';
      case 'special':
        return 'Special gift for special people';
      case 'limited':
        return 'Limited edition gift - grab it fast!';
      case 'flowers':
        return 'Beautiful flowers to brighten their day';
      case 'jewelry':
        return 'Elegant jewelry for your loved ones';
      case 'cars':
        return 'Luxury cars for the ultimate gift';
      case 'pets':
        return 'Cute pets for animal lovers';
      case 'food':
        return 'Delicious food gifts';
      case 'drinks':
        return 'Premium drinks collection';
      case 'travel':
        return 'Travel packages for adventure';
      case 'fashion':
        return 'Fashion items for style';
      case 'tech':
        return 'Latest tech gadgets';
      case 'sports':
        return 'Sports equipment and gear';
      default:
        return 'Send this gift to show your appreciation';
    }
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<GiftModel>('gift', gift));
  }
}

// Gift preview with send option
class GiftPreviewWithSend extends StatelessWidget {
  final GiftModel gift;
  final VoidCallback onSend;
  final VoidCallback? onCancel;

  const GiftPreviewWithSend({
    super.key,
    required this.gift,
    required this.onSend,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GiftPreviewDialog(gift: gift),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onCancel ?? () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 45),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onSend,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _getGiftColor(gift),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 45),
                    ),
                    child: const Text('Send'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getGiftColor(GiftModel gift) {
    switch (gift.category.toLowerCase()) {
      case 'cute':
        return Colors.pink;
      case 'luxury':
        return Colors.amber;
      case 'vip':
        return Colors.purple;
      case 'svip':
        return Colors.deepPurple;
      default:
        return Colors.purple;
    }
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<GiftModel>('gift', gift));
    properties.add(ObjectFlagProperty<VoidCallback>.has('onSend', onSend));
  }
}

// Gift preview with quantity selector
class GiftPreviewWithQuantity extends StatefulWidget {
  final GiftModel gift;
  final int initialQuantity;
  final Function(int) onSend;

  const GiftPreviewWithQuantity({
    super.key,
    required this.gift,
    this.initialQuantity = 1,
    required this.onSend,
  });

  @override
  State<GiftPreviewWithQuantity> createState() => _GiftPreviewWithQuantityState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<GiftModel>('gift', gift));
    properties.add(IntProperty('initialQuantity', initialQuantity));
  }
}

class _GiftPreviewWithQuantityState extends State<GiftPreviewWithQuantity> {
  late int _quantity;

  @override
  void initState() {
    super.initState();
    _quantity = widget.initialQuantity;
  }

  @override
  Widget build(BuildContext context) {
    final totalPrice = widget.gift.price * _quantity;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Gift preview
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: _getGiftColor().withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: widget.gift.animationPath.isNotEmpty
                  ? Image.asset(
                widget.gift.animationPath,
                width: 50,
                height: 50,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    _getGiftIcon(),
                    color: _getGiftColor(),
                    size: 50,
                  );
                },
              )
                  : Icon(
                _getGiftIcon(),
                color: _getGiftColor(),
                size: 50,
              ),
            ),

            const SizedBox(height: 12),

            Text(
              widget.gift.name,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            // Quantity selector
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: _quantity > 1
                      ? () => setState(() => _quantity--)
                      : null,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$_quantity',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: () => setState(() => _quantity++),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Total price
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.monetization_on, color: Colors.amber),
                  const SizedBox(width: 4),
                  Text(
                    'Total: $totalPrice coins',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      widget.onSend(_quantity);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _getGiftColor(),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Send'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getGiftColor() {
    switch (widget.gift.category.toLowerCase()) {
      case 'cute':
        return Colors.pink;
      case 'luxury':
        return Colors.amber;
      case 'vip':
        return Colors.purple;
      case 'svip':
        return Colors.deepPurple;
      default:
        return Colors.purple;
    }
  }

  IconData _getGiftIcon() {
    switch (widget.gift.category.toLowerCase()) {
      case 'cute':
        return Icons.favorite;
      case 'luxury':
        return Icons.diamond;
      case 'vip':
        return Icons.star;
      case 'svip':
        return Icons.auto_awesome;
      default:
        return Icons.card_giftcard;
    }
  }
}