
import 'package:flutter/material.dart';

enum ClanRole { leader, coLeader, elder, member }
enum ClanJoinType { open, approval, invite }
enum ClanWarStatus { preparing, active, ended }

class ClanModel {
  final String id;
  final String name;
  final String? description;
  final String? rules;
  final String? emblem; // Logo URL
  final String leaderId;
  final List<ClanMember> members;
  final int level;
  final int xp;
  final int xpToNextLevel;
  final int clanCoins;
  final int memberCount;
  final int maxMembers;
  final ClanJoinType joinType;
  final List<String> tags;
  final Map<String, dynamic> settings;
  final DateTime createdAt;
  final DateTime? lastActive;
  final bool isActive;
  final int warWins;
  final int warLosses;
  final int warDraws;

  ClanModel({
    required this.id,
    required this.name,
    required this.leaderId,
    required this.members,
    required this.level,
    required this.xp,
    required this.xpToNextLevel,
    required this.clanCoins,
    required this.memberCount,
    required this.maxMembers,
    required this.joinType,
    required this.createdAt,
    this.description,
    this.rules,
    this.emblem,
    this.tags = const [],
    this.settings = const {},
    this.lastActive,
    this.isActive = true,
    this.warWins = 0,
    this.warLosses = 0,
    this.warDraws = 0,
  });

  factory ClanModel.fromJson(Map<String, dynamic> json) {
    return ClanModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      rules: json['rules'],
      emblem: json['emblem'],
      leaderId: json['leaderId'] ?? '',
      members: (json['members'] as List?)
          ?.map((m) => ClanMember.fromJson(m))
          .toList() ??
          [],
      level: json['level'] ?? 1,
      xp: json['xp'] ?? 0,
      xpToNextLevel: json['xpToNextLevel'] ?? 1000,
      clanCoins: json['clanCoins'] ?? 0,
      memberCount: json['memberCount'] ?? 0,
      maxMembers: json['maxMembers'] ?? 50,
      joinType: ClanJoinType.values[json['joinType'] ?? 0],
      tags: List<String>.from(json['tags'] ?? []),
      settings: json['settings'] ?? {},
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      lastActive: json['lastActive'] != null
          ? DateTime.parse(json['lastActive'])
          : null,
      isActive: json['isActive'] ?? true,
      warWins: json['warWins'] ?? 0,
      warLosses: json['warLosses'] ?? 0,
      warDraws: json['warDraws'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'rules': rules,
      'emblem': emblem,
      'leaderId': leaderId,
      'members': members.map((m) => m.toJson()).toList(),
      'level': level,
      'xp': xp,
      'xpToNextLevel': xpToNextLevel,
      'clanCoins': clanCoins,
      'memberCount': memberCount,
      'maxMembers': maxMembers,
      'joinType': joinType.index,
      'tags': tags,
      'settings': settings,
      'createdAt': createdAt.toIso8601String(),
      'lastActive': lastActive?.toIso8601String(),
      'isActive': isActive,
      'warWins': warWins,
      'warLosses': warLosses,
      'warDraws': warDraws,
    };
  }

  // 🟢 ADD: copyWith method
  ClanModel copyWith({
    String? id,
    String? name,
    String? description,
    String? rules,
    String? emblem,
    String? leaderId,
    List<ClanMember>? members,
    int? level,
    int? xp,
    int? xpToNextLevel,
    int? clanCoins,
    int? memberCount,
    int? maxMembers,
    ClanJoinType? joinType,
    List<String>? tags,
    Map<String, dynamic>? settings,
    DateTime? createdAt,
    DateTime? lastActive,
    bool? isActive,
    int? warWins,
    int? warLosses,
    int? warDraws,
  }) {
    return ClanModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      rules: rules ?? this.rules,
      emblem: emblem ?? this.emblem,
      leaderId: leaderId ?? this.leaderId,
      members: members ?? this.members,
      level: level ?? this.level,
      xp: xp ?? this.xp,
      xpToNextLevel: xpToNextLevel ?? this.xpToNextLevel,
      clanCoins: clanCoins ?? this.clanCoins,
      memberCount: memberCount ?? this.memberCount,
      maxMembers: maxMembers ?? this.maxMembers,
      joinType: joinType ?? this.joinType,
      tags: tags ?? this.tags,
      settings: settings ?? this.settings,
      createdAt: createdAt ?? this.createdAt,
      lastActive: lastActive ?? this.lastActive,
      isActive: isActive ?? this.isActive,
      warWins: warWins ?? this.warWins,
      warLosses: warLosses ?? this.warLosses,
      warDraws: warDraws ?? this.warDraws,
    );
  }

  // Helper methods (Getters)
  bool get isFull => memberCount >= maxMembers;

  double get xpProgress => xp / xpToNextLevel;

  bool isLeader(String userId) => leaderId == userId;

  bool isCoLeader(String userId) {
    return members.any((m) => m.userId == userId && m.role == ClanRole.coLeader);
  }

  bool isElder(String userId) {
    return members.any((m) => m.userId == userId && m.role == ClanRole.elder);
  }

  bool canManage(String userId) => isLeader(userId) || isCoLeader(userId);

  ClanMember? getMember(String userId) {
    try {
      return members.firstWhere((m) => m.userId == userId);
    } catch (e) {
      return null;
    }
  }

  int getMemberCountByRole(ClanRole role) {
    return members.where((m) => m.role == role).length;
  }

  List<ClanMember> getMembersByRole(ClanRole role) {
    return members.where((m) => m.role == role).toList();
  }

  int getTotalActivity() {
    return members.fold(0, (sum, m) => sum + m.activityPoints);
  }
}

class ClanMember {
  final String userId;
  final String username;
  final String? avatar;
  final ClanRole role;
  final DateTime joinedAt;
  final int activityPoints;
  final int donations;
  final int lastActive;
  final int warPoints;
  final Map<String, dynamic> stats;

  ClanMember({
    required this.userId,
    required this.username,
    required this.role,
    required this.joinedAt,
    this.avatar,
    this.activityPoints = 0,
    this.donations = 0,
    this.lastActive = 0,
    this.warPoints = 0,
    this.stats = const {},
  });

  factory ClanMember.fromJson(Map<String, dynamic> json) {
    return ClanMember(
      userId: json['userId'] ?? '',
      username: json['username'] ?? '',
      avatar: json['avatar'],
      role: ClanRole.values[json['role'] ?? 0],
      joinedAt: json['joinedAt'] != null
          ? DateTime.parse(json['joinedAt'])
          : DateTime.now(),
      activityPoints: json['activityPoints'] ?? 0,
      donations: json['donations'] ?? 0,
      lastActive: json['lastActive'] ?? 0,
      warPoints: json['warPoints'] ?? 0,
      stats: json['stats'] ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'username': username,
      'avatar': avatar,
      'role': role.index,
      'joinedAt': joinedAt.toIso8601String(),
      'activityPoints': activityPoints,
      'donations': donations,
      'lastActive': lastActive,
      'warPoints': warPoints,
      'stats': stats,
    };
  }

  bool get isOnline => DateTime.now().millisecondsSinceEpoch - lastActive < 300000; // 5 minutes

  // 🟢 ADD: copyWith method for ClanMember (optional but useful)
  ClanMember copyWith({
    String? userId,
    String? username,
    String? avatar,
    ClanRole? role,
    DateTime? joinedAt,
    int? activityPoints,
    int? donations,
    int? lastActive,
    int? warPoints,
    Map<String, dynamic>? stats,
  }) {
    return ClanMember(
      userId: userId ?? this.userId,
      username: username ?? this.username,
      avatar: avatar ?? this.avatar,
      role: role ?? this.role,
      joinedAt: joinedAt ?? this.joinedAt,
      activityPoints: activityPoints ?? this.activityPoints,
      donations: donations ?? this.donations,
      lastActive: lastActive ?? this.lastActive,
      warPoints: warPoints ?? this.warPoints,
      stats: stats ?? this.stats,
    );
  }
}