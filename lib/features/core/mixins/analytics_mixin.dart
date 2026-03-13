import 'package:flutter/material.dart';
import '../../../core/services/analytics_service.dart';
import '../../../core/di/service_locator.dart';

mixin AnalyticsMixin<T extends StatefulWidget> on State<T> {
  final AnalyticsService _analytics = ServiceLocator().get<AnalyticsService>();
  
  @override
  void initState() {
    super.initState();
    _trackScreen();
  }

  // Track current screen
  void _trackScreen() {
    final routeName = ModalRoute.of(context)?.settings.name ?? 'unknown';
    final String className = widget.runtimeType.toString();
    _analytics.trackScreen(className, screenClass: routeName);
  }

  // Track event
  Future<void> trackEvent(String eventName, {Map<String, dynamic>? parameters}) async {
    await _analytics.trackEvent(eventName, parameters: parameters);
  }

  // Track user action
  Future<void> trackUserAction(String action, {Map<String, dynamic>? properties}) async {
    await trackEvent('user_action', parameters: <String, dynamic>{
      'action': action,
      ...?properties,
    });
  }

  // Track button click
  Future<void> trackButtonClick(String buttonName, {Map<String, dynamic>? properties}) async {
    await trackEvent('button_click', parameters: <String, dynamic>{
      'button_name': buttonName,
      'screen': widget.runtimeType.toString(),
      ...?properties,
    });
  }

  // Track form submission
  Future<void> trackFormSubmit(String formName, {bool success = true, String? error}) async {
    await trackEvent('form_submit', parameters: <String, dynamic>{
      'form_name': formName,
      'success': success,
      if (error != null) 'error': error,
      'screen': widget.runtimeType.toString(),
    });
  }

  // Track search
  Future<void> trackSearch(String query, {int resultCount = 0}) async {
    await trackEvent('search', parameters: <String, dynamic>{
      'query': query,
      'result_count': resultCount,
      'screen': widget.runtimeType.toString(),
    });
  }

  // Track filter
  Future<void> trackFilter(Map<String, dynamic> filters) async {
    await trackEvent('filter', parameters: <String, dynamic>{
      ...filters,
      'screen': widget.runtimeType.toString(),
    });
  }

  // Track pagination
  Future<void> trackPagination(int page, int pageSize) async {
    await trackEvent('pagination', parameters: <String, dynamic>{
      'page': page,
      'page_size': pageSize,
      'screen': widget.runtimeType.toString(),
    });
  }

  // Track error
  Future<void> trackError(String error, {String? description, StackTrace? stackTrace}) async {
    await trackEvent('error', parameters: <String, dynamic>{
      'error': error,
      if (description != null) 'description': description,
      'screen': widget.runtimeType.toString(),
    });
  }

  // Track performance
  Future<void> trackPerformance(String operation, Duration duration) async {
    await trackEvent('performance', parameters: <String, dynamic>{
      'operation': operation,
      'duration_ms': duration.inMilliseconds,
      'screen': widget.runtimeType.toString(),
    });
  }

  // Track feature usage
  Future<void> trackFeatureUsage(String feature, {Map<String, dynamic>? properties}) async {
    await trackEvent('feature_usage', parameters: <String, dynamic>{
      'feature': feature,
      ...?properties,
      'screen': widget.runtimeType.toString(),
    });
  }

  // Track navigation
  Future<void> trackNavigation(String from, String to) async {
    await trackEvent('navigation', parameters: <String, dynamic>{
      'from': from,
      'to': to,
    });
  }

  // Track share
  Future<void> trackShare(String contentType, String itemId) async {
    await trackEvent('share', parameters: <String, dynamic>{
      'content_type': contentType,
      'item_id': itemId,
    });
  }

  // Track rating
  Future<void> trackRating(int rating, {String? comment}) async {
    await trackEvent('rating', parameters: <String, dynamic>{
      'rating': rating,
      if (comment != null) 'comment': comment,
    });
  }

  // Track time spent
  final Map<String, DateTime> _timers = <String, DateTime>{};

  void startTimer(String timerName) {
    _timers[timerName] = DateTime.now();
  }

  Future<void> endTimer(String timerName) async {
    final DateTime? start = _timers[timerName];
    if (start != null) {
      final Duration duration = DateTime.now().difference(start);
      await trackPerformance(timerName, duration);
      _timers.remove(timerName);
    }
  }

  // Set user properties
  Future<void> setUserProperties(Map<String, dynamic> properties) async {
    for (MapEntry<String, dynamic> entry in properties.entries) {
      await _analytics.setUserProperty(entry.key, entry.value.toString());
    }
  }

  // Track session
  DateTime? _sessionStart;

  void startSession() {
    _sessionStart = DateTime.now();
  }

  Future<void> endSession() async {
    if (_sessionStart != null) {
      final Duration duration = DateTime.now().difference(_sessionStart!);
      await trackPerformance('session_duration', duration);
      _sessionStart = null;
    }
  }
}