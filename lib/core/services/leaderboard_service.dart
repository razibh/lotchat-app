import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/leaderboard_model.dart';
import '../models/user_model.dart';

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
      final cachedDoc = await _firestore
          .collection('leaderboards')
          .doc(leaderboardId)
          .get();

      if (cachedDoc.exists) {
        final data = cachedDoc.data();
        final generatedAt = (data['generatedAt'] as Timestamp).toDate();
        
        // Return cached if less than 1 hour old
        if (DateTime.now().difference(generatedAt).inHours < 1) {
          return LeaderboardModel.fromJson(data);
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
      print('Error getting leaderboard: $e');
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
    final currentUser = _auth.currentUser;
    
    // Build query based on type
    var query = _firestore.collection('users');
    
    if (country != null) {
      query = query.where('country', isEqualTo: country);
    }
    
    // Filter by age if needed
    if (ageMin != null || ageMax != null) {
      // Note: Age filtering would need birthdate field
    }
    
    if (gender != null) {
      query = query.where('gender', isEqualTo: gender);
    }

    // Order by category
    switch (category) {
      case LeaderboardCategory.gifts:
        query = query.orderBy('totalGiftsSent', descending: true);
      case LeaderboardCategory.diamonds:
        query = query.orderBy('totalDiamondsEarned', descending: true);
      case LeaderboardCategory.games:
        query = query.orderBy('gamesWon', descending: true);
      case LeaderboardCategory.followers:
        query = query.orderBy('followerCount', descending: true);
      case LeaderboardCategory.streaming:
        query = query.orderBy('streamingHours', descending: true);
      case LeaderboardCategory.activity:
        query = query.orderBy('activityPoints', descending: true);
    }

    final snapshot = await query.limit(limit).get();
    
    final List<LeaderboardEntry> entries = <LeaderboardEntry>[];
    LeaderboardEntry? currentUserEntry;

    for (var i = 0; i < snapshot.docs.length; i++) {
      final doc = snapshot.docs[i];
      final userData = doc.data();
      
      // Get previous rank from cache
      final int previousRank = await _getPreviousRank(doc.id, category);
      
      final LeaderboardEntry entry = LeaderboardEntry(
        rank: i + 1,
        userId: doc.id,
        username: userData['username'] ?? 'Unknown',
        displayName: userData['displayName'],
        avatar: userData['photoURL'],
        score: _getScore(userData, category),
        previousRank: previousRank,
        change: previousRank == 0 ? 0 : previousRank - (i + 1),
        stats: <String, dynamic>{
          'totalGifts': userData['totalGiftsSent'] ?? 0,
          'totalDiamonds': userData['totalDiamondsEarned'] ?? 0,
          'gamesWon': userData['gamesWon'] ?? 0,
          'followers': userData['followerCount'] ?? 0,
        },
        badges: userData['badges']?.cast<String>() ?? <String>[],
        isOnline: userData['isOnline'] ?? false,
        country: userData['country'],
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
      metadata: <String, dynamic>{
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
      
      final doc = await _firestore
          .collection('leaderboard_history')
          .doc(dateStr)
          .collection(category.toString())
          .doc(userId)
          .get();

      if (doc.exists) {
        return doc.data()!['rank'];
      }
      return 0;
    } catch (e) {
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
      var query = _firestore.collection('users');
      
      if (country != null) {
        query = query.where('country', isEqualTo: country);
      }
      
      final snapshot = await query.count().get();
      return snapshot.count ?? 0;
    } catch (e) {
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
      print('Error caching leaderboard: $e');
    }
  }

  // Generate leaderboard ID
  String _generateLeaderboardId(
    LeaderboardType type,
    LeaderboardPeriod period,
    LeaderboardCategory category,
    String? country,
  ) {
    final List<String> parts = <String>[
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
    LeaderboardCategory category,
    {int limit = 50}
  ) async {
    final user = _auth.currentUser;
    if (user == null) return null;

    try {
      // Get user's friends
      final friendsSnapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('friends')
          .get();

      final friendIds = friendsSnapshot.docs
          .map((doc) => doc.data()['friendId'])
          .toList();
      
      friendIds.add(user.uid); // Include self

      if (friendIds.isEmpty) return null;

      // Get leaderboard for friends
      final query = _firestore
          .collection('users')
          .where(FieldPath.documentId, whereIn: friendIds);

      final snapshot = await query.get();
      
      final List<LeaderboardEntry> entries = <LeaderboardEntry>[];
      
      for (var i = 0; i < snapshot.docs.length; i++) {
        final doc = snapshot.docs[i];
        final userData = doc.data();
        
        entries.add(LeaderboardEntry(
          rank: i + 1,
          userId: doc.id,
          username: userData['username'] ?? 'Unknown',
          displayName: userData['displayName'],
          avatar: userData['photoURL'],
          score: _getScore(userData, category),
          previousRank: 0,
          change: 0,
          stats: <String, dynamic>{},
          isOnline: userData['isOnline'] ?? false,
          country: userData['country'],
          level: userData['level'] ?? 1,
        ));
      }

      // Sort by score
      entries.sort((LeaderboardEntry a, LeaderboardEntry b) => b.score.compareTo(a.score));
      
      // Update ranks
      for (var i = 0; i < entries.length; i++) {
        entries[i].rank = i + 1;
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
      );
    } catch (e) {
      print('Error getting friends leaderboard: $e');
      return null;
    }
  }

  // Stream leaderboard updates
  Stream<LeaderboardModel?> streamLeaderboard(String leaderboardId) {
    return _firestore
        .collection('leaderboards')
        .doc(leaderboardId)
        .snapshots()
        .map((doc) {
          if (doc.exists) {
            return LeaderboardModel.fromJson(doc.data()!);
          }
          return null;
        });
  }

  // Get leaderboard stats
  Future<LeaderboardStats> getLeaderboardStats() async {
    try {
      final usersSnapshot = await _firestore.collection('users').count().get();
      
      final DateTime today = DateTime.now();
      final DateTime startOfDay = DateTime(today.year, today.month, today.day);
      
      final activeTodaySnapshot = await _firestore
          .collection('users')
          .where('lastActive', isGreaterThanOrEqualTo: startOfDay)
          .count()
          .get();

      final DateTime weekAgo = today.subtract(const Duration(days: 7));
      final activeWeekSnapshot = await _firestore
          .collection('users')
          .where('lastActive', isGreaterThanOrEqualTo: weekAgo)
          .count()
          .get();

      final DateTime monthAgo = today.subtract(const Duration(days: 30));
      final newUsersSnapshot = await _firestore
          .collection('users')
          .where('createdAt', isGreaterThanOrEqualTo: monthAgo)
          .count()
          .get();

      // Get top countries
      final countriesSnapshot = await _firestore
          .collection('users')
          .limit(1000)
          .get();

      final Map<String, int> countryCount = <String, int>{};
      for (final doc in countriesSnapshot.docs) {
        final String? country = doc.data()['country'] as String?;
        if (country != null) {
          countryCount[country] = (countryCount[country] ?? 0) + 1;
        }
      }

      final topCountries = Map.fromEntries(
        countryCount.entries.toList()
          ..sort((MapEntry<String, int> a, MapEntry<String, int> b) => b.value.compareTo(a.value))
      ).take(10);

      return LeaderboardStats(
        totalPlayers: usersSnapshot.count ?? 0,
        activeToday: activeTodaySnapshot.count ?? 0,
        activeThisWeek: activeWeekSnapshot.count ?? 0,
        newPlayers: newUsersSnapshot.count ?? 0,
        topCountries: Map.from(topCountries),
        genderDistribution: <String, int>{}, // Would need gender data
        ageDistribution: <int, int>{}, // Would need age data
      );
    } catch (e) {
      print('Error getting leaderboard stats: $e');
      return LeaderboardStats(
        totalPlayers: 0,
        activeToday: 0,
        activeThisWeek: 0,
        newPlayers: 0,
        topCountries: <String, int>{},
        genderDistribution: <String, int>{},
        ageDistribution: <int, int>{},
      );
    }
  }
}