import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import 'navigation_service.dart';
import 'route_constants.dart';
import 'package:flutter/services.dart';

class DeepLinkingService {
  factory DeepLinkingService() => _instance;
  DeepLinkingService._internal();
  static final DeepLinkingService _instance = DeepLinkingService._internal();

  // Initialize deep linking (for mobile platforms)
  Future<void> initDeepLinking() async {

    if (!kIsWeb) {

    }
  }

  // Handle deep link from platform channels (for mobile)
  void handleIncomingLink(String link) {
    if (kDebugMode) {
      print('Deep link received: $link');
    }

    try {
      final Uri uri = Uri.parse(link);
      _navigateToDeepLink(uri);
    } catch (e) {
      if (kDebugMode) {
        print('Error parsing deep link: $e');
      }
    }
  }

  // Navigate based on deep link
  void _navigateToDeepLink(Uri uri) {
    final String path = uri.path;
    final Map<String, String> queryParams = uri.queryParameters;

    if (path.startsWith('/user/')) {
      final String userId = path.replaceFirst('/user/', '');
      NavigationService.navigateTo(
        RouteConstants.profileView,
        arguments: {'userId': userId},
      );
    }

    else if (path.startsWith('/room/')) {
      final String roomId = path.replaceFirst('/room/', '');
      NavigationService.navigateTo(
        RouteConstants.room,
        arguments: {'roomId': roomId},
      );
    }

    else if (path.startsWith('/clan/')) {
      final String clanId = path.replaceFirst('/clan/', '');
      NavigationService.navigateTo(
        RouteConstants.clanDetail,
        arguments: {'clanId': clanId},
      );
    }

    else if (path == '/promotion') {
      final String? code = queryParams['code'];
      if (code != null) {
        NavigationService.navigateTo(
          '/promotion',
          arguments: {'code': code},
        );
      }
    }

    else if (path == '/invite') {
      final String? ref = queryParams['ref'];
      final String? user = queryParams['user'];
      if (ref != null) {
        NavigationService.navigateTo(
          '/invite',
          arguments: {'referralCode': ref, 'userId': user},
        );
      }
    }
  }


  String createShareableLink({
    required String path,
    Map<String, String>? queryParams,
  }) {
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
      return link;
    } catch (e) {
      if (kDebugMode) {
        print('Error creating shareable link: $e');
      }
      return 'https://lotchat.app';
    }
  }

  // Share deep link
  Future<void> shareDeepLink(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        // Fallback - copy to clipboard
        await _copyToClipboard(url);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error sharing deep link: $e');
      }
      await _copyToClipboard(url);
    }
  }

  // Copy text to clipboard
  Future<void> _copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (kDebugMode) {
      print('Copied to clipboard: $text');
    }
  }

  // Create invite link
  String createInviteLink({
    required String userId,
    String? referralCode,
  }) {
    return createShareableLink(
      path: '/invite',
      queryParams: {
        'ref': referralCode ?? userId,
        'user': userId,
      },
    );
  }

  // Create promotion link
  String createPromotionLink(String code) {
    return createShareableLink(
      path: '/promotion',
      queryParams: {'code': code},
    );
  }

  // Parse invite link data
  Map<String, String?>? parseInviteLink(String url) {
    try {
      final uri = Uri.parse(url);
      if (uri.path == '/invite') {
        return {
          'referralCode': uri.queryParameters['ref'],
          'userId': uri.queryParameters['user'],
        };
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error parsing invite link: $e');
      }
      return null;
    }
  }

  // Dispose
  void dispose() {

  }
}


