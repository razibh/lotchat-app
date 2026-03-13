import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/friend_model.dart';
import '../models/user_model.dart';
import '../di/service_locator.dart';
import 'notification_service.dart';

class FriendService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final NotificationService _notificationService = ServiceLocator().get<NotificationService>();

  // Get friends list
  Stream<List<UserModel>> getFriends(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('friends')
        .snapshots()
        .asyncMap((snapshot) async {
          final List<UserModel> friends = <UserModel>[];
          for (final doc in snapshot.docs) {
            final friendData = doc.data();
            final UserModel? friendUser = await _getUser(friendData['friendId']);
            if (friendUser != null) {
              friends.add(friendUser);
            }
          }
          return friends;
        });
  }

  // Get friend by id
  Future<UserModel?> getFriend(String userId, String friendId) async {
    try {
      final doc = await _firestore
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
      print('Error getting friend: $e');
      return null;
    }
  }

  // Get user
  Future<UserModel?> _getUser(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return UserModel.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Get online friends
  Stream<List<UserModel>> getOnlineFriends(String userId) {
    return getFriends(userId).map((List<UserModel> friends) {
      return friends.where((UserModel f) => f.isOnline).toList();
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
        .asyncMap((snapshot) async {
          final requests = <FriendRequestModel>[];
          for (final doc in snapshot.docs) {
            final data = doc.data();
            data['id'] = doc.id;
            
            // Get sender info
            final UserModel? sender = await _getUser(data['senderId']);
            if (sender != null) {
              data['senderName'] = sender.username;
              data['senderAvatar'] = sender.photoURL;
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
        .asyncMap((snapshot) async {
          final requests = <FriendRequestModel>[];
          for (final doc in snapshot.docs) {
            final data = doc.data();
            data['id'] = doc.id;
            
            // Get receiver info
            final UserModel? receiver = await _getUser(data['receiverId']);
            if (receiver != null) {
              data['receiverName'] = receiver.username;
              data['receiverAvatar'] = receiver.photoURL;
            }
            
            requests.add(FriendRequestModel.fromJson(data));
          }
          return requests;
        });
  }

  // Send friend request
  Future<bool> sendFriendRequest(String receiverId, {String? message}) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    try {
      // Check if already friends
      final friendDoc = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('friends')
          .doc(receiverId)
          .get();
      
      if (friendDoc.exists) return false;

      // Check if request already exists
      final existingRequest = await _firestore
          .collection('friend_requests')
          .where('senderId', isEqualTo: user.uid)
          .where('receiverId', isEqualTo: receiverId)
          .where('status', isEqualTo: 'pending')
          .get();

      if (existingRequest.docs.isNotEmpty) return false;

      // Create request
      await _firestore.collection('friend_requests').add(<String, >{
        'senderId': user.uid,
        'senderName': user.displayName ?? 'User',
        'receiverId': receiverId,
        'message': message,
        'status': 'pending',
        'sentAt': FieldValue.serverTimestamp(),
      });

      // Send notification
      await _notificationService.sendNotification(
        userId: receiverId,
        type: 'friend_request',
        title: 'Friend Request',
        body: '${user.displayName ?? 'User'} sent you a friend request',
        data: <String, >{'senderId': user.uid},
      );

      return true;
    } catch (e) {
      print('Error sending friend request: $e');
      return false;
    }
  }

  // Accept friend request
  Future<bool> acceptFriendRequest(String requestId, String senderId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    try {
      return await _firestore.runTransaction((transaction) async {
        // Update request status
        final requestRef = _firestore.collection('friend_requests').doc(requestId);
        transaction.update(requestRef, <String, >{
          'status': 'accepted',
          'respondedAt': FieldValue.serverTimestamp(),
        });

        // Add to user's friends
        final userFriendsRef = _firestore
            .collection('users')
            .doc(user.uid)
            .collection('friends')
            .doc(senderId);
        
        transaction.set(userFriendsRef, <String, >{
          'friendId': senderId,
          'addedAt': FieldValue.serverTimestamp(),
        });

        // Add to sender's friends
        final senderFriendsRef = _firestore
            .collection('users')
            .doc(senderId)
            .collection('friends')
            .doc(user.uid);
        
        transaction.set(senderFriendsRef, <String, >{
          'friendId': user.uid,
          'addedAt': FieldValue.serverTimestamp(),
        });

        // Send notification
        await _notificationService.sendNotification(
          userId: senderId,
          type: 'friend_accept',
          title: 'Friend Request Accepted',
          body: '${user.displayName ?? 'User'} accepted your friend request',
          data: <String, >{'userId': user.uid},
        );

        return true;
      });
    } catch (e) {
      print('Error accepting friend request: $e');
      return false;
    }
  }

  // Reject friend request
  Future<bool> rejectFriendRequest(String requestId) async {
    try {
      await _firestore
          .collection('friend_requests')
          .doc(requestId)
          .update(<String, >{
            'status': 'rejected',
            'respondedAt': FieldValue.serverTimestamp(),
          });
      return true;
    } catch (e) {
      print('Error rejecting friend request: $e');
      return false;
    }
  }

  // Cancel friend request
  Future<bool> cancelFriendRequest(String requestId) async {
    try {
      await _firestore.collection('friend_requests').doc(requestId).delete();
      return true;
    } catch (e) {
      print('Error canceling friend request: $e');
      return false;
    }
  }

  // Remove friend
  Future<bool> removeFriend(String friendId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    try {
      return await _firestore.runTransaction((transaction) async {
        // Remove from user's friends
        final userFriendRef = _firestore
            .collection('users')
            .doc(user.uid)
            .collection('friends')
            .doc(friendId);
        
        transaction.delete(userFriendRef);

        // Remove from friend's friends
        final friendFriendRef = _firestore
            .collection('users')
            .doc(friendId)
            .collection('friends')
            .doc(user.uid);
        
        transaction.delete(friendFriendRef);

        return true;
      });
    } catch (e) {
      print('Error removing friend: $e');
      return false;
    }
  }

  // Block user
  Future<bool> blockUser(String userId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    try {
      return await _firestore.runTransaction((transaction) async {
        // Remove from friends if exists
        final friendRef = _firestore
            .collection('users')
            .doc(user.uid)
            .collection('friends')
            .doc(userId);
        
        transaction.delete(friendRef);

        // Add to blocked list
        final blockedRef = _firestore
            .collection('users')
            .doc(user.uid)
            .collection('blocked')
            .doc(userId);
        
        transaction.set(blockedRef, <String, >{
          'blockedId': userId,
          'blockedAt': FieldValue.serverTimestamp(),
        });

        return true;
      });
    } catch (e) {
      print('Error blocking user: $e');
      return false;
    }
  }

  // Unblock user
  Future<bool> unblockUser(String userId) async {
    final user = _auth.currentUser;
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
      print('Error unblocking user: $e');
      return false;
    }
  }

  // Get blocked users
  Stream<List<UserModel>> getBlockedUsers() {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('blocked')
        .snapshots()
        .asyncMap((snapshot) async {
          final List<UserModel> blocked = <UserModel>[];
          for (final doc in snapshot.docs) {
            final data = doc.data();
            final userDoc = await _firestore
                .collection('users')
                .doc(data['blockedId'])
                .get();
            
            if (userDoc.exists) {
              blocked.add(UserModel.fromJson(userDoc.data()!));
            }
          }
          return blocked;
        });
  }

  // Get friend suggestions
  Future<List<FriendSuggestion>> getFriendSuggestions({int limit = 20}) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    try {
      // Get user's friends
      final friendsSnapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('friends')
          .get();
      
      final friendIds = friendsSnapshot.docs
          .map((doc) => doc.data()['friendId'] as String)
          .toSet();

      // Get blocked users
      final blockedSnapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('blocked')
          .get();
      
      final blockedIds = blockedSnapshot.docs
          .map((doc) => doc.data()['blockedId'] as String)
          .toSet();

      // Get users with mutual friends
      final suggestions = <FriendSuggestion>[];
      final Set<String> seenIds = <String>{user.uid, ...friendIds, ...blockedIds};

      for (final friendId in friendIds) {
        final friendFriends = await _firestore
            .collection('users')
            .doc(friendId)
            .collection('friends')
            .get();

        for (final doc in friendFriends.docs) {
          final String potentialId = doc.data()['friendId'] as String;
          if (!seenIds.contains(potentialId)) {
            seenIds.add(potentialId);
            
            final userDoc = await _firestore.collection('users').doc(potentialId).get();
            if (userDoc.exists) {
              final data = userDoc.data();
              final int mutualCount = await _getMutualFriendsCount(user.uid, potentialId);
              final List<String> commonInterests = await _getCommonInterests(user.uid, potentialId);
              
              // Calculate score
              final var score = mutualCount * 10 + commonInterests.length * 5;
              
              suggestions.add(FriendSuggestion(
                userId: potentialId,
                name: data['username'] ?? 'Unknown',
                avatar: data['photoURL'],
                mutualFriends: mutualCount,
                commonInterests: commonInterests,
                score: score,
              ));
            }
          }
        }
      }

      // Sort by score
      suggestions.sort((Object? a, Object? b) => b.score.compareTo(a.score));
      return suggestions.take(limit).toList();
    } catch (e) {
      print('Error getting suggestions: $e');
      return <>[];
    }
  }

  // Get mutual friends count
  Future<int> _getMutualFriendsCount(String userId1, String userId2) async {
    try {
      final friends1 = await _firestore
          .collection('users')
          .doc(userId1)
          .collection('friends')
          .get();
      
      final friends2 = await _firestore
          .collection('users')
          .doc(userId2)
          .collection('friends')
          .get();

      final set1 = friends1.docs.map((doc) => doc.data()['friendId']).toSet();
      final set2 = friends2.docs.map((doc) => doc.data()['friendId']).toSet();
      
      return set1.intersection(set2).length;
    } catch (e) {
      return 0;
    }
  }

  // Get common interests
  Future<List<String>> _getCommonInterests(String userId1, String userId2) async {
    try {
      final UserModel? user1 = await _getUser(userId1);
      final UserModel? user2 = await _getUser(userId2);
      
      if (user1 == null || user2 == null) return <String>[];
      
      return user1.interests
          .where((String i) => user2.interests.contains(i))
          .toList();
    } catch (e) {
      return <String>[];
    }
  }

  // Check if users are friends
  Future<bool> areFriends(String userId1, String userId2) async {
    try {
      final doc = await _firestore
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
    final currentUser = _auth.currentUser;
    if (currentUser == null) return null;

    // Check if friends
    if (await areFriends(currentUser.uid, userId)) {
      return 'friends';
    }

    // Check if request sent
    final sentRequest = await _firestore
        .collection('friend_requests')
        .where('senderId', isEqualTo: currentUser.uid)
        .where('receiverId', isEqualTo: userId)
        .where('status', isEqualTo: 'pending')
        .get();

    if (sentRequest.docs.isNotEmpty) {
      return 'request_sent';
    }

    // Check if request received
    final receivedRequest = await _firestore
        .collection('friend_requests')
        .where('senderId', isEqualTo: userId)
        .where('receiverId', isEqualTo: currentUser.uid)
        .where('status', isEqualTo: 'pending')
        .get();

    if (receivedRequest.docs.isNotEmpty) {
      return 'request_received';
    }

    // Check if blocked
    final blocked = await _firestore
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
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    final friends = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('friends')
        .get();

    final pendingRequests = await _firestore
        .collection('friend_requests')
        .where('receiverId', isEqualTo: user.uid)
        .where('status', isEqualTo: 'pending')
        .get();

    final sentRequests = await _firestore
        .collection('friend_requests')
        .where('senderId', isEqualTo: user.uid)
        .where('status', isEqualTo: 'pending')
        .get();

    final blocked = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('blocked')
        .get();

    // Count online friends
    var onlineFriends = 0;
    for (final doc in friends.docs) {
      final friendDoc = await _firestore
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

    for (final doc in friends.docs) {
      final addedAt = (doc.data()['addedAt'] as Timestamp).toDate();
      if (addedAt.isAfter(oneWeekAgo)) friendsThisWeek++;
      if (addedAt.isAfter(oneMonthAgo)) friendsThisMonth++;
    }

    return FriendStats(
      totalFriends: friends.docs.length,
      onlineFriends: onlineFriends,
      pendingRequests: pendingRequests.docs.length,
      sentRequests: sentRequests.docs.length,
      blockedUsers: blocked.docs.length,
      mutualFriends: 0, // Calculate if needed
      friendsThisWeek: friendsThisWeek,
      friendsThisMonth: friendsThisMonth,
    );
  }
}