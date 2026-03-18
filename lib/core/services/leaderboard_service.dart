import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart'; // 🟢 debugPrint এর জন্য
import '../models/leaderboard_model.dart';
import '../models/user_models.dart' as app; // 🟢 UserModel এর পরিবর্তে app.User

class LeaderboardService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get leaderboard
  Future<LeaderboardModel?> getLeaderboard({
    required LeaderboardType type,
    required LeaderboardPeriod period,
    required LeaderboardCategory category,
    int limit = 100,
    String? country,
    int? ageMin,
    int? ageMax,
    String? gender,
  }) async {
    try {
      final String leaderboardId = _generateLeaderboardId(type, period, category, country);

      // Try to get cached leaderboard first
      final DocumentSnapshot<Map<String, dynamic>> cachedDoc = await _firestore
          .collection('leaderboards')
          .doc(leaderboardId)
          .get();

      if (cachedDoc.exists) {
        final Map<String, dynamic>? data = cachedDoc.data();
        if (data != null) {
          final DateTime generatedAt = (data['generatedAt'] as Timestamp).toDate();

          // Return cached if less than 1 hour old
          if (DateTime.now().difference(generatedAt).inHours < 1) {
            return LeaderboardModel.fromJson(data);
          }
        }
      }

      // Generate new leaderboard
      return await _generateLeaderboard(
        type: type,
        period: period,
        category: category,
        limit: limit,
        country: country,
        ageMin: ageMin,
        ageMax: ageMax,
        gender: gender,
      );
    } catch (e) {
      debugPrint('Error getting leaderboard: $e');
      return null;
    }
  }

  // Generate leaderboard
  Future<LeaderboardModel> _generateLeaderboard({
    required LeaderboardType type,
    required LeaderboardPeriod period,
    required LeaderboardCategory category,
    int limit = 100,
    String? country,
    int? ageMin,
    int? ageMax,
    String? gender,
  }) async {
    final User? currentUser = _auth.currentUser;

    // Build query based on type
    Query<Map<String, dynamic>> query = _firestore.collection('users');

    if (country != null) {
      query = query.where('countryId', isEqualTo: country); // 🟢 countryId ব্যবহার
    }

    // Order by category
    switch (category) {
      case LeaderboardCategory.gifts:
        query = query.orderBy('totalGiftsSent', descending: true);
        break;
      case LeaderboardCategory.diamonds:
        query = query.orderBy('totalDiamondsEarned', descending: true);
        break;
      case LeaderboardCategory.games:
        query = query.orderBy('gamesWon', descending: true);
        break;
      case LeaderboardCategory.followers:
        query = query.orderBy('followerCount', descending: true);
        break;
      case LeaderboardCategory.streaming:
        query = query.orderBy('streamingHours', descending: true);
        break;
      case LeaderboardCategory.activity:
        query = query.orderBy('activityPoints', descending: true);
        break;
    }

    final QuerySnapshot<Map<String, dynamic>> snapshot = await query.limit(limit).get();

    final List<LeaderboardEntry> entries = [];
    LeaderboardEntry? currentUserEntry;

    for (var i = 0; i < snapshot.docs.length; i++) {
      final QueryDocumentSnapshot<Map<String, dynamic>> doc = snapshot.docs[i];
      final Map<String, dynamic> userData = doc.data();

      // Get previous rank from cache
      final int previousRank = await _getPreviousRank(doc.id, category);

      final LeaderboardEntry entry = LeaderboardEntry(
        rank: i + 1,
        userId: doc.id,
        username: userData['username'] ?? 'Unknown',
        displayName: userData['name'] ?? userData['username'],
        avatar: userData['avatar'] ?? userData['photoURL'],
        score: _getScore(userData, category),
        previousRank: previousRank,
        change: previousRank == 0 ? 0 : previousRank - (i + 1),
        stats: {
          'totalGifts': userData['totalGiftsSent'] ?? 0,
          'totalDiamonds': userData['totalDiamondsEarned'] ?? 0,
          'gamesWon': userData['gamesWon'] ?? 0,
          'followers': userData['followerCount'] ?? 0,
        },
        badges: List<String>.from(userData['badges'] ?? []),
        isOnline: userData['isOnline'] ?? false,
        country: userData['countryId'],
        level: userData['level'] ?? 1,
      );

      entries.add(entry);

      if (currentUser != null && doc.id == currentUser.uid) {
        currentUserEntry = entry;
      }
    }

    final LeaderboardModel leaderboard = LeaderboardModel(
      id: _generateLeaderboardId(type, period, category, country),
      type: type,
      period: period,
      category: category,
      generatedAt: DateTime.now(),
      entries: entries,
      currentUserEntry: currentUserEntry,
      totalParticipants: await _getTotalParticipants(type, category, country),
      metadata: {
        'country': country,
        'ageMin': ageMin,
        'ageMax': ageMax,
        'gender': gender,
      },
    );

    // Cache the leaderboard
    await _cacheLeaderboard(leaderboard);

    return leaderboard;
  }

  // Get score based on category
  int _getScore(Map<String, dynamic> userData, LeaderboardCategory category) {
    switch (category) {
      case LeaderboardCategory.gifts:
        return userData['totalGiftsSent'] ?? 0;
      case LeaderboardCategory.diamonds:
        return userData['totalDiamondsEarned'] ?? 0;
      case LeaderboardCategory.games:
        return userData['gamesWon'] ?? 0;
      case LeaderboardCategory.followers:
        return userData['followerCount'] ?? 0;
      case LeaderboardCategory.streaming:
        return userData['streamingHours'] ?? 0;
      case LeaderboardCategory.activity:
        return userData['activityPoints'] ?? 0;
    }
  }

  // Get previous rank from cache
  Future<int> _getPreviousRank(String userId, LeaderboardCategory category) async {
    try {
      final DateTime yesterday = DateTime.now().subtract(const Duration(days: 1));
      final String dateStr = '${yesterday.year}-${yesterday.month}-${yesterday.day}';

      final DocumentSnapshot<Map<String, dynamic>> doc = await _firestore
          .collection('leaderboard_history')
          .doc(dateStr)
          .collection(category.toString().split('.').last)
          .doc(userId)
          .get();

      if (doc.exists) {
        return doc.data()!['rank'] ?? 0;
      }
      return 0;
    } catch (e) {
      debugPrint('Error getting previous rank: $e');
      return 0;
    }
  }

  // Get total participants
  Future<int> _getTotalParticipants(
      LeaderboardType type,
      LeaderboardCategory category,
      String? country,
      ) async {
    try {
      Query<Map<String, dynamic>> query = _firestore.collection('users');

      if (country != null) {
        query = query.where('countryId', isEqualTo: country);
      }

      final AggregateQuerySnapshot snapshot = await query.count().get();
      return snapshot.count ?? 0;
    } catch (e) {
      debugPrint('Error getting total participants: $e');
      return 0;
    }
  }

  // Cache leaderboard
  Future<void> _cacheLeaderboard(LeaderboardModel leaderboard) async {
    try {
      await _firestore
          .collection('leaderboards')
          .doc(leaderboard.id)
          .set(leaderboard.toJson());
    } catch (e) {
      debugPrint('Error caching leaderboard: $e');
    }
  }

  // Generate leaderboard ID
  String _generateLeaderboardId(
      LeaderboardType type,
      LeaderboardPeriod period,
      LeaderboardCategory category,
      String? country,
      ) {
    final List<String> parts = [
      'leaderboard',
      type.toString().split('.').last,
      period.toString().split('.').last,
      category.toString().split('.').last,
      if (country != null) country,
    ];
    return parts.join('_');
  }

  // Get friends leaderboard
  Future<LeaderboardModel?> getFriendsLeaderboard(
      LeaderboardCategory category, {
        int limit = 50,
      }) async {
    final User? user = _auth.currentUser;
    if (user == null) return null;

    try {
      // Get user's friends
      final QuerySnapshot<Map<String, dynamic>> friendsSnapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('friends')
          .get();

      final List<String> friendIds = friendsSnapshot.docs
          .map((QueryDocumentSnapshot<Map<String, dynamic>> doc) => doc.data()['friendId'] as String)
          .toList();

      friendIds.add(user.uid); // Include self

      if (friendIds.isEmpty) return null;

      // Get leaderboard for friends
      final QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
          .collection('users')
          .where(FieldPath.documentId, whereIn: friendIds)
          .get();

      final List<LeaderboardEntry> entries = [];

      for (var i = 0; i < snapshot.docs.length; i++) {
        final QueryDocumentSnapshot<Map<String, dynamic>> doc = snapshot.docs[i];
        final Map<String, dynamic> userData = doc.data();

        entries.add(LeaderboardEntry(
          rank: i + 1,
          userId: doc.id,
          username: userData['username'] ?? 'Unknown',
          displayName: userData['name'] ?? userData['username'],
          avatar: userData['avatar'] ?? userData['photoURL'],
          score: _getScore(userData, category),
          previousRank: 0,
          change: 0,
          stats: {},
          isOnline: userData['isOnline'] ?? false,
          country: userData['countryId'],
          level: userData['level'] ?? 1,
        ));
      }

      // Sort by score
      entries.sort((LeaderboardEntry a, LeaderboardEntry b) => b.score.compareTo(a.score));

      // Update ranks
      for (var i = 0; i < entries.length; i++) {
        entries[i] = LeaderboardEntry(
          rank: i + 1,
          userId: entries[i].userId,
          username: entries[i].username,
          displayName: entries[i].displayName,
          avatar: entries[i].avatar,
          score: entries[i].score,
          previousRank: 0,
          change: 0,
          stats: entries[i].stats,
          isOnline: entries[i].isOnline,
          country: entries[i].country,
          level: entries[i].level,
        );
      }

      return LeaderboardModel(
        id: 'friends_${DateTime.now().millisecondsSinceEpoch}',
        type: LeaderboardType.friends,
        period: LeaderboardPeriod.allTime,
        category: category,
        generatedAt: DateTime.now(),
        entries: entries,
        currentUserEntry: entries.firstWhere(
              (LeaderboardEntry e) => e.userId == user.uid,
          orElse: () => entries.first,
        ),
        totalParticipants: entries.length,
        metadata: {},
      );
    } catch (e) {
      debugPrint('Error getting friends leaderboard: $e');
      return null;
    }
  }

  // Stream leaderboard updates
  Stream<LeaderboardModel?> streamLeaderboard(String leaderboardId) {
    return _firestore
        .collection('leaderboards')
        .doc(leaderboardId)
        .snapshots()
        .map((DocumentSnapshot<Map<String, dynamic>> doc) {
      if (doc.exists) {
        final data = doc.data()!;
        data['id'] = doc.id;
        return LeaderboardModel.fromJson(data);
      }
      return null;
    });
  }

  // Get leaderboard stats
  Future<LeaderboardStats> getLeaderboardStats() async {
    try {
      final AggregateQuerySnapshot usersSnapshot = await _firestore.collection('users').count().get();

      final DateTime today = DateTime.now();
      final DateTime startOfDay = DateTime(today.year, today.month, today.day);

      final AggregateQuerySnapshot activeTodaySnapshot = await _firestore
          .collection('users')
          .where('lastActive', isGreaterThanOrEqualTo: startOfDay)
          .count()
          .get();

      final DateTime weekAgo = today.subtract(const Duration(days: 7));
      final AggregateQuerySnapshot activeWeekSnapshot = await _firestore
          .collection('users')
          .where('lastActive', isGreaterThanOrEqualTo: weekAgo)
          .count()
          .get();

      final DateTime monthAgo = today.subtract(const Duration(days: 30));
      final AggregateQuerySnapshot newUsersSnapshot = await _firestore
          .collection('users')
          .where('createdAt', isGreaterThanOrEqualTo: monthAgo)
          .count()
          .get();

      // Get top countries
      final QuerySnapshot<Map<String, dynamic>> countriesSnapshot = await _firestore
          .collection('users')
          .limit(1000)
          .get();

      final Map<String, int> countryCount = {};
      for (final QueryDocumentSnapshot<Map<String, dynamic>> doc in countriesSnapshot.docs) {
        final String? country = doc.data()['countryId'] as String?;
        if (country != null) {
          countryCount[country] = (countryCount[country] ?? 0) + 1;
        }
      }

      final sortedEntries = countryCount.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      final Map<String, int> topCountries = {};
      for (var i = 0; i < sortedEntries.length && i < 10; i++) {
        topCountries[sortedEntries[i].key] = sortedEntries[i].value;
      }

      return LeaderboardStats(
        totalPlayers: usersSnapshot.count ?? 0,
        activeToday: activeTodaySnapshot.count ?? 0,
        activeThisWeek: activeWeekSnapshot.count ?? 0,
        newPlayers: newUsersSnapshot.count ?? 0,
        topCountries: topCountries,
        genderDistribution: {},
        ageDistribution: {},
      );
    } catch (e) {
      debugPrint('Error getting leaderboard stats: $e');
      return LeaderboardStats(
        totalPlayers: 0,
        activeToday: 0,
        activeThisWeek: 0,
        newPlayers: 0,
        topCountries: {},
        genderDistribution: {},
        ageDistribution: {},
      );
    }
  }
}