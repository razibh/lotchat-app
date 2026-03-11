class EffectModel {
  String id;
  String name;
  EffectType type;              // entry, gift, room
  String animationPath;         // assets/effects/vip_entry.json
  String soundPath;             // assets/sounds/vip_entry.mp3
  int duration;                 // in seconds
  bool isFullscreen;
  Map<String, dynamic> particles; // confetti, fireworks etc.
}