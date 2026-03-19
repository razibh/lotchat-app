import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_models.dart' as app;
import '../models/room_model.dart';
import '../models/gift_model.dart';
import '../di/service_locator.dart';

class RecommendationService {
  late final SupabaseClient _supabase;

  RecommendationService() {
    _supabase = getService<SupabaseClient>();
  }

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

  // ==================== GET USER ====================

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

  // ==================== GET ALL USERS ====================

  Future<List<app.User>> _getAllUsers() async {
    try {
      final response = await _supabase
          .from('users')
          .select()
          .limit(1000);

      return response.map((json) => app.User.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error getting all users: $e');
      return [];
    }
  }

  // ==================== GET ACTIVE ROOMS ====================

  Future<List<RoomModel>> _getActiveRooms() async {
    try {
      final response = await _supabase
          .from('rooms')
          .select()
          .eq('status', 'active')
          .limit(100);

      return response.map((json) => RoomModel.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error getting active rooms: $e');
      return [];
    }
  }

  // ==================== GET USER ROOM HISTORY ====================

  Future<List<String>> _getUserRoomHistory(String userId) async {
    try {
      final response = await _supabase
          .from('room_history')
          .select('room_id')
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(50);

      return response.map<String>((item) => item['room_id'] as String).toList();
    } catch (e) {
      debugPrint('Error getting user room history: $e');
      return [];
    }
  }

  // ==================== GET POPULAR GIFTS ====================

  Future<List<GiftModel>> _getPopularGifts() async {
    try {
      final response = await _supabase
          .from('gifts')
          .select()
          .order('price', ascending: false)
          .limit(20);

      return response.map((json) => GiftModel.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error getting popular gifts: $e');
      return [];
    }
  }

  // ==================== GET TIER GIFTS ====================

  Future<List<GiftModel>> _getTierGifts(app.UserTier tier) async {
    try {
      final bool isVip = tier.toString().contains('vip');
      final bool isSvip = tier.toString().contains('svip');

      var query = _supabase.from('gifts').select();

      if (isSvip) {
        query = query.eq('is_svip', true);
      } else if (isVip) {
        query = query.eq('is_vip', true);
      }

      final response = await query.limit(10);
      return response.map((json) => GiftModel.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error getting tier gifts: $e');
      return [];
    }
  }

  // ==================== GET USER GIFT HISTORY ====================

  Future<List<String>> _getUserGiftHistory(String userId) async {
    try {
      final response = await _supabase
          .from('gift_transactions')
          .select('gift_id')
          .eq('sender_id', userId)
          .order('created_at', ascending: false)
          .limit(50);

      return response.map<String>((item) => item['gift_id'] as String).toList();
    } catch (e) {
      debugPrint('Error getting user gift history: $e');
      return [];
    }
  }

  // ==================== GET POPULAR POSTS ====================

  Future<List<Map<String, dynamic>>> _getPopularPostsFromUsers(List<String> userIds) async {
    try {
      if (userIds.isEmpty) return [];

      final response = await _supabase
          .from('posts')
          .select()
          .inFilter('user_id', userIds.take(10).toList())
          .order('likes', ascending: false)
          .limit(20);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error getting popular posts: $e');
      return [];
    }
  }

  // ==================== GET TRENDING GIFTS ====================

  Future<List<GiftModel>> _getTrendingGifts() async {
    try {
      final lastHour = DateTime.now().subtract(const Duration(hours: 1)).toIso8601String();

      final response = await _supabase
          .from('gift_transactions')
          .select('gift_id')
          .gte('created_at', lastHour);

      // Count gift occurrences
      final Map<String, int> giftCounts = {};
      for (final item in response) {
        final giftId = item['gift_id'] as String? ?? '';
        if (giftId.isNotEmpty) {
          giftCounts[giftId] = (giftCounts[giftId] ?? 0) + 1;
        }
      }

      // Sort by count
      final sortedGifts = giftCounts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      // Get gift details
      final List<GiftModel> trendingGifts = [];
      for (final entry in sortedGifts.take(10)) {
        final giftData = await _supabase
            .from('gifts')
            .select()
            .eq('id', entry.key)
            .maybeSingle();

        if (giftData != null) {
          trendingGifts.add(GiftModel.fromJson(giftData));
        }
      }

      return trendingGifts;
    } catch (e) {
      debugPrint('Error getting trending gifts: $e');
      return [];
    }
  }

  // ==================== GET LOCAL EVENTS ====================

  Future<List<Map<String, dynamic>>> _getLocalEvents(String country) async {
    try {
      final now = DateTime.now().toIso8601String();

      final response = await _supabase
          .from('events')
          .select()
          .eq('country', country)
          .gte('end_date', now)
          .order('start_date')
          .limit(10);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error getting local events: $e');
      return [];
    }
  }

  // ==================== FIND USERS BY INTERACTIONS ====================

  Future<List<String>> _findUsersByInteractions(
      List<String> rooms,
      List<String> gifts,
      ) async {
    try {
      final Set<String> similarUsers = {};

      if (rooms.isNotEmpty) {
        final roomUsers = await _supabase
            .from('room_history')
            .select('user_id')
            .inFilter('room_id', rooms.take(10).toList());

        for (final item in roomUsers) {
          similarUsers.add(item['user_id'] as String? ?? '');
        }
      }

      if (gifts.isNotEmpty) {
        final giftUsers = await _supabase
            .from('gift_transactions')
            .select('sender_id, receiver_id')
            .inFilter('gift_id', gifts.take(10).toList());

        for (final item in giftUsers) {
          similarUsers.add(item['sender_id'] as String? ?? '');
          similarUsers.add(item['receiver_id'] as String? ?? '');
        }
      }

      return similarUsers.where((id) => id.isNotEmpty).toList();
    } catch (e) {
      debugPrint('Error finding users by interactions: $e');
      return [];
    }
  }

  // ==================== GET NEW RECOMMENDATIONS ====================

  Future<List<app.User>> _getNewRecommendations(
      String userId,
      List<String> similarUsers,
      ) async {
    try {
      final List<app.User> recommendations = [];
      final Set<String> recommendedIds = {};

      for (String similarUserId in similarUsers.take(20)) {
        if (!recommendedIds.contains(similarUserId) && similarUserId != userId) {
          final similarUser = await _getUser(similarUserId);
          if (similarUser != null) {
            recommendations.add(similarUser);
            recommendedIds.add(similarUser.id);
          }
        }
      }

      return recommendations;
    } catch (e) {
      debugPrint('Error getting new recommendations: $e');
      return [];
    }
  }

  // ==================== GET USER FAVORITE ROOMS ====================

  Future<List<RoomModel>> _getUserFavoriteRooms(String userId) async {
    try {
      final response = await _supabase
          .from('room_history')
          .select('room_id')
          .eq('user_id', userId)
          .eq('is_favorite', true)
          .limit(20);

      final List<RoomModel> rooms = [];
      for (final item in response) {
        final roomId = item['room_id'] as String? ?? '';
        if (roomId.isNotEmpty) {
          final roomData = await _supabase
              .from('rooms')
              .select()
              .eq('id', roomId)
              .maybeSingle();

          if (roomData != null) {
            rooms.add(RoomModel.fromJson(roomData));
          }
        }
      }

      return rooms;
    } catch (e) {
      debugPrint('Error getting user favorite rooms: $e');
      return [];
    }
  }

  // ==================== EXTRACT ROOM FEATURES ====================

  Map<String, dynamic> _extractRoomFeatures(List<RoomModel> rooms) {
    final Map<String, dynamic> features = {};

    // Category distribution
    final Map<String, int> categories = {};
    for (RoomModel room in rooms) {
      categories[room.category] = (categories[room.category] ?? 0) + 1;
    }
    features['categories'] = categories;

    // Average viewer count
    if (rooms.isNotEmpty) {
      int totalViewers = 0;
      for (RoomModel room in rooms) {
        totalViewers += room.viewerCount;
      }
      features['avgViewers'] = totalViewers ~/ rooms.length;
    }

    return features;
  }

  // ==================== CALCULATE SIMILARITY ====================

  double _calculateSimilarity(
      Map<String, dynamic> features1,
      Map<String, dynamic> features2,
      ) {
    double similarity = 0;

    // Compare categories
    final Map<String, int> cats1 = features1['categories'] as Map<String, int>? ?? {};
    final Map<String, int> cats2 = features2['categories'] as Map<String, int>? ?? {};

    if (cats1.isNotEmpty && cats2.isNotEmpty) {
      int commonCategories = 0;
      cats1.forEach((String cat, int count) {
        if (cats2.containsKey(cat)) {
          commonCategories++;
        }
      });
      similarity += (commonCategories / max(cats1.length, cats2.length)) * 0.7;
    }

    // Compare viewer counts
    final int viewers1 = features1['avgViewers'] as int? ?? 0;
    final int viewers2 = features2['avgViewers'] as int? ?? 0;

    if (viewers1 > 0 && viewers2 > 0) {
      final double ratio = min(viewers1, viewers2) / max(viewers1, viewers2);
      similarity += ratio * 0.3;
    }

    return similarity;
  }

  // ==================== USER-BASED RECOMMENDATIONS ====================

  Future<List<RoomModel>> getRecommendedRooms(String userId) async {
    final app.User? user = await _getUser(userId);
    if (user == null) return [];

    // Get user's interests and behavior
    final List<String> userInterests = user.interests;
    final String userCountry = user.countryId;
    final app.UserTier userTier = user.tier ?? app.UserTier.normal;

    // Get user's room history
    final List<String> roomHistory = await _getUserRoomHistory(userId);

    // Calculate scores for rooms
    final List<RoomModel> rooms = await _getActiveRooms();
    final List<Map<String, dynamic>> scoredRooms = [];

    for (RoomModel room in rooms) {
      double score = 0;

      // Interest matching (30%)
      if (userInterests.any((String interest) => room.category.contains(interest))) {
        score += 30;
      }

      // Country matching (20%)
      if (room.country == userCountry) {
        score += 20;
      }

      // Popularity (20%)
      score += (room.viewerCount / 1000).clamp(0, 20).toDouble();

      // Freshness (15%)
      final int age = DateTime.now().difference(room.createdAt).inHours;
      score += max(0, 15 - age).toDouble();

      // Boost if user has visited before
      if (roomHistory.contains(room.id)) {
        score += 10;
      }

      scoredRooms.add({'room': room, 'score': score});
    }

    // Sort by score and return top 20
    scoredRooms.sort((a, b) => b['score'].compareTo(a['score']));
    return scoredRooms.take(20).map((item) => item['room'] as RoomModel).toList();
  }

  // ==================== SIMILAR USERS ====================

  Future<List<app.User>> getSimilarUsers(String userId) async {
    final app.User? user = await _getUser(userId);
    if (user == null) return [];

    final List<app.User> allUsers = await _getAllUsers();
    final List<Map<String, dynamic>> scoredUsers = [];

    for (app.User otherUser in allUsers) {
      if (otherUser.id == userId) continue;

      double score = 0;

      // Same country (30%)
      if (otherUser.countryId == user.countryId) {
        score += 30;
      }

      // Common interests (40%)
      final int commonInterests = user.interests
          .where((String interest) => otherUser.interests.contains(interest))
          .length;
      if (user.interests.isNotEmpty) {
        score += (commonInterests / user.interests.length) * 40;
      }

      // Same tier (20%)
      if (otherUser.tier == user.tier) {
        score += 20;
      }

      scoredUsers.add({'user': otherUser, 'score': score});
    }

    scoredUsers.sort((a, b) => b['score'].compareTo(a['score']));
    return scoredUsers.take(10).map((item) => item['user'] as app.User).toList();
  }

  // ==================== GIFT RECOMMENDATIONS ====================

  Future<List<GiftModel>> getRecommendedGifts(String userId, String receiverId) async {
    final app.User? user = await _getUser(userId);
    final app.User? receiver = await _getUser(receiverId);

    if (user == null || receiver == null) return [];

    // Get popular gifts
    final List<GiftModel> popularGifts = await _getPopularGifts();

    // Get tier-appropriate gifts
    final List<GiftModel> tierGifts = await _getTierGifts(receiver.tier ?? app.UserTier.normal);

    // Combine and score
    final Set<String> recommendedIds = {};
    final List<GiftModel> recommendations = [];

    // Add tier-appropriate gifts first
    for (GiftModel gift in tierGifts) {
      if (!recommendedIds.contains(gift.id) && user.coins >= gift.price) {
        recommendations.add(gift);
        recommendedIds.add(gift.id);
      }
    }

    // Add popular gifts
    for (GiftModel gift in popularGifts) {
      if (!recommendedIds.contains(gift.id) && user.coins >= gift.price) {
        recommendations.add(gift);
        recommendedIds.add(gift.id);
      }
    }

    return recommendations.take(10).toList();
  }

  // ==================== FOR YOU FEED ====================

  Future<List<Map<String, dynamic>>> getForYouFeed(String userId) async {
    final app.User? user = await _getUser(userId);
    if (user == null) return [];

    final List<Map<String, dynamic>> feed = [];

    // 1. Recommended rooms (40%)
    final List<RoomModel> recommendedRooms = await getRecommendedRooms(userId);
    feed.addAll(recommendedRooms.map((RoomModel room) => {
      'type': 'room',
      'data': room,
      'priority': 1,
    }));

    // 2. Popular posts from similar users (30%)
    final List<app.User> similarUsers = await getSimilarUsers(userId);
    final List<Map<String, dynamic>> popularPosts = await _getPopularPostsFromUsers(
      similarUsers.map((app.User u) => u.id).toList(),
    );
    feed.addAll(popularPosts.map((Map<String, dynamic> post) => {
      'type': 'post',
      'data': post,
      'priority': 2,
    }));

    // 3. Trending gifts (20%)
    final List<GiftModel> trendingGifts = await _getTrendingGifts();
    feed.addAll(trendingGifts.map((GiftModel gift) => {
      'type': 'gift',
      'data': gift,
      'priority': 3,
    }));

    // 4. Events in user's country (10%)
    final List<Map<String, dynamic>> localEvents = await _getLocalEvents(user.countryId);
    feed.addAll(localEvents.map((Map<String, dynamic> event) => {
      'type': 'event',
      'data': event,
      'priority': 4,
    }));

    // Sort by priority
    feed.sort((a, b) => a['priority'].compareTo(b['priority']));
    return feed;
  }

  // ==================== COLLABORATIVE FILTERING ====================

  Future<List<app.User>> getCollaborativeRecommendations(String userId) async {
    // Find users with similar behavior patterns
    final app.User? user = await _getUser(userId);
    if (user == null) return [];

    // Get user's interactions
    final List<String> userRooms = await _getUserRoomHistory(userId);
    final List<String> userGifts = await _getUserGiftHistory(userId);

    // Find users who interacted with same rooms/gifts
    final List<String> similarUsers = await _findUsersByInteractions(userRooms, userGifts);

    // Get what those users liked that this user hasn't seen
    final List<app.User> recommendations = await _getNewRecommendations(userId, similarUsers);

    return recommendations;
  }

  // ==================== CONTENT-BASED FILTERING ====================

  Future<List<RoomModel>> getContentBasedRecommendations(String userId) async {
    final app.User? user = await _getUser(userId);
    if (user == null) return [];

    // Get user's favorite rooms
    final List<RoomModel> favoriteRooms = await _getUserFavoriteRooms(userId);

    // Extract features from favorite rooms
    final Map<String, dynamic> favoriteFeatures = _extractRoomFeatures(favoriteRooms);

    // Find rooms with similar features
    final List<RoomModel> allRooms = await _getActiveRooms();
    final List<RoomModel> recommendations = [];

    for (RoomModel room in allRooms) {
      if (favoriteRooms.any((RoomModel fr) => fr.id == room.id)) continue;

      final Map<String, dynamic> roomFeatures = _extractRoomFeatures([room]);
      final double similarity = _calculateSimilarity(favoriteFeatures, roomFeatures);

      if (similarity > 0.5) {
        recommendations.add(room);
      }
    }

    return recommendations.take(20).toList();
  }
}