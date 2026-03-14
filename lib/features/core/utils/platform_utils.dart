import 'dart:io';
import 'package:flutter/material.dart';

class PlatformUtils {
  // Check if platform is Android
  static bool get isAndroid => Platform.isAndroid;

  // Check if platform is iOS
  static bool get isIOS => Platform.isIOS;

  // Check if platform is Web
  static bool get isWeb => kIsWeb;

  // Check if platform is macOS
  static bool get isMacOS => Platform.isMacOS;

  // Check if platform is Windows
  static bool get isWindows => Platform.isWindows;

  // Check if platform is Linux
  static bool get isLinux => Platform.isLinux;

  // Check if platform is Fuchsia
  static bool get isFuchsia => Platform.isFuchsia;

  // Check if platform is mobile (Android or iOS)
  static bool get isMobile => isAndroid || isIOS;

  // Check if platform is desktop (macOS, Windows, Linux)
  static bool get isDesktop => isMacOS || isWindows || isLinux;

  // Get platform name
  static String get platformName {
    if (isWeb) return 'Web';
    if (isAndroid) return 'Android';
    if (isIOS) return 'iOS';
    if (isMacOS) return 'macOS';
    if (isWindows) return 'Windows';
    if (isLinux) return 'Linux';
    if (isFuchsia) return 'Fuchsia';
    return 'Unknown';
  }

  // Get platform from BuildContext
  static TargetPlatform getPlatform(BuildContext context) {
    return Theme.of(context).platform;
  }

  // Check if platform is iOS (from context)
  static bool isIOSPlatform(BuildContext context) {
    return getPlatform(context) == TargetPlatform.iOS;
  }

  // Check if platform is Android (from context)
  static bool isAndroidPlatform(BuildContext context) {
    return getPlatform(context) == TargetPlatform.android;
  }

  // Get adaptive value based on platform
  static T adaptive<T>({
    required T android,
    required T ios,
    T? web,
    T? macOS,
    T? windows,
    T? linux,
  }) {
    if (isWeb && web != null) return web;
    if (isAndroid) return android;
    if (isIOS) return ios;
    if (isMacOS && macOS != null) return macOS;
    if (isWindows && windows != null) return windows;
    if (isLinux && linux != null) return linux;
    return android; // Default fallback
  }

  // Get Cupertino or Material based on platform
  static Widget platformWidget({
    required Widget material,
    required Widget cupertino,
  }) {
    return adaptive(
      android: material,
      ios: cupertino,
    );
  }

  // Get platform specific icon
  static IconData getShareIcon() {
    return adaptive(
      android: Icons.share,
      ios: Icons.ios_share,
    );
  }

  static IconData getBackIcon() {
    return adaptive(
      android: Icons.arrow_back,
      ios: Icons.arrow_back_ios,
    );
  }

  static IconData getMoreIcon() {
    return adaptive(
      android: Icons.more_vert,
      ios: Icons.more_horiz,
    );
  }

  static IconData getSearchIcon() {
    return adaptive(
      android: Icons.search,
      ios: Icons.search,
    );
  }

  static IconData getSettingsIcon() {
    return adaptive(
      android: Icons.settings,
      ios: Icons.settings,
    );
  }

  // Get platform specific padding
  static EdgeInsets getAdaptivePadding() {
    return adaptive(
      android: EdgeInsets.zero,
      ios: const EdgeInsets.only(top: 44),
    );
  }

  // Check if device has notch
  static bool hasNotch(BuildContext context) {
    final EdgeInsets padding = MediaQuery.of(context).padding;
    return padding.top > 24 || padding.bottom > 24;
  }

  // Get status bar height
  static double getStatusBarHeight(BuildContext context) {
    return MediaQuery.of(context).padding.top;
  }

  // Get bottom safe area height
  static double getBottomSafeArea(BuildContext context) {
    return MediaQuery.of(context).padding.bottom;
  }
}