import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;

class AppVersion {
  // App Information
  static const String appName = 'LotChat';
  static const String appVersion = '1.0.0';
  static const String appBuildNumber = '1';
  static const String appPackageName = 'com.lotchat.app';
  static const String appFlavor = 'production'; // development, staging, production

  // Build Information
  static const String buildDate = '2024-01-15';
  static const String buildCommit = 'abc123def';
  static const String buildBranch = 'main';

  // Minimum Requirements
  static const String minIosVersion = '13.0';
  static const String minAndroidVersion = '6.0';
  static const int minIosBuild = 1;
  static const int minAndroidBuild = 1;

  // Latest Versions
  static const String latestIosVersion = '1.0.0';
  static const String latestAndroidVersion = '1.0.0';
  static const int latestIosBuild = 1;
  static const int latestAndroidBuild = 1;

  // Force Update Settings
  static const bool forceIosUpdate = false;
  static const bool forceAndroidUpdate = false;

  // Update Messages
  static const String updateMessage = 'A new version of LotChat is available. Please update to continue using the app.';
  static const String optionalUpdateMessage = 'A new version of LotChat is available. Would you like to update now?';

  // Store URLs
  static const String iosStoreUrl = 'https://apps.apple.com/app/id123456789';
  static const String androidStoreUrl = 'https://play.google.com/store/apps/details?id=com.lotchat.app';

  // Release Notes
  static const Map<String, String> releaseNotes = {
    '1.0.0': '''
      • Initial release
      • Chat with friends
      • Send gifts
      • Voice and video calls
      • Games and entertainment
      • Clan system
      • PK battles
    ''',
  };

  // Changelog
  static const List<Map<String, dynamic>> changelog = [
    {
      'version': '1.0.0',
      'build': 1,
      'date': '2024-01-15',
      'type': 'major',
      'features': [
        'Initial release',
        'Chat system with real-time messaging',
        'Gift system with animations',
        'Voice and video calls',
        'Games: Spin, Bet, Match',
        'Clan creation and management',
        'PK battles with real-time scores',
        'Agency system for referrals',
        'Seller system for coin trading',
        'Multi-language support',
        'Dark/Light theme',
      ],
      'improvements': [],
      'bugFixes': [],
      'security': [],
    },
  ];

  // App Store Review
  static const String appStoreReviewUrl = 'https://apps.apple.com/app/id123456789?action=write-review';
  static const String playStoreReviewUrl = 'https://play.google.com/store/apps/details?id=com.lotchat.app&showAllReviews=true';

  // Support Email
  static const String supportEmail = 'support@lotchat.com';
  static const String supportSubject = 'App Support';
  static const String supportBodyTemplate = '''
    App Version: %s
    Build Number: %s
    Platform: %s
    Issue Description:
  ''';

  // Version Comparison Methods
  static bool isNewerVersion(String currentVersion, String newVersion) {
    final currentParts = currentVersion.split('.').map(int.parse).toList();
    final newParts = newVersion.split('.').map(int.parse).toList();

    for (int i = 0; i < currentParts.length; i++) {
      if (i >= newParts.length) return false;
      if (newParts[i] > currentParts[i]) return true;
      if (newParts[i] < currentParts[i]) return false;
    }

    return newParts.length > currentParts.length;
  }

  static bool isMajorUpdate(String currentVersion, String newVersion) {
    final currentMajor = int.parse(currentVersion.split('.')[0]);
    final newMajor = int.parse(newVersion.split('.')[0]);
    return newMajor > currentMajor;
  }

  static bool isMinorUpdate(String currentVersion, String newVersion) {
    final currentParts = currentVersion.split('.').map(int.parse).toList();
    final newParts = newVersion.split('.').map(int.parse).toList();

    if (newParts[0] > currentParts[0]) return false;
    if (newParts[0] < currentParts[0]) return false;

    return newParts[1] > currentParts[1];
  }

  static bool isPatchUpdate(String currentVersion, String newVersion) {
    final currentParts = currentVersion.split('.').map(int.parse).toList();
    final newParts = newVersion.split('.').map(int.parse).toList();

    if (newParts[0] > currentParts[0]) return false;
    if (newParts[0] < currentParts[0]) return false;
    if (newParts[1] > currentParts[1]) return false;
    if (newParts[1] < currentParts[1]) return false;

    return newParts[2] > currentParts[2];
  }

  // Get Release Notes
  static String getReleaseNotes(String version) {
    return releaseNotes[version] ?? 'No release notes available for this version.';
  }

  // Get Latest Release Notes
  static String getLatestReleaseNotes() {
    return getReleaseNotes(appVersion);
  }

  // Get Changelog
  static List<Map<String, dynamic>> getChangelog() {
    return changelog;
  }

  // Check if Update Required
  static bool isUpdateRequired(String currentVersion, int currentBuild) {
    if (appFlavor == 'production') {
      if (defaultTargetPlatform == TargetPlatform.iOS && currentBuild < minIosBuild) {
        return true;
      }
      if (defaultTargetPlatform == TargetPlatform.android && currentBuild < minAndroidBuild) {
        return true;
      }
    }
    return false;
  }

  // Get Store URL based on Platform
  static String getStoreUrl() {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return iosStoreUrl;
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      return androidStoreUrl;
    }
    return '';
  }

  // Version String
  static String getVersionString() {
    return '$appVersion ($appBuildNumber)';
  }

  // Full App Info
  static String getAppInfo() {
    return '''
      App Name: $appName
      Version: $appVersion
      Build: $appBuildNumber
      Package: $appPackageName
      Flavor: $appFlavor
      Build Date: $buildDate
      Platform: ${defaultTargetPlatform.name}
    ''';
  }

  // Compare Build Numbers
  static bool isNewerBuild(int currentBuild, int newBuild) {
    return newBuild > currentBuild;
  }

  // Get Update Type
  static String getUpdateType(String currentVersion, String newVersion) {
    if (isMajorUpdate(currentVersion, newVersion)) return 'major';
    if (isMinorUpdate(currentVersion, newVersion)) return 'minor';
    if (isPatchUpdate(currentVersion, newVersion)) return 'patch';
    return 'none';
  }

  // Should Show Update Dialog
  static bool shouldShowUpdateDialog(String currentVersion, int currentBuild) {
    if (isUpdateRequired(currentVersion, currentBuild)) return true;

    if (appFlavor == 'production') {
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        return isNewerVersion(currentVersion, latestIosVersion);
      } else if (defaultTargetPlatform == TargetPlatform.android) {
        return isNewerVersion(currentVersion, latestAndroidVersion);
      }
    }

    return false;
  }

  // Get Update Message
  static String getUpdateMessage(String currentVersion, String newVersion) {
    if (isUpdateRequired(currentVersion, int.parse(appBuildNumber))) {
      return updateMessage;
    }
    return optionalUpdateMessage;
  }

  // Version Parts
  static int getMajorVersion(String version) {
    return int.parse(version.split('.')[0]);
  }

  static int getMinorVersion(String version) {
    return int.parse(version.split('.')[1]);
  }

  static int getPatchVersion(String version) {
    return int.parse(version.split('.')[2]);
  }

  // Version Validation
  static bool isValidVersion(String version) {
    final RegExp versionRegex = RegExp(r'^\d+\.\d+\.\d+$');
    return versionRegex.hasMatch(version);
  }

  // Build Validation
  static bool isValidBuild(int build) {
    return build > 0;
  }

  // Platform Specific (methods instead of getters)
  static bool isIos() => defaultTargetPlatform == TargetPlatform.iOS;
  static bool isAndroid() => defaultTargetPlatform == TargetPlatform.android;
  static bool isWeb() => kIsWeb;
  static bool isDesktop() => !kIsWeb && (isWindows() || isMacOS() || isLinux());
  static bool isWindows() => defaultTargetPlatform == TargetPlatform.windows;
  static bool isMacOS() => defaultTargetPlatform == TargetPlatform.macOS;
  static bool isLinux() => defaultTargetPlatform == TargetPlatform.linux;

  // Get Review URL
  static String getReviewUrl() {
    if (isIos()) return appStoreReviewUrl;
    if (isAndroid()) return playStoreReviewUrl;
    return '';
  }

  // Get Support Body
  static String getSupportBody() {
    return supportBodyTemplate
        .replaceFirst('%s', appVersion)
        .replaceFirst('%s', appBuildNumber)
        .replaceFirst('%s', defaultTargetPlatform.name);
  }
}