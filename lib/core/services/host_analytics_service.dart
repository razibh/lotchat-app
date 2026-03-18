import 'dart:convert';
import 'package:flutter/material.dart'; // 🟢 Colors এর জন্য
import 'package:flutter/foundation.dart';
import '../di/service_locator.dart';
import 'logger_service.dart';

class HostAnalyticsService {
  // ApiClient ছাড়া সরাসরি কাজ করবে
  final LoggerService _logger;

  HostAnalyticsService({
    LoggerService? logger,
  }) : _logger = logger ?? ServiceLocator.instance.get<LoggerService>();

  // Get host analytics data
  Future<Map<String, dynamic>> getHostAnalytics(
      String hostId,
      String period,
      ) async {
    try {
      _logger.debug('Fetching analytics for host: $hostId, period: $period');

      // TODO: Replace with actual API call when backend is ready
      // final response = await http.get(
      //   Uri.parse('https://api.example.com/host/$hostId/analytics?period=$period'),
      //   headers: {'Authorization': 'Bearer ${await getToken()}'},
      // );
      // if (response.statusCode == 200) {
      //   return json.decode(response.body);
      // } else {
      //   throw Exception('Failed to load analytics: ${response.statusCode}');
      // }

      // Mock data for development
      await Future.delayed(const Duration(seconds: 1));

      return _getMockAnalyticsData(period);

    } catch (e, stackTrace) {
      _logger.error(
        'Failed to fetch host analytics',
        error: e,
        stackTrace: stackTrace,
      );
      throw Exception('Failed to load analytics: $e');
    }
  }

  // Get mock analytics data based on period
  Map<String, dynamic> _getMockAnalyticsData(String period) {
    final multiplier = _getPeriodMultiplier(period);

    return {
      'viewers': {
        'average': '${(450 * multiplier).round()}',
        'avgTrend': _getTrend(12, multiplier),
        'peak': '${(1250 * multiplier).round()}',
        'peakTrend': _getTrend(8, multiplier),
        'totalHours': '${(312 * multiplier).round()}',
        'hoursTrend': _getTrend(-2, multiplier),
        'hourlyData': _generateHourlyData(multiplier),
        'locations': _generateLocationData(multiplier),
      },
      'earnings': {
        'total': '${(125000 * multiplier).round()}',
        'totalTrend': _getTrend(15, multiplier),
        'monthlyAvg': '${(28500 * multiplier).round()}',
        'monthlyTrend': _getTrend(10, multiplier),
        'bestDay': '${(4500 * multiplier).round()}',
        'bestDayLabel': _getBestDay(),
        'dailyData': _generateDailyData(multiplier),
        'sources': _generateSourceData(),
      },
      'gifts': {
        'total': '${(3456 * multiplier).round()}',
        'totalTrend': _getTrend(20, multiplier),
        'topGifter': _getTopGifter(),
        'topGifterGifts': '${(500 * multiplier).round()}',
        'value': '${(45000 * multiplier).round()}',
        'valueTrend': _getTrend(18, multiplier),
        'popular': _generateGiftData(multiplier),
        'topSupporters': _generateSupporterData(multiplier),
      },
    };
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

  String _getTrend(int baseChange, double multiplier) {
    final change = (baseChange * multiplier).round();
    final arrow = change >= 0 ? '↑' : '↓';
    return '$arrow ${change.abs()}%';
  }

  List<Map<String, dynamic>> _generateHourlyData(double multiplier) {
    return [
      {'label': '12am', 'value': (30 * multiplier).round()},
      {'label': '4am', 'value': (20 * multiplier).round()},
      {'label': '8am', 'value': (45 * multiplier).round()},
      {'label': '12pm', 'value': (80 * multiplier).round()},
      {'label': '4pm', 'value': (95 * multiplier).round()},
      {'label': '8pm', 'value': (100 * multiplier).round()},
      {'label': '11pm', 'value': (70 * multiplier).round()},
    ];
  }

  List<Map<String, dynamic>> _generateDailyData(double multiplier) {
    return [
      {'label': 'Mon', 'value': (40 * multiplier).round()},
      {'label': 'Tue', 'value': (55 * multiplier).round()},
      {'label': 'Wed', 'value': (48 * multiplier).round()},
      {'label': 'Thu', 'value': (70 * multiplier).round()},
      {'label': 'Fri', 'value': (85 * multiplier).round()},
      {'label': 'Sat', 'value': (90 * multiplier).round()},
      {'label': 'Sun', 'value': (75 * multiplier).round()},
    ];
  }

  List<Map<String, dynamic>> _generateLocationData(double multiplier) {
    return [
      {'city': 'Dhaka', 'viewers': (450 * multiplier).round(), 'percentage': 35},
      {'city': 'Chittagong', 'viewers': (280 * multiplier).round(), 'percentage': 22},
      {'city': 'Sylhet', 'viewers': (150 * multiplier).round(), 'percentage': 12},
      {'city': 'Other', 'viewers': (370 * multiplier).round(), 'percentage': 31},
    ];
  }

  List<Map<String, dynamic>> _generateSourceData() {
    return [
      {'source': 'Gifts', 'percentage': 65},
      {'source': 'Room Entry', 'percentage': 20},
      {'source': 'Bonuses', 'percentage': 10},
      {'source': 'Other', 'percentage': 5},
    ];
  }

  List<Map<String, dynamic>> _generateGiftData(double multiplier) {
    return [
      {'gift': 'Super Star', 'count': (150 * multiplier).round(), 'value': 45},
      {'gift': 'Rose', 'count': (280 * multiplier).round(), 'value': 25},
      {'gift': 'Heart', 'count': (420 * multiplier).round(), 'value': 15},
      {'gift': 'Diamond', 'count': (50 * multiplier).round(), 'value': 100},
    ];
  }

  List<Map<String, dynamic>> _generateSupporterData(double multiplier) {
    return [
      {'rank': 1, 'name': 'PoPi', 'gifts': (150 * multiplier).round(), 'value': (7500 * multiplier).round()},
      {'rank': 2, 'name': 'Ritu', 'gifts': (120 * multiplier).round(), 'value': (6000 * multiplier).round()},
      {'rank': 3, 'name': 'Ismail', 'gifts': (95 * multiplier).round(), 'value': (4750 * multiplier).round()},
      {'rank': 4, 'name': 'Kakuli', 'gifts': (80 * multiplier).round(), 'value': (4000 * multiplier).round()},
      {'rank': 5, 'name': 'Razib', 'gifts': (65 * multiplier).round(), 'value': (3250 * multiplier).round()},
    ];
  }

  String _getBestDay() {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[DateTime.now().weekday - 1];
  }

  String _getTopGifter() {
    const names = ['PoPi', 'Ritu', 'Ismail', 'Kakuli', 'Razib'];
    return names[DateTime.now().millisecondsSinceEpoch % names.length];
  }
}