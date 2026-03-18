import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

// 🟢 সঠিক imports
import '../../chat/models/chat_model.dart';
import '../../chat/models/room_model.dart';
import '../../chat/models/gift_model.dart';
import '../models/user_models.dart' as app; // 🟢 alias ব্যবহার
import '../constants/firestore_constants.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // ==================== CHAT OPERATIONS ====================

  Future<void> saveChat(ChatModel chat) async {
    try {
      debugPrint('📝 Saving chat: ${chat.id}');

      await _firestore.collection('chats').doc(chat.id).set({
        'id': chat.id,
        'type': chat.type,
        'groupName': chat.groupName,
        'groupAvatar': chat.groupAvatar,
        'participants': chat.participants,
        'lastMessage': chat.lastMessage,
        'lastMessageTime': chat.lastMessageTime?.toIso8601String(),
      });

      debugPrint('✅ Chat saved successfully: ${chat.id}');
    } catch (e) {
      debugPrint('❌ Error saving chat: $e');
      rethrow;
    }
  }

  Future<void> deleteChat(String chatId) async {
    try {
      debugPrint('📝 Deleting chat: $chatId');
      await _firestore.collection('chats').doc(chatId).delete();
      debugPrint('✅ Chat deleted successfully: $chatId');
    } catch (e) {
      debugPrint('❌ Error deleting chat: $e');
      rethrow;
    }
  }

  Future<ChatModel?> getChat(String chatId) async {
    try {
      final doc = await _firestore.collection('chats').doc(chatId).get();
      if (doc.exists) {
        final data = doc.data()!;
        return ChatModel(
          id: doc.id,
          type: data['type'] ?? 'private',
          groupName: data['groupName'],
          groupAvatar: data['groupAvatar'],
          participants: List<String>.from(data['participants'] ?? []),
          lastMessage: data['lastMessage'],
          lastMessageTime: data['lastMessageTime'] != null
              ? DateTime.parse(data['lastMessageTime'])
              : null,
        );
      }
      return null;
    } catch (e) {
      debugPrint('Error getting chat: $e');
      return null;
    }
  }

  Stream<List<ChatModel>> getChats(String userId) {
    return _firestore
        .collection('chats')
        .where('participants', arrayContains: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return ChatModel(
          id: doc.id,
          type: data['type'] ?? 'private',
          groupName: data['groupName'],
          groupAvatar: data['groupAvatar'],
          participants: List<String>.from(data['participants'] ?? []),
          lastMessage: data['lastMessage'],
          lastMessageTime: data['lastMessageTime'] != null
              ? DateTime.parse(data['lastMessageTime'])
              : null,
        );
      }).toList();
    });
  }

  // ==================== USER OPERATIONS ====================

  Future<void> createUser(app.User user) async {
    try {
      await _firestore
          .collection(FirestoreConstants.users)
          .doc(user.id)
          .set(user.toJson());
      debugPrint('✅ User created: ${user.id}');
    } catch (e) {
      debugPrint('❌ Error creating user: $e');
      rethrow;
    }
  }

  Future<app.User?> getUser(String uid) async {
    try {
      final doc = await _firestore
          .collection(FirestoreConstants.users)
          .doc(uid)
          .get();
      if (doc.exists) {
        final data = doc.data()!;
        data['id'] = doc.id;
        return app.User.fromJson(data);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting user: $e');
      return null;
    }
  }

  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    try {
      await _firestore
          .collection(FirestoreConstants.users)
          .doc(uid)
          .update(data);
      debugPrint('✅ User updated: $uid');
    } catch (e) {
      debugPrint('❌ Error updating user: $e');
      rethrow;
    }
  }

  Future<void> deleteUser(String uid) async {
    try {
      await _firestore
          .collection(FirestoreConstants.users)
          .doc(uid)
          .delete();
      debugPrint('✅ User deleted: $uid');
    } catch (e) {
      debugPrint('❌ Error deleting user: $e');
      rethrow;
    }
  }

  Stream<app.User?> streamUser(String uid) {
    return _firestore
        .collection(FirestoreConstants.users)
        .doc(uid)
        .snapshots()
        .map((doc) {
      if (doc.exists) {
        final data = doc.data()!;
        data['id'] = doc.id;
        return app.User.fromJson(data);
      }
      return null;
    });
  }

  Future<List<app.User>> getUsersByCountry(String country) async {
    try {
      final query = await _firestore
          .collection(FirestoreConstants.users)
          .where('countryId', isEqualTo: country)
          .limit(50)
          .get();
      return query.docs
          .map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return app.User.fromJson(data);
      })
          .toList();
    } catch (e) {
      debugPrint('Error getting users by country: $e');
      return [];
    }
  }

  // ==================== ROOM OPERATIONS ====================

  Future<void> createRoom(RoomModel room) async {
    try {
      await _firestore
          .collection(FirestoreConstants.rooms)
          .doc(room.id)
          .set(room.toJson());
      debugPrint('✅ Room created: ${room.id}');
    } catch (e) {
      debugPrint('❌ Error creating room: $e');
      rethrow;
    }
  }

  Future<RoomModel?> getRoom(String roomId) async {
    try {
      final doc = await _firestore
          .collection(FirestoreConstants.rooms)
          .doc(roomId)
          .get();
      if (doc.exists) {
        final data = doc.data()!;
        data['id'] = doc.id;
        return RoomModel.fromJson(data);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting room: $e');
      return null;
    }
  }

  Future<void> updateRoom(String roomId, Map<String, dynamic> data) async {
    try {
      await _firestore
          .collection(FirestoreConstants.rooms)
          .doc(roomId)
          .update(data);
      debugPrint('✅ Room updated: $roomId');
    } catch (e) {
      debugPrint('❌ Error updating room: $e');
      rethrow;
    }
  }

  Stream<List<RoomModel>> streamActiveRooms(String country) {
    var query = _firestore
        .collection(FirestoreConstants.rooms)
        .where('status', isEqualTo: 'active');
    if (country != 'All') {
      query = query.where('country', isEqualTo: country);
    }
    return query
        .orderBy('viewerCount', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return RoomModel.fromJson(data);
    })
        .toList());
  }

  // ==================== GIFT OPERATIONS ====================

  Future<void> sendGift({
    required String senderId,
    required String receiverId,
    required String giftId,
    required int amount,
    String? roomId,
  }) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final senderRef = _firestore
            .collection(FirestoreConstants.users)
            .doc(senderId);
        final senderDoc = await transaction.get(senderRef);
        if (!senderDoc.exists) return;

        final senderCoins = senderDoc.data()!['coins'] ?? 0;
        if (senderCoins < amount) throw Exception('Insufficient coins');

        transaction.update(senderRef, {'coins': senderCoins - amount});

        final receiverRef = _firestore
            .collection(FirestoreConstants.users)
            .doc(receiverId);
        final receiverDoc = await transaction.get(receiverRef);
        if (receiverDoc.exists) {
          final receiverDiamonds = receiverDoc.data()!['diamonds'] ?? 0;
          transaction.update(receiverRef, {
            'diamonds': receiverDiamonds + (amount ~/ 2),
          });
        }

        final giftTransactionRef = _firestore
            .collection(FirestoreConstants.transactions)
            .doc();
        transaction.set(giftTransactionRef, {
          'senderId': senderId,
          'receiverId': receiverId,
          'giftId': giftId,
          'amount': amount,
          'roomId': roomId,
          'type': 'gift_sent',
          'timestamp': FieldValue.serverTimestamp(),
        });
      });
      debugPrint('✅ Gift sent successfully');
    } catch (e) {
      debugPrint('❌ Error sending gift: $e');
      rethrow;
    }
  }

  Future<List<GiftModel>> getAvailableGifts() async {
    try {
      final snapshot = await _firestore
          .collection(FirestoreConstants.gifts)
          .where('isAvailable', isEqualTo: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return GiftModel.fromJson(data);
      }).toList();
    } catch (e) {
      debugPrint('Error getting gifts: $e');
      return [];
    }
  }

  // ==================== FRIEND OPERATIONS ====================

  Future<void> sendFriendRequest(String fromId, String toId) async {
    try {
      await _firestore
          .collection(FirestoreConstants.friendRequests)
          .doc()
          .set({
        'fromId': fromId,
        'toId': toId,
        'status': 'pending',
        'timestamp': FieldValue.serverTimestamp(),
      });
      debugPrint('✅ Friend request sent');
    } catch (e) {
      debugPrint('❌ Error sending friend request: $e');
      rethrow;
    }
  }

  Future<void> acceptFriendRequest(String requestId) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final requestRef = _firestore
            .collection(FirestoreConstants.friendRequests)
            .doc(requestId);
        final requestDoc = await transaction.get(requestRef);
        if (!requestDoc.exists) return;

        final data = requestDoc.data()!;
        final fromId = data['fromId'];
        final toId = data['toId'];

        transaction.update(requestRef, {'status': 'accepted'});
        transaction.update(
          _firestore.collection(FirestoreConstants.users).doc(fromId),
          {'friends': FieldValue.arrayUnion([toId])},
        );
        transaction.update(
          _firestore.collection(FirestoreConstants.users).doc(toId),
          {'friends': FieldValue.arrayUnion([fromId])},
        );
      });
      debugPrint('✅ Friend request accepted');
    } catch (e) {
      debugPrint('❌ Error accepting friend request: $e');
      rethrow;
    }
  }

  // ==================== TRANSACTION OPERATIONS ====================

  Future<void> addCoins(String userId, int amount, String reason) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final userRef = _firestore
            .collection(FirestoreConstants.users)
            .doc(userId);
        final userDoc = await transaction.get(userRef);
        if (!userDoc.exists) return;

        final currentCoins = userDoc.data()!['coins'] ?? 0;
        transaction.update(userRef, {'coins': currentCoins + amount});

        transaction.set(
          _firestore.collection(FirestoreConstants.transactions).doc(),
          {
            'userId': userId,
            'amount': amount,
            'type': 'credit',
            'reason': reason,
            'timestamp': FieldValue.serverTimestamp(),
          },
        );
      });
      debugPrint('✅ Coins added: $amount');
    } catch (e) {
      debugPrint('❌ Error adding coins: $e');
      rethrow;
    }
  }

  // ==================== REPORT OPERATIONS ====================

  Future<void> submitReport({
    required String reporterId,
    required String reportedUserId,
    required String reason,
    String? description,
    List<String>? evidence,
  }) async {
    try {
      await _firestore.collection(FirestoreConstants.reports).add({
        'reporterId': reporterId,
        'reportedUserId': reportedUserId,
        'reason': reason,
        'description': description,
        'evidence': evidence,
        'status': 'pending',
        'timestamp': FieldValue.serverTimestamp(),
      });
      debugPrint('✅ Report submitted');
    } catch (e) {
      debugPrint('❌ Error submitting report: $e');
      rethrow;
    }
  }

  // ==================== SEARCH OPERATIONS ====================

  Future<List<app.User>> searchUsers(String query) async {
    try {
      if (query.isEmpty) return [];

      final usernameQuery = await _firestore
          .collection(FirestoreConstants.users)
          .where('username', isGreaterThanOrEqualTo: query)
          .where('username', isLessThanOrEqualTo: '$query\uf8ff')
          .limit(20)
          .get();

      final idQuery = await _firestore
          .collection(FirestoreConstants.users)
          .where('uid', isEqualTo: query)
          .get();

      final results = <app.User>[];
      for (final doc in usernameQuery.docs) {
        final data = doc.data();
        data['id'] = doc.id;
        results.add(app.User.fromJson(data));
      }
      for (final doc in idQuery.docs) {
        final data = doc.data();
        data['id'] = doc.id;
        final user = app.User.fromJson(data);
        if (!results.any((u) => u.id == user.id)) {
          results.add(user);
        }
      }
      return results;
    } catch (e) {
      debugPrint('Error searching users: $e');
      return [];
    }
  }

  // ==================== BATCH OPERATIONS ====================

  Future<void> batchWrite(List<Future<void>> operations) async {
    try {
      final batch = _firestore.batch();

      for (var op in operations) {
        // Add operations to batch
        // This needs to be implemented based on your needs
      }

      await batch.commit();
      debugPrint('✅ Batch write completed');
    } catch (e) {
      debugPrint('❌ Error in batch write: $e');
      rethrow;
    }
  }

  // ==================== CLEANUP ====================

  Future<void> clearAllData() async {
    try {
      // Implement your cleanup logic here
      debugPrint('Clearing all database data');
    } catch (e) {
      debugPrint('Error clearing data: $e');
    }
  }
}