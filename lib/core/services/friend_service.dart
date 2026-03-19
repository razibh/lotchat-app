import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_models.dart' as app;
import '../di/service_locator.dart';
import 'notification_service.dart';

class FriendService {
  late final SupabaseClient _supabase;
  late final NotificationService _notificationService;

  FriendService() {
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

  // ==================== HELPER METHODS ====================

  /// Get current user ID
  String? get _currentUserId => _supabase.auth.currentSession?.user.id;

  /// Get user by id
  Future<app.User?> _getUser(String userId) async {
    try {
      final response = await _supabase
          .from('users')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (response != null) {
        return app.User.fromJson(response);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting user: $e');
      return null;
    }
  }

  // ==================== GET FRIENDS - FIXED ====================

  /// Get friends list as stream - FIXED
  Stream<List<app.User>> getFriends(String userId) {
    try {
      // Stream থেকে data নিয়ে manually filter করছি
      return _supabase
          .from('friends')
          .stream(primaryKey: ['id'])
          .map((data) async {
        // Manually filter
        final filtered = data.where((item) =>
        item['user_id'] == userId && item['status'] == 'accepted'
        ).toList();

        final friends = <app.User>[];
        for (final item in filtered) {
          final friendId = item['friend_id'] as String;
          final friend = await _getUser(friendId);
          if (friend != null) {
            friends.add(friend);
          }
        }
        return friends;
      }).asyncMap((event) => event);
    } catch (e) {
      debugPrint('Error getting friends stream: $e');
      return Stream.value([]);
    }
  }

  /// Get friend by id
  Future<app.User?> getFriend(String userId, String friendId) async {
    try {
      final response = await _supabase
          .from('friends')
          .select()
          .eq('user_id', userId)
          .eq('friend_id', friendId)
          .eq('status', 'accepted')
          .maybeSingle();

      if (response != null) {
        return await _getUser(friendId);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting friend: $e');
      return null;
    }
  }

  /// Get online friends - FIXED
  Stream<List<app.User>> getOnlineFriends(String userId) {
    return getFriends(userId).map((friends) {
      return friends.where((f) => f.isOnline).toList();
    });
  }

  // ==================== FRIEND REQUESTS - FIXED ====================

  /// Get received friend requests - FIXED
  Stream<List<FriendRequestModel>> getFriendRequests(String userId) {
    try {
      return _supabase
          .from('friend_requests')
          .stream(primaryKey: ['id'])
          .map((data) async {
        // Manually filter
        final filtered = data.where((item) =>
        item['receiver_id'] == userId && item['status'] == 'pending'
        ).toList();

        // Sort manually
        filtered.sort((a, b) {
          final aTime = DateTime.parse(a['sent_at'] ?? DateTime.now().toIso8601String());
          final bTime = DateTime.parse(b['sent_at'] ?? DateTime.now().toIso8601String());
          return bTime.compareTo(aTime); // descending
        });

        final requests = <FriendRequestModel>[];
        for (final item in filtered) {
          final sender = await _getUser(item['sender_id'] as String);
          if (sender != null) {
            requests.add(FriendRequestModel(
              id: item['id'].toString(),
              senderId: item['sender_id'],
              senderName: sender.username,
              senderAvatar: sender.avatar,
              receiverId: item['receiver_id'],
              receiverName: null,
              receiverAvatar: null,
              message: item['message'],
              status: item['status'],
              sentAt: DateTime.parse(item['sent_at']),
              respondedAt: item['responded_at'] != null
                  ? DateTime.parse(item['responded_at'])
                  : null,
            ));
          }
        }
        return requests;
      }).asyncMap((event) => event);
    } catch (e) {
      debugPrint('Error getting friend requests: $e');
      return Stream.value([]);
    }
  }

  /// Get sent friend requests - FIXED
  Stream<List<FriendRequestModel>> getSentRequests(String userId) {
    try {
      return _supabase
          .from('friend_requests')
          .stream(primaryKey: ['id'])
          .map((data) async {
        // Manually filter
        final filtered = data.where((item) =>
        item['sender_id'] == userId && item['status'] == 'pending'
        ).toList();

        // Sort manually
        filtered.sort((a, b) {
          final aTime = DateTime.parse(a['sent_at'] ?? DateTime.now().toIso8601String());
          final bTime = DateTime.parse(b['sent_at'] ?? DateTime.now().toIso8601String());
          return bTime.compareTo(aTime);
        });

        final requests = <FriendRequestModel>[];
        for (final item in filtered) {
          final receiver = await _getUser(item['receiver_id'] as String);
          if (receiver != null) {
            requests.add(FriendRequestModel(
              id: item['id'].toString(),
              senderId: item['sender_id'],
              senderName: '',
              senderAvatar: null,
              receiverId: item['receiver_id'],
              receiverName: receiver.username,
              receiverAvatar: receiver.avatar,
              message: item['message'],
              status: item['status'],
              sentAt: DateTime.parse(item['sent_at']),
              respondedAt: item['responded_at'] != null
                  ? DateTime.parse(item['responded_at'])
                  : null,
            ));
          }
        }
        return requests;
      }).asyncMap((event) => event);
    } catch (e) {
      debugPrint('Error getting sent requests: $e');
      return Stream.value([]);
    }
  }

  /// Send friend request
  Future<bool> sendFriendRequest(String receiverId, {String? message}) async {
    final userId = _currentUserId;
    if (userId == null) throw Exception('User not logged in');

    try {
      // Check if already friends
      final existingFriend = await _supabase
          .from('friends')
          .select()
          .eq('user_id', userId)
          .eq('friend_id', receiverId)
          .eq('status', 'accepted')
          .maybeSingle();

      if (existingFriend != null) return false;

      // Check if request already exists
      final existingRequest = await _supabase
          .from('friend_requests')
          .select()
          .eq('sender_id', userId)
          .eq('receiver_id', receiverId)
          .eq('status', 'pending')
          .maybeSingle();

      if (existingRequest != null) return false;

      // Create request
      await _supabase.from('friend_requests').insert({
        'sender_id': userId,
        'receiver_id': receiverId,
        'message': message,
        'status': 'pending',
        'sent_at': DateTime.now().toIso8601String(),
      });

      // Send notification - FIXED
      try {
        _notificationService.showNotification(
          title: 'Friend Request',
          body: 'You have a new friend request',
        );
      } catch (e) {
        debugPrint('Notification error: $e');
      }

      return true;
    } catch (e) {
      debugPrint('Error sending friend request: $e');
      return false;
    }
  }

  /// Accept friend request
  Future<bool> acceptFriendRequest(String requestId, String senderId) async {
    final userId = _currentUserId;
    if (userId == null) throw Exception('User not logged in');

    try {
      // Update request status
      await _supabase
          .from('friend_requests')
          .update({
        'status': 'accepted',
        'responded_at': DateTime.now().toIso8601String(),
      })
          .eq('id', requestId);

      // Add to user's friends
      await _supabase.from('friends').insert({
        'user_id': userId,
        'friend_id': senderId,
        'status': 'accepted',
        'created_at': DateTime.now().toIso8601String(),
      });

      // Add to sender's friends
      await _supabase.from('friends').insert({
        'user_id': senderId,
        'friend_id': userId,
        'status': 'accepted',
        'created_at': DateTime.now().toIso8601String(),
      });

      return true;
    } catch (e) {
      debugPrint('Error accepting friend request: $e');
      return false;
    }
  }

  /// Reject friend request
  Future<bool> rejectFriendRequest(String requestId) async {
    try {
      await _supabase
          .from('friend_requests')
          .update({
        'status': 'rejected',
        'responded_at': DateTime.now().toIso8601String(),
      })
          .eq('id', requestId);

      return true;
    } catch (e) {
      debugPrint('Error rejecting friend request: $e');
      return false;
    }
  }

  /// Cancel friend request
  Future<bool> cancelFriendRequest(String requestId) async {
    try {
      await _supabase
          .from('friend_requests')
          .delete()
          .eq('id', requestId);

      return true;
    } catch (e) {
      debugPrint('Error canceling friend request: $e');
      return false;
    }
  }

  // ==================== FRIEND MANAGEMENT ====================

  /// Remove friend
  Future<bool> removeFriend(String friendId) async {
    final userId = _currentUserId;
    if (userId == null) throw Exception('User not logged in');

    try {
      // Remove from user's friends
      await _supabase
          .from('friends')
          .delete()
          .eq('user_id', userId)
          .eq('friend_id', friendId);

      // Remove from friend's friends
      await _supabase
          .from('friends')
          .delete()
          .eq('user_id', friendId)
          .eq('friend_id', userId);

      return true;
    } catch (e) {
      debugPrint('Error removing friend: $e');
      return false;
    }
  }

  // ==================== BLOCK/UNBLOCK ====================

  /// Block user
  Future<bool> blockUser(String userId) async {
    final currentUserId = _currentUserId;
    if (currentUserId == null) throw Exception('User not logged in');

    try {
      // Remove from friends if exists
      await _supabase
          .from('friends')
          .delete()
          .eq('user_id', currentUserId)
          .eq('friend_id', userId);

      await _supabase
          .from('friends')
          .delete()
          .eq('user_id', userId)
          .eq('friend_id', currentUserId);

      // Add to blocked list
      await _supabase.from('blocked_users').insert({
        'user_id': currentUserId,
        'blocked_user_id': userId,
        'blocked_at': DateTime.now().toIso8601String(),
      });

      return true;
    } catch (e) {
      debugPrint('Error blocking user: $e');
      return false;
    }
  }

  /// Unblock user
  Future<bool> unblockUser(String userId) async {
    final currentUserId = _currentUserId;
    if (currentUserId == null) throw Exception('User not logged in');

    try {
      await _supabase
          .from('blocked_users')
          .delete()
          .eq('user_id', currentUserId)
          .eq('blocked_user_id', userId);

      return true;
    } catch (e) {
      debugPrint('Error unblocking user: $e');
      return false;
    }
  }

  /// Get blocked users - FIXED
  Stream<List<app.User>> getBlockedUsers() {
    final userId = _currentUserId;
    if (userId == null) return Stream.value([]);

    try {
      return _supabase
          .from('blocked_users')
          .stream(primaryKey: ['id'])
          .map((data) async {
        // Manually filter
        final filtered = data.where((item) => item['user_id'] == userId).toList();

        final blocked = <app.User>[];
        for (final item in filtered) {
          final blockedUserId = item['blocked_user_id'] as String;
          final user = await _getUser(blockedUserId);
          if (user != null) {
            blocked.add(user);
          }
        }
        return blocked;
      }).asyncMap((event) => event);
    } catch (e) {
      debugPrint('Error getting blocked users: $e');
      return Stream.value([]);
    }
  }

  // ==================== FRIEND STATUS ====================

  /// Check if users are friends
  Future<bool> areFriends(String userId1, String userId2) async {
    try {
      final response = await _supabase
          .from('friends')
          .select()
          .eq('user_id', userId1)
          .eq('friend_id', userId2)
          .eq('status', 'accepted')
          .maybeSingle();

      return response != null;
    } catch (e) {
      return false;
    }
  }

  /// Get friend status
  Future<String?> getFriendStatus(String userId) async {
    final currentUserId = _currentUserId;
    if (currentUserId == null) return null;

    try {
      // Check if friends
      if (await areFriends(currentUserId, userId)) {
        return 'friends';
      }

      // Check if request sent
      final sentRequest = await _supabase
          .from('friend_requests')
          .select()
          .eq('sender_id', currentUserId)
          .eq('receiver_id', userId)
          .eq('status', 'pending')
          .maybeSingle();

      if (sentRequest != null) {
        return 'request_sent';
      }

      // Check if request received
      final receivedRequest = await _supabase
          .from('friend_requests')
          .select()
          .eq('sender_id', userId)
          .eq('receiver_id', currentUserId)
          .eq('status', 'pending')
          .maybeSingle();

      if (receivedRequest != null) {
        return 'request_received';
      }

      // Check if blocked
      final blocked = await _supabase
          .from('blocked_users')
          .select()
          .eq('user_id', currentUserId)
          .eq('blocked_user_id', userId)
          .maybeSingle();

      if (blocked != null) {
        return 'blocked';
      }

      return null;
    } catch (e) {
      debugPrint('Error getting friend status: $e');
      return null;
    }
  }

  // ==================== FRIEND SUGGESTIONS ====================

  /// Get friend suggestions
  Future<List<FriendSuggestion>> getFriendSuggestions({int limit = 20}) async {
    final userId = _currentUserId;
    if (userId == null) throw Exception('User not logged in');

    try {
      // Get user's friends
      final friendsResponse = await _supabase
          .from('friends')
          .select('friend_id')
          .eq('user_id', userId)
          .eq('status', 'accepted');

      final friendIds = friendsResponse
          .map<String>((item) => item['friend_id'] as String)
          .toSet();

      // Get blocked users
      final blockedResponse = await _supabase
          .from('blocked_users')
          .select('blocked_user_id')
          .eq('user_id', userId);

      final blockedIds = blockedResponse
          .map<String>((item) => item['blocked_user_id'] as String)
          .toSet();

      // Get users with mutual friends
      final suggestions = <FriendSuggestion>[];
      final seenIds = <String>{userId, ...friendIds, ...blockedIds};

      for (final friendId in friendIds) {
        final friendFriendsResponse = await _supabase
            .from('friends')
            .select('friend_id')
            .eq('user_id', friendId)
            .eq('status', 'accepted');

        for (final item in friendFriendsResponse) {
          final potentialId = item['friend_id'] as String;
          if (!seenIds.contains(potentialId)) {
            seenIds.add(potentialId);

            final user = await _getUser(potentialId);
            if (user != null) {
              final mutualCount = await _getMutualFriendsCount(userId, potentialId);
              final commonInterests = await _getCommonInterests(userId, potentialId);

              // Calculate score
              final score = mutualCount * 10 + commonInterests.length * 5;

              suggestions.add(FriendSuggestion(
                userId: potentialId,
                name: user.username,
                avatar: user.avatar,
                mutualFriends: mutualCount,
                commonInterests: commonInterests,
                score: score,
              ));
            }
          }
        }
      }

      // Sort by score
      suggestions.sort((a, b) => b.score.compareTo(a.score));
      return suggestions.take(limit).toList();
    } catch (e) {
      debugPrint('Error getting suggestions: $e');
      return [];
    }
  }

  /// Get mutual friends count
  Future<int> _getMutualFriendsCount(String userId1, String userId2) async {
    try {
      final friends1 = await _supabase
          .from('friends')
          .select('friend_id')
          .eq('user_id', userId1)
          .eq('status', 'accepted');

      final friends2 = await _supabase
          .from('friends')
          .select('friend_id')
          .eq('user_id', userId2)
          .eq('status', 'accepted');

      final set1 = friends1.map<String>((item) => item['friend_id'] as String).toSet();
      final set2 = friends2.map<String>((item) => item['friend_id'] as String).toSet();

      return set1.intersection(set2).length;
    } catch (e) {
      return 0;
    }
  }

  /// Get common interests
  Future<List<String>> _getCommonInterests(String userId1, String userId2) async {
    try {
      final user1 = await _getUser(userId1);
      final user2 = await _getUser(userId2);

      if (user1 == null || user2 == null) return [];

      return user1.interests
          .where((i) => user2.interests.contains(i))
          .toList();
    } catch (e) {
      return [];
    }
  }

  // ==================== FRIEND STATS ====================

  /// Get friend stats
  Future<FriendStats> getFriendStats() async {
    final userId = _currentUserId;
    if (userId == null) throw Exception('User not logged in');

    try {
      // Get friends count
      final friends = await _supabase
          .from('friends')
          .select()
          .eq('user_id', userId)
          .eq('status', 'accepted');

      // Get pending requests
      final pendingRequests = await _supabase
          .from('friend_requests')
          .select()
          .eq('receiver_id', userId)
          .eq('status', 'pending');

      // Get sent requests
      final sentRequests = await _supabase
          .from('friend_requests')
          .select()
          .eq('sender_id', userId)
          .eq('status', 'pending');

      // Get blocked users
      final blocked = await _supabase
          .from('blocked_users')
          .select()
          .eq('user_id', userId);

      // Count online friends
      var onlineFriends = 0;
      for (final friend in friends) {
        final friendId = friend['friend_id'] as String;
        final friendUser = await _getUser(friendId);
        if (friendUser != null && friendUser.isOnline) {
          onlineFriends++;
        }
      }

      // Count friends this week/month
      final oneWeekAgo = DateTime.now().subtract(const Duration(days: 7));
      final oneMonthAgo = DateTime.now().subtract(const Duration(days: 30));

      var friendsThisWeek = 0;
      var friendsThisMonth = 0;

      for (final friend in friends) {
        final createdAt = DateTime.parse(friend['created_at']);
        if (createdAt.isAfter(oneWeekAgo)) friendsThisWeek++;
        if (createdAt.isAfter(oneMonthAgo)) friendsThisMonth++;
      }

      return FriendStats(
        totalFriends: friends.length,
        onlineFriends: onlineFriends,
        pendingRequests: pendingRequests.length,
        sentRequests: sentRequests.length,
        blockedUsers: blocked.length,
        mutualFriends: 0,
        friendsThisWeek: friendsThisWeek,
        friendsThisMonth: friendsThisMonth,
      );
    } catch (e) {
      debugPrint('Error getting friend stats: $e');
      return FriendStats(
        totalFriends: 0,
        onlineFriends: 0,
        pendingRequests: 0,
        sentRequests: 0,
        blockedUsers: 0,
        mutualFriends: 0,
        friendsThisWeek: 0,
        friendsThisMonth: 0,
      );
    }
  }
}

// ==================== MODEL CLASSES ====================

class FriendRequestModel {
  final String id;
  final String senderId;
  final String senderName;
  final String? senderAvatar;
  final String receiverId;
  final String? receiverName;
  final String? receiverAvatar;
  final String? message;
  final String status;
  final DateTime sentAt;
  final DateTime? respondedAt;

  FriendRequestModel({
    required this.id,
    required this.senderId,
    required this.senderName,
    this.senderAvatar,
    required this.receiverId,
    this.receiverName,
    this.receiverAvatar,
    this.message,
    required this.status,
    required this.sentAt,
    this.respondedAt,
  });

  factory FriendRequestModel.fromJson(Map<String, dynamic> json) {
    return FriendRequestModel(
      id: json['id'] ?? '',
      senderId: json['senderId'] ?? '',
      senderName: json['senderName'] ?? '',
      senderAvatar: json['senderAvatar'],
      receiverId: json['receiverId'] ?? '',
      receiverName: json['receiverName'],
      receiverAvatar: json['receiverAvatar'],
      message: json['message'],
      status: json['status'] ?? 'pending',
      sentAt: json['sentAt'] is String
          ? DateTime.parse(json['sentAt'])
          : json['sentAt'] ?? DateTime.now(),
      respondedAt: json['respondedAt'] != null
          ? (json['respondedAt'] is String
          ? DateTime.parse(json['respondedAt'])
          : json['respondedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'senderName': senderName,
      'senderAvatar': senderAvatar,
      'receiverId': receiverId,
      'receiverName': receiverName,
      'receiverAvatar': receiverAvatar,
      'message': message,
      'status': status,
      'sentAt': sentAt.toIso8601String(),
      'respondedAt': respondedAt?.toIso8601String(),
    };
  }
}

class FriendSuggestion {
  final String userId;
  final String name;
  final String? avatar;
  final int mutualFriends;
  final List<String> commonInterests;
  final int score;

  FriendSuggestion({
    required this.userId,
    required this.name,
    this.avatar,
    required this.mutualFriends,
    required this.commonInterests,
    required this.score,
  });
}

class FriendStats {
  final int totalFriends;
  final int onlineFriends;
  final int pendingRequests;
  final int sentRequests;
  final int blockedUsers;
  final int mutualFriends;
  final int friendsThisWeek;
  final int friendsThisMonth;

  FriendStats({
    required this.totalFriends,
    required this.onlineFriends,
    required this.pendingRequests,
    required this.sentRequests,
    required this.blockedUsers,
    required this.mutualFriends,
    required this.friendsThisWeek,
    required this.friendsThisMonth,
  });
}