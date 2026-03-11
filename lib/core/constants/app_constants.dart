// App name, version, basic info
class AppConstants {
  static const String appName = 'LotChat';
  static const String appVersion = '1.0.0';
  static const String packageName = 'com.lotchat.app';
  
  // Coin conversion
  static const int coinPerDollar = 10000; // 1$ = 10000 coins
  static const int diamondPerCoin = 2; // 2 coins = 1 diamond
  
  // Limits
  static const int maxBioLength = 150;
  static const int maxUsernameLength = 20;
  static const int minUsernameLength = 3;
  static const int maxInterests = 10;
  static const int maxFriends = 5000;
  
  // Timeouts
  static const int connectionTimeout = 30; // seconds
  static const int receiveTimeout = 30; // seconds
  static const int socketTimeout = 60; // seconds
  
  // Pagination
  static const int pageSize = 20;
  static const int infiniteScrollThreshold = 0.8;
}