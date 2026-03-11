class UserModel {
  String uid;
  String username;
  String email;
  String phone;
  String? photoURL;
  String? bio;
  List<String> interests;
  String country;
  String region;
  int coins;
  int diamonds;
  UserTier tier;
  UserRole role;
  String? agencyId;
  bool isOnline;
  DateTime lastActive;
  List<String> friends;
  List<String> followers;
  List<String> following;
  Map<String, dynamic> stats;

  UserModel({
    required this.uid,
    required this.username,
    required this.email,
    required this.phone,
    this.photoURL,
    this.bio,
    this.interests = const [],
    required this.country,
    required this.region,
    this.coins = 0,
    this.diamonds = 0,
    this.tier = UserTier.normal,
    this.role = UserRole.user,
    this.agencyId,
    this.isOnline = false,
    required this.lastActive,
    this.friends = const [],
    this.followers = const [],
    this.following = const [],
    this.stats = const {},
  });

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'username': username,
        'email': email,
        'phone': phone,
        'photoURL': photoURL,
        'bio': bio,
        'interests': interests,
        'country': country,
        'region': region,
        'coins': coins,
        'diamonds': diamonds,
        'tier': tier.index,
        'role': role.index,
        'agencyId': agencyId,
        'isOnline': isOnline,
        'lastActive': lastActive.toIso8601String(),
        'friends': friends,
        'followers': followers,
        'following': following,
        'stats': stats,
      };

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        uid: json['uid'],
        username: json['username'],
        email: json['email'],
        phone: json['phone'],
        photoURL: json['photoURL'],
        bio: json['bio'],
        interests: List<String>.from(json['interests'] ?? []),
        country: json['country'],
        region: json['region'],
        coins: json['coins'] ?? 0,
        diamonds: json['diamonds'] ?? 0,
        tier: UserTier.values[json['tier'] ?? 0],
        role: UserRole.values[json['role'] ?? 0],
        agencyId: json['agencyId'],
        isOnline: json['isOnline'] ?? false,
        lastActive: DateTime.parse(json['lastActive']),
        friends: List<String>.from(json['friends'] ?? []),
        followers: List<String>.from(json['followers'] ?? []),
        following: List<String>.from(json['following'] ?? []),
        stats: json['stats'] ?? {},
      );
}

enum UserTier {
  normal,
  vip1,
  vip2,
  vip3,
  vip4,
  vip5,
  vip6,
  vip7,
  vip8,
  vip9,
  vip10,
  svip1,
  svip2,
  svip3,
  svip4,
  svip5,
  svip6,
  svip7,
  svip8
}

enum UserRole { user, seller, agency, admin, superAdmin }
