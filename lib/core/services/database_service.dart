import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import '../../chat/models/chat_model.dart';

import '../constants/firestore_constants.dart';
import '../models/gift_model.dart';
import '../../chat/models/room_model.dart';
import '../models/user_model.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // ==================== CHAT OPERATIONS ====================

  // 🟢 Save chat method
  Future<void> saveChat(ChatModel chat) async {
    try {
      debugPrint('📝 Saving chat: ${chat.id}');

      await _firestore.collection('chats').doc(chat.id).set(<String, dynamic>{
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

  // 🟢 Delete chat method
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

  // 🟢 Get chat by ID
  Future<ChatModel?> getChat(String chatId) async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> doc = await _firestore.collection('chats').doc(chatId).get();

      if (doc.exists) {
        final Map<String, dynamic> data = doc.data()!;
        return ChatModel(
          id: doc.id,
          type: data['type'] ?? 'private',
          groupName: data['groupName'],
          groupAvatar: data['groupAvatar'],
          participants: List<String>.from(data['participants'] ?? <dynamic>[]),
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

  // 🟢 Get all chats for a user
  Stream<List<ChatModel>> getChats(String userId) {
    return _firestore
        .collection('chats')
        .where('participants', arrayContains: userId)
        .snapshots()
        .map((QuerySnapshot<Map<String, dynamic>> snapshot) {
      return snapshot.docs.map((QueryDocumentSnapshot<Map<String, dynamic>> doc) {
        final Map<String, dynamic> data = doc.data();
        return ChatModel(
          id: doc.id,
          type: data['type'] ?? 'private',
          groupName: data['groupName'],
          groupAvatar: data['groupAvatar'],
          participants: List<String>.from(data['participants'] ?? <dynamic>[]),
          lastMessage: data['lastMessage'],
          lastMessageTime: data['lastMessageTime'] != null
              ? DateTime.parse(data['lastMessageTime'])
              : null,
        );
      }).toList();
    });
  }

  // ==================== USER OPERATIONS ====================

  Future<void> createUser(UserModel user) async {
    try {
      await _firestore
          .collection(FirestoreConstants.users)
          .doc(user.uid)
          .set(user.toJson());
      debugPrint('✅ User created: ${user.uid}');
    } catch (e) {
      debugPrint('❌ Error creating user: $e');
      rethrow;
    }
  }

  Future<UserModel?> getUser(String uid) async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> doc = await _firestore
          .collection(FirestoreConstants.users)
          .doc(uid)
          .get();

      if (doc.exists) {
        return UserModel.fromJson(doc.data()!);
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

  Stream<UserModel?> streamUser(String uid) {
    return _firestore
        .collection(FirestoreConstants.users)
        .doc(uid)
        .snapshots()
        .map((DocumentSnapshot<Map<String, dynamic>> doc) => doc.exists ? UserModel.fromJson(doc.data()!) : null);
  }

  Future<List<UserModel>> getUsersByCountry(String country) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> query = await _firestore
          .collection(FirestoreConstants.users)
          .where('country', isEqualTo: country)
          .limit(50)
          .get();

      return query.docs
          .map((QueryDocumentSnapshot<Map<String, dynamic>> doc) => UserModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      debugPrint('Error getting users by country: $e');
      return <UserModel>[];
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
      final DocumentSnapshot<Map<String, dynamic>> doc = await _firestore
          .collection(FirestoreConstants.rooms)
          .doc(roomId)
          .get();

      if (doc.exists) {
        return RoomModel.fromJson(doc.data()!);
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
    Query<Map<String, dynamic>> query = _firestore
        .collection(FirestoreConstants.rooms)
        .where('isActive', isEqualTo: true);

    if (country != 'All') {
      query = query.where('country', isEqualTo: country);
    }

    return query
        .orderBy('viewerCount', descending: true)
        .snapshots()
        .map((QuerySnapshot<Map<String, dynamic>> snapshot) => snapshot.docs
        .map((QueryDocumentSnapshot<Map<String, dynamic>> doc) => RoomModel.fromJson(doc.data()))
        .toList(),);
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
      await _firestore.runTransaction((Transaction transaction) async {
        // Update sender's coins
        final DocumentReference<Map<String, dynamic>> senderRef = _firestore
            .collection(FirestoreConstants.users)
            .doc(senderId);

        final DocumentSnapshot<Map<String, dynamic>> senderDoc = await transaction.get(senderRef);
        if (!senderDoc.exists) return;

        final senderCoins = senderDoc.data()!['coins'] ?? 0;
        if (senderCoins < amount) throw Exception('Insufficient coins');

        transaction.update(senderRef, <String, dynamic>{
          'coins': senderCoins - amount,
        });

        // Update receiver's diamonds
        final DocumentReference<Map<String, dynamic>> receiverRef = _firestore
            .collection(FirestoreConstants.users)
            .doc(receiverId);

        final DocumentSnapshot<Map<String, dynamic>> receiverDoc = await transaction.get(receiverRef);
        if (receiverDoc.exists) {
          final receiverDiamonds = receiverDoc.data()!['diamonds'] ?? 0;
          transaction.update(receiverRef, <String, dynamic>{
            'diamonds': receiverDiamonds + (amount ~/ 2), // 50% conversion
          });
        }

        // Record gift transaction
        final DocumentReference<Map<String, dynamic>> giftTransactionRef = _firestore
            .collection(FirestoreConstants.transactions)
            .doc();

        transaction.set(giftTransactionRef, <String, Object?>{
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
      final QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
          .collection(FirestoreConstants.gifts)
          .where('isAvailable', isEqualTo: true)
          .get();

      return snapshot.docs
          .map((QueryDocumentSnapshot<Map<String, dynamic>> doc) => GiftModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      debugPrint('Error getting gifts: $e');
      return <GiftModel>[];
    }
  }

  // ==================== FRIEND OPERATIONS ====================

  Future<void> sendFriendRequest(String fromId, String toId) async {
    try {
      await _firestore
          .collection(FirestoreConstants.friendRequests)
          .doc()
          .set(<String, dynamic>{
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
      await _firestore.runTransaction((Transaction transaction) async {
        final DocumentReference<Map<String, dynamic>> requestRef = _firestore
            .collection(FirestoreConstants.friendRequests)
            .doc(requestId);

        final DocumentSnapshot<Map<String, dynamic>> requestDoc = await transaction.get(requestRef);
        if (!requestDoc.exists) return;

        final Map<String, dynamic> data = requestDoc.data()!;
        final fromId = data['fromId'];
        final toId = data['toId'];

        // Update request status
        transaction.update(requestRef, <String, dynamic>{'status': 'accepted'});

        // Add to friends lists
        transaction.update(
          _firestore.collection(FirestoreConstants.users).doc(fromId),
          <String, dynamic>{'friends': FieldValue.arrayUnion(<dynamic>[toId])},
        );

        transaction.update(
          _firestore.collection(FirestoreConstants.users).doc(toId),
          <String, dynamic>{'friends': FieldValue.arrayUnion(<dynamic>[fromId])},
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
      await _firestore.runTransaction((Transaction transaction) async {
        final DocumentReference<Map<String, dynamic>> userRef = _firestore
            .collection(FirestoreConstants.users)
            .doc(userId);

        final DocumentSnapshot<Map<String, dynamic>> userDoc = await transaction.get(userRef);
        if (!userDoc.exists) return;

        final currentCoins = userDoc.data()!['coins'] ?? 0;

        transaction.update(userRef, <String, dynamic>{
          'coins': currentCoins + amount,
        });

        // Record transaction
        transaction.set(
          _firestore.collection(FirestoreConstants.transactions).doc(),
          <String, Object>{
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
      await _firestore.collection(FirestoreConstants.reports).add(<String, dynamic>{
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

  Future<List<UserModel>> searchUsers(String query) async {
    try {
      if (query.isEmpty) return <UserModel>[];

      // Search by username
      final QuerySnapshot<Map<String, dynamic>> usernameQuery = await _firestore
          .collection(FirestoreConstants.users)
          .where('username', isGreaterThanOrEqualTo: query)
          .where('username', isLessThanOrEqualTo: '$query\uf8ff')
          .limit(20)
          .get();

      // Search by ID
      final QuerySnapshot<Map<String, dynamic>> idQuery = await _firestore
          .collection(FirestoreConstants.users)
          .where('uid', isEqualTo: query)
          .get();

      final List<UserModel> results = <UserModel>[];

      for (final QueryDocumentSnapshot<Map<String, dynamic>> doc in usernameQuery.docs) {
        results.add(UserModel.fromJson(doc.data()));
      }

      for (final QueryDocumentSnapshot<Map<String, dynamic>> doc in idQuery.docs) {
        final UserModel user = UserModel.fromJson(doc.data());
        if (!results.any((UserModel u) => u.uid == user.uid)) {
          results.add(user);
        }
      }

      return results;
    } catch (e) {
      debugPrint('Error searching users: $e');
      return <UserModel>[];
    }
  }

  // ==================== BATCH OPERATIONS ====================

  Future<void> batchWrite(List<Future<void>> operations) async {
    try {
      final WriteBatch batch = _firestore.batch();

      for (Future<void> op in operations) {
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