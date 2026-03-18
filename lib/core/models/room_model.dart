// lib/chat/models/room_model.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart'; // Color এর জন্য
import 'seat_model.dart'; // 🟢 SeatModel ইম্পোর্ট

enum RoomCategory {
  music,
  gaming,
  chat,
  dating,
  education,
  business,
  entertainment,
  sports,
  news,
  other,
}

enum RoomStatus {
  active,
  inactive,
  private,
  scheduled,
  ended,
}

class RoomModel {
  final String id;
  final String name;
  final String hostId;
  final String hostName;
  final String? hostAvatar;
  final String category;
  final String? description;
  final String? announcement;
  final int viewerCount;
  final int activeSpeakers; // 🟢 নতুন ফিল্ড - সক্রিয় স্পিকার সংখ্যা
  final int maxSeats;
  final List<SeatModel> seats;
  final bool isPKActive;
  final String? currentPKId;
  final bool isPrivate;
  final String? pinCode;
  final DateTime createdAt;
  final List<String> moderators;
  final Map<String, int> giftsReceived;
  final bool isActive; // 🟢 নতুন ফিল্ড - রুম কি লাইভ আছে?

  // Additional fields
  final String? coverImage;
  final String? language;
  final String? country;
  final int? ageRestriction;
  final RoomStatus status;
  final DateTime? scheduledStart;
  final DateTime? scheduledEnd;
  final int totalGifts;
  final int totalMessages;
  final int totalParticipants;
  final Map<String, dynamic>? settings;
  final List<String>? tags;
  final double? rating;
  final int? reviewCount;
  final Map<String, int>? viewerDemographics;
  final DateTime? lastActive;
  final DateTime? updatedAt;
  final Map<String, dynamic>? metadata;

  RoomModel({
    required this.id,
    required this.name,
    required this.hostId,
    required this.hostName,
    this.hostAvatar,
    required this.category,
    this.description,
    this.announcement,
    this.viewerCount = 0,
    this.activeSpeakers = 0, // 🟢 ডিফল্ট ভ্যালু
    this.maxSeats = 9,
    this.seats = const [],
    this.isPKActive = false,
    this.currentPKId,
    this.isPrivate = false,
    this.pinCode,
    required this.createdAt,
    this.moderators = const [],
    this.giftsReceived = const {},
    this.isActive = false, // 🟢 ডিফল্ট ভ্যালু
    this.coverImage,
    this.language,
    this.country,
    this.ageRestriction,
    this.status = RoomStatus.active,
    this.scheduledStart,
    this.scheduledEnd,
    this.totalGifts = 0,
    this.totalMessages = 0,
    this.totalParticipants = 0,
    this.settings,
    this.tags,
    this.rating,
    this.reviewCount,
    this.viewerDemographics,
    this.lastActive,
    this.updatedAt,
    this.metadata,
  });

  factory RoomModel.fromJson(Map<String, dynamic> json) {
    return RoomModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      hostId: json['hostId'] ?? '',
      hostName: json['hostName'] ?? '',
      hostAvatar: json['hostAvatar'],
      category: json['category'] ?? 'chat',
      description: json['description'],
      announcement: json['announcement'],
      viewerCount: json['viewerCount'] ?? 0,
      activeSpeakers: json['activeSpeakers'] ?? 0, // 🟢 JSON থেকে পড়া
      maxSeats: json['maxSeats'] ?? 9,
      seats: (json['seats'] as List? ?? [])
          .map((s) => SeatModel.fromJson(s))
          .toList(),
      isPKActive: json['isPKActive'] ?? false,
      currentPKId: json['currentPKId'],
      isPrivate: json['isPrivate'] ?? false,
      pinCode: json['pinCode'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      moderators: List<String>.from(json['moderators'] ?? []),
      giftsReceived: Map<String, int>.from(json['giftsReceived'] ?? {}),
      isActive: json['isActive'] ?? false, // 🟢 JSON থেকে পড়া
      coverImage: json['coverImage'],
      language: json['language'],
      country: json['country'],
      ageRestriction: json['ageRestriction'],
      status: _parseRoomStatus(json['status']),
      scheduledStart: json['scheduledStart'] != null
          ? DateTime.parse(json['scheduledStart'])
          : null,
      scheduledEnd: json['scheduledEnd'] != null
          ? DateTime.parse(json['scheduledEnd'])
          : null,
      totalGifts: json['totalGifts'] ?? 0,
      totalMessages: json['totalMessages'] ?? 0,
      totalParticipants: json['totalParticipants'] ?? 0,
      settings: json['settings'],
      tags: json['tags'] != null
          ? List<String>.from(json['tags'])
          : null,
      rating: json['rating']?.toDouble(),
      reviewCount: json['reviewCount'],
      viewerDemographics: json['viewerDemographics'],
      lastActive: json['lastActive'] != null
          ? DateTime.parse(json['lastActive'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
      metadata: json['metadata'],
    );
  }

  static RoomStatus _parseRoomStatus(String? status) {
    if (status == null) return RoomStatus.active;
    switch (status.toLowerCase()) {
      case 'active':
        return RoomStatus.active;
      case 'inactive':
        return RoomStatus.inactive;
      case 'private':
        return RoomStatus.private;
      case 'scheduled':
        return RoomStatus.scheduled;
      case 'ended':
        return RoomStatus.ended;
      default:
        return RoomStatus.active;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'hostId': hostId,
      'hostName': hostName,
      'hostAvatar': hostAvatar,
      'category': category,
      'description': description,
      'announcement': announcement,
      'viewerCount': viewerCount,
      'activeSpeakers': activeSpeakers, // 🟢 JSON এ লেখা
      'maxSeats': maxSeats,
      'seats': seats.map((s) => s.toJson()).toList(),
      'isPKActive': isPKActive,
      'currentPKId': currentPKId,
      'isPrivate': isPrivate,
      'pinCode': pinCode,
      'createdAt': createdAt.toIso8601String(),
      'moderators': moderators,
      'giftsReceived': giftsReceived,
      'isActive': isActive, // 🟢 JSON এ লেখা
      'coverImage': coverImage,
      'language': language,
      'country': country,
      'ageRestriction': ageRestriction,
      'status': status.toString().split('.').last,
      'scheduledStart': scheduledStart?.toIso8601String(),
      'scheduledEnd': scheduledEnd?.toIso8601String(),
      'totalGifts': totalGifts,
      'totalMessages': totalMessages,
      'totalParticipants': totalParticipants,
      'settings': settings,
      'tags': tags,
      'rating': rating,
      'reviewCount': reviewCount,
      'viewerDemographics': viewerDemographics,
      'lastActive': lastActive?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'metadata': metadata,
    };
  }

  RoomModel copyWith({
    String? id,
    String? name,
    String? hostId,
    String? hostName,
    String? hostAvatar,
    String? category,
    String? description,
    String? announcement,
    int? viewerCount,
    int? activeSpeakers, // 🟢 নতুন প্যারামিটার
    int? maxSeats,
    List<SeatModel>? seats,
    bool? isPKActive,
    String? currentPKId,
    bool? isPrivate,
    String? pinCode,
    DateTime? createdAt,
    List<String>? moderators,
    Map<String, int>? giftsReceived,
    bool? isActive, // 🟢 নতুন প্যারামিটার
    String? coverImage,
    String? language,
    String? country,
    int? ageRestriction,
    RoomStatus? status,
    DateTime? scheduledStart,
    DateTime? scheduledEnd,
    int? totalGifts,
    int? totalMessages,
    int? totalParticipants,
    Map<String, dynamic>? settings,
    List<String>? tags,
    double? rating,
    int? reviewCount,
    Map<String, int>? viewerDemographics,
    DateTime? lastActive,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
  }) {
    return RoomModel(
      id: id ?? this.id,
      name: name ?? this.name,
      hostId: hostId ?? this.hostId,
      hostName: hostName ?? this.hostName,
      hostAvatar: hostAvatar ?? this.hostAvatar,
      category: category ?? this.category,
      description: description ?? this.description,
      announcement: announcement ?? this.announcement,
      viewerCount: viewerCount ?? this.viewerCount,
      activeSpeakers: activeSpeakers ?? this.activeSpeakers, // 🟢 যোগ করা হয়েছে
      maxSeats: maxSeats ?? this.maxSeats,
      seats: seats ?? this.seats,
      isPKActive: isPKActive ?? this.isPKActive,
      currentPKId: currentPKId ?? this.currentPKId,
      isPrivate: isPrivate ?? this.isPrivate,
      pinCode: pinCode ?? this.pinCode,
      createdAt: createdAt ?? this.createdAt,
      moderators: moderators ?? this.moderators,
      giftsReceived: giftsReceived ?? this.giftsReceived,
      isActive: isActive ?? this.isActive, // 🟢 যোগ করা হয়েছে
      coverImage: coverImage ?? this.coverImage,
      language: language ?? this.language,
      country: country ?? this.country,
      ageRestriction: ageRestriction ?? this.ageRestriction,
      status: status ?? this.status,
      scheduledStart: scheduledStart ?? this.scheduledStart,
      scheduledEnd: scheduledEnd ?? this.scheduledEnd,
      totalGifts: totalGifts ?? this.totalGifts,
      totalMessages: totalMessages ?? this.totalMessages,
      totalParticipants: totalParticipants ?? this.totalParticipants,
      settings: settings ?? this.settings,
      tags: tags ?? this.tags,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      viewerDemographics: viewerDemographics ?? this.viewerDemographics,
      lastActive: lastActive ?? this.lastActive,
      updatedAt: updatedAt ?? this.updatedAt,
      metadata: metadata ?? this.metadata,
    );
  }

  // Getters
  int get occupiedSeats => seats.where((s) => !s.isEmpty).length;
  int get emptySeats => maxSeats - occupiedSeats;
  bool get isFull => occupiedSeats >= maxSeats;
  bool get hasModerators => moderators.isNotEmpty;
  bool get isLive => status == RoomStatus.active || isActive; // 🟢 isActive যোগ করা হয়েছে
  bool get isScheduled => status == RoomStatus.scheduled;

  String get seatStatus => '$occupiedSeats/$maxSeats seats occupied';

  Duration get timeSinceCreated => DateTime.now().difference(createdAt);

  String get timeAgo {
    final diff = timeSinceCreated;
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }

  // Methods
  bool isModerator(String userId) => moderators.contains(userId);
  bool isHost(String userId) => hostId == userId;
  bool canModerate(String userId) => isHost(userId) || isModerator(userId);

  // Seat management
  RoomModel addSeat(SeatModel seat) {
    final updatedSeats = List<SeatModel>.from(seats)..add(seat);
    return copyWith(seats: updatedSeats);
  }

  RoomModel updateSeat(int seatNumber, SeatModel updatedSeat) {
    final updatedSeats = seats.map((s) {
      if (s.seatNumber == seatNumber) return updatedSeat;
      return s;
    }).toList();
    return copyWith(seats: updatedSeats);
  }

  RoomModel removeSeat(int seatNumber) {
    final updatedSeats = seats.where((s) => s.seatNumber != seatNumber).toList();
    return copyWith(seats: updatedSeats);
  }

  // Gift management
  RoomModel addGift(String giftId, int amount) {
    final updatedGifts = Map<String, int>.from(giftsReceived);
    updatedGifts[giftId] = (updatedGifts[giftId] ?? 0) + amount;

    return copyWith(
      giftsReceived: updatedGifts,
      totalGifts: totalGifts + 1,
    );
  }

  // Moderator management
  RoomModel addModerator(String userId) {
    if (moderators.contains(userId)) return this;
    final updatedMods = List<String>.from(moderators)..add(userId);
    return copyWith(moderators: updatedMods);
  }

  RoomModel removeModerator(String userId) {
    final updatedMods = List<String>.from(moderators)..remove(userId);
    return copyWith(moderators: updatedMods);
  }

  // Viewer count
  RoomModel incrementViewers() => copyWith(viewerCount: viewerCount + 1);
  RoomModel decrementViewers() => copyWith(viewerCount: (viewerCount - 1).clamp(0, double.infinity).toInt());

  // Active speakers
  RoomModel incrementSpeakers() => copyWith(activeSpeakers: activeSpeakers + 1); // 🟢 নতুন মেথড
  RoomModel decrementSpeakers() => copyWith(activeSpeakers: (activeSpeakers - 1).clamp(0, double.infinity).toInt()); // 🟢 নতুন মেথড

  // PK Battle
  RoomModel startPK(String battleId) => copyWith(isPKActive: true, currentPKId: battleId);
  RoomModel endPK() => copyWith(isPKActive: false, currentPKId: null);

  // Status helpers
  RoomModel activate() => copyWith(status: RoomStatus.active, isActive: true); // 🟢 isActive true
  RoomModel deactivate() => copyWith(status: RoomStatus.inactive, isActive: false); // 🟢 isActive false
  RoomModel end() => copyWith(status: RoomStatus.ended, isActive: false); // 🟢 isActive false

  @override
  String toString() {
    return 'RoomModel(id: $id, name: $name, host: $hostName, viewers: $viewerCount, active: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RoomModel &&
        other.id == id &&
        other.name == name &&
        other.hostId == hostId;
  }

  @override
  int get hashCode => Object.hash(id, name, hostId);
}