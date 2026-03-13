enum CallType { audio, video }
enum CallStatus { ringing, connected, ended, missed }
enum CallDirection { incoming, outgoing }

class CallModel {

  CallModel({
    required this.id,
    required this.callerId,
    required this.callerName,
    this.callerAvatar,
    required this.receiverId,
    required this.receiverName,
    this.receiverAvatar,
    required this.type,
    required this.direction,
    required this.status,
    required this.startTime,
    this.endTime,
    required this.duration,
    this.channelId,
    required this.isVideoEnabled,
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
      type: CallType.values[json['type']],
      direction: CallDirection.values[json['direction']],
      status: CallStatus.values[json['status']],
      startTime: DateTime.parse(json['startTime']),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
      duration: json['duration'],
      channelId: json['channelId'],
      isVideoEnabled: json['isVideoEnabled'],
    );
  }
  final String id;
  final String callerId;
  final String callerName;
  final String? callerAvatar;
  final String receiverId;
  final String receiverName;
  final String? receiverAvatar;
  final CallType type;
  final CallDirection direction;
  final CallStatus status;
  final DateTime startTime;
  final DateTime? endTime;
  final int duration; // in seconds
  final String? channelId;
  final bool isVideoEnabled;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'callerId': callerId,
    'callerName': callerName,
    'callerAvatar': callerAvatar,
    'receiverId': receiverId,
    'receiverName': receiverName,
    'receiverAvatar': receiverAvatar,
    'type': type.index,
    'direction': direction.index,
    'status': status.index,
    'startTime': startTime.toIso8601String(),
    'endTime': endTime?.toIso8601String(),
    'duration': duration,
    'channelId': channelId,
    'isVideoEnabled': isVideoEnabled,
  };
}