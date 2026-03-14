import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/room_model.dart';
import '../models/user_model.dart';
import '../di/service_locator.dart';
import 'notification_service.dart';

class RoomService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final NotificationService _notificationService = ServiceLocator().get<NotificationService>();

  // Create room
  Future<RoomModel?> createRoom({
    required String name,
    required String category,
    String? description,
    String? coverImage,
    bool isPrivate = false,
    String? pinCode,
    int maxSeats = 9,
  }) async {
    final User? user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    try {
      final RoomModel room = RoomModel(
        id: '',
        name: name,
        hostId: user.uid,
        hostName: user.displayName ?? 'User',
        hostAvatar: user.photoURL,
        category: category,
        description: description,
        coverImage: coverImage,
        viewerCount: 0,
        maxSeats: maxSeats,
        seats: List.generate(maxSeats, (int index) => SeatModel(
          seatNumber: index + 1,
          isEmpty: true,
        ),),
        isPrivate: isPrivate,
        pinCode: pinCode,
        createdAt: DateTime.now(),
        isActive: true,
      );

      final DocumentReference<Map<String, dynamic>> docRef = await _firestore.collection('rooms').add(room.toJson());
      return room.copyWith(id: docRef.id);
    } catch (e) {
      print('Error creating room: $e');
      return null;
    }
  }

  // Get room
  Future<RoomModel?> getRoom(String roomId) async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> doc = await _firestore.collection('rooms').doc(roomId).get();
      if (doc.exists) {
        return RoomModel.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      print('Error getting room: $e');
      return null;
    }
  }

  // Stream room
  Stream<RoomModel?> streamRoom(String roomId) {
    return _firestore
        .collection('rooms')
        .doc(roomId)
        .snapshots()
        .map((DocumentSnapshot<Map<String, dynamic>> doc) => doc.exists ? RoomModel.fromJson(doc.data()!) : null);
  }

  // Get active rooms
  Stream<List<RoomModel>> getActiveRooms({String? category, String? country}) {
    Query<Map<String, dynamic>> query = _firestore
        .collection('rooms')
        .where('isActive', isEqualTo: true)
        .orderBy('viewerCount', descending: true);

    if (category != null && category != 'All') {
      query = query.where('category', isEqualTo: category);
    }

    if (country != null && country != 'All') {
      query = query.where('country', isEqualTo: country);
    }

    return query.snapshots().map((QuerySnapshot<Map<String, dynamic>> snapshot) => snapshot.docs
        .map((QueryDocumentSnapshot<Map<String, dynamic>> doc) => RoomModel.fromJson(doc.data()))
        .toList(),);
  }

  // Get recommended rooms
  Future<List<RoomModel>> getRecommendedRooms(String userId, {int limit = 10}) async {
    try {
      final UserModel? user = await _getUser(userId);
      if (user == null) return <RoomModel>[];

      // Get user's room history
      final QuerySnapshot<Map<String, dynamic>> historySnapshot = await _firestore
          .collection('room_history')
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .limit(20)
          .get();

      final Set<String> visitedRoomIds = historySnapshot.docs
          .map((QueryDocumentSnapshot<Map<String, dynamic>> doc) => doc.data()['roomId'] as String)
          .toSet();

      // Get active rooms
      final QuerySnapshot<Map<String, dynamic>> roomsSnapshot = await _firestore
          .collection('rooms')
          .where('isActive', isEqualTo: true)
          .limit(50)
          .get();

      final rooms = roomsSnapshot.docs
          .map((QueryDocumentSnapshot<Map<String, dynamic>> doc) => RoomModel.fromJson(doc.data()))
          .where((Object? r) => !visitedRoomIds.contains(r.id))
          .toList();

      // Score rooms
      final List<Map<String, dynamic>> scoredRooms = rooms.map((Object? room) {
        double score = 0;

        // Match category
        if (room.category == user.interests.firstOrNull) {
          score += 30;
        }

        // Match country
        if (room.country == user.country) {
          score += 20;
        }

        // Popularity
        score += (room.viewerCount / 100).clamp(0, 30);

        // Freshness
        final int ageHours = DateTime.now().difference(room.createdAt).inHours;
        score += (24 - ageHours).clamp(0, 20);

        return <String, dynamic>{'room': room, 'score': score};
      }).toList();

      // Sort by score
      scoredRooms.sort((Map<String, dynamic> a, Map<String, dynamic> b) => b['score'].compareTo(a['score']));
      
      return scoredRooms.take(limit).map((Map<String, dynamic> item) => item['room'] as RoomModel).toList();
    } catch (e) {
      print('Error getting recommended rooms: $e');
      return <RoomModel>[];
    }
  }

  // Update room
  Future<bool> updateRoom(String roomId, Map<String, dynamic> updates) async {
    final User? user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    try {
      final RoomModel? room = await getRoom(roomId);
      if (room == null) throw Exception('Room not found');

      // Check if user is host or moderator
      if (room.hostId != user.uid && !room.moderators.contains(user.uid)) {
        throw Exception('Not authorized');
      }

      await _firestore.collection('rooms').doc(roomId).update(updates);
      return true;
    } catch (e) {
      print('Error updating room: $e');
      return false;
    }
  }

  // Join room
  Future<bool> joinRoom(String roomId, String userId) async {
    try {
      final DocumentReference<Map<String, dynamic>> roomRef = _firestore.collection('rooms').doc(roomId);
      
      await _firestore.runTransaction((Transaction transaction) async {
        final DocumentSnapshot<Map<String, dynamic>> roomDoc = await transaction.get(roomRef);
        if (!roomDoc.exists) throw Exception('Room not found');

        final room = RoomModel.fromJson(roomDoc.data()!);
        
        if (!room.isActive) throw Exception('Room is not active');
        
        if (room.isPrivate) {
          // Check if user is invited
          if (!room.invitedUsers.contains(userId)) {
            throw Exception('You need an invitation to join this room');
          }
        }

        // Add to viewer count
        transaction.update(roomRef, <String, >{
          'viewerCount': FieldValue.increment(1),
        });

        // Add to room history
        transaction.set(
          _firestore.collection('room_history').doc(),
          <String, >{
            'roomId': roomId,
            'userId': userId,
            'timestamp': FieldValue.serverTimestamp(),
          },
        );
      });

      return true;
    } catch (e) {
      print('Error joining room: $e');
      return false;
    }
  }

  // Leave room
  Future<bool> leaveRoom(String roomId) async {
    try {
      final DocumentReference<Map<String, dynamic>> roomRef = _firestore.collection('rooms').doc(roomId);
      
      await _firestore.runTransaction((Transaction transaction) async {
        final DocumentSnapshot<Map<String, dynamic>> roomDoc = await transaction.get(roomRef);
        if (!roomDoc.exists) throw Exception('Room not found');

        transaction.update(roomRef, <String, >{
          'viewerCount': FieldValue.increment(-1),
        });
      });

      return true;
    } catch (e) {
      print('Error leaving room: $e');
      return false;
    }
  }

  // Take seat
  Future<bool> takeSeat(String roomId, int seatNumber, String userId) async {
    try {
      final DocumentReference<Map<String, dynamic>> roomRef = _firestore.collection('rooms').doc(roomId);
      
      await _firestore.runTransaction((Transaction transaction) async {
        final DocumentSnapshot<Map<String, dynamic>> roomDoc = await transaction.get(roomRef);
        if (!roomDoc.exists) throw Exception('Room not found');

        final room = RoomModel.fromJson(roomDoc.data()!);
        
        if (seatNumber < 1 || seatNumber > room.maxSeats) {
          throw Exception('Invalid seat number');
        }

        final seat = room.seats.firstWhere((s) => s.seatNumber == seatNumber);
        
        if (!seat.isEmpty) {
          throw Exception('Seat is already taken');
        }

        // Update seat
        final updatedSeats = room.seats.map((s) {
          if (s.seatNumber == seatNumber) {
            return SeatModel(
              seatNumber: s.seatNumber,
              userId: userId,
              userName: _auth.currentUser?.displayName ?? 'User',
              userAvatar: _auth.currentUser?.photoURL,
              isMuted: false,
              isSpeaking: false,
              isEmpty: false,
            );
          }
          return s;
        }).toList();

        transaction.update(roomRef, <String, >{'seats': updatedSeats.map((s) => s.toJson()).toList()});
      });

      return true;
    } catch (e) {
      print('Error taking seat: $e');
      return false;
    }
  }

  // Leave seat
  Future<bool> leaveSeat(String roomId, int seatNumber) async {
    try {
      final DocumentReference<Map<String, dynamic>> roomRef = _firestore.collection('rooms').doc(roomId);
      
      await _firestore.runTransaction((Transaction transaction) async {
        final DocumentSnapshot<Map<String, dynamic>> roomDoc = await transaction.get(roomRef);
        if (!roomDoc.exists) throw Exception('Room not found');

        final room = RoomModel.fromJson(roomDoc.data()!);
        
        // Update seat
        final updatedSeats = room.seats.map((s) {
          if (s.seatNumber == seatNumber) {
            return SeatModel(
              seatNumber: s.seatNumber,
              isEmpty: true,
            );
          }
          return s;
        }).toList();

        transaction.update(roomRef, <String, >{'seats': updatedSeats.map((s) => s.toJson()).toList()});
      });

      return true;
    } catch (e) {
      print('Error leaving seat: $e');
      return false;
    }
  }

  // Mute/unmute seat
  Future<bool> toggleMute(String roomId, int seatNumber, bool isMuted) async {
    try {
      final DocumentReference<Map<String, dynamic>> roomRef = _firestore.collection('rooms').doc(roomId);
      
      await _firestore.runTransaction((Transaction transaction) async {
        final DocumentSnapshot<Map<String, dynamic>> roomDoc = await transaction.get(roomRef);
        if (!roomDoc.exists) throw Exception('Room not found');

        final room = RoomModel.fromJson(roomDoc.data()!);
        
        // Update seat mute status
        final updatedSeats = room.seats.map((s) {
          if (s.seatNumber == seatNumber) {
            return SeatModel(
              seatNumber: s.seatNumber,
              userId: s.userId,
              userName: s.userName,
              userAvatar: s.userAvatar,
              isMuted: isMuted,
              isSpeaking: s.isSpeaking,
              isEmpty: s.isEmpty,
            );
          }
          return s;
        }).toList();

        transaction.update(roomRef, <String, >{'seats': updatedSeats.map((s) => s.toJson()).toList()});
      });

      return true;
    } catch (e) {
      print('Error toggling mute: $e');
      return false;
    }
  }

  // Update speaking status
  Future<bool> updateSpeaking(String roomId, int seatNumber, bool isSpeaking) async {
    try {
      final DocumentReference<Map<String, dynamic>> roomRef = _firestore.collection('rooms').doc(roomId);
      
      await _firestore.runTransaction((Transaction transaction) async {
        final DocumentSnapshot<Map<String, dynamic>> roomDoc = await transaction.get(roomRef);
        if (!roomDoc.exists) throw Exception('Room not found');

        final room = RoomModel.fromJson(roomDoc.data()!);
        
        // Update seat speaking status
        final updatedSeats = room.seats.map((s) {
          if (s.seatNumber == seatNumber) {
            return SeatModel(
              seatNumber: s.seatNumber,
              userId: s.userId,
              userName: s.userName,
              userAvatar: s.userAvatar,
              isMuted: s.isMuted,
              isSpeaking: isSpeaking,
              isEmpty: s.isEmpty,
            );
          }
          return s;
        }).toList();

        transaction.update(roomRef, <String, >{'seats': updatedSeats.map((s) => s.toJson()).toList()});
      });

      return true;
    } catch (e) {
      print('Error updating speaking status: $e');
      return false;
    }
  }

  // Close room
  Future<bool> closeRoom(String roomId) async {
    final User? user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    try {
      final RoomModel? room = await getRoom(roomId);
      if (room == null) throw Exception('Room not found');

      if (room.hostId != user.uid) {
        throw Exception('Only host can close the room');
      }

      await _firestore.collection('rooms').doc(roomId).update(<String, >{
        'isActive': false,
        'closedAt': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      print('Error closing room: $e');
      return false;
    }
  }

  // Get user
  Future<UserModel?> _getUser(String userId) async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return UserModel.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Get room categories
  static List<String> getCategories() {
    return <String>[
      'All',
      'Chat',
      'Music',
      'Games',
      'Dating',
      'Study',
      'Work',
      'Friends',
      'Party',
      'Chill',
    ];
  }
}