import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../di/service_locator.dart';
import 'logger_service.dart';
import '../../features/host/models/host_models.dart';

class HostService {
  final LoggerService _logger;

  HostService({
    LoggerService? logger,
  }) : _logger = logger ?? ServiceLocator.instance.get<LoggerService>();

  // Get host by ID
  Future<Host> getHostById(String hostId) async {
    try {
      _logger.debug('Fetching host with ID: $hostId');

      // TODO: Replace with actual API call
      // final response = await _apiClient.get('/host/$hostId');
      // return Host.fromJson(response.data);

      await Future.delayed(const Duration(seconds: 1));

      return _generateMockHost(hostId);

    } catch (e, stackTrace) {
      _logger.error(
        'Failed to fetch host',
        error: e,
        stackTrace: stackTrace,
      );
      throw Exception('Failed to load host: $e');
    }
  }

  // Get all hosts (for admin/agency)
  Future<List<Host>> getAllHosts({
    String? agencyId,
    HostStatus? status,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      _logger.debug('Fetching all hosts');

      // TODO: Implement actual API call
      await Future.delayed(const Duration(seconds: 1));

      return List.generate(5, (index) => _generateMockHost('host_00$index'));

    } catch (e, stackTrace) {
      _logger.error(
        'Failed to fetch hosts',
        error: e,
        stackTrace: stackTrace,
      );
      throw Exception('Failed to load hosts: $e');
    }
  }

  // Update host profile
  Future<Host> updateHostProfile(String hostId, Map<String, dynamic> updates) async {
    try {
      _logger.debug('Updating host profile: $hostId');

      // TODO: Implement actual API call
      // final response = await _apiClient.put('/host/$hostId', data: updates);
      // return Host.fromJson(response.data);

      await Future.delayed(const Duration(seconds: 1));

      return _generateMockHost(hostId);

    } catch (e, stackTrace) {
      _logger.error(
        'Failed to update host profile',
        error: e,
        stackTrace: stackTrace,
      );
      throw Exception('Failed to update host: $e');
    }
  }

  // Update host status
  Future<void> updateHostStatus(String hostId, HostStatus status) async {
    try {
      _logger.debug('Updating host status: $hostId -> $status');

      // TODO: Implement actual API call
      await Future.delayed(const Duration(seconds: 1));

    } catch (e, stackTrace) {
      _logger.error(
        'Failed to update host status',
        error: e,
        stackTrace: stackTrace,
      );
      throw Exception('Failed to update status: $e');
    }
  }

  // Get host statistics
  Future<Map<String, dynamic>> getHostStats(String hostId) async {
    try {
      _logger.debug('Fetching host stats: $hostId');

      // TODO: Implement actual API call
      await Future.delayed(const Duration(seconds: 1));

      return {
        'totalRooms': 156,
        'totalHours': 312,
        'avgViewers': 450,
        'peakViewers': 1250,
        'totalGifts': 3456,
        'totalEarnings': 125000,
      };

    } catch (e, stackTrace) {
      _logger.error(
        'Failed to fetch host stats',
        error: e,
        stackTrace: stackTrace,
      );
      throw Exception('Failed to load stats: $e');
    }
  }

  // Get host rooms
  Future<List<HostRoom>> getHostRooms(String hostId, {int page = 1, int limit = 10}) async {
    try {
      _logger.debug('Fetching host rooms: $hostId');

      // TODO: Implement actual API call
      await Future.delayed(const Duration(seconds: 1));

      return _generateMockRooms(hostId);

    } catch (e, stackTrace) {
      _logger.error(
        'Failed to fetch host rooms',
        error: e,
        stackTrace: stackTrace,
      );
      throw Exception('Failed to load rooms: $e');
    }
  }

  // Get host gifts
  Future<List<HostGift>> getHostGifts(String hostId, {int page = 1, int limit = 10}) async {
    try {
      _logger.debug('Fetching host gifts: $hostId');

      // TODO: Implement actual API call
      await Future.delayed(const Duration(seconds: 1));

      return _generateMockGifts();

    } catch (e, stackTrace) {
      _logger.error(
        'Failed to fetch host gifts',
        error: e,
        stackTrace: stackTrace,
      );
      throw Exception('Failed to load gifts: $e');
    }
  }

  // Get host schedule
  Future<List<HostSchedule>> getHostSchedule(String hostId) async {
    try {
      _logger.debug('Fetching host schedule: $hostId');

      // TODO: Implement actual API call
      await Future.delayed(const Duration(seconds: 1));

      return _generateMockSchedules();

    } catch (e, stackTrace) {
      _logger.error(
        'Failed to fetch host schedule',
        error: e,
        stackTrace: stackTrace,
      );
      throw Exception('Failed to load schedule: $e');
    }
  }

  // Create host room
  Future<HostRoom> createRoom(String hostId, Map<String, dynamic> roomData) async {
    try {
      _logger.debug('Creating room for host: $hostId');

      // TODO: Implement actual API call
      await Future.delayed(const Duration(seconds: 1));

      return HostRoom(
        id: 'room_${DateTime.now().millisecondsSinceEpoch}',
        hostId: hostId,
        title: roomData['title'] ?? 'New Room',
        type: roomData['type'] ?? RoomType.voice,
        startTime: DateTime.now(),
        endTime: DateTime.now().add(const Duration(hours: 2)),
        maxViewers: roomData['maxViewers'] ?? 500,
        currentViewers: 0,
        peakViewers: 0,
        totalGifts: 0,
        earnings: 0,
        status: RoomStatus.scheduled,
        tags: roomData['tags'] ?? [],
        isPrivate: roomData['isPrivate'] ?? false,
        password: roomData['password'],
      );

    } catch (e, stackTrace) {
      _logger.error(
        'Failed to create room',
        error: e,
        stackTrace: stackTrace,
      );
      throw Exception('Failed to create room: $e');
    }
  }

  // Update host schedule
  Future<HostSchedule> updateSchedule(String scheduleId, Map<String, dynamic> updates) async {
    try {
      _logger.debug('Updating schedule: $scheduleId');

      // TODO: Implement actual API call
      await Future.delayed(const Duration(seconds: 1));

      return HostSchedule(
        id: scheduleId,
        title: updates['title'] ?? 'Updated Schedule',
        startTime: updates['startTime'] ?? DateTime.now(),
        endTime: updates['endTime'] ?? DateTime.now().add(const Duration(hours: 2)),
        type: updates['type'] ?? RoomType.voice,
        isRecurring: updates['isRecurring'] ?? false,
        recurringPattern: updates['recurringPattern'],
      );

    } catch (e, stackTrace) {
      _logger.error(
        'Failed to update schedule',
        error: e,
        stackTrace: stackTrace,
      );
      throw Exception('Failed to update schedule: $e');
    }
  }

  // Generate mock data
  Host _generateMockHost(String hostId) {
    return Host(
      id: hostId,
      userId: 'user_$hostId',
      name: 'Sarah Rahman',
      username: 'sarah_live',
      avatar: null,
      bio: 'Professional singer and entertainer',
      agencyId: 'ag_001',
      agencyName: 'Elite Talent Agency',
      joinedDate: DateTime.now().subtract(const Duration(days: 180)),
      status: HostStatus.active,
      followers: 15230,
      following: 1250,
      totalGifts: 3456,
      totalEarnings: 125000,
      monthlyEarnings: 28500,
      weeklyEarnings: 7200,
      todayEarnings: 1250,
      rating: 4.8,
      totalRooms: 156,
      totalHours: 312,
      avgViewers: 450,
      peakViewers: 1250,
      agencyCommissionRate: 10,
      platformCommissionRate: 5,
      pendingWithdrawal: 3500,
      availableBalance: 8500,
      currentStreak: 15,
      longestStreak: 30,
      totalStreakRewards: 5,
      badges: _generateBadges(),
      specialties: ['Singing', 'Gaming', 'Talk Show'],
    );
  }

  List<HostBadge> _generateBadges() {
    return [
      HostBadge(
        id: 'badge_001',
        name: 'Rising Star',
        icon: '⭐',
        color: Colors.amber,
        earnedDate: DateTime.now().subtract(const Duration(days: 30)),
        description: 'Reached 10k followers',
      ),
      HostBadge(
        id: 'badge_002',
        name: 'Gift Master',
        icon: '🎁',
        color: Colors.purple,
        earnedDate: DateTime.now().subtract(const Duration(days: 15)),
        description: 'Received 1000 gifts',
      ),
      HostBadge(
        id: 'badge_003',
        name: 'Consistent',
        icon: '🔥',
        color: Colors.orange,
        earnedDate: DateTime.now().subtract(const Duration(days: 7)),
        description: '15 day streak',
      ),
    ];
  }

  List<HostRoom> _generateMockRooms(String hostId) {
    return [
      HostRoom(
        id: 'room_001',
        hostId: hostId,
        title: 'Friday Night Sing-Along',
        type: RoomType.voice,
        startTime: DateTime.now().subtract(const Duration(hours: 2)),
        endTime: DateTime.now().subtract(const Duration(minutes: 30)),
        maxViewers: 1000,
        currentViewers: 0,
        peakViewers: 850,
        totalGifts: 156,
        earnings: 1250,
        status: RoomStatus.ended,
        tags: ['music', 'singing', 'interactive'],
        isPrivate: false,
        password: null,
      ),
      HostRoom(
        id: 'room_002',
        hostId: hostId,
        title: 'Gaming Night: Among Us',
        type: RoomType.video,
        startTime: DateTime.now().subtract(const Duration(days: 1)),
        endTime: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
        maxViewers: 500,
        currentViewers: 0,
        peakViewers: 620,
        totalGifts: 89,
        earnings: 750,
        status: RoomStatus.ended,
        tags: ['gaming', 'amongus', 'fun'],
        isPrivate: false,
        password: null,
      ),
    ];
  }

  List<HostGift> _generateMockGifts() {
    return [
      HostGift(
        id: 'gift_001',
        senderId: 'user_123',
        senderName: 'Popi',
        giftType: 'Super Star',
        amount: 10,
        value: 500,
        timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
        message: 'Amazing voice!',
      ),
      HostGift(
        id: 'gift_002',
        senderId: 'user_456',
        senderName: 'Ritu',
        giftType: 'Rose',
        amount: 50,
        value: 250,
        timestamp: DateTime.now().subtract(const Duration(minutes: 25)),
        message: 'Love your content',
      ),
    ];
  }

  List<HostSchedule> _generateMockSchedules() {
    return [
      HostSchedule(
        id: 'sch_001',
        title: 'Morning Vibes',
        startTime: DateTime.now().add(const Duration(hours: 3)),
        endTime: DateTime.now().add(const Duration(hours: 5)),
        type: RoomType.voice,
        isRecurring: true,
        recurringPattern: 'daily',
      ),
      HostSchedule(
        id: 'sch_002',
        title: 'Weekend Special',
        startTime: DateTime.now().add(const Duration(days: 1, hours: 20)),
        endTime: DateTime.now().add(const Duration(days: 2, hours: 22)),
        type: RoomType.video,
        isRecurring: true,
        recurringPattern: 'weekly',
      ),
    ];
  }
// Get host following list
  Future<List<HostFollower>> getHostFollowing(String hostId, {int page = 1, int limit = 10}) async {
    try {
      _logger.debug('Fetching host following: $hostId');

      // TODO: Implement actual API call
      await Future.delayed(const Duration(seconds: 1));

      return _generateMockFollowing();

    } catch (e, stackTrace) {
      _logger.error(
        'Failed to fetch host following',
        error: e,
        stackTrace: stackTrace,
      );
      throw Exception('Failed to load following: $e');
    }
  }

  List<HostFollower> _generateMockFollowing() {
    return [
      HostFollower(
        userId: 'user_789',
        username: 'singer_rahim',
        avatar: null,
        followedDate: DateTime.now().subtract(const Duration(days: 10)),
        isFollowing: true,
      ),
      HostFollower(
        userId: 'user_101',
        username: 'gamer_kamal',
        avatar: null,
        followedDate: DateTime.now().subtract(const Duration(days: 15)),
        isFollowing: true,
      ),
      HostFollower(
        userId: 'user_102',
        username: 'vlogger_nasim',
        avatar: null,
        followedDate: DateTime.now().subtract(const Duration(days: 20)),
        isFollowing: true,
      ),
    ];
  }
  // Get earnings list
  Future<List<HostEarning>> getHostEarnings(String hostId, {int page = 1, int limit = 10}) async {
    try {
      _logger.debug('Fetching host earnings: $hostId');

      // TODO: Implement actual API call
      await Future.delayed(const Duration(seconds: 1));

      return _generateMockEarnings();

    } catch (e, stackTrace) {
      _logger.error(
        'Failed to fetch host earnings',
        error: e,
        stackTrace: stackTrace,
      );
      throw Exception('Failed to load earnings: $e');
    }
  }

  List<HostEarning> _generateMockEarnings() {
    return [
      HostEarning(
        id: 'earn_001',
        type: EarningType.gift,
        amount: 1250,
        source: 'Gift from John',
        date: DateTime.now().subtract(const Duration(hours: 2)),
        status: EarningStatus.available,
      ),
      HostEarning(
        id: 'earn_002',
        type: EarningType.room,
        amount: 3500,
        source: 'Friday Night Room',
        date: DateTime.now().subtract(const Duration(days: 1)),
        status: EarningStatus.available,
      ),
      HostEarning(
        id: 'earn_003',
        type: EarningType.bonus,
        amount: 500,
        source: 'Streak Bonus',
        date: DateTime.now().subtract(const Duration(days: 2)),
        status: EarningStatus.available,
      ),
      HostEarning(
        id: 'earn_004',
        type: EarningType.gift,
        amount: 750,
        source: 'Gift from Sarah',
        date: DateTime.now().subtract(const Duration(days: 3)),
        status: EarningStatus.pending,
      ),
      HostEarning(
        id: 'earn_005',
        type: EarningType.commission,
        amount: 1200,
        source: 'Referral Commission',
        date: DateTime.now().subtract(const Duration(days: 5)),
        status: EarningStatus.withdrawn,
      ),
    ];
  }

  // Get followers list
  Future<List<HostFollower>> getHostFollowers(String hostId, {int page = 1, int limit = 10}) async {
    try {
      _logger.debug('Fetching host followers: $hostId');

      // TODO: Implement actual API call
      await Future.delayed(const Duration(seconds: 1));

      return _generateMockFollowers();

    } catch (e, stackTrace) {
      _logger.error(
        'Failed to fetch host followers',
        error: e,
        stackTrace: stackTrace,
      );
      throw Exception('Failed to load followers: $e');
    }
  }

  List<HostFollower> _generateMockFollowers() {
    return [
      HostFollower(
        userId: 'user_123',
        username: 'john_doe',
        avatar: null,
        followedDate: DateTime.now().subtract(const Duration(days: 30)),
        isFollowing: true,
      ),
      HostFollower(
        userId: 'user_456',
        username: 'jane_smith',
        avatar: null,
        followedDate: DateTime.now().subtract(const Duration(days: 25)),
        isFollowing: true,
      ),
      HostFollower(
        userId: 'user_789',
        username: 'mike_johnson',
        avatar: null,
        followedDate: DateTime.now().subtract(const Duration(days: 15)),
        isFollowing: false,
      ),
    ];
  }
}