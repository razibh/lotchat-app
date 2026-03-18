import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart'; // 🟢 debugPrint এর জন্য

import '../models/user_models.dart' as app;
import '../models/room_model.dart';
import '../models/gift_model.dart';
// import '../models/post_model.dart'; // 🟢 যদি না থাকে তাহলে কমেন্ট

class SearchService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Search all
  Future<Map<String, dynamic>> searchAll(String query, {int limit = 10}) async {
    if (query.isEmpty) {
      return {
        'users': [],
        'rooms': [],
        'gifts': [],
        'posts': [],
      };
    }

    final List<List<Map<String, dynamic>>> futures = await Future.wait([
      searchUsers(query, limit: limit),
      searchRooms(query, limit: limit),
      searchGifts(query, limit: limit),
      Future.value([]), // Empty list for posts
    ]);

    return {
      'users': futures[0],
      'rooms': futures[1],
      'gifts': futures[2],
      'posts': [], // futures[3],
    };
  }

  // Search users
  Future<List<Map<String, dynamic>>> searchUsers(String query, {int limit = 20}) async {
    try {
      final User? currentUser = _auth.currentUser;

      // Search by username
      final QuerySnapshot<Map<String, dynamic>> usernameQuery = await _firestore
          .collection('users')
          .where('username', isGreaterThanOrEqualTo: query)
          .where('username', isLessThanOrEqualTo: '$query\uf8ff')
          .limit(limit)
          .get();

      // Search by display name
      final QuerySnapshot<Map<String, dynamic>> displayNameQuery = await _firestore
          .collection('users')
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThanOrEqualTo: '$query\uf8ff')
          .limit(limit)
          .get();

      // Search by ID
      final DocumentSnapshot<Map<String, dynamic>> idQuery = await _firestore
          .collection('users')
          .doc(query)
          .get();

      final List<Map<String, dynamic>> results = [];
      final Set<String> seenIds = {};

      // Add username results
      for (final QueryDocumentSnapshot<Map<String, dynamic>> doc in usernameQuery.docs) {
        if (!seenIds.contains(doc.id)) {
          seenIds.add(doc.id);
          results.add({
            'type': 'user',
            'id': doc.id,
            'data': doc.data(),
            'relevance': 1.0,
          });
        }
      }

      // Add display name results
      for (final QueryDocumentSnapshot<Map<String, dynamic>> doc in displayNameQuery.docs) {
        if (!seenIds.contains(doc.id)) {
          seenIds.add(doc.id);
          results.add({
            'type': 'user',
            'id': doc.id,
            'data': doc.data(),
            'relevance': 0.8,
          });
        }
      }

      // Add ID result
      if (idQuery.exists && !seenIds.contains(query)) {
        results.add({
          'type': 'user',
          'id': query,
          'data': idQuery.data(),
          'relevance': 1.5, // Exact ID match is most relevant
        });
      }

      // Sort by relevance
      results.sort((a, b) => b['relevance'].compareTo(a['relevance']));

      return results.take(limit).toList();
    } catch (e) {
      debugPrint('Error searching users: $e');
      return [];
    }
  }

  // Search rooms
  Future<List<Map<String, dynamic>>> searchRooms(String query, {int limit = 20}) async {
    try {
      // Search by name
      final QuerySnapshot<Map<String, dynamic>> nameQuery = await _firestore
          .collection('rooms')
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThanOrEqualTo: '$query\uf8ff')
          .where('status', isEqualTo: 'active')
          .limit(limit)
          .get();

      // Search by description
      final QuerySnapshot<Map<String, dynamic>> descQuery = await _firestore
          .collection('rooms')
          .where('description', isGreaterThanOrEqualTo: query)
          .where('description', isLessThanOrEqualTo: '$query\uf8ff')
          .where('status', isEqualTo: 'active')
          .limit(limit)
          .get();

      final List<Map<String, dynamic>> results = [];
      final Set<String> seenIds = {};

      for (final QueryDocumentSnapshot<Map<String, dynamic>> doc in nameQuery.docs) {
        if (!seenIds.contains(doc.id)) {
          seenIds.add(doc.id);
          results.add({
            'type': 'room',
            'id': doc.id,
            'data': doc.data(),
            'relevance': 1.0,
          });
        }
      }

      for (final QueryDocumentSnapshot<Map<String, dynamic>> doc in descQuery.docs) {
        if (!seenIds.contains(doc.id)) {
          seenIds.add(doc.id);
          results.add({
            'type': 'room',
            'id': doc.id,
            'data': doc.data(),
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

  // Search gifts
  Future<List<Map<String, dynamic>>> searchGifts(String query, {int limit = 20}) async {
    try {
      // Search by name
      final QuerySnapshot<Map<String, dynamic>> nameQuery = await _firestore
          .collection('gifts')
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThanOrEqualTo: '$query\uf8ff')
          .where('isAvailable', isEqualTo: true)
          .limit(limit)
          .get();

      // Search by category
      final QuerySnapshot<Map<String, dynamic>> categoryQuery = await _firestore
          .collection('gifts')
          .where('category', isGreaterThanOrEqualTo: query)
          .where('category', isLessThanOrEqualTo: '$query\uf8ff')
          .where('isAvailable', isEqualTo: true)
          .limit(limit)
          .get();

      final List<Map<String, dynamic>> results = [];
      final Set<String> seenIds = {};

      for (final QueryDocumentSnapshot<Map<String, dynamic>> doc in nameQuery.docs) {
        if (!seenIds.contains(doc.id)) {
          seenIds.add(doc.id);
          results.add({
            'type': 'gift',
            'id': doc.id,
            'data': doc.data(),
            'relevance': 1.0,
          });
        }
      }

      for (final QueryDocumentSnapshot<Map<String, dynamic>> doc in categoryQuery.docs) {
        if (!seenIds.contains(doc.id)) {
          seenIds.add(doc.id);
          results.add({
            'type': 'gift',
            'id': doc.id,
            'data': doc.data(),
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

  // Search posts (commented out if post_model doesn't exist)
  /*
  Future<List<Map<String, dynamic>>> searchPosts(String query, {int limit = 20}) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> contentQuery = await _firestore
          .collection('posts')
          .where('content', isGreaterThanOrEqualTo: query)
          .where('content', isLessThanOrEqualTo: '$query\uf8ff')
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();

      final List<Map<String, dynamic>> results = [];

      for (final QueryDocumentSnapshot<Map<String, dynamic>> doc in contentQuery.docs) {
        results.add({
          'type': 'post',
          'id': doc.id,
          'data': doc.data(),
          'relevance': 1.0,
        });
      }

      return results;
    } catch (e) {
      debugPrint('Error searching posts: $e');
      return [];
    }
  }
  */

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
    Query<Map<String, dynamic>> q = _firestore.collection('users');

    if (query.isNotEmpty) {
      q = q.where('username', isGreaterThanOrEqualTo: query)
          .where('username', isLessThanOrEqualTo: '$query\uf8ff');
    }

    if (country != null) {
      q = q.where('countryId', isEqualTo: country);
    }

    if (fromDate != null) {
      q = q.where('createdAt', isGreaterThanOrEqualTo: fromDate);
    }

    if (toDate != null) {
      q = q.where('createdAt', isLessThanOrEqualTo: toDate);
    }

    final QuerySnapshot<Map<String, dynamic>> snapshot = await q.limit(limit).get();

    return snapshot.docs.map((doc) => {
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
    Query<Map<String, dynamic>> q = _firestore.collection('rooms').where('status', isEqualTo: 'active');

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

    final QuerySnapshot<Map<String, dynamic>> snapshot = await q.limit(limit).get();

    return snapshot.docs.map((doc) => {
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
    Query<Map<String, dynamic>> q = _firestore.collection('gifts').where('isAvailable', isEqualTo: true);

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

    final QuerySnapshot<Map<String, dynamic>> snapshot = await q.limit(limit).get();

    return snapshot.docs.map((doc) => {
      'type': 'gift',
      'id': doc.id,
      'data': doc.data(),
      'relevance': 1.0,
    }).toList();
  }

  // Get search suggestions
  Future<List<String>> getSuggestions(String query) async {
    if (query.length < 2) return [];

    try {
      final Set<String> suggestions = {};

      // User suggestions
      final QuerySnapshot<Map<String, dynamic>> userSnapshot = await _firestore
          .collection('users')
          .where('username', isGreaterThanOrEqualTo: query)
          .where('username', isLessThanOrEqualTo: '$query\uf8ff')
          .limit(5)
          .get();

      for (final QueryDocumentSnapshot<Map<String, dynamic>> doc in userSnapshot.docs) {
        suggestions.add(doc.data()['username'] as String? ?? '');
      }

      // Room suggestions
      final QuerySnapshot<Map<String, dynamic>> roomSnapshot = await _firestore
          .collection('rooms')
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThanOrEqualTo: '$query\uf8ff')
          .where('status', isEqualTo: 'active')
          .limit(5)
          .get();

      for (final QueryDocumentSnapshot<Map<String, dynamic>> doc in roomSnapshot.docs) {
        suggestions.add(doc.data()['name'] as String? ?? '');
      }

      // Gift suggestions
      final QuerySnapshot<Map<String, dynamic>> giftSnapshot = await _firestore
          .collection('gifts')
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThanOrEqualTo: '$query\uf8ff')
          .where('isAvailable', isEqualTo: true)
          .limit(5)
          .get();

      for (final QueryDocumentSnapshot<Map<String, dynamic>> doc in giftSnapshot.docs) {
        suggestions.add(doc.data()['name'] as String? ?? '');
      }

      return suggestions.where((s) => s.isNotEmpty).take(10).toList();
    } catch (e) {
      debugPrint('Error getting suggestions: $e');
      return [];
    }
  }

  // Clear search cache
  Future<void> clearCache() async {
    // Implementation depends on caching strategy
    debugPrint('Search cache cleared');
  }
}