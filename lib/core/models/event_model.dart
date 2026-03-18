import 'package:flutter/material.dart';

enum EventType {
  festival,
  tournament,
  promotion,
  holiday,
  special,
  limitedTime,
}

enum EventStatus {
  upcoming,
  active,
  ended,
  cancelled,
}

class EventModel {
  final String id;
  final String title; // name পরিবর্তে title
  final String description;
  final EventType type;
  final EventStatus status;
  final DateTime startDate;
  final DateTime endDate;
  final String? bannerImage;
  final String? iconImage;
  final Map<String, dynamic> rewards;
  final List<String>? participatingUsers;
  final Map<String, dynamic>? requirements;
  final Map<String, dynamic>? rules;
  final List<String>? effects;
  final int? maxParticipants;
  final bool isFeatured;
  final Map<String, dynamic>? leaderboard;
  final Map<String, dynamic>? prizes;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Color color; // UI এর জন্য color যোগ করা
  final String image; // UI এর জন্য image যোগ করা
  final int participants; // UI এর জন্য participants যোগ করা

  EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.status,
    required this.startDate,
    required this.endDate,
    this.bannerImage,
    this.iconImage,
    this.rewards = const {},
    this.participatingUsers,
    this.requirements,
    this.rules,
    this.effects,
    this.maxParticipants,
    this.isFeatured = false,
    this.leaderboard,
    this.prizes,
    this.createdAt,
    this.updatedAt,
    required this.color,
    required this.image,
    required this.participants,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'] ?? '',
      title: json['title'] ?? json['name'] ?? '',
      description: json['description'] ?? '',
      type: _parseEventType(json['type']),
      status: _parseEventStatus(json['status']),
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'])
          : DateTime.now(),
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'])
          : DateTime.now().add(const Duration(days: 7)),
      bannerImage: json['bannerImage'],
      iconImage: json['iconImage'],
      rewards: json['rewards'] ?? {},
      participatingUsers: json['participatingUsers'] != null
          ? List<String>.from(json['participatingUsers'])
          : null,
      requirements: json['requirements'],
      rules: json['rules'],
      effects: json['effects'] != null
          ? List<String>.from(json['effects'])
          : null,
      maxParticipants: json['maxParticipants'],
      isFeatured: json['isFeatured'] ?? false,
      leaderboard: json['leaderboard'],
      prizes: json['prizes'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
      color: Color(json['color'] ?? 0xFF9C27B0),
      image: json['image'] ?? '',
      participants: json['participants'] ?? 0,
    );
  }

  static EventType _parseEventType(String? type) {
    if (type == null) return EventType.special;
    switch (type.toLowerCase()) {
      case 'festival':
        return EventType.festival;
      case 'tournament':
        return EventType.tournament;
      case 'promotion':
        return EventType.promotion;
      case 'holiday':
        return EventType.holiday;
      case 'special':
        return EventType.special;
      case 'limitedtime':
      case 'limited_time':
        return EventType.limitedTime;
      default:
        return EventType.special;
    }
  }

  static EventStatus _parseEventStatus(String? status) {
    if (status == null) return EventStatus.upcoming;
    switch (status.toLowerCase()) {
      case 'upcoming':
        return EventStatus.upcoming;
      case 'active':
        return EventStatus.active;
      case 'ended':
        return EventStatus.ended;
      case 'cancelled':
        return EventStatus.cancelled;
      default:
        return EventStatus.upcoming;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.toString().split('.').last,
      'status': status.toString().split('.').last,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'bannerImage': bannerImage,
      'iconImage': iconImage,
      'rewards': rewards,
      'participatingUsers': participatingUsers,
      'requirements': requirements,
      'rules': rules,
      'effects': effects,
      'maxParticipants': maxParticipants,
      'isFeatured': isFeatured,
      'leaderboard': leaderboard,
      'prizes': prizes,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'color': color.value,
      'image': image,
      'participants': participants,
    };
  }

  EventModel copyWith({
    String? id,
    String? title,
    String? description,
    EventType? type,
    EventStatus? status,
    DateTime? startDate,
    DateTime? endDate,
    String? bannerImage,
    String? iconImage,
    Map<String, dynamic>? rewards,
    List<String>? participatingUsers,
    Map<String, dynamic>? requirements,
    Map<String, dynamic>? rules,
    List<String>? effects,
    int? maxParticipants,
    bool? isFeatured,
    Map<String, dynamic>? leaderboard,
    Map<String, dynamic>? prizes,
    DateTime? createdAt,
    DateTime? updatedAt,
    Color? color,
    String? image,
    int? participants,
  }) {
    return EventModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      bannerImage: bannerImage ?? this.bannerImage,
      iconImage: iconImage ?? this.iconImage,
      rewards: rewards ?? this.rewards,
      participatingUsers: participatingUsers ?? this.participatingUsers,
      requirements: requirements ?? this.requirements,
      rules: rules ?? this.rules,
      effects: effects ?? this.effects,
      maxParticipants: maxParticipants ?? this.maxParticipants,
      isFeatured: isFeatured ?? this.isFeatured,
      leaderboard: leaderboard ?? this.leaderboard,
      prizes: prizes ?? this.prizes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      color: color ?? this.color,
      image: image ?? this.image,
      participants: participants ?? this.participants,
    );
  }

  // Helper getters
  bool get isActive => status == EventStatus.active;
  bool get isUpcoming => status == EventStatus.upcoming;
  bool get isEnded => status == EventStatus.ended;

  bool get hasStarted => DateTime.now().isAfter(startDate);
  bool get hasEnded => DateTime.now().isAfter(endDate);

  Duration get timeUntilStart => startDate.difference(DateTime.now());
  Duration get timeUntilEnd => endDate.difference(DateTime.now());

  int get participantCount => participatingUsers?.length ?? participants;
  bool get isFull => maxParticipants != null && participantCount >= maxParticipants!;

  bool canParticipate(String userId) {
    if (isEnded || hasEnded) return false;
    if (isFull) return false;
    if (participatingUsers?.contains(userId) ?? false) return false;
    return true;
  }
}