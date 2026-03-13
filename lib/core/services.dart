/// LotChat - Core Services Barrel File
/// This file exports all services for easy imports throughout the app
/// 
/// Created by: LotChat Team
/// Version: 1.0.0
/// Last Updated: 2024

library lotchat_services;

// ============================================================================
// Authentication & User Services
// ============================================================================

/// Service Config - Service configuration
export 'config/service_config.dart';
/// Service Constants - Service constants
export 'constants/service_constants.dart';
/// Service Locator - Dependency injection container
export 'di/service_locator.dart';
/// Service Factory - Creates service instances
export 'factories/service_factory.dart';
/// Service Registry - Service registration
export 'factories/service_registry.dart';
/// Auth Service Interface
export 'interfaces/auth_service_interface.dart';
/// Base Service Interface
export 'interfaces/base_service.dart';
/// Cache Service Interface
export 'interfaces/cache_service_interface.dart';
/// Database Service Interface
export 'interfaces/database_service_interface.dart';
/// Admin Service - Admin panel operations
export 'services/admin_service.dart';
/// Agency Service - Agency management
export 'services/agency_service.dart';
/// AI Service - AI operations
export 'services/ai_service.dart';
/// Amazon Service - Amazon APIs
export 'services/amazon_service.dart';
/// Analytics Service - User analytics
export 'services/analytics_service.dart';
/// API Service - HTTP requests
export 'services/api_service.dart';
/// Apple Service - Apple APIs
export 'services/apple_service.dart';
/// Audio Service - Audio processing
export 'services/audio_service.dart';
/// Authentication Service - Handles user login, registration, logout
export 'services/auth_service.dart';
/// Backup Service - Data backup
export 'services/backup_service.dart';
/// Biometric Service - Biometric authentication
export 'services/biometric_service.dart';
/// Block Service - User blocking
export 'services/block_service.dart';
/// Board Game Service - Board games (Ludo, Carrom)
export 'services/board_game_service.dart';
/// Cache Service - Caching layer for performance
export 'services/cache_service.dart';
/// Call Service - Voice/Video calls using Agora
export 'services/call_service.dart';
/// Card Game Service - Card games (3 Patti, Poker)
export 'services/card_game_service.dart';
/// Chat Service - Messaging system
export 'services/chat_service.dart';
/// Clan Service - Clan/Family system management
export 'services/clan_service.dart';
/// Config Service - App configuration
export 'services/config_service.dart';
/// Dashboard Service - Admin dashboard
export 'services/dashboard_service.dart';
/// Database Service - Firestore operations
export 'services/database_service.dart';
/// Debug Service - Debugging tools
export 'services/debug_service.dart';
/// Dev Service - Development tools
export 'services/dev_service.dart';
/// Device Service - Device information
export 'services/device_service.dart';
/// Email Service - Email notifications
export 'services/email_service.dart';
/// Encryption Service - Data encryption
export 'services/encryption_service.dart';
/// Error Service - Error handling
export 'services/error_service.dart';
/// Export Service - Data export
export 'services/export_service.dart';
/// Face Service - Face detection/recognition
export 'services/face_service.dart';
/// Facebook Service - Facebook APIs
export 'services/facebook_service.dart';
/// File Service - File management
export 'services/file_service.dart';
/// Filter Service - Content filtering
export 'services/filter_service.dart';
/// Firebase Service - Firebase operations
export 'services/firebase_service.dart';
/// Friend Service - Friend requests, suggestions, management
export 'services/friend_service.dart';
/// Game Service - Game logic and management
export 'services/game_service.dart';
/// Gift Service - Gift sending and receiving
export 'services/gift_service.dart';
/// Google Service - Google APIs
export 'services/google_service.dart';
/// GraphQL Service - GraphQL queries
export 'services/graphql_service.dart';
/// Image Service - Image processing
export 'services/image_service.dart';
/// Import Service - Data import
export 'services/import_service.dart';
/// Instagram Service - Instagram APIs
export 'services/instagram_service.dart';
/// Keychain Service - Secure key storage
export 'services/keychain_service.dart';
/// Leaderboard Service - Rankings and leaderboards
export 'services/leaderboard_service.dart';
/// Location Service - User location
export 'services/location_service.dart';
/// Logger Service - Logging system
export 'services/logger_service.dart';
/// Map Service - Maps and geolocation
export 'services/map_service.dart';
/// Microsoft Service - Microsoft APIs
export 'services/microsoft_service.dart';
/// ML Service - Machine learning
export 'services/ml_service.dart';
/// Mock Service - Mock data for testing
export 'services/mock_service.dart';
/// Moderation Service - Content moderation
export 'services/moderation_service.dart';
/// Network Service - Network connectivity
export 'services/network_service.dart';
/// NLP Service - Natural language processing
export 'services/nlp_service.dart';
/// Notification Service - Push notifications
export 'services/notification_service.dart';
/// Object Service - Object detection
export 'services/object_service.dart';
/// Payment Service - Coin purchases and transactions
export 'services/payment_service.dart';
/// PayPal Service - PayPal payments
export 'services/paypal_service.dart';
/// PDF Service - PDF generation
export 'services/pdf_service.dart';
/// Permission Service - Permission handling
export 'services/permission_service.dart';
/// PK Service - PK Battle system
export 'services/pk_service.dart';
/// Presence Service - Online/offline status tracking
export 'services/presence_service.dart';
/// QR Service - QR code generation/scanning
export 'services/qr_service.dart';
/// Razorpay Service - Razorpay payments
export 'services/razorpay_service.dart';
/// Recommendation Service - AI recommendations
export 'services/recommendation_service.dart';
/// Referral Service - Referral system
export 'services/referral_service.dart';
/// Report Service - User reporting system
export 'services/report_service.dart';
/// REST Service - REST API calls
export 'services/rest_service.dart';
/// Room Service - Voice room management
export 'services/room_service.dart';
/// Roulette Service - Roulette game
export 'services/roulette_service.dart';
/// Search Service - Search functionality
export 'services/search_service.dart';
/// Security Service - Security features
export 'services/security_service.dart';
/// Seller Service - Coin seller management
export 'services/seller_service.dart';
/// Session Service - Manages user sessions
export 'services/session_service.dart';
/// SMS Service - SMS notifications
export 'services/sms_service.dart';
/// Socket Service - Real-time connections via Socket.io
export 'services/socket_service.dart';
/// Speech Service - Speech recognition
export 'services/speech_service.dart';
/// Spotify Service - Spotify APIs
export 'services/spotify_service.dart';
/// Storage Service - Local storage (SharedPreferences, Hive)
export 'services/storage_service.dart';
/// Stripe Service - Stripe payments
export 'services/stripe_service.dart';
/// Sync Service - Data synchronization
export 'services/sync_service.dart';
/// Test Service - Testing utilities
export 'services/test_service.dart';
/// Text Service - Text recognition
export 'services/text_service.dart';
/// Transaction Service - Transaction history
export 'services/transaction_service.dart';
/// Translation Service - Voice translation
export 'services/translation_service.dart';
/// Twitter Service - Twitter APIs
export 'services/twitter_service.dart';
/// Typing Service - Real-time typing indicators
export 'services/typing_service.dart';
/// Upload Service - File uploads to Firebase Storage
export 'services/upload_service.dart';
/// User Service - Manages user profiles and data
export 'services/user_service.dart';
/// Video Service - Video processing
export 'services/video_service.dart';
/// Vision Service - Computer vision
export 'services/vision_service.dart';
/// Wallet Service - User wallet management
export 'services/wallet_service.dart';
/// Weather Service - Weather information
export 'services/weather_service.dart';
/// WebSocket Service - WebSocket connections
export 'services/websocket_service.dart';
/// YouTube Service - YouTube APIs
export 'services/youtube_service.dart';

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