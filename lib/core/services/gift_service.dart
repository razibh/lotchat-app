import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/gift_model.dart';
import '../di/service_locator.dart';
import 'notification_service.dart';
import 'analytics_service.dart';

class GiftService {
  late final SupabaseClient _supabase;
  late final NotificationService _notificationService;
  late final AnalyticsService _analyticsService;

  GiftService() {
    _initializeServices();
  }

  void _initializeServices() {
    try {
      _supabase = getService<SupabaseClient>();
      _notificationService = ServiceLocator.instance.get<NotificationService>();
      _analyticsService = ServiceLocator.instance.get<AnalyticsService>();
    } catch (e) {
      debugPrint('Error initializing services: $e');
    }
  }

  // Helper to get current user
  String? get _currentUserId => _supabase.auth.currentSession?.user.id;

  // ==================== GET GIFTS ====================

  /// Get available gifts
  Future<List<GiftModel>> getAvailableGifts() async {
    try {
      final response = await _supabase
          .from('gifts')
          .select()
          .eq('is_available', true)
          .order('price', ascending: true);

      return response.map((json) => GiftModel.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error getting gifts: $e');
      return GiftModel.getMockGifts();
    }
  }

  /// Get gifts by category
  Future<List<GiftModel>> getGiftsByCategory(String category) async {
    try {
      final response = await _supabase
          .from('gifts')
          .select()
          .eq('category', category)
          .eq('is_available', true)
          .order('price', ascending: true);

      return response.map((json) => GiftModel.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error getting gifts by category: $e');
      final allGifts = GiftModel.getMockGifts();
      return allGifts.where((g) => g.category == category).toList();
    }
  }

  /// Get gift by id
  Future<GiftModel?> getGift(String giftId) async {
    try {
      final response = await _supabase
          .from('gifts')
          .select()
          .eq('id', giftId)
          .maybeSingle();

      if (response != null) {
        return GiftModel.fromJson(response);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting gift: $e');
      try {
        return GiftModel.getMockGifts().firstWhere((g) => g.id == giftId);
      } catch (e) {
        return null;
      }
    }
  }

  /// Get recent gifts
  Future<List<GiftModel>> getRecentGifts(String userId) async {
    try {
      final response = await _supabase
          .from('gift_transactions')
          .select()
          .eq('sender_id', userId)
          .order('created_at', ascending: false)
          .limit(10);

      final List<GiftModel> recentGifts = [];

      for (var data in response) {
        final giftId = data['gift_id'] as String?;
        if (giftId != null) {
          final gift = await getGift(giftId);
          if (gift != null) {
            recentGifts.add(gift);
          }
        }
      }

      return recentGifts;
    } catch (e) {
      debugPrint('Error getting recent gifts: $e');
      return [];
    }
  }

  // ==================== SEND GIFT ====================

  /// Send gift - FIXED (update methods)
  Future<bool> sendGift({
    required String senderId,
    required String receiverId,
    required String giftId,
    required int amount,
    String? roomId,
    String? message,
  }) async {
    final userId = _currentUserId;
    if (userId == null) throw Exception('User not logged in');
    if (userId != senderId) throw Exception('Unauthorized');

    try {
      final GiftModel? gift = await getGift(giftId);
      if (gift == null) throw Exception('Gift not found');

      final int totalPrice = gift.price * amount;

      // Get sender's current coins
      final senderData = await _supabase
          .from('users')
          .select('coins')
          .eq('id', senderId)
          .single();

      final senderCoins = senderData['coins'] as int? ?? 0;
      if (senderCoins < totalPrice) {
        throw Exception('Insufficient coins');
      }

      // Get receiver's current diamonds
      final receiverData = await _supabase
          .from('users')
          .select('diamonds')
          .eq('id', receiverId)
          .maybeSingle();

      final receiverDiamonds = receiverData?['diamonds'] as int? ?? 0;
      final int earnedDiamonds = (totalPrice / 2).round();

      try {
        // 1. Deduct coins from sender - FIXED
        final updateSenderQuery = _supabase
            .from('users')
            .update({
          'coins': senderCoins - totalPrice,
          'updated_at': DateTime.now().toIso8601String(),
        });
        await updateSenderQuery.eq('id', senderId);

        // 2. Add diamonds to receiver - FIXED
        final updateReceiverQuery = _supabase
            .from('users')
            .update({
          'diamonds': receiverDiamonds + earnedDiamonds,
          'updated_at': DateTime.now().toIso8601String(),
        });
        await updateReceiverQuery.eq('id', receiverId);

        // 3. Record gift transaction
        await _supabase.from('gift_transactions').insert({
          'sender_id': senderId,
          'sender_name': (await _getUserName(senderId)) ?? 'User',
          'receiver_id': receiverId,
          'gift_id': giftId,
          'gift_name': gift.name,
          'amount': amount,
          'total_price': totalPrice,
          'room_id': roomId,
          'message': message,
          'created_at': DateTime.now().toIso8601String(),
        });

        // 4. Update gift stats - FIXED
        final updateGiftQuery = _supabase
            .from('gifts')
            .update({
          'sent_count': (gift.sentCount ?? 0) + amount,
        });
        await updateGiftQuery.eq('id', giftId);

        // 5. Update sender's stats - FIXED
        final updateSenderStatsQuery = _supabase
            .from('users')
            .update({
          'total_gifts_sent': (await _getUserStat(senderId, 'total_gifts_sent')) + amount,
          'total_coins_spent': (await _getUserStat(senderId, 'total_coins_spent')) + totalPrice,
        });
        await updateSenderStatsQuery.eq('id', senderId);

        // 6. Update receiver's stats - FIXED
        final updateReceiverStatsQuery = _supabase
            .from('users')
            .update({
          'total_gifts_received': (await _getUserStat(receiverId, 'total_gifts_received')) + amount,
          'total_diamonds_earned': (await _getUserStat(receiverId, 'total_diamonds_earned')) + earnedDiamonds,
        });
        await updateReceiverStatsQuery.eq('id', receiverId);

        // Send notification
        try {
          final senderName = await _getUserName(senderId) ?? 'Someone';
          await _notificationService.showNotification(
            title: 'Gift Received! 🎁',
            body: '$senderName sent you ${amount == 1 ? 'a' : amount} ${gift.name}${amount > 1 ? 's' : ''}',
            data: {
              'type': 'gift',
              'senderId': senderId,
              'receiverId': receiverId,
              'giftId': giftId,
              'amount': amount,
            },
          );
        } catch (e) {
          debugPrint('Error sending notification: $e');
        }

        // Track analytics
        try {
          await _analyticsService.trackGiftSent(
            giftId: giftId,
            giftName: gift.name,
            price: totalPrice,
            receiverId: receiverId,
            roomId: roomId,
          );
        } catch (e) {
          debugPrint('Error tracking analytics: $e');
        }

        return true;
      } catch (e) {
        debugPrint('Transaction failed: $e');
        return false;
      }
    } catch (e) {
      debugPrint('Error sending gift: $e');
      return false;
    }
  }

  /// Helper to get user stat
  Future<int> _getUserStat(String userId, String statField) async {
    try {
      final response = await _supabase
          .from('users')
          .select(statField)
          .eq('id', userId)
          .maybeSingle();

      return response?[statField] as int? ?? 0;
    } catch (e) {
      return 0;
    }
  }

  /// Get user name helper
  Future<String?> _getUserName(String userId) async {
    try {
      final response = await _supabase
          .from('users')
          .select('username')
          .eq('id', userId)
          .maybeSingle();

      return response?['username'];
    } catch (e) {
      return null;
    }
  }

  // ==================== GIFT HISTORY - FIXED ====================

  /// Get gift history (as user or receiver) - FIXED
  Stream<List<Map<String, dynamic>>> getGiftHistory(String userId) {
    try {
      final stream = _supabase
          .from('gift_transactions')
          .stream(primaryKey: ['id']);

      return stream.map((data) {
        // Manual filtering for both sender and receiver
        final filtered = data.where((item) =>
        item['sender_id'] == userId || item['receiver_id'] == userId
        ).toList();

        // Manual sorting
        filtered.sort((a, b) {
          final aTime = DateTime.parse(a['created_at'] ?? DateTime.now().toIso8601String());
          final bTime = DateTime.parse(b['created_at'] ?? DateTime.now().toIso8601String());
          return bTime.compareTo(aTime);
        });

        // Take first 100
        final limited = filtered.take(100).toList();

        return limited.map((item) {
          final map = Map<String, dynamic>.from(item);
          map['id'] = map['id'].toString();
          return map;
        }).toList();
      });
    } catch (e) {
      debugPrint('Error getting gift history: $e');
      return Stream.value([]);
    }
  }

  /// Get sent gifts - FIXED
  Stream<List<Map<String, dynamic>>> getSentGifts(String userId) {
    try {
      final stream = _supabase
          .from('gift_transactions')
          .stream(primaryKey: ['id']);

      return stream.map((data) {
        // Manual filtering
        final filtered = data.where((item) => item['sender_id'] == userId).toList();

        // Manual sorting
        filtered.sort((a, b) {
          final aTime = DateTime.parse(a['created_at'] ?? DateTime.now().toIso8601String());
          final bTime = DateTime.parse(b['created_at'] ?? DateTime.now().toIso8601String());
          return bTime.compareTo(aTime);
        });

        return filtered.map((item) {
          final map = Map<String, dynamic>.from(item);
          map['id'] = map['id'].toString();
          return map;
        }).toList();
      });
    } catch (e) {
      debugPrint('Error getting sent gifts: $e');
      return Stream.value([]);
    }
  }

  /// Get received gifts - FIXED
  Stream<List<Map<String, dynamic>>> getReceivedGifts(String userId) {
    try {
      final stream = _supabase
          .from('gift_transactions')
          .stream(primaryKey: ['id']);

      return stream.map((data) {
        // Manual filtering
        final filtered = data.where((item) => item['receiver_id'] == userId).toList();

        // Manual sorting
        filtered.sort((a, b) {
          final aTime = DateTime.parse(a['created_at'] ?? DateTime.now().toIso8601String());
          final bTime = DateTime.parse(b['created_at'] ?? DateTime.now().toIso8601String());
          return bTime.compareTo(aTime);
        });

        return filtered.map((item) {
          final map = Map<String, dynamic>.from(item);
          map['id'] = map['id'].toString();
          return map;
        }).toList();
      });
    } catch (e) {
      debugPrint('Error getting received gifts: $e');
      return Stream.value([]);
    }
  }

  // ==================== LEADERBOARDS ====================

  /// Get top gifters
  Future<List<Map<String, dynamic>>> getTopGifters({int limit = 10}) async {
    try {
      final response = await _supabase
          .from('users')
          .select('id, username, avatar_url, total_gifts_sent, total_coins_spent')
          .not('total_gifts_sent', 'is', null)
          .order('total_gifts_sent', ascending: false)
          .limit(limit);

      return response.map((user) {
        return {
          'userId': user['id'] ?? '',
          'username': user['username'] ?? '',
          'avatar': user['avatar_url'] ?? '',
          'totalGifts': (user['total_gifts_sent'] ?? 0).toString(),
          'totalCoinsSpent': (user['total_coins_spent'] ?? 0).toString(),
        };
      }).toList();
    } catch (e) {
      debugPrint('Error getting top gifters: $e');
      return [];
    }
  }

  /// Get top receivers
  Future<List<Map<String, dynamic>>> getTopReceivers({int limit = 10}) async {
    try {
      final response = await _supabase
          .from('users')
          .select('id, username, avatar_url, total_gifts_received, total_diamonds_earned')
          .not('total_gifts_received', 'is', null)
          .order('total_gifts_received', ascending: false)
          .limit(limit);

      return response.map((user) {
        return {
          'userId': user['id'] ?? '',
          'username': user['username'] ?? '',
          'avatar': user['avatar_url'] ?? '',
          'totalGifts': (user['total_gifts_received'] ?? 0).toString(),
          'totalDiamondsEarned': (user['total_diamonds_earned'] ?? 0).toString(),
        };
      }).toList();
    } catch (e) {
      debugPrint('Error getting top receivers: $e');
      return [];
    }
  }

  /// Get recent gifters
  Future<List<Map<String, dynamic>>> getRecentGifters(String receiverId) async {
    try {
      final response = await _supabase
          .from('gift_transactions')
          .select('''
            sender_id,
            gift_name,
            amount,
            created_at,
            users:sender_id (username, avatar_url)
          ''')
          .eq('receiver_id', receiverId)
          .order('created_at', ascending: false)
          .limit(10);

      final List<Map<String, dynamic>> gifters = [];
      final Set<String> seenIds = {};

      for (final item in response) {
        final senderId = item['sender_id'] as String?;

        if (senderId != null && !seenIds.contains(senderId)) {
          seenIds.add(senderId);

          final userData = item['users'] as Map<String, dynamic>?;

          gifters.add({
            'userId': senderId,
            'name': userData?['username'] ?? '',
            'avatar': userData?['avatar_url'] ?? '',
            'giftName': item['gift_name'] ?? '',
            'amount': (item['amount'] ?? 0).toString(),
            'timestamp': item['created_at'] ?? '',
          });
        }
      }

      return gifters;
    } catch (e) {
      debugPrint('Error getting recent gifters: $e');
      return [];
    }
  }

  // ==================== STATISTICS ====================

  /// Get gift stats
  Future<Map<String, dynamic>> getGiftStats(String userId) async {
    try {
      // Get sent transactions
      final sentResponse = await _supabase
          .from('gift_transactions')
          .select('amount, total_price')
          .eq('sender_id', userId);

      // Get received transactions
      final receivedResponse = await _supabase
          .from('gift_transactions')
          .select('amount, total_price')
          .eq('receiver_id', userId);

      var totalSent = 0;
      var totalReceived = 0;
      var coinsSpent = 0;
      var diamondsEarned = 0;

      for (final item in sentResponse) {
        totalSent += item['amount'] as int? ?? 0;
        coinsSpent += item['total_price'] as int? ?? 0;
      }

      for (final item in receivedResponse) {
        totalReceived += item['amount'] as int? ?? 0;
        diamondsEarned += ((item['total_price'] as int? ?? 0) / 2).round();
      }

      // Get unique senders/receivers
      final uniqueSenders = await _getUniqueCount('gift_transactions', 'sender_id', receiverId: userId);
      final uniqueReceivers = await _getUniqueCount('gift_transactions', 'receiver_id', senderId: userId);

      return {
        'totalSent': totalSent.toString(),
        'totalReceived': totalReceived.toString(),
        'coinsSpent': coinsSpent.toString(),
        'diamondsEarned': diamondsEarned.toString(),
        'uniqueSenders': uniqueSenders,
        'uniqueReceivers': uniqueReceivers,
      };
    } catch (e) {
      debugPrint('Error getting gift stats: $e');
      return {};
    }
  }

  /// Get unique count helper
  Future<int> _getUniqueCount(String table, String field, {String? senderId, String? receiverId}) async {
    try {
      var query = _supabase.from(table).select(field);

      if (senderId != null) {
        query = query.eq('sender_id', senderId);
      }
      if (receiverId != null) {
        query = query.eq('receiver_id', receiverId);
      }

      final response = await query;
      final Set<String> unique = {};
      for (final item in response) {
        unique.add(item[field] as String);
      }
      return unique.length;
    } catch (e) {
      return 0;
    }
  }

  // ==================== FAVORITES ====================

  /// Get favorite gifts
  Future<List<Map<String, dynamic>>> getFavoriteGifts(String userId) async {
    try {
      final response = await _supabase
          .from('favorite_gifts')
          .select('''
            gift_id,
            gift_name,
            gift_category,
            added_at,
            gifts (*)
          ''')
          .eq('user_id', userId)
          .order('added_at', ascending: false);

      return response.map((item) {
        final Map<String, dynamic> data = Map.from(item);
        data['id'] = data['gift_id'];
        data['addedAt'] = data['added_at'];

        // Merge gift data if available
        if (data['gifts'] != null) {
          data.addAll(Map.from(data['gifts'] as Map));
          data.remove('gifts');
        }

        return data;
      }).toList();
    } catch (e) {
      debugPrint('Error getting favorite gifts: $e');
      return [];
    }
  }

  /// Add to favorites
  Future<bool> addToFavorites(String giftId) async {
    final userId = _currentUserId;
    if (userId == null) throw Exception('User not logged in');

    try {
      final GiftModel? gift = await getGift(giftId);
      if (gift == null) throw Exception('Gift not found');

      // Check if already in favorites
      final existing = await _supabase
          .from('favorite_gifts')
          .select()
          .eq('user_id', userId)
          .eq('gift_id', giftId)
          .maybeSingle();

      if (existing != null) return true; // Already exists

      await _supabase.from('favorite_gifts').insert({
        'user_id': userId,
        'gift_id': giftId,
        'gift_name': gift.name,
        'gift_category': gift.category,
        'added_at': DateTime.now().toIso8601String(),
      });

      return true;
    } catch (e) {
      debugPrint('Error adding to favorites: $e');
      return false;
    }
  }

  /// Remove from favorites
  Future<bool> removeFromFavorites(String giftId) async {
    final userId = _currentUserId;
    if (userId == null) throw Exception('User not logged in');

    try {
      await _supabase
          .from('favorite_gifts')
          .delete()
          .eq('user_id', userId)
          .eq('gift_id', giftId);

      return true;
    } catch (e) {
      debugPrint('Error removing from favorites: $e');
      return false;
    }
  }

  /// Get popular gifts
  Future<List<GiftModel>> getPopularGifts({int limit = 10}) async {
    try {
      final response = await _supabase
          .from('gifts')
          .select()
          .eq('is_available', true)
          .order('sent_count', ascending: false)
          .limit(limit);

      return response.map((json) => GiftModel.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error getting popular gifts: $e');
      return GiftModel.getMockGifts().take(limit).toList();
    }
  }
}