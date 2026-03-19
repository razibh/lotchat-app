import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_models.dart' as app;
import 'database_service.dart';
import '../di/service_locator.dart';

class AdminService {
  final SupabaseClient _supabase = getService<SupabaseClient>();
  final DatabaseService _databaseService = DatabaseService();

  // ==================== CHECK ADMIN ====================
  Future<bool> isAdmin(String userId) async {
    final app.User? user = await _databaseService.getUser(userId);
    return user?.role == app.UserRole.admin;
  }

  Future<void> _checkAdmin() async {
    final session = _supabase.auth.currentSession;
    if (session == null) throw Exception('Not logged in');

    final bool isAdminUser = await isAdmin(session.user.id);
    if (!isAdminUser) throw Exception('Unauthorized: Admin access required');
  }

  // ==================== USER MANAGEMENT ====================
  Future<List<app.User>> getAllUsers({
    int limit = 100,
    int offset = 0,
  }) async {
    await _checkAdmin();

    final response = await _supabase
        .from('users')
        .select()
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);

    return response.map((json) => app.User.fromJson(json)).toList();
  }

  Future<List<app.User>> searchUsers(String query) async {
    await _checkAdmin();

    final response = await _supabase
        .from('users')
        .select()
        .or('username.ilike.%$query%,email.ilike.%$query%,phone_number.ilike.%$query%')
        .limit(20);

    return response.map((json) => app.User.fromJson(json)).toList();
  }

  // ==================== BAN/UNBAN USER ====================
  Future<void> banUser({
    required String userId,
    required String reason,
    int durationDays = 0, // 0 = permanent
  }) async {
    await _checkAdmin();

    final session = _supabase.auth.currentSession;

    DateTime? banUntil;
    if (durationDays > 0) {
      banUntil = DateTime.now().add(Duration(days: durationDays));
    }

    await _supabase
        .from('users')
        .update({
      'is_banned': true,
      'ban_reason': reason,
      'banned_at': DateTime.now().toIso8601String(),
      'banned_by': session?.user.id,
      'ban_until': banUntil?.toIso8601String(),
    })
        .eq('id', userId);

    // Log admin action
    await _logAdminAction(
      action: 'ban_user',
      targetId: userId,
      details: {'reason': reason, 'duration': durationDays},
    );
  }

  Future<void> unbanUser(String userId) async {
    await _checkAdmin();

    await _supabase
        .from('users')
        .update({
      'is_banned': false,
      'ban_reason': null,
      'banned_at': null,
      'banned_by': null,
      'ban_until': null,
    })
        .eq('id', userId);

    await _logAdminAction(
      action: 'unban_user',
      targetId: userId,
    );
  }

  // ==================== ADD/REMOVE COINS ====================
  Future<void> addCoinsToUser({
    required String userId,
    required int amount,
    required String reason,
  }) async {
    await _checkAdmin();

    final session = _supabase.auth.currentSession;

    // First get current user data
    final userData = await _supabase
        .from('users')
        .select('coins')
        .eq('id', userId)
        .single();

    final currentCoins = userData['coins'] ?? 0;

    // Update coins
    await _supabase
        .from('users')
        .update({'coins': currentCoins + amount})
        .eq('id', userId);

    // Log transaction
    await _supabase.from('admin_transactions').insert({
      'admin_id': session?.user.id,
      'user_id': userId,
      'amount': amount,
      'type': 'add',
      'reason': reason,
      'created_at': DateTime.now().toIso8601String(),
    });

    await _logAdminAction(
      action: 'add_coins',
      targetId: userId,
      details: {'amount': amount, 'reason': reason},
    );
  }

  Future<void> removeCoinsFromUser({
    required String userId,
    required int amount,
    required String reason,
  }) async {
    await _checkAdmin();

    final session = _supabase.auth.currentSession;

    // First get current user data
    final userData = await _supabase
        .from('users')
        .select('coins')
        .eq('id', userId)
        .single();

    final currentCoins = userData['coins'] ?? 0;
    if (currentCoins < amount) throw Exception('Insufficient coins');

    // Update coins
    await _supabase
        .from('users')
        .update({'coins': currentCoins - amount})
        .eq('id', userId);

    // Log transaction
    await _supabase.from('admin_transactions').insert({
      'admin_id': session?.user.id,
      'user_id': userId,
      'amount': amount,
      'type': 'remove',
      'reason': reason,
      'created_at': DateTime.now().toIso8601String(),
    });

    await _logAdminAction(
      action: 'remove_coins',
      targetId: userId,
      details: {'amount': amount, 'reason': reason},
    );
  }

  // ==================== USER ROLE MANAGEMENT ====================
  Future<void> changeUserRole({
    required String userId,
    required app.UserRole newRole,
  }) async {
    await _checkAdmin();

    await _supabase
        .from('users')
        .update({
      'role': newRole.toString().split('.').last,
    })
        .eq('id', userId);

    await _logAdminAction(
      action: 'change_role',
      targetId: userId,
      details: {'newRole': newRole.toString()},
    );
  }

  // ==================== AGENCY MANAGEMENT ====================
  Future<void> createAgency({
    required String name,
    required String ownerId,
    required double commissionRate,
  }) async {
    await _checkAdmin();

    final response = await _supabase
        .from('agencies')
        .insert({
      'name': name,
      'owner_id': ownerId,
      'commission_rate': commissionRate,
      'members': [ownerId],
      'total_earnings': 0,
      'created_at': DateTime.now().toIso8601String(),
      'status': 'active',
    })
        .select()
        .single();

    // Update owner's role
    await _supabase
        .from('users')
        .update({
      'role': 'agency',
      'agency_id': response['id'],
    })
        .eq('id', ownerId);

    await _logAdminAction(
      action: 'create_agency',
      targetId: response['id'],
      details: {'name': name, 'ownerId': ownerId},
    );
  }

  Future<void> deleteAgency(String agencyId) async {
    await _checkAdmin();

    // Get agency members
    final agency = await _supabase
        .from('agencies')
        .select('members')
        .eq('id', agencyId)
        .single();

    final members = agency['members'] as List? ?? [];

    // Update all members' roles
    for (final memberId in members) {
      await _supabase
          .from('users')
          .update({
        'role': 'user',
        'agency_id': null,
      })
          .eq('id', memberId);
    }

    // Delete agency
    await _supabase
        .from('agencies')
        .delete()
        .eq('id', agencyId);

    await _logAdminAction(
      action: 'delete_agency',
      targetId: agencyId,
    );
  }

  // ==================== SELLER MANAGEMENT ====================
  Future<void> createSeller({
    required String userId,
    required double commissionRate,
    required int initialCoins,
  }) async {
    await _checkAdmin();

    await _supabase
        .from('sellers')
        .insert({
      'user_id': userId,
      'commission_rate': commissionRate,
      'coin_balance': initialCoins,
      'total_coins_sold': 0,
      'total_earnings': 0,
      'created_at': DateTime.now().toIso8601String(),
      'is_active': true,
    });

    // Update user's role
    await _supabase
        .from('users')
        .update({
      'role': 'coinSeller',
    })
        .eq('id', userId);

    await _logAdminAction(
      action: 'create_seller',
      targetId: userId,
      details: {'commissionRate': commissionRate, 'initialCoins': initialCoins},
    );
  }

  Future<void> addCoinsToSeller({
    required String sellerId,
    required int amount,
  }) async {
    await _checkAdmin();

    // Get current seller data
    final sellerData = await _supabase
        .from('sellers')
        .select('coin_balance')
        .eq('id', sellerId)
        .single();

    final currentBalance = sellerData['coin_balance'] ?? 0;

    await _supabase
        .from('sellers')
        .update({'coin_balance': currentBalance + amount})
        .eq('id', sellerId);

    await _logAdminAction(
      action: 'add_coins_to_seller',
      targetId: sellerId,
      details: {'amount': amount},
    );
  }

  // ==================== GIFT MANAGEMENT ====================
  Future<void> addGift(Map<String, dynamic> giftData) async {
    await _checkAdmin();

    final session = _supabase.auth.currentSession;

    await _supabase.from('gifts').insert({
      ...giftData,
      'created_at': DateTime.now().toIso8601String(),
      'created_by': session?.user.id,
    });

    await _logAdminAction(
      action: 'add_gift',
      details: {'giftData': giftData},
    );
  }

  Future<void> updateGift(String giftId, Map<String, dynamic> giftData) async {
    await _checkAdmin();

    final session = _supabase.auth.currentSession;

    await _supabase
        .from('gifts')
        .update({
      ...giftData,
      'updated_at': DateTime.now().toIso8601String(),
      'updated_by': session?.user.id,
    })
        .eq('id', giftId);

    await _logAdminAction(
      action: 'update_gift',
      targetId: giftId,
      details: giftData,
    );
  }

  Future<void> deleteGift(String giftId) async {
    await _checkAdmin();

    await _supabase
        .from('gifts')
        .delete()
        .eq('id', giftId);

    await _logAdminAction(
      action: 'delete_gift',
      targetId: giftId,
    );
  }

  // ==================== DASHBOARD STATS ====================
  Future<AdminDashboardStats> getDashboardStats() async {
    await _checkAdmin();

    // Get counts using separate queries
    final usersResponse = await _supabase
        .from('users')
        .select('*');

    final activeNowResponse = await _supabase
        .from('users')
        .select()
        .eq('is_online', true);

    final DateTime today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day).toIso8601String();

    final todayTransactions = await _supabase
        .from('transactions')
        .select('amount')
        .gte('created_at', startOfDay);

    double totalRevenue = 0;
    for (var tx in todayTransactions) {
      totalRevenue += (tx['amount'] ?? 0).toDouble();
    }

    final roomsResponse = await _supabase
        .from('rooms')
        .select()
        .eq('status', 'active');

    final giftsResponse = await _supabase
        .from('gifts')
        .select();

    final reportsResponse = await _supabase
        .from('reports')
        .select()
        .eq('status', 'pending');

    return AdminDashboardStats(
      totalUsers: usersResponse.length,
      activeNow: activeNowResponse.length,
      todayRevenue: totalRevenue,
      activeRooms: roomsResponse.length,
      totalGifts: giftsResponse.length,
      pendingReports: reportsResponse.length,
    );
  }

  // ==================== LOGGING ====================
  Future<void> _logAdminAction({
    required String action,
    String? targetId,
    Map<String, dynamic>? details,
  }) async {
    final session = _supabase.auth.currentSession;

    await _supabase.from('admin_logs').insert({
      'admin_id': session?.user.id,
      'admin_email': session?.user.email,
      'action': action,
      'target_id': targetId,
      'details': details,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  // Get admin logs
  Stream<List<AdminLog>> getAdminLogs({int limit = 100}) {
    return _supabase
        .from('admin_logs')
        .stream(primaryKey: ['id'])
        .map((data) {
      return data
          .take(limit)
          .map((json) => AdminLog.fromJson(json, json['id']))
          .toList();
    });
  }
}

// ==================== MODEL CLASSES ====================

class AdminDashboardStats {
  final int totalUsers;
  final int activeNow;
  final double todayRevenue;
  final int activeRooms;
  final int totalGifts;
  final int pendingReports;

  AdminDashboardStats({
    required this.totalUsers,
    required this.activeNow,
    required this.todayRevenue,
    required this.activeRooms,
    required this.totalGifts,
    required this.pendingReports,
  });
}

class AdminLog {
  final String id;
  final String adminId;
  final String adminEmail;
  final String action;
  final String? targetId;
  final Map<String, dynamic>? details;
  final DateTime timestamp;

  AdminLog({
    required this.id,
    required this.adminId,
    required this.adminEmail,
    required this.action,
    required this.timestamp,
    this.targetId,
    this.details,
  });

  factory AdminLog.fromJson(Map<String, dynamic> json, String id) {
    return AdminLog(
      id: id,
      adminId: json['admin_id'] ?? '',
      adminEmail: json['admin_email'] ?? '',
      action: json['action'] ?? '',
      targetId: json['target_id'],
      details: json['details'],
      timestamp: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }
}