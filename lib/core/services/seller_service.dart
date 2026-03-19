import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_models.dart' as app;
import '../di/service_locator.dart';

class SellerService {
  late final SupabaseClient _supabase;

  SellerService() {
    _supabase = getService<SupabaseClient>();
  }

  // Helper to get current user
  String? get _currentUserId => _supabase.auth.currentSession?.user.id;

  // Helper methods
  int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  DateTime _parseDate(dynamic date) {
    if (date == null) return DateTime.now();
    if (date is String) return DateTime.parse(date);
    if (date is DateTime) return date;
    return DateTime.now();
  }

  // ==================== SELLER OPERATIONS ====================

  /// Get seller
  Future<Seller?> getSeller(String sellerId) async {
    try {
      final response = await _supabase
          .from('sellers')
          .select()
          .eq('id', sellerId)
          .maybeSingle();

      if (response != null) {
        return Seller.fromJson(response);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting seller: $e');
      return null;
    }
  }

  /// Stream seller
  Stream<Seller?> streamSeller(String sellerId) {
    try {
      final stream = _supabase
          .from('sellers')
          .stream(primaryKey: ['id']);

      return stream.map((data) {
        for (var item in data) {
          if (item['id'].toString() == sellerId) {
            return Seller.fromJson(item);
          }
        }
        return null;
      });
    } catch (e) {
      debugPrint('Error streaming seller: $e');
      return Stream.value(null);
    }
  }

  /// Create seller account
  Future<Seller?> createSellerAccount({
    required String name,
    double commissionRate = 0.1,
  }) async {
    final userId = _currentUserId;
    if (userId == null) throw Exception('User not logged in');

    try {
      // Check if seller already exists
      final existing = await _supabase
          .from('sellers')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (existing != null) {
        return Seller.fromJson(existing);
      }

      final sellerData = {
        'user_id': userId,
        'name': name,
        'commission_rate': commissionRate,
        'coin_balance': 0,
        'total_coins_sold': 0,
        'total_earnings': 0,
        'packages': [],
        'is_active': true,
        'created_at': DateTime.now().toIso8601String(),
      };

      final response = await _supabase
          .from('sellers')
          .insert(sellerData)
          .select()
          .single();

      return Seller.fromJson(response);
    } catch (e) {
      debugPrint('Error creating seller account: $e');
      return null;
    }
  }

  // ==================== COIN PACKAGES ====================

  /// Get seller packages
  List<CoinPackage> getSellerPackages(Seller seller) {
    return seller.packages;
  }

  /// Update packages
  Future<bool> updatePackages(String sellerId, List<CoinPackage> packages) async {
    final userId = _currentUserId;
    if (userId == null) throw Exception('Not logged in');

    try {
      final seller = await getSeller(sellerId);
      if (seller == null) throw Exception('Seller not found');

      // Check if current user is the seller
      if (seller.userId != userId) {
        throw Exception('Unauthorized');
      }

      final updateQuery = _supabase
          .from('sellers')
          .update({
        'packages': packages.map((p) => p.toJson()).toList(),
        'updated_at': DateTime.now().toIso8601String(),
      });
      await updateQuery.eq('id', sellerId);

      return true;
    } catch (e) {
      debugPrint('Error updating packages: $e');
      return false;
    }
  }

  /// Add package
  Future<bool> addPackage(String sellerId, CoinPackage package) async {
    final userId = _currentUserId;
    if (userId == null) throw Exception('Not logged in');

    try {
      final seller = await getSeller(sellerId);
      if (seller == null) throw Exception('Seller not found');

      if (seller.userId != userId) {
        throw Exception('Unauthorized');
      }

      final updatedPackages = [...seller.packages, package];

      final updateQuery = _supabase
          .from('sellers')
          .update({
        'packages': updatedPackages.map((p) => p.toJson()).toList(),
        'updated_at': DateTime.now().toIso8601String(),
      });
      await updateQuery.eq('id', sellerId);

      return true;
    } catch (e) {
      debugPrint('Error adding package: $e');
      return false;
    }
  }

  /// Remove package
  Future<bool> removePackage(String sellerId, String packageId) async {
    final userId = _currentUserId;
    if (userId == null) throw Exception('Not logged in');

    try {
      final seller = await getSeller(sellerId);
      if (seller == null) throw Exception('Seller not found');

      if (seller.userId != userId) {
        throw Exception('Unauthorized');
      }

      final updatedPackages = seller.packages.where((p) => p.id != packageId).toList();

      final updateQuery = _supabase
          .from('sellers')
          .update({
        'packages': updatedPackages.map((p) => p.toJson()).toList(),
        'updated_at': DateTime.now().toIso8601String(),
      });
      await updateQuery.eq('id', sellerId);

      return true;
    } catch (e) {
      debugPrint('Error removing package: $e');
      return false;
    }
  }

  // ==================== COIN SALES ====================

  /// Sell coins
  Future<bool> sellCoins({
    required String sellerId,
    required String buyerId,
    required CoinPackage package,
  }) async {
    try {
      final seller = await getSeller(sellerId);
      if (seller == null) throw Exception('Seller not found');

      if (!seller.isActive) throw Exception('Seller is not active');

      if (seller.coinBalance < package.coins) {
        throw Exception('Insufficient coin balance');
      }

      // Deduct from seller
      final updateSellerQuery = _supabase
          .from('sellers')
          .update({
        'coin_balance': seller.coinBalance - package.coins,
        'total_coins_sold': seller.totalCoinsSold + package.coins,
        'total_earnings': seller.totalEarnings + package.price,
        'updated_at': DateTime.now().toIso8601String(),
      });
      await updateSellerQuery.eq('id', sellerId);

      // Add to buyer
      final buyerData = await _supabase
          .from('users')
          .select('coins')
          .eq('id', buyerId)
          .maybeSingle();

      final buyerCoins = _toInt(buyerData?['coins']);

      final updateBuyerQuery = _supabase
          .from('users')
          .update({
        'coins': buyerCoins + package.coins,
        'updated_at': DateTime.now().toIso8601String(),
      });
      await updateBuyerQuery.eq('id', buyerId);

      // Record sale
      await _supabase.from('coin_sales').insert({
        'seller_id': sellerId,
        'buyer_id': buyerId,
        'package': package.toJson(),
        'amount': package.price,
        'coins': package.coins,
        'status': 'completed',
        'created_at': DateTime.now().toIso8601String(),
      });

      return true;
    } catch (e) {
      debugPrint('Coin sale error: $e');
      return false;
    }
  }

  // ==================== SELLER STATS ====================

  /// Get seller stats
  Future<SellerStats> getSellerStats(String sellerId) async {
    final seller = await getSeller(sellerId);
    if (seller == null) throw Exception('Seller not found');

    try {
      // Get today's sales
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day).toIso8601String();

      final todaySales = await _supabase
          .from('coin_sales')
          .select()
          .eq('seller_id', sellerId)
          .gte('created_at', startOfDay);

      int todayCoins = 0;
      double todayEarnings = 0;

      for (var sale in todaySales) {
        todayCoins += _toInt(sale['coins']);
        todayEarnings += _toDouble(sale['amount']);
      }

      // Get this month's sales
      final startOfMonth = DateTime(today.year, today.month, 1).toIso8601String();

      final monthSales = await _supabase
          .from('coin_sales')
          .select()
          .eq('seller_id', sellerId)
          .gte('created_at', startOfMonth);

      int monthCoins = 0;
      double monthEarnings = 0;

      for (var sale in monthSales) {
        monthCoins += _toInt(sale['coins']);
        monthEarnings += _toDouble(sale['amount']);
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
    } catch (e) {
      debugPrint('Error getting seller stats: $e');
      return SellerStats(
        totalCoinsSold: seller.totalCoinsSold,
        totalEarnings: seller.totalEarnings,
        coinBalance: seller.coinBalance,
        todayCoins: 0,
        todayEarnings: 0,
        monthCoins: 0,
        monthEarnings: 0,
        totalSales: 0,
      );
    }
  }

  /// Get total sales count
  Future<int> _getTotalSales(String sellerId) async {
    try {
      final response = await _supabase
          .from('coin_sales')
          .select('id')
          .eq('seller_id', sellerId);

      return response.length;
    } catch (e) {
      debugPrint('Error getting total sales: $e');
      return 0;
    }
  }

  // ==================== SALES HISTORY ====================

  /// Get sales history as stream
  Stream<List<CoinSale>> getSalesHistory(String sellerId, {int limit = 50}) {
    try {
      final stream = _supabase
          .from('coin_sales')
          .stream(primaryKey: ['id']);

      return stream.map((data) {
        final filteredData = data.where((item) => item['seller_id'] == sellerId).toList();

        // Sort manually
        filteredData.sort((a, b) {
          final aTime = _parseDate(a['created_at']);
          final bTime = _parseDate(b['created_at']);
          return bTime.compareTo(aTime);
        });

        // Apply limit
        final limitedData = filteredData.take(limit).toList();

        return limitedData.map((item) {
          item['id'] = item['id'].toString();
          return CoinSale.fromJson(item);
        }).toList();
      });
    } catch (e) {
      debugPrint('Error getting sales history stream: $e');
      return Stream.value([]);
    }
  }

  /// Get sales history as future
  Future<List<CoinSale>> getSalesHistoryFuture(String sellerId, {int limit = 50}) async {
    try {
      final response = await _supabase
          .from('coin_sales')
          .select()
          .eq('seller_id', sellerId)
          .order('created_at', ascending: false)
          .limit(limit);

      return response.map((item) {
        item['id'] = item['id'].toString();
        return CoinSale.fromJson(item);
      }).toList();
    } catch (e) {
      debugPrint('Error getting sales history: $e');
      return [];
    }
  }

  // ==================== TOP SELLERS ====================

  /// Get top sellers as stream
  Stream<List<SellerRank>> getTopSellers({int limit = 10}) {
    try {
      final stream = _supabase
          .from('sellers')
          .stream(primaryKey: ['id']);

      return stream.map((data) {
        final filteredData = data.where((item) => item['is_active'] == true).toList();

        // Sort by total coins sold
        filteredData.sort((a, b) {
          final aSold = _toInt(a['total_coins_sold']);
          final bSold = _toInt(b['total_coins_sold']);
          return bSold.compareTo(aSold);
        });

        // Apply limit
        final limitedData = filteredData.take(limit).toList();

        return limitedData.map((item) {
          return SellerRank(
            sellerId: item['id'].toString(),
            name: item['name'] ?? 'Unknown',
            totalCoinsSold: _toInt(item['total_coins_sold']),
            totalEarnings: _toDouble(item['total_earnings']),
          );
        }).toList();
      });
    } catch (e) {
      debugPrint('Error getting top sellers: $e');
      return Stream.value([]);
    }
  }

  /// Get top sellers as future
  Future<List<SellerRank>> getTopSellersFuture({int limit = 10}) async {
    try {
      final response = await _supabase
          .from('sellers')
          .select()
          .eq('is_active', true)
          .order('total_coins_sold', ascending: false)
          .limit(limit);

      return response.map((item) {
        return SellerRank(
          sellerId: item['id'].toString(),
          name: item['name'] ?? 'Unknown',
          totalCoinsSold: _toInt(item['total_coins_sold']),
          totalEarnings: _toDouble(item['total_earnings']),
        );
      }).toList();
    } catch (e) {
      debugPrint('Error getting top sellers: $e');
      return [];
    }
  }

  // ==================== REQUEST COIN RESTOCK ====================

  /// Request coin restock
  Future<bool> requestRestock(int amount) async {
    final userId = _currentUserId;
    if (userId == null) throw Exception('Not logged in');

    try {
      final seller = await getSeller(userId);
      if (seller == null) throw Exception('Seller not found');

      await _supabase.from('restock_requests').insert({
        'seller_id': userId,
        'seller_name': seller.name,
        'amount': amount,
        'status': 'pending',
        'created_at': DateTime.now().toIso8601String(),
      });

      return true;
    } catch (e) {
      debugPrint('Error requesting restock: $e');
      return false;
    }
  }

  // ==================== UPDATE COMMISSION RATE ====================

  /// Update commission rate
  Future<bool> updateCommissionRate(double rate) async {
    final userId = _currentUserId;
    if (userId == null) throw Exception('Not logged in');

    try {
      final updateQuery = _supabase
          .from('sellers')
          .update({
        'commission_rate': rate,
        'updated_at': DateTime.now().toIso8601String(),
      });
      await updateQuery.eq('user_id', userId);

      return true;
    } catch (e) {
      debugPrint('Error updating commission rate: $e');
      return false;
    }
  }

  // ==================== TOGGLE SELLER STATUS ====================

  /// Toggle seller status
  Future<bool> toggleStatus(bool isActive) async {
    final userId = _currentUserId;
    if (userId == null) throw Exception('Not logged in');

    try {
      final updateQuery = _supabase
          .from('sellers')
          .update({
        'is_active': isActive,
        'updated_at': DateTime.now().toIso8601String(),
      });
      await updateQuery.eq('user_id', userId);

      return true;
    } catch (e) {
      debugPrint('Error toggling status: $e');
      return false;
    }
  }

  // ==================== SELLER BALANCE ====================

  /// Add coins to seller balance (admin only)
  Future<bool> addCoinsToBalance(String sellerId, int amount) async {
    try {
      final seller = await getSeller(sellerId);
      if (seller == null) throw Exception('Seller not found');

      final updateQuery = _supabase
          .from('sellers')
          .update({
        'coin_balance': seller.coinBalance + amount,
        'updated_at': DateTime.now().toIso8601String(),
      });
      await updateQuery.eq('id', sellerId);

      return true;
    } catch (e) {
      debugPrint('Error adding coins to balance: $e');
      return false;
    }
  }

  /// Withdraw earnings
  Future<bool> withdrawEarnings(double amount) async {
    final userId = _currentUserId;
    if (userId == null) throw Exception('Not logged in');

    try {
      final seller = await getSeller(userId);
      if (seller == null) throw Exception('Seller not found');

      if (seller.totalEarnings < amount) {
        throw Exception('Insufficient earnings');
      }

      // Record withdrawal request
      await _supabase.from('withdrawal_requests').insert({
        'seller_id': userId,
        'seller_name': seller.name,
        'amount': amount,
        'status': 'pending',
        'created_at': DateTime.now().toIso8601String(),
      });

      return true;
    } catch (e) {
      debugPrint('Error withdrawing earnings: $e');
      return false;
    }
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

  factory Seller.fromJson(Map<String, dynamic> json) {
    return Seller(
      id: json['id']?.toString() ?? '',
      userId: json['user_id'] ?? json['userId'] ?? '',
      name: json['name'] ?? 'Unknown',
      commissionRate: (json['commission_rate'] ?? json['commissionRate'] ?? 0.1).toDouble(),
      coinBalance: json['coin_balance'] ?? json['coinBalance'] ?? 0,
      totalCoinsSold: json['total_coins_sold'] ?? json['totalCoinsSold'] ?? 0,
      totalEarnings: (json['total_earnings'] ?? json['totalEarnings'] ?? 0).toDouble(),
      packages: (json['packages'] as List? ?? [])
          .map((p) => CoinPackage.fromJson(p))
          .toList(),
      isActive: json['is_active'] ?? json['isActive'] ?? true,
      createdAt: _parseDate(json['created_at'] ?? json['createdAt']),
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
      'user_id': userId,
      'name': name,
      'commission_rate': commissionRate,
      'coin_balance': coinBalance,
      'total_coins_sold': totalCoinsSold,
      'total_earnings': totalEarnings,
      'packages': packages.map((p) => p.toJson()).toList(),
      'is_active': isActive,
    };
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

  factory CoinSale.fromJson(Map<String, dynamic> json) {
    return CoinSale(
      id: json['id']?.toString() ?? '',
      sellerId: json['seller_id'] ?? json['sellerId'] ?? '',
      buyerId: json['buyer_id'] ?? json['buyerId'] ?? '',
      package: CoinPackage.fromJson(json['package'] ?? {}),
      amount: (json['amount'] ?? 0).toDouble(),
      coins: json['coins'] ?? 0,
      timestamp: _parseDate(json['created_at'] ?? json['timestamp']),
    );
  }

  static DateTime _parseDate(dynamic date) {
    if (date == null) return DateTime.now();
    if (date is String) return DateTime.parse(date);
    if (date is DateTime) return date;
    return DateTime.now();
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