import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_models.dart' as app;
import '../di/service_locator.dart';
import 'database_service.dart';
import 'notification_service.dart';

class LuckyDrawService {
  late final SupabaseClient _supabase;
  late final DatabaseService _databaseService;
  late final NotificationService _notificationService;

  LuckyDrawService() {
    _initializeServices();
  }

  void _initializeServices() {
    try {
      _supabase = getService<SupabaseClient>();
      _databaseService = ServiceLocator.instance.get<DatabaseService>();
      _notificationService = ServiceLocator.instance.get<NotificationService>();
    } catch (e) {
      debugPrint('Error initializing services: $e');
    }
  }

  // Helper to get current user
  String? get _currentUserId => _supabase.auth.currentSession?.user.id;

  // ==================== HELPER METHODS ====================

  DateTime _parseDate(dynamic date) {
    if (date == null) return DateTime.now();
    if (date is String) return DateTime.parse(date);
    if (date is DateTime) return date;
    return DateTime.now();
  }

  int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  // ==================== GET LUCKY DRAWS ====================

  /// Get active lucky draws
  Future<List<LuckyDraw>> getActiveDraws() async {
    try {
      final now = DateTime.now().toIso8601String();

      final response = await _supabase
          .from('lucky_draws')
          .select()
          .eq('is_active', true)
          .lte('start_time', now)
          .gte('end_time', now)
          .order('end_time');

      return response.map((json) => LuckyDraw.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error getting active draws: $e');
      return [];
    }
  }

  /// Get upcoming lucky draws
  Future<List<LuckyDraw>> getUpcomingDraws() async {
    try {
      final now = DateTime.now().toIso8601String();

      final response = await _supabase
          .from('lucky_draws')
          .select()
          .eq('is_active', true)
          .gt('start_time', now)
          .order('start_time');

      return response.map((json) => LuckyDraw.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error getting upcoming draws: $e');
      return [];
    }
  }

  /// Get completed lucky draws
  Future<List<LuckyDraw>> getCompletedDraws({int limit = 20}) async {
    try {
      final now = DateTime.now().toIso8601String();

      final response = await _supabase
          .from('lucky_draws')
          .select()
          .lt('end_time', now)
          .order('end_time', ascending: false)
          .limit(limit);

      return response.map((json) => LuckyDraw.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error getting completed draws: $e');
      return [];
    }
  }

  /// Get lucky draw by ID
  Future<LuckyDraw?> getLuckyDraw(String drawId) async {
    try {
      final response = await _supabase
          .from('lucky_draws')
          .select()
          .eq('id', drawId)
          .maybeSingle();

      if (response != null) {
        return LuckyDraw.fromJson(response);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting lucky draw: $e');
      return null;
    }
  }

  /// Stream lucky draw
  Stream<LuckyDraw?> streamLuckyDraw(String drawId) {
    try {
      final stream = _supabase
          .from('lucky_draws')
          .stream(primaryKey: ['id']);

      return stream.map((data) {
        for (var item in data) {
          if (item['id'] == drawId) {
            return LuckyDraw.fromJson(item);
          }
        }
        return null;
      });
    } catch (e) {
      debugPrint('Error streaming lucky draw: $e');
      return Stream.value(null);
    }
  }

  // ==================== ENTER LUCKY DRAW ====================

  Future<bool> enterDraw(String drawId, {int ticketCount = 1}) async {
    final userId = _currentUserId;
    if (userId == null) throw Exception('User not logged in');

    try {
      // Get draw data
      final drawData = await _supabase
          .from('lucky_draws')
          .select()
          .eq('id', drawId)
          .single();

      if (drawData == null) throw Exception('Lucky draw not found');

      final draw = LuckyDraw.fromJson(drawData);

      // Check if draw is active
      final now = DateTime.now();
      if (now.isBefore(draw.startTime) || now.isAfter(draw.endTime)) {
        throw Exception('Lucky draw is not active');
      }

      // Check max entries per user
      final userEntryCount = draw.participants.where((p) => p.userId == userId).length;
      if (userEntryCount + ticketCount > draw.maxEntriesPerUser) {
        throw Exception('Maximum entries reached for this user');
      }

      // Check total tickets
      if (draw.currentParticipants + ticketCount > draw.maxParticipants) {
        throw Exception('Lucky draw is full');
      }

      // Check if user has enough coins
      final userData = await _supabase
          .from('users')
          .select('coins, username, avatar_url')
          .eq('id', userId)
          .single();

      if (userData == null) throw Exception('User not found');

      final userCoins = _toInt(userData['coins']);
      final int totalCost = draw.entryFee * ticketCount;

      if (userCoins < totalCost) {
        throw Exception('Insufficient coins');
      }

      // Deduct coins
      final updateUserQuery = _supabase
          .from('users')
          .update({
        'coins': userCoins - totalCost,
        'updated_at': DateTime.now().toIso8601String(),
      });
      await updateUserQuery.eq('id', userId);

      // Add entries
      final List<LuckyDrawParticipant> newParticipants = [];
      for (int i = 0; i < ticketCount; i++) {
        newParticipants.add(LuckyDrawParticipant(
          userId: userId,
          username: userData['username'] ?? 'User',
          avatar: userData['avatar_url'],
          ticketNumber: draw.currentParticipants + i + 1,
          enteredAt: DateTime.now(),
        ));
      }

      final updatedParticipants = [...draw.participants, ...newParticipants];

      // Update draw
      final updateDrawQuery = _supabase
          .from('lucky_draws')
          .update({
        'participants': updatedParticipants.map((p) => p.toJson()).toList(),
        'current_participants': draw.currentParticipants + ticketCount,
        'updated_at': DateTime.now().toIso8601String(),
      });
      await updateDrawQuery.eq('id', drawId);

      // Record transaction
      await _recordEntryTransaction(
        userId: userId,
        drawId: drawId,
        drawName: draw.name,
        ticketCount: ticketCount,
        totalCost: totalCost,
      );

      return true;
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
      await _supabase.from('lucky_draw_transactions').insert({
        'user_id': userId,
        'draw_id': drawId,
        'draw_name': drawName,
        'ticket_count': ticketCount,
        'total_cost': totalCost,
        'type': 'entry',
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('Error recording entry transaction: $e');
    }
  }

  // ==================== DRAW WINNER ====================

  Future<LuckyDrawParticipant?> drawWinner(String drawId) async {
    final userId = _currentUserId;
    if (userId == null) throw Exception('User not logged in');

    try {
      // Get draw data
      final drawData = await _supabase
          .from('lucky_draws')
          .select()
          .eq('id', drawId)
          .single();

      if (drawData == null) throw Exception('Lucky draw not found');

      final draw = LuckyDraw.fromJson(drawData);

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
      final updateDrawQuery = _supabase
          .from('lucky_draws')
          .update({
        'winner': winner.toJson(),
        'winner_selected_at': DateTime.now().toIso8601String(),
        'is_active': false,
        'updated_at': DateTime.now().toIso8601String(),
      });
      await updateDrawQuery.eq('id', drawId);

      // Award prize
      await _awardPrize(winner.userId, draw.prize);

      // Notify winner
      try {
        await _notificationService.showNotification(
          title: 'Congratulations! 🎉',
          body: 'You won ${draw.prize.name} in ${draw.name}',
          data: {'type': 'lucky_draw', 'drawId': drawId, 'prizeId': draw.prize.id},
        );
      } catch (e) {
        debugPrint('Error sending winner notification: $e');
      }

      return winner;
    } catch (e) {
      debugPrint('Error drawing winner: $e');
      return null;
    }
  }

  Future<void> _awardPrize(String userId, LuckyDrawPrize prize) async {
    try {
      final userData = await _supabase
          .from('users')
          .select('coins, diamonds')
          .eq('id', userId)
          .single();

      if (userData == null) return;

      switch (prize.type) {
        case 'coins':
          final currentCoins = _toInt(userData['coins']);
          final updateQuery = _supabase
              .from('users')
              .update({
            'coins': currentCoins + prize.value,
            'updated_at': DateTime.now().toIso8601String(),
          });
          await updateQuery.eq('id', userId);
          break;
        case 'diamonds':
          final currentDiamonds = _toInt(userData['diamonds']);
          final updateQuery = _supabase
              .from('users')
              .update({
            'diamonds': currentDiamonds + prize.value,
            'updated_at': DateTime.now().toIso8601String(),
          });
          await updateQuery.eq('id', userId);
          break;
        case 'gift':
        case 'badge':
        case 'frame':
        // Award logic for non-currency items
          await _awardSpecialItem(userId, prize);
          break;
      }
    } catch (e) {
      debugPrint('Error awarding prize: $e');
    }
  }

  Future<void> _awardSpecialItem(String userId, LuckyDrawPrize prize) async {
    try {
      await _supabase.from('user_items').insert({
        'user_id': userId,
        'item_id': prize.id,
        'item_name': prize.name,
        'item_type': prize.type,
        'acquired_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('Error awarding special item: $e');
    }
  }

  // ==================== USER PARTICIPATION ====================

  Future<List<LuckyDraw>> getUserEntries(String userId) async {
    try {
      final response = await _supabase
          .from('lucky_draw_transactions')
          .select('draw_id')
          .eq('user_id', userId)
          .eq('type', 'entry')
          .order('created_at', ascending: false)
          .limit(50);

      final drawIds = response.map<String>((item) => item['draw_id'] as String).toSet();

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
      final response = await _supabase
          .from('lucky_draws')
          .select()
          .eq('winner->>userId', userId)
          .order('winner_selected_at', ascending: false)
          .limit(20);

      return response.map((json) => LuckyDraw.fromJson(json)).toList();
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
    final userId = _currentUserId;
    if (userId == null) throw Exception('User not logged in');

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
        createdBy: userId,
      );

      final response = await _supabase
          .from('lucky_draws')
          .insert(draw.toJson())
          .select()
          .single();

      return response['id'].toString();
    } catch (e) {
      debugPrint('Error creating lucky draw: $e');
      return null;
    }
  }

  // ==================== STATISTICS ====================

  Future<LuckyDrawStats> getLuckyDrawStats(String userId) async {
    try {
      final entries = await _supabase
          .from('lucky_draw_transactions')
          .select()
          .eq('user_id', userId)
          .eq('type', 'entry');

      final wins = await _supabase
          .from('lucky_draws')
          .select()
          .eq('winner->>userId', userId);

      int totalSpent = 0;
      for (var item in entries) {
        totalSpent += _toInt(item['total_cost']);
      }

      int totalWon = 0;
      for (var item in wins) {
        final prizeData = item['prize'] as Map<String, dynamic>?;
        if (prizeData != null) {
          final prize = LuckyDrawPrize.fromJson(prizeData);
          if (prize.type == 'coins' || prize.type == 'diamonds') {
            totalWon += prize.value;
          }
        }
      }

      double winRate = 0;
      if (entries.isNotEmpty) {
        winRate = wins.length / entries.length;
      }

      return LuckyDrawStats(
        totalEntries: entries.length,
        totalWins: wins.length,
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
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['image_url'] ?? json['imageUrl'],
      startTime: DateTime.parse(json['start_time'] ?? json['startTime'] ?? DateTime.now().toIso8601String()),
      endTime: DateTime.parse(json['end_time'] ?? json['endTime'] ?? DateTime.now().toIso8601String()),
      entryFee: json['entry_fee'] ?? json['entryFee'] ?? 0,
      maxParticipants: json['max_participants'] ?? json['maxParticipants'] ?? 0,
      maxEntriesPerUser: json['max_entries_per_user'] ?? json['maxEntriesPerUser'] ?? 1,
      currentParticipants: json['current_participants'] ?? json['currentParticipants'] ?? 0,
      participants: (json['participants'] as List? ?? [])
          .map((p) => LuckyDrawParticipant.fromJson(p))
          .toList(),
      prize: LuckyDrawPrize.fromJson(json['prize'] ?? {}),
      isActive: json['is_active'] ?? json['isActive'] ?? true,
      createdAt: DateTime.parse(json['created_at'] ?? json['createdAt'] ?? DateTime.now().toIso8601String()),
      createdBy: json['created_by'] ?? json['createdBy'] ?? '',
      winner: json['winner'] != null ? LuckyDrawParticipant.fromJson(json['winner']) : null,
      winnerSelectedAt: json['winner_selected_at'] != null
          ? DateTime.parse(json['winner_selected_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'image_url': imageUrl,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'entry_fee': entryFee,
      'max_participants': maxParticipants,
      'max_entries_per_user': maxEntriesPerUser,
      'current_participants': currentParticipants,
      'participants': participants.map((p) => p.toJson()).toList(),
      'prize': prize.toJson(),
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'created_by': createdBy,
      'winner': winner?.toJson(),
      'winner_selected_at': winnerSelectedAt?.toIso8601String(),
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
      userId: json['user_id'] ?? json['userId'] ?? '',
      username: json['username'] ?? '',
      avatar: json['avatar'] ?? json['avatar_url'],
      ticketNumber: json['ticket_number'] ?? json['ticketNumber'] ?? 0,
      enteredAt: DateTime.parse(json['entered_at'] ?? json['enteredAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'username': username,
      'avatar': avatar,
      'ticket_number': ticketNumber,
      'entered_at': enteredAt.toIso8601String(),
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
      imageUrl: json['image_url'] ?? json['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type,
      'value': value,
      'image_url': imageUrl,
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