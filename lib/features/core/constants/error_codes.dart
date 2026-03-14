class ErrorCodes {
  // Authentication Errors (1000-1999)
  static const int authInvalidCredentials = 1001;
  static const int authUserNotFound = 1002;
  static const int authEmailAlreadyInUse = 1003;
  static const int authWeakPassword = 1004;
  static const int authInvalidEmail = 1005;
  static const int authAccountDisabled = 1006;
  static const int authTooManyRequests = 1007;
  static const int authNetworkError = 1008;
  static const int authSessionExpired = 1009;
  static const int authTokenInvalid = 1010;
  static const int authPhoneNumberExists = 1011;
  static const int authInvalidOtp = 1012;
  static const int authOtpExpired = 1013;
  static const int authMaxAttempts = 1014;

  // User Errors (2000-2999)
  static const int userNotFound = 2001;
  static const int userAlreadyExists = 2002;
  static const int userInsufficientCoins = 2003;
  static const int userInsufficientDiamonds = 2004;
  static const int userAlreadyFriend = 2005;
  static const int userNotFriend = 2006;
  static const int userBlocked = 2007;
  static const int userAlreadyBlocked = 2008;
  static const int userNotBlocked = 2009;
  static const int userMaxFriends = 2010;
  static const int userAlreadySentRequest = 2011;
  static const int userAlreadyReceivedRequest = 2012;

  // Gift Errors (3000-3999)
  static const int giftNotFound = 3001;
  static const int giftNotAvailable = 3002;
  static const int giftInsufficientCoins = 3003;
  static const int giftCannotSendToSelf = 3004;
  static const int giftMaxPerMinute = 3005;
  static const int giftInvalidAmount = 3006;
  static const int giftAlreadyInFavorites = 3007;
  static const int giftNotInFavorites = 3008;

  // Room Errors (4000-4999)
  static const int roomNotFound = 4001;
  static const int roomFull = 4002;
  static const int roomAlreadyJoined = 4003;
  static const int roomNotJoined = 4004;
  static const int roomSeatTaken = 4005;
  static const int roomSeatNotFound = 4006;
  static const int roomInvalidPin = 4007;
  static const int roomNotAuthorized = 4008;
  static const int roomAlreadyInPk = 4009;
  static const int roomCannotJoinPk = 4010;

  // Game Errors (5000-5999)
  static const int gameNotFound = 5001;
  static const int gameInsufficientCoins = 5002;
  static const int gameInvalidBet = 5003;
  static const int gameAlreadyPlaying = 5004;
  static const int gameMaxPlayers = 5005;
  static const int gameInvalidMove = 5006;
  static const int gameTimeout = 5007;

  // Chat Errors (6000-6999)
  static const int chatNotFound = 6001;
  static const int chatCannotMessageSelf = 6002;
  static const int chatBlocked = 6003;
  static const int chatMaxParticipants = 6004;
  static const int messageNotFound = 6005;
  static const int messageCannotEdit = 6006;
  static const int messageCannotDelete = 6007;
  static const int messageTooLong = 6008;
  static const int messageEmpty = 6009;

  // Call Errors (7000-7999)
  static const int callNotFound = 7001;
  static const int callAlreadyInProgress = 7002;
  static const int callUserBusy = 7003;
  static const int callUserOffline = 7004;
  static const int callRejected = 7005;
  static const int callMissed = 7006;
  static const int callMaxParticipants = 7007;

  // Payment Errors (8000-8999)
  static const int paymentFailed = 8001;
  static const int paymentCancelled = 8002;
  static const int paymentInvalid = 8003;
  static const int paymentInsufficientFunds = 8004;
  static const int paymentLimitExceeded = 8005;
  static const int paymentMethodInvalid = 8006;

  // Clan Errors (9000-9999)
  static const int clanNotFound = 9001;
  static const int clanAlreadyMember = 9002;
  static const int clanNotMember = 9003;
  static const int clanFull = 9004;
  static const int clanCannotLeave = 9005;
  static const int clanCannotKickLeader = 9006;
  static const int clanInvalidRole = 9007;
  static const int clanRequestExists = 9008;
  static const int clanRequestNotFound = 9009;

  // PK Battle Errors (10000-10999)
  static const int pkBattleNotFound = 10001;
  static const int pkBattleAlreadyStarted = 10002;
  static const int pkBattleEnded = 10003;
  static const int pkBattleCannotJoin = 10004;
  static const int pkBattleInvalidScore = 10005;

  // Upload Errors (11000-11999)
  static const int uploadFailed = 11001;
  static const int uploadFileTooLarge = 11002;
  static const int uploadInvalidType = 11003;
  static const int uploadCorrupted = 11004;

  // Report Errors (12000-12999)
  static const int reportNotFound = 12001;
  static const int reportAlreadyResolved = 12002;
  static const int reportInvalidReason = 12003;
  static const int reportCannotReportSelf = 12004;
  static const int reportDuplicate = 12005;

  // Server Errors (13000-13999)
  static const int serverInternal = 13001;
  static const int serverUnavailable = 13002;
  static const int serverTimeout = 13003;
  static const int serverMaintenance = 13004;

  // Network Errors (14000-14999)
  static const int networkNoConnection = 14001;
  static const int networkTimeout = 14002;
  static const int networkTlsError = 14003;
  static const int networkProxyError = 14004;

  // Database Errors (15000-15999)
  static const int databaseError = 15001;
  static const int databaseConstraint = 15002;
  static const int databaseDuplicate = 15003;
  static const int databaseNotFound = 15004;

  // Permission Errors (16000-16999)
  static const int permissionDenied = 16001;
  static const int permissionPermanentlyDenied = 16002;
  static const int permissionNotGranted = 16003;

  // Validation Errors (17000-17999)
  static const int validationRequired = 17001;
  static const int validationInvalidFormat = 17002;
  static const int validationTooShort = 17003;
  static const int validationTooLong = 17004;
  static const int validationInvalidRange = 17005;

  // Get error message
  static String getErrorMessage(int code) {
    switch (code) {
      // Authentication
      case authInvalidCredentials:
        return 'Invalid email or password';
      case authUserNotFound:
        return 'User not found';
      case authEmailAlreadyInUse:
        return 'Email already in use';
      case authWeakPassword:
        return 'Password is too weak';
      case authInvalidEmail:
        return 'Invalid email address';
      case authAccountDisabled:
        return 'Account has been disabled';
      case authTooManyRequests:
        return 'Too many attempts. Please try again later';
      case authNetworkError:
        return 'Network error. Please check your connection';
      case authSessionExpired:
        return 'Session expired. Please login again';
      case authTokenInvalid:
        return 'Invalid authentication token';
      case authPhoneNumberExists:
        return 'Phone number already exists';
      case authInvalidOtp:
        return 'Invalid OTP';
      case authOtpExpired:
        return 'OTP has expired';
      case authMaxAttempts:
        return 'Maximum attempts exceeded';

      // User
      case userNotFound:
        return 'User not found';
      case userAlreadyExists:
        return 'User already exists';
      case userInsufficientCoins:
        return 'Insufficient coins';
      case userInsufficientDiamonds:
        return 'Insufficient diamonds';
      case userAlreadyFriend:
        return 'Already friends';
      case userNotFriend:
        return 'Not friends';
      case userBlocked:
        return 'User is blocked';
      case userAlreadyBlocked:
        return 'User already blocked';
      case userNotBlocked:
        return 'User is not blocked';
      case userMaxFriends:
        return 'Maximum friends limit reached';
      case userAlreadySentRequest:
        return 'Friend request already sent';
      case userAlreadyReceivedRequest:
        return 'Friend request already received';

      // Gift
      case giftNotFound:
        return 'Gift not found';
      case giftNotAvailable:
        return 'Gift is not available';
      case giftInsufficientCoins:
        return 'Insufficient coins to send gift';
      case giftCannotSendToSelf:
        return 'Cannot send gift to yourself';
      case giftMaxPerMinute:
        return 'Maximum gifts per minute reached';
      case giftInvalidAmount:
        return 'Invalid gift amount';
      case giftAlreadyInFavorites:
        return 'Gift already in favorites';
      case giftNotInFavorites:
        return 'Gift not in favorites';

      // Room
      case roomNotFound:
        return 'Room not found';
      case roomFull:
        return 'Room is full';
      case roomAlreadyJoined:
        return 'Already joined this room';
      case roomNotJoined:
        return 'Not joined this room';
      case roomSeatTaken:
        return 'Seat is already taken';
      case roomSeatNotFound:
        return 'Seat not found';
      case roomInvalidPin:
        return 'Invalid room PIN';
      case roomNotAuthorized:
        return 'Not authorized for this action';
      case roomAlreadyInPk:
        return 'Room is already in a PK battle';
      case roomCannotJoinPk:
        return 'Cannot join PK battle';

      default:
        return 'An error occurred. Please try again';
    }
  }
}