import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/user_models.dart' as app;
import '../di/service_locator.dart';
import 'database_service.dart';
import 'notification_service.dart';

class LuckyDrawService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late final DatabaseService _databaseService;
  late final NotificationService _notificationService;

  LuckyDrawService() {
    _initializeServices();
  }

  void _initializeServices() {
    try {
      _databaseService = ServiceLocator.instance.get<DatabaseService>();
      _notificationService = ServiceLocator.instance.get<NotificationService>();
    } catch (e) {
      debugPrint('Error initializing services: $e');
    }
  }

  // ==================== GET LUCKY DRAWS ====================

  // Get active lucky draws
  Future<List<LuckyDraw>> getActiveDraws() async {
    try {
      final now = DateTime.now();

      final snapshot = await _firestore
          .collection('lucky_draws')
          .where('isActive', isEqualTo: true)
          .where('startTime', isLessThanOrEqualTo: now)
          .where('endTime', isGreaterThanOrEqualTo: now)
          .orderBy('endTime')
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return LuckyDraw.fromJson(data);
      }).toList();
    } catch (e) {
      debugPrint('Error getting active draws: $e');
      return [];
    }
  }

  // Get upcoming lucky draws
  Future<List<LuckyDraw>> getUpcomingDraws() async {
    try {
      final now = DateTime.now();

      final snapshot = await _firestore
          .collection('lucky_draws')
          .where('isActive', isEqualTo: true)
          .where('startTime', isGreaterThan: now)
          .orderBy('startTime')
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return LuckyDraw.fromJson(data);
      }).toList();
    } catch (e) {
      debugPrint('Error getting upcoming draws: $e');
      return [];
    }
  }

  // Get completed lucky draws
  Future<List<LuckyDraw>> getCompletedDraws({int limit = 20}) async {
    try {
      final now = DateTime.now();

      final snapshot = await _firestore
          .collection('lucky_draws')
          .where('endTime', isLessThan: now)
          .orderBy('endTime', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return LuckyDraw.fromJson(data);
      }).toList();
    } catch (e) {
      debugPrint('Error getting completed draws: $e');
      return [];
    }
  }

  // Get lucky draw by ID
  Future<LuckyDraw?> getLuckyDraw(String drawId) async {
    try {
      final doc = await _firestore.collection('lucky_draws').doc(drawId).get();
      if (doc.exists) {
        final data = doc.data()!;
        data['id'] = doc.id;
        return LuckyDraw.fromJson(data);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting lucky draw: $e');
      return null;
    }
  }

  // Stream lucky draw
  Stream<LuckyDraw?> streamLuckyDraw(String drawId) {
    return _firestore
        .collection('lucky_draws')
        .doc(drawId)
        .snapshots()
        .map((doc) {
      if (doc.exists) {
        final data = doc.data()!;
        data['id'] = doc.id;
        return LuckyDraw.fromJson(data);
      }
      return null;
    });
  }

  // ==================== ENTER LUCKY DRAW ====================

  Future<bool> enterDraw(String drawId, {int ticketCount = 1}) async {
    final User? user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    try {
      final drawRef = _firestore.collection('lucky_draws').doc(drawId);

      return await _firestore.runTransaction((transaction) async {
        final drawDoc = await transaction.get(drawRef);
        if (!drawDoc.exists) throw Exception('Lucky draw not found');

        final draw = LuckyDraw.fromJson(drawDoc.data()!..['id'] = drawDoc.id);

        // Check if draw is active
        final now = DateTime.now();
        if (now.isBefore(draw.startTime) || now.isAfter(draw.endTime)) {
          throw Exception('Lucky draw is not active');
        }

        // Check max entries per user
        final userEntryCount = draw.participants.where((p) => p.userId == user.uid).length;
        if (userEntryCount + ticketCount > draw.maxEntriesPerUser) {
          throw Exception('Maximum entries reached for this user');
        }

        // Check total tickets
        if (draw.currentParticipants + ticketCount > draw.maxParticipants) {
          throw Exception('Lucky draw is full');
        }

        // Check if user has enough coins
        final app.User? userData = await _databaseService.getUser(user.uid);
        if (userData == null) throw Exception('User not found');

        final int totalCost = draw.entryFee * ticketCount;
        if (userData.coins < totalCost) {
          throw Exception('Insufficient coins');
        }

        // Deduct coins
        await _databaseService.updateUser(user.uid, {
          'coins': userData.coins - totalCost,
        });

        // Add entries
        final List<LuckyDrawParticipant> newParticipants = [];
        for (int i = 0; i < ticketCount; i++) {
          newParticipants.add(LuckyDrawParticipant(
            userId: user.uid,
            username: user.displayName ?? userData.username,
            avatar: user.photoURL ?? userData.avatar,
            ticketNumber: draw.currentParticipants + i + 1,
            enteredAt: DateTime.now(),
          ));
        }

        final updatedParticipants = [...draw.participants, ...newParticipants];

        transaction.update(drawRef, {
          'participants': updatedParticipants.map((p) => p.toJson()).toList(),
          'currentParticipants': draw.currentParticipants + ticketCount,
        });

        // Record transaction
        await _recordEntryTransaction(
          userId: user.uid,
          drawId: drawId,
          drawName: draw.name,
          ticketCount: ticketCount,
          totalCost: totalCost,
        );

        return true;
      });
    } catch (e) {
      debugPrint('Error entering lucky draw: $e');
      return false;
    }
  }

  Future<void> _recordEntryTransaction({
    required String userId,
    required String drawId,
    required String drawName,
    required int ticketCount,
    required int totalCost,
  }) async {
    try {
      await _firestore.collection('lucky_draw_transactions').add({
        'userId': userId,
        'drawId': drawId,
        'drawName': drawName,
        'ticketCount': ticketCount,
        'totalCost': totalCost,
        'type': 'entry',
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error recording entry transaction: $e');
    }
  }

  // ==================== DRAW WINNER ====================

  Future<LuckyDrawParticipant?> drawWinner(String drawId) async {
    final User? user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    try {
      final drawRef = _firestore.collection('lucky_draws').doc(drawId);

      return await _firestore.runTransaction((transaction) async {
        final drawDoc = await transaction.get(drawRef);
        if (!drawDoc.exists) throw Exception('Lucky draw not found');

        final draw = LuckyDraw.fromJson(drawDoc.data()!..['id'] = drawDoc.id);

        // Check if draw has ended
        final now = DateTime.now();
        if (now.isBefore(draw.endTime)) {
          throw Exception('Lucky draw has not ended yet');
        }

        // Check if winner already drawn
        if (draw.winner != null) {
          throw Exception('Winner already drawn');
        }

        if (draw.participants.isEmpty) {
          throw Exception('No participants in this draw');
        }

        // Select random winner
        final random = Random();
        final winnerIndex = random.nextInt(draw.participants.length);
        final winner = draw.participants[winnerIndex];

        // Update draw with winner
        transaction.update(drawRef, {
          'winner': winner.toJson(),
          'winnerSelectedAt': FieldValue.serverTimestamp(),
          'isActive': false,
        });

        // Award prize
        await _awardPrize(winner.userId, draw.prize);

        // Notify winner
        await _notificationService.sendNotification(
          userId: winner.userId,
          type: 'lucky_draw',
          title: 'Congratulations! 🎉',
          body: 'You won ${draw.prize.name} in ${draw.name}',
          data: {'drawId': drawId, 'prizeId': draw.prize.id},
        );

        // Notify all participants
        await _notifyParticipants(draw, winner);

        return winner;
      });
    } catch (e) {
      debugPrint('Error drawing winner: $e');
      return null;
    }
  }

  Future<void> _awardPrize(String userId, LuckyDrawPrize prize) async {
    try {
      final app.User? user = await _databaseService.getUser(userId);
      if (user == null) return;

      switch (prize.type) {
        case 'coins':
          await _databaseService.updateUser(userId, {
            'coins': user.coins + prize.value,
          });
          break;
        case 'diamonds':
          await _databaseService.updateUser(userId, {
            'diamonds': user.diamonds + prize.value,
          });
          break;
        case 'gift':
        // Award gift logic
          break;
        case 'badge':
        // Award badge logic
          break;
        case 'frame':
        // Award frame logic
          break;
      }
    } catch (e) {
      debugPrint('Error awarding prize: $e');
    }
  }

  Future<void> _notifyParticipants(LuckyDraw draw, LuckyDrawParticipant winner) async {
    try {
      for (var participant in draw.participants) {
        if (participant.userId != winner.userId) {
          await _notificationService.sendNotification(
            userId: participant.userId,
            type: 'lucky_draw',
            title: 'Lucky Draw Result',
            body: '${winner.username} won ${draw.prize.name} in ${draw.name}',
            data: {'drawId': draw.id, 'winnerId': winner.userId},
          );
        }
      }
    } catch (e) {
      debugPrint('Error notifying participants: $e');
    }
  }

  // ==================== USER PARTICIPATION ====================

  Future<List<LuckyDraw>> getUserEntries(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('lucky_draw_transactions')
          .where('userId', isEqualTo: userId)
          .where('type', isEqualTo: 'entry')
          .orderBy('timestamp', descending: true)
          .limit(50)
          .get();

      final drawIds = snapshot.docs.map((doc) => doc.data()['drawId'] as String).toSet();

      final List<LuckyDraw> draws = [];
      for (var drawId in drawIds) {
        final draw = await getLuckyDraw(drawId);
        if (draw != null) {
          draws.add(draw);
        }
      }

      return draws;
    } catch (e) {
      debugPrint('Error getting user entries: $e');
      return [];
    }
  }

  Future<List<LuckyDraw>> getUserWins(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('lucky_draws')
          .where('winner.userId', isEqualTo: userId)
          .orderBy('winnerSelectedAt', descending: true)
          .limit(20)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return LuckyDraw.fromJson(data);
      }).toList();
    } catch (e) {
      debugPrint('Error getting user wins: $e');
      return [];
    }
  }

  // ==================== CREATE LUCKY DRAW (ADMIN) ====================

  Future<String?> createLuckyDraw({
    required String name,
    required String description,
    required DateTime startTime,
    required DateTime endTime,
    required int entryFee,
    required int maxParticipants,
    required int maxEntriesPerUser,
    required LuckyDrawPrize prize,
    String? imageUrl,
  }) async {
    final User? user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    try {
      final draw = LuckyDraw(
        id: '',
        name: name,
        description: description,
        imageUrl: imageUrl,
        startTime: startTime,
        endTime: endTime,
        entryFee: entryFee,
        maxParticipants: maxParticipants,
        maxEntriesPerUser: maxEntriesPerUser,
        currentParticipants: 0,
        participants: [],
        prize: prize,
        isActive: true,
        createdAt: DateTime.now(),
        createdBy: user.uid,
      );

      final docRef = await _firestore.collection('lucky_draws').add(draw.toJson());

      return docRef.id;
    } catch (e) {
      debugPrint('Error creating lucky draw: $e');
      return null;
    }
  }

  // ==================== STATISTICS ====================

  Future<LuckyDrawStats> getLuckyDrawStats(String userId) async {
    try {
      final entries = await _firestore
          .collection('lucky_draw_transactions')
          .where('userId', isEqualTo: userId)
          .where('type', isEqualTo: 'entry')
          .get();

      final wins = await _firestore
          .collection('lucky_draws')
          .where('winner.userId', isEqualTo: userId)
          .get();

      // 🟢 Fix: Convert num to int using .toInt()
      int totalSpent = 0;
      for (var doc in entries.docs) {
        final num value = doc.data()['totalCost'] ?? 0;
        totalSpent += value.toInt();
      }

      // 🟢 Calculate total won
      int totalWon = 0;
      for (var doc in wins.docs) {
        final prizeData = doc.data()['prize'] as Map<String, dynamic>?;
        if (prizeData != null) {
          final prize = LuckyDrawPrize.fromJson(prizeData);
          if (prize.type == 'coins' || prize.type == 'diamonds') {
            totalWon += prize.value;
          }
        }
      }

      // 🟢 Calculate win rate
      double winRate = 0;
      if (entries.docs.length > 0) {
        winRate = wins.docs.length / entries.docs.length;
      }

      return LuckyDrawStats(
        totalEntries: entries.docs.length,
        totalWins: wins.docs.length,
        totalSpent: totalSpent,
        totalWon: totalWon,
        winRate: winRate,
      );
    } catch (e) {
      debugPrint('Error getting lucky draw stats: $e');
      return LuckyDrawStats(
        totalEntries: 0,
        totalWins: 0,
        totalSpent: 0,
        totalWon: 0,
        winRate: 0,
      );
    }
  }
}

// ==================== MODEL CLASSES ====================

class LuckyDraw {
  final String id;
  final String name;
  final String description;
  final String? imageUrl;
  final DateTime startTime;
  final DateTime endTime;
  final int entryFee;
  final int maxParticipants;
  final int maxEntriesPerUser;
  final int currentParticipants;
  final List<LuckyDrawParticipant> participants;
  final LuckyDrawPrize prize;
  final bool isActive;
  final DateTime createdAt;
  final String createdBy;
  final LuckyDrawParticipant? winner;
  final DateTime? winnerSelectedAt;

  LuckyDraw({
    required this.id,
    required this.name,
    required this.description,
    this.imageUrl,
    required this.startTime,
    required this.endTime,
    required this.entryFee,
    required this.maxParticipants,
    required this.maxEntriesPerUser,
    required this.currentParticipants,
    required this.participants,
    required this.prize,
    required this.isActive,
    required this.createdAt,
    required this.createdBy,
    this.winner,
    this.winnerSelectedAt,
  });

  factory LuckyDraw.fromJson(Map<String, dynamic> json) {
    return LuckyDraw(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'],
      startTime: json['startTime'] != null
          ? (json['startTime'] as Timestamp).toDate()
          : DateTime.now(),
      endTime: json['endTime'] != null
          ? (json['endTime'] as Timestamp).toDate()
          : DateTime.now(),
      entryFee: json['entryFee'] ?? 0,
      maxParticipants: json['maxParticipants'] ?? 0,
      maxEntriesPerUser: json['maxEntriesPerUser'] ?? 1,
      currentParticipants: json['currentParticipants'] ?? 0,
      participants: (json['participants'] as List? ?? [])
          .map((p) => LuckyDrawParticipant.fromJson(p))
          .toList(),
      prize: LuckyDrawPrize.fromJson(json['prize'] ?? {}),
      isActive: json['isActive'] ?? true,
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      createdBy: json['createdBy'] ?? '',
      winner: json['winner'] != null
          ? LuckyDrawParticipant.fromJson(json['winner'])
          : null,
      winnerSelectedAt: json['winnerSelectedAt'] != null
          ? (json['winnerSelectedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'entryFee': entryFee,
      'maxParticipants': maxParticipants,
      'maxEntriesPerUser': maxEntriesPerUser,
      'currentParticipants': currentParticipants,
      'participants': participants.map((p) => p.toJson()).toList(),
      'prize': prize.toJson(),
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'createdBy': createdBy,
      'winner': winner?.toJson(),
      'winnerSelectedAt': winnerSelectedAt != null
          ? Timestamp.fromDate(winnerSelectedAt!)
          : null,
    };
  }
}

class LuckyDrawParticipant {
  final String userId;
  final String username;
  final String? avatar;
  final int ticketNumber;
  final DateTime enteredAt;

  LuckyDrawParticipant({
    required this.userId,
    required this.username,
    this.avatar,
    required this.ticketNumber,
    required this.enteredAt,
  });

  factory LuckyDrawParticipant.fromJson(Map<String, dynamic> json) {
    return LuckyDrawParticipant(
      userId: json['userId'] ?? '',
      username: json['username'] ?? '',
      avatar: json['avatar'],
      ticketNumber: json['ticketNumber'] ?? 0,
      enteredAt: json['enteredAt'] != null
          ? (json['enteredAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'username': username,
      'avatar': avatar,
      'ticketNumber': ticketNumber,
      'enteredAt': Timestamp.fromDate(enteredAt),
    };
  }
}

class LuckyDrawPrize {
  final String id;
  final String name;
  final String description;
  final String type; // 'coins', 'diamonds', 'gift', 'badge', 'frame'
  final int value;
  final String? imageUrl;

  LuckyDrawPrize({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.value,
    this.imageUrl,
  });

  factory LuckyDrawPrize.fromJson(Map<String, dynamic> json) {
    return LuckyDrawPrize(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      type: json['type'] ?? 'coins',
      value: json['value'] ?? 0,
      imageUrl: json['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type,
      'value': value,
      'imageUrl': imageUrl,
    };
  }
}

class LuckyDrawStats {
  final int totalEntries;
  final int totalWins;
  final int totalSpent;
  final int totalWon;
  final double winRate;

  LuckyDrawStats({
    required this.totalEntries,
    required this.totalWins,
    required this.totalSpent,
    required this.totalWon,
    required this.winRate,
  });
}