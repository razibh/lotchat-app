import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/friend_model.dart';

class FriendService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ==================== FRIEND OPERATIONS ====================

  Stream<List<FriendModel>> getFriends(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('friends')
        .snapshots()
        .asyncMap((snapshot) async {
          final List<FriendModel> friends = <FriendModel>[];
          for (final doc in snapshot.docs) {
            final friendData = doc.data();
            final FriendModel? friendUser = await _getUserInfo(friendData['friendId']);
            if (friendUser != null) {
              friends.add(friendUser);
            }
          }
          return friends;
        });
  }

  Future<FriendModel?> _getUserInfo(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (!doc.exists) return null;

      final data = doc.data();
      return FriendModel(
        userId: userId,
        username: data['username'] ?? 'Unknown',
        displayName: data['displayName'],
        avatar: data['photoURL'],
        bio: data['bio'],
        onlineStatus: data['isOnline'] == true
            ? OnlineStatus.online
            : OnlineStatus.offline,
        lastActive: (data['lastActive'] as Timestamp?)?.toDate(),
        friendsSince: DateTime.now(), // Need to get from friendship document
        mutualFriends: await _getMutualFriendsCount(
          _auth.currentUser?.uid ?? '',
          userId,
        ),
        commonInterests: _getCommonInterests(data),
      );
    } catch (e) {
      print('Error getting user info: $e');
      return null;
    }
  }

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

      final Set<String> set1 = friends1.docs.map((doc) => doc.data()['friendId']).toSet();
      final Set<String> set2 = friends2.docs.map((doc) => doc.data()['friendId']).toSet();
      
      return set1.intersection(set2).length;
    } catch (e) {
      return 0;
    }
  }

  List<String> _getCommonInterests(Map<String, dynamic> userData) {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return <String>[];

    // This would need to fetch current user's interests and compare
    return <String>[];
  }

  // ==================== FRIEND REQUESTS ====================

  Stream<List<FriendRequestModel>> getIncomingRequests(String userId) {
    return _firestore
        .collection('friend_requests')
        .where('toId', isEqualTo: userId)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .asyncMap((snapshot) async {
          final List<FriendRequestModel> requests = <FriendRequestModel>[];
          for (final doc in snapshot.docs) {
            final data = doc.data();
            final FriendModel? fromUser = await _getUserInfo(data['fromId']);
            if (fromUser != null) {
              requests.add(FriendRequestModel(
                requestId: doc.id,
                userId: fromUser.userId,
                username: fromUser.username,
                avatar: fromUser.avatar,
                timestamp: (data['timestamp'] as Timestamp).toDate(),
                message: data['message'],
                mutualFriends: await _getMutualFriendsCount(
                  userId,
                  fromUser.userId,
                ),
              ));
            }
          }
          return requests;
        });
  }

  Stream<List<FriendRequestModel>> getOutgoingRequests(String userId) {
    return _firestore
        .collection('friend_requests')
        .where('fromId', isEqualTo: userId)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
          final data = doc.data();
          return FriendRequestModel(
            requestId: doc.id,
            userId: data['toId'],
            username: data['toName'] ?? 'Unknown',
            timestamp: (data['timestamp'] as Timestamp).toDate(),
            mutualFriends: 0,
          );
        }).toList());
  }

  Future<bool> sendFriendRequest(String toUserId, {String? message}) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      // Check if already friends
      final friendDoc = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('friends')
          .doc(toUserId)
          .get();
      
      if (friendDoc.exists) return false;

      // Check if request already exists
      final existingRequest = await _firestore
          .collection('friend_requests')
          .where('fromId', isEqualTo: user.uid)
          .where('toId', isEqualTo: toUserId)
          .where('status', isEqualTo: 'pending')
          .get();

      if (existingRequest.docs.isNotEmpty) return false;

      // Get receiver info for notification
      final toUserDoc = await _firestore.collection('users').doc(toUserId).get();
      final toUserName = toUserDoc.data()?['username'] ?? 'User';

      // Create request
      await _firestore.collection('friend_requests').add(<String, >{
        'fromId': user.uid,
        'fromName': user.displayName ?? 'User',
        'toId': toUserId,
        'toName': toUserName,
        'message': message,
        'status': 'pending',
        'timestamp': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      print('Error sending friend request: $e');
      return false;
    }
  }

  Future<bool> acceptFriendRequest(String requestId, String fromUserId) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      await _firestore.runTransaction((transaction) async {
        // Update request status
        final requestRef = _firestore.collection('friend_requests').doc(requestId);
        transaction.update(requestRef, <String, String>{'status': 'accepted'});

        // Add to user's friends list
        final userFriendsRef = _firestore
            .collection('users')
            .doc(user.uid)
            .collection('friends')
            .doc(fromUserId);
        
        transaction.set(userFriendsRef, <String, >{
          'friendId': fromUserId,
          'addedAt': FieldValue.serverTimestamp(),
        });

        // Add to other user's friends list
        final otherFriendsRef = _firestore
            .collection('users')
            .doc(fromUserId)
            .collection('friends')
            .doc(user.uid);
        
        transaction.set(otherFriendsRef, <String, >{
          'friendId': user.uid,
          'addedAt': FieldValue.serverTimestamp(),
        });
      });

      return true;
    } catch (e) {
      print('Error accepting friend request: $e');
      return false;
    }
  }

  Future<bool> rejectFriendRequest(String requestId) async {
    try {
      await _firestore
          .collection('friend_requests')
          .doc(requestId)
          .update(<String, String>{'status': 'rejected'});
      return true;
    } catch (e) {
      print('Error rejecting friend request: $e');
      return false;
    }
  }

  Future<bool> cancelFriendRequest(String requestId) async {
    try {
      await _firestore.collection('friend_requests').doc(requestId).delete();
      return true;
    } catch (e) {
      print('Error canceling friend request: $e');
      return false;
    }
  }

  // ==================== FRIEND MANAGEMENT ====================

  Future<bool> removeFriend(String friendId) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      await _firestore.runTransaction((transaction) async {
        // Remove from user's friends
        final userFriendRef = _firestore
            .collection('users')
            .doc(user.uid)
            .collection('friends')
            .doc(friendId);
        
        transaction.delete(userFriendRef);

        // Remove from other user's friends
        final otherFriendRef = _firestore
            .collection('users')
            .doc(friendId)
            .collection('friends')
            .doc(user.uid);
        
        transaction.delete(otherFriendRef);
      });

      return true;
    } catch (e) {
      print('Error removing friend: $e');
      return false;
    }
  }

  Future<bool> blockUser(String userId) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      await _firestore.runTransaction((transaction) async {
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
      });

      return true;
    } catch (e) {
      print('Error blocking user: $e');
      return false;
    }
  }

  Future<bool> unblockUser(String userId) async {
    final user = _auth.currentUser;
    if (user == null) return false;

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

  // ==================== FRIEND SUGGESTIONS ====================

  Future<List<FriendSuggestionModel>> getSuggestions() async {
    final user = _auth.currentUser;
    if (user == null) return <FriendSuggestionModel>[];

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

      // Get users with mutual friends (friends of friends)
      final List<FriendSuggestionModel> suggestions = <FriendSuggestionModel>[];
      final Set<String> seenIds = <String>{user.uid, ...friendIds};

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
              
              suggestions.add(FriendSuggestionModel(
                userId: potentialId,
                username: data['username'] ?? 'Unknown',
                displayName: data['displayName'],
                avatar: data['photoURL'],
                mutualFriends: mutualCount,
                reason: 'Mutual friends',
                score: mutualCount * 10,
              ));
            }
          }
        }
      }

      // Sort by score
      suggestions.sort((FriendSuggestionModel a, FriendSuggestionModel b) => b.score.compareTo(a.score));
      return suggestions.take(50).toList();
    } catch (e) {
      print('Error getting suggestions: $e');
      return <FriendSuggestionModel>[];
    }
  }

  // ==================== ONLINE STATUS ====================

  Stream<OnlineStatus> streamOnlineStatus(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((doc) {
          if (!doc.exists) return OnlineStatus.offline;
          final data = doc.data();
          final isOnline = data['isOnline'] ?? false;
          final lastActive = (data['lastActive'] as Timestamp?)?.toDate();
          
          if (!isOnline) return OnlineStatus.offline;
          
          // Check if away (inactive for 5 minutes)
          if (lastActive != null &&
              DateTime.now().difference(lastActive).inMinutes > 5) {
            return OnlineStatus.away;
          }
          
          return OnlineStatus.online;
        });
  }

  Future<void> updateOnlineStatus(bool isOnline) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _firestore.collection('users').doc(user.uid).update(<String, >{
        'isOnline': isOnline,
        'lastActive': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating online status: $e');
    }
  }

  // ==================== FAVORITES ====================

  Future<void> toggleFavorite(String friendId, bool isFavorite) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('friends')
          .doc(friendId)
          .update(<String, bool>{'isFavorite': isFavorite});
    } catch (e) {
      print('Error toggling favorite: $e');
    }
  }

  // ==================== FRIEND NOTES ====================

  Future<void> updateFriendNote(String friendId, String note) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('friends')
          .doc(friendId)
          .update(<String, String>{'note': note});
    } catch (e) {
      print('Error updating friend note: $e');
    }
  }

  // ==================== BLOCKED USERS ====================

  Stream<List<Map<String, dynamic>>> getBlockedUsers() {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('blocked')
        .snapshots()
        .asyncMap((snapshot) async {
          final List<Map<String, dynamic>> blocked = <Map<String, dynamic>>[];
          for (final doc in snapshot.docs) {
            final data = doc.data();
            final userDoc = await _firestore
                .collection('users')
                .doc(data['blockedId'])
                .get();
            
            if (userDoc.exists) {
              blocked.add(userDoc.data()!);
            }
          }
          return blocked;
        });
  }
}