import 'package:flutter/material.dart';
import '../models/profile_model.dart';
import '../../core/models/badge_model.dart';
import '../../core/models/frame_model.dart';

import '../models/achievement_model.dart';
import '../../core/services/database_service.dart';
import '../../core/di/service_locator.dart';

class ProfileProvider extends ChangeNotifier {
  final DatabaseService _databaseService = ServiceLocator.instance.get<DatabaseService>();

  ProfileModel? _profile;
  List<BadgeModel> _badges = [];
  List<FrameModel> _frames = [];
  List<UserFrame> _ownedFrames = [];
  List<AchievementModel> _achievements = [];

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
        birthDate: DateTime(1990, 1, 1),
        gender: 'Male',
        interests: ['Music', 'Travel', 'Gaming', 'Photography'],
        joinedAt: DateTime(2020, 1, 1),
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
        badges: ['badge1', 'badge2'],
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
        _profile = _profile!.copyWith(
          displayName: updates.displayName ?? _profile!.displayName,
          bio: updates.bio ?? _profile!.bio,
          location: updates.location ?? _profile!.location,
          website: updates.website ?? _profile!.website,
          birthDate: updates.birthDate ?? _profile!.birthDate,
          gender: updates.gender ?? _profile!.gender,
          interests: updates.interests ?? _profile!.interests,
          avatar: updates.avatar ?? _profile!.avatar,
          coverImage: updates.coverImage ?? _profile!.coverImage,
        );
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
        final bool isAcquired = index % 3 == 0;
        return BadgeModel(
          id: 'badge_$index',
          name: 'Badge ${index + 1}',
          description: 'Description for badge ${index + 1}',
          type: BadgeType.values[index % BadgeType.values.length],
          tier: index + 1,
          svgPath: 'assets/badges/badge_$index.svg',
          rarity: BadgeRarity.values[index % 5],
          level: index + 1,
          isHidden: false,
          acquiredAt: isAcquired ? DateTime.now() : null,
          isEquipped: index == 0 && isAcquired,
          requirements: {'points': 100 * (index + 1)},
          expiryDays: 0,
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
      _badges = _badges.map((badge) {
        return badge.copyWith(
          isEquipped: badge.id == badgeId,
        );
      }).toList();

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
        final bool isPurchased = index < 3;
        return FrameModel(
          id: 'frame_$index',
          name: 'Frame ${index + 1}',
          description: 'Description for frame ${index + 1}',
          rarity: FrameRarity.values[index % 5],
          type: FrameType.values[index % 5],
          imageUrl: 'https://via.placeholder.com/150',
          price: 500 * (index + 1),
          isPurchased: isPurchased,
          isEquipped: index == 0 && isPurchased,
          requirements: {'level': index + 1},
          isAnimated: index % 3 == 0,
          borderColor: Colors.purple,
          borderWidth: 2.0,
        );
      });

      _ownedFrames = _frames
          .where((FrameModel f) => f.isPurchased)
          .map((FrameModel f) => UserFrame(
        frameId: f.id,
        acquiredAt: DateTime.now(),
        isEquipped: f.isEquipped,
      ))
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
      final index = _frames.indexWhere((FrameModel f) => f.id == frameId);
      if (index != -1) {
        _frames[index] = _frames[index].copyWith(isPurchased: true);

        _ownedFrames.add(UserFrame(
          frameId: frameId,
          acquiredAt: DateTime.now(),
        ));

        notifyListeners();
      }
    } catch (e) {
      rethrow;
    }
  }

  // Equip frame
  Future<void> equipFrame(String frameId) async {
    try {
      _frames = _frames.map((frame) {
        return frame.copyWith(
          isEquipped: frame.id == frameId,
        );
      }).toList();

      _ownedFrames = _ownedFrames.map((owned) {
        return owned.copyWith(
          isEquipped: owned.frameId == frameId,
        );
      }).toList();

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
          badgeReward: isUnlocked ? 'badge_$index' : null,
          requirements: {'count': index + 1},
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

  // Get equipped frame
  FrameModel? get equippedFrame {
    return _frames.firstWhere(
          (frame) => frame.isEquipped,
      orElse: () => _frames.isNotEmpty ? _frames.first : null as FrameModel,
    );
  }

  // Get equipped badge
  BadgeModel? get equippedBadge {
    return _badges.firstWhere(
          (badge) => badge.isEquipped,
      orElse: () => _badges.isNotEmpty ? _badges.first : null as BadgeModel,
    );
  }

  // Get unlocked achievements count
  int get unlockedAchievementsCount {
    return _achievements.where((a) => a.isUnlocked).length;
  }

  // Get total achievements count
  int get totalAchievementsCount => _achievements.length;

  // Get completion percentage
  double get completionPercentage {
    if (_achievements.isEmpty) return 0.0;
    return unlockedAchievementsCount / _achievements.length;
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Refresh all data
  Future<void> refreshAll(String userId) async {
    await Future.wait([
      loadProfile(userId),
      loadBadges(userId),
      loadFrames(userId),
      loadAchievements(userId),
    ]);
  }
}