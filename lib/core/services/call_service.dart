import 'dart:math';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class CallService {
  static const String appId = 'YOUR_AGORA_APP_ID'; // Replace with your Agora App ID

  late RtcEngine _engine;
  String? currentChannelId;
  CallState callState = CallState.idle;

  // Callback functions
  Function(String channelId, int uid)? onUserJoined;
  Function(String channelId, int uid)? onUserOffline;
  Function(String channelId, int uid, int elapsed)? onJoinChannelSuccess;

  Future<void> initialize() async {
    try {
      // Request permissions
      await <Permission>[Permission.microphone, Permission.camera].request();

      // Initialize Agora engine
      _engine = createAgoraRtcEngine();
      await _engine.initialize(const RtcEngineContext(
        appId: appId,
        channelProfile: ChannelProfileType.channelProfileCommunication,
      ),);

      // Register event handlers - 🟢 Fixed null safety
      _engine.registerEventHandler(
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
            debugPrint('Agora error: $error - $errorDescription');
            callState = CallState.error;
          },
        ),
      );

      debugPrint('✅ CallService initialized');
    } catch (e) {
      debugPrint('❌ Error initializing CallService: $e');
      rethrow;
    }
  }

  // Start a call
  Future<String> startCall({
    required String targetUserId,
    required CallType callType,
    required String roomId,
  }) async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('User not logged in');

    try {
      // Generate unique channel ID
      currentChannelId = 'call_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1000)}';

      // Enable video if video call
      if (callType == CallType.video) {
        await _engine.enableVideo();
        await _engine.startPreview();
      }

      // Join channel - 🟢 Fixed null safety
      final ChannelMediaOptions options = ChannelMediaOptions(
        channelProfile: ChannelProfileType.channelProfileCommunication,
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
        publishCameraTrack: callType == CallType.video,
        publishMicrophoneTrack: true,
        autoSubscribeAudio: true,
        autoSubscribeVideo: true,
      );

      await _engine.joinChannel(
        token: '', // Generate token from your server
        channelId: currentChannelId!,
        uid: 0,
        options: options,
      );

      callState = CallState.connecting;

      // Save call record to Firestore
      await _saveCallRecord(
        targetUserId: targetUserId,
        callType: callType,
        channelId: currentChannelId!,
        roomId: roomId,
      );

      return currentChannelId!;
    } catch (e) {
      debugPrint('Error starting call: $e');
      throw Exception('Failed to start call');
    }
  }

  // Join a call
  Future<void> joinCall(String channelId) async {
    try {
      currentChannelId = channelId;

      const ChannelMediaOptions options = ChannelMediaOptions(
        channelProfile: ChannelProfileType.channelProfileCommunication,
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
        publishCameraTrack: false,
        publishMicrophoneTrack: true,
        autoSubscribeAudio: true,
        autoSubscribeVideo: true,
      );

      await _engine.joinChannel(
        token: '',
        channelId: channelId,
        uid: 0,
        options: options,
      );

      callState = CallState.connecting;
    } catch (e) {
      debugPrint('Error joining call: $e');
      throw Exception('Failed to join call');
    }
  }

  // End call
  Future<void> endCall() async {
    try {
      await _engine.leaveChannel();
      callState = CallState.ended;

      if (currentChannelId != null) {
        await _updateCallRecord(currentChannelId!);
      }
      currentChannelId = null;
    } catch (e) {
      debugPrint('Error ending call: $e');
    }
  }

  // Toggle microphone
  Future<void> toggleMic(bool mute) async {
    await _engine.muteLocalAudioStream(mute);
  }

  // Toggle camera
  Future<void> toggleCamera(bool enable) async {
    await _engine.enableLocalVideo(enable);
    await _engine.muteLocalVideoStream(!enable);
  }

  // Switch camera
  Future<void> switchCamera() async {
    await _engine.switchCamera();
  }

  // Set speakerphone
  Future<void> setSpeakerphone(bool enable) async {
    await _engine.setEnableSpeakerphone(enable);
  }

  // Save call record to Firestore - 🟢 Fixed null safety
  Future<void> _saveCallRecord({
    required String targetUserId,
    required CallType callType,
    required String channelId,
    required String roomId,
  }) async {
    final User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final Map<String, Object?> callData = <String, Object?>{
      'callId': channelId,
      'callerId': currentUser.uid,
      'callerName': currentUser.displayName ?? 'Unknown',
      'callerAvatar': currentUser.photoURL ?? '',
      'receiverId': targetUserId,
      'callType': callType.toString().split('.').last,
      'channelId': channelId,
      'roomId': roomId,
      'startTime': FieldValue.serverTimestamp(),
      'endTime': null,
      'status': 'ongoing',
    };

    await FirebaseFirestore.instance.collection('calls').add(callData);
  }

  // Update call record - 🟢 Fixed null safety
  Future<void> _updateCallRecord(String channelId) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> query = await FirebaseFirestore.instance
          .collection('calls')
          .where('channelId', isEqualTo: channelId)
          .where('status', isEqualTo: 'ongoing')
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        await query.docs.first.reference.update(<Object, Object?>{
          'endTime': FieldValue.serverTimestamp(),
          'status': 'ended',
        });
      }
    } catch (e) {
      debugPrint('Error updating call record: $e');
    }
  }

  // Get call history - 🟢 Fixed null safety
  Stream<List<CallRecord>> getCallHistory() {
    final User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return const Stream.empty();

    return FirebaseFirestore.instance
        .collection('calls')
        .where('callerId', isEqualTo: currentUser.uid)
        .orderBy('startTime', descending: true)
        .limit(50)
        .snapshots()
        .map((QuerySnapshot<Map<String, dynamic>> snapshot) => snapshot.docs
        .map((QueryDocumentSnapshot<Map<String, dynamic>> doc) => CallRecord.fromJson(doc.data()))
        .toList(),);
  }

  // Dispose method
  Future<void> dispose() async {
    debugPrint('🗑️ Disposing CallService...');
    try {
      if (callState == CallState.connected || callState == CallState.connecting) {
        await endCall();
      }
      _engine.release();
      debugPrint('✅ CallService disposed successfully');
    } catch (e) {
      debugPrint('❌ Error disposing CallService: $e');
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

  CallRecord({
    required this.callId,
    required this.callerId,
    required this.callerName,
    this.callerAvatar,
    required this.receiverId,
    required this.callType,
    required this.channelId,
    required this.roomId,
    required this.startTime,
    this.endTime,
    required this.status,
  });

  factory CallRecord.fromJson(Map<String, dynamic> json) {
    // Parse callType safely
    CallType callType = CallType.audio;
    final typeStr = json['callType'] as String? ?? '';
    if (typeStr.toLowerCase() == 'video') {
      callType = CallType.video;
    }

    // Parse timestamp safely
    DateTime startTime = DateTime.now();
    if (json['startTime'] != null && json['startTime'] is Timestamp) {
      startTime = (json['startTime'] as Timestamp).toDate();
    }

    DateTime? endTime;
    if (json['endTime'] != null && json['endTime'] is Timestamp) {
      endTime = (json['endTime'] as Timestamp).toDate();
    }

    return CallRecord(
      callId: json['callId'] as String? ?? '',
      callerId: json['callerId'] as String? ?? '',
      callerName: json['callerName'] as String? ?? 'Unknown',
      callerAvatar: json['callerAvatar'] as String?,
      receiverId: json['receiverId'] as String? ?? '',
      callType: callType,
      channelId: json['channelId'] as String? ?? '',
      roomId: json['roomId'] as String? ?? '',
      startTime: startTime,
      endTime: endTime,
      status: json['status'] as String? ?? '',
    );
  }
  final String callId;
  final String callerId;
  final String callerName;
  final String? callerAvatar;
  final String receiverId;
  final CallType callType;
  final String channelId;
  final String roomId;
  final DateTime startTime;
  final DateTime? endTime;
  final String status;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'callId': callId,
      'callerId': callerId,
      'callerName': callerName,
      'callerAvatar': callerAvatar ?? '',
      'receiverId': receiverId,
      'callType': callType.toString().split('.').last,
      'channelId': channelId,
      'roomId': roomId,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': endTime != null ? Timestamp.fromDate(endTime!) : null,
      'status': status,
    };
  }
}