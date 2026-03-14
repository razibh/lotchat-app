class FrameHelper {
  static const String basePath = 'assets/frames/';
  
  static String getDefaultFrame() => '${basePath}default_frame.png';
  static String getBronzeFrame() => '${basePath}bronze_frame.png';
  static String getSilverFrame() => '${basePath}silver_frame.png';
  static String getGoldFrame() => '${basePath}gold_frame.png';
  static String getPlatinumFrame() => '${basePath}platinum_frame.png';
  
  static String getVipFrame(int level) {
    if (level < 1 || level > 10) return getDefaultFrame();
    return '${basePath}vip_frame_$level.png';
  }
  
  static String getSvipFrame(int level) {
    if (level < 1 || level > 8) return getDefaultFrame();
    return '${basePath}svip_frame_$level.png';
  }
  
  static String getEventFrame(String event) {
    switch(event) {
      case 'valentine':
        return '${basePath}event_frame_1.png';
      case 'birthday':
        return '${basePath}event_frame_2.png';
      case 'anniversary':
        return '${basePath}anniversary_frame.png';
      default:
        return getDefaultFrame();
    }
  }
  
  static String getAnimatedFrame(int level) {
    return '${basePath}animated_frame_$level.gif';
  }
  
  static String getCoupleFrame(int type) {
    return '${basePath}couple_frame_$type.png';
  }
  
  static Color getFrameColor(String tier) {
    switch(tier) {
      case 'bronze': return Color(0xFFCD7F32);
      case 'silver': return Color(0xFFC0C0C0);
      case 'gold': return Color(0xFFFFD700);
      case 'platinum': return Color(0xFFE5E4E2);
      case 'vip': return Color(0xFF8B5CF6);
      case 'svip': return Color(0xFFFF69B4);
      default: return Colors.transparent;
    }
  }
}