import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/room_model.dart';
import '../models/user_models.dart' as app;
import '../models/seat_model.dart';
import '../di/service_locator.dart';
import 'notification_service.dart';

class RoomService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late final NotificationService _notificationService;

  RoomService() {
    _initializeServices();
  }

  void _initializeServices() {
    try {
      _notificationService = ServiceLocator.instance.get<NotificationService>();
    } catch (e) {
      debugPrint('Error initializing services: $e');
    }
  }

  // 🟢 NEW: Get rooms by country
  Future<List<RoomModel>> getRooms(String country) async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot;

      if (country == 'All') {
        snapshot = await _firestore
            .collection('rooms')
            .where('status', isEqualTo: 'active')
            .orderBy('viewerCount', descending: true)
            .limit(50)
            .get();
      } else {
        snapshot = await _firestore
            .collection('rooms')
            .where('country', isEqualTo: country)
            .where('status', isEqualTo: 'active')
            .orderBy('viewerCount', descending: true)
            .limit(50)
            .get();
      }

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return RoomModel.fromJson(data);
      }).toList();
    } catch (e) {
      debugPrint('Error getting rooms: $e');
      return _getMockRooms();
    }
  }

  // 🟢 NEW: Update viewer count
  Future<void> updateViewerCount(String roomId, int count) async {
    try {
      await _firestore.collection('rooms').doc(roomId).update({
        'viewerCount': count,
      });
    } catch (e) {
      debugPrint('Error updating viewer count: $e');
    }
  }

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
    final User? firebaseUser = _auth.currentUser;
    if (firebaseUser == null) throw Exception('User not logged in');

    try {
      final RoomModel room = RoomModel(
        id: '',
        name: name,
        hostId: firebaseUser.uid,
        hostName: firebaseUser.displayName ?? 'User',
        hostAvatar: firebaseUser.photoURL,
        category: category,
        description: description,
        coverImage: coverImage,
        viewerCount: 0,
        maxSeats: maxSeats,
        seats: List.generate(maxSeats, (int index) => SeatModel(
          seatNumber: index + 1,
          isEmpty: true,
        )),
        isPrivate: isPrivate,
        pinCode: pinCode,
        createdAt: DateTime.now(),
        status: RoomStatus.active,
      );

      final DocumentReference<Map<String, dynamic>> docRef = await _firestore.collection('rooms').add(room.toJson());
      return room.copyWith(id: docRef.id);
    } catch (e) {
      debugPrint('Error creating room: $e');
      return null;
    }
  }

  // Get room
  Future<RoomModel?> getRoom(String roomId) async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> doc = await _firestore.collection('rooms').doc(roomId).get();
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

  // Stream room
  Stream<RoomModel?> streamRoom(String roomId) {
    return _firestore
        .collection('rooms')
        .doc(roomId)
        .snapshots()
        .map((DocumentSnapshot<Map<String, dynamic>> doc) {
      if (doc.exists) {
        final data = doc.data()!;
        data['id'] = doc.id;
        return RoomModel.fromJson(data);
      }
      return null;
    });
  }

  // Get active rooms
  Stream<List<RoomModel>> getActiveRooms({String? category, String? country}) {
    Query<Map<String, dynamic>> query = _firestore
        .collection('rooms')
        .where('status', isEqualTo: 'active')
        .orderBy('viewerCount', descending: true);

    if (category != null && category != 'All') {
      query = query.where('category', isEqualTo: category);
    }

    if (country != null && country != 'All') {
      query = query.where('country', isEqualTo: country);
    }

    return query.snapshots().map((QuerySnapshot<Map<String, dynamic>> snapshot) => snapshot.docs
        .map((QueryDocumentSnapshot<Map<String, dynamic>> doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return RoomModel.fromJson(data);
    }).toList());
  }

  // Get recommended rooms
  Future<List<RoomModel>> getRecommendedRooms(String userId, {int limit = 10}) async {
    try {
      final app.User? user = await _getUser(userId);
      if (user == null) return [];

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
          .where('status', isEqualTo: 'active')
          .limit(50)
          .get();

      final rooms = roomsSnapshot.docs
          .map((QueryDocumentSnapshot<Map<String, dynamic>> doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return RoomModel.fromJson(data);
      })
          .where((RoomModel r) => !visitedRoomIds.contains(r.id))
          .toList();

      // Score rooms
      final List<Map<String, dynamic>> scoredRooms = rooms.map((RoomModel room) {
        double score = 0;

        // Popularity
        score += (room.viewerCount / 100).clamp(0, 30).toDouble();

        // Freshness
        final int ageHours = DateTime.now().difference(room.createdAt).inHours;
        score += (24 - ageHours).clamp(0, 20).toDouble();

        return {'room': room, 'score': score};
      }).toList();

      // Sort by score
      scoredRooms.sort((Map<String, dynamic> a, Map<String, dynamic> b) => b['score'].compareTo(a['score']));

      return scoredRooms.take(limit).map((Map<String, dynamic> item) => item['room'] as RoomModel).toList();
    } catch (e) {
      debugPrint('Error getting recommended rooms: $e');
      return [];
    }
  }

  // Update room
  Future<bool> updateRoom(String roomId, Map<String, dynamic> updates) async {
    final User? firebaseUser = _auth.currentUser;
    if (firebaseUser == null) throw Exception('User not logged in');

    try {
      final RoomModel? room = await getRoom(roomId);
      if (room == null) throw Exception('Room not found');

      // Check if user is host or moderator
      if (room.hostId != firebaseUser.uid && !room.moderators.contains(firebaseUser.uid)) {
        throw Exception('Not authorized');
      }

      await _firestore.collection('rooms').doc(roomId).update(updates);
      return true;
    } catch (e) {
      debugPrint('Error updating room: $e');
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

        if (room.status != RoomStatus.active) throw Exception('Room is not active');

        // Add to viewer count
        transaction.update(roomRef, {
          'viewerCount': FieldValue.increment(1),
        });

        // Add to room history
        transaction.set(
          _firestore.collection('room_history').doc(),
          {
            'roomId': roomId,
            'userId': userId,
            'timestamp': FieldValue.serverTimestamp(),
          },
        );
      });

      return true;
    } catch (e) {
      debugPrint('Error joining room: $e');
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

        transaction.update(roomRef, {
          'viewerCount': FieldValue.increment(-1),
        });
      });

      return true;
    } catch (e) {
      debugPrint('Error leaving room: $e');
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

        transaction.update(roomRef, {'seats': updatedSeats.map((s) => s.toJson()).toList()});
      });

      return true;
    } catch (e) {
      debugPrint('Error taking seat: $e');
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

        transaction.update(roomRef, {'seats': updatedSeats.map((s) => s.toJson()).toList()});
      });

      return true;
    } catch (e) {
      debugPrint('Error leaving seat: $e');
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
          if (s.seatNumber == seatNumber && s.userId != null) {
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

        transaction.update(roomRef, {'seats': updatedSeats.map((s) => s.toJson()).toList()});
      });

      return true;
    } catch (e) {
      debugPrint('Error toggling mute: $e');
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
          if (s.seatNumber == seatNumber && s.userId != null) {
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

        transaction.update(roomRef, {'seats': updatedSeats.map((s) => s.toJson()).toList()});
      });

      return true;
    } catch (e) {
      debugPrint('Error updating speaking status: $e');
      return false;
    }
  }

  // Close room
  Future<bool> closeRoom(String roomId) async {
    final User? firebaseUser = _auth.currentUser;
    if (firebaseUser == null) throw Exception('User not logged in');

    try {
      final RoomModel? room = await getRoom(roomId);
      if (room == null) throw Exception('Room not found');

      if (room.hostId != firebaseUser.uid) {
        throw Exception('Only host can close the room');
      }

      await _firestore.collection('rooms').doc(roomId).update({
        'status': 'ended',
        'closedAt': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      debugPrint('Error closing room: $e');
      return false;
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

  // Mock rooms for testing
  List<RoomModel> _getMockRooms() {
    return List.generate(5, (index) {
      return RoomModel(
        id: 'room_$index',
        name: 'Room ${index + 1}',
        hostId: 'host_$index',
        hostName: 'Host ${index + 1}',
        category: 'Chat',
        createdAt: DateTime.now().subtract(Duration(hours: index)),
        viewerCount: 100 + (index * 50),
        maxSeats: 9,
        seats: List.generate(9, (i) => SeatModel(
          seatNumber: i + 1,
          isEmpty: true,
        )),
        isPKActive: false,
        isPrivate: false,
        status: RoomStatus.active,
      );
    });
  }

  // Get room categories
  static List<String> getCategories() {
    return [
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