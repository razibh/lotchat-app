import '../../core/models/user_model.dart';

enum ProfileVisibility {
  public,
  friends,
  private
}

class ProfileModel {

  ProfileModel({
    required this.userId,
    required this.username,
    this.displayName,
    this.bio,
    this.avatar,
    this.coverImage,
    this.location,
    this.website,
    this.birthDate,
    this.gender,
    this.interests = const [],
    this.visibility = ProfileVisibility.public,
    this.privacySettings = const {},
    required this.joinedAt,
    this.lastActive,
    this.isOnline = false,
    this.followersCount = 0,
    this.followingCount = 0,
    this.friendsCount = 0,
    this.postsCount = 0,
    this.giftsReceived = 0,
    this.giftsSent = 0,
    this.gamesPlayed = 0,
    this.gamesWon = 0,
    this.totalCoins = 0,
    this.totalDiamonds = 0,
    this.level = 1,
    this.xp = 0,
    this.xpToNextLevel = 1000,
    this.badges = const [],
    this.currentFrame,
    this.customFields = const {},
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      userId: json['userId'],
      username: json['username'],
      displayName: json['displayName'],
      bio: json['bio'],
      avatar: json['avatar'],
      coverImage: json['coverImage'],
      location: json['location'],
      website: json['website'],
      birthDate: json['birthDate'] != null 
          ? DateTime.parse(json['birthDate']) 
          : null,
      gender: json['gender'],
      interests: List<String>.from(json['interests'] ?? []),
      visibility: ProfileVisibility.values[json['visibility'] ?? 0],
      privacySettings: Map<String, bool>.from(json['privacySettings'] ?? {}),
      joinedAt: DateTime.parse(json['joinedAt']),
      lastActive: json['lastActive'] != null 
          ? DateTime.parse(json['lastActive']) 
          : null,
      isOnline: json['isOnline'] ?? false,
      followersCount: json['followersCount'] ?? 0,
      followingCount: json['followingCount'] ?? 0,
      friendsCount: json['friendsCount'] ?? 0,
      postsCount: json['postsCount'] ?? 0,
      giftsReceived: json['giftsReceived'] ?? 0,
      giftsSent: json['giftsSent'] ?? 0,
      gamesPlayed: json['gamesPlayed'] ?? 0,
      gamesWon: json['gamesWon'] ?? 0,
      totalCoins: json['totalCoins'] ?? 0,
      totalDiamonds: json['totalDiamonds'] ?? 0,
      level: json['level'] ?? 1,
      xp: json['xp'] ?? 0,
      xpToNextLevel: json['xpToNextLevel'] ?? 1000,
      badges: List<String>.from(json['badges'] ?? []),
      currentFrame: json['currentFrame'],
      customFields: json['customFields'] ?? {},
    );
  }
  final String userId;
  final String username;
  final String? displayName;
  final String? bio;
  final String? avatar;
  final String? coverImage;
  final String? location;
  final String? website;
  final DateTime? birthDate;
  final String? gender;
  final List<String> interests;
  final ProfileVisibility visibility;
  final Map<String, bool> privacySettings;
  final DateTime joinedAt;
  final DateTime? lastActive;
  final bool isOnline;
  final int followersCount;
  final int followingCount;
  final int friendsCount;
  final int postsCount;
  final int giftsReceived;
  final int giftsSent;
  final int gamesPlayed;
  final int gamesWon;
  final int totalCoins;
  final int totalDiamonds;
  final int level;
  final int xp;
  final int xpToNextLevel;
  final List<String> badges;
  final String? currentFrame;
  final Map<String, dynamic> customFields;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'userId': userId,
    'username': username,
    'displayName': displayName,
    'bio': bio,
    'avatar': avatar,
    'coverImage': coverImage,
    'location': location,
    'website': website,
    'birthDate': birthDate?.toIso8601String(),
    'gender': gender,
    'interests': interests,
    'visibility': visibility.index,
    'privacySettings': privacySettings,
    'joinedAt': joinedAt.toIso8601String(),
    'lastActive': lastActive?.toIso8601String(),
    'isOnline': isOnline,
    'followersCount': followersCount,
    'followingCount': followingCount,
    'friendsCount': friendsCount,
    'postsCount': postsCount,
    'giftsReceived': giftsReceived,
    'giftsSent': giftsSent,
    'gamesPlayed': gamesPlayed,
    'gamesWon': gamesWon,
    'totalCoins': totalCoins,
    'totalDiamonds': totalDiamonds,
    'level': level,
    'xp': xp,
    'xpToNextLevel': xpToNextLevel,
    'badges': badges,
    'currentFrame': currentFrame,
    'customFields': customFields,
  };

  // Computed properties
  String get displayNameOrUsername => displayName ?? username;
  
  double get xpProgress => xp / xpToNextLevel;
  
  int get totalGifts => giftsReceived + giftsSent;
  
  double get winRate => gamesPlayed > 0 ? gamesWon / gamesPlayed : 0;

  // Check if profile is complete
  bool get isProfileComplete {
    return avatar != null &&
           bio != null &&
           bio!.isNotEmpty &&
           interests.isNotEmpty;
  }

  // Get age
  int? get age {
    if (birthDate == null) return null;
    final DateTime now = DateTime.now();
    var age = now.year - birthDate!.year;
    if (now.month < birthDate!.month || 
        (now.month == birthDate!.month && now.day < birthDate!.day)) {
      age--;
    }
    return age;
  }

  // Get zodiac sign
  String? get zodiacSign {
    if (birthDate == null) return null;
    final int month = birthDate!.month;
    final int day = birthDate!.day;

    if ((month == 3 && day >= 21) || (month == 4 && day <= 19)) return 'Aries';
    if ((month == 4 && day >= 20) || (month == 5 && day <= 20)) return 'Taurus';
    if ((month == 5 && day >= 21) || (month == 6 && day <= 20)) return 'Gemini';
    if ((month == 6 && day >= 21) || (month == 7 && day <= 22)) return 'Cancer';
    if ((month == 7 && day >= 23) || (month == 8 && day <= 22)) return 'Leo';
    if ((month == 8 && day >= 23) || (month == 9 && day <= 22)) return 'Virgo';
    if ((month == 9 && day >= 23) || (month == 10 && day <= 22)) return 'Libra';
    if ((month == 10 && day >= 23) || (month == 11 && day <= 21)) return 'Scorpio';
    if ((month == 11 && day >= 22) || (month == 12 && day <= 21)) return 'Sagittarius';
    if ((month == 12 && day >= 22) || (month == 1 && day <= 19)) return 'Capricorn';
    if ((month == 1 && day >= 20) || (month == 2 && day <= 18)) return 'Aquarius';
    if ((month == 2 && day >= 19) || (month == 3 && day <= 20)) return 'Pisces';
    
    return null;
  }
}

class ProfileUpdateModel {

  ProfileUpdateModel({
    this.displayName,
    this.bio,
    this.location,
    this.website,
    this.birthDate,
    this.gender,
    this.interests,
    this.visibility,
    this.privacySettings,
    this.avatar,
    this.coverImage,
    this.customFields,
  });
  String? displayName;
  String? bio;
  String? location;
  String? website;
  DateTime? birthDate;
  String? gender;
  List<String>? interests;
  ProfileVisibility? visibility;
  Map<String, bool>? privacySettings;
  String? avatar;
  String? coverImage;
  Map<String, dynamic>? customFields;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{};
    
    if (displayName != null) json['displayName'] = displayName;
    if (bio != null) json['bio'] = bio;
    if (location != null) json['location'] = location;
    if (website != null) json['website'] = website;
    if (birthDate != null) json['birthDate'] = birthDate!.toIso8601String();
    if (gender != null) json['gender'] = gender;
    if (interests != null) json['interests'] = interests;
    if (visibility != null) json['visibility'] = visibility!.index;
    if (privacySettings != null) json['privacySettings'] = privacySettings;
    if (avatar != null) json['avatar'] = avatar;
    if (coverImage != null) json['coverImage'] = coverImage;
    if (customFields != null) json['customFields'] = customFields;
    
    return json;
  }
}