import 'package:flutter/foundation.dart';
import '../di/service_locator.dart';
import 'logger_service.dart';
import '../../features/host/models/host_models.dart';

// Earnings Summary class
class EarningsSummary {
  final double totalEarnings;
  final double monthlyEarnings;
  final double weeklyEarnings;
  final double todayEarnings;
  final double availableBalance;
  final double pendingWithdrawal;

  EarningsSummary({
    required this.totalEarnings,
    required this.monthlyEarnings,
    required this.weeklyEarnings,
    required this.todayEarnings,
    required this.availableBalance,
    required this.pendingWithdrawal,
  });

  // CopyWith method
  EarningsSummary copyWith({
    double? totalEarnings,
    double? monthlyEarnings,
    double? weeklyEarnings,
    double? todayEarnings,
    double? availableBalance,
    double? pendingWithdrawal,
  }) {
    return EarningsSummary(
      totalEarnings: totalEarnings ?? this.totalEarnings,
      monthlyEarnings: monthlyEarnings ?? this.monthlyEarnings,
      weeklyEarnings: weeklyEarnings ?? this.weeklyEarnings,
      todayEarnings: todayEarnings ?? this.todayEarnings,
      availableBalance: availableBalance ?? this.availableBalance,
      pendingWithdrawal: pendingWithdrawal ?? this.pendingWithdrawal,
    );
  }

  // Empty summary
  factory EarningsSummary.empty() {
    return EarningsSummary(
      totalEarnings: 0,
      monthlyEarnings: 0,
      weeklyEarnings: 0,
      todayEarnings: 0,
      availableBalance: 0,
      pendingWithdrawal: 0,
    );
  }

  // FromJson method (for API response)
  factory EarningsSummary.fromJson(Map<String, dynamic> json) {
    return EarningsSummary(
      totalEarnings: (json['totalEarnings'] ?? 0).toDouble(),
      monthlyEarnings: (json['monthlyEarnings'] ?? 0).toDouble(),
      weeklyEarnings: (json['weeklyEarnings'] ?? 0).toDouble(),
      todayEarnings: (json['todayEarnings'] ?? 0).toDouble(),
      availableBalance: (json['availableBalance'] ?? 0).toDouble(),
      pendingWithdrawal: (json['pendingWithdrawal'] ?? 0).toDouble(),
    );
  }

  // ToJson method
  Map<String, dynamic> toJson() {
    return {
      'totalEarnings': totalEarnings,
      'monthlyEarnings': monthlyEarnings,
      'weeklyEarnings': weeklyEarnings,
      'todayEarnings': todayEarnings,
      'availableBalance': availableBalance,
      'pendingWithdrawal': pendingWithdrawal,
    };
  }
}

class HostEarningsService {
  final LoggerService _logger;

  HostEarningsService({
    LoggerService? logger,
  }) : _logger = logger ?? ServiceLocator.instance.get<LoggerService>();

  Future<Map<String, dynamic>> getHostEarnings(
      String hostId,
      String period,
      ) async {
    try {
      _logger.debug('Fetching earnings for host: $hostId, period: $period');

      // TODO: Replace with actual API call
      await Future.delayed(const Duration(seconds: 1));

      final earnings = _generateEarnings(period);
      final summary = _generateSummary(period);

      return {
        'earnings': earnings,
        'summary': summary,
      };

    } catch (e, stackTrace) {
      _logger.error(
        'Failed to fetch host earnings',
        error: e,
        stackTrace: stackTrace,
      );
      throw Exception('Failed to load earnings: $e');
    }
  }

  // Get earnings by type
  Future<List<HostEarning>> getEarningsByType(
      String hostId,
      EarningStatus status, {
        int page = 1,
        int limit = 20,
      }) async {
    try {
      _logger.debug('Fetching earnings by type for host: $hostId, status: $status');

      await Future.delayed(const Duration(seconds: 1));

      final allEarnings = _generateEarnings('month');
      return allEarnings.where((e) => e.status == status).toList();

    } catch (e, stackTrace) {
      _logger.error('Failed to fetch earnings by type', error: e, stackTrace: stackTrace);
      throw Exception('Failed to load earnings: $e');
    }
  }

  // Get earnings summary
  Future<EarningsSummary> getEarningsSummary(
      String hostId,
      String period,
      ) async {
    try {
      _logger.debug('Fetching earnings summary for host: $hostId, period: $period');

      await Future.delayed(const Duration(seconds: 1));

      return _generateSummary(period);

    } catch (e, stackTrace) {
      _logger.error('Failed to fetch earnings summary', error: e, stackTrace: stackTrace);
      throw Exception('Failed to load summary: $e');
    }
  }

  List<HostEarning> _generateEarnings(String period) {
    final multiplier = _getPeriodMultiplier(period);

    return [
      HostEarning(
        id: 'earn_001',
        type: EarningType.gift,
        amount: (1250 * multiplier).toDouble(),
        source: 'Gift from John',
        date: DateTime.now().subtract(const Duration(hours: 2)),
        status: EarningStatus.available,
      ),
      HostEarning(
        id: 'earn_002',
        type: EarningType.room,
        amount: (3500 * multiplier).toDouble(),
        source: 'Friday Night Room',
        date: DateTime.now().subtract(const Duration(days: 1)),
        status: EarningStatus.available,
      ),
      HostEarning(
        id: 'earn_003',
        type: EarningType.bonus,
        amount: (500 * multiplier).toDouble(),
        source: 'Streak Bonus',
        date: DateTime.now().subtract(const Duration(days: 2)),
        status: EarningStatus.available,
      ),
      HostEarning(
        id: 'earn_004',
        type: EarningType.gift,
        amount: (750 * multiplier).toDouble(),
        source: 'Gift from Sarah',
        date: DateTime.now().subtract(const Duration(days: 3)),
        status: EarningStatus.pending,
      ),
      HostEarning(
        id: 'earn_005',
        type: EarningType.commission,
        amount: (1200 * multiplier).toDouble(),
        source: 'Referral Commission',
        date: DateTime.now().subtract(const Duration(days: 5)),
        status: EarningStatus.withdrawn,
      ),
    ];
  }

  EarningsSummary _generateSummary(String period) {
    final multiplier = _getPeriodMultiplier(period);

    return EarningsSummary(
      totalEarnings: (125000 * multiplier).toDouble(),
      monthlyEarnings: (28500 * multiplier).toDouble(),
      weeklyEarnings: (7200 * multiplier).toDouble(),
      todayEarnings: (1250 * multiplier).toDouble(),
      availableBalance: (8500 * multiplier).toDouble(),
      pendingWithdrawal: (3500 * multiplier).toDouble(),
    );
  }

  double _getPeriodMultiplier(String period) {
    switch (period) {
      case 'day':
        return 0.1;
      case 'week':
        return 0.7;
      case 'month':
        return 1.0;
      case 'year':
        return 12.0;
      default:
        return 1.0;
    }
  }
}