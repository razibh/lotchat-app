import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
    await <>[Permission.microphone, Permission.camera].request();
    
    _engine = createAgoraRtcEngine();
    await _engine.initialize(RtcEngineContext(appId: appId));
    
    _engine.registerEventHandler(RtcEngineEventHandler(
      onJoinChannelSuccess: (connection, elapsed) {
        callState = CallState.connected;
        onJoinChannelSuccess?.call(connection.channelId, connection.localUid, elapsed);
      },
      onUserJoined: (connection, remoteUid, elapsed) {
        onUserJoined?.call(connection.channelId, remoteUid);
      },
      onUserOffline: (connection, remoteUid, reason) {
        onUserOffline?.call(connection.channelId, remoteUid);
      },
      onLeaveChannel: (connection, stats) {
        callState = CallState.ended;
      },
      onError: (error) {
        print('Agora error: $error');
        callState = CallState.error;
      },
    ));
  }

  // Start a call
  Future<String> startCall({
    required String targetUserId,
    required CallType callType,
    required String roomId,
  }) async {
    try {
      // Generate unique channel ID
      currentChannelId = 'call_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1000)}';
      
      // Enable video if video call
      if (callType == CallType.video) {
        await _engine.enableVideo();
        await _engine.startPreview();
      }
      
      // Join channel
      await _engine.joinChannel(
        token: '', // Generate token from your server
        channelId: currentChannelId!,
        uid: 0,
        options: ChannelMediaOptions(
          channelProfile: ChannelProfileType.channelProfileCommunication,
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
        ),
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
      print('Error starting call: $e');
      throw Exception('Failed to start call');
    }
  }

  // Join a call
  Future<void> joinCall(String channelId) async {
    try {
      currentChannelId = channelId;
      
      await _engine.joinChannel(
        token: '',
        channelId: channelId,
        uid: 0,
        options: ChannelMediaOptions(
          channelProfile: ChannelProfileType.channelProfileCommunication,
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
        ),
      );
      
      callState = CallState.connecting;
    } catch (e) {
      print('Error joining call: $e');
      throw Exception('Failed to join call');
    }
  }

  // End call
  Future<void> endCall() async {
    try {
      await _engine.leaveChannel();
      callState = CallState.ended;
      currentChannelId = null;
      
      // Update call record
      if (currentChannelId != null) {
        await _updateCallRecord(currentChannelId!);
      }
    } catch (e) {
      print('Error ending call: $e');
    }
  }

  // Toggle microphone
  Future<void> toggleMic(bool mute) async {
    await _engine.muteLocalAudioStream(mute);
  }

  // Toggle camera
  Future<void> toggleCamera(bool enable) async {
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

  // Save call record to Firestore
  Future<void> _saveCallRecord({
    required String targetUserId,
    required CallType callType,
    required String channelId,
    required String roomId,
  }) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;
    
    await FirebaseFirestore.instance.collection('calls').add(<String, >{
      'callId': channelId,
      'callerId': currentUser.uid,
      'callerName': currentUser.displayName,
      'callerAvatar': currentUser.photoURL,
      'receiverId': targetUserId,
      'callType': callType.toString(),
      'channelId': channelId,
      'roomId': roomId,
      'startTime': FieldValue.serverTimestamp(),
      'endTime': null,
      'status': 'ongoing',
    });
  }

  // Update call record
  Future<void> _updateCallRecord(String channelId) async {
    final query = await FirebaseFirestore.instance
        .collection('calls')
        .where('channelId', isEqualTo: channelId)
        .where('status', isEqualTo: 'ongoing')
        .limit(1)
        .get();
    
    if (query.docs.isNotEmpty) {
      await query.docs.first.reference.update(<String, >{
        'endTime': FieldValue.serverTimestamp(),
        'status': 'ended',
      });
    }
  }

  // Get call history
  Stream<List<CallRecord>> getCallHistory() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return const Stream.empty();
    
    return FirebaseFirestore.instance
        .collection('calls')
        .where('callerId', isEqualTo: currentUser.uid)
        .orderBy('startTime', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CallRecord.fromJson(doc.data()))
            .toList());
  }

  // Dispose
  void dispose() {
    _engine.release();
  }
}

// ==================== MODEL CLASSES ====================

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
    return CallRecord(
      callId: json['callId'] ?? '',
      callerId: json['callerId'] ?? '',
      callerName: json['callerName'] ?? 'Unknown',
      callerAvatar: json['callerAvatar'],
      receiverId: json['receiverId'] ?? '',
      callType: json['callType'] == 'CallType.audio' ? CallType.audio : CallType.video,
      channelId: json['channelId'] ?? '',
      roomId: json['roomId'] ?? '',
      startTime: (json['startTime'] as Timestamp).toDate(),
      endTime: json['endTime'] != null ? (json['endTime'] as Timestamp).toDate() : null,
      status: json['status'] ?? '',
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
}