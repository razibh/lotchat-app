class CallSettings {

  CallSettings({
    this.enableBeautyFilter = false,
    this.enableVoiceChanger = false,
    this.beautyLevel = 50,
    this.selectedVoice = 'normal',
    this.enableNoiseCancellation = true,
    this.enableEchoCancellation = true,
    this.autoAnswer = false,
    this.maxCallDuration = 3600,
    this.recordCalls = false,
    this.pictureInPicture = true,
    this.videoQuality = VideoQuality.hd,
  });

  factory CallSettings.fromJson(Map<String, dynamic> json) {
    return CallSettings(
      enableBeautyFilter: json['enableBeautyFilter'] ?? false,
      enableVoiceChanger: json['enableVoiceChanger'] ?? false,
      beautyLevel: json['beautyLevel'] ?? 50,
      selectedVoice: json['selectedVoice'] ?? 'normal',
      enableNoiseCancellation: json['enableNoiseCancellation'] ?? true,
      enableEchoCancellation: json['enableEchoCancellation'] ?? true,
      autoAnswer: json['autoAnswer'] ?? false,
      maxCallDuration: json['maxCallDuration'] ?? 3600,
      recordCalls: json['recordCalls'] ?? false,
      pictureInPicture: json['pictureInPicture'] ?? true,
      videoQuality: VideoQuality.values[json['videoQuality'] ?? 1],
    );
  }
  bool enableBeautyFilter;
  bool enableVoiceChanger;
  int beautyLevel; // 0-100
  String selectedVoice;
  bool enableNoiseCancellation;
  bool enableEchoCancellation;
  bool autoAnswer;
  int maxCallDuration;
  bool recordCalls;
  bool pictureInPicture;
  VideoQuality videoQuality;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'enableBeautyFilter': enableBeautyFilter,
    'enableVoiceChanger': enableVoiceChanger,
    'beautyLevel': beautyLevel,
    'selectedVoice': selectedVoice,
    'enableNoiseCancellation': enableNoiseCancellation,
    'enableEchoCancellation': enableEchoCancellation,
    'autoAnswer': autoAnswer,
    'maxCallDuration': maxCallDuration,
    'recordCalls': recordCalls,
    'pictureInPicture': pictureInPicture,
    'videoQuality': videoQuality.index,
  };
}

enum VideoQuality {
  low,    // 360p
  medium, // 480p
  hd,     // 720p
  fullHd, // 1080p
}