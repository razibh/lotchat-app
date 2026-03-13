import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/room_model.dart';
import '../di/service_locator.dart';
import 'notification_service.dart';
import 'socket_service.dart';

class PKService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final NotificationService _notificationService = ServiceLocator().get<NotificationService>();
  final SocketService _socketService = ServiceLocator().get<SocketService>();

  // Start PK battle
  Future<PKBattle?> startBattle({
    required String room1Id,
    required String room2Id,
    int durationMinutes = 5,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    try {
      // Check if rooms exist
      final RoomModel? room1 = await _getRoom(room1Id);
      final RoomModel? room2 = await _getRoom(room2Id);
      
      if (room1 == null || room2 == null) {
        throw Exception('Room not found');
      }

      // Check if rooms are already in battle
      if (room1.isPKActive || room2.isPKActive) {
        throw Exception('One of the rooms is already in a battle');
      }

      final PKBattle battle = PKBattle(
        id: '',
        room1Id: room1Id,
        room2Id: room2Id,
        room1Name: room1.name,
        room2Name: room2.name,
        room1Score: 0,
        room2Score: 0,
        startTime: DateTime.now(),
        endTime: DateTime.now().add(Duration(minutes: durationMinutes)),
        status: 'active',
        createdBy: user.uid,
      );

      final docRef = await _firestore.collection('pk_battles').add(battle.toJson());

      // Update rooms
      await _firestore.collection('rooms').doc(room1Id).update(<String, >{
        'currentPK': docRef.id,
        'isPKActive': true,
      });

      await _firestore.collection('rooms').doc(room2Id).update(<String, >{
        'currentPK': docRef.id,
        'isPKActive': true,
      });

      // Notify rooms via socket
      _socketService.emit('pk-started', <String, >{
        'battleId': docRef.id,
        'room1Id': room1Id,
        'room2Id': room2Id,
        'endTime': battle.endTime.toIso8601String(),
      });

      // Start timer to end battle
      Timer(battle.endTime.difference(DateTime.now()), () {
        _endBattle(docRef.id);
      });

      return battle.copyWith(id: docRef.id);
    } catch (e) {
      print('Error starting PK battle: $e');
      return null;
    }
  }

  // Get battle
  Future<PKBattle?> getBattle(String battleId) async {
    try {
      final doc = await _firestore.collection('pk_battles').doc(battleId).get();
      if (doc.exists) {
        return PKBattle.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      print('Error getting battle: $e');
      return null;
    }
  }

  // Stream battle
  Stream<PKBattle?> streamBattle(String battleId) {
    return _firestore
        .collection('pk_battles')
        .doc(battleId)
        .snapshots()
        .map((doc) => doc.exists ? PKBattle.fromJson(doc.data()!) : null);
  }

  // Update score
  Future<void> updateScore({
    required String battleId,
    required String roomId,
    required int points,
  }) async {
    try {
      final battleRef = _firestore.collection('pk_battles').doc(battleId);
      
      await _firestore.runTransaction((transaction) async {
        final battleDoc = await transaction.get(battleRef);
        if (!battleDoc.exists) throw Exception('Battle not found');

        final PKBattle battle = PKBattle.fromJson(battleDoc.data()!);
        
        if (battle.status != 'active') {
          throw Exception('Battle is not active');
        }

        if (DateTime.now().isAfter(battle.endTime)) {
          throw Exception('Battle has ended');
        }

        if (roomId == battle.room1Id) {
          transaction.update(battleRef, <String, >{
            'room1Score': FieldValue.increment(points),
          });
        } else if (roomId == battle.room2Id) {
          transaction.update(battleRef, <String, >{
            'room2Score': FieldValue.increment(points),
          });
        } else {
          throw Exception('Room not in this battle');
        }
      });

      // Notify via socket
      _socketService.emit('pk-score-updated', <String, Object>{
        'battleId': battleId,
        'roomId': roomId,
        'points': points,
      });
    } catch (e) {
      print('Error updating PK score: $e');
    }
  }

  // End battle
  Future<PKBattle?> _endBattle(String battleId) async {
    try {
      final battleRef = _firestore.collection('pk_battles').doc(battleId);
      
      final result = await _firestore.runTransaction((transaction) async {
        final battleDoc = await transaction.get(battleRef);
        if (!battleDoc.exists) throw Exception('Battle not found');

        final PKBattle battle = PKBattle.fromJson(battleDoc.data()!);
        
        if (battle.status != 'active') {
          return null;
        }

        // Determine winner
        String? winnerId;
        if (battle.room1Score > battle.room2Score) {
          winnerId = battle.room1Id;
        } else if (battle.room2Score > battle.room1Score) {
          winnerId = battle.room2Id;
        }

        // Update battle
        transaction.update(battleRef, <String, >{
          'status': 'ended',
          'winnerId': winnerId,
          'endedAt': FieldValue.serverTimestamp(),
        });

        // Update rooms
        transaction.update(
          _firestore.collection('rooms').doc(battle.room1Id),
          <String, bool?>{'isPKActive': false, 'currentPK': null},
        );

        transaction.update(
          _firestore.collection('rooms').doc(battle.room2Id),
          <String, bool?>{'isPKActive': false, 'currentPK': null},
        );

        // Award winners
        if (winnerId != null) {
          await _awardWinner(battle, winnerId, transaction);
        }

        return battle;
      });

      if (result != null) {
        // Notify via socket
        _socketService.emit('pk-ended', <String, >{
          'battleId': battleId,
          'winnerId': result.winnerId,
          'room1Score': result.room1Score,
          'room2Score': result.room2Score,
        });

        // Send notifications
        await _notifyBattleEnd(result);
      }

      return result;
    } catch (e) {
      print('Error ending PK battle: $e');
      return null;
    }
  }

  // Award winner
  Future<void> _awardWinner(
    PKBattle battle,
    String winnerId,
    Transaction transaction,
  ) async {
    // Calculate rewards
    final int totalScore = battle.room1Score + battle.room2Score;
    final int reward = totalScore * 10; // Example: 10 coins per point

    // Get room participants
    final roomDoc = await transaction.get(
      _firestore.collection('rooms').doc(winnerId)
    );
    
    if (roomDoc.exists) {
      final room = RoomModel.fromJson(roomDoc.data()!);
      
      // Award to host
      transaction.update(
        _firestore.collection('users').doc(room.hostId),
        <String, >{'coins': FieldValue.increment(reward)},
      );

      // Award to top gifters
      final List<Map<String, dynamic>> topGifters = await _getTopGifters(battle.id);
      for (Map<String, dynamic> gifter in topGifters.take(3)) {
        transaction.update(
          _firestore.collection('users').doc(gifter['userId']),
          <String, >{'coins': FieldValue.increment(reward ~/ 2)},
        );
      }
    }
  }

  // Get top gifters in battle
  Future<List<Map<String, dynamic>>> _getTopGifters(String battleId) async {
    try {
      final snapshot = await _firestore
          .collection('gift_transactions')
          .where('battleId', isEqualTo: battleId)
          .orderBy('totalPrice', descending: true)
          .limit(10)
          .get();

      final List<Map<String, dynamic>> gifters = <Map<String, dynamic>>[];
      final Set<String> seenIds = <String>{};

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final senderId = data['senderId'];
        
        if (!seenIds.contains(senderId)) {
          seenIds.add(senderId);
          
          final userDoc = await _firestore
              .collection('users')
              .doc(senderId)
              .get();
          
          gifters.add(<String, dynamic>{
            'userId': senderId,
            'name': userDoc.data()?['username'] ?? data['senderName'],
            'avatar': userDoc.data()?['photoURL'],
            'gifts': data['amount'],
            'total': data['totalPrice'],
          });
        }
      }

      return gifters;
    } catch (e) {
      return <Map<String, dynamic>>[];
    }
  }

  // Notify battle end
  Future<void> _notifyBattleEnd(PKBattle battle) async {
    // Get room participants
    final RoomModel? room1 = await _getRoom(battle.room1Id);
    final RoomModel? room2 = await _getRoom(battle.room2Id);
    
    if (room1 == null || room2 == null) return;

    final RoomModel winner = battle.winnerId == battle.room1Id ? room1 : room2;
    final RoomModel loser = battle.winnerId == battle.room1Id ? room2 : room1;

    // Notify all participants in room1
    for (final seat in room1.seats) {
      if (seat.userId != null) {
        await _notificationService.sendNotification(
          userId: seat.userId!,
          type: 'pk',
          title: battle.winnerId == battle.room1Id ? 'Victory! 🏆' : 'Defeat 😢',
          body: battle.winnerId == battle.room1Id
              ? 'Your room won the PK battle!'
              : 'Your room lost the PK battle',
          data: <String, String>{'battleId': battle.id},
        );
      }
    }

    // Notify all participants in room2
    for (final seat in room2.seats) {
      if (seat.userId != null) {
        await _notificationService.sendNotification(
          userId: seat.userId!,
          type: 'pk',
          title: battle.winnerId == battle.room2Id ? 'Victory! 🏆' : 'Defeat 😢',
          body: battle.winnerId == battle.room2Id
              ? 'Your room won the PK battle!'
              : 'Your room lost the PK battle',
          data: <String, String>{'battleId': battle.id},
        );
      }
    }
  }

  // Get room
  Future<RoomModel?> _getRoom(String roomId) async {
    try {
      final doc = await _firestore.collection('rooms').doc(roomId).get();
      if (doc.exists) {
        return RoomModel.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Get active battles
  Stream<List<PKBattle>> getActiveBattles() {
    return _firestore
        .collection('pk_battles')
        .where('status', isEqualTo: 'active')
        .orderBy('startTime', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PKBattle.fromJson(doc.data()))
            .toList());
  }

  // Get battle history
  Stream<List<PKBattle>> getBattleHistory(String userId) {
    return _firestore
        .collection('pk_battles')
        .where('status', isEqualTo: 'ended')
        .orderBy('endTime', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PKBattle.fromJson(doc.data()))
            .toList());
  }

  // Get battle stats
  Future<Map<String, dynamic>> getBattleStats(String userId) async {
    try {
      final battles = await _firestore
          .collection('pk_battles')
          .where(Filter.or(
            Filter('room1Id', isEqualTo: userId),
            Filter('room2Id', isEqualTo: userId),
          ))
          .where('status', isEqualTo: 'ended')
          .get();

      var wins = 0;
      var losses = 0;
      var totalScore = 0;

      for (final doc in battles.docs) {
        final PKBattle battle = PKBattle.fromJson(doc.data());
        if (battle.winnerId == userId) {
          wins++;
        } else {
          losses++;
        }
        totalScore += battle.room1Id == userId 
            ? battle.room1Score 
            : battle.room2Score;
      }

      return <String, dynamic>{
        'totalBattles': battles.docs.length,
        'wins': wins,
        'losses': losses,
        'winRate': battles.docs.length > 0 
            ? (wins / battles.docs.length * 100).round() 
            : 0,
        'totalScore': totalScore,
        'averageScore': battles.docs.length > 0
            ? (totalScore / battles.docs.length).round()
            : 0,
      };
    } catch (e) {
      return <String, dynamic>{};
    }
  }
}

class PKBattle {

  PKBattle({
    required this.id,
    required this.room1Id,
    required this.room2Id,
    required this.room1Name,
    required this.room2Name,
    required this.room1Score,
    required this.room2Score,
    required this.startTime,
    required this.endTime,
    required this.status,
    this.winnerId,
    required this.createdBy,
    this.endedAt,
  });

  factory PKBattle.fromJson(Map<String, dynamic> json) {
    return PKBattle(
      id: json['id'],
      room1Id: json['room1Id'],
      room2Id: json['room2Id'],
      room1Name: json['room1Name'],
      room2Name: json['room2Name'],
      room1Score: json['room1Score'],
      room2Score: json['room2Score'],
      startTime: (json['startTime'] as Timestamp).toDate(),
      endTime: (json['endTime'] as Timestamp).toDate(),
      status: json['status'],
      winnerId: json['winnerId'],
      createdBy: json['createdBy'],
      endedAt: json['endedAt'] != null 
          ? (json['endedAt'] as Timestamp).toDate() 
          : null,
    );
  }
  final String id;
  final String room1Id;
  final String room2Id;
  final String room1Name;
  final String room2Name;
  int room1Score;
  int room2Score;
  final DateTime startTime;
  final DateTime endTime;
  String status; // 'active', 'ended'
  String? winnerId;
  final String createdBy;
  DateTime? endedAt;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'room1Id': room1Id,
    'room2Id': room2Id,
    'room1Name': room1Name,
    'room2Name': room2Name,
    'room1Score': room1Score,
    'room2Score': room2Score,
    'startTime': Timestamp.fromDate(startTime),
    'endTime': Timestamp.fromDate(endTime),
    'status': status,
    'winnerId': winnerId,
    'createdBy': createdBy,
    'endedAt': endedAt != null ? Timestamp.fromDate(endedAt!) : null,
  };

  PKBattle copyWith({String? id}) {
    return PKBattle(
      id: id ?? this.id,
      room1Id: room1Id,
      room2Id: room2Id,
      room1Name: room1Name,
      room2Name: room2Name,
      room1Score: room1Score,
      room2Score: room2Score,
      startTime: startTime,
      endTime: endTime,
      status: status,
      winnerId: winnerId,
      createdBy: createdBy,
      endedAt: endedAt,
    );
  }
}