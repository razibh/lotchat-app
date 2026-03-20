import 'dart:convert';
import 'dart:developer';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';

// Conditional import for web support
import 'agora_web_check_mobile.dart' 
    if (dart.library.js_interop) 'agora_web_checker_web.dart' as web_check;

class AgoraService {
  static final AgoraService _instance = AgoraService._internal();
  factory AgoraService() => _instance;
  AgoraService._internal();

  static const String appId = 'cc371f6507f24f6480d631b7f3a7f1c9';

  // Token Server URL
  static const String tokenServerUrl = 'https://your-token-server.com';

  RtcEngine? _engine;
  String? _currentChannel;
  int? _localUid;
  String? _currentToken;
  DateTime? _tokenExpiry;
  bool _isWebInitialized = false;

  // Get engine (for external use)
  RtcEngine? get engine => _engine;

  // Callbacks
  Function(int uid)? onUserJoined;
  Function(int uid)? onUserOffline;
  Function()? onJoinChannelSuccess;
  Function(String channelId)? onTokenWillExpire;

  /// Initialize Agora Engine with Web Support
  Future<bool> initialize() async {
    try {
      if (kIsWeb) {
        log(' Running on Web - Checking Agora Web SDK...');

        if (web_check.isAgoraRTCDefined()) {
          _isWebInitialized = true;
          log(' Agora Web SDK ready');
          return true;
        } else {
          log(' Agora Web SDK not loaded. Please check index.html');
          return false;
        }
      }

      // Mobile platform
      await _requestPermissions();

      // Create engine instance
      _engine = createAgoraRtcEngine();

      // Initialize engine
      await _engine!.initialize(const RtcEngineContext(
        appId: appId,
        channelProfile: ChannelProfileType.channelProfileCommunication,
      ));

      // Register event handlers
      _engine!.registerEventHandler(
        RtcEngineEventHandler(
          onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
            _localUid = connection.localUid;
            log(' Joined channel: ${connection.channelId} as UID: $connection.localUid');
            onJoinChannelSuccess?.call();
          },

          onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
            log(' Remote user joined: $remoteUid');
            onUserJoined?.call(remoteUid);
          },

          onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
            log(' Remote user left: $remoteUid');
            onUserOffline?.call(remoteUid);
          },

          onTokenPrivilegeWillExpire: (RtcConnection connection, String? token) {
            log('⚠ Token will expire soon, renewing...');
            _renewToken(connection.channelId ?? _currentChannel ?? '');
          },

          onRequestToken: (RtcConnection connection) {
            log(' Token expired, requesting new token...');
            _renewToken(connection.channelId ?? _currentChannel ?? '');
          },

          onError: (ErrorCodeType err, String msg) {
            log(' Agora error: $err - $msg');
          },
        ),
      );

      log(' Agora Service initialized on mobile');
      return true;
    } catch (e) {
      log(' Failed to initialize Agora: $e');
      return false;
    }
  }

  /// Request camera and microphone permissions
  Future<void> _requestPermissions() async {
    if (!kIsWeb) {
      await [
        Permission.camera,
        Permission.microphone,
      ].request();
    }
  }

  /// Get token from server
  Future<String?> _getTokenFromServer(String channelName, {int? uid}) async {
    try {
      final response = await http.post(
        Uri.parse('$tokenServerUrl/api/agora/token'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'channelName': channelName,
          'uid': uid ?? 0,
          'role': 'publisher',
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _currentToken = data['token'];
        _tokenExpiry = DateTime.now().add(const Duration(seconds: 3500));
        log(' Token received. Expires: $_tokenExpiry');
        return _currentToken;
      } else {
        log(' Server error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      log(' Token server connection error: $e');

      // Fallback to empty token for development (24 hour validity)
      log('⚠ Using empty token (development mode)');
      return '';
    }
  }

  /// Renew token when it's about to expire
  Future<void> _renewToken(String channelName) async {
    if (_engine == null) return;

    final newToken = await _getTokenFromServer(channelName, uid: _localUid);
    if (newToken != null && newToken.isNotEmpty) {
      await _engine!.renewToken(newToken);
      log(' Token renewed successfully');
    }
  }

  /// Join a channel
  Future<bool> joinChannel(String channelName, {int uid = 0}) async {
    if (kIsWeb) {
      if (!_isWebInitialized) {
        log(' Agora Web not initialized');
        return false;
      }
      log(' Web: Joining channel $channelName');
      return true;
    }

    if (_engine == null) return false;

    try {
      final token = await _getTokenFromServer(channelName, uid: uid);

      const ChannelMediaOptions options = ChannelMediaOptions(
        channelProfile: ChannelProfileType.channelProfileCommunication,
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
        publishCameraTrack: true,
        publishMicrophoneTrack: true,
        autoSubscribeAudio: true,
        autoSubscribeVideo: true,
      );

      await _engine!.joinChannel(
        token: token ?? '',
        channelId: channelName,
        uid: uid,
        options: options,
      );

      _currentChannel = channelName;
      return true;
    } catch (e) {
      log('Failed to join channel: $e');
      return false;
    }
  }

  /// Join as audience (subscriber only)
  Future<bool> joinAsAudience(String channelName, {int uid = 0}) async {
    if (kIsWeb) {
      log(' Web: Joining as audience');
      return true;
    }

    if (_engine == null) return false;

    try {
      final token = await _getTokenFromServer(channelName, uid: uid);

      const ChannelMediaOptions options = ChannelMediaOptions(
        channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
        clientRoleType: ClientRoleType.clientRoleAudience,
        publishCameraTrack: false,
        publishMicrophoneTrack: false,
        autoSubscribeAudio: true,
        autoSubscribeVideo: true,
      );

      await _engine!.joinChannel(
        token: token ?? '',
        channelId: channelName,
        uid: uid,
        options: options,
      );

      _currentChannel = channelName;
      return true;
    } catch (e) {
      log('Failed to join as audience: $e');
      return false;
    }
  }

  /// Leave current channel
  Future<void> leaveChannel() async {
    if (kIsWeb) {
      log(' Web: Leaving channel');
      return;
    }

    if (_engine == null) return;

    await _engine!.leaveChannel();
    _currentChannel = null;
    _currentToken = null;
  }

  /// Toggle microphone
  Future<void> toggleMic(bool mute) async {
    if (kIsWeb) {
      log(' Web: Toggle mic: $mute');
      return;
    }
    if (_engine == null) return;
    await _engine!.muteLocalAudioStream(mute);
  }

  /// Toggle camera
  Future<void> toggleCamera(bool enable) async {
    if (kIsWeb) {
      log(' Web: Toggle camera: $enable');
      return;
    }
    if (_engine == null) return;
    await _engine!.enableLocalVideo(enable);
    await _engine!.muteLocalVideoStream(!enable);
  }

  /// Switch camera (front/back)
  Future<void> switchCamera() async {
    if (kIsWeb) {
      log(' Web: Switch camera');
      return;
    }
    if (_engine == null) return;
    await _engine!.switchCamera();
  }

  /// Setup local video renderer
  Widget setupLocalVideo() {
    if (kIsWeb) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: Text(
            'Web Video',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    if (_engine == null) return const SizedBox();

    return AgoraVideoView(
      controller: VideoViewController(
        rtcEngine: _engine!,
        canvas: const VideoCanvas(uid: 0),
      ),
    );
  }

  /// Setup remote video renderer
  Widget setupRemoteVideo(int uid) {
    if (kIsWeb) {
      return Container(
        color: Colors.grey.shade900,
        child: Center(
          child: Text(
            'Remote User $uid',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    if (_engine == null) return const SizedBox();

    return AgoraVideoView(
      controller: VideoViewController(
        rtcEngine: _engine!,
        canvas: VideoCanvas(uid: uid),
      ),
    );
  }

  /// Check if token is valid
  bool get isTokenValid {
    if (_tokenExpiry == null) return false;
    return DateTime.now().isBefore(_tokenExpiry!);
  }

  /// Dispose engine
  Future<void> dispose() async {
    await leaveChannel();
    if (!kIsWeb && _engine != null) {
      await _engine?.release();
      _engine = null;
    }
    log(' AgoraService disposed');
  }
}
