// lib/core/models/pk_battle_model.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart'; // Color এর জন্য

enum PKBattleStatus {
  scheduled,
  active,
  ended,
  cancelled,
}

enum PKBattleType {
  normal,
  tournament,
  championship,
  special,
}

class PKBattleModel {
  final String id;
  final String room1Id;
  final String room2Id;
  final int room1Score;
  final int room2Score;
  final DateTime startTime;
  final DateTime endTime;
  final bool isActive;
  final String? winnerId;
  final Map<String, int> topGifters;

  // Additional fields
  final String? room1Name;
  final String? room2Name;
  final String? room1Avatar;
  final String? room2Avatar;
  final PKBattleStatus status;
  final PKBattleType type;
  final int viewerCount;
  final int totalGifts;
  final int totalCoins;
  final Map<String, dynamic>? room1Stats;
  final Map<String, dynamic>? room2Stats;
  final List<String>? spectators;
  final Map<String, int>? giftHistory;
  final String? createdBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? endedAt;
  final String? tournamentId;
  final int round;
  final Map<String, dynamic>? metadata;

  PKBattleModel({
    required this.id,
    required this.room1Id,
    required this.room2Id,
    this.room1Score = 0,
    this.room2Score = 0,
    required this.startTime,
    required this.endTime,
    this.isActive = false,
    this.winnerId,
    this.topGifters = const {},
    this.room1Name,
    this.room2Name,
    this.room1Avatar,
    this.room2Avatar,
    this.status = PKBattleStatus.scheduled,
    this.type = PKBattleType.normal,
    this.viewerCount = 0,
    this.totalGifts = 0,
    this.totalCoins = 0,
    this.room1Stats,
    this.room2Stats,
    this.spectators,
    this.giftHistory,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
    this.endedAt,
    this.tournamentId,
    this.round = 1,
    this.metadata,
  });

  factory PKBattleModel.fromJson(Map<String, dynamic> json) {
    return PKBattleModel(
      id: json['id'] ?? '',
      room1Id: json['room1Id'] ?? '',
      room2Id: json['room2Id'] ?? '',
      room1Score: json['room1Score'] ?? 0,
      room2Score: json['room2Score'] ?? 0,
      startTime: json['startTime'] != null
          ? DateTime.parse(json['startTime'])
          : DateTime.now(),
      endTime: json['endTime'] != null
          ? DateTime.parse(json['endTime'])
          : DateTime.now().add(const Duration(minutes: 5)),
      isActive: json['isActive'] ?? false,
      winnerId: json['winnerId'],
      topGifters: Map<String, int>.from(json['topGifters'] ?? {}),
      room1Name: json['room1Name'],
      room2Name: json['room2Name'],
      room1Avatar: json['room1Avatar'],
      room2Avatar: json['room2Avatar'],
      status: _parsePKBattleStatus(json['status']),
      type: _parsePKBattleType(json['type']),
      viewerCount: json['viewerCount'] ?? 0,
      totalGifts: json['totalGifts'] ?? 0,
      totalCoins: json['totalCoins'] ?? 0,
      room1Stats: json['room1Stats'],
      room2Stats: json['room2Stats'],
      spectators: json['spectators'] != null
          ? List<String>.from(json['spectators'])
          : null,
      giftHistory: json['giftHistory'] != null
          ? Map<String, int>.from(json['giftHistory'])
          : null,
      createdBy: json['createdBy'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
      endedAt: json['endedAt'] != null
          ? DateTime.parse(json['endedAt'])
          : null,
      tournamentId: json['tournamentId'],
      round: json['round'] ?? 1,
      metadata: json['metadata'],
    );
  }

  static PKBattleStatus _parsePKBattleStatus(String? status) {
    if (status == null) return PKBattleStatus.scheduled;
    switch (status.toLowerCase()) {
      case 'scheduled':
        return PKBattleStatus.scheduled;
      case 'active':
        return PKBattleStatus.active;
      case 'ended':
        return PKBattleStatus.ended;
      case 'cancelled':
        return PKBattleStatus.cancelled;
      default:
        return PKBattleStatus.scheduled;
    }
  }

  static PKBattleType _parsePKBattleType(String? type) {
    if (type == null) return PKBattleType.normal;
    switch (type.toLowerCase()) {
      case 'normal':
        return PKBattleType.normal;
      case 'tournament':
        return PKBattleType.tournament;
      case 'championship':
        return PKBattleType.championship;
      case 'special':
        return PKBattleType.special;
      default:
        return PKBattleType.normal;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'room1Id': room1Id,
      'room2Id': room2Id,
      'room1Score': room1Score,
      'room2Score': room2Score,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'isActive': isActive,
      'winnerId': winnerId,
      'topGifters': topGifters,
      'room1Name': room1Name,
      'room2Name': room2Name,
      'room1Avatar': room1Avatar,
      'room2Avatar': room2Avatar,
      'status': status.toString().split('.').last,
      'type': type.toString().split('.').last,
      'viewerCount': viewerCount,
      'totalGifts': totalGifts,
      'totalCoins': totalCoins,
      'room1Stats': room1Stats,
      'room2Stats': room2Stats,
      'spectators': spectators,
      'giftHistory': giftHistory,
      'createdBy': createdBy,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'endedAt': endedAt?.toIso8601String(),
      'tournamentId': tournamentId,
      'round': round,
      'metadata': metadata,
    };
  }

  PKBattleModel copyWith({
    String? id,
    String? room1Id,
    String? room2Id,
    int? room1Score,
    int? room2Score,
    DateTime? startTime,
    DateTime? endTime,
    bool? isActive,
    String? winnerId,
    Map<String, int>? topGifters,
    String? room1Name,
    String? room2Name,
    String? room1Avatar,
    String? room2Avatar,
    PKBattleStatus? status,
    PKBattleType? type,
    int? viewerCount,
    int? totalGifts,
    int? totalCoins,
    Map<String, dynamic>? room1Stats,
    Map<String, dynamic>? room2Stats,
    List<String>? spectators,
    Map<String, int>? giftHistory,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? endedAt,
    String? tournamentId,
    int? round,
    Map<String, dynamic>? metadata,
  }) {
    return PKBattleModel(
      id: id ?? this.id,
      room1Id: room1Id ?? this.room1Id,
      room2Id: room2Id ?? this.room2Id,
      room1Score: room1Score ?? this.room1Score,
      room2Score: room2Score ?? this.room2Score,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isActive: isActive ?? this.isActive,
      winnerId: winnerId ?? this.winnerId,
      topGifters: topGifters ?? this.topGifters,
      room1Name: room1Name ?? this.room1Name,
      room2Name: room2Name ?? this.room2Name,
      room1Avatar: room1Avatar ?? this.room1Avatar,
      room2Avatar: room2Avatar ?? this.room2Avatar,
      status: status ?? this.status,
      type: type ?? this.type,
      viewerCount: viewerCount ?? this.viewerCount,
      totalGifts: totalGifts ?? this.totalGifts,
      totalCoins: totalCoins ?? this.totalCoins,
      room1Stats: room1Stats ?? this.room1Stats,
      room2Stats: room2Stats ?? this.room2Stats,
      spectators: spectators ?? this.spectators,
      giftHistory: giftHistory ?? this.giftHistory,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      endedAt: endedAt ?? this.endedAt,
      tournamentId: tournamentId ?? this.tournamentId,
      round: round ?? this.round,
      metadata: metadata ?? this.metadata,
    );
  }

  // Helper getters
  int get totalScore => room1Score + room2Score;

  int get scoreDifference => (room1Score - room2Score).abs();

  String get leadingRoom {
    if (room1Score > room2Score) return room1Id;
    if (room2Score > room1Score) return room2Id;
    return 'tie';
  }

  bool get isTie => room1Score == room2Score;

  bool get hasWinner => winnerId != null && winnerId!.isNotEmpty;

  bool get isRoom1Winner => winnerId == room1Id;

  bool get isRoom2Winner => winnerId == room2Id;

  Duration get timeRemaining {
    final now = DateTime.now();
    if (now.isAfter(endTime)) return Duration.zero;
    return endTime.difference(now);
  }

  Duration get timeElapsed {
    final now = DateTime.now();
    if (now.isBefore(startTime)) return Duration.zero;
    return now.difference(startTime);
  }

  double get progress {
    final total = endTime.difference(startTime);
    final elapsed = DateTime.now().difference(startTime);
    if (elapsed.inSeconds <= 0) return 0;
    if (elapsed >= total) return 1;
    return elapsed.inSeconds / total.inSeconds;
  }

  // Gifters
  List<MapEntry<String, int>> get topGiftersList {
    final sorted = topGifters.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted;
  }

  int getGifterRank(String userId) {
    final sorted = topGiftersList;
    for (int i = 0; i < sorted.length; i++) {
      if (sorted[i].key == userId) return i + 1;
    }
    return 0;
  }

  // Add gift
  PKBattleModel addGift(String userId, int amount) {
    final updatedGifters = Map<String, int>.from(topGifters);
    updatedGifters[userId] = (updatedGifters[userId] ?? 0) + amount;

    return copyWith(
      topGifters: updatedGifters,
      totalGifts: totalGifts + 1,
      totalCoins: totalCoins + amount,
    );
  }

  // Update score
  PKBattleModel updateScore(String roomId, int points) {
    if (roomId == room1Id) {
      return copyWith(room1Score: room1Score + points);
    } else if (roomId == room2Id) {
      return copyWith(room2Score: room2Score + points);
    }
    return this;
  }

  // End battle
  PKBattleModel endBattle([String? winner]) {
    return copyWith(
      isActive: false,
      status: PKBattleStatus.ended,
      winnerId: winner ?? (room1Score > room2Score ? room1Id : room2Id),
      endedAt: DateTime.now(),
    );
  }

  // Status helpers
  bool get isScheduled => status == PKBattleStatus.scheduled;
  bool get isEnded => status == PKBattleStatus.ended;
  bool get isCancelled => status == PKBattleStatus.cancelled;
  bool get isOngoing => status == PKBattleStatus.active && isActive;

  @override
  String toString() {
    return 'PKBattleModel(id: $id, room1: $room1Id($room1Score) vs room2: $room2Id($room2Score))';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PKBattleModel &&
        other.id == id &&
        other.room1Id == room1Id &&
        other.room2Id == room2Id;
  }

  @override
  int get hashCode => Object.hash(id, room1Id, room2Id);
}