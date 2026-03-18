/// LotChat - Core Services Barrel File
/// This file exports all services for easy imports throughout the app
///
/// Created by: LotChat Team
/// Version: 1.0.0
/// Last Updated: 2024

library core_services;

// ============================================================================
// Core Services
// ============================================================================

/// Service Locator - Dependency injection container
export 'di/service_locator.dart';

// ============================================================================
// Existing Services (যে ফাইলগুলো আসলে আছে)
// ============================================================================

/// API Service - HTTP requests
export 'services/api_service.dart';

/// Authentication Service - Handles user login, registration, logout
export 'services/auth_service.dart';

/// Database Service - Firestore operations
export 'services/database_service.dart';

/// Firebase Service - Firebase operations
export 'services/firebase_service.dart';

/// Notification Service - Push notifications
export 'services/notification_service.dart';

/// Payment Service - Coin purchases and transactions
export 'services/payment_service.dart';

/// Seller Service - Coin seller management
export 'services/seller_service.dart';

/// Socket Service - Real-time connections via Socket.io
export 'services/socket_service.dart';

/// Storage Service - Local storage (SharedPreferences, Hive)
export 'services/storage_service.dart';

/// Upload Service - File uploads to Firebase Storage
export 'services/upload_service.dart';

// ============================================================================
// Additional Services (আপনার প্রজেক্টে যা আছে)
// ============================================================================

/// আপনার অন্যান্য services এখানে যোগ করুন
/// যেমন: call_service.dart, game_service.dart ইত্যাদি

// ============================================================================
// Convenience Exports
// ============================================================================

/// Export all core services in a single import
/// Usage: import 'package:lotchat_app/core/services.dart';
///
/// To get a service from ServiceLocator:
/// final authService = ServiceLocator().get<AuthService>();
///
/// To create a new service instance:
/// final analyticsService = AnalyticsService();
///
/// For detailed documentation, see:
/// https://docs.lotchat.app/services

// ============================================================================
// Version Information
// ============================================================================

/// Services package version
const String servicesVersion = '1.0.0';

/// Services package name
const String servicesPackage = 'lotchat_services';

/// Last updated timestamp
const String servicesLastUpdated = '2024-01-15';