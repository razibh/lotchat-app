import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../constants/app_constants.dart';

class PaymentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Coin packages
  static const List<CoinPackage> coinPackages = <CoinPackage>[
    CoinPackage(id: 'pkg1', coins: 10000, price: 1, popular: false),
    CoinPackage(id: 'pkg2', coins: 20000, price: 2, popular: true),
    CoinPackage(id: 'pkg3', coins: 50000, price: 5, popular: false),
    CoinPackage(id: 'pkg4', coins: 100000, price: 10, popular: false),
    CoinPackage(id: 'pkg5', coins: 200000, price: 20, popular: false),
    CoinPackage(id: 'pkg6', coins: 500000, price: 50, popular: true),
  ];

  // ==================== STRIPE PAYMENT ====================
  Future<bool> purchaseWithStripe({
    required CoinPackage package,
    required String paymentMethodId,
  }) async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      // Create payment intent on your backend
      final Map<String, dynamic> paymentIntent = await _createStripePaymentIntent(
        amount: (package.price * 100).toInt(), // Convert to cents
        currency: 'usd',
        paymentMethodId: paymentMethodId,
      );

      // Confirm payment
      final PaymentMethodParams params = PaymentMethodParams.cardFromMethodId(
        paymentMethodData: PaymentMethodDataCardFromMethodId(
          paymentMethodId: paymentMethodId,
        ),
      );
      
      final PaymentIntent paymentResult = await Stripe.instance.confirmPayment(
        paymentIntent['client_secret'],
        params: params,
      );

      if (paymentResult.status == PaymentIntentsStatus.Succeeded) {
        // Add coins to user
        await _addCoinsToUser(user.uid, package.coins);
        
        // Save transaction
        await _saveTransaction(
          userId: user.uid,
          package: package,
          paymentMethod: 'stripe',
          transactionId: paymentResult.id,
        );
        
        return true;
      }
      
      return false;
    } catch (e) {
      print('Stripe payment error: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>> _createStripePaymentIntent({
    required int amount,
    required String currency,
    required String paymentMethodId,
  }) async {
    // Call your backend to create payment intent
    // This is just a mock implementation
    return <String, dynamic>{
      'client_secret': 'mock_client_secret',
      'id': 'mock_payment_id',
    };
  }

  // ==================== RAZORPAY PAYMENT ====================
  final Razorpay _razorpay = Razorpay();

  Future<void> purchaseWithRazorpay({
    required CoinPackage package,
    required Function(bool success) onResult,
  }) async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      final options = <String, Object>{
        'key': 'YOUR_RAZORPAY_KEY',
        'amount': (package.price * 100).toInt(), // in paise
        'name': 'LotChat',
        'description': '${package.coins} Coins',
        'prefill': <String, >{
          'contact': user.phoneNumber,
          'email': user.email,
        },
      };

      _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, (response) async {
        // Add coins to user
        await _addCoinsToUser(user.uid, package.coins);
        
        // Save transaction
        await _saveTransaction(
          userId: user.uid,
          package: package,
          paymentMethod: 'razorpay',
          transactionId: response.paymentId,
        );
        
        onResult(true);
      });

      _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, (response) {
        onResult(false);
      });

      _razorpay.open(options);
    } catch (e) {
      print('Razorpay error: $e');
      onResult(false);
    }
  }

  // ==================== COIN SELLER PURCHASE ====================
  Future<bool> purchaseFromSeller({
    required String sellerId,
    required CoinPackage package,
  }) async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      // Check seller's coin balance
      final DocumentSnapshot<Map<String, dynamic>> sellerDoc = await _firestore
          .collection('sellers')
          .doc(sellerId)
          .get();
      
      if (!sellerDoc.exists) throw Exception('Seller not found');
      
      final Map<String, dynamic>? sellerData = sellerDoc.data();
      final sellerCoins = sellerData['coinBalance'] ?? 0;
      
      if (sellerCoins < package.coins) {
        throw Exception('Seller has insufficient coins');
      }

      // Process transaction
      await _firestore.runTransaction((Transaction transaction) async {
        // Deduct from seller
        transaction.update(
          _firestore.collection('sellers').doc(sellerId),
          <String, >{'coinBalance': sellerCoins - package.coins},
        );
        
        // Add to user
        transaction.update(
          _firestore.collection('users').doc(user.uid),
          <String, >{'coins': FieldValue.increment(package.coins)},
        );
        
        // Record sale
        transaction.set(
          _firestore.collection('coin_sales').doc(),
          <String, >{
            'sellerId': sellerId,
            'userId': user.uid,
            'package': package.toJson(),
            'amount': package.price,
            'coins': package.coins,
            'timestamp': FieldValue.serverTimestamp(),
          },
        );
      });

      return true;
    } catch (e) {
      print('Seller purchase error: $e');
      return false;
    }
  }

  // ==================== ADMIN ADD COINS ====================
  Future<bool> adminAddCoins({
    required String userId,
    required int amount,
    required String reason,
  }) async {
    try {
      final User? admin = _auth.currentUser;
      if (admin == null) throw Exception('Not logged in');

      // Check if admin
      final DocumentSnapshot<Map<String, dynamic>> adminDoc = await _firestore
          .collection('users')
          .doc(admin.uid)
          .get();
      
      final adminRole = adminDoc.data()?['role'];
      if (adminRole != 3 && adminRole != 4) { // 3=admin, 4=superAdmin
        throw Exception('Unauthorized');
      }

      // Add coins
      await _firestore.runTransaction((Transaction transaction) async {
        transaction.update(
          _firestore.collection('users').doc(userId),
          <String, >{'coins': FieldValue.increment(amount)},
        );
        
        transaction.set(
          _firestore.collection('admin_transactions').doc(),
          <String, >{
            'adminId': admin.uid,
            'userId': userId,
            'amount': amount,
            'reason': reason,
            'timestamp': FieldValue.serverTimestamp(),
          },
        );
      });

      return true;
    } catch (e) {
      print('Admin add coins error: $e');
      return false;
    }
  }

  // ==================== HELPER METHODS ====================
  Future<void> _addCoinsToUser(String userId, int coins) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .update(<String, >{
          'coins': FieldValue.increment(coins),
        });
  }

  Future<void> _saveTransaction({
    required String userId,
    required CoinPackage package,
    required String paymentMethod,
    required String transactionId,
  }) async {
    await _firestore.collection('transactions').add(<String, >{
      'userId': userId,
      'package': package.toJson(),
      'amount': package.price,
      'coins': package.coins,
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
        .map((QuerySnapshot<Map<String, dynamic>> snapshot) => snapshot.docs
            .map((QueryDocumentSnapshot<Map<String, dynamic>> doc) => PurchaseRecord.fromJson(doc.data()))
            .toList(),);
  }
}

// ==================== MODEL CLASSES ====================

class CoinPackage {
  
  CoinPackage({
    required this.id,
    required this.coins,
    required this.price,
    required this.popular,
  });
  
  factory CoinPackage.fromJson(Map<String, dynamic> json) => CoinPackage(
    id: json['id'],
    coins: json['coins'],
    price: json['price'],
    popular: json['popular'],
  );
  final String id;
  final int coins;
  final double price;
  final bool popular;
  
  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'coins': coins,
    'price': price,
    'popular': popular,
  };
}

class PurchaseRecord {
  
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
      amount: json['amount']?.toDouble() ?? 0.0,
      paymentMethod: json['paymentMethod'] ?? '',
      timestamp: (json['timestamp'] as Timestamp).toDate(),
    );
  }
  final String id;
  final int coins;
  final double amount;
  final String paymentMethod;
  final DateTime timestamp;
}