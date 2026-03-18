import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/frame_model.dart';
import '../models/user_models.dart' as app; // 🟢 alias ব্যবহার
import '../di/service_locator.dart';
import 'notification_service.dart';

class FriendService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late final NotificationService _notificationService;

  FriendService() {
    _initializeServices();
  }

  void _initializeServices() {
    try {
      _notificationService = ServiceLocator.instance.get<NotificationService>();
    } catch (e) {
      debugPrint('Error initializing services: $e');
    }
  }

  // Get friends list
  Stream<List<app.User>> getFriends(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('friends')
        .snapshots()
        .asyncMap((QuerySnapshot<Map<String, dynamic>> snapshot) async {
      final List<app.User> friends = [];
      for (final QueryDocumentSnapshot<Map<String, dynamic>> doc in snapshot.docs) {
        final Map<String, dynamic> friendData = doc.data();
        final app.User? friendUser = await _getUser(friendData['friendId']);
        if (friendUser != null) {
          friends.add(friendUser);
        }
      }
      return friends;
    });
  }

  // Get friend by id
  Future<app.User?> getFriend(String userId, String friendId) async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('friends')
          .doc(friendId)
          .get();

      if (doc.exists) {
        return await _getUser(doc.data()!['friendId']);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting friend: $e');
      return null;
    }
  }

  // Get user
  Future<app.User?> _getUser(String userId) async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> doc = await _firestore.collection('users').doc(userId).get();
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

  // Get online friends
  Stream<List<app.User>> getOnlineFriends(String userId) {
    return getFriends(userId).map((List<app.User> friends) {
      return friends.where((app.User f) => f.isOnline).toList();
    });
  }

  // Get friend requests
  Stream<List<FriendRequestModel>> getFriendRequests(String userId) {
    return _firestore
        .collection('friend_requests')
        .where('receiverId', isEqualTo: userId)
        .where('status', isEqualTo: 'pending')
        .orderBy('sentAt', descending: true)
        .snapshots()
        .asyncMap((QuerySnapshot<Map<String, dynamic>> snapshot) async {
      final requests = <FriendRequestModel>[];
      for (final QueryDocumentSnapshot<Map<String, dynamic>> doc in snapshot.docs) {
        final Map<String, dynamic> data = doc.data();
        data['id'] = doc.id;

        // Get sender info
        final app.User? sender = await _getUser(data['senderId']);
        if (sender != null) {
          data['senderName'] = sender.username;
          data['senderAvatar'] = sender.avatar;
        }

        requests.add(FriendRequestModel.fromJson(data));
      }
      return requests;
    });
  }

  // Get sent requests
  Stream<List<FriendRequestModel>> getSentRequests(String userId) {
    return _firestore
        .collection('friend_requests')
        .where('senderId', isEqualTo: userId)
        .where('status', isEqualTo: 'pending')
        .orderBy('sentAt', descending: true)
        .snapshots()
        .asyncMap((QuerySnapshot<Map<String, dynamic>> snapshot) async {
      final requests = <FriendRequestModel>[];
      for (final QueryDocumentSnapshot<Map<String, dynamic>> doc in snapshot.docs) {
        final Map<String, dynamic> data = doc.data();
        data['id'] = doc.id;

        // Get receiver info
        final app.User? receiver = await _getUser(data['receiverId']);
        if (receiver != null) {
          data['receiverName'] = receiver.username;
          data['receiverAvatar'] = receiver.avatar;
        }

        requests.add(FriendRequestModel.fromJson(data));
      }
      return requests;
    });
  }

  // Send friend request
  Future<bool> sendFriendRequest(String receiverId, {String? message}) async {
    final User? user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    try {
      // Check if already friends
      final DocumentSnapshot<Map<String, dynamic>> friendDoc = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('friends')
          .doc(receiverId)
          .get();

      if (friendDoc.exists) return false;

      // Check if request already exists
      final QuerySnapshot<Map<String, dynamic>> existingRequest = await _firestore
          .collection('friend_requests')
          .where('senderId', isEqualTo: user.uid)
          .where('receiverId', isEqualTo: receiverId)
          .where('status', isEqualTo: 'pending')
          .get();

      if (existingRequest.docs.isNotEmpty) return false;

      // Create request
      await _firestore.collection('friend_requests').add({
        'senderId': user.uid,
        'senderName': user.displayName ?? 'User',
        'receiverId': receiverId,
        'message': message,
        'status': 'pending',
        'sentAt': FieldValue.serverTimestamp(),
      });

      // Send notification
      await _notificationService?.sendNotification(
        userId: receiverId,
        type: 'friend_request',
        title: 'Friend Request',
        body: '${user.displayName ?? 'User'} sent you a friend request',
        data: {'senderId': user.uid},
      );

      return true;
    } catch (e) {
      debugPrint('Error sending friend request: $e');
      return false;
    }
  }

  // Accept friend request
  Future<bool> acceptFriendRequest(String requestId, String senderId) async {
    final User? user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    try {
      return await _firestore.runTransaction((Transaction transaction) async {
        // Update request status
        final DocumentReference<Map<String, dynamic>> requestRef = _firestore.collection('friend_requests').doc(requestId);
        transaction.update(requestRef, {
          'status': 'accepted',
          'respondedAt': FieldValue.serverTimestamp(),
        });

        // Add to user's friends
        final DocumentReference<Map<String, dynamic>> userFriendsRef = _firestore
            .collection('users')
            .doc(user.uid)
            .collection('friends')
            .doc(senderId);

        transaction.set(userFriendsRef, {
          'friendId': senderId,
          'addedAt': FieldValue.serverTimestamp(),
        });

        // Add to sender's friends
        final DocumentReference<Map<String, dynamic>> senderFriendsRef = _firestore
            .collection('users')
            .doc(senderId)
            .collection('friends')
            .doc(user.uid);

        transaction.set(senderFriendsRef, {
          'friendId': user.uid,
          'addedAt': FieldValue.serverTimestamp(),
        });

        // Send notification
        await _notificationService?.sendNotification(
          userId: senderId,
          type: 'friend_accept',
          title: 'Friend Request Accepted',
          body: '${user.displayName ?? 'User'} accepted your friend request',
          data: {'userId': user.uid},
        );

        return true;
      });
    } catch (e) {
      debugPrint('Error accepting friend request: $e');
      return false;
    }
  }

  // Reject friend request
  Future<bool> rejectFriendRequest(String requestId) async {
    try {
      await _firestore
          .collection('friend_requests')
          .doc(requestId)
          .update({
        'status': 'rejected',
        'respondedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      debugPrint('Error rejecting friend request: $e');
      return false;
    }
  }

  // Cancel friend request
  Future<bool> cancelFriendRequest(String requestId) async {
    try {
      await _firestore.collection('friend_requests').doc(requestId).delete();
      return true;
    } catch (e) {
      debugPrint('Error canceling friend request: $e');
      return false;
    }
  }

  // Remove friend
  Future<bool> removeFriend(String friendId) async {
    final User? user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    try {
      return await _firestore.runTransaction((Transaction transaction) async {
        // Remove from user's friends
        final DocumentReference<Map<String, dynamic>> userFriendRef = _firestore
            .collection('users')
            .doc(user.uid)
            .collection('friends')
            .doc(friendId);

        transaction.delete(userFriendRef);

        // Remove from friend's friends
        final DocumentReference<Map<String, dynamic>> friendFriendRef = _firestore
            .collection('users')
            .doc(friendId)
            .collection('friends')
            .doc(user.uid);

        transaction.delete(friendFriendRef);

        return true;
      });
    } catch (e) {
      debugPrint('Error removing friend: $e');
      return false;
    }
  }

  // Block user
  Future<bool> blockUser(String userId) async {
    final User? user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    try {
      return await _firestore.runTransaction((Transaction transaction) async {
        // Remove from friends if exists
        final DocumentReference<Map<String, dynamic>> friendRef = _firestore
            .collection('users')
            .doc(user.uid)
            .collection('friends')
            .doc(userId);

        transaction.delete(friendRef);

        // Add to blocked list
        final DocumentReference<Map<String, dynamic>> blockedRef = _firestore
            .collection('users')
            .doc(user.uid)
            .collection('blocked')
            .doc(userId);

        transaction.set(blockedRef, {
          'blockedId': userId,
          'blockedAt': FieldValue.serverTimestamp(),
        });

        return true;
      });
    } catch (e) {
      debugPrint('Error blocking user: $e');
      return false;
    }
  }

  // Unblock user
  Future<bool> unblockUser(String userId) async {
    final User? user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('blocked')
          .doc(userId)
          .delete();
      return true;
    } catch (e) {
      debugPrint('Error unblocking user: $e');
      return false;
    }
  }

  // Get blocked users
  Stream<List<app.User>> getBlockedUsers() {
    final User? user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('blocked')
        .snapshots()
        .asyncMap((QuerySnapshot<Map<String, dynamic>> snapshot) async {
      final List<app.User> blocked = [];
      for (final QueryDocumentSnapshot<Map<String, dynamic>> doc in snapshot.docs) {
        final Map<String, dynamic> data = doc.data();
        final DocumentSnapshot<Map<String, dynamic>> userDoc = await _firestore
            .collection('users')
            .doc(data['blockedId'])
            .get();

        if (userDoc.exists) {
          final userData = userDoc.data()!;
          userData['id'] = userDoc.id;
          blocked.add(app.User.fromJson(userData));
        }
      }
      return blocked;
    });
  }

  // Get friend suggestions
  Future<List<FriendSuggestion>> getFriendSuggestions({int limit = 20}) async {
    final User? user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    try {
      // Get user's friends
      final QuerySnapshot<Map<String, dynamic>> friendsSnapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('friends')
          .get();

      final Set<String> friendIds = friendsSnapshot.docs
          .map((QueryDocumentSnapshot<Map<String, dynamic>> doc) => doc.data()['friendId'] as String)
          .toSet();

      // Get blocked users
      final QuerySnapshot<Map<String, dynamic>> blockedSnapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('blocked')
          .get();

      final Set<String> blockedIds = blockedSnapshot.docs
          .map((QueryDocumentSnapshot<Map<String, dynamic>> doc) => doc.data()['blockedId'] as String)
          .toSet();

      // Get users with mutual friends
      final suggestions = <FriendSuggestion>[];
      final Set<String> seenIds = {user.uid, ...friendIds, ...blockedIds};

      for (final String friendId in friendIds) {
        final QuerySnapshot<Map<String, dynamic>> friendFriends = await _firestore
            .collection('users')
            .doc(friendId)
            .collection('friends')
            .get();

        for (final QueryDocumentSnapshot<Map<String, dynamic>> doc in friendFriends.docs) {
          final String potentialId = doc.data()['friendId'] as String;
          if (!seenIds.contains(potentialId)) {
            seenIds.add(potentialId);

            final DocumentSnapshot<Map<String, dynamic>> userDoc = await _firestore.collection('users').doc(potentialId).get();
            if (userDoc.exists) {
              final Map<String, dynamic>? data = userDoc.data();
              final int mutualCount = await _getMutualFriendsCount(user.uid, potentialId);
              final List<String> commonInterests = await _getCommonInterests(user.uid, potentialId);

              // Calculate score
              final score = mutualCount * 10 + commonInterests.length * 5;

              suggestions.add(FriendSuggestion(
                userId: potentialId,
                name: data?['username'] ?? 'Unknown',
                avatar: data?['photoURL'],
                mutualFriends: mutualCount,
                commonInterests: commonInterests,
                score: score,
              ));
            }
          }
        }
      }

      // Sort by score
      suggestions.sort((a, b) => b.score.compareTo(a.score));
      return suggestions.take(limit).toList();
    } catch (e) {
      debugPrint('Error getting suggestions: $e');
      return [];
    }
  }

  // Get mutual friends count
  Future<int> _getMutualFriendsCount(String userId1, String userId2) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> friends1 = await _firestore
          .collection('users')
          .doc(userId1)
          .collection('friends')
          .get();

      final QuerySnapshot<Map<String, dynamic>> friends2 = await _firestore
          .collection('users')
          .doc(userId2)
          .collection('friends')
          .get();

      final Set<String> set1 = friends1.docs.map((doc) => doc.data()['friendId'] as String).toSet();
      final Set<String> set2 = friends2.docs.map((doc) => doc.data()['friendId'] as String).toSet();

      return set1.intersection(set2).length;
    } catch (e) {
      return 0;
    }
  }

  // Get common interests
  Future<List<String>> _getCommonInterests(String userId1, String userId2) async {
    try {
      final app.User? user1 = await _getUser(userId1);
      final app.User? user2 = await _getUser(userId2);

      if (user1 == null || user2 == null) return [];

      return user1.interests
          .where((String i) => user2.interests.contains(i))
          .toList();
    } catch (e) {
      return [];
    }
  }

  // Check if users are friends
  Future<bool> areFriends(String userId1, String userId2) async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> doc = await _firestore
          .collection('users')
          .doc(userId1)
          .collection('friends')
          .doc(userId2)
          .get();

      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  // Get friend status
  Future<String?> getFriendStatus(String userId) async {
    final User? currentUser = _auth.currentUser;
    if (currentUser == null) return null;

    // Check if friends
    if (await areFriends(currentUser.uid, userId)) {
      return 'friends';
    }

    // Check if request sent
    final QuerySnapshot<Map<String, dynamic>> sentRequest = await _firestore
        .collection('friend_requests')
        .where('senderId', isEqualTo: currentUser.uid)
        .where('receiverId', isEqualTo: userId)
        .where('status', isEqualTo: 'pending')
        .get();

    if (sentRequest.docs.isNotEmpty) {
      return 'request_sent';
    }

    // Check if request received
    final QuerySnapshot<Map<String, dynamic>> receivedRequest = await _firestore
        .collection('friend_requests')
        .where('senderId', isEqualTo: userId)
        .where('receiverId', isEqualTo: currentUser.uid)
        .where('status', isEqualTo: 'pending')
        .get();

    if (receivedRequest.docs.isNotEmpty) {
      return 'request_received';
    }

    // Check if blocked
    final DocumentSnapshot<Map<String, dynamic>> blocked = await _firestore
        .collection('users')
        .doc(currentUser.uid)
        .collection('blocked')
        .doc(userId)
        .get();

    if (blocked.exists) {
      return 'blocked';
    }

    return null;
  }

  // Get friend stats
  Future<FriendStats> getFriendStats() async {
    final User? user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    final QuerySnapshot<Map<String, dynamic>> friends = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('friends')
        .get();

    final QuerySnapshot<Map<String, dynamic>> pendingRequests = await _firestore
        .collection('friend_requests')
        .where('receiverId', isEqualTo: user.uid)
        .where('status', isEqualTo: 'pending')
        .get();

    final QuerySnapshot<Map<String, dynamic>> sentRequests = await _firestore
        .collection('friend_requests')
        .where('senderId', isEqualTo: user.uid)
        .where('status', isEqualTo: 'pending')
        .get();

    final QuerySnapshot<Map<String, dynamic>> blocked = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('blocked')
        .get();

    // Count online friends
    var onlineFriends = 0;
    for (final QueryDocumentSnapshot<Map<String, dynamic>> doc in friends.docs) {
      final DocumentSnapshot<Map<String, dynamic>> friendDoc = await _firestore
          .collection('users')
          .doc(doc.data()['friendId'])
          .get();
      if (friendDoc.exists && friendDoc.data()!['isOnline'] == true) {
        onlineFriends++;
      }
    }

    // Count friends this week/month
    final DateTime oneWeekAgo = DateTime.now().subtract(const Duration(days: 7));
    final DateTime oneMonthAgo = DateTime.now().subtract(const Duration(days: 30));

    var friendsThisWeek = 0;
    var friendsThisMonth = 0;

    for (final QueryDocumentSnapshot<Map<String, dynamic>> doc in friends.docs) {
      final DateTime addedAt = (doc.data()['addedAt'] as Timestamp).toDate();
      if (addedAt.isAfter(oneWeekAgo)) friendsThisWeek++;
      if (addedAt.isAfter(oneMonthAgo)) friendsThisMonth++;
    }

    return FriendStats(
      totalFriends: friends.docs.length,
      onlineFriends: onlineFriends,
      pendingRequests: pendingRequests.docs.length,
      sentRequests: sentRequests.docs.length,
      blockedUsers: blocked.docs.length,
      mutualFriends: 0,
      friendsThisWeek: friendsThisWeek,
      friendsThisMonth: friendsThisMonth,
    );
  }
}

// ==================== MODEL CLASSES ====================

class FriendRequestModel {
  final String id;
  final String senderId;
  final String senderName;
  final String? senderAvatar;
  final String receiverId;
  final String? receiverName;
  final String? receiverAvatar;
  final String? message;
  final String status;
  final DateTime sentAt;
  final DateTime? respondedAt;

  FriendRequestModel({
    required this.id,
    required this.senderId,
    required this.senderName,
    this.senderAvatar,
    required this.receiverId,
    this.receiverName,
    this.receiverAvatar,
    this.message,
    required this.status,
    required this.sentAt,
    this.respondedAt,
  });

  factory FriendRequestModel.fromJson(Map<String, dynamic> json) {
    return FriendRequestModel(
      id: json['id'] ?? '',
      senderId: json['senderId'] ?? '',
      senderName: json['senderName'] ?? '',
      senderAvatar: json['senderAvatar'],
      receiverId: json['receiverId'] ?? '',
      receiverName: json['receiverName'],
      receiverAvatar: json['receiverAvatar'],
      message: json['message'],
      status: json['status'] ?? 'pending',
      sentAt: json['sentAt'] != null
          ? (json['sentAt'] as Timestamp).toDate()
          : DateTime.now(),
      respondedAt: json['respondedAt'] != null
          ? (json['respondedAt'] as Timestamp).toDate()
          : null,
    );
  }

  // ✅ toJson() method add koro
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'senderName': senderName,
      'senderAvatar': senderAvatar,
      'receiverId': receiverId,
      'receiverName': receiverName,
      'receiverAvatar': receiverAvatar,
      'message': message,
      'status': status,
      'sentAt': sentAt.toIso8601String(),
      'respondedAt': respondedAt?.toIso8601String(),
    };
  }
}

class FriendSuggestion {
  final String userId;
  final String name;
  final String? avatar;
  final int mutualFriends;
  final List<String> commonInterests;
  final int score;

  FriendSuggestion({
    required this.userId,
    required this.name,
    this.avatar,
    required this.mutualFriends,
    required this.commonInterests,
    required this.score,
  });
}

class FriendStats {
  final int totalFriends;
  final int onlineFriends;
  final int pendingRequests;
  final int sentRequests;
  final int blockedUsers;
  final int mutualFriends;
  final int friendsThisWeek;
  final int friendsThisMonth;

  FriendStats({
    required this.totalFriends,
    required this.onlineFriends,
    required this.pendingRequests,
    required this.sentRequests,
    required this.blockedUsers,
    required this.mutualFriends,
    required this.friendsThisWeek,
    required this.friendsThisMonth,
  });
}