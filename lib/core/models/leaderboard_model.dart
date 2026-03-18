// lib/core/models/leaderboard_model.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart'; // 🟢 Color ব্যবহারের জন্য

enum LeaderboardType {
  global,
  friends,
  country,
  age,
  gender
}

enum LeaderboardPeriod {
  daily,
  weekly,
  monthly,
  allTime
}

enum LeaderboardCategory {
  gifts,
  diamonds,
  games,
  followers,
  streaming,
  activity
}

class LeaderboardEntry {
  final int rank;
  final String userId;
  final String username;
  final String? displayName;
  final String? avatar;
  final int score;
  final int previousRank;
  final int change; // positive = up, negative = down, 0 = same
  final Map<String, dynamic> stats;
  final List<String> badges;
  final bool isOnline;
  final String? country;
  final int level;

  LeaderboardEntry({
    required this.rank,
    required this.userId,
    required this.username,
    required this.score,
    required this.previousRank,
    required this.change,
    this.displayName,
    this.avatar,
    this.stats = const {},
    this.badges = const [],
    this.isOnline = false,
    this.country,
    this.level = 1,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      rank: json['rank'] ?? 0,
      userId: json['userId'] ?? '',
      username: json['username'] ?? '',
      displayName: json['displayName'],
      avatar: json['avatar'],
      score: json['score'] ?? 0,
      previousRank: json['previousRank'] ?? 0,
      change: json['change'] ?? 0,
      stats: json['stats'] ?? {},
      badges: List<String>.from(json['badges'] ?? []),
      isOnline: json['isOnline'] ?? false,
      country: json['country'],
      level: json['level'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rank': rank,
      'userId': userId,
      'username': username,
      'displayName': displayName,
      'avatar': avatar,
      'score': score,
      'previousRank': previousRank,
      'change': change,
      'stats': stats,
      'badges': badges,
      'isOnline': isOnline,
      'country': country,
      'level': level,
    };
  }

  String get rankEmoji {
    if (rank == 1) return '🥇';
    if (rank == 2) return '🥈';
    if (rank == 3) return '🥉';
    return '#$rank';
  }

  Color get rankColor {
    if (rank == 1) return const Color(0xFFFFD700); // Gold
    if (rank == 2) return const Color(0xFFC0C0C0); // Silver
    if (rank == 3) return const Color(0xFFCD7F32); // Bronze
    return const Color(0xFF6B7280); // Gray
  }
}

class LeaderboardModel {
  final String id;
  final LeaderboardType type;
  final LeaderboardPeriod period;
  final LeaderboardCategory category;
  final DateTime generatedAt;
  final List<LeaderboardEntry> entries;
  final LeaderboardEntry? currentUserEntry;
  final int totalParticipants;
  final Map<String, dynamic> metadata;

  LeaderboardModel({
    required this.id,
    required this.type,
    required this.period,
    required this.category,
    required this.generatedAt,
    required this.entries,
    required this.totalParticipants,
    this.currentUserEntry,
    this.metadata = const {},
  });

  factory LeaderboardModel.fromJson(Map<String, dynamic> json) {
    return LeaderboardModel(
      id: json['id'] ?? '',
      type: LeaderboardType.values[json['type'] ?? 0],
      period: LeaderboardPeriod.values[json['period'] ?? 0],
      category: LeaderboardCategory.values[json['category'] ?? 0],
      generatedAt: json['generatedAt'] != null
          ? DateTime.parse(json['generatedAt'])
          : DateTime.now(),
      entries: (json['entries'] as List? ?? [])
          .map((e) => LeaderboardEntry.fromJson(e))
          .toList(),
      currentUserEntry: json['currentUserEntry'] != null
          ? LeaderboardEntry.fromJson(json['currentUserEntry'])
          : null,
      totalParticipants: json['totalParticipants'] ?? 0,
      metadata: json['metadata'] ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.index,
      'period': period.index,
      'category': category.index,
      'generatedAt': generatedAt.toIso8601String(),
      'entries': entries.map((e) => e.toJson()).toList(),
      'currentUserEntry': currentUserEntry?.toJson(),
      'totalParticipants': totalParticipants,
      'metadata': metadata,
    };
  }

  // Helper getters
  LeaderboardEntry? get topEntry => entries.isNotEmpty ? entries.first : null;
  LeaderboardEntry? get currentUser => currentUserEntry;

  int get currentUserRank => currentUserEntry?.rank ?? 0;
  bool get hasCurrentUser => currentUserEntry != null;

  // Get entries by page
  List<LeaderboardEntry> getPage(int page, int pageSize) {
    final start = page * pageSize;
    final end = start + pageSize;
    if (start >= entries.length) return [];
    return entries.sublist(start, end.clamp(0, entries.length));
  }

  // Find user by ID
  LeaderboardEntry? findUser(String userId) {
    try {
      return entries.firstWhere((e) => e.userId == userId);
    } catch (e) {
      return null;
    }
  }
}

class LeaderboardFilter {
  final LeaderboardType? type;
  final LeaderboardPeriod? period;
  final LeaderboardCategory? category;
  final String? country;
  final int? ageMin;
  final int? ageMax;
  final String? gender;
  final int limit;

  LeaderboardFilter({
    this.type,
    this.period,
    this.category,
    this.country,
    this.ageMin,
    this.ageMax,
    this.gender,
    this.limit = 100,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type?.index,
      'period': period?.index,
      'category': category?.index,
      'country': country,
      'ageMin': ageMin,
      'ageMax': ageMax,
      'gender': gender,
      'limit': limit,
    };
  }

  LeaderboardFilter copyWith({
    LeaderboardType? type,
    LeaderboardPeriod? period,
    LeaderboardCategory? category,
    String? country,
    int? ageMin,
    int? ageMax,
    String? gender,
    int? limit,
  }) {
    return LeaderboardFilter(
      type: type ?? this.type,
      period: period ?? this.period,
      category: category ?? this.category,
      country: country ?? this.country,
      ageMin: ageMin ?? this.ageMin,
      ageMax: ageMax ?? this.ageMax,
      gender: gender ?? this.gender,
      limit: limit ?? this.limit,
    );
  }
}

class LeaderboardStats {
  final int totalPlayers;
  final int activeToday;
  final int activeThisWeek;
  final int newPlayers;
  final Map<String, int> topCountries;
  final Map<String, int> genderDistribution;
  final Map<int, int> ageDistribution;

  LeaderboardStats({
    required this.totalPlayers,
    required this.activeToday,
    required this.activeThisWeek,
    required this.newPlayers,
    required this.topCountries,
    required this.genderDistribution,
    required this.ageDistribution,
  });

  factory LeaderboardStats.fromJson(Map<String, dynamic> json) {
    return LeaderboardStats(
      totalPlayers: json['totalPlayers'] ?? 0,
      activeToday: json['activeToday'] ?? 0,
      activeThisWeek: json['activeThisWeek'] ?? 0,
      newPlayers: json['newPlayers'] ?? 0,
      topCountries: Map<String, int>.from(json['topCountries'] ?? {}),
      genderDistribution: Map<String, int>.from(json['genderDistribution'] ?? {}),
      ageDistribution: Map<int, int>.from(json['ageDistribution'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalPlayers': totalPlayers,
      'activeToday': activeToday,
      'activeThisWeek': activeThisWeek,
      'newPlayers': newPlayers,
      'topCountries': topCountries,
      'genderDistribution': genderDistribution,
      'ageDistribution': ageDistribution,
    };
  }

  // Helper getters
  double get activeTodayPercentage {
    if (totalPlayers == 0) return 0;
    return (activeToday / totalPlayers) * 100;
  }

  double get activeThisWeekPercentage {
    if (totalPlayers == 0) return 0;
    return (activeThisWeek / totalPlayers) * 100;
  }

  double get newPlayersPercentage {
    if (totalPlayers == 0) return 0;
    return (newPlayers / totalPlayers) * 100;
  }

  String? get topCountry {
    if (topCountries.isEmpty) return null;
    return topCountries.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  String? get topGender {
    if (genderDistribution.isEmpty) return null;
    return genderDistribution.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  int? get topAgeGroup {
    if (ageDistribution.isEmpty) return null;
    return ageDistribution.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }
}