class FirestoreConstants {
  // Collections
  static const String users = 'users';
  static const String rooms = 'rooms';
  static const String gifts = 'gifts';
  static const String messages = 'messages';
  static const String transactions = 'transactions';
  static const String reports = 'reports';
  static const String agencies = 'agencies';
  static const String sellers = 'sellers';
  static const String games = 'games';
  static const String pkBattles = 'pk_battles';
  static const String clans = 'clans';
  static const String notifications = 'notifications';
  static const String friendRequests = 'friend_requests';
  static const String callHistory = 'call_history';
  static const String leaderboard = 'leaderboard';
  
  // Sub-collections
  static const String userGifts = 'gifts'; // subcollection under users
  static const String userFriends = 'friends'; // subcollection under users
  static const String userFollowers = 'followers'; // subcollection under users
  static const String userFollowing = 'following'; // subcollection under users
  static const String userTransactions = 'transactions'; // subcollection under users
  
  static const String roomMessages = 'messages'; // subcollection under rooms
  static const String roomSeats = 'seats'; // subcollection under rooms
  static const String roomGifts = 'gifts'; // subcollection under rooms
  
  // Fields
  static const String createdAt = 'createdAt';
  static const String updatedAt = 'updatedAt';
  static const String deletedAt = 'deletedAt';
  
  static const String isActive = 'isActive';
  static const String isDeleted = 'isDeleted';
  static const String isBanned = 'isBanned';
  
  // Indexes
  static const List<String> userIndexes = ['username', 'email', 'country', 'tier'];
  static const List<String> roomIndexes = ['name', 'hostId', 'category', 'viewerCount'];
  static const List<String> giftIndexes = ['name', 'category', 'price'];
}