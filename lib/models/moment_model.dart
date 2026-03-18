import 'package:flutter/material.dart';

enum MediaType { text, image, video, carousel }
enum MomentVisibility { public, followers, private }

class Moment {
  final String id;
  final String userId;
  final String userName;
  final String? userAvatar;
  final String content;
  final List<String> mediaUrls;
  final MediaType mediaType;
  final int likes;
  final int comments;
  final int shares;
  final bool isLiked;
  final bool isSaved;
  final DateTime createdAt;
  final List<String> tags;
  final String? location;
  final MomentVisibility visibility;
  final List<MomentComment>? recentComments;

  Moment({
    required this.id,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.content,
    required this.mediaUrls,
    required this.mediaType,
    required this.likes,
    required this.comments,
    required this.shares,
    required this.isLiked,
    required this.isSaved,
    required this.createdAt,
    required this.tags,
    this.location,
    this.visibility = MomentVisibility.public,
    this.recentComments,
  });

  // CopyWith method
  Moment copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userAvatar,
    String? content,
    List<String>? mediaUrls,
    MediaType? mediaType,
    int? likes,
    int? comments,
    int? shares,
    bool? isLiked,
    bool? isSaved,
    DateTime? createdAt,
    List<String>? tags,
    String? location,
    MomentVisibility? visibility,
    List<MomentComment>? recentComments,
  }) {
    return Moment(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userAvatar: userAvatar ?? this.userAvatar,
      content: content ?? this.content,
      mediaUrls: mediaUrls ?? this.mediaUrls,
      mediaType: mediaType ?? this.mediaType,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      shares: shares ?? this.shares,
      isLiked: isLiked ?? this.isLiked,
      isSaved: isSaved ?? this.isSaved,
      createdAt: createdAt ?? this.createdAt,
      tags: tags ?? this.tags,
      location: location ?? this.location,
      visibility: visibility ?? this.visibility,
      recentComments: recentComments ?? this.recentComments,
    );
  }

  // FromJson method
  factory Moment.fromJson(Map<String, dynamic> json) {
    return Moment(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? '',
      userAvatar: json['userAvatar'],
      content: json['content'] ?? '',
      mediaUrls: List<String>.from(json['mediaUrls'] ?? []),
      mediaType: _parseMediaType(json['mediaType']),
      likes: json['likes'] ?? 0,
      comments: json['comments'] ?? 0,
      shares: json['shares'] ?? 0,
      isLiked: json['isLiked'] ?? false,
      isSaved: json['isSaved'] ?? false,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      tags: List<String>.from(json['tags'] ?? []),
      location: json['location'],
      visibility: _parseVisibility(json['visibility']),
      recentComments: json['recentComments'] != null
          ? (json['recentComments'] as List)
          .map((c) => MomentComment.fromJson(c))
          .toList()
          : null,
    );
  }

  // ToJson method
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userAvatar': userAvatar,
      'content': content,
      'mediaUrls': mediaUrls,
      'mediaType': mediaType.toString().split('.').last,
      'likes': likes,
      'comments': comments,
      'shares': shares,
      'isLiked': isLiked,
      'isSaved': isSaved,
      'createdAt': createdAt.toIso8601String(),
      'tags': tags,
      'location': location,
      'visibility': visibility.toString().split('.').last,
      'recentComments': recentComments?.map((c) => c.toJson()).toList(),
    };
  }

  static MediaType _parseMediaType(String? type) {
    switch (type) {
      case 'image':
        return MediaType.image;
      case 'video':
        return MediaType.video;
      case 'carousel':
        return MediaType.carousel;
      default:
        return MediaType.text;
    }
  }

  static MomentVisibility _parseVisibility(String? visibility) {
    switch (visibility) {
      case 'followers':
        return MomentVisibility.followers;
      case 'private':
        return MomentVisibility.private;
      default:
        return MomentVisibility.public;
    }
  }
}

class MomentComment {
  final String id;
  final String userId;
  final String userName;
  final String? userAvatar;
  final String text;
  final int likes;
  final bool isLiked;
  final DateTime createdAt;
  final List<MomentComment> replies;
  final String? parentId;

  MomentComment({
    required this.id,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.text,
    required this.likes,
    required this.isLiked,
    required this.createdAt,
    required this.replies,
    this.parentId,
  });

  // CopyWith method
  MomentComment copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userAvatar,
    String? text,
    int? likes,
    bool? isLiked,
    DateTime? createdAt,
    List<MomentComment>? replies,
    String? parentId,
  }) {
    return MomentComment(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userAvatar: userAvatar ?? this.userAvatar,
      text: text ?? this.text,
      likes: likes ?? this.likes,
      isLiked: isLiked ?? this.isLiked,
      createdAt: createdAt ?? this.createdAt,
      replies: replies ?? this.replies,
      parentId: parentId ?? this.parentId,
    );
  }

  // FromJson method
  factory MomentComment.fromJson(Map<String, dynamic> json) {
    return MomentComment(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? '',
      userAvatar: json['userAvatar'],
      text: json['text'] ?? '',
      likes: json['likes'] ?? 0,
      isLiked: json['isLiked'] ?? false,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      replies: json['replies'] != null
          ? (json['replies'] as List)
          .map((r) => MomentComment.fromJson(r))
          .toList()
          : [],
      parentId: json['parentId'],
    );
  }

  // ToJson method
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userAvatar': userAvatar,
      'text': text,
      'likes': likes,
      'isLiked': isLiked,
      'createdAt': createdAt.toIso8601String(),
      'replies': replies.map((r) => r.toJson()).toList(),
      'parentId': parentId,
    };
  }
}

class MomentStats {
  final int totalMoments;
  final int totalLikes;
  final int totalComments;
  final int totalShares;
  final int totalViews;
  final Map<String, int> momentsByDay;
  final List<Moment> popularMoments;

  MomentStats({
    required this.totalMoments,
    required this.totalLikes,
    required this.totalComments,
    required this.totalShares,
    required this.totalViews,
    required this.momentsByDay,
    required this.popularMoments,
  });

  // FromJson method
  factory MomentStats.fromJson(Map<String, dynamic> json) {
    return MomentStats(
      totalMoments: json['totalMoments'] ?? 0,
      totalLikes: json['totalLikes'] ?? 0,
      totalComments: json['totalComments'] ?? 0,
      totalShares: json['totalShares'] ?? 0,
      totalViews: json['totalViews'] ?? 0,
      momentsByDay: Map<String, int>.from(json['momentsByDay'] ?? {}),
      popularMoments: (json['popularMoments'] as List? ?? [])
          .map((m) => Moment.fromJson(m))
          .toList(),
    );
  }

  // ToJson method
  Map<String, dynamic> toJson() {
    return {
      'totalMoments': totalMoments,
      'totalLikes': totalLikes,
      'totalComments': totalComments,
      'totalShares': totalShares,
      'totalViews': totalViews,
      'momentsByDay': momentsByDay,
      'popularMoments': popularMoments.map((m) => m.toJson()).toList(),
    };
  }
}

class MomentCreateRequest {
  final String content;
  final List<String> mediaUrls;
  final MediaType mediaType;
  final List<String> tags;
  final String? location;
  final MomentVisibility visibility;

  MomentCreateRequest({
    required this.content,
    required this.mediaUrls,
    required this.mediaType,
    required this.tags,
    this.location,
    this.visibility = MomentVisibility.public,
  });

  // ToJson method
  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'mediaUrls': mediaUrls,
      'mediaType': mediaType.toString().split('.').last,
      'tags': tags,
      'location': location,
      'visibility': visibility.toString().split('.').last,
    };
  }
}

class MomentUpdateRequest {
  final String? content;
  final List<String>? mediaUrls;
  final MediaType? mediaType;
  final List<String>? tags;
  final String? location;
  final MomentVisibility? visibility;

  MomentUpdateRequest({
    this.content,
    this.mediaUrls,
    this.mediaType,
    this.tags,
    this.location,
    this.visibility,
  });

  // ToJson method
  Map<String, dynamic> toJson() {
    return {
      if (content != null) 'content': content,
      if (mediaUrls != null) 'mediaUrls': mediaUrls,
      if (mediaType != null) 'mediaType': mediaType.toString().split('.').last,
      if (tags != null) 'tags': tags,
      if (location != null) 'location': location,
      if (visibility != null) 'visibility': visibility.toString().split('.').last,
    };
  }
}