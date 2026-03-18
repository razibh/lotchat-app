import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../coin_seller/models/seller_models.dart';

class SellerBadgeWidget extends StatelessWidget {
  final SellerBadge badge;
  final VoidCallback? onTap;
  final bool showDetails;

  const SellerBadgeWidget({
    required this.badge,
    this.onTap,
    this.showDetails = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              badge.tierColor.withOpacity(0.3),
              badge.tierColor,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: badge.tierColor.withOpacity(0.5),
          ),
          boxShadow: [
            BoxShadow(
              color: badge.tierColor.withOpacity(0.3),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getTierIcon(badge.tier),
              color: Colors.white,
              size: 14,
            ),
            const SizedBox(width: 4),
            Text(
              badge.businessName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (badge.isVerified) ...[
              const SizedBox(width: 4),
              const Icon(
                Icons.verified,
                color: Colors.blue,
                size: 12,
              ),
            ],
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              margin: const EdgeInsets.only(left: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${badge.discountRate}% off',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                ),
              ),
            ),
            if (showDetails) ...[
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: badge.tierColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  badge.tierName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getTierIcon(SellerTier tier) {
    switch (tier) {
      case SellerTier.bronze:
        return Icons.emoji_events;
      case SellerTier.silver:
        return Icons.emoji_events;
      case SellerTier.gold:
        return Icons.emoji_events;
      case SellerTier.platinum:
        return Icons.diamond;
      case SellerTier.diamond:
        return Icons.diamond;
    }
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<SellerBadge>('badge', badge));
    properties.add(ObjectFlagProperty<VoidCallback?>.has('onTap', onTap));
    properties.add(DiagnosticsProperty<bool>('showDetails', showDetails));
  }
}

class SellerRatingBadge extends StatelessWidget {
  final double rating;
  final int totalSales;

  const SellerRatingBadge({
    required this.rating,
    required this.totalSales,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, color: Colors.amber, size: 12),
          const SizedBox(width: 2),
          Text(
            rating.toStringAsFixed(1),
            style: const TextStyle(
              color: Colors.amber,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 4),
          Container(
            width: 1,
            height: 10,
            color: Colors.white24,
          ),
          const SizedBox(width: 4),
          Text(
            '$totalSales sales',
            style: const TextStyle(color: Colors.white70, fontSize: 8),
          ),
        ],
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DoubleProperty('rating', rating));
    properties.add(IntProperty('totalSales', totalSales));
  }
}