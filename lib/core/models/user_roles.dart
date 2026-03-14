enum UserRole {
  user,
  host,
  agency,
  countryManager,
  coinSeller,
  admin,
}

enum BadgeType {
  none,
  agency,
  coinSeller,
  official,
  vip,
}

class UserBadge {

  UserBadge({
    required this.type,
    this.agencyId,
    this.sellerId,
    this.assignedAt,
    this.isVerified = false,
  });
  final BadgeType type;
  final String? agencyId;
  final String? sellerId;
  final DateTime? assignedAt;
  final bool isVerified;

  bool get hasBadge => type != BadgeType.none;
  
  String get badgeName {
    switch (type) {
      case BadgeType.agency:
        return 'Official Agency';
      case BadgeType.coinSeller:
        return 'Coin Seller';
      case BadgeType.official:
        return 'Official';
      case BadgeType.vip:
        return 'VIP';
      default:
        return '';
    }
  }

  Color get badgeColor {
    switch (type) {
      case BadgeType.agency:
        return const Color(0xFF9C27B0); // Purple
      case BadgeType.coinSeller:
        return const Color(0xFFFF9800); // Orange
      case BadgeType.official:
        return const Color(0xFF2196F3); // Blue
      case BadgeType.vip:
        return const Color(0xFFF44336); // Red
      default:
        return Colors.grey;
    }
  }
}