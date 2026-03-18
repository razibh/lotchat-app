import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

enum PostType { text, image, video, gif, audio }
enum PostVisibility { public, followers, private }

class PostModel {
  final String id;
  final String userId;
  final String username;
  final String? userAvatar;
  final String content;
  final String? mediaUrl;
  final PostType type;
  final int? imagesCount; // for multiple images
  final int likes;
  final int comments;
  final int shares;
  final DateTime timestamp;
  final PostVisibility visibility;
  final List<String>? tags;
  final String? location;
  final bool isLiked;
  final bool isSaved;
  final bool isPinned;
  final List<PostMedia>? media; // for multiple media
  final Map<String, dynamic>? metadata;

  PostModel({
    required this.id,
    required this.userId,
    required this.username,
    this.userAvatar,
    required this.content,
    this.mediaUrl,
    required this.type,
    this.imagesCount,
    required this.likes,
    required this.comments,
    required this.shares,
    required this.timestamp,
    this.visibility = PostVisibility.public,
    this.tags,
    this.location,
    this.isLiked = false,
    this.isSaved = false,
    this.isPinned = false,
    this.media,
    this.metadata,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      username: json['username'] ?? '',
      userAvatar: json['userAvatar'],
      content: json['content'] ?? '',
      mediaUrl: json['mediaUrl'],
      type: _parsePostType(json['type']),
      imagesCount: json['imagesCount'],
      likes: json['likes'] ?? 0,
      comments: json['comments'] ?? 0,
      shares: json['shares'] ?? 0,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
      visibility: _parsePostVisibility(json['visibility']),
      tags: json['tags'] != null ? List<String>.from(json['tags']) : null,
      location: json['location'],
      isLiked: json['isLiked'] ?? false,
      isSaved: json['isSaved'] ?? false,
      isPinned: json['isPinned'] ?? false,
      media: json['media'] != null
          ? (json['media'] as List).map((m) => PostMedia.fromJson(m)).toList()
          : null,
      metadata: json['metadata'],
    );
  }

  static PostType _parsePostType(String? type) {
    if (type == null) return PostType.text;
    switch (type.toLowerCase()) {
      case 'text':
        return PostType.text;
      case 'image':
        return PostType.image;
      case 'video':
        return PostType.video;
      case 'gif':
        return PostType.gif;
      case 'audio':
        return PostType.audio;
      default:
        return PostType.text;
    }
  }

  static PostVisibility _parsePostVisibility(String? visibility) {
    if (visibility == null) return PostVisibility.public;
    switch (visibility.toLowerCase()) {
      case 'public':
        return PostVisibility.public;
      case 'followers':
        return PostVisibility.followers;
      case 'private':
        return PostVisibility.private;
      default:
        return PostVisibility.public;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'username': username,
      'userAvatar': userAvatar,
      'content': content,
      'mediaUrl': mediaUrl,
      'type': type.toString().split('.').last,
      'imagesCount': imagesCount,
      'likes': likes,
      'comments': comments,
      'shares': shares,
      'timestamp': timestamp.toIso8601String(),
      'visibility': visibility.toString().split('.').last,
      'tags': tags,
      'location': location,
      'isLiked': isLiked,
      'isSaved': isSaved,
      'isPinned': isPinned,
      'media': media?.map((m) => m.toJson()).toList(),
      'metadata': metadata,
    };
  }

  PostModel copyWith({
    String? id,
    String? userId,
    String? username,
    String? userAvatar,
    String? content,
    String? mediaUrl,
    PostType? type,
    int? imagesCount,
    int? likes,
    int? comments,
    int? shares,
    DateTime? timestamp,
    PostVisibility? visibility,
    List<String>? tags,
    String? location,
    bool? isLiked,
    bool? isSaved,
    bool? isPinned,
    List<PostMedia>? media,
    Map<String, dynamic>? metadata,
  }) {
    return PostModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      userAvatar: userAvatar ?? this.userAvatar,
      content: content ?? this.content,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      type: type ?? this.type,
      imagesCount: imagesCount ?? this.imagesCount,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      shares: shares ?? this.shares,
      timestamp: timestamp ?? this.timestamp,
      visibility: visibility ?? this.visibility,
      tags: tags ?? this.tags,
      location: location ?? this.location,
      isLiked: isLiked ?? this.isLiked,
      isSaved: isSaved ?? this.isSaved,
      isPinned: isPinned ?? this.isPinned,
      media: media ?? this.media,
      metadata: metadata ?? this.metadata,
    );
  }

  // Getters
  String get displayTime {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  bool get hasMedia => mediaUrl != null || (media != null && media!.isNotEmpty);
  bool get isMultipleMedia => media != null && media!.length > 1;

  @override
  String toString() {
    return 'PostModel(id: $id, username: $username, type: $type, likes: $likes)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PostModel &&
        other.id == id &&
        other.userId == userId &&
        other.timestamp == timestamp;
  }

  @override
  int get hashCode => Object.hash(id, userId, timestamp);
}

// Media class for multiple media posts
class PostMedia {
  final String url;
  final PostType type;
  final double? aspectRatio;
  final String? thumbnailUrl;
  final int? duration; // for video/audio
  final Map<String, dynamic>? metadata;

  PostMedia({
    required this.url,
    required this.type,
    this.aspectRatio,
    this.thumbnailUrl,
    this.duration,
    this.metadata,
  });

  factory PostMedia.fromJson(Map<String, dynamic> json) {
    return PostMedia(
      url: json['url'] ?? '',
      type: PostModel._parsePostType(json['type']),
      aspectRatio: json['aspectRatio']?.toDouble(),
      thumbnailUrl: json['thumbnailUrl'],
      duration: json['duration'],
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'type': type.toString().split('.').last,
      'aspectRatio': aspectRatio,
      'thumbnailUrl': thumbnailUrl,
      'duration': duration,
      'metadata': metadata,
    };
  }
}

// Reaction model
class PostReaction {
  final String userId;
  final String type; // like, love, haha, wow, sad, angry
  final DateTime timestamp;

  PostReaction({
    required this.userId,
    required this.type,
    required this.timestamp,
  });

  factory PostReaction.fromJson(Map<String, dynamic> json) {
    return PostReaction(
      userId: json['userId'] ?? '',
      type: json['type'] ?? 'like',
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'type': type,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

// Comment model
class PostComment {
  final String id;
  final String userId;
  final String username;
  final String? userAvatar;
  final String content;
  final DateTime timestamp;
  final int likes;
  final bool isLiked;
  final List<PostComment>? replies;

  PostComment({
    required this.id,
    required this.userId,
    required this.username,
    this.userAvatar,
    required this.content,
    required this.timestamp,
    required this.likes,
    required this.isLiked,
    this.replies,
  });

  factory PostComment.fromJson(Map<String, dynamic> json) {
    return PostComment(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      username: json['username'] ?? '',
      userAvatar: json['userAvatar'],
      content: json['content'] ?? '',
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
      likes: json['likes'] ?? 0,
      isLiked: json['isLiked'] ?? false,
      replies: json['replies'] != null
          ? (json['replies'] as List).map((r) => PostComment.fromJson(r)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'username': username,
      'userAvatar': userAvatar,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'likes': likes,
      'isLiked': isLiked,
      'replies': replies?.map((r) => r.toJson()).toList(),
    };
  }

  String get displayTime {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'now';
    }
  }
}