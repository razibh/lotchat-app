import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/user_model.dart';
import '../models/room_model.dart';
import '../models/gift_model.dart';
import '../constants/firestore_constants.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // ==================== USER OPERATIONS ====================

  Future<void> createUser(UserModel user) async {
    await _firestore
        .collection(FirestoreConstants.users)
        .doc(user.uid)
        .set(user.toJson());
  }

  Future<UserModel?> getUser(String uid) async {
    final doc = await _firestore
        .collection(FirestoreConstants.users)
        .doc(uid)
        .get();
    
    if (doc.exists) {
      return UserModel.fromJson(doc.data()!);
    }
    return null;
  }

  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    await _firestore
        .collection(FirestoreConstants.users)
        .doc(uid)
        .update(data);
  }

  Future<void> deleteUser(String uid) async {
    await _firestore
        .collection(FirestoreConstants.users)
        .doc(uid)
        .delete();
  }

  Stream<UserModel?> streamUser(String uid) {
    return _firestore
        .collection(FirestoreConstants.users)
        .doc(uid)
        .snapshots()
        .map((doc) => doc.exists ? UserModel.fromJson(doc.data()!) : null);
  }

  Future<List<UserModel>> getUsersByCountry(String country) async {
    final query = await _firestore
        .collection(FirestoreConstants.users)
        .where('country', isEqualTo: country)
        .limit(50)
        .get();
    
    return query.docs
        .map((doc) => UserModel.fromJson(doc.data()))
        .toList();
  }

  // ==================== ROOM OPERATIONS ====================

  Future<void> createRoom(RoomModel room) async {
    await _firestore
        .collection(FirestoreConstants.rooms)
        .doc(room.id)
        .set(room.toJson());
  }

  Future<RoomModel?> getRoom(String roomId) async {
    final doc = await _firestore
        .collection(FirestoreConstants.rooms)
        .doc(roomId)
        .get();
    
    if (doc.exists) {
      return RoomModel.fromJson(doc.data()!);
    }
    return null;
  }

  Future<void> updateRoom(String roomId, Map<String, dynamic> data) async {
    await _firestore
        .collection(FirestoreConstants.rooms)
        .doc(roomId)
        .update(data);
  }

  Stream<List<RoomModel>> streamActiveRooms(String country) {
    var query = _firestore
        .collection(FirestoreConstants.rooms)
        .where('isActive', isEqualTo: true);
    
    if (country != 'All') {
      query = query.where('country', isEqualTo: country);
    }
    
    return query
        .orderBy('viewerCount', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => RoomModel.fromJson(doc.data()))
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
    await _firestore.runTransaction((transaction) async {
      // Update sender's coins
      final senderRef = _firestore
          .collection(FirestoreConstants.users)
          .doc(senderId);
      
      final senderDoc = await transaction.get(senderRef);
      if (!senderDoc.exists) return;
      
      final senderCoins = senderDoc.data()!['coins'] ?? 0;
      if (senderCoins < amount) throw Exception('Insufficient coins');
      
      transaction.update(senderRef, <String, dynamic>{
        'coins': senderCoins - amount,
      });

      // Update receiver's diamonds
      final receiverRef = _firestore
          .collection(FirestoreConstants.users)
          .doc(receiverId);
      
      final receiverDoc = await transaction.get(receiverRef);
      if (receiverDoc.exists) {
        final receiverDiamonds = receiverDoc.data()!['diamonds'] ?? 0;
        transaction.update(receiverRef, <String, dynamic>{
          'diamonds': receiverDiamonds + (amount ~/ 2), // 50% conversion
        });
      }

      // Record gift transaction
      final giftTransactionRef = _firestore
          .collection(FirestoreConstants.transactions)
          .doc();
      
      transaction.set(giftTransactionRef, <String, >{
        'senderId': senderId,
        'receiverId': receiverId,
        'giftId': giftId,
        'amount': amount,
        'roomId': roomId,
        'type': 'gift_sent',
        'timestamp': FieldValue.serverTimestamp(),
      });
    });
  }

  Future<List<GiftModel>> getAvailableGifts() async {
    final snapshot = await _firestore
        .collection(FirestoreConstants.gifts)
        .where('isAvailable', isEqualTo: true)
        .get();
    
    return snapshot.docs
        .map((doc) => GiftModel.fromJson(doc.data()))
        .toList();
  }

  // ==================== FRIEND OPERATIONS ====================

  Future<void> sendFriendRequest(String fromId, String toId) async {
    await _firestore
        .collection(FirestoreConstants.friendRequests)
        .doc()
        .set(<String, >{
      'fromId': fromId,
      'toId': toId,
      'status': 'pending',
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<void> acceptFriendRequest(String requestId) async {
    await _firestore.runTransaction((transaction) async {
      final requestRef = _firestore
          .collection(FirestoreConstants.friendRequests)
          .doc(requestId);
      
      final requestDoc = await transaction.get(requestRef);
      if (!requestDoc.exists) return;
      
      final data = requestDoc.data();
      final fromId = data['fromId'];
      final toId = data['toId'];

      // Update request status
      transaction.update(requestRef, <String, String>{'status': 'accepted'});

      // Add to friends lists
      transaction.update(
        _firestore.collection(FirestoreConstants.users).doc(fromId),
        <String, >{'friends': FieldValue.arrayUnion(<dynamic>[toId])},
      );
      
      transaction.update(
        _firestore.collection(FirestoreConstants.users).doc(toId),
        <String, >{'friends': FieldValue.arrayUnion(<dynamic>[fromId])},
      );
    });
  }

  // ==================== TRANSACTION OPERATIONS ====================

  Future<void> addCoins(String userId, int amount, String reason) async {
    await _firestore.runTransaction((transaction) async {
      final userRef = _firestore
          .collection(FirestoreConstants.users)
          .doc(userId);
      
      final userDoc = await transaction.get(userRef);
      if (!userDoc.exists) return;
      
      final currentCoins = userDoc.data()!['coins'] ?? 0;
      
      transaction.update(userRef, <String, dynamic>{
        'coins': currentCoins + amount,
      });

      // Record transaction
      transaction.set(
        _firestore.collection(FirestoreConstants.transactions).doc(),
        <String, >{
          'userId': userId,
          'amount': amount,
          'type': 'credit',
          'reason': reason,
          'timestamp': FieldValue.serverTimestamp(),
        },
      );
    });
  }

  // ==================== REPORT OPERATIONS ====================

  Future<void> submitReport({
    required String reporterId,
    required String reportedUserId,
    required String reason,
    String? description,
    List<String>? evidence,
  }) async {
    await _firestore.collection(FirestoreConstants.reports).add(<String, >{
      'reporterId': reporterId,
      'reportedUserId': reportedUserId,
      'reason': reason,
      'description': description,
      'evidence': evidence,
      'status': 'pending',
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // ==================== SEARCH OPERATIONS ====================

  Future<List<UserModel>> searchUsers(String query) async {
    if (query.isEmpty) return <UserModel>[];
    
    // Search by username
    final usernameQuery = await _firestore
        .collection(FirestoreConstants.users)
        .where('username', isGreaterThanOrEqualTo: query)
        .where('username', isLessThanOrEqualTo: '$query\uf8ff')
        .limit(20)
        .get();
    
    // Search by ID
    final idQuery = await _firestore
        .collection(FirestoreConstants.users)
        .where('uid', isEqualTo: query)
        .get();
    
    final List<UserModel> results = <UserModel>[];
    
    for (final doc in usernameQuery.docs) {
      results.add(UserModel.fromJson(doc.data()));
    }
    
    for (final doc in idQuery.docs) {
      final UserModel user = UserModel.fromJson(doc.data());
      if (!results.any((UserModel u) => u.uid == user.uid)) {
        results.add(user);
      }
    }
    
    return results;
  }

  // ==================== BATCH OPERATIONS ====================

  Future<void> batchWrite(List<Future<void>> operations) async {
    final batch = _firestore.batch();
    
    for (Future<void> op in operations) {
      // Add operations to batch
    }
    
    await batch.commit();
  }
}