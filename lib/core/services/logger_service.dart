import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../di/service_locator.dart';

enum LogLevel {
  debug,
  info,
  warning,
  error,
  fatal
}

class LoggerService {
  factory LoggerService() => _instance;
  LoggerService._internal();
  static final LoggerService _instance = LoggerService._internal();

  late final SupabaseClient _supabase;
  bool _isInitialized = false;
  LogLevel _minLogLevel = LogLevel.debug;
  final List<LogEntry> _recentLogs = [];
  static const int _maxRecentLogs = 100;

  // ==================== INITIALIZATION ====================
  Future<void> initialize({
    LogLevel minLogLevel = LogLevel.debug,
  }) async {
    try {
      _supabase = getService<SupabaseClient>();
      _minLogLevel = minLogLevel;
      _isInitialized = true;

      debug('LoggerService initialized with Supabase');
    } catch (e) {
      if (kDebugMode) {
        print('LoggerService initialization error: $e');
      }
      _isInitialized = true; // Still initialize even without Supabase
    }
  }

  // ==================== LOGGING METHODS ====================

  void debug(String message, {Map<String, dynamic>? data, String? tag}) {
    _log(LogLevel.debug, message, data: data, tag: tag);
  }

  void info(String message, {Map<String, dynamic>? data, String? tag}) {
    _log(LogLevel.info, message, data: data, tag: tag);
  }

  void warning(String message, {Map<String, dynamic>? data, String? tag, dynamic error}) {
    _log(LogLevel.warning, message, data: data, tag: tag, error: error);
  }

  void error(String message, {Map<String, dynamic>? data, String? tag, dynamic error, StackTrace? stackTrace}) {
    _log(LogLevel.error, message, data: data, tag: tag, error: error, stackTrace: stackTrace);
  }

  void fatal(String message, {Map<String, dynamic>? data, String? tag, dynamic error, StackTrace? stackTrace}) {
    _log(LogLevel.fatal, message, data: data, tag: tag, error: error, stackTrace: stackTrace);
  }

  // ==================== PRIVATE LOG METHOD ====================
  void _log(
      LogLevel level,
      String message, {
        Map<String, dynamic>? data,
        String? tag,
        dynamic error,
        StackTrace? stackTrace,
      }) {
    if (!_isInitialized) return;
    if (level.index < _minLogLevel.index) return;

    final DateTime timestamp = DateTime.now();
    final LogEntry logEntry = LogEntry(
      level: level,
      message: message,
      data: data,
      tag: tag,
      error: error?.toString(),
      stackTrace: stackTrace?.toString(),
      timestamp: timestamp,
    );

    // Add to recent logs
    _recentLogs.add(logEntry);
    if (_recentLogs.length > _maxRecentLogs) {
      _recentLogs.removeAt(0);
    }

    // Print to console
    _printToConsole(logEntry);

    // Save to Supabase for important logs
    if (level == LogLevel.warning || level == LogLevel.error || level == LogLevel.fatal) {
      _saveToSupabase(logEntry);
    }
  }

  // ==================== OUTPUT METHODS ====================

  void _printToConsole(LogEntry entry) {
    final String emoji = _getLevelEmoji(entry.level);
    final String tag = entry.tag != null ? '[${entry.tag}]' : '';
    final String errorStr = entry.error != null ? '\nError: ${entry.error}' : '';

    developer.log(
      '$emoji $tag ${entry.message}$errorStr',
      time: entry.timestamp,
      level: entry.level.index * 100,
      error: entry.error,
      stackTrace: entry.stackTrace != null ? StackTrace.fromString(entry.stackTrace!) : null,
    );
  }

  String _getLevelEmoji(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return '🔍';
      case LogLevel.info:
        return 'ℹ️';
      case LogLevel.warning:
        return '⚠️';
      case LogLevel.error:
        return '❌';
      case LogLevel.fatal:
        return '💀';
    }
  }

  Future<void> _saveToSupabase(LogEntry entry) async {
    try {
      if (!_isInitialized) return;

      await _supabase.from('app_logs').insert({
        'level': entry.level.toString().split('.').last,
        'message': entry.message,
        'data': entry.data,
        'tag': entry.tag,
        'error': entry.error,
        'stack_trace': entry.stackTrace,
        'timestamp': entry.timestamp.toIso8601String(),
      });
    } catch (e) {
      if (kDebugMode) {
        print('Supabase log error: $e');
      }
    }
  }

  // ==================== LOG RETRIEVAL - FIXED ====================

  List<LogEntry> getRecentLogs({LogLevel? minLevel, String? tag}) {
    List<LogEntry> logs = List.from(_recentLogs);

    if (minLevel != null) {
      logs = logs.where((LogEntry log) => log.level.index >= minLevel.index).toList();
    }

    if (tag != null) {
      logs = logs.where((LogEntry log) => log.tag == tag).toList();
    }

    return logs;
  }

  Future<List<LogEntry>> getLogsFromSupabase({
    DateTime? startDate,
    DateTime? endDate,
    LogLevel? minLevel,
    String? tag,
    int limit = 100,
  }) async {
    try {
      if (!_isInitialized) return [];

      // Build query
      var query = _supabase
          .from('app_logs')
          .select()
          .order('timestamp', ascending: false)
          .limit(limit);

      // Apply date filters if provided - FIXED
      if (startDate != null) {
        // Manual filtering for start date
        // We'll fetch and filter manually
      }

      if (endDate != null) {
        // Manual filtering for end date
      }

      if (tag != null) {
        // Manual filtering for tag
      }

      // Execute query
      final response = await query;

      // Manual filtering
      List<Map<String, dynamic>> filteredResponse = List.from(response);

      if (startDate != null) {
        filteredResponse = filteredResponse.where((item) {
          final itemDate = DateTime.parse(item['timestamp']);
          return itemDate.isAfter(startDate) || itemDate.isAtSameMomentAs(startDate);
        }).toList();
      }

      if (endDate != null) {
        filteredResponse = filteredResponse.where((item) {
          final itemDate = DateTime.parse(item['timestamp']);
          return itemDate.isBefore(endDate) || itemDate.isAtSameMomentAs(endDate);
        }).toList();
      }

      if (tag != null) {
        filteredResponse = filteredResponse.where((item) => item['tag'] == tag).toList();
      }

      // Convert to LogEntry objects
      List<LogEntry> logs = filteredResponse.map((json) {
        return LogEntry(
          level: _parseLogLevel(json['level']),
          message: json['message'] ?? '',
          data: json['data'],
          tag: json['tag'],
          error: json['error'],
          stackTrace: json['stack_trace'],
          timestamp: DateTime.parse(json['timestamp']),
        );
      }).toList();

      // Apply minLevel filter
      if (minLevel != null) {
        logs = logs.where((log) => log.level.index >= minLevel.index).toList();
      }

      return logs;
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching logs from Supabase: $e');
      }
      return [];
    }
  }

  LogLevel _parseLogLevel(String? levelStr) {
    if (levelStr == null) return LogLevel.info;
    try {
      return LogLevel.values.firstWhere(
            (e) => e.toString().split('.').last == levelStr,
        orElse: () => LogLevel.info,
      );
    } catch (e) {
      return LogLevel.info;
    }
  }

  // ==================== PERFORMANCE TRACKING ====================

  PerformanceTracker startPerformanceTracking(String operation, {Map<String, dynamic>? data}) {
    return PerformanceTracker(
      logger: this,
      operation: operation,
      data: data,
    );
  }

  // ==================== USER ACTIONS ====================

  void logUserAction(String action, {Map<String, dynamic>? data, String? userId}) {
    info('User action: $action', data: {
      'userId': userId,
      'action': action,
      ...?data,
    }, tag: 'USER_ACTION');
  }

  // ==================== NETWORK LOGGING ====================

  void logNetworkRequest(String method, String url, {Map<String, dynamic>? headers, dynamic body}) {
    debug('Network Request: $method $url', data: {
      'method': method,
      'url': url,
      'headers': headers,
      'body': body,
    }, tag: 'NETWORK');
  }

  void logNetworkResponse(String method, String url, int statusCode, {dynamic response}) {
    debug('Network Response: $method $url - $statusCode', data: {
      'method': method,
      'url': url,
      'statusCode': statusCode,
      'response': response,
    }, tag: 'NETWORK');
  }

  // ==================== ERROR REPORTING ====================

  Future<void> reportError(dynamic error, StackTrace? stackTrace, {String? message, Map<String, dynamic>? extraData}) async {
    final errorMsg = message ?? 'Unhandled error';
    fatal(errorMsg, error: error, stackTrace: stackTrace, data: extraData);
  }

  // ==================== CLEANUP ====================

  void clearRecentLogs() {
    _recentLogs.clear();
  }
}

// ==================== MODEL CLASSES ====================

class LogEntry {
  final LogLevel level;
  final String message;
  final Map<String, dynamic>? data;
  final String? tag;
  final String? error;
  final String? stackTrace;
  final DateTime timestamp;

  LogEntry({
    required this.level,
    required this.message,
    required this.timestamp,
    this.data,
    this.tag,
    this.error,
    this.stackTrace,
  });

  Map<String, dynamic> toJson() {
    return {
      'level': level.toString().split('.').last,
      'message': message,
      'data': data,
      'tag': tag,
      'error': error,
      'stack_trace': stackTrace,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

class PerformanceTracker {
  final LoggerService logger;
  final String operation;
  final Map<String, dynamic>? data;
  final DateTime startTime;
  DateTime? endTime;

  PerformanceTracker({
    required this.logger,
    required this.operation,
    this.data,
  }) : startTime = DateTime.now();

  void end({Map<String, dynamic>? resultData}) {
    endTime = DateTime.now();
    final Duration duration = endTime!.difference(startTime);

    logger.debug('Performance: $operation completed in ${duration.inMilliseconds}ms', data: {
      'operation': operation,
      'durationMs': duration.inMilliseconds,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime!.toIso8601String(),
      ...?data,
      ...?resultData,
    }, tag: 'PERFORMANCE');
  }

  // Track with custom completion
  void completeWithSuccess({Map<String, dynamic>? metadata}) {
    end(resultData: {'status': 'success', ...?metadata});
  }

  void completeWithError(dynamic error, {Map<String, dynamic>? metadata}) {
    end(resultData: {'status': 'error', 'error': error.toString(), ...?metadata});
  }
}

// ==================== ALTERNATIVE HTTP-BASED VERSION (যদি উপরেরটা কাজ না করে) ====================

/*
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoggerService {
  // ... same as above ...

  Future<List<LogEntry>> getLogsFromSupabase({
    DateTime? startDate,
    DateTime? endDate,
    LogLevel? minLevel,
    String? tag,
    int limit = 100,
  }) async {
    try {
      if (!_isInitialized) return [];

      final session = _supabase.auth.currentSession;
      if (session == null) return [];

      final supabaseUrl = 'YOUR_SUPABASE_URL'; // Get from environment
      final supabaseKey = 'YOUR_SUPABASE_ANON_KEY'; // Get from environment

      // Build URL with filters
      String urlStr = '$supabaseUrl/rest/v1/app_logs?order=timestamp.desc&limit=$limit';

      if (startDate != null) {
        urlStr += '&timestamp=gte.${startDate.toIso8601String()}';
      }
      if (endDate != null) {
        urlStr += '&timestamp=lte.${endDate.toIso8601String()}';
      }
      if (tag != null) {
        urlStr += '&tag=eq.$tag';
      }

      final url = Uri.parse(urlStr);

      final response = await http.get(
        url,
        headers: {
          'apikey': supabaseKey,
          'Authorization': 'Bearer ${session.accessToken}',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        List<LogEntry> logs = data.map((json) {
          return LogEntry(
            level: _parseLogLevel(json['level']),
            message: json['message'] ?? '',
            data: json['data'],
            tag: json['tag'],
            error: json['error'],
            stackTrace: json['stack_trace'],
            timestamp: DateTime.parse(json['timestamp']),
          );
        }).toList();

        if (minLevel != null) {
          logs = logs.where((log) => log.level.index >= minLevel.index).toList();
        }

        return logs;
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching logs: $e');
      return [];
    }
  }
}
*/

// ==================== EXTENSION FOR CONVENIENCE ====================

extension LogLevelExtension on LogLevel {
  String get displayName {
    switch (this) {
      case LogLevel.debug:
        return 'DEBUG';
      case LogLevel.info:
        return 'INFO';
      case LogLevel.warning:
        return 'WARNING';
      case LogLevel.error:
        return 'ERROR';
      case LogLevel.fatal:
        return 'FATAL';
    }
  }
}

// ==================== GLOBAL LOGGER ACCESS ====================

LoggerService get logger => ServiceLocator.instance.get<LoggerService>();