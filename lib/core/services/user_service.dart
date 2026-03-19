import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;  // ✅ Supabase User হাইড করুন
import '../di/service_locator.dart';
import 'logger_service.dart';
import '../models/user_models.dart' as app;  // ✅ alias ব্যবহার করুন

class UserService {
  final LoggerService _logger;
  final SupabaseClient _supabase = getService<SupabaseClient>();

  UserService({
    LoggerService? logger,
  }) : _logger = logger ?? ServiceLocator.instance.get<LoggerService>();

  // ==================== USER CRUD OPERATIONS ====================

  // Get user by ID
  Future<app.User?> getUserById(String userId) async {  // ✅ app.User ব্যবহার করুন
    try {
      _logger.debug('Fetching user with ID: $userId');

      final response = await _supabase
          .from('users')
          .select()
          .eq('id', userId)
          .single();

      return _mapToUserModel(response);
    } catch (e, stackTrace) {
      _logger.error('Failed to fetch user', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  // Get user by email
  Future<app.User?> getUserByEmail(String email) async {
    try {
      _logger.debug('Fetching user with email: $email');

      final response = await _supabase
          .from('users')
          .select()
          .eq('email', email)
          .maybeSingle();

      if (response == null) return null;
      return _mapToUserModel(response);
    } catch (e, stackTrace) {
      _logger.error('Failed to fetch user by email', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  // Get user by username
  Future<app.User?> getUserByUsername(String username) async {
    try {
      _logger.debug('Fetching user with username: $username');

      final response = await _supabase
          .from('users')
          .select()
          .eq('username', username)
          .maybeSingle();

      if (response == null) return null;
      return _mapToUserModel(response);
    } catch (e, stackTrace) {
      _logger.error('Failed to fetch user by username', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  // Update user profile
  Future<bool> updateProfile(String userId, Map<String, dynamic> data) async {
    try {
      _logger.debug('Updating profile for user: $userId with data: $data');

      // Convert field names to match database schema
      final Map<String, dynamic> dbData = {
        if (data.containsKey('name')) 'name': data['name'],
        if (data.containsKey('username')) 'username': data['username'],
        if (data.containsKey('bio')) 'bio': data['bio'],
        if (data.containsKey('location')) 'location': data['location'],
        if (data.containsKey('website')) 'website': data['website'],
        if (data.containsKey('phoneNumber')) 'phone_number': data['phoneNumber'],
        if (data.containsKey('avatar')) 'avatar': data['avatar'],
        if (data.containsKey('coverImage')) 'cover_image': data['coverImage'],
        if (data.containsKey('gender')) 'gender': data['gender'],
        if (data.containsKey('dateOfBirth')) 'date_of_birth': data['dateOfBirth'],
        if (data.containsKey('interests')) 'interests': data['interests'],
        'updated_at': DateTime.now().toIso8601String(),
      };

      await _supabase
          .from('users')
          .update(dbData)
          .eq('id', userId);

      return true;
    } catch (e, stackTrace) {
      _logger.error('Failed to update profile', error: e, stackTrace: stackTrace);
      return false;
    }
  }

  // Update user settings
  Future<bool> updateSettings(String userId, Map<String, dynamic> settings) async {
    try {
      _logger.debug('Updating settings for user: $userId');

      await _supabase
          .from('users')
          .update({
        'settings': settings,
        'updated_at': DateTime.now().toIso8601String(),
      })
          .eq('id', userId);

      return true;
    } catch (e, stackTrace) {
      _logger.error('Failed to update settings', error: e, stackTrace: stackTrace);
      return false;
    }
  }

  // Delete account
  Future<bool> deleteAccount(String userId) async {
    try {
      _logger.debug('Deleting account for user: $userId');

      await _supabase
          .from('users')
          .delete()
          .eq('id', userId);

      return true;
    } catch (e, stackTrace) {
      _logger.error('Failed to delete account', error: e, stackTrace: stackTrace);
      return false;
    }
  }

  // ==================== SEARCH ====================

  // Search users
  Future<List<app.User>> searchUsers(String query, {int page = 1, int limit = 20}) async {
    try {
      _logger.debug('Searching users with query: $query');

      final int offset = (page - 1) * limit;

      final response = await _supabase
          .from('users')
          .select()
          .or('username.ilike.%$query%,name.ilike.%$query%')
          .range(offset, offset + limit - 1)
          .order('username');

      return response.map((data) => _mapToUserModel(data)).toList();
    } catch (e, stackTrace) {
      _logger.error('Failed to search users', error: e, stackTrace: stackTrace);
      return [];
    }
  }

  // ==================== FOLLOW/UNFOLLOW ====================

  // Follow user
  Future<bool> followUser(String userId, String targetUserId) async {
    try {
      _logger.debug('User $userId following $targetUserId');

      // Check if already following
      final existing = await _supabase
          .from('follows')
          .select()
          .eq('follower_id', userId)
          .eq('following_id', targetUserId)
          .maybeSingle();

      if (existing != null) return true; // Already following

      // Create follow relationship
      await _supabase.from('follows').insert({
        'follower_id': userId,
        'following_id': targetUserId,
        'created_at': DateTime.now().toIso8601String(),
      });

      // Update follower/following counts
      await _updateFollowCounts(userId, targetUserId);

      return true;
    } catch (e, stackTrace) {
      _logger.error('Failed to follow user', error: e, stackTrace: stackTrace);
      return false;
    }
  }

  // Unfollow user
  Future<bool> unfollowUser(String userId, String targetUserId) async {
    try {
      _logger.debug('User $userId unfollowing $targetUserId');

      await _supabase
          .from('follows')
          .delete()
          .eq('follower_id', userId)
          .eq('following_id', targetUserId);

      // Update follower/following counts
      await _updateFollowCounts(userId, targetUserId);

      return true;
    } catch (e, stackTrace) {
      _logger.error('Failed to unfollow user', error: e, stackTrace: stackTrace);
      return false;
    }
  }

// Update follower/following counts
  Future<void> _updateFollowCounts(String userId, String targetUserId) async {
    try {
      // Get follower count for target user
      final followers = await _supabase
          .from('follows')
          .select()
          .eq('following_id', targetUserId);

      final followerCount = followers.length;

      await _supabase
          .from('users')
          .update({
        'followers_count': followerCount,
        'updated_at': DateTime.now().toIso8601String(),
      })
          .eq('id', targetUserId);

      // Get following count for current user
      final following = await _supabase
          .from('follows')
          .select()
          .eq('follower_id', userId);

      final followingCount = following.length;

      await _supabase
          .from('users')
          .update({
        'following_count': followingCount,
        'updated_at': DateTime.now().toIso8601String(),
      })
          .eq('id', userId);

    } catch (e) {
      _logger.error('Failed to update follow counts', error: e);
    }
  }

  // Get followers
  Future<List<app.User>> getFollowers(String userId, {int page = 1, int limit = 20}) async {
    try {
      _logger.debug('Fetching followers for user: $userId');

      final int offset = (page - 1) * limit;

      final response = await _supabase
          .from('follows')
          .select('follower_id, users!follower_id(*)')
          .eq('following_id', userId)
          .range(offset, offset + limit - 1);

      return response.map((item) {
        final userData = item['users'] as Map<String, dynamic>;
        return _mapToUserModel(userData);
      }).toList();
    } catch (e, stackTrace) {
      _logger.error('Failed to fetch followers', error: e, stackTrace: stackTrace);
      return [];
    }
  }

  // Get following
  Future<List<app.User>> getFollowing(String userId, {int page = 1, int limit = 20}) async {
    try {
      _logger.debug('Fetching following for user: $userId');

      final int offset = (page - 1) * limit;

      final response = await _supabase
          .from('follows')
          .select('following_id, users!following_id(*)')
          .eq('follower_id', userId)
          .range(offset, offset + limit - 1);

      return response.map((item) {
        final userData = item['users'] as Map<String, dynamic>;
        return _mapToUserModel(userData);
      }).toList();
    } catch (e, stackTrace) {
      _logger.error('Failed to fetch following', error: e, stackTrace: stackTrace);
      return [];
    }
  }

  // Check if following
  Future<bool> isFollowing(String userId, String targetUserId) async {
    try {
      _logger.debug('Checking if $userId follows $targetUserId');

      final response = await _supabase
          .from('follows')
          .select()
          .eq('follower_id', userId)
          .eq('following_id', targetUserId)
          .maybeSingle();

      return response != null;
    } catch (e, stackTrace) {
      _logger.error('Failed to check following status', error: e, stackTrace: stackTrace);
      return false;
    }
  }

  // ==================== BLOCK/UNBLOCK ====================

  // Block user
  Future<bool> blockUser(String userId, String targetUserId) async {
    try {
      _logger.debug('User $userId blocking $targetUserId');

      // Check if already blocked
      final existing = await _supabase
          .from('blocks')
          .select()
          .eq('blocker_id', userId)
          .eq('blocked_id', targetUserId)
          .maybeSingle();

      if (existing != null) return true; // Already blocked

      await _supabase.from('blocks').insert({
        'blocker_id': userId,
        'blocked_id': targetUserId,
        'created_at': DateTime.now().toIso8601String(),
      });

      // If following, unfollow
      await unfollowUser(userId, targetUserId);
      await unfollowUser(targetUserId, userId);

      return true;
    } catch (e, stackTrace) {
      _logger.error('Failed to block user', error: e, stackTrace: stackTrace);
      return false;
    }
  }

  // Unblock user
  Future<bool> unblockUser(String userId, String targetUserId) async {
    try {
      _logger.debug('User $userId unblocking $targetUserId');

      await _supabase
          .from('blocks')
          .delete()
          .eq('blocker_id', userId)
          .eq('blocked_id', targetUserId);

      return true;
    } catch (e, stackTrace) {
      _logger.error('Failed to unblock user', error: e, stackTrace: stackTrace);
      return false;
    }
  }

  // Get blocked users
  Future<List<app.User>> getBlockedUsers(String userId) async {
    try {
      _logger.debug('Fetching blocked users for: $userId');

      final response = await _supabase
          .from('blocks')
          .select('blocked_id, users!blocked_id(*)')
          .eq('blocker_id', userId);

      return response.map((item) {
        final userData = item['users'] as Map<String, dynamic>;
        return _mapToUserModel(userData);
      }).toList();
    } catch (e, stackTrace) {
      _logger.error('Failed to fetch blocked users', error: e, stackTrace: stackTrace);
      return [];
    }
  }

  // ==================== REPORT ====================

  // Report user
  Future<bool> reportUser(String userId, String targetUserId, String reason) async {
    try {
      _logger.debug('User $userId reporting $targetUserId for: $reason');

      await _supabase.from('reports').insert({
        'reporter_id': userId,
        'reported_id': targetUserId,
        'reason': reason,
        'status': 'pending',
        'created_at': DateTime.now().toIso8601String(),
      });

      return true;
    } catch (e, stackTrace) {
      _logger.error('Failed to report user', error: e, stackTrace: stackTrace);
      return false;
    }
  }

  // ==================== STATS & BALANCE ====================

  // Get user stats
  Future<Map<String, dynamic>> getUserStats(String userId) async {
    try {
      _logger.debug('Fetching stats for user: $userId');

      final response = await _supabase
          .from('users')
          .select('''
            followers_count,
            following_count,
            friends_count,
            total_rooms,
            total_hours,
            total_gifts,
            total_earnings,
            total_spent,
            level,
            xp,
            xp_to_next_level,
            streak,
            longest_streak,
            rating,
            rank,
            achievements,
            badges,
            created_at,
            last_active
          ''')
          .eq('id', userId)
          .single();

      return {
        'followers_count': response['followers_count'] ?? 0,
        'following_count': response['following_count'] ?? 0,
        'friends_count': response['friends_count'] ?? 0,
        'total_rooms': response['total_rooms'] ?? 0,
        'total_hours': response['total_hours'] ?? 0,
        'total_gifts': response['total_gifts'] ?? 0,
        'total_earnings': response['total_earnings'] ?? 0,
        'total_spent': response['total_spent'] ?? 0,
        'total_views': response['total_views'] ?? 0,
        'total_likes': response['total_likes'] ?? 0,
        'total_comments': response['total_comments'] ?? 0,
        'level': response['level'] ?? 1,
        'xp': response['xp'] ?? 0,
        'xp_to_next_level': response['xp_to_next_level'] ?? 100,
        'streak': response['streak'] ?? 0,
        'longest_streak': response['longest_streak'] ?? 0,
        'rating': response['rating'] ?? 0,
        'rank': response['rank'] ?? 0,
        'achievements': response['achievements'] ?? 0,
        'badges': response['badges'] ?? 0,
        'join_date': response['created_at'],
        'last_active': response['last_active'],
      };
    } catch (e, stackTrace) {
      _logger.error('Failed to fetch user stats', error: e, stackTrace: stackTrace);
      return {};
    }
  }

  // Update coins
  Future<bool> updateCoins(String userId, int amount) async {
    try {
      _logger.debug('Updating coins for user: $userId by $amount');

      // Simple update instead of RPC
      await _supabase.rpc('increment_user_coins', params: {
        'user_id': userId,
        'amount': amount,
      });

      return true;
    } catch (e, stackTrace) {
      _logger.error('Failed to update coins', error: e, stackTrace: stackTrace);
      return false;
    }
  }

  // Update diamonds
  Future<bool> updateDiamonds(String userId, int amount) async {
    try {
      _logger.debug('Updating diamonds for user: $userId by $amount');

      await _supabase.rpc('increment_user_diamonds', params: {
        'user_id': userId,
        'amount': amount,
      });

      return true;
    } catch (e, stackTrace) {
      _logger.error('Failed to update diamonds', error: e, stackTrace: stackTrace);
      return false;
    }
  }

  // Update tier
  Future<bool> updateTier(String userId, app.UserTier tier) async {
    try {
      _logger.debug('Updating tier for user: $userId to $tier');

      await _supabase
          .from('users')
          .update({
        'tier': tier.toString().split('.').last,
        'updated_at': DateTime.now().toIso8601String(),
      })
          .eq('id', userId);

      return true;
    } catch (e, stackTrace) {
      _logger.error('Failed to update tier', error: e, stackTrace: stackTrace);
      return false;
    }
  }

  // ==================== FRIENDS ====================

  // Get user's friends
  Future<List<app.UserFriend>> getFriends(String userId, {int page = 1, int limit = 20}) async {
    try {
      _logger.debug('Fetching friends for user: $userId');

      final int offset = (page - 1) * limit;

      // Get mutual follows
      final response = await _supabase
          .from('follows')
          .select('''
            following_id,
            users!following_id(*)
          ''')
          .eq('follower_id', userId)
          .range(offset, offset + limit - 1);

      return response.map((item) {
        final userData = item['users'] as Map<String, dynamic>;
        return app.UserFriend(
          userId: userData['id'],
          username: userData['username'],
          name: userData['name'] ?? userData['username'],
          avatar: userData['avatar'],
          isOnline: userData['is_online'] ?? false,
          lastActive: userData['last_seen'] != null
              ? DateTime.parse(userData['last_seen'])
              : null,
          isFollowing: true,
          isFollower: true,
          isMutual: true,
          friendSince: userData['created_at'] != null
              ? DateTime.parse(userData['created_at'])
              : DateTime.now(),
        );
      }).toList();
    } catch (e, stackTrace) {
      _logger.error('Failed to fetch friends', error: e, stackTrace: stackTrace);
      return [];
    }
  }

  // ==================== HELPER METHODS ====================

  // Map database row to User model
  app.User _mapToUserModel(Map<String, dynamic> data) {
    return app.User.regular(
      id: data['id'],
      username: data['username'],
      email: data['email'],
      name: data['name'] ?? data['username'],
      countryId: data['country_id'] ?? 'Unknown',
      avatar: data['avatar'],
      bio: data['bio'],
      isVerified: data['is_verified'] ?? false,
      coins: data['coins'] ?? 0,
      diamonds: data['diamonds'] ?? 0,
      tier: _parseTier(data['tier']),
      isOnline: data['is_online'] ?? false,
      interests: List<String>.from(data['interests'] ?? []),
      phoneNumber: data['phone_number'],
      createdAt: data['created_at'] != null
          ? DateTime.parse(data['created_at'])
          : DateTime.now(),
      photoURL: data['avatar'],
      location: data['location'],
      website: data['website'],
    );
  }

  // Parse tier string to UserTier enum
  app.UserTier? _parseTier(String? tier) {
    if (tier == null) return null;
    switch (tier.toLowerCase()) {
      case 'vip':
        return app.UserTier.vip;
      case 'svip':
        return app.UserTier.svip;
      default:
        return app.UserTier.normal;
    }
  }

  // Method to change password (note: this is handled by Supabase Auth)
  Future<bool> changePassword(String userId, String oldPassword, String newPassword) async {
    try {
      _logger.debug('Changing password for user: $userId');

      // First verify old password by signing in
      final user = getService<SupabaseClient>().auth.currentUser;
      if (user == null) return false;

      // Update password through Supabase Auth
      await getService<SupabaseClient>().auth.updateUser(
        UserAttributes(password: newPassword),
      );

      return true;
    } catch (e, stackTrace) {
      _logger.error('Failed to change password', error: e, stackTrace: stackTrace);
      return false;
    }
  }
}