import '../../../core/models/platform_models.dart';

enum HostStatus { active, inactive, blocked, pending }
enum RoomType { voice, video, text }
enum GiftType { coin, diamond, special }

class Host {

  Host({
    required this.id,
    required this.userId,
    required this.name,
    required this.username,
    required this.agencyId, required this.agencyName, required this.joinedDate, required this.status, required this.followers, required this.following, required this.totalGifts, required this.totalEarnings, required this.monthlyEarnings, required this.weeklyEarnings, required this.todayEarnings, required this.rating, required this.totalRooms, required this.totalHours, required this.avgViewers, required this.peakViewers, required this.agencyCommissionRate, required this.platformCommissionRate, required this.pendingWithdrawal, required this.availableBalance, required this.currentStreak, required this.longestStreak, required this.totalStreakRewards, required this.badges, required this.specialties, this.avatar,
    this.bio,
  });
  final String id;
  final String userId;
  final String name;
  final String username;
  final String? avatar;
  final String? bio;
  final String agencyId;
  final String agencyName;
  final DateTime joinedDate;
  final HostStatus status;
  
  // Stats
  final int followers;
  final int following;
  final int totalGifts;
  final double totalEarnings;
  final double monthlyEarnings;
  final double weeklyEarnings;
  final double todayEarnings;
  
  // Performance
  final double rating;
  final int totalRooms;
  final int totalHours;
  final int avgViewers;
  final int peakViewers;
  
  // Commission
  final double agencyCommissionRate;
  final double platformCommissionRate;
  final double pendingWithdrawal;
  final double availableBalance;
  
  // Streaks
  final int currentStreak;
  final int longestStreak;
  final int totalStreakRewards;
  
  // Badges
  final List<HostBadge> badges;
  final List<String> specialties;
}

class HostBadge {

  HostBadge({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.earnedDate,
    required this.description,
  });
  final String id;
  final String name;
  final String icon;
  final Color color;
  final DateTime earnedDate;
  final String description;
}

class HostRoom {

  HostRoom({
    required this.id,
    required this.hostId,
    required this.title,
    required this.type,
    required this.startTime,
    required this.maxViewers, required this.currentViewers, required this.peakViewers, required this.totalGifts, required this.earnings, required this.status, required this.tags, required this.isPrivate, this.endTime,
    this.password,
  });
  final String id;
  final String hostId;
  final String title;
  final RoomType type;
  final DateTime startTime;
  final DateTime? endTime;
  final int maxViewers;
  final int currentViewers;
  final int peakViewers;
  final int totalGifts;
  final double earnings;
  final RoomStatus status;
  final List<String> tags;
  final bool isPrivate;
  final String? password;
}

enum RoomStatus { scheduled, live, ended, cancelled }

class HostGift {

  HostGift({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.giftType,
    required this.amount,
    required this.value,
    required this.timestamp,
    this.message,
  });
  final String id;
  final String senderId;
  final String senderName;
  final String giftType;
  final int amount;
  final double value;
  final DateTime timestamp;
  final String? message;
}

class HostFollower {

  HostFollower({
    required this.userId,
    required this.username,
    required this.followedDate, required this.isFollowing, this.avatar,
  });
  final String userId;
  final String username;
  final String? avatar;
  final DateTime followedDate;
  final bool isFollowing;
}

class HostEarning {

  HostEarning({
    required this.id,
    required this.type,
    required this.amount,
    required this.source,
    required this.date,
    required this.status,
  });
  final String id;
  final EarningType type;
  final double amount;
  final String source;
  final DateTime date;
  final EarningStatus status;
}

enum EarningType { gift, room, bonus, commission, streak }
enum EarningStatus { pending, available, withdrawn }

class HostAnalytics {

  HostAnalytics({
    required this.hourlyViewers,
    required this.hourlyEarnings,
    required this.dailyStats,
    required this.giftCategories,
    required this.topGiftGivers,
    required this.revenueByHour,
  });
  final Map<String, int> hourlyViewers;
  final Map<String, double> hourlyEarnings;
  final List<DailyStats> dailyStats;
  final Map<String, int> giftCategories;
  final List<String> topGiftGivers;
  final Map<String, double> revenueByHour;
}

class DailyStats {

  DailyStats({
    required this.date,
    required this.viewers,
    required this.earnings,
    required this.gifts,
    required this.hours,
  });
  final DateTime date;
  final int viewers;
  final double earnings;
  final int gifts;
  final int hours;
}

class HostSchedule {

  HostSchedule({
    required this.id,
    required this.title,
    required this.startTime,
    required this.endTime,
    required this.type,
    required this.isRecurring,
    this.recurringPattern,
  });
  final String id;
  final String title;
  final DateTime startTime;
  final DateTime endTime;
  final RoomType type;
  final bool isRecurring;
  final String? recurringPattern;
}