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

  LeaderboardEntry({
    required this.rank,
    required this.userId,
    required this.username,
    this.displayName,
    this.avatar,
    required this.score,
    required this.previousRank,
    required this.change,
    this.stats = const {},
    this.badges = const [],
    this.isOnline = false,
    this.country,
    this.level = 1,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      rank: json['rank'],
      userId: json['userId'],
      username: json['username'],
      displayName: json['displayName'],
      avatar: json['avatar'],
      score: json['score'],
      previousRank: json['previousRank'],
      change: json['change'],
      stats: json['stats'] ?? {},
      badges: List<String>.from(json['badges'] ?? []),
      isOnline: json['isOnline'] ?? false,
      country: json['country'],
      level: json['level'] ?? 1,
    );
  }
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

  Map<String, dynamic> toJson() => <String, dynamic>{
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

  LeaderboardModel({
    required this.id,
    required this.type,
    required this.period,
    required this.category,
    required this.generatedAt,
    required this.entries,
    this.currentUserEntry,
    required this.totalParticipants,
    this.metadata = const {},
  });

  factory LeaderboardModel.fromJson(Map<String, dynamic> json) {
    return LeaderboardModel(
      id: json['id'],
      type: LeaderboardType.values[json['type']],
      period: LeaderboardPeriod.values[json['period']],
      category: LeaderboardCategory.values[json['category']],
      generatedAt: DateTime.parse(json['generatedAt']),
      entries: (json['entries'] as List)
          .map((e) => LeaderboardEntry.fromJson(e))
          .toList(),
      currentUserEntry: json['currentUserEntry'] != null
          ? LeaderboardEntry.fromJson(json['currentUserEntry'])
          : null,
      totalParticipants: json['totalParticipants'],
      metadata: json['metadata'] ?? {},
    );
  }
  final String id;
  final LeaderboardType type;
  final LeaderboardPeriod period;
  final LeaderboardCategory category;
  final DateTime generatedAt;
  final List<LeaderboardEntry> entries;
  final LeaderboardEntry? currentUserEntry;
  final int totalParticipants;
  final Map<String, dynamic> metadata;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'type': type.index,
    'period': period.index,
    'category': category.index,
    'generatedAt': generatedAt.toIso8601String(),
    'entries': entries.map((LeaderboardEntry e) => e.toJson()).toList(),
    'currentUserEntry': currentUserEntry?.toJson(),
    'totalParticipants': totalParticipants,
    'metadata': metadata,
  };
}

class LeaderboardFilter {

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
  final LeaderboardType? type;
  final LeaderboardPeriod? period;
  final LeaderboardCategory? category;
  final String? country;
  final int? ageMin;
  final int? ageMax;
  final String? gender;
  final int limit;

  Map<String, dynamic> toJson() => <String, dynamic>{
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

class LeaderboardStats {

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
      totalPlayers: json['totalPlayers'],
      activeToday: json['activeToday'],
      activeThisWeek: json['activeThisWeek'],
      newPlayers: json['newPlayers'],
      topCountries: Map<String, int>.from(json['topCountries']),
      genderDistribution: Map<String, int>.from(json['genderDistribution']),
      ageDistribution: Map<int, int>.from(json['ageDistribution']),
    );
  }
  final int totalPlayers;
  final int activeToday;
  final int activeThisWeek;
  final int newPlayers;
  final Map<String, int> topCountries;
  final Map<String, int> genderDistribution;
  final Map<int, int> ageDistribution;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'totalPlayers': totalPlayers,
    'activeToday': activeToday,
    'activeThisWeek': activeThisWeek,
    'newPlayers': newPlayers,
    'topCountries': topCountries,
    'genderDistribution': genderDistribution,
    'ageDistribution': ageDistribution,
  };
}