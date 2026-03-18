import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart'; // 🟢 debugPrint এর জন্য

import '../models/user_models.dart' as app; // 🟢 UserModel এর জন্য
import 'database_service.dart';

class SellerService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseService _databaseService = DatabaseService();

  // ==================== SELLER OPERATIONS ====================
  Future<Seller?> getSeller(String sellerId) async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> doc = await _firestore.collection('sellers').doc(sellerId).get();
      if (doc.exists) {
        return Seller.fromJson(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting seller: $e');
      return null;
    }
  }

  Stream<Seller?> streamSeller(String sellerId) {
    return _firestore
        .collection('sellers')
        .doc(sellerId)
        .snapshots()
        .map((DocumentSnapshot<Map<String, dynamic>> doc) {
      if (doc.exists) {
        return Seller.fromJson(doc.data()!, doc.id);
      }
      return null;
    });
  }

  // ==================== COIN PACKAGES ====================
  List<CoinPackage> getSellerPackages(Seller seller) {
    return seller.packages;
  }

  Future<void> updatePackages(String sellerId, List<CoinPackage> packages) async {
    final User? currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception('Not logged in');

    final Seller? seller = await getSeller(sellerId);
    if (seller == null) throw Exception('Seller not found');

    // Check if current user is the seller
    if (seller.userId != currentUser.uid) {
      throw Exception('Unauthorized');
    }

    await _firestore
        .collection('sellers')
        .doc(sellerId)
        .update({
      'packages': packages.map((CoinPackage p) => p.toJson()).toList(),
    });
  }

  // ==================== COIN SALES ====================
  Future<bool> sellCoins({
    required String sellerId,
    required String buyerId,
    required CoinPackage package,
  }) async {
    try {
      final Seller? seller = await getSeller(sellerId);
      if (seller == null) throw Exception('Seller not found');

      if (!seller.isActive) throw Exception('Seller is not active');

      if (seller.coinBalance < package.coins) {
        throw Exception('Insufficient coin balance');
      }

      await _firestore.runTransaction((Transaction transaction) async {
        // Deduct from seller
        transaction.update(
          _firestore.collection('sellers').doc(sellerId),
          {
            'coinBalance': FieldValue.increment(-package.coins),
            'totalCoinsSold': FieldValue.increment(package.coins),
            'totalEarnings': FieldValue.increment(package.price),
          },
        );

        // Add to buyer
        transaction.update(
          _firestore.collection('users').doc(buyerId),
          {
            'coins': FieldValue.increment(package.coins),
          },
        );

        // Record sale
        transaction.set(
          _firestore.collection('coin_sales').doc(),
          {
            'sellerId': sellerId,
            'buyerId': buyerId,
            'package': package.toJson(),
            'amount': package.price,
            'coins': package.coins,
            'status': 'completed',
            'timestamp': FieldValue.serverTimestamp(),
          },
        );
      });

      return true;
    } catch (e) {
      debugPrint('Coin sale error: $e');
      return false;
    }
  }

  // ==================== SELLER STATS ====================
  Future<SellerStats> getSellerStats(String sellerId) async {
    final Seller? seller = await getSeller(sellerId);
    if (seller == null) throw Exception('Seller not found');

    // Get today's sales
    final DateTime today = DateTime.now();
    final DateTime startOfDay = DateTime(today.year, today.month, today.day);

    final QuerySnapshot<Map<String, dynamic>> todaySales = await _firestore
        .collection('coin_sales')
        .where('sellerId', isEqualTo: sellerId)
        .where('timestamp', isGreaterThanOrEqualTo: startOfDay)
        .get();

    // 🟢 Fix: Convert num to int properly
    int todayCoins = 0;
    for (var doc in todaySales.docs) {
      final num value = doc.data()['coins'] ?? 0;
      todayCoins += value.toInt();
    }

    double todayEarnings = 0;
    for (var doc in todaySales.docs) {
      final num value = doc.data()['amount'] ?? 0;
      todayEarnings += value.toDouble();
    }

    // Get this month's sales
    final DateTime startOfMonth = DateTime(today.year, today.month, 1);

    final QuerySnapshot<Map<String, dynamic>> monthSales = await _firestore
        .collection('coin_sales')
        .where('sellerId', isEqualTo: sellerId)
        .where('timestamp', isGreaterThanOrEqualTo: startOfMonth)
        .get();

    // 🟢 Fix: Convert num to int properly
    int monthCoins = 0;
    for (var doc in monthSales.docs) {
      final num value = doc.data()['coins'] ?? 0;
      monthCoins += value.toInt();
    }

    double monthEarnings = 0;
    for (var doc in monthSales.docs) {
      final num value = doc.data()['amount'] ?? 0;
      monthEarnings += value.toDouble();
    }

    return SellerStats(
      totalCoinsSold: seller.totalCoinsSold,
      totalEarnings: seller.totalEarnings,
      coinBalance: seller.coinBalance,
      todayCoins: todayCoins,
      todayEarnings: todayEarnings,
      monthCoins: monthCoins,
      monthEarnings: monthEarnings,
      totalSales: await _getTotalSales(sellerId),
    );
  }

  Future<int> _getTotalSales(String sellerId) async {
    try {
      final AggregateQuerySnapshot snapshot = await _firestore
          .collection('coin_sales')
          .where('sellerId', isEqualTo: sellerId)
          .count()
          .get();

      return snapshot.count ?? 0;
    } catch (e) {
      debugPrint('Error getting total sales: $e');
      return 0;
    }
  }

  // ==================== SALES HISTORY ====================
  Stream<List<CoinSale>> getSalesHistory(String sellerId, {int limit = 50}) {
    return _firestore
        .collection('coin_sales')
        .where('sellerId', isEqualTo: sellerId)
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots()
        .map((QuerySnapshot<Map<String, dynamic>> snapshot) => snapshot.docs
        .map((QueryDocumentSnapshot<Map<String, dynamic>> doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return CoinSale.fromJson(data, doc.id);
    })
        .toList());
  }

  // ==================== TOP SELLERS ====================
  Stream<List<SellerRank>> getTopSellers({int limit = 10}) {
    return _firestore
        .collection('sellers')
        .where('isActive', isEqualTo: true)
        .orderBy('totalCoinsSold', descending: true)
        .limit(limit)
        .snapshots()
        .map((QuerySnapshot<Map<String, dynamic>> snapshot) => snapshot.docs
        .map((QueryDocumentSnapshot<Map<String, dynamic>> doc) {
      final Map<String, dynamic> data = doc.data();
      return SellerRank(
        sellerId: doc.id,
        name: data['name'] ?? 'Unknown',
        totalCoinsSold: (data['totalCoinsSold'] ?? 0).toInt(),
        totalEarnings: (data['totalEarnings'] ?? 0).toDouble(),
      );
    })
        .toList());
  }

  // ==================== REQUEST COIN RESTOCK ====================
  Future<void> requestRestock(int amount) async {
    final User? currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception('Not logged in');

    final Seller? seller = await getSeller(currentUser.uid);
    if (seller == null) throw Exception('Seller not found');

    await _firestore.collection('restock_requests').add({
      'sellerId': currentUser.uid,
      'sellerName': seller.name,
      'amount': amount,
      'status': 'pending',
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // ==================== UPDATE COMMISSION RATE ====================
  Future<void> updateCommissionRate(double rate) async {
    final User? currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception('Not logged in');

    await _firestore
        .collection('sellers')
        .doc(currentUser.uid)
        .update({
      'commissionRate': rate,
    });
  }

  // ==================== TOGGLE SELLER STATUS ====================
  Future<void> toggleStatus(bool isActive) async {
    final User? currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception('Not logged in');

    await _firestore
        .collection('sellers')
        .doc(currentUser.uid)
        .update({
      'isActive': isActive,
    });
  }
}

// ==================== MODEL CLASSES ====================

class Seller {
  final String id;
  final String userId;
  final String name;
  final double commissionRate;
  final int coinBalance;
  final int totalCoinsSold;
  final double totalEarnings;
  final List<CoinPackage> packages;
  final bool isActive;
  final DateTime createdAt;

  Seller({
    required this.id,
    required this.userId,
    required this.name,
    required this.commissionRate,
    required this.coinBalance,
    required this.totalCoinsSold,
    required this.totalEarnings,
    required this.packages,
    required this.isActive,
    required this.createdAt,
  });

  factory Seller.fromJson(Map<String, dynamic> json, String id) {
    return Seller(
      id: id,
      userId: json['userId'] ?? '',
      name: json['name'] ?? 'Unknown',
      commissionRate: (json['commissionRate'] ?? 0.1).toDouble(),
      coinBalance: json['coinBalance'] ?? 0,
      totalCoinsSold: json['totalCoinsSold'] ?? 0,
      totalEarnings: (json['totalEarnings'] ?? 0).toDouble(),
      packages: (json['packages'] as List? ?? [])
          .map((p) => CoinPackage.fromJson(p))
          .toList(),
      isActive: json['isActive'] ?? true,
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }
}

class CoinPackage {
  final String id;
  final int coins;
  final double price;
  final bool popular;

  CoinPackage({
    required this.id,
    required this.coins,
    required this.price,
    this.popular = false,
  });

  factory CoinPackage.fromJson(Map<String, dynamic> json) {
    return CoinPackage(
      id: json['id'] ?? '',
      coins: json['coins'] ?? 0,
      price: (json['price'] ?? 0).toDouble(),
      popular: json['popular'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'coins': coins,
      'price': price,
      'popular': popular,
    };
  }
}

class CoinSale {
  final String id;
  final String sellerId;
  final String buyerId;
  final CoinPackage package;
  final double amount;
  final int coins;
  final DateTime timestamp;

  CoinSale({
    required this.id,
    required this.sellerId,
    required this.buyerId,
    required this.package,
    required this.amount,
    required this.coins,
    required this.timestamp,
  });

  factory CoinSale.fromJson(Map<String, dynamic> json, String id) {
    return CoinSale(
      id: id,
      sellerId: json['sellerId'] ?? '',
      buyerId: json['buyerId'] ?? '',
      package: CoinPackage.fromJson(json['package'] ?? {}),
      amount: (json['amount'] ?? 0).toDouble(),
      coins: json['coins'] ?? 0,
      timestamp: json['timestamp'] != null
          ? (json['timestamp'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }
}

class SellerStats {
  final int totalCoinsSold;
  final double totalEarnings;
  final int coinBalance;
  final int todayCoins;
  final double todayEarnings;
  final int monthCoins;
  final double monthEarnings;
  final int totalSales;

  SellerStats({
    required this.totalCoinsSold,
    required this.totalEarnings,
    required this.coinBalance,
    required this.todayCoins,
    required this.todayEarnings,
    required this.monthCoins,
    required this.monthEarnings,
    required this.totalSales,
  });
}

class SellerRank {
  final String sellerId;
  final String name;
  final int totalCoinsSold;
  final double totalEarnings;

  SellerRank({
    required this.sellerId,
    required this.name,
    required this.totalCoinsSold,
    required this.totalEarnings,
  });
}