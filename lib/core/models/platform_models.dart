import 'package:flutter/material.dart';

// Platform Enums
enum PlatformRole { user, host, agency, admin, moderator }
enum PlatformStatus { active, inactive, suspended, banned }
enum PlatformGender { male, female, other }
enum PlatformVerificationStatus { unverified, pending, verified, rejected }

// Platform User Model
class PlatformUser {
  final String id;
  final String username;
  final String email;
  final String? phone;
  final String? displayName;
  final String? avatar;
  final String? coverImage;
  final PlatformRole role;
  final PlatformStatus status;
  final PlatformVerificationStatus verificationStatus;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final bool isEmailVerified;
  final bool isPhoneVerified;
  final bool isTwoFactorEnabled;
  final String? countryCode;
  final String? languageCode;
  final PlatformGender? gender;
  final DateTime? dateOfBirth;
  final String? bio;
  final Map<String, dynamic> settings;
  final Map<String, dynamic> preferences;
  final Map<String, dynamic> metadata;

  PlatformUser({
    required this.id,
    required this.username,
    required this.email,
    this.phone,
    this.displayName,
    this.avatar,
    this.coverImage,
    required this.role,
    required this.status,
    required this.verificationStatus,
    required this.createdAt,
    this.lastLoginAt,
    this.isEmailVerified = false,
    this.isPhoneVerified = false,
    this.isTwoFactorEnabled = false,
    this.countryCode,
    this.languageCode,
    this.gender,
    this.dateOfBirth,
    this.bio,
    this.settings = const {},
    this.preferences = const {},
    this.metadata = const {},
  });

  // CopyWith method
  PlatformUser copyWith({
    String? id,
    String? username,
    String? email,
    String? phone,
    String? displayName,
    String? avatar,
    String? coverImage,
    PlatformRole? role,
    PlatformStatus? status,
    PlatformVerificationStatus? verificationStatus,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    bool? isEmailVerified,
    bool? isPhoneVerified,
    bool? isTwoFactorEnabled,
    String? countryCode,
    String? languageCode,
    PlatformGender? gender,
    DateTime? dateOfBirth,
    String? bio,
    Map<String, dynamic>? settings,
    Map<String, dynamic>? preferences,
    Map<String, dynamic>? metadata,
  }) {
    return PlatformUser(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      displayName: displayName ?? this.displayName,
      avatar: avatar ?? this.avatar,
      coverImage: coverImage ?? this.coverImage,
      role: role ?? this.role,
      status: status ?? this.status,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
      isTwoFactorEnabled: isTwoFactorEnabled ?? this.isTwoFactorEnabled,
      countryCode: countryCode ?? this.countryCode,
      languageCode: languageCode ?? this.languageCode,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      bio: bio ?? this.bio,
      settings: settings ?? this.settings,
      preferences: preferences ?? this.preferences,
      metadata: metadata ?? this.metadata,
    );
  }
}

// Platform Settings Model
class PlatformSettings {
  final bool allowNotifications;
  final bool allowMarketingEmails;
  final bool allowPushNotifications;
  final bool darkMode;
  final String language;
  final String currency;
  final String country;
  final Map<String, dynamic> privacySettings;
  final Map<String, dynamic> notificationSettings;

  PlatformSettings({
    this.allowNotifications = true,
    this.allowMarketingEmails = false,
    this.allowPushNotifications = true,
    this.darkMode = false,
    this.language = 'en',
    this.currency = 'BDT',
    this.country = 'BD',
    this.privacySettings = const {},
    this.notificationSettings = const {},
  });

  // CopyWith method
  PlatformSettings copyWith({
    bool? allowNotifications,
    bool? allowMarketingEmails,
    bool? allowPushNotifications,
    bool? darkMode,
    String? language,
    String? currency,
    String? country,
    Map<String, dynamic>? privacySettings,
    Map<String, dynamic>? notificationSettings,
  }) {
    return PlatformSettings(
      allowNotifications: allowNotifications ?? this.allowNotifications,
      allowMarketingEmails: allowMarketingEmails ?? this.allowMarketingEmails,
      allowPushNotifications: allowPushNotifications ?? this.allowPushNotifications,
      darkMode: darkMode ?? this.darkMode,
      language: language ?? this.language,
      currency: currency ?? this.currency,
      country: country ?? this.country,
      privacySettings: privacySettings ?? this.privacySettings,
      notificationSettings: notificationSettings ?? this.notificationSettings,
    );
  }
}

// Platform Response Model
class PlatformResponse<T> {
  final bool success;
  final String? message;
  final T? data;
  final PlatformError? error;
  final int? statusCode;
  final DateTime timestamp;

  PlatformResponse({
    required this.success,
    this.message,
    this.data,
    this.error,
    this.statusCode,
    required this.timestamp,
  });

  // Factory for success response
  factory PlatformResponse.success(T data, {String? message, int? statusCode}) {
    return PlatformResponse(
      success: true,
      message: message,
      data: data,
      statusCode: statusCode,
      timestamp: DateTime.now(),
    );
  }

  // Factory for error response
  factory PlatformResponse.error(PlatformError error, {int? statusCode}) {
    return PlatformResponse(
      success: false,
      error: error,
      message: error.message,
      statusCode: statusCode,
      timestamp: DateTime.now(),
    );
  }
}

// Platform Error Model
class PlatformError {
  final String code;
  final String message;
  final String? details;
  final StackTrace? stackTrace;

  PlatformError({
    required this.code,
    required this.message,
    this.details,
    this.stackTrace,
  });

  // Common errors
  static const String networkError = 'NETWORK_ERROR';
  static const String authError = 'AUTH_ERROR';
  static const String validationError = 'VALIDATION_ERROR';
  static const String serverError = 'SERVER_ERROR';
  static const String notFoundError = 'NOT_FOUND';
  static const String permissionError = 'PERMISSION_ERROR';
  static const String rateLimitError = 'RATE_LIMIT_ERROR';
  static const String unknownError = 'UNKNOWN_ERROR';
}

// Platform Pagination Model
class PlatformPagination<T> {
  final List<T> items;
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int itemsPerPage;
  final bool hasNextPage;
  final bool hasPreviousPage;

  PlatformPagination({
    required this.items,
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.itemsPerPage,
    required this.hasNextPage,
    required this.hasPreviousPage,
  });
}

// Platform API Request Model
class PlatformRequest<T> {
  final String path;
  final String method;
  final Map<String, String>? headers;
  final Map<String, dynamic>? queryParams;
  final T? body;
  final bool requiresAuth;

  PlatformRequest({
    required this.path,
    required this.method,
    this.headers,
    this.queryParams,
    this.body,
    this.requiresAuth = true,
  });
}

// Platform File Model
class PlatformFile {
  final String id;
  final String name;
  final String path;
  final String url;
  final String mimeType;
  final int size;
  final DateTime uploadedAt;
  final Map<String, dynamic> metadata;

  PlatformFile({
    required this.id,
    required this.name,
    required this.path,
    required this.url,
    required this.mimeType,
    required this.size,
    required this.uploadedAt,
    this.metadata = const {},
  });
}

// Platform Location Model
class PlatformLocation {
  final double latitude;
  final double longitude;
  final String? address;
  final String? city;
  final String? state;
  final String? country;
  final String? postalCode;

  PlatformLocation({
    required this.latitude,
    required this.longitude,
    this.address,
    this.city,
    this.state,
    this.country,
    this.postalCode,
  });
}

// Platform Device Info Model
class PlatformDeviceInfo {
  final String deviceId;
  final String deviceType;
  final String deviceModel;
  final String operatingSystem;
  final String operatingSystemVersion;
  final String appVersion;
  final String? pushToken;
  final Map<String, dynamic>? additionalInfo;

  PlatformDeviceInfo({
    required this.deviceId,
    required this.deviceType,
    required this.deviceModel,
    required this.operatingSystem,
    required this.operatingSystemVersion,
    required this.appVersion,
    this.pushToken,
    this.additionalInfo,
  });
}

// Platform Session Model
class PlatformSession {
  final String sessionId;
  final String userId;
  final String deviceId;
  final String ipAddress;
  final DateTime createdAt;
  final DateTime expiresAt;
  final DateTime? lastActivityAt;
  final bool isValid;

  PlatformSession({
    required this.sessionId,
    required this.userId,
    required this.deviceId,
    required this.ipAddress,
    required this.createdAt,
    required this.expiresAt,
    this.lastActivityAt,
    this.isValid = true,
  });
}

// Platform Notification Model
class PlatformNotification {
  final String id;
  final String userId;
  final String title;
  final String body;
  final String type;
  final Map<String, dynamic> data;
  final bool isRead;
  final DateTime createdAt;

  PlatformNotification({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    required this.data,
    this.isRead = false,
    required this.createdAt,
  });

  // CopyWith method
  PlatformNotification copyWith({
    String? id,
    String? userId,
    String? title,
    String? body,
    String? type,
    Map<String, dynamic>? data,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return PlatformNotification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      data: data ?? this.data,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

// Platform Coin Transaction Model
class PlatformCoinTransaction {
  final String id;
  final String userId;
  final int amount;
  final String type; // 'earn', 'spend', 'purchase', 'gift'
  final String description;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;

  PlatformCoinTransaction({
    required this.id,
    required this.userId,
    required this.amount,
    required this.type,
    required this.description,
    required this.timestamp,
    this.metadata = const {},
  });
}

// Platform Gift Model
class PlatformGift {
  final String id;
  final String name;
  final String icon;
  final int coinValue;
  final double? cashValue;
  final String category;
  final bool isAnimated;
  final bool isLimited;
  final DateTime? expiresAt;
  final Map<String, dynamic> animationData;

  PlatformGift({
    required this.id,
    required this.name,
    required this.icon,
    required this.coinValue,
    this.cashValue,
    required this.category,
    this.isAnimated = false,
    this.isLimited = false,
    this.expiresAt,
    this.animationData = const {},
  });
}

// Platform Theme Model
class PlatformTheme {
  final String id;
  final String name;
  final Color primaryColor;
  final Color secondaryColor;
  final Color accentColor;
  final Color backgroundColor;
  final Color surfaceColor;
  final Color textColor;
  final bool isDark;

  PlatformTheme({
    required this.id,
    required this.name,
    required this.primaryColor,
    required this.secondaryColor,
    required this.accentColor,
    required this.backgroundColor,
    required this.surfaceColor,
    required this.textColor,
    required this.isDark,
  });

  // Light theme factory
  factory PlatformTheme.light() {
    return PlatformTheme(
      id: 'light',
      name: 'Light',
      primaryColor: Colors.pink,
      secondaryColor: Colors.purple,
      accentColor: Colors.blue,
      backgroundColor: Colors.white,
      surfaceColor: Colors.grey[100]!,
      textColor: Colors.black,
      isDark: false,
    );
  }

  // Dark theme factory
  factory PlatformTheme.dark() {
    return PlatformTheme(
      id: 'dark',
      name: 'Dark',
      primaryColor: Colors.pink[300]!,
      secondaryColor: Colors.purple[300]!,
      accentColor: Colors.blue[300]!,
      backgroundColor: Colors.grey[900]!,
      surfaceColor: Colors.grey[800]!,
      textColor: Colors.white,
      isDark: true,
    );
  }
}