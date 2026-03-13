enum ClanRole { leader, coLeader, elder, member }
enum MemberStatus { online, offline, away, busy }

class ClanMemberModel {

  ClanMemberModel({
    required this.userId,
    required this.username,
    this.displayName,
    this.avatar,
    required this.role,
    required this.status,
    required this.joinedAt,
    this.lastActive,
    this.activityPoints = 0,
    this.donations = 0,
    this.warPoints = 0,
    this.giftsReceived = 0,
    this.giftsSent = 0,
    this.messagesCount = 0,
    this.voiceMinutes = 0,
    this.badges = const [],
    this.stats = const {},
    this.isFavorite = false,
    this.note,
  });

  factory ClanMemberModel.fromJson(Map<String, dynamic> json) {
    return ClanMemberModel(
      userId: json['userId'],
      username: json['username'],
      displayName: json['displayName'],
      avatar: json['avatar'],
      role: ClanRole.values[json['role']],
      status: MemberStatus.values[json['status'] ?? 0],
      joinedAt: DateTime.parse(json['joinedAt']),
      lastActive: json['lastActive'] != null
          ? DateTime.parse(json['lastActive'])
          : null,
      activityPoints: json['activityPoints'] ?? 0,
      donations: json['donations'] ?? 0,
      warPoints: json['warPoints'] ?? 0,
      giftsReceived: json['giftsReceived'] ?? 0,
      giftsSent: json['giftsSent'] ?? 0,
      messagesCount: json['messagesCount'] ?? 0,
      voiceMinutes: json['voiceMinutes'] ?? 0,
      badges: List<String>.from(json['badges'] ?? []),
      stats: json['stats'] ?? {},
      isFavorite: json['isFavorite'] ?? false,
      note: json['note'],
    );
  }
  final String userId;
  final String username;
  final String? displayName;
  final String? avatar;
  final ClanRole role;
  final MemberStatus status;
  final DateTime joinedAt;
  final DateTime? lastActive;
  final int activityPoints;
  final int donations;
  final int warPoints;
  final int giftsReceived;
  final int giftsSent;
  final int messagesCount;
  final int voiceMinutes;
  final List<String> badges;
  final Map<String, dynamic> stats;
  final bool isFavorite;
  final String? note;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'userId': userId,
    'username': username,
    'displayName': displayName,
    'avatar': avatar,
    'role': role.index,
    'status': status.index,
    'joinedAt': joinedAt.toIso8601String(),
    'lastActive': lastActive?.toIso8601String(),
    'activityPoints': activityPoints,
    'donations': donations,
    'warPoints': warPoints,
    'giftsReceived': giftsReceived,
    'giftsSent': giftsSent,
    'messagesCount': messagesCount,
    'voiceMinutes': voiceMinutes,
    'badges': badges,
    'stats': stats,
    'isFavorite': isFavorite,
    'note': note,
  };

  // Computed properties
  String get displayNameOrUsername => displayName ?? username;
  
  bool get isOnline => status == MemberStatus.online;
  
  int get totalContribution => activityPoints + donations * 10 + warPoints * 5;
  
  double get activityLevel => activityPoints / 1000; // Normalized to 0-1
  
  String get roleDisplay {
    switch (role) {
      case ClanRole.leader:
        return 'Leader';
      case ClanRole.coLeader:
        return 'Co-Leader';
      case ClanRole.elder:
        return 'Elder';
      case ClanRole.member:
        return 'Member';
    }
  }

  Color get roleColor {
    switch (role) {
      case ClanRole.leader:
        return const Color(0xFFEF4444); // Red
      case ClanRole.coLeader:
        return const Color(0xFFF59E0B); // Orange
      case ClanRole.elder:
        return const Color(0xFF3B82F6); // Blue
      case ClanRole.member:
        return const Color(0xFF6B7280); // Gray
    }
  }

  String get roleIcon {
    switch (role) {
      case ClanRole.leader:
        return '👑';
      case ClanRole.coLeader:
        return '⭐';
      case ClanRole.elder:
        return '🔰';
      case ClanRole.member:
        return '👤';
    }
  }

  // Copy with modifications
  ClanMemberModel copyWith({
    String? userId,
    String? username,
    String? displayName,
    String? avatar,
    ClanRole? role,
    MemberStatus? status,
    DateTime? joinedAt,
    DateTime? lastActive,
    int? activityPoints,
    int? donations,
    int? warPoints,
    int? giftsReceived,
    int? giftsSent,
    int? messagesCount,
    int? voiceMinutes,
    List<String>? badges,
    Map<String, dynamic>? stats,
    bool? isFavorite,
    String? note,
  }) {
    return ClanMemberModel(
      userId: userId ?? this.userId,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      avatar: avatar ?? this.avatar,
      role: role ?? this.role,
      status: status ?? this.status,
      joinedAt: joinedAt ?? this.joinedAt,
      lastActive: lastActive ?? this.lastActive,
      activityPoints: activityPoints ?? this.activityPoints,
      donations: donations ?? this.donations,
      warPoints: warPoints ?? this.warPoints,
      giftsReceived: giftsReceived ?? this.giftsReceived,
      giftsSent: giftsSent ?? this.giftsSent,
      messagesCount: messagesCount ?? this.messagesCount,
      voiceMinutes: voiceMinutes ?? this.voiceMinutes,
      badges: badges ?? this.badges,
      stats: stats ?? this.stats,
      isFavorite: isFavorite ?? this.isFavorite,
      note: note ?? this.note,
    );
  }

  // Get rank in clan
  int getRank(List<ClanMemberModel> members) {
    final List<ClanMemberModel> sorted = List<ClanMemberModel>.from(members)
      ..sort((ClanMemberModel a, ClanMemberModel b) => b.activityPoints.compareTo(a.activityPoints));
    return sorted.indexWhere((ClanMemberModel m) => m.userId == userId) + 1;
  }

  // Get contribution level
  String get contributionLevel {
    if (activityPoints >= 10000) return 'Legendary';
    if (activityPoints >= 5000) return 'Elite';
    if (activityPoints >= 1000) return 'Veteran';
    if (activityPoints >= 500) return 'Active';
    return 'New';
  }
}

class ClanMemberStats {

  ClanMemberStats({
    required this.totalMembers,
    required this.onlineNow,
    required this.activeToday,
    required this.activeThisWeek,
    required this.newMembers,
    required this.roleDistribution,
  });

  factory ClanMemberStats.fromJson(Map<String, dynamic> json) {
    return ClanMemberStats(
      totalMembers: json['totalMembers'],
      onlineNow: json['onlineNow'],
      activeToday: json['activeToday'],
      activeThisWeek: json['activeThisWeek'],
      newMembers: json['newMembers'],
      roleDistribution: Map<ClanRole, int>.from(json['roleDistribution']),
    );
  }
  final int totalMembers;
  final int onlineNow;
  final int activeToday;
  final int activeThisWeek;
  final int newMembers;
  final Map<ClanRole, int> roleDistribution;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'totalMembers': totalMembers,
    'onlineNow': onlineNow,
    'activeToday': activeToday,
    'activeThisWeek': activeThisWeek,
    'newMembers': newMembers,
    'roleDistribution': roleDistribution,
  };
}