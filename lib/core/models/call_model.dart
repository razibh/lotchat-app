enum CallType { audio, video }
enum CallStatus { ringing, connected, ended, missed, declined }
enum CallDirection { outgoing, incoming }

class CallModel {

  CallModel({
    required this.id,
    required this.callerId,
    required this.callerName,
    this.callerAvatar,
    required this.receiverId,
    required this.receiverName,
    this.receiverAvatar,
    required this.callType,
    required this.direction,
    required this.status,
    required this.startTime,
    this.endTime,
    required this.duration,
    this.roomId,
    this.isGroupCall = false,
    this.participants = const [],
    this.metadata,
  });

  factory CallModel.fromJson(Map<String, dynamic> json) {
    return CallModel(
      id: json['id'],
      callerId: json['callerId'],
      callerName: json['callerName'],
      callerAvatar: json['callerAvatar'],
      receiverId: json['receiverId'],
      receiverName: json['receiverName'],
      receiverAvatar: json['receiverAvatar'],
      callType: CallType.values[json['callType']],
      direction: CallDirection.values[json['direction']],
      status: CallStatus.values[json['status']],
      startTime: DateTime.parse(json['startTime']),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
      duration: json['duration'],
      roomId: json['roomId'],
      isGroupCall: json['isGroupCall'] ?? false,
      participants: List<String>.from(json['participants'] ?? []),
      metadata: json['metadata'],
    );
  }
  final String id;
  final String callerId;
  final String callerName;
  final String? callerAvatar;
  final String receiverId;
  final String receiverName;
  final String? receiverAvatar;
  final CallType callType;
  final CallDirection direction;
  final CallStatus status;
  final DateTime startTime;
  final DateTime? endTime;
  final int duration; // in seconds
  final String? roomId;
  final bool isGroupCall;
  final List<String> participants;
  final Map<String, dynamic>? metadata;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'callerId': callerId,
    'callerName': callerName,
    'callerAvatar': callerAvatar,
    'receiverId': receiverId,
    'receiverName': receiverName,
    'receiverAvatar': receiverAvatar,
    'callType': callType.index,
    'direction': direction.index,
    'status': status.index,
    'startTime': startTime.toIso8601String(),
    'endTime': endTime?.toIso8601String(),
    'duration': duration,
    'roomId': roomId,
    'isGroupCall': isGroupCall,
    'participants': participants,
    'metadata': metadata,
  };
}

class CallLog {

  CallLog({
    required this.id,
    required this.userId,
    required this.contactId,
    required this.contactName,
    this.contactAvatar,
    required this.callType,
    required this.direction,
    required this.status,
    required this.timestamp,
    required this.duration,
  });

  factory CallLog.fromJson(Map<String, dynamic> json) {
    return CallLog(
      id: json['id'],
      userId: json['userId'],
      contactId: json['contactId'],
      contactName: json['contactName'],
      contactAvatar: json['contactAvatar'],
      callType: CallType.values[json['callType']],
      direction: CallDirection.values[json['direction']],
      status: CallStatus.values[json['status']],
      timestamp: DateTime.parse(json['timestamp']),
      duration: json['duration'],
    );
  }
  final String id;
  final String userId;
  final String contactId;
  final String contactName;
  final String? contactAvatar;
  final CallType callType;
  final CallDirection direction;
  final CallStatus status;
  final DateTime timestamp;
  final int duration;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'userId': userId,
    'contactId': contactId,
    'contactName': contactName,
    'contactAvatar': contactAvatar,
    'callType': callType.index,
    'direction': direction.index,
    'status': status.index,
    'timestamp': timestamp.toIso8601String(),
    'duration': duration,
  };
}

class CallSettings {

  CallSettings({
    this.enableVideo = true,
    this.enableAudio = true,
    this.enableSpeaker = false,
    this.enableFrontCamera = true,
    this.enableBeautyFilter = false,
    this.beautyLevel = 0.5,
    this.enableNoiseSuppression = true,
    this.enableEchoCancellation = true,
    this.enableAutoGainControl = true,
    this.videoQuality = 'hd',
    this.maxBitrate = 1000,
    this.maxFrameRate = 30,
  });

  factory CallSettings.fromJson(Map<String, dynamic> json) {
    return CallSettings(
      enableVideo: json['enableVideo'] ?? true,
      enableAudio: json['enableAudio'] ?? true,
      enableSpeaker: json['enableSpeaker'] ?? false,
      enableFrontCamera: json['enableFrontCamera'] ?? true,
      enableBeautyFilter: json['enableBeautyFilter'] ?? false,
      beautyLevel: json['beautyLevel'] ?? 0.5,
      enableNoiseSuppression: json['enableNoiseSuppression'] ?? true,
      enableEchoCancellation: json['enableEchoCancellation'] ?? true,
      enableAutoGainControl: json['enableAutoGainControl'] ?? true,
      videoQuality: json['videoQuality'] ?? 'hd',
      maxBitrate: json['maxBitrate'] ?? 1000,
      maxFrameRate: json['maxFrameRate'] ?? 30,
    );
  }
  final bool enableVideo;
  final bool enableAudio;
  final bool enableSpeaker;
  final bool enableFrontCamera;
  final bool enableBeautyFilter;
  final double beautyLevel;
  final bool enableNoiseSuppression;
  final bool enableEchoCancellation;
  final bool enableAutoGainControl;
  final String videoQuality; // 'low', 'medium', 'high', 'hd'
  final int maxBitrate;
  final int maxFrameRate;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'enableVideo': enableVideo,
    'enableAudio': enableAudio,
    'enableSpeaker': enableSpeaker,
    'enableFrontCamera': enableFrontCamera,
    'enableBeautyFilter': enableBeautyFilter,
    'beautyLevel': beautyLevel,
    'enableNoiseSuppression': enableNoiseSuppression,
    'enableEchoCancellation': enableEchoCancellation,
    'enableAutoGainControl': enableAutoGainControl,
    'videoQuality': videoQuality,
    'maxBitrate': maxBitrate,
    'maxFrameRate': maxFrameRate,
  };
}