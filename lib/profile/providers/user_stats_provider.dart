import 'package:flutter/material.dart';

class UserStatsProvider extends ChangeNotifier {
  Map<String, dynamic> _stats = <String, dynamic>{};
  bool _isLoading = false;
  String? _error;

  // Getters
  Map<String, dynamic> get stats => _stats;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load user statistics
  Future<void> loadStats(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // In real app, load from service
      await Future.delayed(const Duration(seconds: 1));

      // Mock data
      _stats = <String, dynamic>{
        // Basic counts
        'postsCount': 42,
        'commentsCount': 156,
        'likesReceived': 1243,
        'totalViews': 5678,
        
        // Activity data for chart
        'activityData': <String, int>{
          'Mon': 12,
          'Tue': 8,
          'Wed': 15,
          'Thu': 22,
          'Fri': 18,
          'Sat': 25,
          'Sun': 30,
        },
        
        // Detailed stats
        'profileViews': 892,
        'searchAppearances': 234,
        'shareCount': 56,
        'reportsCount': 0,
        'warningsCount': 0,
        
        // Achievements
        'achievements': <String, int>{
          'total': 50,
          'unlocked': 23,
        },
        
        // Game statistics
        'games': <String, num>{
          'played': 145,
          'won': 89,
          'lost': 56,
          'totalBet': 15000,
          'totalWon': 23500,
          'winRate': 61.4,
        },
        
        // Gift statistics
        'gifts': <String, Object>{
          'sent': 75,
          'received': 120,
          'coinsSpent': 15000,
          'diamondsEarned': 7500,
          'favoriteGift': 'Diamond Ring',
          'topGifter': 'Alex',
        },
        
        // Room statistics
        'rooms': <String, int>{
          'created': 5,
          'joined': 48,
          'hosted': 12,
          'totalHours': 124,
        },
        
        // Call statistics
        'calls': <String, int>{
          'audio': 67,
          'video': 34,
          'totalMinutes': 356,
        },
        
        // Friendship stats
        'friends': <String, int>{
          'total': 89,
          'online': 23,
          'mutual': 45,
        },
        
        // Level and progression
        'level': <String, num>{
          'current': 25,
          'xp': 2500,
          'nextLevel': 3000,
          'progress': 0.83,
        },
        
        // Badges
        'badges': <String, int>{
          'total': 15,
          'equipped': 3,
          'rare': 5,
          'epic': 3,
          'legendary': 1,
        },
      };

      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load game statistics
  Future<void> loadGameStats(String userId) async {
    // Implementation for loading specific game stats
  }

  // Load gift statistics
  Future<void> loadGiftStats(String userId) async {
    // Implementation for loading specific gift stats
  }

  // Load room statistics
  Future<void> loadRoomStats(String userId) async {
    // Implementation for loading specific room stats
  }

  // Load call statistics
  Future<void> loadCallStats(String userId) async {
    // Implementation for loading specific call stats
  }

  // Get formatted stats
  String getFormattedStat(String key) {
    final value = _stats[key];
    if (value == null) return '0';

    if (value is int) {
      if (value >= 1000000) {
        return '${(value / 1000000).toStringAsFixed(1)}M';
      } else if (value >= 1000) {
        return '${(value / 1000).toStringAsFixed(1)}K';
      } else {
        return value.toString();
      }
    } else if (value is double) {
      return value.toStringAsFixed(1);
    }

    return value.toString();
  }

  // Get win rate percentage
  double getWinRate() {
    final Map<String, dynamic> games = _stats['games'] as Map<String, dynamic>? ?? <String, dynamic>{};
    final played = games['played'] ?? 0;
    final won = games['won'] ?? 0;
    return played > 0 ? (won / played) : 0.0;
  }

  // Get level progress
  double getLevelProgress() {
    final Map<String, dynamic> level = _stats['level'] as Map<String, dynamic>? ?? <String, dynamic>{};
    return level['progress'] ?? 0.0;
  }

  // Get total earnings
  int getTotalEarnings() {
    final Map<String, dynamic> gifts = _stats['gifts'] as Map<String, dynamic>? ?? <String, dynamic>{};
    return (gifts['diamondsEarned'] ?? 0) * 2; // Convert diamonds to coins
  }

  // Reset stats
  void resetStats() {
    _stats = <String, dynamic>{};
    notifyListeners();
  }

  // Update specific stat
  void updateStat(String key, dynamic value) {
    _stats[key] = value;
    notifyListeners();
  }

  // Increment stat
  void incrementStat(String key, [int amount = 1]) {
    if (_stats[key] is int) {
      _stats[key] = (_stats[key] as int) + amount;
    } else {
      _stats[key] = amount;
    }
    notifyListeners();
  }
}