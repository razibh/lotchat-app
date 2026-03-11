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
    this.description,
    this.rules,
    this.emblem,
    required this.leaderId,
    required this.members,
    required this.level,
    required this.xp,
    required this.xpToNextLevel,
    required this.clanCoins,
    required this.memberCount,
    required this.maxMembers,
    required this.joinType,
    this.tags = const [],
    this.settings = const {},
    required this.createdAt,
    this.lastActive,
    this.isActive = true,
    this.warWins = 0,
    this.warLosses = 0,
    this.warDraws = 0,
  });

  factory ClanModel.fromJson(Map<String, dynamic> json) {
    return ClanModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      rules: json['rules'],
      emblem: json['emblem'],
      leaderId: json['leaderId'],
      members: (json['members'] as List)
          .map((m) => ClanMember.fromJson(m))
          .toList(),
      level: json['level'],
      xp: json['xp'],
      xpToNextLevel: json['xpToNextLevel'],
      clanCoins: json['clanCoins'],
      memberCount: json['memberCount'],
      maxMembers: json['maxMembers'],
      joinType: ClanJoinType.values[json['joinType']],
      tags: List<String>.from(json['tags'] ?? []),
      settings: json['settings'] ?? {},
      createdAt: DateTime.parse(json['createdAt']),
      lastActive: json['lastActive'] != null
          ? DateTime.parse(json['lastActive'])
          : null,
      isActive: json['isActive'] ?? true,
      warWins: json['warWins'] ?? 0,
      warLosses: json['warLosses'] ?? 0,
      warDraws: json['warDraws'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
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

  // Helper methods
  bool get isFull => memberCount >= maxMembers;
  double get xpProgress => xp / xpToNextLevel;
  
  bool isLeader(String userId) => leaderId == userId;
  bool isCoLeader(String userId) => members.any((m) => m.userId == userId && m.role == ClanRole.coLeader);
  bool isElder(String userId) => members.any((m) => m.userId == userId && m.role == ClanRole.elder);
  bool canManage(String userId) => isLeader(userId) || isCoLeader(userId);
  
  ClanMember? getMember(String userId) {
    try {
      return members.firstWhere((m) => m.userId == userId);
    } catch (e) {
      return null;
    }
  }

  int get memberCountByRole(ClanRole role) {
    return members.where((m) => m.role == role).length;
  }

  List<ClanMember> getMembersByRole(ClanRole role) {
    return members.where((m) => m.role == role).toList();
  }

  int get totalActivity {
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
    this.avatar,
    required this.role,
    required this.joinedAt,
    this.activityPoints = 0,
    this.donations = 0,
    this.lastActive = 0,
    this.warPoints = 0,
    this.stats = const {},
  });

  factory ClanMember.fromJson(Map<String, dynamic> json) {
    return ClanMember(
      userId: json['userId'],
      username: json['username'],
      avatar: json['avatar'],
      role: ClanRole.values[json['role']],
      joinedAt: DateTime.parse(json['joinedAt']),
      activityPoints: json['activityPoints'] ?? 0,
      donations: json['donations'] ?? 0,
      lastActive: json['lastActive'] ?? 0,
      warPoints: json['warPoints'] ?? 0,
      stats: json['stats'] ?? {},
    );
  }

  Map<String, dynamic> toJson() => {
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

  bool get isOnline => DateTime.now().millisecondsSinceEpoch - lastActive < 300000; // 5 minutes
}