import 'dart:developer' as developer;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

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

  bool _isInitialized = false;
  LogLevel _minLogLevel = LogLevel.debug;
  final List<LogEntry> _recentLogs = <LogEntry>[];
  static const int _maxRecentLogs = 100;

  // ==================== INITIALIZATION ====================
  Future<void> initialize({
    LogLevel minLogLevel = LogLevel.debug,
    bool enableCrashlytics = true,
  }) async {
    _minLogLevel = minLogLevel;
    _isInitialized = true;

    if (enableCrashlytics) {
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
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
    
    // Report fatal errors to Crashlytics
    if (error != null) {
      FirebaseCrashlytics.instance.recordError(error, stackTrace, reason: message);
    }
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

    // Send to Crashlytics for errors
    if (level == LogLevel.error || level == LogLevel.fatal) {
      _sendToCrashlytics(logEntry);
    }

    // Save to Firestore for important logs
    if (level == LogLevel.warning || level == LogLevel.error || level == LogLevel.fatal) {
      _saveToFirestore(logEntry);
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

  Future<void> _sendToCrashlytics(LogEntry entry) async {
    try {
      FirebaseCrashlytics.instance.log('${entry.level}: ${entry.message}');
      if (entry.data != null) {
        FirebaseCrashlytics.instance.setCustomKeys(entry.data!);
      }
    } catch (e) {
      print('Error sending to Crashlytics: $e');
    }
  }

  Future<void> _saveToFirestore(LogEntry entry) async {
    try {
      await FirebaseFirestore.instance.collection('app_logs').add(<String, Object?>{
        'level': entry.level.toString(),
        'message': entry.message,
        'data': entry.data,
        'tag': entry.tag,
        'error': entry.error,
        'timestamp': entry.timestamp,
      });
    } catch (e) {
      print('Error saving log to Firestore: $e');
    }
  }

  // ==================== LOG RETRIEVAL ====================

  List<LogEntry> getRecentLogs({LogLevel? minLevel, String? tag}) {
    List<LogEntry> logs = _recentLogs;
    
    if (minLevel != null) {
      logs = logs.where((LogEntry log) => log.level.index >= minLevel.index).toList();
    }
    
    if (tag != null) {
      logs = logs.where((LogEntry log) => log.tag == tag).toList();
    }
    
    return logs;
  }

  Future<List<LogEntry>> getLogsFromFirestore({
    DateTime? startDate,
    DateTime? endDate,
    LogLevel? minLevel,
    int limit = 100,
  }) async {
    try {
      Query<Map<String, dynamic>> query = FirebaseFirestore.instance
          .collection('app_logs')
          .orderBy('timestamp', descending: true)
          .limit(limit);
      
      if (startDate != null) {
        query = query.where('timestamp', isGreaterThanOrEqualTo: startDate);
      }
      
      if (endDate != null) {
        query = query.where('timestamp', isLessThanOrEqualTo: endDate);
      }
      
      final QuerySnapshot<Map<String, dynamic>> snapshot = await query.get();
      
      return snapshot.docs.map((QueryDocumentSnapshot<Map<String, dynamic>> doc) {
        final Map<String, dynamic> data = doc.data();
        return LogEntry(
          level: LogLevel.values.firstWhere(
            (LogLevel e) => e.toString() == data['level'],
            orElse: () => LogLevel.info,
          ),
          message: data['message'] ?? '',
          data: data['data'],
          tag: data['tag'],
          error: data['error'],
          timestamp: (data['timestamp'] as Timestamp).toDate(),
        );
      }).toList();
    } catch (e) {
      print('Error fetching logs: $e');
      return <LogEntry>[];
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
    info('User action: $action', data: <String, dynamic>{
      'userId': userId,
      'action': action,
      ...?data,
    }, tag: 'USER_ACTION',);
  }

  // ==================== NETWORK LOGGING ====================

  void logNetworkRequest(String method, String url, {Map<String, dynamic>? headers, dynamic body}) {
    debug('Network Request: $method $url', data: <String, dynamic>{
      'method': method,
      'url': url,
      'headers': headers,
      'body': body,
    }, tag: 'NETWORK',);
  }

  void logNetworkResponse(String method, String url, int statusCode, {dynamic response}) {
    debug('Network Response: $method $url - $statusCode', data: <String, dynamic>{
      'method': method,
      'url': url,
      'statusCode': statusCode,
      'response': response,
    }, tag: 'NETWORK',);
  }

  // ==================== CLEANUP ====================

  void clearRecentLogs() {
    _recentLogs.clear();
  }
}

// ==================== MODEL CLASSES ====================

class LogEntry {

  LogEntry({
    required this.level,
    required this.message,
    required this.timestamp, this.data,
    this.tag,
    this.error,
    this.stackTrace,
  });
  final LogLevel level;
  final String message;
  final Map<String, dynamic>? data;
  final String? tag;
  final String? error;
  final String? stackTrace;
  final DateTime timestamp;
}

class PerformanceTracker {

  PerformanceTracker({
    required this.logger,
    required this.operation,
    this.data,
  }) : startTime = DateTime.now();
  final LoggerService logger;
  final String operation;
  final Map<String, dynamic>? data;
  final DateTime startTime;
  DateTime? endTime;

  void end({Map<String, dynamic>? resultData}) {
    endTime = DateTime.now();
    final Duration duration = endTime!.difference(startTime);
    
    logger.debug('Performance: $operation completed in ${duration.inMilliseconds}ms', data: <String, dynamic>{
      'operation': operation,
      'durationMs': duration.inMilliseconds,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime!.toIso8601String(),
      ...?data,
      ...?resultData,
    }, tag: 'PERFORMANCE',);
  }
}