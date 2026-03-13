import 'package:flutter/material.dart';

import '../../core/di/service_locator.dart';
import '../../core/services/analytics_service.dart';

class NavigationObserver extends NavigatorObserver {
  final AnalyticsService _analytics = ServiceLocator().get<AnalyticsService>();

  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    _sendScreenView(route);
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    if (previousRoute != null) {
      _sendScreenView(previousRoute);
    }
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute != null) {
      _sendScreenView(newRoute);
    }
  }

  void _sendScreenView(Route route) {
    if (route.settings.name != null) {
      _analytics.trackScreen(
        route.settings.name!,
        screenClass: route.settings.name,
      );
    }
  }
}

// Route Aware Widget Mixin
mixin RouteAwareMixin on State<StatefulWidget> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route != null && route.settings.name != null) {
      ServiceLocator().get<AnalyticsService>().trackScreen(
        route.settings.name!,
        screenClass: route.settings.name,
      );
    }
  }
}