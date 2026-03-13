import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/room_model.dart';
import '../models/gift_model.dart';

class RecommendationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ==================== USER-BASED RECOMMENDATIONS ====================
  Future<List<RoomModel>> getRecommendedRooms(String userId) async {
    final UserModel? user = await _getUser(userId);
    if (user == null) return <RoomModel>[];

    // Get user's interests and behavior
    final List<String> userInterests = user.interests;
    final String userCountry = user.country;
    final UserTier userTier = user.tier;

    // Get user's room history
    final List<String> roomHistory = await _getUserRoomHistory(userId);

    // Calculate scores for rooms
    final List<RoomModel> rooms = await _getActiveRooms();
    final scoredRooms = <Map<String, dynamic>><Map<String, dynamic>>[];

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

      // Tier matching (15%)
      if (room.hostTier == userTier) {
        score += 15;
      }

      // Popularity (20%)
      score += (room.viewerCount / 1000).clamp(0, 20);

      // Freshness (15%)
      final int age = DateTime.now().difference(room.createdAt).inHours;
      score += max(0, 15 - age);

      // Boost if user has visited before
      if (roomHistory.contains(room.id)) {
        score += 10;
      }

      scoredRooms.add(<String, dynamic>{'room': room, 'score': score});
    }

    // Sort by score and return top 20
    scoredRooms.sort((Map<String, dynamic> a, Map<String, dynamic> b) => b['score'].compareTo(a['score']));
    return scoredRooms.take(20).map((Map<String, dynamic> item) => item['room'] as RoomModel).toList();
  }

  // ==================== SIMILAR USERS ====================
  Future<List<UserModel>> getSimilarUsers(String userId) async {
    final UserModel? user = await _getUser(userId);
    if (user == null) return <UserModel>[];

    final List<UserModel> allUsers = await _getAllUsers();
    final scoredUsers = <Map<String, dynamic>><Map<String, dynamic>>[];

    for (UserModel otherUser in allUsers) {
      if (otherUser.uid == userId) continue;

      double score = 0;

      // Same country (30%)
      if (otherUser.country == user.country) {
        score += 30;
      }

      // Common interests (40%)
      final int commonInterests = user.interests
          .where((String interest) => otherUser.interests.contains(interest))
          .length;
      score += (commonInterests / user.interests.length) * 40;

      // Same tier (20%)
      if (otherUser.tier == user.tier) {
        score += 20;
      }

      // Age similarity (10%)
      // Add age calculation logic here

      scoredUsers.add(<String, dynamic>{'user': otherUser, 'score': score});
    }

    scoredUsers.sort((Map<String, dynamic> a, Map<String, dynamic> b) => b['score'].compareTo(a['score']));
    return scoredUsers.take(10).map((Map<String, dynamic> item) => item['user'] as UserModel).toList();
  }

  // ==================== GIFT RECOMMENDATIONS ====================
  Future<List<GiftModel>> getRecommendedGifts(String userId, String receiverId) async {
    final UserModel? user = await _getUser(userId);
    final UserModel? receiver = await _getUser(receiverId);
    
    if (user == null || receiver == null) return <GiftModel>[];

    // Get gift sending history
    final List<Map<String, dynamic>> giftHistory = await _getGiftHistory(userId, receiverId);
    
    // Get popular gifts
    final List<GiftModel> popularGifts = await _getPopularGifts();

    // Get tier-appropriate gifts
    final List<GiftModel> tierGifts = await _getTierGifts(receiver.tier);

    // Combine and score
    final recommendedIds = <String><String>{};
    final recommendations = <GiftModel><GiftModel>[];

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
    final UserModel? user = await _getUser(userId);
    if (user == null) return <Map<String, dynamic>>[];

    final List<Map<String, dynamic>> feed = <Map<String, dynamic>>[];

    // 1. Recommended rooms (40%)
    final List<RoomModel> recommendedRooms = await getRecommendedRooms(userId);
    feed.addAll(recommendedRooms.map((RoomModel room) => <String, dynamic>{
      'type': 'room',
      'data': room,
      'priority': 1,
    }));

    // 2. Popular posts from similar users (30%)
    final List<UserModel> similarUsers = await getSimilarUsers(userId);
    final List<Map<String, dynamic>> popularPosts = await _getPopularPostsFromUsers(
      similarUsers.map((UserModel u) => u.uid).toList(),
    );
    feed.addAll(popularPosts.map((Map<String, dynamic> post) => <String, dynamic>{
      'type': 'post',
      'data': post,
      'priority': 2,
    }));

    // 3. Trending gifts (20%)
    final List<GiftModel> trendingGifts = await _getTrendingGifts();
    feed.addAll(trendingGifts.map((GiftModel gift) => <String, dynamic>{
      'type': 'gift',
      'data': gift,
      'priority': 3,
    }));

    // 4. Events in user's country (10%)
    final List<Map<String, dynamic>> localEvents = await _getLocalEvents(user.country);
    feed.addAll(localEvents.map((Map<String, dynamic> event) => <String, dynamic>{
      'type': 'event',
      'data': event,
      'priority': 4,
    }));

    // Sort by priority
    feed.sort((Map<String, dynamic> a, Map<String, dynamic> b) => a['priority'].compareTo(b['priority']));
    return feed;
  }

  // ==================== COLLABORATIVE FILTERING ====================
  Future<List<UserModel>> getCollaborativeRecommendations(String userId) async {
    // Find users with similar behavior patterns
    final UserModel? user = await _getUser(userId);
    if (user == null) return <UserModel>[];

    // Get user's interactions
    final List<String> userRooms = await _getUserRoomHistory(userId);
    final List<String> userGifts = await _getUserGiftHistory(userId);

    // Find users who interacted with same rooms/gifts
    final List<String> similarUsers = await _findUsersByInteractions(userRooms, userGifts);
    
    // Get what those users liked that this user hasn't seen
    final List<UserModel> recommendations = await _getNewRecommendations(userId, similarUsers);

    return recommendations;
  }

  // ==================== CONTENT-BASED FILTERING ====================
  Future<List<RoomModel>> getContentBasedRecommendations(String userId) async {
    final UserModel? user = await _getUser(userId);
    if (user == null) return <RoomModel>[];

    // Get user's favorite rooms
    final List<RoomModel> favoriteRooms = await _getUserFavoriteRooms(userId);
    
    // Extract features from favorite rooms
    final Map<String, dynamic> favoriteFeatures = _extractRoomFeatures(favoriteRooms);
    
    // Find rooms with similar features
    final List<RoomModel> allRooms = await _getActiveRooms();
    final List<RoomModel> recommendations = <RoomModel>[];

    for (RoomModel room in allRooms) {
      if (favoriteRooms.any((RoomModel fr) => fr.id == room.id)) continue;

      final Map<String, dynamic> roomFeatures = _extractRoomFeatures(<RoomModel>[room]);
      final double similarity = _calculateSimilarity(favoriteFeatures, roomFeatures);
      
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
    final bool isVip = tier.index >= UserTier.vip1.index && tier.index <= UserTier.vip10.index;
    final bool isSvip = tier.index >= UserTier.svip1.index;
    
    var query = _firestore.collection('gifts');
    
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
    if (userIds.isEmpty) return <Map<String, dynamic>>[];
    
    final snapshot = await _firestore
        .collection('posts')
        .where('userId', whereIn: userIds)
        .orderBy('likes', descending: true)
        .limit(20)
        .get();
    
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  Future<List<GiftModel>> _getTrendingGifts() async {
    final DateTime lastHour = DateTime.now().subtract(const Duration(hours: 1));
    
    final snapshot = await _firestore
        .collection('gifts_sent')
        .where('timestamp', isGreaterThanOrEqualTo: lastHour)
        .get();
    
    // Count gift occurrences
    final giftCounts = <String, int><String, int>{};
    for (final doc in snapshot.docs) {
      final giftId = doc.data()['giftId'];
      giftCounts[giftId] = (giftCounts[giftId] ?? 0) + 1;
    }
    
    // Sort by count
    final List<MapEntry<String, int>> sortedGifts = giftCounts.entries.toList()
      ..sort((MapEntry<String, int> a, MapEntry<String, int> b) => b.value.compareTo(a.value));
    
    // Get gift details
    final List<GiftModel> trendingGifts = <GiftModel>[];
    for (MapEntry<String, int> entry in sortedGifts.take(10)) {
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
    
    final similarUsers = <String><String>{};
    
    for (final doc in roomUsers.docs) {
      similarUsers.add(doc.data()['userId']);
    }
    
    for (final doc in giftUsers.docs) {
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
    final List<UserModel> recommendations = <UserModel>[];
    final recommendedIds = <String><String>{};
    
    for (String similarUserId in similarUsers.take(20)) {
      final UserModel? similarUser = await _getUser(similarUserId);
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
    
    final List<RoomModel> rooms = <RoomModel>[];
    for (final doc in snapshot.docs) {
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
    final Map<String, dynamic> features = <String, dynamic>{};
    
    // Category distribution
    final Map<String, int> categories = <String, int>{};
    for (RoomModel room in rooms) {
      categories[room.category] = (categories[room.category] ?? 0) + 1;
    }
    features['categories'] = categories;
    
    // Average viewer count
    if (rooms.isNotEmpty) {
      features['avgViewers'] = rooms
          .map((RoomModel r) => r.viewerCount)
          .reduce((int a, int b) => a + b) ~/
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
    final Map<String, int> cats1 = features1['categories'] as Map<String, int>? ?? <String, int>{};
    final Map<String, int> cats2 = features2['categories'] as Map<String, int>? ?? <String, int>{};
    
    if (cats1.isNotEmpty && cats2.isNotEmpty) {
      var commonCategories = 0;
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
}