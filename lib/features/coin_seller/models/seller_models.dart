import 'package:flutter/material.dart'; // Color এর জন্য এই ইম্পোর্ট যোগ করুন

// Seller Models
enum SellerStatus { active, inactive, suspended }
enum SellerVerificationStatus { pending, verified, rejected }
enum TransferStatus { pending, completed, failed, refunded }
enum PurchaseStatus { pending, completed, cancelled, failed } // failed যোগ করা হলো
enum TransactionType { sale, purchase, commission, withdrawal }
enum TransactionStatus { pending, completed, failed, cancelled }
enum SellerTier { bronze, silver, gold, platinum, diamond }

class CoinSeller {
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
  final double discountRate;
  final Map<String, double> customPackages;

  // Stats
  final int totalCustomers;
  final double rating;
  final int completedTransactions;
  final int pendingTransactions;
  final DateTime? lastTransactionDate;

  const CoinSeller({
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

  // Helper methods - গেটার হিসেবে ডিফাইন করুন
  double get availableCoins => coinBalance - lockedCoins;

  bool get isVerified => verificationStatus == SellerVerificationStatus.verified;

  bool get isActive => status == SellerStatus.active;

  double calculatePrice(int coins) {
    var originalPrice = coins * 1.0;
    var discount = originalPrice * discountRate / 100;
    return originalPrice - discount;
  }
}

class CoinTransfer {
  final String id;
  final String sellerId;
  final String receiverId;
  final String receiverName;
  final int coins;
  final double amount;
  final double costPrice;
  final double sellerProfit;
  final DateTime transferDate;
  final TransferStatus status;
  final String? note;
  final String? transactionId;

  const CoinTransfer({
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

  // গেটার
  double get profitMargin => costPrice > 0 ? (sellerProfit / costPrice) * 100 : 0;
}

class BulkCoinPurchase {
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

  const BulkCoinPurchase({
    required this.id,
    required this.sellerId,
    required this.coins,
    required this.costPrice,
    required this.pricePerCoin,
    required this.supplier,
    required this.purchaseDate,
    required this.status,
    this.supplierContact,
    this.invoiceUrl,
  });
}

class CoinPackage {
  final String id;
  final String name;
  final int coins;
  final double regularPrice;
  final double? sellerPrice;
  final double discountRate;
  final bool isPopular;
  final String? badge;

  const CoinPackage({
    required this.id,
    required this.name,
    required this.coins,
    required this.regularPrice,
    required this.discountRate,
    this.sellerPrice,
    this.isPopular = false,
    this.badge,
  });

  // গেটার
  double get currentPrice => sellerPrice ?? (regularPrice * (100 - discountRate) / 100);

  double get savings => regularPrice - currentPrice;
}

class SellerTransaction {
  final String id;
  final String sellerId;
  final TransactionType type;
  final double amount;
  final int coins;
  final String counterparty;
  final DateTime date;
  final TransactionStatus status;
  final String? description;

  const SellerTransaction({
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
}

class SellerBadge {
  final String sellerId;
  final String businessName;
  final double discountRate;
  final int totalSold;
  final double rating;
  final bool isVerified;
  final SellerTier tier;

  const SellerBadge({
    required this.sellerId,
    required this.businessName,
    required this.discountRate,
    required this.totalSold,
    required this.rating,
    required this.isVerified,
    required this.tier,
  });

  // গেটার
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

class SellerReview {
  final String id;
  final String sellerId;
  final String userId;
  final String userName;
  final double rating;
  final String comment;
  final DateTime date;
  final int coinsPurchased;

  const SellerReview({
    required this.id,
    required this.sellerId,
    required this.userId,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.date,
    required this.coinsPurchased,
  });
}

// API Request/Response Models
class TransferCoinRequest {
  final String sellerId;
  final String receiverId;
  final int coins;
  final double amount;
  final String paymentMethod;

  const TransferCoinRequest({
    required this.sellerId,
    required this.receiverId,
    required this.coins,
    required this.amount,
    required this.paymentMethod,
  });

  Map<String, dynamic> toJson() => {
    'sellerId': sellerId,
    'receiverId': receiverId,
    'coins': coins,
    'amount': amount,
    'paymentMethod': paymentMethod,
  };
}

class TransferCoinResponse {
  final bool success;
  final String? transactionId;
  final String? message;
  final CoinTransfer? transfer;

  TransferCoinResponse({
    required this.success,
    this.transactionId,
    this.message,
    this.transfer,
  });

  factory TransferCoinResponse.fromJson(Map<String, dynamic> json) {
    TransferStatus? transferStatus;
    if (json['transfer'] != null && json['transfer']['status'] != null) {
      try {
        transferStatus = TransferStatus.values.firstWhere(
              (e) => e.toString() == 'TransferStatus.${json['transfer']['status']}',
        );
      } catch (e) {
        transferStatus = TransferStatus.pending;
      }
    }

    return TransferCoinResponse(
      success: json['success'] ?? false,
      transactionId: json['transactionId'],
      message: json['message'],
      transfer: json['transfer'] != null
          ? CoinTransfer(
        id: json['transfer']['id'] ?? '',
        sellerId: json['transfer']['sellerId'] ?? '',
        receiverId: json['transfer']['receiverId'] ?? '',
        receiverName: json['transfer']['receiverName'] ?? '',
        coins: json['transfer']['coins'] ?? 0,
        amount: (json['transfer']['amount'] ?? 0).toDouble(),
        costPrice: (json['transfer']['costPrice'] ?? 0).toDouble(),
        sellerProfit: (json['transfer']['sellerProfit'] ?? 0).toDouble(),
        transferDate: json['transfer']['transferDate'] != null
            ? DateTime.parse(json['transfer']['transferDate'])
            : DateTime.now(),
        status: transferStatus ?? TransferStatus.pending,
        transactionId: json['transfer']['transactionId'],
      )
          : null,
    );
  }
}

// Extension for coin calculations
extension CoinCalculator on int {
  double get officialPrice => this * 1.0;

  double sellerPriceWithDiscount(double discountRate) {
    return this * 1.0 * (100 - discountRate) / 100;
  }

  double calculateProfit(double costPricePerCoin, double sellingPricePerCoin) {
    return this * (sellingPricePerCoin - costPricePerCoin);
  }
}