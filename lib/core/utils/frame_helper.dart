import 'package:flutter/material.dart'; // 🟢 Color এবং Colors এর জন্য

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

  // 🟢 Color getter
  static Color getFrameColor(String tier) {
    switch(tier) {
      case 'bronze':
        return const Color(0xFFCD7F32); // Bronze
      case 'silver':
        return const Color(0xFFC0C0C0); // Silver
      case 'gold':
        return const Color(0xFFFFD700); // Gold
      case 'platinum':
        return const Color(0xFFE5E4E2); // Platinum
      case 'vip':
        return const Color(0xFF8B5CF6); // Purple
      case 'svip':
        return const Color(0xFFFF69B4); // Hot Pink
      default:
        return Colors.transparent;
    }
  }

  // 🟢 Additional helper methods
  static String getFrameByTier(String tier, {int level = 1}) {
    switch(tier) {
      case 'bronze':
        return getBronzeFrame();
      case 'silver':
        return getSilverFrame();
      case 'gold':
        return getGoldFrame();
      case 'platinum':
        return getPlatinumFrame();
      case 'vip':
        return getVipFrame(level);
      case 'svip':
        return getSvipFrame(level);
      default:
        return getDefaultFrame();
    }
  }

  static bool isFrameAvailable(String framePath) {
    // This would check if the frame exists in assets
    return true; // Placeholder implementation
  }

  static String getFrameName(String framePath) {
    if (framePath.contains('vip')) {
      return 'VIP Frame';
    } else if (framePath.contains('svip')) {
      return 'SVIP Frame';
    } else if (framePath.contains('bronze')) {
      return 'Bronze Frame';
    } else if (framePath.contains('silver')) {
      return 'Silver Frame';
    } else if (framePath.contains('gold')) {
      return 'Gold Frame';
    } else if (framePath.contains('platinum')) {
      return 'Platinum Frame';
    } else {
      return 'Default Frame';
    }
  }
}