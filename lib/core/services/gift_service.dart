import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/gift_model.dart';
import '../models/user_model.dart';
import '../di/service_locator.dart';
import 'notification_service.dart';
import 'analytics_service.dart';

class GiftService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final NotificationService _notificationService = ServiceLocator().get<NotificationService>();
  final AnalyticsService _analyticsService = ServiceLocator().get<AnalyticsService>();

  // Get available gifts
  Future<List<GiftModel>> getAvailableGifts() async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
          .collection('gifts')
          .where('isAvailable', isEqualTo: true)
          .orderBy('price')
          .get();

      return snapshot.docs
          .map((QueryDocumentSnapshot<Map<String, dynamic>> doc) => GiftModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('Error getting gifts: $e');
      return GiftModel.getMockGifts(); // Fallback to mock data
    }
  }

  // Get gifts by category
  Future<List<GiftModel>> getGiftsByCategory(String category) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
          .collection('gifts')
          .where('category', isEqualTo: category)
          .where('isAvailable', isEqualTo: true)
          .orderBy('price')
          .get();

      return snapshot.docs
          .map((QueryDocumentSnapshot<Map<String, dynamic>> doc) => GiftModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('Error getting gifts by category: $e');
      final allGifts = GiftModel.getMockGifts();
      return allGifts.where((g) => g.category == category).toList();
    }
  }

  // Get gift by id
  Future<GiftModel?> getGift(String giftId) async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> doc = await _firestore.collection('gifts').doc(giftId).get();
      if (doc.exists) {
        return GiftModel.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      print('Error getting gift: $e');
      return GiftModel.getMockGifts().firstWhere((g) => g.id == giftId);
    }
  }

  // Send gift
  Future<bool> sendGift({
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
        final DocumentReference<Map<String, dynamic>> senderRef = _firestore.collection('users').doc(user.uid);
        final DocumentSnapshot<Map<String, dynamic>> senderDoc = await transaction.get(senderRef);
        
        if (!senderDoc.exists) throw Exception('Sender not found');
        
        final senderCoins = senderDoc.data()!['coins'] ?? 0;
        if (senderCoins < totalPrice) {
          throw Exception('Insufficient coins');
        }

        // Deduct coins from sender
        transaction.update(senderRef, <String, dynamic>{
          'coins': senderCoins - totalPrice,
        });

        // Add diamonds to receiver (50% conversion)
        final DocumentReference<Map<String, dynamic>> receiverRef = _firestore.collection('users').doc(receiverId);
        final DocumentSnapshot<Map<String, dynamic>> receiverDoc = await transaction.get(receiverRef);
        
        if (receiverDoc.exists) {
          final receiverDiamonds = receiverDoc.data()!['diamonds'] ?? 0;
          final int earnedDiamonds = (totalPrice / 2).round();
          
          transaction.update(receiverRef, <String, dynamic>{
            'diamonds': receiverDiamonds + earnedDiamonds,
          });
        }

        // Record gift transaction
        final DocumentReference<Map<String, dynamic>> giftTransactionRef = _firestore.collection('gift_transactions').doc();
        transaction.set(giftTransactionRef, <String, >{
          'senderId': user.uid,
          'senderName': user.displayName,
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
        transaction.update(giftRef, <String, >{
          'sentCount': FieldValue.increment(amount),
        });

        // Update sender's stats
        transaction.update(senderRef, <String, >{
          'totalGiftsSent': FieldValue.increment(amount),
          'totalCoinsSpent': FieldValue.increment(totalPrice),
        });

        // Update receiver's stats
        if (receiverDoc.exists) {
          transaction.update(receiverRef, <String, >{
            'totalGiftsReceived': FieldValue.increment(amount),
            'totalDiamondsEarned': FieldValue.increment(earnedDiamonds),
          });
        }

        // Send notification
        await _notificationService.sendNotification(
          userId: receiverId,
          type: 'gift',
          title: 'Gift Received! 🎁',
          body: '${user.displayName ?? 'Someone'} sent you ${amount == 1 ? 'a' : amount} ${gift.name}${amount > 1 ? 's' : ''}',
          data: <String, >{
            'senderId': user.uid,
            'giftId': giftId,
            'amount': amount,
            'roomId': roomId,
          },
        );

        // Track analytics
        await _analyticsService.trackGiftSent(
          giftId: giftId,
          giftName: gift.name,
          price: totalPrice,
          receiverId: receiverId,
          roomId: roomId,
        );

        return true;
      });
    } catch (e) {
      print('Error sending gift: $e');
      return false;
    }
  }

  // Get gift history
  Stream<List<Map<String, dynamic>>> getGiftHistory(String userId) {
    return _firestore
        .collection('gift_transactions')
        .where(Filter.or(
          Filter('senderId', isEqualTo: userId),
          Filter('receiverId', isEqualTo: userId),
        ),)
        .orderBy('timestamp', descending: true)
        .limit(100)
        .snapshots()
        .map((QuerySnapshot<Map<String, dynamic>> snapshot) => snapshot.docs.map((QueryDocumentSnapshot<Map<String, dynamic>> doc) {
          final Map<String, dynamic> data = doc.data();
          data['id'] = doc.id;
          return data;
        }).toList(),);
  }

  // Get sent gifts
  Stream<List<Map<String, dynamic>>> getSentGifts(String userId) {
    return _firestore
        .collection('gift_transactions')
        .where('senderId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((QuerySnapshot<Map<String, dynamic>> snapshot) => snapshot.docs.map((QueryDocumentSnapshot<Map<String, dynamic>> doc) {
          final Map<String, dynamic> data = doc.data();
          data['id'] = doc.id;
          return data;
        }).toList(),);
  }

  // Get received gifts
  Stream<List<Map<String, dynamic>>> getReceivedGifts(String userId) {
    return _firestore
        .collection('gift_transactions')
        .where('receiverId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((QuerySnapshot<Map<String, dynamic>> snapshot) => snapshot.docs.map((QueryDocumentSnapshot<Map<String, dynamic>> doc) {
          final Map<String, dynamic> data = doc.data();
          data['id'] = doc.id;
          return data;
        }).toList(),);
  }

  // Get top gifters
  Future<List<Map<String, dynamic>>> getTopGifters({int limit = 10}) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
          .collection('users')
          .orderBy('totalGiftsSent', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((QueryDocumentSnapshot<Map<String, dynamic>> doc) {
        final Map<String, dynamic> data = doc.data();
        return <String, dynamic>{
          'userId': doc.id,
          'username': data['username'],
          'avatar': data['photoURL'],
          'totalGifts': data['totalGiftsSent'] ?? 0,
          'totalCoinsSpent': data['totalCoinsSpent'] ?? 0,
        };
      }).toList();
    } catch (e) {
      print('Error getting top gifters: $e');
      return <Map<String, dynamic>>[];
    }
  }

  // Get top receivers
  Future<List<Map<String, dynamic>>> getTopReceivers({int limit = 10}) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
          .collection('users')
          .orderBy('totalGiftsReceived', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((QueryDocumentSnapshot<Map<String, dynamic>> doc) {
        final Map<String, dynamic> data = doc.data();
        return <String, dynamic>{
          'userId': doc.id,
          'username': data['username'],
          'avatar': data['photoURL'],
          'totalGifts': data['totalGiftsReceived'] ?? 0,
          'totalDiamondsEarned': data['totalDiamondsEarned'] ?? 0,
        };
      }).toList();
    } catch (e) {
      print('Error getting top receivers: $e');
      return <Map<String, dynamic>>[];
    }
  }

  // Get recent gifters
  Future<List<Map<String, dynamic>>> getRecentGifters(String receiverId) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
          .collection('gift_transactions')
          .where('receiverId', isEqualTo: receiverId)
          .orderBy('timestamp', descending: true)
          .limit(10)
          .get();

      final List<Map<String, dynamic>> gifters = <Map<String, dynamic>>[];
      final Set<String> seenIds = <String>{};

      for (final QueryDocumentSnapshot<Map<String, dynamic>> doc in snapshot.docs) {
        final Map<String, dynamic> data = doc.data();
        final senderId = data['senderId'];
        
        if (!seenIds.contains(senderId)) {
          seenIds.add(senderId);
          
          final DocumentSnapshot<Map<String, dynamic>> senderDoc = await _firestore
              .collection('users')
              .doc(senderId)
              .get();
          
          if (senderDoc.exists) {
            final Map<String, dynamic>? senderData = senderDoc.data();
            gifters.add(<String, dynamic>{
              'userId': senderId,
              'name': senderData['username'] ?? data['senderName'],
              'avatar': senderData['photoURL'],
              'giftName': data['giftName'],
              'amount': data['amount'],
              'timestamp': data['timestamp'],
            });
          }
        }
      }

      return gifters;
    } catch (e) {
      print('Error getting recent gifters: $e');
      return <Map<String, dynamic>>[];
    }
  }

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

      for (final QueryDocumentSnapshot<Map<String, dynamic>> doc in sent.docs) {
        final Map<String, dynamic> data = doc.data();
        totalSent += data['amount'] ?? 0;
        coinsSpent += data['totalPrice'] ?? 0;
      }

      for (final QueryDocumentSnapshot<Map<String, dynamic>> doc in received.docs) {
        final Map<String, dynamic> data = doc.data();
        totalReceived += data['amount'] ?? 0;
        diamondsEarned += (data['totalPrice'] ?? 0) ~/ 2;
      }

      return <String, dynamic>{
        'totalSent': totalSent,
        'totalReceived': totalReceived,
        'coinsSpent': coinsSpent,
        'diamondsEarned': diamondsEarned,
        'uniqueSenders': _getUniqueCount(received.docs, 'senderId'),
        'uniqueReceivers': _getUniqueCount(sent.docs, 'receiverId'),
      };
    } catch (e) {
      print('Error getting gift stats: $e');
      return <String, dynamic>{};
    }
  }

  int _getUniqueCount(List<QueryDocumentSnapshot> docs, String field) {
    final Set<String> unique = <String>{};
    for (final QueryDocumentSnapshot<Object?> doc in docs) {
      unique.add(doc.data()[field] as String);
    }
    return unique.length;
  }

  // Get favorite gifts
  Future<List<Map<String, dynamic>>> getFavoriteGifts(String userId) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('favorite_gifts')
          .orderBy('addedAt', descending: true)
          .get();

      return snapshot.docs.map((QueryDocumentSnapshot<Map<String, dynamic>> doc) {
        final Map<String, dynamic> data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      return <Map<String, dynamic>>[];
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
          .set(<String, >{
            'giftId': giftId,
            'giftName': gift.name,
            'giftCategory': gift.category,
            'giftIcon': gift.icon,
            'giftColor': gift.color,
            'addedAt': FieldValue.serverTimestamp(),
          });

      return true;
    } catch (e) {
      print('Error adding to favorites: $e');
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
      print('Error removing from favorites: $e');
      return false;
    }
  }
}