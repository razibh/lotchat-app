import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../di/service_locator.dart';

class PaymentService {
  late final SupabaseClient _supabase;

  PaymentService() {
    _supabase = getService<SupabaseClient>();
  }

  // Coin packages
  static const List<PaymentCoinPackage> coinPackages = [
    PaymentCoinPackage(id: 'pkg1', coins: 1000, price: 1, popular: false),
    PaymentCoinPackage(id: 'pkg2', coins: 5000, price: 5, popular: false),
    PaymentCoinPackage(id: 'pkg3', coins: 10000, price: 10, popular: true),
    PaymentCoinPackage(id: 'pkg4', coins: 50000, price: 50, popular: false),
  ];

  // Helper to get current user
  String? get _currentUserId => _supabase.auth.currentSession?.user.id;

  // Helper to safely convert to int
  int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  // Helper to safely convert to double
  double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  // ==================== BALANCE OPERATIONS ====================

  /// Check user balance
  Future<bool> checkBalance(String userId, int amount) async {
    try {
      final userData = await _supabase
          .from('users')
          .select('coins')
          .eq('id', userId)
          .maybeSingle();

      if (userData == null) return false;

      final userCoins = _toInt(userData['coins']);
      return userCoins >= amount;
    } catch (e) {
      debugPrint('Error checking balance: $e');
      return false;
    }
  }

  /// Deduct coins
  Future<bool> deductCoins(String userId, int amount) async {
    try {
      // Get current coins
      final userData = await _supabase
          .from('users')
          .select('coins')
          .eq('id', userId)
          .maybeSingle();

      if (userData == null) return false;

      final currentCoins = _toInt(userData['coins']);
      final newCoins = currentCoins - amount;

      if (newCoins < 0) return false;

      // Update coins - FIXED: আলাদা করে updateQuery
      final updateQuery = _supabase
          .from('users')
          .update({
        'coins': newCoins,
        'updated_at': DateTime.now().toIso8601String(),
      });
      await updateQuery.eq('id', userId);

      return true;
    } catch (e) {
      debugPrint('Error deducting coins: $e');
      return false;
    }
  }

  /// Add coins
  Future<bool> addCoins(String userId, int amount) async {
    try {
      // Get current coins
      final userData = await _supabase
          .from('users')
          .select('coins')
          .eq('id', userId)
          .maybeSingle();

      if (userData == null) return false;

      final currentCoins = _toInt(userData['coins']);
      final newCoins = currentCoins + amount;

      // Update coins - FIXED: আলাদা করে updateQuery
      final updateQuery = _supabase
          .from('users')
          .update({
        'coins': newCoins,
        'updated_at': DateTime.now().toIso8601String(),
      });
      await updateQuery.eq('id', userId);

      return true;
    } catch (e) {
      debugPrint('Error adding coins: $e');
      return false;
    }
  }

  /// Purchase coins
  Future<bool> purchaseCoins({
    required String userId,
    required PaymentCoinPackage package,
  }) async {
    try {
      // Simulate payment success
      await Future.delayed(const Duration(seconds: 1));

      // Add coins to user
      final success = await addCoins(userId, package.coins);
      if (!success) return false;

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

  /// Save transaction
  Future<void> _saveTransaction({
    required String userId,
    required PaymentCoinPackage package,
    required String paymentMethod,
    required String transactionId,
  }) async {
    try {
      await _supabase.from('transactions').insert({
        'user_id': userId,
        'package_id': package.id,
        'coins': package.coins,
        'amount': package.price,
        'payment_method': paymentMethod,
        'transaction_id': transactionId,
        'status': 'success',
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('Error saving transaction: $e');
    }
  }

  /// Get user balance
  Future<int> getUserBalance(String userId) async {
    try {
      final userData = await _supabase
          .from('users')
          .select('coins')
          .eq('id', userId)
          .maybeSingle();

      return _toInt(userData?['coins']);
    } catch (e) {
      debugPrint('Error getting balance: $e');
      return 0;
    }
  }

  // ==================== PURCHASE HISTORY ====================

  /// Get purchase history as stream
  Stream<List<PurchaseRecord>> getPurchaseHistory() {
    final userId = _currentUserId;
    if (userId == null) return const Stream.empty();

    try {
      final stream = _supabase
          .from('transactions')
          .stream(primaryKey: ['id']);

      return stream.map((data) {
        // Manual filtering
        final filteredData = data.where((item) => item['user_id'] == userId).toList();

        // Manual sorting
        filteredData.sort((a, b) {
          final aTime = DateTime.parse(a['created_at'] ?? DateTime.now().toIso8601String());
          final bTime = DateTime.parse(b['created_at'] ?? DateTime.now().toIso8601String());
          return bTime.compareTo(aTime);
        });

        // Take first 50
        final limited = filteredData.take(50).toList();

        return limited.map((item) {
          item['id'] = item['id'].toString();
          return PurchaseRecord.fromJson(item);
        }).toList();
      });
    } catch (e) {
      debugPrint('Error getting purchase history stream: $e');
      return Stream.value([]);
    }
  }

  /// Get purchase history as future (non-streaming)
  Future<List<PurchaseRecord>> getPurchaseHistoryFuture({int limit = 50}) async {
    final userId = _currentUserId;
    if (userId == null) return [];

    try {
      final response = await _supabase
          .from('transactions')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(limit);

      return response.map((item) {
        item['id'] = item['id'].toString();
        return PurchaseRecord.fromJson(item);
      }).toList();
    } catch (e) {
      debugPrint('Error getting purchase history: $e');
      return [];
    }
  }

  // ==================== ADMIN METHODS ====================

  /// Get all transactions (admin only)
  Future<List<Map<String, dynamic>>> getAllTransactions({int limit = 100}) async {
    try {
      final response = await _supabase
          .from('transactions')
          .select('''
            *,
            users:user_id (username, email)
          ''')
          .order('created_at', ascending: false)
          .limit(limit);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error getting all transactions: $e');
      return [];
    }
  }

  /// Get total revenue (admin only)
  Future<double> getTotalRevenue() async {
    try {
      final response = await _supabase
          .from('transactions')
          .select('amount');

      double total = 0;
      for (var item in response) {
        total += _toDouble(item['amount']);
      }
      return total;
    } catch (e) {
      debugPrint('Error getting total revenue: $e');
      return 0;
    }
  }

  /// Get revenue by date range
  Future<Map<String, double>> getRevenueByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final response = await _supabase
          .from('transactions')
          .select('amount, created_at')
          .gte('created_at', startDate.toIso8601String())
          .lte('created_at', endDate.toIso8601String());

      final Map<String, double> dailyRevenue = {};

      for (var item in response) {
        final date = DateTime.parse(item['created_at']).toIso8601String().substring(0, 10);
        final amount = _toDouble(item['amount']);

        dailyRevenue[date] = (dailyRevenue[date] ?? 0) + amount;
      }

      return dailyRevenue;
    } catch (e) {
      debugPrint('Error getting revenue by date: $e');
      return {};
    }
  }

  // ==================== USER STATISTICS ====================

  /// Get user spending statistics
  Future<Map<String, dynamic>> getUserSpendingStats(String userId) async {
    try {
      final transactions = await _supabase
          .from('transactions')
          .select()
          .eq('user_id', userId);

      int totalPurchases = transactions.length;
      int totalCoins = 0;
      double totalSpent = 0;

      for (var item in transactions) {
        totalCoins += _toInt(item['coins']);
        totalSpent += _toDouble(item['amount']);
      }

      // Get first and last purchase dates
      DateTime? firstPurchase;
      DateTime? lastPurchase;

      if (transactions.isNotEmpty) {
        final dates = transactions.map((t) => DateTime.parse(t['created_at'])).toList();
        dates.sort();
        firstPurchase = dates.first;
        lastPurchase = dates.last;
      }

      return {
        'totalPurchases': totalPurchases,
        'totalCoins': totalCoins,
        'totalSpent': totalSpent,
        'averageSpentPerPurchase': totalPurchases > 0 ? totalSpent / totalPurchases : 0,
        'firstPurchase': firstPurchase?.toIso8601String(),
        'lastPurchase': lastPurchase?.toIso8601String(),
      };
    } catch (e) {
      debugPrint('Error getting user spending stats: $e');
      return {};
    }
  }

  // ==================== VERIFY PAYMENT ====================

  /// Verify payment (for real payment gateways)
  Future<bool> verifyPayment(String transactionId, String paymentMethod) async {
    // This would integrate with actual payment gateways
    // For now, just simulate success
    await Future.delayed(const Duration(seconds: 1));
    return true;
  }

  /// Process refund
  Future<bool> processRefund(String transactionId) async {
    try {
      final transaction = await _supabase
          .from('transactions')
          .select()
          .eq('transaction_id', transactionId)
          .maybeSingle();

      if (transaction == null) return false;

      final userId = transaction['user_id'];
      final coins = _toInt(transaction['coins']);

      // Deduct coins (refund)
      await deductCoins(userId, coins);

      // Update transaction status
      final updateQuery = _supabase
          .from('transactions')
          .update({
        'status': 'refunded',
        'refunded_at': DateTime.now().toIso8601String(),
      });
      await updateQuery.eq('transaction_id', transactionId);

      return true;
    } catch (e) {
      debugPrint('Error processing refund: $e');
      return false;
    }
  }
}

// ==================== MODEL CLASSES ====================

class PaymentCoinPackage {
  final String id;
  final int coins;
  final double price;
  final bool popular;

  const PaymentCoinPackage({
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
  final String? transactionId;
  final String? status;

  PurchaseRecord({
    required this.id,
    required this.coins,
    required this.amount,
    required this.paymentMethod,
    required this.timestamp,
    this.transactionId,
    this.status,
  });

  factory PurchaseRecord.fromJson(Map<String, dynamic> json) {
    return PurchaseRecord(
      id: json['id']?.toString() ?? '',
      coins: json['coins'] ?? 0,
      amount: (json['amount'] ?? 0).toDouble(),
      paymentMethod: json['payment_method'] ?? json['paymentMethod'] ?? '',
      timestamp: _parseDate(json['created_at'] ?? json['timestamp']),
      transactionId: json['transaction_id'] ?? json['transactionId'],
      status: json['status'] ?? 'success',
    );
  }

  static DateTime _parseDate(dynamic date) {
    if (date == null) return DateTime.now();
    if (date is String) return DateTime.parse(date);
    if (date is DateTime) return date;
    return DateTime.now();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'coins': coins,
      'amount': amount,
      'payment_method': paymentMethod,
      'created_at': timestamp.toIso8601String(),
      'transaction_id': transactionId,
      'status': status,
    };
  }
}

class PaymentStats {
  final int totalTransactions;
  final int totalCoins;
  final double totalRevenue;
  final double averageTransaction;
  final int uniqueUsers;
  final Map<String, int> popularPackages;

  PaymentStats({
    required this.totalTransactions,
    required this.totalCoins,
    required this.totalRevenue,
    required this.averageTransaction,
    required this.uniqueUsers,
    required this.popularPackages,
  });
}