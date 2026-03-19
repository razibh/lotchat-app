import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/leaderboard_model.dart';
import '../models/user_models.dart' as app;
import '../di/service_locator.dart';

class LeaderboardService {
  late final SupabaseClient _supabase;
  late final String _supabaseUrl;
  late final String _supabaseKey;

  LeaderboardService() {
    _supabase = getService<SupabaseClient>();
    _supabaseUrl = 'YOUR_SUPABASE_URL'; // আপনার URL দিন
    _supabaseKey = 'YOUR_SUPABASE_ANON_KEY'; // আপনার Anon Key দিন
  }

  // Helper to get current user
  String? get _currentUserId => _supabase.auth.currentSession?.user.id;

  // ==================== HTTP HELPER METHODS ====================

  /// Update menggunakan HTTP request
  Future<void> _httpUpdate(String table, Map<String, dynamic> data, String id) async {
    try {
      final session = _supabase.auth.currentSession;
      if (session == null) throw Exception('No session');

      final url = Uri.parse('$_supabaseUrl/rest/v1/$table?id=eq.$id');

      final response = await http.patch(
        url,
        headers: {
          'apikey': _supabaseKey,
          'Authorization': 'Bearer ${session.accessToken}',
          'Content-Type': 'application/json',
          'Prefer': 'return=minimal',
        },
        body: json.encode(data),
      );

      if (response.statusCode >= 400) {
        debugPrint('HTTP Update error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('HTTP Update exception: $e');
    }
  }

  /// Insert menggunakan HTTP request
  Future<void> _httpInsert(String table, Map<String, dynamic> data) async {
    try {
      final session = _supabase.auth.currentSession;
      if (session == null) throw Exception('No session');

      final url = Uri.parse('$_supabaseUrl/rest/v1/$table');

      final response = await http.post(
        url,
        headers: {
          'apikey': _supabaseKey,
          'Authorization': 'Bearer ${session.accessToken}',
          'Content-Type': 'application/json',
          'Prefer': 'return=minimal',
        },
        body: json.encode(data),
      );

      if (response.statusCode >= 400) {
        debugPrint('HTTP Insert error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('HTTP Insert exception: $e');
    }
  }

  /// Select menggunakan HTTP request (যদি প্রয়োজন হয়)
  Future<List<Map<String, dynamic>>> _httpSelect(String table, {Map<String, String>? filters}) async {
    try {
      final session = _supabase.auth.currentSession;
      if (session == null) throw Exception('No session');

      String filterString = '';
      if (filters != null) {
        filterString = '?' + filters.entries.map((e) => '${e.key}=eq.${e.value}').join('&');
      }

      final url = Uri.parse('$_supabaseUrl/rest/v1/$table$filterString');

      final response = await http.get(
        url,
        headers: {
          'apikey': _supabaseKey,
          'Authorization': 'Bearer ${session.accessToken}',
        },
      );

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(json.decode(response.body));
      }
      return [];
    } catch (e) {
      debugPrint('HTTP Select exception: $e');
      return [];
    }
  }

  // ==================== MAIN LEADERBOARD METHODS ====================

  /// Get leaderboard
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
      final cachedDoc = await _supabase
          .from('leaderboards')
          .select()
          .eq('id', leaderboardId)
          .maybeSingle();

      if (cachedDoc != null) {
        final generatedAt = DateTime.parse(cachedDoc['generated_at']);

        // Return cached if less than 1 hour old
        if (DateTime.now().difference(generatedAt).inHours < 1) {
          return LeaderboardModel.fromJson(cachedDoc);
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

  /// Generate leaderboard - HTTP VERSION (সব query HTTP দিয়ে)
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
    final userId = _currentUserId;

    // HTTP দিয়ে users select করছি
    Map<String, String> filters = {};

    String orderByColumn = _getOrderByColumn(category);

    if (country != null) {
      filters['country_id'] = country;
    }

    if (gender != null) {
      filters['gender'] = gender;
    }

    // HTTP request
    final session = _supabase.auth.currentSession;
    if (session == null) throw Exception('No session');

    String filterString = '';
    if (filters.isNotEmpty) {
      filterString = '?' + filters.entries.map((e) => '${e.key}=eq.${e.value}').join('&');
    }

    // Order by and limit যোগ করুন
    final url = Uri.parse('$_supabaseUrl/rest/v1/users$filterString&order=$orderByColumn.desc&limit=$limit');

    final response = await http.get(
      url,
      headers: {
        'apikey': _supabaseKey,
        'Authorization': 'Bearer ${session.accessToken}',
      },
    );

    List<Map<String, dynamic>> responseData = [];
    if (response.statusCode == 200) {
      responseData = List<Map<String, dynamic>>.from(json.decode(response.body));
    }

    final List<LeaderboardEntry> entries = [];
    LeaderboardEntry? currentUserEntry;

    for (var i = 0; i < responseData.length; i++) {
      final userData = responseData[i];

      // Get previous rank from cache
      final int previousRank = await _getPreviousRank(userData['id'], category);

      final LeaderboardEntry entry = LeaderboardEntry(
        rank: i + 1,
        userId: userData['id'] ?? '',
        username: userData['username'] ?? 'Unknown',
        displayName: userData['full_name'] ?? userData['username'],
        avatar: userData['avatar_url'],
        score: _getScore(userData, category),
        previousRank: previousRank,
        change: previousRank == 0 ? 0 : previousRank - (i + 1),
        stats: _getStats(userData, category),
        badges: List<String>.from(userData['badges'] ?? []),
        isOnline: userData['is_online'] ?? false,
        country: userData['country_id'],
        level: userData['level'] ?? 1,
      );

      entries.add(entry);

      if (userId != null && userData['id'] == userId) {
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
      totalParticipants: await _getTotalParticipants(country),
      metadata: {
        'country': country,
        'ageMin': ageMin,
        'ageMax': ageMax,
        'gender': gender,
      },
    );

    // Cache the leaderboard using HTTP
    await _cacheLeaderboardHTTP(leaderboard);

    return leaderboard;
  }

  /// Get order by column based on category
  String _getOrderByColumn(LeaderboardCategory category) {
    switch (category) {
      case LeaderboardCategory.gifts:
        return 'total_gifts_sent';
      case LeaderboardCategory.diamonds:
        return 'total_diamonds_earned';
      case LeaderboardCategory.games:
        return 'games_won';
      case LeaderboardCategory.followers:
        return 'follower_count';
      case LeaderboardCategory.streaming:
        return 'streaming_hours';
      case LeaderboardCategory.activity:
        return 'activity_points';
    }
  }

  /// Get score based on category
  int _getScore(Map<String, dynamic> userData, LeaderboardCategory category) {
    switch (category) {
      case LeaderboardCategory.gifts:
        return userData['total_gifts_sent'] ?? 0;
      case LeaderboardCategory.diamonds:
        return userData['total_diamonds_earned'] ?? 0;
      case LeaderboardCategory.games:
        return userData['games_won'] ?? 0;
      case LeaderboardCategory.followers:
        return userData['follower_count'] ?? 0;
      case LeaderboardCategory.streaming:
        return userData['streaming_hours'] ?? 0;
      case LeaderboardCategory.activity:
        return userData['activity_points'] ?? 0;
    }
  }

  /// Get stats map
  Map<String, dynamic> _getStats(Map<String, dynamic> userData, LeaderboardCategory category) {
    return {
      'totalGifts': userData['total_gifts_sent'] ?? 0,
      'totalDiamonds': userData['total_diamonds_earned'] ?? 0,
      'gamesWon': userData['games_won'] ?? 0,
      'followers': userData['follower_count'] ?? 0,
    };
  }

  /// Get previous rank from cache
  Future<int> _getPreviousRank(String userId, LeaderboardCategory category) async {
    try {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final dateStr = '${yesterday.year}-${yesterday.month}-${yesterday.day}';
      final categoryStr = category.toString().split('.').last;

      final response = await _supabase
          .from('leaderboard_history')
          .select('rank')
          .eq('user_id', userId)
          .eq('date', dateStr)
          .eq('category', categoryStr)
          .maybeSingle();

      return response?['rank'] ?? 0;
    } catch (e) {
      debugPrint('Error getting previous rank: $e');
      return 0;
    }
  }

  /// Get total participants - HTTP VERSION
  Future<int> _getTotalParticipants(String? country) async {
    try {
      final session = _supabase.auth.currentSession;
      if (session == null) return 0;

      String urlStr = '$_supabaseUrl/rest/v1/users?id=select:*';
      if (country != null) {
        urlStr = '$_supabaseUrl/rest/v1/users?country_id=eq.$country&id=select:*';
      }

      final url = Uri.parse(urlStr);

      final response = await http.get(
        url,
        headers: {
          'apikey': _supabaseKey,
          'Authorization': 'Bearer ${session.accessToken}',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data.length;
      }
      return 0;
    } catch (e) {
      debugPrint('Error getting total participants: $e');
      return 0;
    }
  }

  /// Cache leaderboard using HTTP
  Future<void> _cacheLeaderboardHTTP(LeaderboardModel leaderboard) async {
    try {
      final session = _supabase.auth.currentSession;
      if (session == null) return;

      // First delete
      final deleteUrl = Uri.parse('$_supabaseUrl/rest/v1/leaderboards?id=eq.${leaderboard.id}');
      await http.delete(
        deleteUrl,
        headers: {
          'apikey': _supabaseKey,
          'Authorization': 'Bearer ${session.accessToken}',
        },
      );

      // Then insert
      final insertUrl = Uri.parse('$_supabaseUrl/rest/v1/leaderboards');
      await http.post(
        insertUrl,
        headers: {
          'apikey': _supabaseKey,
          'Authorization': 'Bearer ${session.accessToken}',
          'Content-Type': 'application/json',
        },
        body: json.encode(leaderboard.toJson()),
      );

      debugPrint('Leaderboard cached successfully via HTTP');
    } catch (e) {
      debugPrint('Error caching leaderboard via HTTP: $e');
    }
  }

  /// Generate leaderboard ID
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

  // ==================== FRIENDS LEADERBOARD ====================

  /// Get friends leaderboard - HTTP VERSION
  Future<LeaderboardModel?> getFriendsLeaderboard(
      LeaderboardCategory category, {
        int limit = 50,
      }) async {
    final userId = _currentUserId;
    if (userId == null) return null;

    try {
      // Get user's friends using HTTP
      final session = _supabase.auth.currentSession;
      if (session == null) return null;

      final friendsUrl = Uri.parse('$_supabaseUrl/rest/v1/friends?user_id=eq.$userId&status=eq.accepted&select=friend_id');
      final friendsResponse = await http.get(
        friendsUrl,
        headers: {
          'apikey': _supabaseKey,
          'Authorization': 'Bearer ${session.accessToken}',
        },
      );

      List<String> friendIds = [];
      if (friendsResponse.statusCode == 200) {
        final friendsData = json.decode(friendsResponse.body);
        friendIds = friendsData.map<String>((item) => item['friend_id'] as String).toList();
      }

      friendIds.add(userId); // Include self

      if (friendIds.isEmpty) return null;

      // Get users data
      String inFilter = friendIds.map((id) => 'id=eq.$id').join('&');
      final usersUrl = Uri.parse('$_supabaseUrl/rest/v1/users?$inFilter');

      final usersResponse = await http.get(
        usersUrl,
        headers: {
          'apikey': _supabaseKey,
          'Authorization': 'Bearer ${session.accessToken}',
        },
      );

      List<Map<String, dynamic>> usersData = [];
      if (usersResponse.statusCode == 200) {
        usersData = List<Map<String, dynamic>>.from(json.decode(usersResponse.body));
      }

      final List<LeaderboardEntry> entries = [];

      for (var i = 0; i < usersData.length; i++) {
        final userData = usersData[i];

        entries.add(LeaderboardEntry(
          rank: i + 1,
          userId: userData['id'] ?? '',
          username: userData['username'] ?? 'Unknown',
          displayName: userData['full_name'] ?? userData['username'],
          avatar: userData['avatar_url'],
          score: _getScore(userData, category),
          previousRank: 0,
          change: 0,
          stats: _getStats(userData, category),
          isOnline: userData['is_online'] ?? false,
          country: userData['country_id'],
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
              (LeaderboardEntry e) => e.userId == userId,
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

  // ==================== STREAM LEADERBOARD ====================

  /// Stream leaderboard updates
  Stream<LeaderboardModel?> streamLeaderboard(String leaderboardId) {
    try {
      final stream = _supabase
          .from('leaderboards')
          .stream(primaryKey: ['id']);

      return stream.map((data) {
        for (var item in data) {
          if (item['id'] == leaderboardId) {
            return LeaderboardModel.fromJson(item);
          }
        }
        return null;
      });
    } catch (e) {
      debugPrint('Error streaming leaderboard: $e');
      return Stream.value(null);
    }
  }

  // ==================== LEADERBOARD STATS ====================

  /// Get leaderboard stats - HTTP VERSION
  Future<LeaderboardStats> getLeaderboardStats() async {
    try {
      final session = _supabase.auth.currentSession;
      if (session == null) {
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

      // Total users count
      final totalUrl = Uri.parse('$_supabaseUrl/rest/v1/users?id=select:*');
      final totalResponse = await http.get(
        totalUrl,
        headers: {
          'apikey': _supabaseKey,
          'Authorization': 'Bearer ${session.accessToken}',
        },
      );
      final totalPlayers = totalResponse.statusCode == 200
          ? json.decode(totalResponse.body).length
          : 0;

      // Active today
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day).toIso8601String();
      final activeTodayUrl = Uri.parse('$_supabaseUrl/rest/v1/users?last_active=gte.$startOfDay&id=select:*');
      final activeTodayResponse = await http.get(
        activeTodayUrl,
        headers: {
          'apikey': _supabaseKey,
          'Authorization': 'Bearer ${session.accessToken}',
        },
      );
      final activeToday = activeTodayResponse.statusCode == 200
          ? json.decode(activeTodayResponse.body).length
          : 0;

      // Active this week
      final weekAgo = today.subtract(const Duration(days: 7)).toIso8601String();
      final activeWeekUrl = Uri.parse('$_supabaseUrl/rest/v1/users?last_active=gte.$weekAgo&id=select:*');
      final activeWeekResponse = await http.get(
        activeWeekUrl,
        headers: {
          'apikey': _supabaseKey,
          'Authorization': 'Bearer ${session.accessToken}',
        },
      );
      final activeThisWeek = activeWeekResponse.statusCode == 200
          ? json.decode(activeWeekResponse.body).length
          : 0;

      // New users this month
      final monthAgo = today.subtract(const Duration(days: 30)).toIso8601String();
      final newUsersUrl = Uri.parse('$_supabaseUrl/rest/v1/users?created_at=gte.$monthAgo&id=select:*');
      final newUsersResponse = await http.get(
        newUsersUrl,
        headers: {
          'apikey': _supabaseKey,
          'Authorization': 'Bearer ${session.accessToken}',
        },
      );
      final newUsers = newUsersResponse.statusCode == 200
          ? json.decode(newUsersResponse.body).length
          : 0;

      // Get top countries
      final countriesUrl = Uri.parse('$_supabaseUrl/rest/v1/users?select=country_id&limit=1000');
      final countriesResponse = await http.get(
        countriesUrl,
        headers: {
          'apikey': _supabaseKey,
          'Authorization': 'Bearer ${session.accessToken}',
        },
      );

      final Map<String, int> countryCount = {};
      if (countriesResponse.statusCode == 200) {
        final countriesData = json.decode(countriesResponse.body);
        for (final item in countriesData) {
          final country = item['country_id'] as String?;
          if (country != null && country.isNotEmpty) {
            countryCount[country] = (countryCount[country] ?? 0) + 1;
          }
        }
      }

      final sortedEntries = countryCount.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      final Map<String, int> topCountries = {};
      for (var i = 0; i < sortedEntries.length && i < 10; i++) {
        topCountries[sortedEntries[i].key] = sortedEntries[i].value;
      }

      return LeaderboardStats(
        totalPlayers: totalPlayers,
        activeToday: activeToday,
        activeThisWeek: activeThisWeek,
        newPlayers: newUsers,
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

  // ==================== HELPER METHODS - HTTP VERSION ====================

  /// Update user stats using HTTP
  Future<void> updateUserStats(String userId, Map<String, dynamic> stats) async {
    await _httpUpdate('users', stats, userId);
  }

  /// Record game win using HTTP
  Future<void> recordGameWin(String userId) async {
    try {
      // Get current games won
      final url = Uri.parse('$_supabaseUrl/rest/v1/users?id=eq.$userId&select=games_won');
      final session = _supabase.auth.currentSession;
      if (session == null) return;

      final response = await http.get(
        url,
        headers: {
          'apikey': _supabaseKey,
          'Authorization': 'Bearer ${session.accessToken}',
        },
      );

      int currentWins = 0;
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data.isNotEmpty) {
          currentWins = data[0]['games_won'] ?? 0;
        }
      }

      await _httpUpdate('users', {
        'games_won': currentWins + 1,
        'updated_at': DateTime.now().toIso8601String(),
      }, userId);
    } catch (e) {
      debugPrint('Error recording game win: $e');
    }
  }

  /// Record gift sent using HTTP
  Future<void> recordGiftSent(String userId, int amount) async {
    try {
      // Get current gifts sent
      final url = Uri.parse('$_supabaseUrl/rest/v1/users?id=eq.$userId&select=total_gifts_sent,total_coins_spent');
      final session = _supabase.auth.currentSession;
      if (session == null) return;

      final response = await http.get(
        url,
        headers: {
          'apikey': _supabaseKey,
          'Authorization': 'Bearer ${session.accessToken}',
        },
      );

      int currentGifts = 0;
      int currentCoins = 0;
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data.isNotEmpty) {
          currentGifts = data[0]['total_gifts_sent'] ?? 0;
          currentCoins = data[0]['total_coins_spent'] ?? 0;
        }
      }

      await _httpUpdate('users', {
        'total_gifts_sent': currentGifts + 1,
        'total_coins_spent': currentCoins + amount,
        'updated_at': DateTime.now().toIso8601String(),
      }, userId);
    } catch (e) {
      debugPrint('Error recording gift sent: $e');
    }
  }

  /// Record follower using HTTP
  Future<void> recordFollower(String userId) async {
    try {
      // Get current followers
      final url = Uri.parse('$_supabaseUrl/rest/v1/users?id=eq.$userId&select=follower_count');
      final session = _supabase.auth.currentSession;
      if (session == null) return;

      final response = await http.get(
        url,
        headers: {
          'apikey': _supabaseKey,
          'Authorization': 'Bearer ${session.accessToken}',
        },
      );

      int currentFollowers = 0;
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data.isNotEmpty) {
          currentFollowers = data[0]['follower_count'] ?? 0;
        }
      }

      await _httpUpdate('users', {
        'follower_count': currentFollowers + 1,
        'updated_at': DateTime.now().toIso8601String(),
      }, userId);
    } catch (e) {
      debugPrint('Error recording follower: $e');
    }
  }

  /// Record streaming hours using HTTP
  Future<void> recordStreamingHours(String userId, int hours) async {
    try {
      // Get current streaming hours
      final url = Uri.parse('$_supabaseUrl/rest/v1/users?id=eq.$userId&select=streaming_hours');
      final session = _supabase.auth.currentSession;
      if (session == null) return;

      final response = await http.get(
        url,
        headers: {
          'apikey': _supabaseKey,
          'Authorization': 'Bearer ${session.accessToken}',
        },
      );

      int currentHours = 0;
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data.isNotEmpty) {
          currentHours = data[0]['streaming_hours'] ?? 0;
        }
      }

      await _httpUpdate('users', {
        'streaming_hours': currentHours + hours,
        'updated_at': DateTime.now().toIso8601String(),
      }, userId);
    } catch (e) {
      debugPrint('Error recording streaming hours: $e');
    }
  }
}