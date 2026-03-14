// User Related Enums
enum UserTier {
  normal,
  vip1, vip2, vip3, vip4, vip5, vip6, vip7, vip8, vip9, vip10,
  svip1, svip2, svip3, svip4, svip5, svip6, svip7, svip8
}

enum UserRole {
  user,
  seller,
  agency,
  admin,
  superAdmin
}

enum UserStatus {
  online,
  offline,
  away,
  busy
}

// Room Related Enums
enum RoomCategory {
  chat,
  music,
  game,
  dating,
  education,
  business
}

enum SeatStatus {
  empty,
  occupied,
  muted,
  speaking
}

// Gift Related Enums
enum GiftCategory {
  cute,
  luxury,
  vip,
  svip,
  special
}

enum GiftEffect {
  none,
  fullscreen,
  confetti,
  fireworks,
  combo
}

// Game Related Enums
enum GameType {
  roulette,
  threePatti,
  ludo,
  carrom,
  greedyCat,
  werewolf,
  trivia,
  pictionary,
  truthOrDare,
  chess,
  checkers
}

enum GameResult {
  win,
  lose,
  draw
}

// Transaction Related Enums
enum TransactionType {
  purchase,
  giftSent,
  giftReceived,
  gameWin,
  gameLose,
  withdraw,
  adminAdd
}

enum PaymentMethod {
  stripe,
  razorpay,
  paypal,
  coin,
  diamond
}

// Notification Related Enums
enum NotificationType {
  gift,
  friendRequest,
  message,
  call,
  game,
  pk,
  system
}

// Report Related Enums
enum ReportReason {
  spam,
  harassment,
  nudity,
  violence,
  fake,
  other
}

enum ReportStatus {
  pending,
  resolved,
  rejected
}

// Call Related Enums
enum CallType {
  audio,
  video
}

enum CallStatus {
  ringing,
  connected,
  ended,
  missed
}

// PK Battle Enums
enum PKStatus {
  waiting,
  active,
  ended
}

// Clan Enums
enum ClanRole {
  leader,
  coLeader,
  member
}

// Agency Enums
enum AgencyStatus {
  active,
  suspended,
  pending
}

// Frame & Badge Enums
enum FrameType {
  normal,
  vip,
  svip,
  event,
  special
}

enum BadgeType {
  normal,
  vip,
  svip,
  fan,
  event,
  achievement
}