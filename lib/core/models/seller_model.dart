// lib/core/models/seller_model.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart'; // Color এর জন্য

enum SellerStatus {
  active,
  inactive,
  suspended,
  pending,
  verified,
}

enum SellerTier {
  bronze,
  silver,
  gold,
  platinum,
  diamond,
}

class CoinPackage {
  final String id;
  final String name;
  final int coinAmount;
  final double price;
  final double? discountPrice;
  final bool isPopular;
  final bool isBestValue;
  final String? imageUrl;
  final String? description;
  final Map<String, dynamic>? metadata;

  CoinPackage({
    required this.id,
    required this.name,
    required this.coinAmount,
    required this.price,
    this.discountPrice,
    this.isPopular = false,
    this.isBestValue = false,
    this.imageUrl,
    this.description,
    this.metadata,
  });

  factory CoinPackage.fromJson(Map<String, dynamic> json) {
    return CoinPackage(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      coinAmount: json['coinAmount'] ?? 0,
      price: (json['price'] ?? 0).toDouble(),
      discountPrice: json['discountPrice']?.toDouble(),
      isPopular: json['isPopular'] ?? false,
      isBestValue: json['isBestValue'] ?? false,
      imageUrl: json['imageUrl'],
      description: json['description'],
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'coinAmount': coinAmount,
      'price': price,
      'discountPrice': discountPrice,
      'isPopular': isPopular,
      'isBestValue': isBestValue,
      'imageUrl': imageUrl,
      'description': description,
      'metadata': metadata,
    };
  }

  CoinPackage copyWith({
    String? id,
    String? name,
    int? coinAmount,
    double? price,
    double? discountPrice,
    bool? isPopular,
    bool? isBestValue,
    String? imageUrl,
    String? description,
    Map<String, dynamic>? metadata,
  }) {
    return CoinPackage(
      id: id ?? this.id,
      name: name ?? this.name,
      coinAmount: coinAmount ?? this.coinAmount,
      price: price ?? this.price,
      discountPrice: discountPrice ?? this.discountPrice,
      isPopular: isPopular ?? this.isPopular,
      isBestValue: isBestValue ?? this.isBestValue,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      metadata: metadata ?? this.metadata,
    );
  }

  // Helper getters
  double get effectivePrice => discountPrice ?? price;
  double get pricePerCoin => effectivePrice / coinAmount;
  double get discountPercentage {
    if (discountPrice == null) return 0;
    return ((price - discountPrice!) / price * 100).roundToDouble();
  }

  String get priceDisplay => '\$${effectivePrice.toStringAsFixed(2)}';
  String get coinDisplay => '$coinAmount coins';
}

class SellerModel {
  final String id;
  final String userId;
  final String name;
  final int coinBalance;
  final int totalCoinsSold;
  final double commissionRate;
  final List<CoinPackage> packages;   // 1000 coins = $1 etc.
  final bool isActive;
  final DateTime joinedAt;

  // Additional fields
  final String? email;
  final String? phone;
  final String? avatar;
  final String? description;
  final SellerStatus status;
  final SellerTier tier;
  final double totalRevenue;
  final int totalTransactions;
  final double averageRating;
  final int reviewCount;
  final List<String>? reviews;
  final Map<String, dynamic>? stats;
  final Map<String, dynamic>? settings;
  final String? bankAccount;
  final String? paymentMethod;
  final DateTime? lastSaleAt;
  final DateTime? updatedAt;
  final Map<String, dynamic>? metadata;

  SellerModel({
    required this.id,
    required this.userId,
    required this.name,
    this.coinBalance = 0,
    this.totalCoinsSold = 0,
    this.commissionRate = 0.1, // 10% default
    this.packages = const [],
    this.isActive = true,
    required this.joinedAt,
    this.email,
    this.phone,
    this.avatar,
    this.description,
    this.status = SellerStatus.pending,
    this.tier = SellerTier.bronze,
    this.totalRevenue = 0,
    this.totalTransactions = 0,
    this.averageRating = 0,
    this.reviewCount = 0,
    this.reviews,
    this.stats,
    this.settings,
    this.bankAccount,
    this.paymentMethod,
    this.lastSaleAt,
    this.updatedAt,
    this.metadata,
  });

  factory SellerModel.fromJson(Map<String, dynamic> json) {
    return SellerModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      name: json['name'] ?? '',
      coinBalance: json['coinBalance'] ?? 0,
      totalCoinsSold: json['totalCoinsSold'] ?? 0,
      commissionRate: (json['commissionRate'] ?? 0.1).toDouble(),
      packages: (json['packages'] as List? ?? [])
          .map((p) => CoinPackage.fromJson(p))
          .toList(),
      isActive: json['isActive'] ?? true,
      joinedAt: json['joinedAt'] != null
          ? DateTime.parse(json['joinedAt'])
          : DateTime.now(),
      email: json['email'],
      phone: json['phone'],
      avatar: json['avatar'],
      description: json['description'],
      status: _parseSellerStatus(json['status']),
      tier: _parseSellerTier(json['tier']),
      totalRevenue: (json['totalRevenue'] ?? 0).toDouble(),
      totalTransactions: json['totalTransactions'] ?? 0,
      averageRating: (json['averageRating'] ?? 0).toDouble(),
      reviewCount: json['reviewCount'] ?? 0,
      reviews: json['reviews'] != null
          ? List<String>.from(json['reviews'])
          : null,
      stats: json['stats'],
      settings: json['settings'],
      bankAccount: json['bankAccount'],
      paymentMethod: json['paymentMethod'],
      lastSaleAt: json['lastSaleAt'] != null
          ? DateTime.parse(json['lastSaleAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
      metadata: json['metadata'],
    );
  }

  static SellerStatus _parseSellerStatus(String? status) {
    if (status == null) return SellerStatus.pending;
    switch (status.toLowerCase()) {
      case 'active':
        return SellerStatus.active;
      case 'inactive':
        return SellerStatus.inactive;
      case 'suspended':
        return SellerStatus.suspended;
      case 'pending':
        return SellerStatus.pending;
      case 'verified':
        return SellerStatus.verified;
      default:
        return SellerStatus.pending;
    }
  }

  static SellerTier _parseSellerTier(String? tier) {
    if (tier == null) return SellerTier.bronze;
    switch (tier.toLowerCase()) {
      case 'bronze':
        return SellerTier.bronze;
      case 'silver':
        return SellerTier.silver;
      case 'gold':
        return SellerTier.gold;
      case 'platinum':
        return SellerTier.platinum;
      case 'diamond':
        return SellerTier.diamond;
      default:
        return SellerTier.bronze;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'coinBalance': coinBalance,
      'totalCoinsSold': totalCoinsSold,
      'commissionRate': commissionRate,
      'packages': packages.map((p) => p.toJson()).toList(),
      'isActive': isActive,
      'joinedAt': joinedAt.toIso8601String(),
      'email': email,
      'phone': phone,
      'avatar': avatar,
      'description': description,
      'status': status.toString().split('.').last,
      'tier': tier.toString().split('.').last,
      'totalRevenue': totalRevenue,
      'totalTransactions': totalTransactions,
      'averageRating': averageRating,
      'reviewCount': reviewCount,
      'reviews': reviews,
      'stats': stats,
      'settings': settings,
      'bankAccount': bankAccount,
      'paymentMethod': paymentMethod,
      'lastSaleAt': lastSaleAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'metadata': metadata,
    };
  }

  SellerModel copyWith({
    String? id,
    String? userId,
    String? name,
    int? coinBalance,
    int? totalCoinsSold,
    double? commissionRate,
    List<CoinPackage>? packages,
    bool? isActive,
    DateTime? joinedAt,
    String? email,
    String? phone,
    String? avatar,
    String? description,
    SellerStatus? status,
    SellerTier? tier,
    double? totalRevenue,
    int? totalTransactions,
    double? averageRating,
    int? reviewCount,
    List<String>? reviews,
    Map<String, dynamic>? stats,
    Map<String, dynamic>? settings,
    String? bankAccount,
    String? paymentMethod,
    DateTime? lastSaleAt,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
  }) {
    return SellerModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      coinBalance: coinBalance ?? this.coinBalance,
      totalCoinsSold: totalCoinsSold ?? this.totalCoinsSold,
      commissionRate: commissionRate ?? this.commissionRate,
      packages: packages ?? this.packages,
      isActive: isActive ?? this.isActive,
      joinedAt: joinedAt ?? this.joinedAt,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatar: avatar ?? this.avatar,
      description: description ?? this.description,
      status: status ?? this.status,
      tier: tier ?? this.tier,
      totalRevenue: totalRevenue ?? this.totalRevenue,
      totalTransactions: totalTransactions ?? this.totalTransactions,
      averageRating: averageRating ?? this.averageRating,
      reviewCount: reviewCount ?? this.reviewCount,
      reviews: reviews ?? this.reviews,
      stats: stats ?? this.stats,
      settings: settings ?? this.settings,
      bankAccount: bankAccount ?? this.bankAccount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      lastSaleAt: lastSaleAt ?? this.lastSaleAt,
      updatedAt: updatedAt ?? this.updatedAt,
      metadata: metadata ?? this.metadata,
    );
  }

  // Helper getters
  int get packageCount => packages.length;

  CoinPackage? get popularPackage => packages.firstWhere(
        (p) => p.isPopular,
    orElse: () => packages.isNotEmpty ? packages.first : packages[0],
  );

  CoinPackage? get bestValuePackage => packages.firstWhere(
        (p) => p.isBestValue,
    orElse: () => packages.isNotEmpty ? packages.last : packages[0],
  );

  double get totalEarnings => totalRevenue - (totalRevenue * commissionRate);

  double get averageSaleValue {
    if (totalTransactions == 0) return 0;
    return totalRevenue / totalTransactions;
  }

  bool get isVerified => status == SellerStatus.verified;
  bool get isSuspended => status == SellerStatus.suspended;

  String get tierDisplay {
    switch (tier) {
      case SellerTier.bronze:
        return '🥉 Bronze';
      case SellerTier.silver:
        return '🥈 Silver';
      case SellerTier.gold:
        return '🥇 Gold';
      case SellerTier.platinum:
        return '💎 Platinum';
      case SellerTier.diamond:
        return '💎 Diamond';
    }
  }

  Color get tierColor {
    switch (tier) {
      case SellerTier.bronze:
        return Colors.brown;
      case SellerTier.silver:
        return Colors.grey;
      case SellerTier.gold:
        return Colors.amber;
      case SellerTier.platinum:
        return Colors.lightBlue;
      case SellerTier.diamond:
        return Colors.purple;
    }
  }

  // Package management
  SellerModel addPackage(CoinPackage package) {
    final updatedPackages = List<CoinPackage>.from(packages)..add(package);
    return copyWith(packages: updatedPackages);
  }

  SellerModel updatePackage(String packageId, CoinPackage updatedPackage) {
    final updatedPackages = packages.map((p) {
      if (p.id == packageId) return updatedPackage;
      return p;
    }).toList();
    return copyWith(packages: updatedPackages);
  }

  SellerModel removePackage(String packageId) {
    final updatedPackages = packages.where((p) => p.id != packageId).toList();
    return copyWith(packages: updatedPackages);
  }

  // Sale transaction
  SellerModel recordSale(int coinAmount, double revenue) {
    return copyWith(
      coinBalance: coinBalance - coinAmount,
      totalCoinsSold: totalCoinsSold + coinAmount,
      totalRevenue: totalRevenue + revenue,
      totalTransactions: totalTransactions + 1,
      lastSaleAt: DateTime.now(),
    );
  }

  // Add coins to inventory
  SellerModel addCoins(int amount) {
    return copyWith(coinBalance: coinBalance + amount);
  }

  @override
  String toString() {
    return 'SellerModel(id: $id, name: $name, tier: $tier, coins: $coinBalance)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SellerModel &&
        other.id == id &&
        other.userId == userId &&
        other.name == name;
  }

  @override
  int get hashCode => Object.hash(id, userId, name);
}