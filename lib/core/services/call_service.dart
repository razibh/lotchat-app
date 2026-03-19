import 'dart:math';
import 'dart:developer' as developer;
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode; // ⚡ FIX: Add kDebugMode
import 'package:supabase_flutter/supabase_flutter.dart';
import '../di/service_locator.dart';

class CallService {
  static const String appId = 'cc371f6507f24f6480d631b7f3a7f1c9';

  late final SupabaseClient _supabase;
  RtcEngine? _engine; // Make nullable for web
  String? currentChannelId;
  CallState callState = CallState.idle;

  // Callback functions
  Function(String channelId, int uid)? onUserJoined;
  Function(String channelId, int uid)? onUserOffline;
  Function(String channelId, int uid, int elapsed)? onJoinChannelSuccess;

  // Call listeners for real-time updates
  RealtimeChannel? _callChannel;

  Future<void> initialize() async {
    try {
      _supabase = getService<SupabaseClient>();

      // Skip permission request on web
      if (!kIsWeb) {
        await <Permission>[Permission.microphone, Permission.camera].request();
      }

      // Only initialize Agora on non-web platforms
      if (!kIsWeb) {
        _engine = createAgoraRtcEngine();
        await _engine!.initialize(const RtcEngineContext(
          appId: appId,
          channelProfile: ChannelProfileType.channelProfileCommunication,
        ));

        _engine!.registerEventHandler(
          RtcEngineEventHandler(
            onJoinChannelSuccess: (connection, elapsed) {
              callState = CallState.connected;
              onJoinChannelSuccess?.call(connection.channelId ?? '', connection.localUid ?? 0, elapsed);
            },
            onUserJoined: (connection, remoteUid, elapsed) {
              onUserJoined?.call(connection.channelId ?? '', remoteUid);
            },
            onUserOffline: (connection, remoteUid, reason) {
              onUserOffline?.call(connection.channelId ?? '', remoteUid);
            },
            onLeaveChannel: (connection, stats) {
              callState = CallState.ended;
            },
            onError: (error, errorDescription) {
              _debugPrint('Agora error: $error - $errorDescription');
              callState = CallState.error;
            },
          ),
        );
        _debugPrint(' Agora engine initialized on mobile');
      } else {
        _debugPrint(' Web platform - using webRTC simulation');
      }

      _debugPrint(' CallService initialized with Supabase');
    } catch (e) {
      _debugPrint(' Error initializing CallService: $e');
      // Don't rethrow - allow app to continue without calls
    }
  }

  // Custom debugPrint method
  void _debugPrint(String message) {
    developer.log(message);
    if (kDebugMode) { // ⚡ FIX: Now kDebugMode is defined
      // ignore: avoid_print
      print(message);
    }
  }

  // Start a call
  Future<String> startCall({
    required String targetUserId,
    required CallType callType,
    required String roomId,
  }) async {
    final session = _supabase.auth.currentSession;
    if (session == null) throw Exception('User not logged in');

    final currentUser = session.user;

    try {
      currentChannelId = 'call_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1000)}';

      // Check if on mobile and engine exists
      if (!kIsWeb && _engine != null && callType == CallType.video) {
        await _engine!.enableVideo();
        await _engine!.startPreview();
      }

      // Only use engine on mobile
      if (!kIsWeb && _engine != null) {
        final ChannelMediaOptions options = ChannelMediaOptions(
          channelProfile: ChannelProfileType.channelProfileCommunication,
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
          publishCameraTrack: callType == CallType.video,
          publishMicrophoneTrack: true,
          autoSubscribeAudio: true,
          autoSubscribeVideo: true,
        );

        await _engine!.joinChannel(
          token: '',
          channelId: currentChannelId!,
          uid: 0,
          options: options,
        );
      } else {
        _debugPrint(' Web: Simulating call start');
      }

      callState = CallState.connecting;

      await _saveCallRecord(
        targetUserId: targetUserId,
        callType: callType,
        channelId: currentChannelId!,
        roomId: roomId,
        callerId: currentUser.id,
        callerName: currentUser.userMetadata?['full_name'] ?? currentUser.email ?? 'Unknown',
        callerAvatar: currentUser.userMetadata?['avatar_url'],
      );

      return currentChannelId!;
    } catch (e) {
      _debugPrint('Error starting call: $e');
      throw Exception('Failed to start call');
    }
  }

  // Join a call
  Future<void> joinCall(String channelId) async {
    try {
      currentChannelId = channelId;

      // Only use engine on mobile
      if (!kIsWeb && _engine != null) {
        final ChannelMediaOptions options = ChannelMediaOptions(
          channelProfile: ChannelProfileType.channelProfileCommunication,
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
          publishCameraTrack: false,
          publishMicrophoneTrack: true,
          autoSubscribeAudio: true,
          autoSubscribeVideo: true,
        );

        await _engine!.joinChannel(
          token: '',
          channelId: channelId,
          uid: 0,
          options: options,
        );
      } else {
        _debugPrint('🌐 Web: Simulating call join');
      }

      callState = CallState.connecting;
    } catch (e) {
      _debugPrint('Error joining call: $e');
      throw Exception('Failed to join call');
    }
  }

  // End call
  Future<void> endCall() async {
    try {
      // Only use engine on mobile
      if (!kIsWeb && _engine != null) {
        await _engine!.leaveChannel();
      }
      callState = CallState.ended;

      if (currentChannelId != null) {
        await _updateCallRecord(currentChannelId!);
      }
      currentChannelId = null;
    } catch (e) {
      _debugPrint('Error ending call: $e');
    }
  }

  // Toggle microphone
  Future<void> toggleMic(bool mute) async {
    // Only use engine on mobile
    if (!kIsWeb && _engine != null) {
      await _engine!.muteLocalAudioStream(mute);
    } else {
      _debugPrint(' Web: Toggle mic: $mute');
    }
  }

  // Toggle camera
  Future<void> toggleCamera(bool enable) async {
    // Only use engine on mobile
    if (!kIsWeb && _engine != null) {
      await _engine!.enableLocalVideo(enable);
      await _engine!.muteLocalVideoStream(!enable);
    } else {
      _debugPrint(' Web: Toggle camera: $enable');
    }
  }

  // Switch camera
  Future<void> switchCamera() async {
    // Only use engine on mobile
    if (!kIsWeb && _engine != null) {
      await _engine!.switchCamera();
    } else {
      _debugPrint(' Web: Switch camera');
    }
  }

  // Set speakerphone
  Future<void> setSpeakerphone(bool enable) async {
    // Only use engine on mobile
    if (!kIsWeb && _engine != null) {
      await _engine!.setEnableSpeakerphone(enable);
    } else {
      _debugPrint(' Web: Set speakerphone: $enable');
    }
  }

  // ==================== DATABASE METHODS ====================

  // Save call record
  Future<void> _saveCallRecord({
    required String targetUserId,
    required CallType callType,
    required String channelId,
    required String roomId,
    required String callerId,
    required String callerName,
    String? callerAvatar,
  }) async {
    try {
      final now = DateTime.now().toIso8601String();

      final callData = {
        'call_id': channelId,
        'caller_id': callerId,
        'caller_name': callerName,
        'caller_avatar': callerAvatar,
        'receiver_id': targetUserId,
        'call_type': callType.toString().split('.').last,
        'channel_id': channelId,
        'room_id': roomId,
        'started_at': now,
        'ended_at': null,
        'status': 'ongoing',
        'participants': [callerId, targetUserId],
        'created_at': now,
      };

      await _supabase.from('calls').insert(callData);
      _debugPrint('Call record saved: $channelId');
    } catch (e) {
      _debugPrint('Error saving call record: $e');
    }
  }

  // Update call record
  Future<void> _updateCallRecord(String channelId) async {
    try {
      final now = DateTime.now().toIso8601String();

      final callRecord = await _supabase
          .from('calls')
          .select('started_at')
          .eq('channel_id', channelId)
          .eq('status', 'ongoing')
          .maybeSingle();

      int? duration;
      if (callRecord != null) {
        final startedAt = DateTime.parse(callRecord['started_at']);
        duration = DateTime.now().difference(startedAt).inSeconds;
      }

      // Separate update query
      final updateQuery = _supabase
          .from('calls')
          .update({
        'ended_at': now,
        'status': 'ended',
        'duration_seconds': duration,
        'updated_at': now,
      });

      await updateQuery
          .eq('channel_id', channelId)
          .eq('status', 'ongoing');

      _debugPrint('Call record updated: $channelId, duration: ${duration}s');
    } catch (e) {
      _debugPrint('Error updating call record: $e');
    }
  }

  // ==================== STREAM QUERIES ====================

  // Get caller history as stream
  Stream<List<CallRecord>> getCallerHistoryStream() {
    final session = _supabase.auth.currentSession;
    if (session == null) return const Stream.empty();

    try {
      final stream = _supabase
          .from('calls')
          .stream(primaryKey: ['id']);

      return stream.map((data) {
        try {
          final filteredData = data.where((call) =>
          call['caller_id'] == session!.user.id &&
              call['status'] == 'ended'
          ).toList();

          return filteredData.map((call) => CallRecord.fromJson(call)).toList();
        } catch (e) {
          _debugPrint('Error parsing caller history: $e');
          return [];
        }
      });
    } catch (e) {
      _debugPrint('Error in caller history stream: $e');
      return const Stream.empty();
    }
  }

  // Get receiver history as stream
  Stream<List<CallRecord>> getReceiverHistoryStream() {
    final session = _supabase.auth.currentSession;
    if (session == null) return const Stream.empty();

    try {
      final stream = _supabase
          .from('calls')
          .stream(primaryKey: ['id']);

      return stream.map((data) {
        try {
          final filteredData = data.where((call) =>
          call['receiver_id'] == session!.user.id &&
              call['status'] == 'ended'
          ).toList();

          return filteredData.map((call) => CallRecord.fromJson(call)).toList();
        } catch (e) {
          _debugPrint('Error parsing receiver history: $e');
          return [];
        }
      });
    } catch (e) {
      _debugPrint('Error in receiver history stream: $e');
      return const Stream.empty();
    }
  }

  // Get active calls as stream
  Stream<List<CallRecord>> getActiveCallsStream() {
    try {
      final stream = _supabase
          .from('calls')
          .stream(primaryKey: ['id']);

      return stream.map((data) {
        try {
          final filteredData = data.where((call) =>
          call['status'] == 'ongoing'
          ).toList();

          return filteredData.map((call) => CallRecord.fromJson(call)).toList();
        } catch (e) {
          _debugPrint('Error parsing active calls: $e');
          return [];
        }
      });
    } catch (e) {
      _debugPrint('Error in active calls stream: $e');
      return const Stream.empty();
    }
  }

  // Get user's calls as stream
  Stream<List<CallRecord>> getUserCallsStream(String userId) {
    try {
      final stream = _supabase
          .from('calls')
          .stream(primaryKey: ['id']);

      return stream.map((data) {
        try {
          final filteredData = data.where((call) =>
          call['caller_id'] == userId ||
              call['receiver_id'] == userId
          ).toList();

          return filteredData.map((call) => CallRecord.fromJson(call)).toList();
        } catch (e) {
          _debugPrint('Error parsing user calls: $e');
          return [];
        }
      });
    } catch (e) {
      _debugPrint('Error in user calls stream: $e');
      return const Stream.empty();
    }
  }

  // ==================== FUTURE BASED METHODS ====================

  // Get call history as future
  Future<List<CallRecord>> getCallHistory() async {
    final session = _supabase.auth.currentSession;
    if (session == null) return [];

    final userId = session.user.id;

    try {
      final response = await _supabase
          .from('calls')
          .select()
          .eq('status', 'ended')
          .or('caller_id.eq.$userId,receiver_id.eq.$userId')
          .order('started_at', ascending: false)
          .limit(50);

      return response.map((call) => CallRecord.fromJson(call)).toList();
    } catch (e) {
      _debugPrint('Error getting call history: $e');
      return [];
    }
  }

  // Get active calls as future
  Future<List<CallRecord>> getActiveCalls() async {
    try {
      final response = await _supabase
          .from('calls')
          .select()
          .eq('status', 'ongoing')
          .order('started_at', ascending: false);

      return response.map((call) => CallRecord.fromJson(call)).toList();
    } catch (e) {
      _debugPrint('Error getting active calls: $e');
      return [];
    }
  }

  // Check if user is in a call
  Future<bool> isUserInCall(String userId) async {
    try {
      final response = await _supabase
          .from('calls')
          .select('id')
          .eq('status', 'ongoing')
          .or('caller_id.eq.$userId,receiver_id.eq.$userId')
          .maybeSingle();

      return response != null;
    } catch (e) {
      _debugPrint('Error checking user in call: $e');
      return false;
    }
  }

  // Rate call
  Future<void> rateCall(String channelId, int rating, {String? feedback}) async {
    try {
      // Separate update query
      final updateQuery = _supabase
          .from('calls')
          .update({
        'rating': rating,
        'feedback': feedback,
        'rated_at': DateTime.now().toIso8601String(),
      });

      await updateQuery.eq('channel_id', channelId);

      _debugPrint('Call rated: $channelId, rating: $rating');
    } catch (e) {
      _debugPrint('Error rating call: $e');
    }
  }

  // Get ongoing call for user
  Future<CallRecord?> getOngoingCall(String userId) async {
    try {
      final response = await _supabase
          .from('calls')
          .select()
          .eq('status', 'ongoing')
          .or('caller_id.eq.$userId,receiver_id.eq.$userId')
          .maybeSingle();

      return response != null ? CallRecord.fromJson(response) : null;
    } catch (e) {
      _debugPrint('Error getting ongoing call: $e');
      return null;
    }
  }

  // Dispose method
  Future<void> dispose() async {
    _debugPrint(' Disposing CallService...');
    try {
      if (callState == CallState.connected || callState == CallState.connecting) {
        await endCall();
      }
      // Only release on mobile
      if (!kIsWeb && _engine != null) {
        _engine!.release();
      }
      _debugPrint('✅ CallService disposed successfully');
    } catch (e) {
      _debugPrint('❌ Error disposing CallService: $e');
    }
  }
}

// ==================== ENUMS ====================

enum CallType {
  audio,
  video
}

enum CallState {
  idle,
  connecting,
  connected,
  ended,
  error
}

// ==================== MODEL CLASS ====================

class CallRecord {
  final String id;
  final String callId;
  final String callerId;
  final String callerName;
  final String? callerAvatar;
  final String receiverId;
  final CallType callType;
  final String channelId;
  final String roomId;
  final DateTime startedAt;
  final DateTime? endedAt;
  final String status;
  final int? durationSeconds;
  final List<String> participants;
  final int? rating;
  final String? feedback;
  final DateTime createdAt;
  final DateTime? updatedAt;

  CallRecord({
    required this.id,
    required this.callId,
    required this.callerId,
    required this.callerName,
    this.callerAvatar,
    required this.receiverId,
    required this.callType,
    required this.channelId,
    required this.roomId,
    required this.startedAt,
    this.endedAt,
    required this.status,
    this.durationSeconds,
    required this.participants,
    this.rating,
    this.feedback,
    required this.createdAt,
    this.updatedAt,
  });

  factory CallRecord.fromJson(Map<String, dynamic> json) {
    CallType callType = CallType.audio;
    final typeStr = json['call_type'] as String? ?? '';
    if (typeStr.toLowerCase() == 'video') {
      callType = CallType.video;
    }

    DateTime parseDate(String? dateStr) {
      if (dateStr == null) return DateTime.now();
      return DateTime.parse(dateStr);
    }

    return CallRecord(
      id: json['id']?.toString() ?? '',
      callId: json['call_id']?.toString() ?? json['channel_id']?.toString() ?? '',
      callerId: json['caller_id']?.toString() ?? '',
      callerName: json['caller_name']?.toString() ?? 'Unknown',
      callerAvatar: json['caller_avatar']?.toString(),
      receiverId: json['receiver_id']?.toString() ?? '',
      callType: callType,
      channelId: json['channel_id']?.toString() ?? '',
      roomId: json['room_id']?.toString() ?? '',
      startedAt: parseDate(json['started_at']),
      endedAt: json['ended_at'] != null ? parseDate(json['ended_at']) : null,
      status: json['status']?.toString() ?? '',
      durationSeconds: json['duration_seconds'] != null
          ? (json['duration_seconds'] as num).toInt()
          : null,
      participants: List<String>.from(json['participants'] ?? []),
      rating: json['rating'] != null ? (json['rating'] as num).toInt() : null,
      feedback: json['feedback']?.toString(),
      createdAt: parseDate(json['created_at']),
      updatedAt: json['updated_at'] != null ? parseDate(json['updated_at']) : null,
    );
  }

  Duration? get duration {
    if (endedAt == null) return null;
    return endedAt!.difference(startedAt);
  }

  String get formattedDuration {
    if (duration == null) return 'Ongoing';
    final d = duration!;
    if (d.inHours > 0) {
      return '${d.inHours}h ${d.inMinutes.remainder(60)}m';
    } else if (d.inMinutes > 0) {
      return '${d.inMinutes}m ${d.inSeconds.remainder(60)}s';
    } else {
      return '${d.inSeconds}s';
    }
  }

  bool get isActive => status == 'ongoing';
  bool get isEnded => status == 'ended';
  bool get isRated => rating != null;
}