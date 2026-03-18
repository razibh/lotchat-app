// lib/core/models/seat_model.dart

import 'user_models.dart';
class SeatModel {
  final int seatNumber;
  final String? userId;
  final String? userName;
  final String? userAvatar;
  final bool isMuted;
  final bool isSpeaking;
  final UserTier? userTier;  // 🟢 এখন user_model থেকে আসছে
  final bool isEmpty;

  SeatModel({
    required this.seatNumber,
    this.userId,
    this.userName,
    this.userAvatar,
    this.isMuted = false,
    this.isSpeaking = false,
    this.userTier,
    this.isEmpty = false,
  });

  factory SeatModel.empty(int seatNumber) {
    return SeatModel(
      seatNumber: seatNumber,
      isEmpty: true,
    );
  }

  factory SeatModel.fromJson(Map<String, dynamic> json) {
    return SeatModel(
      seatNumber: json['seatNumber'] ?? 0,
      userId: json['userId'],
      userName: json['userName'],
      userAvatar: json['userAvatar'],
      isMuted: json['isMuted'] ?? false,
      isSpeaking: json['isSpeaking'] ?? false,
      userTier: _parseUserTier(json['userTier']),
      isEmpty: json['isEmpty'] ?? false,
    );
  }

  static UserTier? _parseUserTier(String? tier) {
    if (tier == null) return null;
    switch (tier.toLowerCase()) {
      case 'vip':
        return UserTier.vip;
      case 'svip':
        return UserTier.svip;
      default:
        return UserTier.normal;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'seatNumber': seatNumber,
      'userId': userId,
      'userName': userName,
      'userAvatar': userAvatar,
      'isMuted': isMuted,
      'isSpeaking': isSpeaking,
      'userTier': userTier?.toString().split('.').last,
      'isEmpty': isEmpty,
    };
  }

  SeatModel copyWith({
    int? seatNumber,
    String? userId,
    String? userName,
    String? userAvatar,
    bool? isMuted,
    bool? isSpeaking,
    UserTier? userTier,
    bool? isEmpty,
  }) {
    return SeatModel(
      seatNumber: seatNumber ?? this.seatNumber,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userAvatar: userAvatar ?? this.userAvatar,
      isMuted: isMuted ?? this.isMuted,
      isSpeaking: isSpeaking ?? this.isSpeaking,
      userTier: userTier ?? this.userTier,
      isEmpty: isEmpty ?? this.isEmpty,
    );
  }
}

// 🟢 এই enum টি সরিয়ে ফেলুন (কারণ user_model.dart এ আছে)
// enum UserTier {
//   normal,
//   vip,
//   svip,
// }