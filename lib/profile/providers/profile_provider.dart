import 'package:flutter/material.dart';
import '../models/profile_model.dart';
import '../models/badge_model.dart';
import '../models/frame_model.dart';
import '../models/achievement_model.dart';
import '../../../core/services/database_service.dart';
import '../../../core/di/service_locator.dart';

class ProfileProvider extends ChangeNotifier {
  final DatabaseService _databaseService = ServiceLocator().get<DatabaseService>();
  
  ProfileModel? _profile;
  List<BadgeModel> _badges = <BadgeModel>[];
  List<FrameModel> _frames = <FrameModel>[];
  List<UserFrame> _ownedFrames = <UserFrame>[];
  List<AchievementModel> _achievements = <AchievementModel>[];
  
  bool _isLoading = false;
  bool _isLoadingBadges = false;
  bool _isLoadingFrames = false;
  bool _isLoadingAchievements = false;
  String? _error;

  // Getters
  ProfileModel? get profile => _profile;
  List<BadgeModel> get badges => _badges;
  List<FrameModel> get frames => _frames;
  List<UserFrame> get ownedFrames => _ownedFrames;
  List<AchievementModel> get achievements => _achievements;
  
  bool get isLoading => _isLoading;
  bool get isLoadingBadges => _isLoadingBadges;
  bool get isLoadingFrames => _isLoadingFrames;
  bool get isLoadingAchievements => _isLoadingAchievements;
  String? get error => _error;

  // Load profile
  Future<void> loadProfile(String? userId) async {
    if (userId == null) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // In real app, load from service
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock data
      _profile = ProfileModel(
        userId: userId,
        username: 'john_doe',
        displayName: 'John Doe',
        bio: 'Live life to the fullest! 🌟',
        avatar: 'https://i.pravatar.cc/300?u=$userId',
        coverImage: 'https://picsum.photos/800/200?random=$userId',
        location: 'New York, USA',
        website: 'https://johndoe.com',
        birthDate: DateTime(1990),
        gender: 'Male',
        interests: <String>['Music', 'Travel', 'Gaming', 'Photography'],
        joinedAt: DateTime(2020),
        isOnline: true,
        followersCount: 1234,
        followingCount: 567,
        friendsCount: 89,
        postsCount: 42,
        giftsReceived: 150,
        giftsSent: 75,
        gamesPlayed: 200,
        gamesWon: 150,
        totalCoins: 15000,
        totalDiamonds: 500,
        level: 25,
        xp: 2500,
        xpToNextLevel: 3000,
        badges: <String>['badge1', 'badge2'],
        currentFrame: 'frame1',
      );

      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update profile
  Future<void> updateProfile(ProfileUpdateModel updates) async {
    _isLoading = true;
    notifyListeners();

    try {
      // In real app, update in service
      await Future.delayed(const Duration(seconds: 1));
      
      // Update local profile
      if (_profile != null) {
        if (updates.displayName != null) _profile = _profile!.copyWith(displayName: updates.displayName);
        if (updates.bio != null) _profile = _profile!.copyWith(bio: updates.bio);
        if (updates.location != null) _profile = _profile!.copyWith(location: updates.location);
        if (updates.website != null) _profile = _profile!.copyWith(website: updates.website);
        if (updates.birthDate != null) _profile = _profile!.copyWith(birthDate: updates.birthDate);
        if (updates.gender != null) _profile = _profile!.copyWith(gender: updates.gender);
        if (updates.interests != null) _profile = _profile!.copyWith(interests: updates.interests);
        if (updates.avatar != null) _profile = _profile!.copyWith(avatar: updates.avatar);
        if (updates.coverImage != null) _profile = _profile!.copyWith(coverImage: updates.coverImage);
      }

      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load badges
  Future<void> loadBadges(String userId) async {
    _isLoadingBadges = true;
    notifyListeners();

    try {
      // In real app, load from service
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock data
      _badges = List.generate(10, (int index) {
        return BadgeModel(
          id: 'badge_$index',
          name: 'Badge ${index + 1}',
          description: 'Description for badge ${index + 1}',
          rarity: BadgeRarity.values[index % 5],
          category: BadgeCategory.values[index % 4],
          iconUrl: 'https://via.placeholder.com/50',
          acquiredAt: index % 3 == 0 ? DateTime.now() : null,
          isEquipped: index == 0,
          requirements: <String, dynamic>{'points': 100 * (index + 1)},
        );
      });
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoadingBadges = false;
      notifyListeners();
    }
  }

  // Equip badge
  Future<void> equipBadge(String badgeId) async {
    try {
      // Update local state
      for (BadgeModel badge in _badges) {
        badge.isEquipped = badge.id == badgeId;
      }
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  // Load frames
  Future<void> loadFrames(String userId) async {
    _isLoadingFrames = true;
    notifyListeners();

    try {
      // In real app, load from service
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock data
      _frames = List.generate(15, (int index) {
        return FrameModel(
          id: 'frame_$index',
          name: 'Frame ${index + 1}',
          description: 'Description for frame ${index + 1}',
          rarity: FrameRarity.values[index % 5],
          type: FrameType.values[index % 5],
          imageUrl: 'https://via.placeholder.com/150',
          price: 500 * (index + 1),
          isPurchased: index < 3,
          isEquipped: index == 0,
          requirements: <String, dynamic>{'level': index + 1},
        );
      });

      _ownedFrames = _frames
          .where((FrameModel f) => f.isPurchased)
          .map((FrameModel f) => UserFrame(
                frameId: f.id,
                acquiredAt: DateTime.now(),
                isEquipped: f.isEquipped,
              ),)
          .toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoadingFrames = false;
      notifyListeners();
    }
  }

  // Purchase frame
  Future<void> purchaseFrame(String frameId) async {
    try {
      final FrameModel frame = _frames.firstWhere((FrameModel f) => f.id == frameId);
      frame.isPurchased = true;
      
      _ownedFrames.add(UserFrame(
        frameId: frameId,
        acquiredAt: DateTime.now(),
      ),);
      
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  // Equip frame
  Future<void> equipFrame(String frameId) async {
    try {
      for (FrameModel frame in _frames) {
        frame.isEquipped = frame.id == frameId;
      }
      
      for (UserFrame owned in _ownedFrames) {
        owned.isEquipped = owned.frameId == frameId;
      }
      
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  // Load achievements
  Future<void> loadAchievements(String userId) async {
    _isLoadingAchievements = true;
    notifyListeners();

    try {
      // In real app, load from service
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock data
      _achievements = List.generate(20, (int index) {
        final bool isUnlocked = index < 8;
        return AchievementModel(
          id: 'achievement_$index',
          name: 'Achievement ${index + 1}',
          description: 'Description for achievement ${index + 1}',
          rarity: AchievementRarity.values[index % 5],
          category: AchievementCategory.values[index % 5],
          iconUrl: 'https://via.placeholder.com/50',
          xpReward: 100 * (index + 1),
          coinReward: 50 * (index + 1),
          requirements: <String, dynamic>{'count': index + 1},
          progress: isUnlocked ? 100 : index * 10,
          target: 100,
          unlockedAt: isUnlocked ? DateTime.now() : null,
          isUnlocked: isUnlocked,
        );
      });
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoadingAchievements = false;
      notifyListeners();
    }
  }
}