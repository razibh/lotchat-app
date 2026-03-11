class SellerModel {
  String id;
  String userId;
  String name;
  int coinBalance;
  int totalCoinsSold;
  double commissionRate;
  List<CoinPackage> packages;   // 10000 coins = $1 etc.
  bool isActive;
  DateTime joinedAt;
}