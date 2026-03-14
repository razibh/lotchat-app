import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../../chat/models/room_model.dart';
import '../di/service_locator.dart';  // 🟢 এই import টি যোগ করুন
import 'socket_service.dart';
import 'notification_service.dart';

class PKService {

  PKService() {
    _initializeServices();
  }
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late final NotificationService _notificationService;
  late final SocketService _socketService;

  final Map<String, Timer> _battleTimers = <String, Timer>{};

  void _initializeServices() {
    try {
      _notificationService = ServiceLocator.instance.get<NotificationService>();
      _socketService = ServiceLocator.instance.get<SocketService>();
      debugPrint('✅ PKService services initialized');
    } catch (e) {
      debugPrint('❌ Error initializing services in PKService: $e');
    }
  }
  Future<void> initialize() async {
    try {
      debugPrint('📝 PKService initializing...');
      _cancelAllTimers();
      await _restoreActiveBattles();
      debugPrint('✅ PKService initialized successfully');
    } catch (e) {
      debugPrint('❌ PKService initialization error: $e');
    }
  }

  Future<void> _restoreActiveBattles() async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
          .collection('pk_battles')
          .where('status', isEqualTo: 'active')
          .get();

      for (QueryDocumentSnapshot<Map<String, dynamic>> doc in snapshot.docs) {
        final PKBattle battle = PKBattle.fromJson(doc.data()..['id'] = doc.id);
        final Duration timeLeft = battle.endTime.difference(DateTime.now());

        if (timeLeft.isNegative) {
          _endBattle(battle.id);
        } else {
          _startBattleTimer(battle.id, timeLeft);
        }
      }
      debugPrint('   ✅ Restored ${snapshot.docs.length} active battles');
    } catch (e) {
      debugPrint('   ⚠️ Error restoring battles: $e');
    }
  }

  void _startBattleTimer(String battleId, Duration duration) {
    _battleTimers[battleId] = Timer(duration, () {
      _endBattle(battleId);
      _battleTimers.remove(battleId);
    });
  }

  void _cancelAllTimers() {
    for (Timer timer in _battleTimers.values) {
      timer.cancel();
    }
    _battleTimers.clear();
  }

  Future<PKBattle?> startBattle({
    required String room1Id,
    required String room2Id,
    int durationMinutes = 5,
  }) async {
    final User? user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    try {
      debugPrint('📝 Starting PK battle between $room1Id and $room2Id');

      final RoomModel? room1 = await _getRoom(room1Id);
      final RoomModel? room2 = await _getRoom(room2Id);

      if (room1 == null || room2 == null) {
        throw Exception('Room not found');
      }

      if ((room1.isPKActive ?? false) || (room2.isPKActive ?? false)) {
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

      final DocumentReference<Map<String, dynamic>> docRef = await _firestore.collection('pk_battles').add(battle.toJson());
      debugPrint('   ✅ Battle created with ID: ${docRef.id}');

      await _firestore.collection('rooms').doc(room1Id).update(<Object, Object?>{
        'currentPK': docRef.id,
        'isPKActive': true,
      });

      await _firestore.collection('rooms').doc(room2Id).update(<Object, Object?>{
        'currentPK': docRef.id,
        'isPKActive': true,
      });

      _startBattleTimer(docRef.id, Duration(minutes: durationMinutes));

      try {
        _socketService.emit('pk-started', <String, dynamic>{
          'battleId': docRef.id,
          'room1Id': room1Id,
          'room2Id': room2Id,
          'endTime': battle.endTime.toIso8601String(),
        });
      } catch (e) {
        debugPrint('⚠️ Socket emit error: $e');
      }

      return battle.copyWith(id: docRef.id);
    } catch (e) {
      debugPrint('❌ Error starting PK battle: $e');
      return null;
    }
  }

  Future<PKBattle?> getBattle(String battleId) async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> doc = await _firestore.collection('pk_battles').doc(battleId).get();
      if (doc.exists) {
        final Map<String, dynamic> data = doc.data()!;
        data['id'] = doc.id;
        return PKBattle.fromJson(data);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting battle: $e');
      return null;
    }
  }

  Stream<PKBattle?> streamBattle(String battleId) {
    return _firestore
        .collection('pk_battles')
        .doc(battleId)
        .snapshots()
        .map((DocumentSnapshot<Map<String, dynamic>> doc) {
      if (doc.exists) {
        final Map<String, dynamic> data = doc.data()!;
        data['id'] = doc.id;
        return PKBattle.fromJson(data);
      }
      return null;
    });
  }

  Future<void> updateScore({
    required String battleId,
    required String roomId,
    required int points,
  }) async {
    try {
      final DocumentReference<Map<String, dynamic>> battleRef = _firestore.collection('pk_battles').doc(battleId);

      await _firestore.runTransaction((Transaction transaction) async {
        final DocumentSnapshot<Map<String, dynamic>> battleDoc = await transaction.get(battleRef);
        if (!battleDoc.exists) throw Exception('Battle not found');

        final Map<String, dynamic> data = battleDoc.data()!;
        data['id'] = battleDoc.id;
        final PKBattle battle = PKBattle.fromJson(data);

        if (battle.status != 'active') {
          throw Exception('Battle is not active');
        }

        if (DateTime.now().isAfter(battle.endTime)) {
          throw Exception('Battle has ended');
        }

        if (roomId == battle.room1Id) {
          transaction.update(battleRef, <String, dynamic>{
            'room1Score': FieldValue.increment(points),
          });
        } else if (roomId == battle.room2Id) {
          transaction.update(battleRef, <String, dynamic>{
            'room2Score': FieldValue.increment(points),
          });
        } else {
          throw Exception('Room not in this battle');
        }
      });

      try {
        _socketService.emit('pk-score-updated', <String, dynamic>{
          'battleId': battleId,
          'roomId': roomId,
          'points': points,
        });
      } catch (e) {
        debugPrint('⚠️ Socket emit error: $e');
      }
    } catch (e) {
      debugPrint('Error updating PK score: $e');
    }
  }

  Future<PKBattle?> _endBattle(String battleId) async {
    try {
      debugPrint('📝 Ending battle: $battleId');
      final DocumentReference<Map<String, dynamic>> battleRef = _firestore.collection('pk_battles').doc(battleId);

      final PKBattle? result = await _firestore.runTransaction((Transaction transaction) async {
        final DocumentSnapshot<Map<String, dynamic>> battleDoc = await transaction.get(battleRef);
        if (!battleDoc.exists) throw Exception('Battle not found');

        final Map<String, dynamic> data = battleDoc.data()!;
        data['id'] = battleDoc.id;
        final PKBattle battle = PKBattle.fromJson(data);

        if (battle.status != 'active') {
          return null;
        }

        String? winnerId;
        if (battle.room1Score > battle.room2Score) {
          winnerId = battle.room1Id;
        } else if (battle.room2Score > battle.room1Score) {
          winnerId = battle.room2Id;
        }

        transaction.update(battleRef, <String, dynamic>{
          'status': 'ended',
          'winnerId': winnerId,
          'endedAt': FieldValue.serverTimestamp(),
        });

        transaction.update(
          _firestore.collection('rooms').doc(battle.room1Id),
          <String, dynamic>{'isPKActive': false, 'currentPK': null},
        );

        transaction.update(
          _firestore.collection('rooms').doc(battle.room2Id),
          <String, dynamic>{'isPKActive': false, 'currentPK': null},
        );

        if (winnerId != null) {
          await _awardWinner(battle, winnerId, transaction);
        }

        return battle;
      });

      if (result != null) {
        debugPrint('   ✅ Battle ended, winner: ${result.winnerId ?? 'Tie'}');
        _battleTimers.remove(battleId);

        try {
          _socketService.emit('pk-ended', <String, dynamic>{
            'battleId': battleId,
            'winnerId': result.winnerId,
            'room1Score': result.room1Score,
            'room2Score': result.room2Score,
          });
        } catch (e) {
          debugPrint('⚠️ Socket emit error: $e');
        }

        await _notifyBattleEnd(result);
      }

      return result;
    } catch (e) {
      debugPrint('❌ Error ending PK battle: $e');
      return null;
    }
  }

  Future<void> _awardWinner(
      PKBattle battle,
      String winnerId,
      Transaction transaction,
      ) async {
    try {
      final int totalScore = battle.room1Score + battle.room2Score;
      final int reward = totalScore * 10;

      final DocumentSnapshot<Map<String, dynamic>> roomDoc = await transaction.get(
          _firestore.collection('rooms').doc(winnerId),
      );

      if (roomDoc.exists) {
        final Map<String, dynamic> roomData = roomDoc.data()!;
        roomData['id'] = roomDoc.id;
        final RoomModel room = RoomModel.fromJson(roomData);

        transaction.update(
          _firestore.collection('users').doc(room.hostId),
          <String, dynamic>{'coins': FieldValue.increment(reward)},
        );

        final List<Map<String, dynamic>> topGifters = await _getTopGifters(battle.id);
        for (Map<String, dynamic> gifter in topGifters.take(3)) {
          transaction.update(
            _firestore.collection('users').doc(gifter['userId']),
            <String, dynamic>{'coins': FieldValue.increment(reward ~/ 2)},
          );
        }
      }
    } catch (e) {
      debugPrint('Error awarding winner: $e');
    }
  }

  Future<List<Map<String, dynamic>>> _getTopGifters(String battleId) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
          .collection('gift_transactions')
          .where('battleId', isEqualTo: battleId)
          .orderBy('totalPrice', descending: true)
          .limit(10)
          .get();

      final List<Map<String, dynamic>> gifters = <Map<String, dynamic>>[];
      final Set<String> seenIds = <String>{};

      for (final QueryDocumentSnapshot<Map<String, dynamic>> doc in snapshot.docs) {
        final Map<String, dynamic> data = doc.data();
        final String senderId = data['senderId'] as String? ?? '';

        if (senderId.isNotEmpty && !seenIds.contains(senderId)) {
          seenIds.add(senderId);

          final DocumentSnapshot<Map<String, dynamic>> userDoc = await _firestore
              .collection('users')
              .doc(senderId)
              .get();

          gifters.add(<String, dynamic>{
            'userId': senderId,
            'name': userDoc.data()?['username'] ?? data['senderName'] ?? 'Unknown',
            'avatar': userDoc.data()?['photoURL'],
            'gifts': data['amount'] ?? 0,
            'total': data['totalPrice'] ?? 0,
          });
        }
      }

      return gifters;
    } catch (e) {
      debugPrint('Error getting top gifters: $e');
      return <Map<String, dynamic>>[];
    }
  }

  Future<void> _notifyBattleEnd(PKBattle battle) async {
    try {
      final RoomModel? room1 = await _getRoom(battle.room1Id);
      final RoomModel? room2 = await _getRoom(battle.room2Id);

      if (room1 == null || room2 == null) return;

      for (final Seat seat in room1.seats) {
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

      for (final Seat seat in room2.seats) {
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
    } catch (e) {
      debugPrint('Error notifying battle end: $e');
    }
  }

  Future<RoomModel?> _getRoom(String roomId) async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> doc = await _firestore.collection('rooms').doc(roomId).get();
      if (doc.exists) {
        final Map<String, dynamic> data = doc.data()!;
        data['id'] = doc.id;
        return RoomModel.fromJson(data);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting room: $e');
      return null;
    }
  }

  Stream<List<PKBattle>> getActiveBattles() {
    return _firestore
        .collection('pk_battles')
        .where('status', isEqualTo: 'active')
        .orderBy('startTime', descending: true)
        .snapshots()
        .map((QuerySnapshot<Map<String, dynamic>> snapshot) => snapshot.docs
        .map((QueryDocumentSnapshot<Map<String, dynamic>> doc) {
      final Map<String, dynamic> data = doc.data();
      data['id'] = doc.id;
      return PKBattle.fromJson(data);
    })
        .toList(),);
  }

  Stream<List<PKBattle>> getBattleHistory(String userId) {
    return _firestore
        .collection('pk_battles')
        .where('status', isEqualTo: 'ended')
        .orderBy('endTime', descending: true)
        .limit(50)
        .snapshots()
        .map((QuerySnapshot<Map<String, dynamic>> snapshot) => snapshot.docs
        .map((QueryDocumentSnapshot<Map<String, dynamic>> doc) {
      final Map<String, dynamic> data = doc.data();
      data['id'] = doc.id;
      return PKBattle.fromJson(data);
    })
        .toList(),);
  }

  Future<Map<String, dynamic>> getBattleStats(String userId) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> battles = await _firestore
          .collection('pk_battles')
          .where(Filter.or(
        Filter('room1Id', isEqualTo: userId),
        Filter('room2Id', isEqualTo: userId),
      ),)
          .where('status', isEqualTo: 'ended')
          .get();

      var wins = 0;
      var losses = 0;
      var totalScore = 0;

      for (final QueryDocumentSnapshot<Map<String, dynamic>> doc in battles.docs) {
        final Map<String, dynamic> data = doc.data();
        data['id'] = doc.id;
        final PKBattle battle = PKBattle.fromJson(data);

        if (battle.winnerId == userId) {
          wins++;
        } else if (battle.winnerId != null) {
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
        'winRate': battles.docs.isNotEmpty
            ? (wins / battles.docs.length * 100).round()
            : 0,
        'totalScore': totalScore,
        'averageScore': battles.docs.isNotEmpty
            ? (totalScore / battles.docs.length).round()
            : 0,
      };
    } catch (e) {
      debugPrint('Error getting battle stats: $e');
      return <String, dynamic>{};
    }
  }

  Future<void> dispose() async {
    debugPrint('🗑️ Disposing PKService...');
    try {
      _cancelAllTimers();
      _battleTimers.clear();
      debugPrint('✅ PKService disposed successfully');
    } catch (e) {
      debugPrint('❌ Error disposing PKService: $e');
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
    required this.createdBy,
    this.winnerId,
    this.endedAt,
  });

  factory PKBattle.fromJson(Map<String, dynamic> json) {
    return PKBattle(
      id: json['id'] as String? ?? '',
      room1Id: json['room1Id'] as String? ?? '',
      room2Id: json['room2Id'] as String? ?? '',
      room1Name: json['room1Name'] as String? ?? '',
      room2Name: json['room2Name'] as String? ?? '',
      room1Score: json['room1Score'] as int? ?? 0,
      room2Score: json['room2Score'] as int? ?? 0,
      startTime: json['startTime'] != null
          ? (json['startTime'] as Timestamp).toDate()
          : DateTime.now(),
      endTime: json['endTime'] != null
          ? (json['endTime'] as Timestamp).toDate()
          : DateTime.now(),
      status: json['status'] as String? ?? 'active',
      winnerId: json['winnerId'] as String?,
      createdBy: json['createdBy'] as String? ?? '',
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
  String status;
  String? winnerId;
  final String createdBy;
  DateTime? endedAt;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
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
  }

  PKBattle copyWith({
    String? id,
    int? room1Score,
    int? room2Score,
    String? status,
    String? winnerId,
    DateTime? endedAt,
  }) {
    return PKBattle(
      id: id ?? this.id,
      room1Id: room1Id,
      room2Id: room2Id,
      room1Name: room1Name,
      room2Name: room2Name,
      room1Score: room1Score ?? this.room1Score,
      room2Score: room2Score ?? this.room2Score,
      startTime: startTime,
      endTime: endTime,
      status: status ?? this.status,
      winnerId: winnerId ?? this.winnerId,
      createdBy: createdBy,
      endedAt: endedAt ?? this.endedAt,
    );
  }
}