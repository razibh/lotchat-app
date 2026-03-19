import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_models.dart' as app;
import '../models/room_model.dart';
import '../models/gift_model.dart';
import '../di/service_locator.dart';

class SearchService {
  late final SupabaseClient _supabase;

  SearchService() {
    _supabase = getService<SupabaseClient>();
  }

  // Helper to get current user
  String? get _currentUserId => _supabase.auth.currentSession?.user.id;

  // Helper methods
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

  // ==================== SEARCH ALL ====================

  /// Search all
  Future<Map<String, dynamic>> searchAll(String query, {int limit = 10}) async {
    if (query.isEmpty) {
      return {
        'users': [],
        'rooms': [],
        'gifts': [],
        'posts': [],
      };
    }

    final futures = await Future.wait([
      searchUsers(query, limit: limit),
      searchRooms(query, limit: limit),
      searchGifts(query, limit: limit),
      Future.value([]), // Empty list for posts
    ]);

    return {
      'users': futures[0],
      'rooms': futures[1],
      'gifts': futures[2],
      'posts': [],
    };
  }

  // ==================== SEARCH USERS ====================

  /// Search users
  Future<List<Map<String, dynamic>>> searchUsers(String query, {int limit = 20}) async {
    try {
      // Search by username
      final usernameResponse = await _supabase
          .from('users')
          .select()
          .ilike('username', '%$query%')
          .limit(limit);

      // Search by display name (full_name)
      final displayNameResponse = await _supabase
          .from('users')
          .select()
          .ilike('full_name', '%$query%')
          .limit(limit);

      // Search by ID
      Map<String, dynamic>? idResponse;
      try {
        idResponse = await _supabase
            .from('users')
            .select()
            .eq('id', query)
            .maybeSingle();
      } catch (e) {
        // Ignore error
      }

      final List<Map<String, dynamic>> results = [];
      final Set<String> seenIds = {};

      // Add username results
      for (var user in usernameResponse) {
        final id = user['id']?.toString() ?? '';
        if (!seenIds.contains(id)) {
          seenIds.add(id);
          results.add({
            'type': 'user',
            'id': id,
            'data': user,
            'relevance': 1.0,
          });
        }
      }

      // Add display name results
      for (var user in displayNameResponse) {
        final id = user['id']?.toString() ?? '';
        if (!seenIds.contains(id)) {
          seenIds.add(id);
          results.add({
            'type': 'user',
            'id': id,
            'data': user,
            'relevance': 0.8,
          });
        }
      }

      // Add ID result
      if (idResponse != null) {
        final id = idResponse['id']?.toString() ?? '';
        if (!seenIds.contains(id)) {
          results.add({
            'type': 'user',
            'id': id,
            'data': idResponse,
            'relevance': 1.5, // Exact ID match is most relevant
          });
        }
      }

      // Sort by relevance
      results.sort((a, b) => b['relevance'].compareTo(a['relevance']));

      return results.take(limit).toList();
    } catch (e) {
      debugPrint('Error searching users: $e');
      return [];
    }
  }

  // ==================== SEARCH ROOMS ====================

  /// Search rooms
  Future<List<Map<String, dynamic>>> searchRooms(String query, {int limit = 20}) async {
    try {
      // Search by name
      final nameResponse = await _supabase
          .from('rooms')
          .select()
          .ilike('name', '%$query%')
          .eq('status', 'active')
          .limit(limit);

      // Search by description
      final descResponse = await _supabase
          .from('rooms')
          .select()
          .ilike('description', '%$query%')
          .eq('status', 'active')
          .limit(limit);

      final List<Map<String, dynamic>> results = [];
      final Set<String> seenIds = {};

      for (var room in nameResponse) {
        final id = room['id']?.toString() ?? '';
        if (!seenIds.contains(id)) {
          seenIds.add(id);
          results.add({
            'type': 'room',
            'id': id,
            'data': room,
            'relevance': 1.0,
          });
        }
      }

      for (var room in descResponse) {
        final id = room['id']?.toString() ?? '';
        if (!seenIds.contains(id)) {
          seenIds.add(id);
          results.add({
            'type': 'room',
            'id': id,
            'data': room,
            'relevance': 0.7,
          });
        }
      }

      return results.take(limit).toList();
    } catch (e) {
      debugPrint('Error searching rooms: $e');
      return [];
    }
  }

  // ==================== SEARCH GIFTS ====================

  /// Search gifts
  Future<List<Map<String, dynamic>>> searchGifts(String query, {int limit = 20}) async {
    try {
      // Search by name
      final nameResponse = await _supabase
          .from('gifts')
          .select()
          .ilike('name', '%$query%')
          .eq('is_available', true)
          .limit(limit);

      // Search by category
      final categoryResponse = await _supabase
          .from('gifts')
          .select()
          .ilike('category', '%$query%')
          .eq('is_available', true)
          .limit(limit);

      final List<Map<String, dynamic>> results = [];
      final Set<String> seenIds = {};

      for (var gift in nameResponse) {
        final id = gift['id']?.toString() ?? '';
        if (!seenIds.contains(id)) {
          seenIds.add(id);
          results.add({
            'type': 'gift',
            'id': id,
            'data': gift,
            'relevance': 1.0,
          });
        }
      }

      for (var gift in categoryResponse) {
        final id = gift['id']?.toString() ?? '';
        if (!seenIds.contains(id)) {
          seenIds.add(id);
          results.add({
            'type': 'gift',
            'id': id,
            'data': gift,
            'relevance': 0.6,
          });
        }
      }

      return results;
    } catch (e) {
      debugPrint('Error searching gifts: $e');
      return [];
    }
  }

  // ==================== ADVANCED SEARCH ====================

  /// Advanced search with filters
  Future<List<Map<String, dynamic>>> advancedSearch({
    required String query,
    String? type,
    String? category,
    String? country,
    int? minPrice,
    int? maxPrice,
    DateTime? fromDate,
    DateTime? toDate,
    int limit = 50,
  }) async {
    try {
      final List<Map<String, dynamic>> results = [];

      if (type == null || type == 'users') {
        results.addAll(await _advancedSearchUsers(
          query: query,
          country: country,
          fromDate: fromDate,
          toDate: toDate,
          limit: limit,
        ));
      }

      if (type == null || type == 'rooms') {
        results.addAll(await _advancedSearchRooms(
          query: query,
          category: category,
          country: country,
          fromDate: fromDate,
          toDate: toDate,
          limit: limit,
        ));
      }

      if (type == null || type == 'gifts') {
        results.addAll(await _advancedSearchGifts(
          query: query,
          category: category,
          minPrice: minPrice,
          maxPrice: maxPrice,
          limit: limit,
        ));
      }

      // Sort by relevance
      results.sort((a, b) => b['relevance'].compareTo(a['relevance']));

      return results.take(limit).toList();
    } catch (e) {
      debugPrint('Error in advanced search: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> _advancedSearchUsers({
    required String query,
    String? country,
    DateTime? fromDate,
    DateTime? toDate,
    int limit = 50,
  }) async {
    try {
      var dbQuery = _supabase
          .from('users')
          .select();

      if (query.isNotEmpty) {
        dbQuery = dbQuery.ilike('username', '%$query%');
      }

      if (country != null) {
        dbQuery = dbQuery.eq('country_id', country);
      }

      if (fromDate != null) {
        dbQuery = dbQuery.gte('created_at', fromDate.toIso8601String());
      }

      if (toDate != null) {
        dbQuery = dbQuery.lte('created_at', toDate.toIso8601String());
      }

      final response = await dbQuery.limit(limit);

      return response.map((user) {
        return {
          'type': 'user',
          'id': user['id']?.toString() ?? '',
          'data': user,
          'relevance': 1.0,
        };
      }).toList();
    } catch (e) {
      debugPrint('Error in advanced search users: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> _advancedSearchRooms({
    required String query,
    String? category,
    String? country,
    DateTime? fromDate,
    DateTime? toDate,
    int limit = 50,
  }) async {
    try {
      var dbQuery = _supabase
          .from('rooms')
          .select()
          .eq('status', 'active');

      if (query.isNotEmpty) {
        dbQuery = dbQuery.ilike('name', '%$query%');
      }

      if (category != null && category != 'All') {
        dbQuery = dbQuery.eq('category', category);
      }

      if (country != null) {
        dbQuery = dbQuery.eq('country', country);
      }

      if (fromDate != null) {
        dbQuery = dbQuery.gte('created_at', fromDate.toIso8601String());
      }

      if (toDate != null) {
        dbQuery = dbQuery.lte('created_at', toDate.toIso8601String());
      }

      final response = await dbQuery.limit(limit);

      return response.map((room) {
        return {
          'type': 'room',
          'id': room['id']?.toString() ?? '',
          'data': room,
          'relevance': 1.0,
        };
      }).toList();
    } catch (e) {
      debugPrint('Error in advanced search rooms: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> _advancedSearchGifts({
    required String query,
    String? category,
    int? minPrice,
    int? maxPrice,
    int limit = 50,
  }) async {
    try {
      var dbQuery = _supabase
          .from('gifts')
          .select()
          .eq('is_available', true);

      if (query.isNotEmpty) {
        dbQuery = dbQuery.ilike('name', '%$query%');
      }

      if (category != null && category != 'All') {
        dbQuery = dbQuery.eq('category', category);
      }

      if (minPrice != null) {
        dbQuery = dbQuery.gte('price', minPrice);
      }

      if (maxPrice != null) {
        dbQuery = dbQuery.lte('price', maxPrice);
      }

      final response = await dbQuery.limit(limit);

      return response.map((gift) {
        return {
          'type': 'gift',
          'id': gift['id']?.toString() ?? '',
          'data': gift,
          'relevance': 1.0,
        };
      }).toList();
    } catch (e) {
      debugPrint('Error in advanced search gifts: $e');
      return [];
    }
  }

  // ==================== GET SUGGESTIONS ====================

  /// Get search suggestions
  Future<List<String>> getSuggestions(String query) async {
    if (query.length < 2) return [];

    try {
      final Set<String> suggestions = {};

      // User suggestions
      final userResponse = await _supabase
          .from('users')
          .select('username')
          .ilike('username', '%$query%')
          .limit(5);

      for (var user in userResponse) {
        final username = user['username'] as String?;
        if (username != null && username.isNotEmpty) {
          suggestions.add(username);
        }
      }

      // Room suggestions
      final roomResponse = await _supabase
          .from('rooms')
          .select('name')
          .ilike('name', '%$query%')
          .eq('status', 'active')
          .limit(5);

      for (var room in roomResponse) {
        final name = room['name'] as String?;
        if (name != null && name.isNotEmpty) {
          suggestions.add(name);
        }
      }

      // Gift suggestions
      final giftResponse = await _supabase
          .from('gifts')
          .select('name')
          .ilike('name', '%$query%')
          .eq('is_available', true)
          .limit(5);

      for (var gift in giftResponse) {
        final name = gift['name'] as String?;
        if (name != null && name.isNotEmpty) {
          suggestions.add(name);
        }
      }

      return suggestions.where((s) => s.isNotEmpty).take(10).toList();
    } catch (e) {
      debugPrint('Error getting suggestions: $e');
      return [];
    }
  }

  // ==================== CLEAR CACHE ====================

  /// Clear search cache
  Future<void> clearCache() async {
    // Implementation depends on caching strategy
    debugPrint('Search cache cleared');
  }

  // ==================== RECENT SEARCHES ====================

  /// Save recent search
  Future<void> saveRecentSearch(String query) async {
    final userId = _currentUserId;
    if (userId == null) return;

    try {
      await _supabase.from('recent_searches').insert({
        'user_id': userId,
        'query': query,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('Error saving recent search: $e');
    }
  }

  /// Get recent searches
  Future<List<String>> getRecentSearches({int limit = 10}) async {
    final userId = _currentUserId;
    if (userId == null) return [];

    try {
      final response = await _supabase
          .from('recent_searches')
          .select('query')
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(limit);

      return response.map<String>((item) => item['query'] as String).toList();
    } catch (e) {
      debugPrint('Error getting recent searches: $e');
      return [];
    }
  }

  /// Clear recent searches
  Future<void> clearRecentSearches() async {
    final userId = _currentUserId;
    if (userId == null) return;

    try {
      await _supabase
          .from('recent_searches')
          .delete()
          .eq('user_id', userId);
    } catch (e) {
      debugPrint('Error clearing recent searches: $e');
    }
  }

  // ==================== SEARCH STATISTICS ====================

  /// Get popular searches
  Future<List<Map<String, dynamic>>> getPopularSearches({int limit = 10}) async {
    try {
      // This would require aggregating search data
      // For now, return empty list
      return [];
    } catch (e) {
      debugPrint('Error getting popular searches: $e');
      return [];
    }
  }
}