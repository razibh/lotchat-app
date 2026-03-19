import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../di/service_locator.dart';
import 'notification_service.dart';

class ReferralService {
  late final SupabaseClient _supabase;
  late final NotificationService _notificationService;

  ReferralService() {
    _initializeServices();
  }

  void _initializeServices() {
    try {
      _supabase = getService<SupabaseClient>();
      _notificationService = ServiceLocator.instance.get<NotificationService>();
    } catch (e) {
      debugPrint('Error initializing services: $e');
    }
  }

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

  DateTime _parseDate(dynamic date) {
    if (date == null) return DateTime.now();
    if (date is String) return DateTime.parse(date);
    if (date is DateTime) return date;
    return DateTime.now();
  }

  // Generate random code
  String _generateCode() {
    const String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final int random = DateTime.now().millisecondsSinceEpoch;
    String code = '';
    for (var i = 0; i < 8; i++) {
      code += chars[(random + i) % chars.length];
    }
    return code;
  }

  // ==================== GENERATE REFERRAL CODE ====================

  /// Generate referral code
  Future<String?> generateReferralCode() async {
    final userId = _currentUserId;
    if (userId == null) throw Exception('User not logged in');

    try {
      // Check if user already has a code
      final userData = await _supabase
          .from('users')
          .select('referral_code')
          .eq('id', userId)
          .maybeSingle();

      if (userData != null && userData['referral_code'] != null) {
        return userData['referral_code'];
      }

      // Generate unique code
      String code;
      bool exists;
      do {
        code = _generateCode();
        final existing = await _supabase
            .from('referral_codes')
            .select()
            .eq('code', code)
            .maybeSingle();
        exists = existing != null;
      } while (exists);

      // Save code
      await _supabase.from('referral_codes').insert({
        'code': code,
        'user_id': userId,
        'created_at': DateTime.now().toIso8601String(),
      });

      // Update user - FIXED: আলাদা করে updateQuery
      final updateQuery = _supabase
          .from('users')
          .update({
        'referral_code': code,
        'updated_at': DateTime.now().toIso8601String(),
      });
      await updateQuery.eq('id', userId);

      return code;
    } catch (e) {
      debugPrint('Error generating referral code: $e');
      return null;
    }
  }

  // ==================== GET REFERRAL CODE ====================

  /// Get referral code
  Future<String?> getReferralCode(String userId) async {
    try {
      final userData = await _supabase
          .from('users')
          .select('referral_code')
          .eq('id', userId)
          .maybeSingle();

      return userData?['referral_code'];
    } catch (e) {
      debugPrint('Error getting referral code: $e');
      return null;
    }
  }

  // ==================== APPLY REFERRAL CODE ====================

  /// Apply referral code
  Future<bool> applyReferralCode(String code) async {
    final userId = _currentUserId;
    if (userId == null) throw Exception('User not logged in');

    try {
      // Check if code exists
      final codeData = await _supabase
          .from('referral_codes')
          .select()
          .eq('code', code)
          .maybeSingle();

      if (codeData == null) throw Exception('Invalid referral code');

      final referrerId = codeData['user_id'];

      // Check if trying to refer self
      if (referrerId == userId) {
        throw Exception('Cannot use your own referral code');
      }

      // Check if already used
      final userData = await _supabase
          .from('users')
          .select('referred_by')
          .eq('id', userId)
          .maybeSingle();

      if (userData != null && userData['referred_by'] != null) {
        throw Exception('Referral code already used');
      }

      // Get current coins and referrals
      final referrerData = await _supabase
          .from('users')
          .select('coins, total_referrals')
          .eq('id', referrerId)
          .maybeSingle();

      final referrerCoins = _toInt(referrerData?['coins']);
      final referrerTotal = _toInt(referrerData?['total_referrals']);

      // Get current user coins
      final currentUserData = await _supabase
          .from('users')
          .select('coins')
          .eq('id', userId)
          .maybeSingle();

      final currentUserCoins = _toInt(currentUserData?['coins']);

      // Update referred user - FIXED: আলাদা করে updateQuery
      final updateUserQuery = _supabase
          .from('users')
          .update({
        'referred_by': referrerId,
        'referred_at': DateTime.now().toIso8601String(),
        'coins': currentUserCoins + 500, // Welcome bonus
        'updated_at': DateTime.now().toIso8601String(),
      });
      await updateUserQuery.eq('id', userId);

      // Update referrer - FIXED: আলাদা করে updateQuery
      final updateReferrerQuery = _supabase
          .from('users')
          .update({
        'total_referrals': referrerTotal + 1,
        'coins': referrerCoins + 1000, // Referral bonus
        'updated_at': DateTime.now().toIso8601String(),
      });
      await updateReferrerQuery.eq('id', referrerId);

      // Record referral
      await _supabase.from('referrals').insert({
        'referrer_id': referrerId,
        'referred_id': userId,
        'code': code,
        'bonus': 1000,
        'created_at': DateTime.now().toIso8601String(),
      });

      // Send notification to referrer
      try {
        await _notificationService.showNotification(
          title: 'New Referral! 🎉',
          body: 'Someone used your referral code. You earned 1000 coins!',
          data: {'type': 'referral', 'referredId': userId},
        );
      } catch (e) {
        debugPrint('Error sending notification: $e');
      }

      return true;
    } catch (e) {
      debugPrint('Error applying referral code: $e');
      return false;
    }
  }

  // ==================== GET REFERRAL STATS ====================

  /// Get referral stats
  Future<Map<String, dynamic>> getReferralStats() async {
    final userId = _currentUserId;
    if (userId == null) throw Exception('User not logged in');

    try {
      // Get total referrals
      final referralsResponse = await _supabase
          .from('referrals')
          .select()
          .eq('referrer_id', userId);

      final totalReferrals = referralsResponse.length;

      // Get this month's referrals
      final startOfMonth = DateTime(DateTime.now().year, DateTime.now().month, 1).toIso8601String();
      final monthReferrals = referralsResponse.where((item) {
        final date = _parseDate(item['created_at']);
        return date.isAfter(_parseDate(startOfMonth)) || date.isAtSameMomentAs(_parseDate(startOfMonth));
      }).length;

      // Get this week's referrals
      final startOfWeek = DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1)).toIso8601String();
      final weekReferrals = referralsResponse.where((item) {
        final date = _parseDate(item['created_at']);
        return date.isAfter(_parseDate(startOfWeek)) || date.isAtSameMomentAs(_parseDate(startOfWeek));
      }).length;

      // Get user's code
      final code = await getReferralCode(userId);

      // Calculate earnings
      final int totalEarnings = totalReferrals * 1000;
      const int bonusPerReferral = 1000;

      return {
        'code': code,
        'totalReferrals': totalReferrals,
        'monthReferrals': monthReferrals,
        'weekReferrals': weekReferrals,
        'totalEarnings': totalEarnings,
        'bonusPerReferral': bonusPerReferral,
        'nextMilestone': _getNextMilestone(totalReferrals),
      };
    } catch (e) {
      debugPrint('Error getting referral stats: $e');
      return {};
    }
  }

  // ==================== GET REFERRAL HISTORY ====================

  /// Get referral history as stream
  Stream<List<Map<String, dynamic>>> getReferralHistory() {
    final userId = _currentUserId;
    if (userId == null) throw Exception('User not logged in');

    try {
      final stream = _supabase
          .from('referrals')
          .stream(primaryKey: ['id']);

      return stream.map((data) async* {
        final filteredData = data.where((item) => item['referrer_id'] == userId).toList();

        // Sort manually
        filteredData.sort((a, b) {
          final aTime = _parseDate(a['created_at']);
          final bTime = _parseDate(b['created_at']);
          return bTime.compareTo(aTime);
        });

        final List<Map<String, dynamic>> history = [];

        for (final item in filteredData) {
          final referredId = item['referred_id'];

          final referredUser = await _supabase
              .from('users')
              .select('username, avatar_url')
              .eq('id', referredId)
              .maybeSingle();

          history.add({
            'id': item['id'].toString(),
            'referredName': referredUser?['username'] ?? 'User',
            'referredAvatar': referredUser?['avatar_url'],
            'timestamp': _parseDate(item['created_at']),
            'bonus': item['bonus'] ?? 1000,
          });
        }

        yield history;
      }).asyncExpand((event) => event);
    } catch (e) {
      debugPrint('Error getting referral history: $e');
      return Stream.value([]);
    }
  }

  /// Get referral history as future
  Future<List<Map<String, dynamic>>> getReferralHistoryFuture() async {
    final userId = _currentUserId;
    if (userId == null) return [];

    try {
      final referrals = await _supabase
          .from('referrals')
          .select()
          .eq('referrer_id', userId)
          .order('created_at', ascending: false);

      final List<Map<String, dynamic>> history = [];

      for (final item in referrals) {
        final referredId = item['referred_id'];

        final referredUser = await _supabase
            .from('users')
            .select('username, avatar_url')
            .eq('id', referredId)
            .maybeSingle();

        history.add({
          'id': item['id'].toString(),
          'referredName': referredUser?['username'] ?? 'User',
          'referredAvatar': referredUser?['avatar_url'],
          'timestamp': _parseDate(item['created_at']),
          'bonus': item['bonus'] ?? 1000,
        });
      }

      return history;
    } catch (e) {
      debugPrint('Error getting referral history: $e');
      return [];
    }
  }

  // ==================== GET REFERRED BY INFO ====================

  /// Get referred by info
  Future<Map<String, dynamic>?> getReferredBy() async {
    final userId = _currentUserId;
    if (userId == null) throw Exception('User not logged in');

    try {
      final userData = await _supabase
          .from('users')
          .select('referred_by, referred_at')
          .eq('id', userId)
          .maybeSingle();

      final referredBy = userData?['referred_by'];
      if (referredBy == null) return null;

      final referrerData = await _supabase
          .from('users')
          .select('username, avatar_url')
          .eq('id', referredBy)
          .maybeSingle();

      return {
        'userId': referredBy,
        'name': referrerData?['username'] ?? 'User',
        'avatar': referrerData?['avatar_url'],
        'referredAt': _parseDate(userData?['referred_at']),
      };
    } catch (e) {
      debugPrint('Error getting referred by: $e');
      return null;
    }
  }

  // ==================== GET REFERRAL LEADERBOARD ====================

  /// Get referral leaderboard
  Future<List<Map<String, dynamic>>> getReferralLeaderboard({int limit = 10}) async {
    try {
      final response = await _supabase
          .from('users')
          .select('id, username, avatar_url, total_referrals')
          .not('total_referrals', 'is', null)
          .order('total_referrals', ascending: false)
          .limit(limit);

      return response.map((user) {
        return {
          'userId': user['id'] ?? '',
          'name': user['username'] ?? 'User',
          'avatar': user['avatar_url'],
          'totalReferrals': user['total_referrals'] ?? 0,
        };
      }).toList();
    } catch (e) {
      debugPrint('Error getting referral leaderboard: $e');
      return [];
    }
  }

  // ==================== GET REFERRAL LINK ====================

  /// Get referral link
  Future<String?> getReferralLink() async {
    final userId = _currentUserId;
    if (userId == null) return null;

    final code = await getReferralCode(userId);
    if (code == null) return null;

    return 'https://lotchat.app/ref/$code';
  }

  // ==================== SHARE REFERRAL ====================

  /// Share referral
  Future<void> shareReferral() async {
    final link = await getReferralLink();
    if (link == null) return;

    // Share implementation using share_plus
    debugPrint('Sharing referral link: $link');
    // await Share.share('Join me on LotChat! Use my referral code: $link');
  }

  // ==================== GET NEXT MILESTONE ====================

  /// Get next milestone
  Map<String, dynamic> _getNextMilestone(int current) {
    const List<int> milestones = [1, 5, 10, 25, 50, 100, 250, 500, 1000];

    for (int milestone in milestones) {
      if (current < milestone) {
        return {
          'next': milestone,
          'remaining': milestone - current,
          'bonus': milestone * 1000,
        };
      }
    }

    return {
      'next': 1000,
      'remaining': 1000 - current,
      'bonus': 1000000,
    };
  }

  // ==================== ADMIN METHODS - FIXED (FetchOptions সরিয়ে) ====================

  /// Get all referrals (admin only)
  Future<List<Map<String, dynamic>>> getAllReferrals({int limit = 100}) async {
    try {
      final response = await _supabase
          .from('referrals')
          .select('''
            *,
            referrer:referrer_id (username, email),
            referred:referred_id (username, email)
          ''')
          .order('created_at', ascending: false)
          .limit(limit);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error getting all referrals: $e');
      return [];
    }
  }

  /// Get referral statistics (admin only) - FIXED
  Future<Map<String, dynamic>> getReferralStatistics() async {
    try {
      // সরাসরি count() ব্যবহার না করে length নিচ্ছি
      final totalReferrals = await _supabase
          .from('referrals')
          .select('id');
      final totalReferralsCount = totalReferrals.length;

      final totalUsers = await _supabase
          .from('users')
          .select('id');
      final totalUsersCount = totalUsers.length;

      final usersWithReferrals = await _supabase
          .from('users')
          .select('id')
          .not('total_referrals', 'is', null)
          .gt('total_referrals', 0);
      final usersWithReferralsCount = usersWithReferrals.length;

      final totalBonus = await _supabase
          .from('referrals')
          .select('bonus');

      int bonusSum = 0;
      for (var item in totalBonus) {
        bonusSum += _toInt(item['bonus']);
      }

      return {
        'totalReferrals': totalReferralsCount,
        'totalUsers': totalUsersCount,
        'usersWithReferrals': usersWithReferralsCount,
        'totalBonusPaid': bonusSum,
        'averageReferralsPerUser': totalUsersCount > 0
            ? totalReferralsCount / totalUsersCount
            : 0,
      };
    } catch (e) {
      debugPrint('Error getting referral statistics: $e');
      return {};
    }
  }
}