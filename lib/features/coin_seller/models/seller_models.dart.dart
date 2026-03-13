// Seller Models
enum SellerStatus { active, inactive, suspended }
enum SellerVerificationStatus { pending, verified, rejected }
enum TransferStatus { pending, completed, failed, refunded }
enum PurchaseStatus { pending, completed, cancelled }

class CoinSeller {

  CoinSeller({
    required this.id,
    required this.userId,
    required this.businessName,
    required this.ownerName,
    required this.email,
    required this.phone,
    required this.countryId,
    required this.registrationDate,
    required this.status,
    required this.verificationStatus,
    required this.coinBalance,
    required this.lockedCoins,
    required this.totalSold,
    required this.totalRevenue,
    required this.discountRate,
    required this.customPackages,
    required this.totalCustomers,
    required this.rating,
    required this.completedTransactions,
    required this.pendingTransactions,
    this.lastTransactionDate,
  });
  final String id;
  final String userId;
  final String businessName;
  final String ownerName;
  final String email;
  final String phone;
  final String countryId;
  final DateTime registrationDate;
  final SellerStatus status;
  final SellerVerificationStatus verificationStatus;
  
  // Coin Inventory
  final double coinBalance;
  final double lockedCoins;
  final double totalSold;
  final double totalRevenue;
  
  // Pricing
  final double discountRate; // কত ডিসকাউন্ট দেয় (5% to 30%)
  final Map<String, double> customPackages; // packageId -> price
  
  // Stats
  final int totalCustomers;
  final double rating;
  final int completedTransactions;
  final int pendingTransactions;
  final DateTime? lastTransactionDate;

  // Helper methods
  double get availableCoins => coinBalance - lockedCoins;
  
  bool get isVerified => verificationStatus == SellerVerificationStatus.verified;
  
  bool get isActive => status == SellerStatus.active;
  
  double calculatePrice(int coins) {
    var originalPrice = coins * 1.0; // 1 coin = 1 taka base price
    var discount = originalPrice * discountRate / 100;
    return originalPrice - discount;
  }
}

class CoinTransfer {

  CoinTransfer({
    required this.id,
    required this.sellerId,
    required this.receiverId,
    required this.receiverName,
    required this.coins,
    required this.amount,
    required this.costPrice,
    required this.sellerProfit,
    required this.transferDate,
    required this.status,
    this.note,
    this.transactionId,
  });
  final String id;
  final String sellerId;
  final String receiverId; // user ID who receives coins
  final String receiverName;
  final int coins;
  final double amount; // amount paid by receiver
  final double costPrice; // সেলারের কেনা দাম
  final double sellerProfit;
  final DateTime transferDate;
  final TransferStatus status;
  final String? note;
  final String? transactionId;

  double get profitMargin => (sellerProfit / costPrice) * 100;
}

class BulkCoinPurchase {

  BulkCoinPurchase({
    required this.id,
    required this.sellerId,
    required this.coins,
    required this.costPrice,
    required this.pricePerCoin,
    required this.supplier,
    this.supplierContact,
    required this.purchaseDate,
    required this.status,
    this.invoiceUrl,
  });
  final String id;
  final String sellerId;
  final int coins;
  final double costPrice;
  final double pricePerCoin;
  final String supplier;
  final String? supplierContact;
  final DateTime purchaseDate;
  final PurchaseStatus status;
  final String? invoiceUrl;
}

class CoinPackage {

  CoinPackage({
    required this.id,
    required this.name,
    required this.coins,
    required this.regularPrice,
    this.sellerPrice,
    required this.discountRate,
    this.isPopular = false,
    this.badge,
  });
  final String id;
  final String name;
  final int coins;
  final double regularPrice;
  final double? sellerPrice; // সেলারের দেওয়া দাম (ডিসকাউন্টেড)
  final double discountRate;
  final bool isPopular;
  final String? badge;

  double get currentPrice => sellerPrice ?? (regularPrice * (100 - discountRate) / 100);
  
  double get savings => regularPrice - currentPrice;
}

class SellerTransaction {

  SellerTransaction({
    required this.id,
    required this.sellerId,
    required this.type,
    required this.amount,
    required this.coins,
    required this.counterparty,
    required this.date,
    required this.status,
    this.description,
  });
  final String id;
  final String sellerId;
  final TransactionType type;
  final double amount;
  final int coins;
  final String counterparty; // buyer or supplier
  final DateTime date;
  final TransactionStatus status;
  final String? description;
}

enum TransactionType {
  sale, // কয়েন বিক্রি
  purchase, // বাল্ক কয়েন কেনা
  commission, // কমিশন
  withdrawal, // টাকা তুলা
}

enum TransactionStatus {
  pending,
  completed,
  failed,
  cancelled,
}

class SellerBadge {

  SellerBadge({
    required this.sellerId,
    required this.businessName,
    required this.discountRate,
    required this.totalSold,
    required this.rating,
    required this.isVerified,
    required this.tier,
  });
  final String sellerId;
  final String businessName;
  final double discountRate;
  final int totalSold;
  final double rating;
  final bool isVerified;
  final SellerTier tier;

  Color get tierColor {
    switch (tier) {
      case SellerTier.bronze:
        return Colors.brown;
      case SellerTier.silver:
        return Colors.grey;
      case SellerTier.gold:
        return Colors.amber;
      case SellerTier.platinum:
        return Colors.blueGrey;
      case SellerTier.diamond:
        return Colors.cyan;
    }
  }

  String get tierName {
    switch (tier) {
      case SellerTier.bronze:
        return 'Bronze';
      case SellerTier.silver:
        return 'Silver';
      case SellerTier.gold:
        return 'Gold';
      case SellerTier.platinum:
        return 'Platinum';
      case SellerTier.diamond:
        return 'Diamond';
    }
  }
}

enum SellerTier {
  bronze,
  silver,
  gold,
  platinum,
  diamond,
}

class SellerReview {

  SellerReview({
    required this.id,
    required this.sellerId,
    required this.userId,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.date,
    required this.coinsPurchased,
  });
  final String id;
  final String sellerId;
  final String userId;
  final String userName;
  final double rating;
  final String comment;
  final DateTime date;
  final int coinsPurchased;
}

// API Request/Response Models
class TransferCoinRequest {

  TransferCoinRequest({
    required this.sellerId,
    required this.receiverId,
    required this.coins,
    required this.amount,
    required this.paymentMethod,
  });
  final String sellerId;
  final String receiverId;
  final int coins;
  final double amount;
  final String paymentMethod;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'sellerId': sellerId,
    'receiverId': receiverId,
    'coins': coins,
    'amount': amount,
    'paymentMethod': paymentMethod,
  };
}

class TransferCoinResponse {

  TransferCoinResponse({
    required this.success,
    this.transactionId,
    this.message,
    this.transfer,
  });

  factory TransferCoinResponse.fromJson(Map<String, dynamic> json) {
    return TransferCoinResponse(
      success: json['success'] ?? false,
      transactionId: json['transactionId'],
      message: json['message'],
      transfer: json['transfer'] != null 
          ? CoinTransfer(
              id: json['transfer']['id'],
              sellerId: json['transfer']['sellerId'],
              receiverId: json['transfer']['receiverId'],
              receiverName: json['transfer']['receiverName'],
              coins: json['transfer']['coins'],
              amount: json['transfer']['amount'].toDouble(),
              costPrice: json['transfer']['costPrice'].toDouble(),
              sellerProfit: json['transfer']['sellerProfit'].toDouble(),
              transferDate: DateTime.parse(json['transfer']['transferDate']),
              status: TransferStatus.values.firstWhere(
                (e) => e.toString() == 'TransferStatus.${json['transfer']['status']}',
              ),
              transactionId: json['transfer']['transactionId'],
            )
          : null,
    );
  }
  final bool success;
  final String? transactionId;
  final String? message;
  final CoinTransfer? transfer;
}

// Extension for coin calculations
extension CoinCalculator on int {
  double get officialPrice => this * 1.0;
  
  double get sellerPriceWithDiscount(double discountRate) {
    return this * 1.0 * (100 - discountRate) / 100;
  }
  
  double calculateProfit(double costPricePerCoin, double sellingPricePerCoin) {
    return this * (sellingPricePerCoin - costPricePerCoin);
  }
}