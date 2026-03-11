import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/room_model.dart';
import '../models/gift_model.dart';

class RecommendationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ==================== USER-BASED RECOMMENDATIONS ====================
  Future<List<RoomModel>> getRecommendedRooms(String userId) async {
    final user = await _getUser(userId);
    if (user == null) return [];

    // Get user's interests and behavior
    final userInterests = user.interests;
    final userCountry = user.country;
    final userTier = user.tier;

    // Get user's room history
    final roomHistory = await _getUserRoomHistory(userId);

    // Calculate scores for rooms
    final rooms = await _getActiveRooms();
    final List<Map<String, dynamic>> scoredRooms = [];

    for (var room in rooms) {
      double score = 0;

      // Interest matching (30%)
      if (userInterests.any((interest) => room.category.contains(interest))) {
        score += 30;
      }

      // Country matching (20%)
      if (room.country == userCountry) {
        score += 20;
      }

      // Tier matching (15%)
      if (room.hostTier == userTier) {
        score += 15;
      }

      // Popularity (20%)
      score += (room.viewerCount / 1000).clamp(0, 20);

      // Freshness (15%)
      final age = DateTime.now().difference(room.createdAt).inHours;
      score += max(0, 15 - age);

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
  Future<List<UserModel>> getSimilarUsers(String userId) async {
    final user = await _getUser(userId);
    if (user == null) return [];

    final allUsers = await _getAllUsers();
    final List<Map<String, dynamic>> scoredUsers = [];

    for (var otherUser in allUsers) {
      if (otherUser.uid == userId) continue;

      double score = 0;

      // Same country (30%)
      if (otherUser.country == user.country) {
        score += 30;
      }

      // Common interests (40%)
      final commonInterests = user.interests
          .where((interest) => otherUser.interests.contains(interest))
          .length;
      score += (commonInterests / user.interests.length) * 40;

      // Same tier (20%)
      if (otherUser.tier == user.tier) {
        score += 20;
      }

      // Age similarity (10%)
      // Add age calculation logic here

      scoredUsers.add({'user': otherUser, 'score': score});
    }

    scoredUsers.sort((a, b) => b['score'].compareTo(a['score']));
    return scoredUsers.take(10).map((item) => item['user'] as UserModel).toList();
  }

  // ==================== GIFT RECOMMENDATIONS ====================
  Future<List<GiftModel>> getRecommendedGifts(String userId, String receiverId) async {
    final user = await _getUser(userId);
    final receiver = await _getUser(receiverId);
    
    if (user == null || receiver == null) return [];

    // Get gift sending history
    final giftHistory = await _getGiftHistory(userId, receiverId);
    
    // Get popular gifts
    final popularGifts = await _getPopularGifts();

    // Get tier-appropriate gifts
    final tierGifts = await _getTierGifts(receiver.tier);

    // Combine and score
    final Set<String> recommendedIds = {};
    final List<GiftModel> recommendations = [];

    // Add tier-appropriate gifts first
    for (var gift in tierGifts) {
      if (!recommendedIds.contains(gift.id) && user.coins >= gift.price) {
        recommendations.add(gift);
        recommendedIds.add(gift.id);
      }
    }

    // Add popular gifts
    for (var gift in popularGifts) {
      if (!recommendedIds.contains(gift.id) && user.coins >= gift.price) {
        recommendations.add(gift);
        recommendedIds.add(gift.id);
      }
    }

    return recommendations.take(10).toList();
  }

  // ==================== FOR YOU FEED ====================
  Future<List<Map<String, dynamic>>> getForYouFeed(String userId) async {
    final user = await _getUser(userId);
    if (user == null) return [];

    final feed = <Map<String, dynamic>>[];

    // 1. Recommended rooms (40%)
    final recommendedRooms = await getRecommendedRooms(userId);
    feed.addAll(recommendedRooms.map((room) => {
      'type': 'room',
      'data': room,
      'priority': 1,
    }));

    // 2. Popular posts from similar users (30%)
    final similarUsers = await getSimilarUsers(userId);
    final popularPosts = await _getPopularPostsFromUsers(
      similarUsers.map((u) => u.uid).toList(),
    );
    feed.addAll(popularPosts.map((post) => {
      'type': 'post',
      'data': post,
      'priority': 2,
    }));

    // 3. Trending gifts (20%)
    final trendingGifts = await _getTrendingGifts();
    feed.addAll(trendingGifts.map((gift) => {
      'type': 'gift',
      'data': gift,
      'priority': 3,
    }));

    // 4. Events in user's country (10%)
    final localEvents = await _getLocalEvents(user.country);
    feed.addAll(localEvents.map((event) => {
      'type': 'event',
      'data': event,
      'priority': 4,
    }));

    // Sort by priority
    feed.sort((a, b) => a['priority'].compareTo(b['priority']));
    return feed;
  }

  // ==================== COLLABORATIVE FILTERING ====================
  Future<List<UserModel>> getCollaborativeRecommendations(String userId) async {
    // Find users with similar behavior patterns
    final user = await _getUser(userId);
    if (user == null) return [];

    // Get user's interactions
    final userRooms = await _getUserRoomHistory(userId);
    final userGifts = await _getUserGiftHistory(userId);

    // Find users who interacted with same rooms/gifts
    final similarUsers = await _findUsersByInteractions(userRooms, userGifts);
    
    // Get what those users liked that this user hasn't seen
    final recommendations = await _getNewRecommendations(userId, similarUsers);

    return recommendations;
  }

  // ==================== CONTENT-BASED FILTERING ====================
  Future<List<RoomModel>> getContentBasedRecommendations(String userId) async {
    final user = await _getUser(userId);
    if (user == null) return [];

    // Get user's favorite rooms
    final favoriteRooms = await _getUserFavoriteRooms(userId);
    
    // Extract features from favorite rooms
    final favoriteFeatures = _extractRoomFeatures(favoriteRooms);
    
    // Find rooms with similar features
    final allRooms = await _getActiveRooms();
    final recommendations = <RoomModel>[];

    for (var room in allRooms) {
      if (favoriteRooms.any((fr) => fr.id == room.id)) continue;

      final roomFeatures = _extractRoomFeatures([room]);
      final similarity = _calculateSimilarity(favoriteFeatures, roomFeatures);
      
      if (similarity > 0.5) {
        recommendations.add(room);
      }
    }

    return recommendations.take(20).toList();
  }

  // ==================== HELPER METHODS ====================
  Future<UserModel?> _getUser(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    if (doc.exists) {
      return UserModel.fromJson(doc.data()!);
    }
    return null;
  }

  Future<List<UserModel>> _getAllUsers() async {
    final snapshot = await _firestore.collection('users').limit(1000).get();
    return snapshot.docs
        .map((doc) => UserModel.fromJson(doc.data()))
        .toList();
  }

  Future<List<RoomModel>> _getActiveRooms() async {
    final snapshot = await _firestore
        .collection('rooms')
        .where('isActive', isEqualTo: true)
        .limit(100)
        .get();
    return snapshot.docs
        .map((doc) => RoomModel.fromJson(doc.data()))
        .toList();
  }

  Future<List<String>> _getUserRoomHistory(String userId) async {
    final snapshot = await _firestore
        .collection('room_history')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .limit(50)
        .get();
    
    return snapshot.docs
        .map((doc) => doc.data()['roomId'] as String)
        .toList();
  }

  Future<List<GiftModel>> _getPopularGifts() async {
    final snapshot = await _firestore
        .collection('gifts')
        .orderBy('sentCount', descending: true)
        .limit(20)
        .get();
    
    return snapshot.docs
        .map((doc) => GiftModel.fromJson(doc.data()))
        .toList();
  }

  Future<List<GiftModel>> _getTierGifts(UserTier tier) async {
    final isVip = tier.index >= UserTier.vip1.index && tier.index <= UserTier.vip10.index;
    final isSvip = tier.index >= UserTier.svip1.index;
    
    Query query = _firestore.collection('gifts');
    
    if (isSvip) {
      query = query.where('isSvip', isEqualTo: true);
    } else if (isVip) {
      query = query.where('isVip', isEqualTo: true);
    }
    
    final snapshot = await query.limit(10).get();
    return snapshot.docs
        .map((doc) => GiftModel.fromJson(doc.data()))
        .toList();
  }

  Future<List<Map<String, dynamic>>> _getGiftHistory(String userId, String receiverId) async {
    final snapshot = await _firestore
        .collection('gifts_sent')
        .where('senderId', isEqualTo: userId)
        .where('receiverId', isEqualTo: receiverId)
        .orderBy('timestamp', descending: true)
        .limit(20)
        .get();
    
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  Future<List<Map<String, dynamic>>> _getPopularPostsFromUsers(List<String> userIds) async {
    if (userIds.isEmpty) return [];
    
    final snapshot = await _firestore
        .collection('posts')
        .where('userId', whereIn: userIds)
        .orderBy('likes', descending: true)
        .limit(20)
        .get();
    
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  Future<List<GiftModel>> _getTrendingGifts() async {
    final lastHour = DateTime.now().subtract(Duration(hours: 1));
    
    final snapshot = await _firestore
        .collection('gifts_sent')
        .where('timestamp', isGreaterThanOrEqualTo: lastHour)
        .get();
    
    // Count gift occurrences
    final Map<String, int> giftCounts = {};
    for (var doc in snapshot.docs) {
      final giftId = doc.data()['giftId'];
      giftCounts[giftId] = (giftCounts[giftId] ?? 0) + 1;
    }
    
    // Sort by count
    final sortedGifts = giftCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    // Get gift details
    final trendingGifts = <GiftModel>[];
    for (var entry in sortedGifts.take(10)) {
      final giftDoc = await _firestore.collection('gifts').doc(entry.key).get();
      if (giftDoc.exists) {
        trendingGifts.add(GiftModel.fromJson(giftDoc.data()!));
      }
    }
    
    return trendingGifts;
  }

  Future<List<Map<String, dynamic>>> _getLocalEvents(String country) async {
    final snapshot = await _firestore
        .collection('events')
        .where('country', isEqualTo: country)
        .where('endDate', isGreaterThanOrEqualTo: DateTime.now())
        .orderBy('startDate')
        .limit(10)
        .get();
    
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  Future<List<String>> _getUserGiftHistory(String userId) async {
    final snapshot = await _firestore
        .collection('gifts_sent')
        .where('senderId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .limit(50)
        .get();
    
    return snapshot.docs
        .map((doc) => doc.data()['giftId'] as String)
        .toList();
  }

  Future<List<String>> _findUsersByInteractions(
    List<String> rooms,
    List<String> gifts,
  ) async {
    // Find users who interacted with same rooms
    final roomUsers = await _firestore
        .collection('room_history')
        .where('roomId', whereIn: rooms.take(10).toList())
        .get();
    
    // Find users who sent/received same gifts
    final giftUsers = await _firestore
        .collection('gifts_sent')
        .where('giftId', whereIn: gifts.take(10).toList())
        .get();
    
    final Set<String> similarUsers = {};
    
    for (var doc in roomUsers.docs) {
      similarUsers.add(doc.data()['userId']);
    }
    
    for (var doc in giftUsers.docs) {
      similarUsers.add(doc.data()['senderId']);
      similarUsers.add(doc.data()['receiverId']);
    }
    
    return similarUsers.toList();
  }

  Future<List<UserModel>> _getNewRecommendations(
    String userId,
    List<String> similarUsers,
  ) async {
    // Get what similar users liked
    final recommendations = <UserModel>[];
    final Set<String> recommendedIds = {};
    
    for (var similarUserId in similarUsers.take(20)) {
      final similarUser = await _getUser(similarUserId);
      if (similarUser != null && !recommendedIds.contains(similarUser.uid)) {
        recommendations.add(similarUser);
        recommendedIds.add(similarUser.uid);
      }
    }
    
    return recommendations;
  }

  Future<List<RoomModel>> _getUserFavoriteRooms(String userId) async {
    final snapshot = await _firestore
        .collection('room_history')
        .where('userId', isEqualTo: userId)
        .where('isFavorite', isEqualTo: true)
        .limit(20)
        .get();
    
    final rooms = <RoomModel>[];
    for (var doc in snapshot.docs) {
      final roomDoc = await _firestore
          .collection('rooms')
          .doc(doc.data()['roomId'])
          .get();
      if (roomDoc.exists) {
        rooms.add(RoomModel.fromJson(roomDoc.data()!));
      }
    }
    
    return rooms;
  }

  Map<String, dynamic> _extractRoomFeatures(List<RoomModel> rooms) {
    final features = <String, dynamic>{};
    
    // Category distribution
    final categories = <String, int>{};
    for (var room in rooms) {
      categories[room.category] = (categories[room.category] ?? 0) + 1;
    }
    features['categories'] = categories;
    
    // Average viewer count
    if (rooms.isNotEmpty) {
      features['avgViewers'] = rooms
          .map((r) => r.viewerCount)
          .reduce((a, b) => a + b) ~/
          rooms.length;
    }
    
    return features;
  }

  double _calculateSimilarity(
    Map<String, dynamic> features1,
    Map<String, dynamic> features2,
  ) {
    double similarity = 0;
    
    // Compare categories
    final cats1 = features1['categories'] as Map<String, int>? ?? {};
    final cats2 = features2['categories'] as Map<String, int>? ?? {};
    
    if (cats1.isNotEmpty && cats2.isNotEmpty) {
      int commonCategories = 0;
      cats1.forEach((cat, count) {
        if (cats2.containsKey(cat)) {
          commonCategories++;
        }
      });
      similarity += (commonCategories / max(cats1.length, cats2.length)) * 0.7;
    }
    
    // Compare viewer counts
    final viewers1 = features1['avgViewers'] as int? ?? 0;
    final viewers2 = features2['avgViewers'] as int? ?? 0;
    
    if (viewers1 > 0 && viewers2 > 0) {
      final ratio = min(viewers1, viewers2) / max(viewers1, viewers2);
      similarity += ratio * 0.3;
    }
    
    return similarity;
  }
}