import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../models/room_model.dart';
import '../models/gift_model.dart';
import '../models/post_model.dart';

class SearchService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Search all
  Future<Map<String, dynamic>> searchAll(String query, {int limit = 10}) async {
    if (query.isEmpty) {
      return <String, dynamic>{
        'users': <dynamic>[],
        'rooms': <dynamic>[],
        'gifts': <dynamic>[],
        'posts': <dynamic>[],
      };
    }

    final List<List<Map<String, dynamic>>> futures = await Future.wait(<Future<List<Map<String, dynamic>>>>[
      searchUsers(query, limit: limit),
      searchRooms(query, limit: limit),
      searchGifts(query, limit: limit),
      searchPosts(query, limit: limit),
    ]);

    return <String, dynamic>{
      'users': futures[0],
      'rooms': futures[1],
      'gifts': futures[2],
      'posts': futures[3],
    };
  }

  // Search users
  Future<List<Map<String, dynamic>>> searchUsers(String query, {int limit = 20}) async {
    try {
      final currentUser = _auth.currentUser;
      
      // Search by username
      final usernameQuery = await _firestore
          .collection('users')
          .where('username', isGreaterThanOrEqualTo: query)
          .where('username', isLessThanOrEqualTo: '$query\uf8ff')
          .limit(limit)
          .get();

      // Search by display name
      final displayNameQuery = await _firestore
          .collection('users')
          .where('displayName', isGreaterThanOrEqualTo: query)
          .where('displayName', isLessThanOrEqualTo: '$query\uf8ff')
          .limit(limit)
          .get();

      // Search by ID
      final idQuery = await _firestore
          .collection('users')
          .doc(query)
          .get();

      final List<Map<String, dynamic>> results = <Map<String, dynamic>>[];
      final Set<String> seenIds = <String>{};

      // Add username results
      for (final doc in usernameQuery.docs) {
        if (!seenIds.contains(doc.id)) {
          seenIds.add(doc.id);
          results.add(<String, dynamic>{
            'type': 'user',
            'id': doc.id,
            'data': doc.data(),
            'relevance': 1.0,
          });
        }
      }

      // Add display name results
      for (final doc in displayNameQuery.docs) {
        if (!seenIds.contains(doc.id)) {
          seenIds.add(doc.id);
          results.add(<String, dynamic>{
            'type': 'user',
            'id': doc.id,
            'data': doc.data(),
            'relevance': 0.8,
          });
        }
      }

      // Add ID result
      if (idQuery.exists && !seenIds.contains(query)) {
        results.add(<String, dynamic>{
          'type': 'user',
          'id': query,
          'data': idQuery.data(),
          'relevance': 1.5, // Exact ID match is most relevant
        });
      }

      // Sort by relevance
      results.sort((Map<String, dynamic> a, Map<String, dynamic> b) => b['relevance'].compareTo(a['relevance']));
      
      return results.take(limit).toList();
    } catch (e) {
      print('Error searching users: $e');
      return <Map<String, dynamic>>[];
    }
  }

  // Search rooms
  Future<List<Map<String, dynamic>>> searchRooms(String query, {int limit = 20}) async {
    try {
      // Search by name
      final nameQuery = await _firestore
          .collection('rooms')
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThanOrEqualTo: '$query\uf8ff')
          .where('isActive', isEqualTo: true)
          .limit(limit)
          .get();

      // Search by description
      final descQuery = await _firestore
          .collection('rooms')
          .where('description', isGreaterThanOrEqualTo: query)
          .where('description', isLessThanOrEqualTo: '$query\uf8ff')
          .where('isActive', isEqualTo: true)
          .limit(limit)
          .get();

      final List<Map<String, dynamic>> results = <Map<String, dynamic>>[];
      final Set<String> seenIds = <String>{};

      for (final doc in nameQuery.docs) {
        if (!seenIds.contains(doc.id)) {
          seenIds.add(doc.id);
          results.add(<String, dynamic>{
            'type': 'room',
            'id': doc.id,
            'data': doc.data(),
            'relevance': 1.0,
          });
        }
      }

      for (final doc in descQuery.docs) {
        if (!seenIds.contains(doc.id)) {
          seenIds.add(doc.id);
          results.add(<String, dynamic>{
            'type': 'room',
            'id': doc.id,
            'data': doc.data(),
            'relevance': 0.7,
          });
        }
      }

      return results.take(limit).toList();
    } catch (e) {
      print('Error searching rooms: $e');
      return <Map<String, dynamic>>[];
    }
  }

  // Search gifts
  Future<List<Map<String, dynamic>>> searchGifts(String query, {int limit = 20}) async {
    try {
      // Search by name
      final nameQuery = await _firestore
          .collection('gifts')
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThanOrEqualTo: '$query\uf8ff')
          .where('isAvailable', isEqualTo: true)
          .limit(limit)
          .get();

      // Search by category
      final categoryQuery = await _firestore
          .collection('gifts')
          .where('category', isGreaterThanOrEqualTo: query)
          .where('category', isLessThanOrEqualTo: '$query\uf8ff')
          .where('isAvailable', isEqualTo: true)
          .limit(limit)
          .get();

      final List<Map<String, dynamic>> results = <Map<String, dynamic>>[];
      final Set<String> seenIds = <String>{};

      for (final doc in nameQuery.docs) {
        if (!seenIds.contains(doc.id)) {
          seenIds.add(doc.id);
          results.add(<String, dynamic>{
            'type': 'gift',
            'id': doc.id,
            'data': doc.data(),
            'relevance': 1.0,
          });
        }
      }

      for (final doc in categoryQuery.docs) {
        if (!seenIds.contains(doc.id)) {
          seenIds.add(doc.id);
          results.add(<String, dynamic>{
            'type': 'gift',
            'id': doc.id,
            'data': doc.data(),
            'relevance': 0.6,
          });
        }
      }

      return results;
    } catch (e) {
      print('Error searching gifts: $e');
      return <Map<String, dynamic>>[];
    }
  }

  // Search posts
  Future<List<Map<String, dynamic>>> searchPosts(String query, {int limit = 20}) async {
    try {
      // Search by content
      final contentQuery = await _firestore
          .collection('posts')
          .where('content', isGreaterThanOrEqualTo: query)
          .where('content', isLessThanOrEqualTo: '$query\uf8ff')
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();

      final List<Map<String, dynamic>> results = <Map<String, dynamic>>[];

      for (final doc in contentQuery.docs) {
        results.add(<String, dynamic>{
          'type': 'post',
          'id': doc.id,
          'data': doc.data(),
          'relevance': 1.0,
        });
      }

      return results;
    } catch (e) {
      print('Error searching posts: $e');
      return <Map<String, dynamic>>[];
    }
  }

  // Advanced search with filters
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
      final var results = <Map<String, dynamic>><Map<String, dynamic>>[];

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

      if (type == null || type == 'posts') {
        results.addAll(await _advancedSearchPosts(
          query: query,
          fromDate: fromDate,
          toDate: toDate,
          limit: limit,
        ));
      }

      // Sort by relevance
      results.sort((Map<String, dynamic> a, Map<String, dynamic> b) => b['relevance'].compareTo(a['relevance']));
      
      return results.take(limit).toList();
    } catch (e) {
      print('Error in advanced search: $e');
      return <Map<String, dynamic>>[];
    }
  }

  Future<List<Map<String, dynamic>>> _advancedSearchUsers({
    required String query,
    String? country,
    DateTime? fromDate,
    DateTime? toDate,
    int limit = 50,
  }) async {
    var q = _firestore.collection('users');

    if (query.isNotEmpty) {
      q = q.where('username', isGreaterThanOrEqualTo: query)
            .where('username', isLessThanOrEqualTo: '$query\uf8ff');
    }

    if (country != null) {
      q = q.where('country', isEqualTo: country);
    }

    if (fromDate != null) {
      q = q.where('createdAt', isGreaterThanOrEqualTo: fromDate);
    }

    if (toDate != null) {
      q = q.where('createdAt', isLessThanOrEqualTo: toDate);
    }

    final snapshot = await q.limit(limit).get();
    
    return snapshot.docs.map((doc) => <String, dynamic>{
      'type': 'user',
      'id': doc.id,
      'data': doc.data(),
      'relevance': 1.0,
    }).toList();
  }

  Future<List<Map<String, dynamic>>> _advancedSearchRooms({
    required String query,
    String? category,
    String? country,
    DateTime? fromDate,
    DateTime? toDate,
    int limit = 50,
  }) async {
    var q = _firestore.collection('rooms').where('isActive', isEqualTo: true);

    if (query.isNotEmpty) {
      q = q.where('name', isGreaterThanOrEqualTo: query)
            .where('name', isLessThanOrEqualTo: '$query\uf8ff');
    }

    if (category != null && category != 'All') {
      q = q.where('category', isEqualTo: category);
    }

    if (country != null) {
      q = q.where('country', isEqualTo: country);
    }

    if (fromDate != null) {
      q = q.where('createdAt', isGreaterThanOrEqualTo: fromDate);
    }

    if (toDate != null) {
      q = q.where('createdAt', isLessThanOrEqualTo: toDate);
    }

    final snapshot = await q.limit(limit).get();
    
    return snapshot.docs.map((doc) => <String, dynamic>{
      'type': 'room',
      'id': doc.id,
      'data': doc.data(),
      'relevance': 1.0,
    }).toList();
  }

  Future<List<Map<String, dynamic>>> _advancedSearchGifts({
    required String query,
    String? category,
    int? minPrice,
    int? maxPrice,
    int limit = 50,
  }) async {
    var q = _firestore.collection('gifts').where('isAvailable', isEqualTo: true);

    if (query.isNotEmpty) {
      q = q.where('name', isGreaterThanOrEqualTo: query)
            .where('name', isLessThanOrEqualTo: '$query\uf8ff');
    }

    if (category != null && category != 'All') {
      q = q.where('category', isEqualTo: category);
    }

    if (minPrice != null) {
      q = q.where('price', isGreaterThanOrEqualTo: minPrice);
    }

    if (maxPrice != null) {
      q = q.where('price', isLessThanOrEqualTo: maxPrice);
    }

    final snapshot = await q.limit(limit).get();
    
    return snapshot.docs.map((doc) => <String, dynamic>{
      'type': 'gift',
      'id': doc.id,
      'data': doc.data(),
      'relevance': 1.0,
    }).toList();
  }

  Future<List<Map<String, dynamic>>> _advancedSearchPosts({
    required String query,
    DateTime? fromDate,
    DateTime? toDate,
    int limit = 50,
  }) async {
    var q = _firestore.collection('posts');

    if (query.isNotEmpty) {
      q = q.where('content', isGreaterThanOrEqualTo: query)
            .where('content', isLessThanOrEqualTo: '$query\uf8ff');
    }

    if (fromDate != null) {
      q = q.where('timestamp', isGreaterThanOrEqualTo: fromDate);
    }

    if (toDate != null) {
      q = q.where('timestamp', isLessThanOrEqualTo: toDate);
    }

    q = q.orderBy('timestamp', descending: true);

    final snapshot = await q.limit(limit).get();
    
    return snapshot.docs.map((doc) => <String, dynamic>{
      'type': 'post',
      'id': doc.id,
      'data': doc.data(),
      'relevance': 1.0,
    }).toList();
  }

  // Get search suggestions
  Future<List<String>> getSuggestions(String query) async {
    if (query.length < 2) return <String>[];

    try {
      final Set<String> suggestions = <String>{};

      // User suggestions
      final userSnapshot = await _firestore
          .collection('users')
          .where('username', isGreaterThanOrEqualTo: query)
          .where('username', isLessThanOrEqualTo: '$query\uf8ff')
          .limit(5)
          .get();

      for (final doc in userSnapshot.docs) {
        suggestions.add(doc.data()['username']);
      }

      // Room suggestions
      final roomSnapshot = await _firestore
          .collection('rooms')
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThanOrEqualTo: '$query\uf8ff')
          .where('isActive', isEqualTo: true)
          .limit(5)
          .get();

      for (final doc in roomSnapshot.docs) {
        suggestions.add(doc.data()['name']);
      }

      // Gift suggestions
      final giftSnapshot = await _firestore
          .collection('gifts')
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThanOrEqualTo: '$query\uf8ff')
          .where('isAvailable', isEqualTo: true)
          .limit(5)
          .get();

      for (final doc in giftSnapshot.docs) {
        suggestions.add(doc.data()['name']);
      }

      return suggestions.take(10).toList();
    } catch (e) {
      print('Error getting suggestions: $e');
      return <String>[];
    }
  }

  // Clear search cache
  Future<void> clearCache() async {
    // Implementation depends on caching strategy
  }
}