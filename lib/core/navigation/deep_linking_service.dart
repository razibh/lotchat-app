import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // 🟢 kDebugMode এর জন্য
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:url_launcher/url_launcher.dart';
import 'navigation_service.dart';
import 'route_constants.dart';

class DeepLinkingService {
  factory DeepLinkingService() => _instance;
  DeepLinkingService._internal();
  static final DeepLinkingService _instance = DeepLinkingService._internal();

  final FirebaseDynamicLinks _dynamicLinks = FirebaseDynamicLinks.instance;
  StreamSubscription<PendingDynamicLinkData>? _dynamicLinksSubscription; // 🟢 Fixed type

  // Initialize deep linking
  Future<void> initDynamicLinks() async {
    // Handle links when app is already running
    _dynamicLinksSubscription = _dynamicLinks.onLink.listen(
          (PendingDynamicLinkData dynamicLink) {
        _handleDeepLink(dynamicLink);
      },
      onError: (e) {
        if (kDebugMode) {
          print('Error handling dynamic link: $e');
        }
      },
    );

    // Handle links that opened the app
    final PendingDynamicLinkData? initialLink = await _dynamicLinks.getInitialLink();
    if (initialLink != null) {
      _handleDeepLink(initialLink);
    }
  }

  // Handle deep link
  void _handleDeepLink(PendingDynamicLinkData? dynamicLink) {
    if (dynamicLink == null) return;

    final Uri? deepLink = dynamicLink.link;
    if (deepLink == null) return;

    if (kDebugMode) {
      print('Deep link received: $deepLink');
    }

    // Parse the link and navigate
    _navigateToDeepLink(deepLink);
  }

  // Navigate based on deep link
  void _navigateToDeepLink(Uri uri) {
    final String path = uri.path;
    final Map<String, String> queryParams = uri.queryParameters;

    // Example: https://lotchat.app/user/123
    if (path.startsWith('/user/')) {
      final String userId = path.replaceFirst('/user/', '');
      NavigationService.navigateTo(
        RouteConstants.profileView,
        arguments: {'userId': userId},
      );
    }
    // Example: https://lotchat.app/room/456
    else if (path.startsWith('/room/')) {
      final String roomId = path.replaceFirst('/room/', '');
      NavigationService.navigateTo(
        RouteConstants.room,
        arguments: {'roomId': roomId},
      );
    }
    // Example: https://lotchat.app/clan/789
    else if (path.startsWith('/clan/')) {
      final String clanId = path.replaceFirst('/clan/', '');
      NavigationService.navigateTo(
        RouteConstants.clanDetail,
        arguments: {'clanId': clanId},
      );
    }
    // Example: https://lotchat.app/promotion?code=WELCOME50
    else if (path == '/promotion') {
      final String? code = queryParams['code'];
      if (code != null) {
        NavigationService.navigateTo(
          '/promotion',
          arguments: {'code': code},
        );
      }
    }
  }

  // Create dynamic link
  Future<String?> createDynamicLink({
    required String path,
    Map<String, String>? queryParams,
    String? title,
    String? description,
    String? imageUrl,
  }) async {
    try {
      // Build the link
      String link = 'https://lotchat.app$path';
      if (queryParams != null && queryParams.isNotEmpty) {
        final uri = Uri(
          scheme: 'https',
          host: 'lotchat.app',
          path: path,
          queryParameters: queryParams,
        );
        link = uri.toString();
      }

      final DynamicLinkParameters parameters = DynamicLinkParameters(
        uriPrefix: 'https://lotchat.page.link',
        link: Uri.parse(link),
        androidParameters: const AndroidParameters(
          packageName: 'com.lotchat.app',
          minimumVersion: 1,
        ),
        iosParameters: const IOSParameters(
          bundleId: 'com.lotchat.app',
          minimumVersion: '1.0.0',
          appStoreId: '123456789',
        ),
        socialMetaTagParameters: SocialMetaTagParameters(
          title: title ?? 'LotChat',
          description: description ?? 'Join me on LotChat!',
          imageUrl: imageUrl != null ? Uri.parse(imageUrl) : null,
        ),
      );

      final ShortDynamicLink shortLink = await _dynamicLinks.buildShortLink(parameters);

      return shortLink.shortUrl.toString();
    } catch (e) {
      if (kDebugMode) {
        print('Error creating dynamic link: $e');
      }
      return null;
    }
  }

  // Share deep link
  Future<void> shareDeepLink(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error sharing deep link: $e');
      }
    }
  }

  // Create invite link
  Future<String?> createInviteLink({
    required String userId,
    String? referralCode,
  }) async {
    return createDynamicLink(
      path: '/invite',
      queryParams: {
        'ref': referralCode ?? userId,
        'user': userId,
      },
      title: 'Join me on LotChat!',
      description: 'Download LotChat and connect with me!',
    );
  }

  // Dispose
  void dispose() {
    _dynamicLinksSubscription?.cancel();
  }
}