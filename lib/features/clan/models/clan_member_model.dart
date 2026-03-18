import 'package:flutter/material.dart';

// Enum গুলোকে clash এড়ানোর জন্য আলাদা নাম দিন
enum MemberClanRole { leader, coLeader, elder, member }  // নাম পরিবর্তন করে MemberClanRole
enum MemberOnlineStatus { online, offline, away, busy }  // নাম পরিবর্তন করে MemberOnlineStatus

class ClanMemberModel {
  final String userId;
  final String username;
  final String? displayName;
  final String? avatar;
  final MemberClanRole role;  // এখানে MemberClanRole ব্যবহার করুন
  final MemberOnlineStatus status;  // এখানে MemberOnlineStatus ব্যবহার করুন
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

  ClanMemberModel({
    required this.userId,
    required this.username,
    required this.role,
    required this.status,
    required this.joinedAt,
    this.displayName,
    this.avatar,
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
      userId: json['userId'] ?? '',
      username: json['username'] ?? '',
      displayName: json['displayName'],
      avatar: json['avatar'],
      role: MemberClanRole.values[json['role'] ?? 0],
      status: MemberOnlineStatus.values[json['status'] ?? 0],
      joinedAt: json['joinedAt'] != null
          ? DateTime.parse(json['joinedAt'])
          : DateTime.now(),
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

  Map<String, dynamic> toJson() {
    return {
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
  }

  // Computed properties
  String get displayNameOrUsername => displayName ?? username;

  bool get isOnline => status == MemberOnlineStatus.online;

  int get totalContribution => activityPoints + donations * 10 + warPoints * 5;

  double get activityLevel => activityPoints / 1000;

  String get roleDisplay {
    switch (role) {
      case MemberClanRole.leader:
        return 'Leader';
      case MemberClanRole.coLeader:
        return 'Co-Leader';
      case MemberClanRole.elder:
        return 'Elder';
      case MemberClanRole.member:
        return 'Member';
    }
  }

  Color get roleColor {
    switch (role) {
      case MemberClanRole.leader:
        return const Color(0xFFEF4444);
      case MemberClanRole.coLeader:
        return const Color(0xFFF59E0B);
      case MemberClanRole.elder:
        return const Color(0xFF3B82F6);
      case MemberClanRole.member:
        return const Color(0xFF6B7280);
    }
  }

  String get roleIcon {
    switch (role) {
      case MemberClanRole.leader:
        return '👑';
      case MemberClanRole.coLeader:
        return '⭐';
      case MemberClanRole.elder:
        return '🔰';
      case MemberClanRole.member:
        return '👤';
    }
  }

  // Copy with modifications
  ClanMemberModel copyWith({
    String? userId,
    String? username,
    String? displayName,
    String? avatar,
    MemberClanRole? role,
    MemberOnlineStatus? status,
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
    final sorted = List<ClanMemberModel>.from(members)
      ..sort((a, b) => b.activityPoints.compareTo(a.activityPoints));
    return sorted.indexWhere((m) => m.userId == userId) + 1;
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
  final int totalMembers;
  final int onlineNow;
  final int activeToday;
  final int activeThisWeek;
  final int newMembers;
  final Map<MemberClanRole, int> roleDistribution;  // এখানেও MemberClanRole

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
      totalMembers: json['totalMembers'] ?? 0,
      onlineNow: json['onlineNow'] ?? 0,
      activeToday: json['activeToday'] ?? 0,
      activeThisWeek: json['activeThisWeek'] ?? 0,
      newMembers: json['newMembers'] ?? 0,
      roleDistribution: Map<MemberClanRole, int>.from(json['roleDistribution'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalMembers': totalMembers,
      'onlineNow': onlineNow,
      'activeToday': activeToday,
      'activeThisWeek': activeThisWeek,
      'newMembers': newMembers,
      'roleDistribution': roleDistribution,
    };
  }
}