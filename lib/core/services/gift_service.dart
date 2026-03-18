import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/gift_model.dart';
import '../di/service_locator.dart';
import 'notification_service.dart';
import 'analytics_service.dart';

class GiftService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late final NotificationService _notificationService;
  late final AnalyticsService _analyticsService;

  GiftService() {
    _initializeServices();
  }

  void _initializeServices() {
    try {
      _notificationService = ServiceLocator.instance.get<NotificationService>();
      _analyticsService = ServiceLocator.instance.get<AnalyticsService>();
    } catch (e) {
      debugPrint('Error initializing services: $e');
    }
  }

  // ==================== GET GIFTS ====================

  // Get available gifts
  Future<List<GiftModel>> getAvailableGifts() async {
    try {
      final snapshot = await _firestore
          .collection('gifts')
          .where('isAvailable', isEqualTo: true)
          .orderBy('price')
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return GiftModel.fromJson(data);
      }).toList();
    } catch (e) {
      debugPrint('Error getting gifts: $e');
      return GiftModel.getMockGifts();
    }
  }

  // Get gifts by category
  Future<List<GiftModel>> getGiftsByCategory(String category) async {
    try {
      final snapshot = await _firestore
          .collection('gifts')
          .where('category', isEqualTo: category)
          .where('isAvailable', isEqualTo: true)
          .orderBy('price')
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return GiftModel.fromJson(data);
      }).toList();
    } catch (e) {
      debugPrint('Error getting gifts by category: $e');
      final allGifts = GiftModel.getMockGifts();
      return allGifts.where((g) => g.category == category).toList();
    }
  }

  // Get gift by id
  Future<GiftModel?> getGift(String giftId) async {
    try {
      final doc = await _firestore.collection('gifts').doc(giftId).get();
      if (doc.exists) {
        final data = doc.data()!;
        data['id'] = doc.id;
        return GiftModel.fromJson(data);
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

  // Get recent gifts
  Future<List<GiftModel>> getRecentGifts(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('gift_transactions')
          .where('senderId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .limit(10)
          .get();

      final List<GiftModel> recentGifts = [];

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final giftId = data['giftId'] as String?;

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

  // Send gift
  Future<bool> sendGift({
    required String senderId,
    required String receiverId,
    required String giftId,
    required int amount,
    String? roomId,
    String? message,
  }) async {
    final User? user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    try {
      final GiftModel? gift = await getGift(giftId);
      if (gift == null) throw Exception('Gift not found');

      final int totalPrice = gift.price * amount;

      return await _firestore.runTransaction((Transaction transaction) async {
        // Check sender's coins
        final DocumentReference<Map<String, dynamic>> senderRef = _firestore.collection('users').doc(senderId);
        final DocumentSnapshot<Map<String, dynamic>> senderDoc = await transaction.get(senderRef);

        if (!senderDoc.exists) throw Exception('Sender not found');

        final senderCoins = senderDoc.data()!['coins'] as int? ?? 0;
        if (senderCoins < totalPrice) {
          throw Exception('Insufficient coins');
        }

        // Deduct coins from sender
        transaction.update(senderRef, {
          'coins': senderCoins - totalPrice,
        });

        // Add diamonds to receiver (50% conversion)
        final DocumentReference<Map<String, dynamic>> receiverRef = _firestore.collection('users').doc(receiverId);
        final DocumentSnapshot<Map<String, dynamic>> receiverDoc = await transaction.get(receiverRef);

        int earnedDiamonds = 0;
        if (receiverDoc.exists) {
          final receiverDiamonds = receiverDoc.data()!['diamonds'] as int? ?? 0;
          earnedDiamonds = (totalPrice / 2).round();

          transaction.update(receiverRef, {
            'diamonds': receiverDiamonds + earnedDiamonds,
          });
        }

        // Record gift transaction
        final DocumentReference<Map<String, dynamic>> giftTransactionRef = _firestore.collection('gift_transactions').doc();
        transaction.set(giftTransactionRef, {
          'senderId': senderId,
          'senderName': user.displayName ?? 'User',
          'receiverId': receiverId,
          'giftId': giftId,
          'giftName': gift.name,
          'amount': amount,
          'totalPrice': totalPrice,
          'roomId': roomId,
          'message': message,
          'timestamp': FieldValue.serverTimestamp(),
        });

        // Update gift stats
        final DocumentReference<Map<String, dynamic>> giftRef = _firestore.collection('gifts').doc(giftId);
        transaction.update(giftRef, {
          'sentCount': FieldValue.increment(amount),
        });

        // Update sender's stats
        transaction.update(senderRef, {
          'totalGiftsSent': FieldValue.increment(amount),
          'totalCoinsSpent': FieldValue.increment(totalPrice),
        });

        // Update receiver's stats
        if (receiverDoc.exists) {
          transaction.update(receiverRef, {
            'totalGiftsReceived': FieldValue.increment(amount),
            'totalDiamondsEarned': FieldValue.increment(earnedDiamonds),
          });
        }

        // Send notification
        try {
          await _notificationService.sendNotification(
            userId: receiverId,
            type: 'gift',
            title: 'Gift Received! 🎁',
            body: '${user.displayName ?? 'Someone'} sent you ${amount == 1 ? 'a' : amount} ${gift.name}${amount > 1 ? 's' : ''}',
            data: {
              'senderId': senderId,
              'giftId': giftId,
              'amount': amount.toString(), // 🟢 Convert to String
              'roomId': roomId ?? '',
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
      });
    } catch (e) {
      debugPrint('Error sending gift: $e');
      return false;
    }
  }

  // ==================== GIFT HISTORY ====================

  // Get gift history
  Stream<List<Map<String, dynamic>>> getGiftHistory(String userId) {
    return _firestore
        .collection('gift_transactions')
        .where(Filter.or(
      Filter('senderId', isEqualTo: userId),
      Filter('receiverId', isEqualTo: userId),
    ))
        .orderBy('timestamp', descending: true)
        .limit(100)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
      final Map<String, dynamic> data = doc.data();
      data['id'] = doc.id;
      return data;
    }).toList());
  }

  // Get sent gifts
  Stream<List<Map<String, dynamic>>> getSentGifts(String userId) {
    return _firestore
        .collection('gift_transactions')
        .where('senderId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
      final Map<String, dynamic> data = doc.data();
      data['id'] = doc.id;
      return data;
    }).toList());
  }

  // Get received gifts
  Stream<List<Map<String, dynamic>>> getReceivedGifts(String userId) {
    return _firestore
        .collection('gift_transactions')
        .where('receiverId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
      final Map<String, dynamic> data = doc.data();
      data['id'] = doc.id;
      return data;
    }).toList());
  }

  // ==================== LEADERBOARDS ====================

  // Get top gifters
  Future<List<Map<String, dynamic>>> getTopGifters({int limit = 10}) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .orderBy('totalGiftsSent', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) {
        final Map<String, dynamic> data = doc.data();
        return {
          'userId': doc.id,
          'username': data['username'] ?? '',
          'avatar': data['photoURL'] ?? '',
          'totalGifts': data['totalGiftsSent']?.toString() ?? '0', // 🟢 Convert to String
          'totalCoinsSpent': data['totalCoinsSpent']?.toString() ?? '0', // 🟢 Convert to String
        };
      }).toList();
    } catch (e) {
      debugPrint('Error getting top gifters: $e');
      return [];
    }
  }

  // Get top receivers
  Future<List<Map<String, dynamic>>> getTopReceivers({int limit = 10}) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .orderBy('totalGiftsReceived', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) {
        final Map<String, dynamic> data = doc.data();
        return {
          'userId': doc.id,
          'username': data['username'] ?? '',
          'avatar': data['photoURL'] ?? '',
          'totalGifts': data['totalGiftsReceived']?.toString() ?? '0', // 🟢 Convert to String
          'totalDiamondsEarned': data['totalDiamondsEarned']?.toString() ?? '0', // 🟢 Convert to String
        };
      }).toList();
    } catch (e) {
      debugPrint('Error getting top receivers: $e');
      return [];
    }
  }

  // Get recent gifters
  Future<List<Map<String, dynamic>>> getRecentGifters(String receiverId) async {
    try {
      final snapshot = await _firestore
          .collection('gift_transactions')
          .where('receiverId', isEqualTo: receiverId)
          .orderBy('timestamp', descending: true)
          .limit(10)
          .get();

      final List<Map<String, dynamic>> gifters = [];
      final Set<String> seenIds = {};

      for (final doc in snapshot.docs) {
        final Map<String, dynamic> data = doc.data();
        final senderId = data['senderId'] as String?;

        if (senderId != null && !seenIds.contains(senderId)) {
          seenIds.add(senderId);

          final senderDoc = await _firestore
              .collection('users')
              .doc(senderId)
              .get();

          if (senderDoc.exists) {
            final Map<String, dynamic>? senderData = senderDoc.data();
            gifters.add({
              'userId': senderId,
              'name': senderData?['username'] ?? data['senderName'] ?? '',
              'avatar': senderData?['photoURL'] ?? '',
              'giftName': data['giftName'] ?? '',
              'amount': data['amount']?.toString() ?? '0', // 🟢 Convert to String
              'timestamp': data['timestamp']?.toString() ?? '',
            });
          }
        }
      }

      return gifters;
    } catch (e) {
      debugPrint('Error getting recent gifters: $e');
      return [];
    }
  }

  // ==================== STATISTICS ====================

  // Get gift stats
  Future<Map<String, dynamic>> getGiftStats(String userId) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> sent = await _firestore
          .collection('gift_transactions')
          .where('senderId', isEqualTo: userId)
          .get();

      final QuerySnapshot<Map<String, dynamic>> received = await _firestore
          .collection('gift_transactions')
          .where('receiverId', isEqualTo: userId)
          .get();

      var totalSent = 0;
      var totalReceived = 0;
      var coinsSpent = 0;
      var diamondsEarned = 0;

      for (final doc in sent.docs) {
        final Map<String, dynamic> data = doc.data();
        totalSent += data['amount'] as int? ?? 0;
        coinsSpent += data['totalPrice'] as int? ?? 0;
      }

      for (final doc in received.docs) {
        final Map<String, dynamic> data = doc.data();
        totalReceived += data['amount'] as int? ?? 0;
        diamondsEarned += ((data['totalPrice'] as int? ?? 0) / 2).round();
      }

      return {
        'totalSent': totalSent.toString(), // 🟢 Convert to String
        'totalReceived': totalReceived.toString(), // 🟢 Convert to String
        'coinsSpent': coinsSpent.toString(), // 🟢 Convert to String
        'diamondsEarned': diamondsEarned.toString(), // 🟢 Convert to String
        'uniqueSenders': _getUniqueCount(received.docs, 'senderId'),
        'uniqueReceivers': _getUniqueCount(sent.docs, 'receiverId'),
      };
    } catch (e) {
      debugPrint('Error getting gift stats: $e');
      return {};
    }
  }

  int _getUniqueCount(List<QueryDocumentSnapshot> docs, String field) {
    final Set<String> unique = {};
    for (final doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      unique.add(data[field] as String);
    }
    return unique.length;
  }

  // ==================== FAVORITES ====================

  // Get favorite gifts
  Future<List<Map<String, dynamic>>> getFavoriteGifts(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('favorite_gifts')
          .orderBy('addedAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final Map<String, dynamic> data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      debugPrint('Error getting favorite gifts: $e');
      return [];
    }
  }

  // Add to favorites
  Future<bool> addToFavorites(String giftId) async {
    final User? user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    try {
      final GiftModel? gift = await getGift(giftId);
      if (gift == null) throw Exception('Gift not found');

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('favorite_gifts')
          .doc(giftId)
          .set({
        'giftId': giftId,
        'giftName': gift.name,
        'giftCategory': gift.category,
        'addedAt': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      debugPrint('Error adding to favorites: $e');
      return false;
    }
  }

  // Remove from favorites
  Future<bool> removeFromFavorites(String giftId) async {
    final User? user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('favorite_gifts')
          .doc(giftId)
          .delete();

      return true;
    } catch (e) {
      debugPrint('Error removing from favorites: $e');
      return false;
    }
  }
}