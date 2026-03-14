class AgencyBadge {

  AgencyBadge({
    required this.agencyId,
    required this.agencyName,
    required this.totalHosts, required this.totalEarnings, required this.commissionRate, required this.isVerified, this.logo,
  });
  final String agencyId;
  final String agencyName;
  final String? logo;
  final int totalHosts;
  final double totalEarnings;
  final double commissionRate; // 5% to 20%
  final bool isVerified;
}

class CoinSellerBadge {

  CoinSellerBadge({
    required this.sellerId,
    required this.businessName,
    required this.discountRate,
    required this.totalSold,
    required this.rating,
    required this.isVerified,
  });
  final String sellerId;
  final String businessName;
  final double discountRate; // কত ডিসকাউন্ট দেয়
  final int totalSold;
  final double rating;
  final bool isVerified;
}