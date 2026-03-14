// User Roles Enum
enum UserRole {
  user,
  host,
  agency,
  countryManager,
  coinSeller,
  admin,
}

// User Status Enum
enum UserStatus {
  active,
  inactive,
  banned,
  suspended,
  pending,
  verified,
}

// Badge Type Enum
enum BadgeType {
  none,
  agency,
  coinSeller,
  official,
  vip,
  host,
  moderator,
  streamer,
}

// Gender Enum
enum Gender {
  male,
  female,
  other,
  preferNotToSay,
}

// User Class
class User {

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.name,
    required this.role, required this.countryId, required this.createdAt, this.avatar,
    this.coverImage,
    this.bio,
    this.status = UserStatus.active,
    this.updatedAt,
    this.lastLoginAt,
    this.isVerified = false,
    this.isEmailVerified = false,
    this.isPhoneVerified = false,
    this.isTwoFactorEnabled = false,
    this.badge,
    this.metadata,
    this.stats,
    this.settings,
    this.socialLinks,
    this.gender,
    this.dateOfBirth,
    this.phoneNumber,
    this.address,
  });

  // Factory constructor for regular user
  factory User.regular({
    required String id,
    required String email,
    required String name,
    required String username,
    required String countryId,
    String? avatar,
    String? bio,
    UserStatus status = UserStatus.active,
    bool isVerified = false,
  }) {
    return User(
      id: id,
      username: username,
      email: email,
      name: name,
      avatar: avatar,
      bio: bio,
      role: UserRole.user,
      status: status,
      countryId: countryId,
      createdAt: DateTime.now(),
      isVerified: isVerified,
    );
  }

  // Factory constructor for host
  factory User.host({
    required String id,
    required String email,
    required String name,
    required String username,
    required String countryId,
    required String agencyId,
    String? avatar,
    String? bio,
    UserStatus status = UserStatus.active,
    bool isVerified = false,
  }) {
    return User(
      id: id,
      username: username,
      email: email,
      name: name,
      avatar: avatar,
      bio: bio,
      role: UserRole.host,
      status: status,
      countryId: countryId,
      createdAt: DateTime.now(),
      isVerified: isVerified,
      badge: UserBadge(
        type: BadgeType.host,
        isVerified: isVerified,
      ),
      metadata: <String, dynamic>{'agencyId': agencyId},
    );
  }

  // Factory constructor for agency
  factory User.agency({
    required String id,
    required String email,
    required String name,
    required String username,
    required String countryId,
    required String agencyId,
    String? avatar,
    String? bio,
    UserStatus status = UserStatus.active,
    bool isVerified = false,
  }) {
    return User(
      id: id,
      username: username,
      email: email,
      name: name,
      avatar: avatar,
      bio: bio,
      role: UserRole.agency,
      status: status,
      countryId: countryId,
      createdAt: DateTime.now(),
      isVerified: isVerified,
      badge: UserBadge(
        type: BadgeType.agency,
        agencyId: agencyId,
        isVerified: isVerified,
      ),
      metadata: <String, dynamic>{'agencyId': agencyId},
    );
  }

  // Factory constructor for country manager
  factory User.countryManager({
    required String id,
    required String email,
    required String name,
    required String username,
    required String countryId,
    String? avatar,
    String? bio,
    UserStatus status = UserStatus.active,
    bool isVerified = false,
  }) {
    return User(
      id: id,
      username: username,
      email: email,
      name: name,
      avatar: avatar,
      bio: bio,
      role: UserRole.countryManager,
      status: status,
      countryId: countryId,
      createdAt: DateTime.now(),
      isVerified: isVerified,
      badge: UserBadge(
        type: BadgeType.official,
        isVerified: isVerified,
      ),
    );
  }

  // Factory constructor for coin seller
  factory User.coinSeller({
    required String id,
    required String email,
    required String name,
    required String username,
    required String countryId,
    required String sellerId,
    String? avatar,
    String? bio,
    UserStatus status = UserStatus.active,
    bool isVerified = false,
  }) {
    return User(
      id: id,
      username: username,
      email: email,
      name: name,
      avatar: avatar,
      bio: bio,
      role: UserRole.coinSeller,
      status: status,
      countryId: countryId,
      createdAt: DateTime.now(),
      isVerified: isVerified,
      badge: UserBadge(
        type: BadgeType.coinSeller,
        sellerId: sellerId,
        isVerified: isVerified,
      ),
      metadata: <String, dynamic>{'sellerId': sellerId},
    );
  }

  // Factory constructor for admin
  factory User.admin({
    required String id,
    required String email,
    required String name,
    required String username,
    String? avatar,
    String? bio,
    UserStatus status = UserStatus.active,
    bool isVerified = true,
  }) {
    return User(
      id: id,
      username: username,
      email: email,
      name: name,
      avatar: avatar,
      bio: bio,
      role: UserRole.admin,
      status: status,
      countryId: 'global',
      createdAt: DateTime.now(),
      isVerified: isVerified,
      badge: UserBadge(
        type: BadgeType.official,
        isVerified: true,
      ),
    );
  }

  // JSON deserialization
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      name: json['name'],
      avatar: json['avatar'],
      coverImage: json['coverImage'],
      bio: json['bio'],
      role: _parseUserRole(json['role']),
      status: _parseUserStatus(json['status']),
      countryId: json['countryId'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      lastLoginAt: json['lastLoginAt'] != null ? DateTime.parse(json['lastLoginAt']) : null,
      isVerified: json['isVerified'] ?? false,
      isEmailVerified: json['isEmailVerified'] ?? false,
      isPhoneVerified: json['isPhoneVerified'] ?? false,
      isTwoFactorEnabled: json['isTwoFactorEnabled'] ?? false,
      badge: json['badge'] != null ? UserBadge.fromJson(json['badge']) : null,
      metadata: json['metadata'],
      stats: json['stats'] != null ? UserStats.fromJson(json['stats']) : null,
      settings: json['settings'] != null ? UserSettings.fromJson(json['settings']) : null,
      socialLinks: json['socialLinks'] != null ? SocialLinks.fromJson(json['socialLinks']) : null,
      gender: json['gender'] != null ? _parseGender(json['gender']) : null,
      dateOfBirth: json['dateOfBirth'] != null ? DateTime.parse(json['dateOfBirth']) : null,
      phoneNumber: json['phoneNumber'],
      address: json['address'],
    );
  }
  final String id;
  final String username;
  final String email;
  final String name;
  final String? avatar;
  final String? coverImage;
  final String? bio;
  final UserRole role;
  final UserStatus status;
  final String countryId;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? lastLoginAt;
  final bool isVerified;
  final bool isEmailVerified;
  final bool isPhoneVerified;
  final bool isTwoFactorEnabled;
  final UserBadge? badge;
  final Map<String, dynamic>? metadata;
  final UserStats? stats;
  final UserSettings? settings;
  final SocialLinks? socialLinks;
  final Gender? gender;
  final DateTime? dateOfBirth;
  final String? phoneNumber;
  final String? address;

  // Copy with method
  User copyWith({
    String? id,
    String? username,
    String? email,
    String? name,
    String? avatar,
    String? coverImage,
    String? bio,
    UserRole? role,
    UserStatus? status,
    String? countryId,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastLoginAt,
    bool? isVerified,
    bool? isEmailVerified,
    bool? isPhoneVerified,
    bool? isTwoFactorEnabled,
    UserBadge? badge,
    Map<String, dynamic>? metadata,
    UserStats? stats,
    UserSettings? settings,
    SocialLinks? socialLinks,
    Gender? gender,
    DateTime? dateOfBirth,
    String? phoneNumber,
    String? address,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      coverImage: coverImage ?? this.coverImage,
      bio: bio ?? this.bio,
      role: role ?? this.role,
      status: status ?? this.status,
      countryId: countryId ?? this.countryId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      isVerified: isVerified ?? this.isVerified,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
      isTwoFactorEnabled: isTwoFactorEnabled ?? this.isTwoFactorEnabled,
      badge: badge ?? this.badge,
      metadata: metadata ?? this.metadata,
      stats: stats ?? this.stats,
      settings: settings ?? this.settings,
      socialLinks: socialLinks ?? this.socialLinks,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
    );
  }

  // Role-based navigation
  String get homeRoute {
    switch (role) {
      case UserRole.admin:
        return '/admin/dashboard';
      case UserRole.countryManager:
        return '/country-manager/dashboard';
      case UserRole.agency:
        return '/agency/dashboard';
      case UserRole.coinSeller:
        return '/coin-seller/dashboard';
      case UserRole.host:
        return '/host/dashboard';
      default:
        return '/home';
    }
  }

  // Role-based permissions
  bool canAccess(String feature) {
    switch (role) {
      case UserRole.admin:
        return true; // Admin can access everything
      case UserRole.countryManager:
        return <String>['agencies', 'hosts', 'reports', 'issues', 'recruitment'].contains(feature);
      case UserRole.agency:
        return <String>['hosts', 'earnings', 'commission', 'recruit'].contains(feature);
      case UserRole.coinSeller:
        return <String>['inventory', 'transfers', 'earnings', 'packages'].contains(feature);
      case UserRole.host:
        return <String>['rooms', 'earnings', 'analytics', 'schedule'].contains(feature);
      default:
        return <String>['games', 'wallet', 'profile', 'friends', 'rooms'].contains(feature);
    }
  }

  // Display name with fallback
  String get displayName => name.isNotEmpty ? name : username;

  // Initials for avatar
  String get initials {
    if (name.isNotEmpty) {
      final var nameParts = name.split(' ');
      if (nameParts.length > 1) {
        return '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase();
      }
      return name[0].toUpperCase();
    }
    return username[0].toUpperCase();
  }

  // JSON serialization
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'username': username,
      'email': email,
      'name': name,
      'avatar': avatar,
      'coverImage': coverImage,
      'bio': bio,
      'role': role.toString(),
      'status': status.toString(),
      'countryId': countryId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
      'isVerified': isVerified,
      'isEmailVerified': isEmailVerified,
      'isPhoneVerified': isPhoneVerified,
      'isTwoFactorEnabled': isTwoFactorEnabled,
      'badge': badge?.toJson(),
      'metadata': metadata,
      'stats': stats?.toJson(),
      'settings': settings?.toJson(),
      'socialLinks': socialLinks?.toJson(),
      'gender': gender?.toString(),
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'phoneNumber': phoneNumber,
      'address': address,
    };
  }

  // Helper methods for parsing enums
  static UserRole _parseUserRole(String role) {
    switch (role.replaceAll('UserRole.', '')) {
      case 'admin':
        return UserRole.admin;
      case 'countryManager':
        return UserRole.countryManager;
      case 'agency':
        return UserRole.agency;
      case 'coinSeller':
        return UserRole.coinSeller;
      case 'host':
        return UserRole.host;
      default:
        return UserRole.user;
    }
  }

  static UserStatus _parseUserStatus(String status) {
    switch (status.replaceAll('UserStatus.', '')) {
      case 'active':
        return UserStatus.active;
      case 'inactive':
        return UserStatus.inactive;
      case 'banned':
        return UserStatus.banned;
      case 'suspended':
        return UserStatus.suspended;
      case 'pending':
        return UserStatus.pending;
      case 'verified':
        return UserStatus.verified;
      default:
        return UserStatus.active;
    }
  }

  static Gender _parseGender(String gender) {
    switch (gender.replaceAll('Gender.', '')) {
      case 'male':
        return Gender.male;
      case 'female':
        return Gender.female;
      case 'other':
        return Gender.other;
      default:
        return Gender.preferNotToSay;
    }
  }
}

// User Badge Class
class UserBadge {

  UserBadge({
    required this.type,
    this.agencyId,
    this.sellerId,
    this.assignedAt,
    this.isVerified = false,
  });

  factory UserBadge.fromJson(Map<String, dynamic> json) {
    return UserBadge(
      type: _parseBadgeType(json['type']),
      agencyId: json['agencyId'],
      sellerId: json['sellerId'],
      assignedAt: json['assignedAt'] != null ? DateTime.parse(json['assignedAt']) : null,
      isVerified: json['isVerified'] ?? false,
    );
  }
  final BadgeType type;
  final String? agencyId;
  final String? sellerId;
  final DateTime? assignedAt;
  final bool isVerified;

  bool get hasBadge => type != BadgeType.none;
  
  String get badgeName {
    switch (type) {
      case BadgeType.agency:
        return 'Official Agency';
      case BadgeType.coinSeller:
        return 'Coin Seller';
      case BadgeType.official:
        return 'Official';
      case BadgeType.vip:
        return 'VIP';
      case BadgeType.host:
        return 'Host';
      case BadgeType.moderator:
        return 'Moderator';
      case BadgeType.streamer:
        return 'Streamer';
      default:
        return '';
    }
  }

  Color get badgeColor {
    switch (type) {
      case BadgeType.agency:
        return const Color(0xFF9C27B0); // Purple
      case BadgeType.coinSeller:
        return const Color(0xFFFF9800); // Orange
      case BadgeType.official:
        return const Color(0xFF2196F3); // Blue
      case BadgeType.vip:
        return const Color(0xFFF44336); // Red
      case BadgeType.host:
        return const Color(0xFFE91E63); // Pink
      case BadgeType.moderator:
        return const Color(0xFF4CAF50); // Green
      case BadgeType.streamer:
        return const Color(0xFF673AB7); // Deep Purple
      default:
        return Colors.grey;
    }
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'type': type.toString(),
      'agencyId': agencyId,
      'sellerId': sellerId,
      'assignedAt': assignedAt?.toIso8601String(),
      'isVerified': isVerified,
    };
  }

  static BadgeType _parseBadgeType(String type) {
    switch (type.replaceAll('BadgeType.', '')) {
      case 'agency':
        return BadgeType.agency;
      case 'coinSeller':
        return BadgeType.coinSeller;
      case 'official':
        return BadgeType.official;
      case 'vip':
        return BadgeType.vip;
      case 'host':
        return BadgeType.host;
      case 'moderator':
        return BadgeType.moderator;
      case 'streamer':
        return BadgeType.streamer;
      default:
        return BadgeType.none;
    }
  }
}

// User Stats Class
class UserStats {

  UserStats({
    this.followers = 0,
    this.following = 0,
    this.friends = 0,
    this.totalRooms = 0,
    this.totalHours = 0,
    this.totalGifts = 0,
    this.totalGiftsReceived = 0,
    this.totalGiftsSent = 0,
    this.totalEarnings = 0,
    this.totalSpent = 0,
    this.totalWithdrawn = 0,
    this.coinBalance = 0,
    this.diamondBalance = 0,
    this.level = 1,
    this.xp = 0,
    this.xpToNextLevel = 100,
    this.streak = 0,
    this.longestStreak = 0,
    this.rating = 0,
    this.rank = 0,
    this.achievements = 0,
    this.badges = 0,
    this.lastActive,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      followers: json['followers'] ?? 0,
      following: json['following'] ?? 0,
      friends: json['friends'] ?? 0,
      totalRooms: json['totalRooms'] ?? 0,
      totalHours: json['totalHours'] ?? 0,
      totalGifts: json['totalGifts'] ?? 0,
      totalGiftsReceived: json['totalGiftsReceived'] ?? 0,
      totalGiftsSent: json['totalGiftsSent'] ?? 0,
      totalEarnings: (json['totalEarnings'] ?? 0).toDouble(),
      totalSpent: (json['totalSpent'] ?? 0).toDouble(),
      totalWithdrawn: (json['totalWithdrawn'] ?? 0).toDouble(),
      coinBalance: (json['coinBalance'] ?? 0).toDouble(),
      diamondBalance: (json['diamondBalance'] ?? 0).toDouble(),
      level: json['level'] ?? 1,
      xp: json['xp'] ?? 0,
      xpToNextLevel: json['xpToNextLevel'] ?? 100,
      streak: json['streak'] ?? 0,
      longestStreak: json['longestStreak'] ?? 0,
      rating: (json['rating'] ?? 0).toDouble(),
      rank: json['rank'] ?? 0,
      achievements: json['achievements'] ?? 0,
      badges: json['badges'] ?? 0,
      lastActive: json['lastActive'] != null ? DateTime.parse(json['lastActive']) : null,
    );
  }
  final int followers;
  final int following;
  final int friends;
  final int totalRooms;
  final int totalHours;
  final int totalGifts;
  final int totalGiftsReceived;
  final int totalGiftsSent;
  final double totalEarnings;
  final double totalSpent;
  final double totalWithdrawn;
  final double coinBalance;
  final double diamondBalance;
  final int level;
  final int xp;
  final int xpToNextLevel;
  final int streak;
  final int longestStreak;
  final double rating;
  final int rank;
  final int achievements;
  final int badges;
  final DateTime? lastActive;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'followers': followers,
      'following': following,
      'friends': friends,
      'totalRooms': totalRooms,
      'totalHours': totalHours,
      'totalGifts': totalGifts,
      'totalGiftsReceived': totalGiftsReceived,
      'totalGiftsSent': totalGiftsSent,
      'totalEarnings': totalEarnings,
      'totalSpent': totalSpent,
      'totalWithdrawn': totalWithdrawn,
      'coinBalance': coinBalance,
      'diamondBalance': diamondBalance,
      'level': level,
      'xp': xp,
      'xpToNextLevel': xpToNextLevel,
      'streak': streak,
      'longestStreak': longestStreak,
      'rating': rating,
      'rank': rank,
      'achievements': achievements,
      'badges': badges,
      'lastActive': lastActive?.toIso8601String(),
    };
  }
}

// User Settings Class
class UserSettings {

  UserSettings({
    this.notifications = true,
    this.soundEnabled = true,
    this.vibrationEnabled = true,
    this.darkMode = false,
    this.language = 'en',
    this.privateAccount = false,
    this.showOnlineStatus = true,
    this.allowFriendRequests = true,
    this.allowMessages = true,
    this.allowGifts = true,
    this.allowComments = true,
    this.saveHistory = true,
    this.autoPlay = true,
    this.videoQuality = 720,
    this.theme,
  });

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      notifications: json['notifications'] ?? true,
      soundEnabled: json['soundEnabled'] ?? true,
      vibrationEnabled: json['vibrationEnabled'] ?? true,
      darkMode: json['darkMode'] ?? false,
      language: json['language'] ?? 'en',
      privateAccount: json['privateAccount'] ?? false,
      showOnlineStatus: json['showOnlineStatus'] ?? true,
      allowFriendRequests: json['allowFriendRequests'] ?? true,
      allowMessages: json['allowMessages'] ?? true,
      allowGifts: json['allowGifts'] ?? true,
      allowComments: json['allowComments'] ?? true,
      saveHistory: json['saveHistory'] ?? true,
      autoPlay: json['autoPlay'] ?? true,
      videoQuality: json['videoQuality'] ?? 720,
      theme: json['theme'],
    );
  }
  final bool notifications;
  final bool soundEnabled;
  final bool vibrationEnabled;
  final bool darkMode;
  final String language;
  final bool privateAccount;
  final bool showOnlineStatus;
  final bool allowFriendRequests;
  final bool allowMessages;
  final bool allowGifts;
  final bool allowComments;
  final bool saveHistory;
  final bool autoPlay;
  final int videoQuality;
  final String? theme;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'notifications': notifications,
      'soundEnabled': soundEnabled,
      'vibrationEnabled': vibrationEnabled,
      'darkMode': darkMode,
      'language': language,
      'privateAccount': privateAccount,
      'showOnlineStatus': showOnlineStatus,
      'allowFriendRequests': allowFriendRequests,
      'allowMessages': allowMessages,
      'allowGifts': allowGifts,
      'allowComments': allowComments,
      'saveHistory': saveHistory,
      'autoPlay': autoPlay,
      'videoQuality': videoQuality,
      'theme': theme,
    };
  }
}

// Social Links Class
class SocialLinks {

  SocialLinks({
    this.facebook,
    this.instagram,
    this.twitter,
    this.youtube,
    this.tiktok,
    this.snapchat,
    this.discord,
    this.telegram,
    this.whatsapp,
    this.website,
  });

  factory SocialLinks.fromJson(Map<String, dynamic> json) {
    return SocialLinks(
      facebook: json['facebook'],
      instagram: json['instagram'],
      twitter: json['twitter'],
      youtube: json['youtube'],
      tiktok: json['tiktok'],
      snapchat: json['snapchat'],
      discord: json['discord'],
      telegram: json['telegram'],
      whatsapp: json['whatsapp'],
      website: json['website'],
    );
  }
  final String? facebook;
  final String? instagram;
  final String? twitter;
  final String? youtube;
  final String? tiktok;
  final String? snapchat;
  final String? discord;
  final String? telegram;
  final String? whatsapp;
  final String? website;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'facebook': facebook,
      'instagram': instagram,
      'twitter': twitter,
      'youtube': youtube,
      'tiktok': tiktok,
      'snapchat': snapchat,
      'discord': discord,
      'telegram': telegram,
      'whatsapp': whatsapp,
      'website': website,
    };
  }
}

// Level Calculator Extension
extension LevelCalculator on UserStats {
  int get currentLevel {
    // Level calculation formula
    return level;
  }

  double get levelProgress {
    return xp / xpToNextLevel;
  }

  int get xpNeededForNextLevel {
    return xpToNextLevel - xp;
  }
}

// User Achievement Class
class UserAchievement {

  UserAchievement({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.earnedAt,
    required this.xpReward,
  });

  factory UserAchievement.fromJson(Map<String, dynamic> json) {
    return UserAchievement(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      icon: json['icon'],
      earnedAt: DateTime.parse(json['earnedAt']),
      xpReward: json['xpReward'],
    );
  }
  final String id;
  final String name;
  final String description;
  final String icon;
  final DateTime earnedAt;
  final int xpReward;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
      'earnedAt': earnedAt.toIso8601String(),
      'xpReward': xpReward,
    };
  }
}

// User Friend Class
class UserFriend {

  UserFriend({
    required this.userId,
    required this.username,
    required this.name,
    required this.isOnline, required this.isFollowing, required this.isFollower, required this.isMutual, this.avatar,
    this.lastActive,
    this.friendSince,
  });

  factory UserFriend.fromJson(Map<String, dynamic> json) {
    return UserFriend(
      userId: json['userId'],
      username: json['username'],
      name: json['name'],
      avatar: json['avatar'],
      isOnline: json['isOnline'] ?? false,
      lastActive: json['lastActive'] != null ? DateTime.parse(json['lastActive']) : null,
      isFollowing: json['isFollowing'] ?? false,
      isFollower: json['isFollower'] ?? false,
      isMutual: json['isMutual'] ?? false,
      friendSince: json['friendSince'] != null ? DateTime.parse(json['friendSince']) : null,
    );
  }
  final String userId;
  final String username;
  final String name;
  final String? avatar;
  final bool isOnline;
  final DateTime? lastActive;
  final bool isFollowing;
  final bool isFollower;
  final bool isMutual;
  final DateTime? friendSince;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'userId': userId,
      'username': username,
      'name': name,
      'avatar': avatar,
      'isOnline': isOnline,
      'lastActive': lastActive?.toIso8601String(),
      'isFollowing': isFollowing,
      'isFollower': isFollower,
      'isMutual': isMutual,
      'friendSince': friendSince?.toIso8601String(),
    };
  }
}