import 'package:flutter/material.dart';
import '../../../core/models/platform_models.dart';

// Enums
enum HostStatus { active, inactive, blocked, pending }
enum RoomType { voice, video, chat }
enum RoomStatus { scheduled, live, ended, cancelled }
enum EarningType { gift, room, bonus, commission }
enum EarningStatus { pending, available, withdrawn }

class Host {
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

  // Badges & Specialties
  final List<HostBadge> badges;
  final List<String> specialties;

  // Additional fields for comparison (used in dashboard)
  final double yesterdayEarnings;
  final double lastWeekEarnings;
  final double lastMonthEarnings;
  final bool isVerified;

  Host({
    required this.id,
    required this.userId,
    required this.name,
    required this.username,
    this.avatar,
    this.bio,
    required this.agencyId,
    required this.agencyName,
    required this.joinedDate,
    required this.status,
    required this.followers,
    required this.following,
    required this.totalGifts,
    required this.totalEarnings,
    required this.monthlyEarnings,
    required this.weeklyEarnings,
    required this.todayEarnings,
    required this.rating,
    required this.totalRooms,
    required this.totalHours,
    required this.avgViewers,
    required this.peakViewers,
    required this.agencyCommissionRate,
    required this.platformCommissionRate,
    required this.pendingWithdrawal,
    required this.availableBalance,
    required this.currentStreak,
    required this.longestStreak,
    required this.totalStreakRewards,
    required this.badges,
    required this.specialties,
    // Optional fields with defaults
    this.yesterdayEarnings = 0,
    this.lastWeekEarnings = 0,
    this.lastMonthEarnings = 0,
    this.isVerified = false,
  });

  // CopyWith method for updating
  Host copyWith({
    String? id,
    String? userId,
    String? name,
    String? username,
    String? avatar,
    String? bio,
    String? agencyId,
    String? agencyName,
    DateTime? joinedDate,
    HostStatus? status,
    int? followers,
    int? following,
    int? totalGifts,
    double? totalEarnings,
    double? monthlyEarnings,
    double? weeklyEarnings,
    double? todayEarnings,
    double? rating,
    int? totalRooms,
    int? totalHours,
    int? avgViewers,
    int? peakViewers,
    double? agencyCommissionRate,
    double? platformCommissionRate,
    double? pendingWithdrawal,
    double? availableBalance,
    int? currentStreak,
    int? longestStreak,
    int? totalStreakRewards,
    List<HostBadge>? badges,
    List<String>? specialties,
    double? yesterdayEarnings,
    double? lastWeekEarnings,
    double? lastMonthEarnings,
    bool? isVerified,
  }) {
    return Host(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      username: username ?? this.username,
      avatar: avatar ?? this.avatar,
      bio: bio ?? this.bio,
      agencyId: agencyId ?? this.agencyId,
      agencyName: agencyName ?? this.agencyName,
      joinedDate: joinedDate ?? this.joinedDate,
      status: status ?? this.status,
      followers: followers ?? this.followers,
      following: following ?? this.following,
      totalGifts: totalGifts ?? this.totalGifts,
      totalEarnings: totalEarnings ?? this.totalEarnings,
      monthlyEarnings: monthlyEarnings ?? this.monthlyEarnings,
      weeklyEarnings: weeklyEarnings ?? this.weeklyEarnings,
      todayEarnings: todayEarnings ?? this.todayEarnings,
      rating: rating ?? this.rating,
      totalRooms: totalRooms ?? this.totalRooms,
      totalHours: totalHours ?? this.totalHours,
      avgViewers: avgViewers ?? this.avgViewers,
      peakViewers: peakViewers ?? this.peakViewers,
      agencyCommissionRate: agencyCommissionRate ?? this.agencyCommissionRate,
      platformCommissionRate: platformCommissionRate ?? this.platformCommissionRate,
      pendingWithdrawal: pendingWithdrawal ?? this.pendingWithdrawal,
      availableBalance: availableBalance ?? this.availableBalance,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      totalStreakRewards: totalStreakRewards ?? this.totalStreakRewards,
      badges: badges ?? this.badges,
      specialties: specialties ?? this.specialties,
      yesterdayEarnings: yesterdayEarnings ?? this.yesterdayEarnings,
      lastWeekEarnings: lastWeekEarnings ?? this.lastWeekEarnings,
      lastMonthEarnings: lastMonthEarnings ?? this.lastMonthEarnings,
      isVerified: isVerified ?? this.isVerified,
    );
  }
}

class HostBadge {
  final String id;
  final String name;
  final String icon;
  final Color color;
  final DateTime earnedDate;
  final String description;

  HostBadge({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.earnedDate,
    required this.description,
  });

  // CopyWith method
  HostBadge copyWith({
    String? id,
    String? name,
    String? icon,
    Color? color,
    DateTime? earnedDate,
    String? description,
  }) {
    return HostBadge(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      earnedDate: earnedDate ?? this.earnedDate,
      description: description ?? this.description,
    );
  }
}

class HostRoom {
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

  HostRoom({
    required this.id,
    required this.hostId,
    required this.title,
    required this.type,
    required this.startTime,
    this.endTime,
    required this.maxViewers,
    required this.currentViewers,
    required this.peakViewers,
    required this.totalGifts,
    required this.earnings,
    required this.status,
    required this.tags,
    required this.isPrivate,
    this.password,
  });

  // CopyWith method
  HostRoom copyWith({
    String? id,
    String? hostId,
    String? title,
    RoomType? type,
    DateTime? startTime,
    DateTime? endTime,
    int? maxViewers,
    int? currentViewers,
    int? peakViewers,
    int? totalGifts,
    double? earnings,
    RoomStatus? status,
    List<String>? tags,
    bool? isPrivate,
    String? password,
  }) {
    return HostRoom(
      id: id ?? this.id,
      hostId: hostId ?? this.hostId,
      title: title ?? this.title,
      type: type ?? this.type,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      maxViewers: maxViewers ?? this.maxViewers,
      currentViewers: currentViewers ?? this.currentViewers,
      peakViewers: peakViewers ?? this.peakViewers,
      totalGifts: totalGifts ?? this.totalGifts,
      earnings: earnings ?? this.earnings,
      status: status ?? this.status,
      tags: tags ?? this.tags,
      isPrivate: isPrivate ?? this.isPrivate,
      password: password ?? this.password,
    );
  }
}

class HostGift {
  final String id;
  final String senderId;
  final String senderName;
  final String giftType;
  final int amount;
  final double value;
  final DateTime timestamp;
  final String? message;

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

  // CopyWith method
  HostGift copyWith({
    String? id,
    String? senderId,
    String? senderName,
    String? giftType,
    int? amount,
    double? value,
    DateTime? timestamp,
    String? message,
  }) {
    return HostGift(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      giftType: giftType ?? this.giftType,
      amount: amount ?? this.amount,
      value: value ?? this.value,
      timestamp: timestamp ?? this.timestamp,
      message: message ?? this.message,
    );
  }
}

class HostFollower {
  final String userId;
  final String username;
  final String? avatar;
  final DateTime followedDate;
  final bool isFollowing;

  HostFollower({
    required this.userId,
    required this.username,
    this.avatar,
    required this.followedDate,
    required this.isFollowing,
  });

  // CopyWith method
  HostFollower copyWith({
    String? userId,
    String? username,
    String? avatar,
    DateTime? followedDate,
    bool? isFollowing,
  }) {
    return HostFollower(
      userId: userId ?? this.userId,
      username: username ?? this.username,
      avatar: avatar ?? this.avatar,
      followedDate: followedDate ?? this.followedDate,
      isFollowing: isFollowing ?? this.isFollowing,
    );
  }
}

class HostEarning {
  final String id;
  final EarningType type;
  final double amount;
  final String source;
  final DateTime date;
  final EarningStatus status;

  HostEarning({
    required this.id,
    required this.type,
    required this.amount,
    required this.source,
    required this.date,
    required this.status,
  });

  // CopyWith method
  HostEarning copyWith({
    String? id,
    EarningType? type,
    double? amount,
    String? source,
    DateTime? date,
    EarningStatus? status,
  }) {
    return HostEarning(
      id: id ?? this.id,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      source: source ?? this.source,
      date: date ?? this.date,
      status: status ?? this.status,
    );
  }
}

class HostAnalytics {
  final Map<String, int> hourlyViewers;
  final Map<String, double> hourlyEarnings;
  final List<DailyStats> dailyStats;
  final Map<String, int> giftCategories;
  final List<String> topGiftGivers;
  final Map<String, double> revenueByHour;

  HostAnalytics({
    required this.hourlyViewers,
    required this.hourlyEarnings,
    required this.dailyStats,
    required this.giftCategories,
    required this.topGiftGivers,
    required this.revenueByHour,
  });

  // CopyWith method
  HostAnalytics copyWith({
    Map<String, int>? hourlyViewers,
    Map<String, double>? hourlyEarnings,
    List<DailyStats>? dailyStats,
    Map<String, int>? giftCategories,
    List<String>? topGiftGivers,
    Map<String, double>? revenueByHour,
  }) {
    return HostAnalytics(
      hourlyViewers: hourlyViewers ?? this.hourlyViewers,
      hourlyEarnings: hourlyEarnings ?? this.hourlyEarnings,
      dailyStats: dailyStats ?? this.dailyStats,
      giftCategories: giftCategories ?? this.giftCategories,
      topGiftGivers: topGiftGivers ?? this.topGiftGivers,
      revenueByHour: revenueByHour ?? this.revenueByHour,
    );
  }
}

class DailyStats {
  final DateTime date;
  final int viewers;
  final double earnings;
  final int gifts;
  final int hours;

  DailyStats({
    required this.date,
    required this.viewers,
    required this.earnings,
    required this.gifts,
    required this.hours,
  });

  // CopyWith method
  DailyStats copyWith({
    DateTime? date,
    int? viewers,
    double? earnings,
    int? gifts,
    int? hours,
  }) {
    return DailyStats(
      date: date ?? this.date,
      viewers: viewers ?? this.viewers,
      earnings: earnings ?? this.earnings,
      gifts: gifts ?? this.gifts,
      hours: hours ?? this.hours,
    );
  }
}

class HostSchedule {
  final String id;
  final String title;
  final DateTime startTime;
  final DateTime endTime;
  final RoomType type;
  final bool isRecurring;
  final String? recurringPattern;

  HostSchedule({
    required this.id,
    required this.title,
    required this.startTime,
    required this.endTime,
    required this.type,
    required this.isRecurring,
    this.recurringPattern,
  });

  // CopyWith method
  HostSchedule copyWith({
    String? id,
    String? title,
    DateTime? startTime,
    DateTime? endTime,
    RoomType? type,
    bool? isRecurring,
    String? recurringPattern,
  }) {
    return HostSchedule(
      id: id ?? this.id,
      title: title ?? this.title,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      type: type ?? this.type,
      isRecurring: isRecurring ?? this.isRecurring,
      recurringPattern: recurringPattern ?? this.recurringPattern,
    );
  }
}