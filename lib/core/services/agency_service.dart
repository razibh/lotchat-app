import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_models.dart' as app;
import '../di/service_locator.dart';

// AgencyRole enum
enum AgencyRole {
  leader,
  coLeader,
  elder,
  member,
}

class AgencyService {
  final SupabaseClient _supabase = getService<SupabaseClient>();

  // ==================== AGENCY OPERATIONS ====================
  Future<Agency?> getAgency(String agencyId) async {
    try {
      final response = await _supabase
          .from('agencies')
          .select()
          .eq('id', agencyId)
          .maybeSingle();

      if (response == null) return null;
      return Agency.fromJson(response, response['id']);
    } catch (e) {
      debugPrint('Error getting agency: $e');
      return null;
    }
  }

  Future<Agency?> getAgencyByOwner(String ownerId) async {
    try {
      final response = await _supabase
          .from('agencies')
          .select()
          .eq('owner_id', ownerId)
          .limit(1)
          .maybeSingle();

      if (response == null) return null;
      return Agency.fromJson(response, response['id']);
    } catch (e) {
      debugPrint('Error getting agency by owner: $e');
      return null;
    }
  }

  Stream<Agency?> streamAgency(String agencyId) {
    return _supabase
        .from('agencies')
        .stream(primaryKey: ['id'])
        .eq('id', agencyId)
        .map((data) {
      if (data.isEmpty) return null;
      return Agency.fromJson(data.first, data.first['id']);
    });
  }

  // ==================== MEMBER MANAGEMENT ====================
  Future<void> addMember(String agencyId, String userId) async {
    final Agency? agency = await getAgency(agencyId);
    if (agency == null) throw Exception('Agency not found');

    final session = _supabase.auth.currentSession;
    if (session == null) throw Exception('Not logged in');

    // Check if current user is owner or co-owner
    if (session.user.id != agency.ownerId && !agency.coOwners.contains(session.user.id)) {
      throw Exception('Unauthorized');
    }

    // Add member to agency
    final updatedMembers = [...agency.members, userId];
    await _supabase
        .from('agencies')
        .update({'members': updatedMembers})
        .eq('id', agencyId);

    // Update user's agency info
    await _supabase
        .from('users')
        .update({
      'agency_id': agencyId,
      'role': 'agency',
    })
        .eq('id', userId);
  }

  Future<void> removeMember(String agencyId, String userId) async {
    final Agency? agency = await getAgency(agencyId);
    if (agency == null) throw Exception('Agency not found');

    final session = _supabase.auth.currentSession;
    if (session == null) throw Exception('Not logged in');

    // Check if current user is owner or co-owner
    if (session.user.id != agency.ownerId && !agency.coOwners.contains(session.user.id)) {
      throw Exception('Unauthorized');
    }

    // Remove member from agency
    final updatedMembers = agency.members.where((id) => id != userId).toList();
    await _supabase
        .from('agencies')
        .update({'members': updatedMembers})
        .eq('id', agencyId);

    // Update user's agency info
    await _supabase
        .from('users')
        .update({
      'agency_id': null,
      'role': 'user',
    })
        .eq('id', userId);
  }

  // Change member role
  Future<void> changeMemberRole(
      String agencyId,
      String userId,
      AgencyRole newRole,
      ) async {
    try {
      final Agency? agency = await getAgency(agencyId);
      if (agency == null) throw Exception('Agency not found');

      final session = _supabase.auth.currentSession;
      if (session == null) throw Exception('Not logged in');

      // Check if current user is owner or co-owner
      if (session.user.id != agency.ownerId && !agency.coOwners.contains(session.user.id)) {
        throw Exception('Unauthorized');
      }

      // Update user's role in users collection
      await _supabase
          .from('users')
          .update({
        'agency_role': newRole.toString().split('.').last,
      })
          .eq('id', userId);

      debugPrint('Changed role for user $userId in agency $agencyId to $newRole');
    } catch (e) {
      debugPrint('Error changing member role: $e');
      rethrow;
    }
  }

  // ==================== CO-OWNER MANAGEMENT ====================
  Future<void> addCoOwner(String agencyId, String userId) async {
    final Agency? agency = await getAgency(agencyId);
    if (agency == null) throw Exception('Agency not found');

    final session = _supabase.auth.currentSession;
    if (session == null) throw Exception('Not logged in');

    // Only owner can add co-owners
    if (session.user.id != agency.ownerId) {
      throw Exception('Only owner can add co-owners');
    }

    final updatedCoOwners = [...agency.coOwners, userId];
    await _supabase
        .from('agencies')
        .update({'co_owners': updatedCoOwners})
        .eq('id', agencyId);
  }

  Future<void> removeCoOwner(String agencyId, String userId) async {
    final Agency? agency = await getAgency(agencyId);
    if (agency == null) throw Exception('Agency not found');

    final session = _supabase.auth.currentSession;
    if (session == null) throw Exception('Not logged in');

    // Only owner can remove co-owners
    if (session.user.id != agency.ownerId) {
      throw Exception('Only owner can remove co-owners');
    }

    final updatedCoOwners = agency.coOwners.where((id) => id != userId).toList();
    await _supabase
        .from('agencies')
        .update({'co_owners': updatedCoOwners})
        .eq('id', agencyId);
  }

  // ==================== EARNINGS MANAGEMENT ====================
  Future<void> recordEarnings({
    required String agencyId,
    required String userId,
    required int amount,
    required String source,
  }) async {
    // Get agency data
    final agency = await getAgency(agencyId);
    if (agency == null) throw Exception('Agency not found');

    final commissionRate = agency.commissionRate;
    final int agencyCommission = (amount * commissionRate).round();
    final int userEarnings = amount - agencyCommission;

    // Update agency earnings - type conversion important here
    final updatedMemberEarnings = Map<String, int>.from(agency.memberEarnings);
    updatedMemberEarnings[userId] = (updatedMemberEarnings[userId] ?? 0) + userEarnings;

    await _supabase
        .from('agencies')
        .update({
      'total_earnings': agency.totalEarnings + agencyCommission,
      'member_earnings': updatedMemberEarnings,
    })
        .eq('id', agencyId);

    // Record transaction
    await _supabase.from('agency_transactions').insert({
      'agency_id': agencyId,
      'user_id': userId,
      'amount': amount,
      'agency_commission': agencyCommission,
      'user_earnings': userEarnings,
      'source': source,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  // ==================== WITHDRAW EARNINGS ====================
  Future<bool> withdrawEarnings({
    required String agencyId,
    required String userId,
    required int amount,
  }) async {
    try {
      final Agency? agency = await getAgency(agencyId);
      if (agency == null) throw Exception('Agency not found');

      final int userEarnings = agency.memberEarnings[userId] ?? 0;
      if (userEarnings < amount) throw Exception('Insufficient earnings');

      // Update member earnings
      final updatedEarnings = Map<String, int>.from(agency.memberEarnings);
      updatedEarnings[userId] = userEarnings - amount;

      await _supabase
          .from('agencies')
          .update({
        'member_earnings': updatedEarnings,
      })
          .eq('id', agencyId);

      // Record withdrawal
      await _supabase.from('withdrawals').insert({
        'agency_id': agencyId,
        'user_id': userId,
        'amount': amount,
        'status': 'pending',
        'created_at': DateTime.now().toIso8601String(),
      });

      return true;
    } catch (e) {
      debugPrint('Withdrawal error: $e');
      return false;
    }
  }

  // Get member earnings history
  Future<List<Map<String, dynamic>>> getMemberEarnings(
      String agencyId,
      String userId,
      ) async {
    try {
      final response = await _supabase
          .from('agency_transactions')
          .select()
          .eq('agency_id', agencyId)
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(20);

      return response.map((data) {
        return {
          'amount': data['user_earnings'] ?? 0,
          'description': data['source'] ?? 'Earning',
          'timestamp': DateTime.parse(data['created_at'] ?? DateTime.now().toIso8601String()),
        };
      }).toList();
    } catch (e) {
      debugPrint('Error getting member earnings: $e');

      // Return mock data for testing
      return [
        {
          'amount': 5000,
          'description': 'Commission from hosting',
          'timestamp': DateTime.now().subtract(const Duration(days: 1)),
        },
        {
          'amount': 3000,
          'description': 'Gift received',
          'timestamp': DateTime.now().subtract(const Duration(days: 3)),
        },
        {
          'amount': 2000,
          'description': 'Game winnings',
          'timestamp': DateTime.now().subtract(const Duration(days: 5)),
        },
      ];
    }
  }

  // ==================== GET AGENCY MEMBERS ====================
  Future<List<app.User>> getAgencyMembers(String agencyId) async {
    try {
      final Agency? agency = await getAgency(agencyId);
      if (agency == null) return [];

      final List<app.User> members = [];
      for (String memberId in agency.members) {
        final userData = await _supabase
            .from('users')
            .select()
            .eq('id', memberId)
            .maybeSingle();

        if (userData != null) {
          members.add(app.User.fromJson(userData));
        }
      }

      return members;
    } catch (e) {
      debugPrint('Error getting agency members: $e');
      return [];
    }
  }

  // ==================== AGENCY LEADERBOARD ====================
  Stream<List<AgencyMemberRank>> getAgencyLeaderboard(String agencyId) {
    return _supabase
        .from('agencies')
        .stream(primaryKey: ['id'])
        .eq('id', agencyId)
        .map((data) {
      if (data.isEmpty) return [];

      final agency = Agency.fromJson(data.first, data.first['id']);
      final memberEarnings = agency.memberEarnings;

      final List<AgencyMemberRank> ranks = [];
      memberEarnings.forEach((String userId, int earnings) {
        ranks.add(AgencyMemberRank(userId: userId, earnings: earnings));
      });

      ranks.sort((a, b) => b.earnings.compareTo(a.earnings));
      return ranks;
    });
  }

  // ==================== AGENCY STATS ====================
  Future<AgencyStats> getAgencyStats(String agencyId) async {
    final Agency? agency = await getAgency(agencyId);
    if (agency == null) throw Exception('Agency not found');

    // Get today's earnings
    final DateTime today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day).toIso8601String();

    final todayTransactions = await _supabase
        .from('agency_transactions')
        .select('agency_commission')
        .eq('agency_id', agencyId)
        .gte('created_at', startOfDay);

    int todayEarnings = 0;
    for (var tx in todayTransactions) {
      // Fix: Convert num to int safely
      todayEarnings += _toInt(tx['agency_commission']);
    }

    // Get this month's earnings
    final startOfMonth = DateTime(today.year, today.month, 1).toIso8601String();

    final monthTransactions = await _supabase
        .from('agency_transactions')
        .select('agency_commission')
        .eq('agency_id', agencyId)
        .gte('created_at', startOfMonth);

    int monthEarnings = 0;
    for (var tx in monthTransactions) {
      // Fix: Convert num to int safely
      monthEarnings += _toInt(tx['agency_commission']);
    }

    // Get active members
    final activeMembers = await _supabase
        .from('users')
        .select()
        .eq('agency_id', agencyId)
        .eq('is_online', true);

    return AgencyStats(
      totalEarnings: agency.totalEarnings,
      todayEarnings: todayEarnings,
      monthEarnings: monthEarnings,
      memberCount: agency.members.length,
      activeMembers: activeMembers.length,
    );
  }

  // Helper method to safely convert dynamic to int
  int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is String) return int.tryParse(value) ?? 0;
    if (value is num) return value.toInt();
    return 0;
  }

  // Helper method to safely convert dynamic to double
  double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    if (value is num) return value.toDouble();
    return 0.0;
  }
}

// ==================== MODEL CLASSES ====================

class Agency {
  final String id;
  final String name;
  final String ownerId;
  final List<String> coOwners;
  final List<String> members;
  final double commissionRate;
  final int totalEarnings;
  final Map<String, int> memberEarnings;
  final DateTime createdAt;
  final String status;

  Agency({
    required this.id,
    required this.name,
    required this.ownerId,
    required this.coOwners,
    required this.members,
    required this.commissionRate,
    required this.totalEarnings,
    required this.memberEarnings,
    required this.createdAt,
    required this.status,
  });

  factory Agency.fromJson(Map<String, dynamic> json, String id) {
    // Helper function to safely convert to int
    int toInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is double) return value.round();
      if (value is String) return int.tryParse(value) ?? 0;
      if (value is num) return value.toInt();
      return 0;
    }

    // Helper function to safely convert to double
    double toDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      if (value is num) return value.toDouble();
      return 0.0;
    }

    // Safely convert member_earnings map
    Map<String, int> parseMemberEarnings(dynamic earnings) {
      final Map<String, int> result = {};
      if (earnings is Map) {
        earnings.forEach((key, value) {
          result[key.toString()] = toInt(value);
        });
      }
      return result;
    }

    return Agency(
      id: id,
      name: json['name'] ?? '',
      ownerId: json['owner_id'] ?? '',
      coOwners: List<String>.from(json['co_owners'] ?? []),
      members: List<String>.from(json['members'] ?? []),
      commissionRate: toDouble(json['commission_rate'] ?? 0.1),
      totalEarnings: toInt(json['total_earnings'] ?? 0),
      memberEarnings: parseMemberEarnings(json['member_earnings']),
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      status: json['status'] ?? 'active',
    );
  }
}

class AgencyMemberRank {
  final String userId;
  final int earnings;

  AgencyMemberRank({required this.userId, required this.earnings});
}

class AgencyStats {
  final int totalEarnings;
  final int todayEarnings;
  final int monthEarnings;
  final int memberCount;
  final int activeMembers;

  AgencyStats({
    required this.totalEarnings,
    required this.todayEarnings,
    required this.monthEarnings,
    required this.memberCount,
    required this.activeMembers,
  });
}