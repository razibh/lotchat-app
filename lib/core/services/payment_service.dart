import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class PaymentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Coin packages - PaymentCoinPackage ব্যবহার করুন
  static const List<PaymentCoinPackage> coinPackages = [
    PaymentCoinPackage(id: 'pkg1', coins: 1000, price: 1, popular: false),
    PaymentCoinPackage(id: 'pkg2', coins: 5000, price: 5, popular: false),
    PaymentCoinPackage(id: 'pkg3', coins: 10000, price: 10, popular: true),
    PaymentCoinPackage(id: 'pkg4', coins: 50000, price: 50, popular: false),
  ];

  // Check user balance
  Future<bool> checkBalance(String userId, int amount) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) return false;

      final userCoins = userDoc.data()?['coins'] ?? 0;
      return userCoins >= amount;
    } catch (e) {
      debugPrint('Error checking balance: $e');
      return false;
    }
  }

  // Deduct coins
  Future<bool> deductCoins(String userId, int amount) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .update({'coins': FieldValue.increment(-amount)});
      return true;
    } catch (e) {
      debugPrint('Error deducting coins: $e');
      return false;
    }
  }

  // Add coins
  Future<bool> addCoins(String userId, int amount) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .update({'coins': FieldValue.increment(amount)});
      return true;
    } catch (e) {
      debugPrint('Error adding coins: $e');
      return false;
    }
  }

  // Purchase coins
  Future<bool> purchaseCoins({
    required String userId,
    required PaymentCoinPackage package,  // ← PaymentCoinPackage ব্যবহার করুন
  }) async {
    try {
      // Simulate payment success
      await Future.delayed(const Duration(seconds: 1));

      // Add coins to user
      await addCoins(userId, package.coins);

      // Save transaction
      await _saveTransaction(
        userId: userId,
        package: package,
        paymentMethod: 'purchase',
        transactionId: 'txn_${DateTime.now().millisecondsSinceEpoch}',
      );

      return true;
    } catch (e) {
      debugPrint('Purchase error: $e');
      return false;
    }
  }

  // Save transaction
  Future<void> _saveTransaction({
    required String userId,
    required PaymentCoinPackage package,  // ← PaymentCoinPackage ব্যবহার করুন
    required String paymentMethod,
    required String transactionId,
  }) async {
    await _firestore.collection('transactions').add({
      'userId': userId,
      'packageId': package.id,
      'coins': package.coins,
      'amount': package.price,
      'paymentMethod': paymentMethod,
      'transactionId': transactionId,
      'status': 'success',
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // Get purchase history
  Stream<List<PurchaseRecord>> getPurchaseHistory() {
    final User? user = _auth.currentUser;
    if (user == null) return const Stream.empty();

    return _firestore
        .collection('transactions')
        .where('userId', isEqualTo: user.uid)
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => PurchaseRecord.fromJson(doc.data()))
        .toList());
  }

  // Get user balance
  Future<int> getUserBalance(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      return userDoc.data()?['coins'] ?? 0;
    } catch (e) {
      debugPrint('Error getting balance: $e');
      return 0;
    }
  }
}

// ==================== MODEL CLASSES ====================

class PaymentCoinPackage {  // ← নাম পরিবর্তন করে PaymentCoinPackage
  final String id;
  final int coins;
  final double price;
  final bool popular;

  const PaymentCoinPackage({  // ← কনস্ট্রাক্টরের নামও আপডেট
    required this.id,
    required this.coins,
    required this.price,
    required this.popular,
  });

  factory PaymentCoinPackage.fromJson(Map<String, dynamic> json) {
    return PaymentCoinPackage(
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

class PurchaseRecord {
  final String id;
  final int coins;
  final double amount;
  final String paymentMethod;
  final DateTime timestamp;

  PurchaseRecord({
    required this.id,
    required this.coins,
    required this.amount,
    required this.paymentMethod,
    required this.timestamp,
  });

  factory PurchaseRecord.fromJson(Map<String, dynamic> json) {
    return PurchaseRecord(
      id: json['transactionId'] ?? '',
      coins: json['coins'] ?? 0,
      amount: (json['amount'] ?? 0).toDouble(),
      paymentMethod: json['paymentMethod'] ?? '',
      timestamp: (json['timestamp'] as Timestamp).toDate(),
    );
  }
}