import 'package:flutter/foundation.dart';
import '../di/service_locator.dart';
import 'logger_service.dart';
import '../../models/moment_model.dart';

class MomentsService {
  final LoggerService _logger;

  MomentsService({
    LoggerService? logger,
  }) : _logger = logger ?? ServiceLocator.instance.get<LoggerService>();

  // Get moments feed
  Future<List<Moment>> getFeed({
    String? userId,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      _logger.debug('Fetching moments feed, page: $page, limit: $limit');

      // TODO: Replace with actual API call
      await Future.delayed(const Duration(seconds: 1));

      return _generateMockMoments();

    } catch (e, stackTrace) {
      _logger.error('Failed to fetch moments feed', error: e, stackTrace: stackTrace);
      throw Exception('Failed to load moments: $e');
    }
  }

  // Get user moments
  Future<List<Moment>> getUserMoments(String userId, {int page = 1, int limit = 20}) async {
    try {
      _logger.debug('Fetching moments for user: $userId');

      // TODO: Implement actual API call
      await Future.delayed(const Duration(seconds: 1));

      return _generateMockMoments().where((m) => m.userId == userId).toList();

    } catch (e, stackTrace) {
      _logger.error('Failed to fetch user moments', error: e, stackTrace: stackTrace);
      throw Exception('Failed to load user moments: $e');
    }
  }

  // Get single moment
  Future<Moment> getMoment(String momentId) async {
    try {
      _logger.debug('Fetching moment: $momentId');

      // TODO: Implement actual API call
      await Future.delayed(const Duration(seconds: 1));

      return _generateMockMoments().first;

    } catch (e, stackTrace) {
      _logger.error('Failed to fetch moment', error: e, stackTrace: stackTrace);
      throw Exception('Failed to load moment: $e');
    }
  }

  // Create moment
  Future<Moment> createMoment(Map<String, dynamic> data) async {
    try {
      _logger.debug('Creating new moment');

      // TODO: Implement actual API call
      await Future.delayed(const Duration(seconds: 1));

      return Moment(
        id: 'moment_${DateTime.now().millisecondsSinceEpoch}',
        userId: data['userId'] ?? 'current_user',
        userName: data['userName'] ?? 'Current User',
        userAvatar: data['userAvatar'],
        content: data['content'] ?? '',
        mediaUrls: data['mediaUrls'] ?? [],
        mediaType: data['mediaType'] ?? MediaType.text,
        likes: 0,
        comments: 0,
        shares: 0,
        isLiked: false,
        isSaved: false,
        createdAt: DateTime.now(),
        tags: data['tags'] ?? [],
        location: data['location'],
      );

    } catch (e, stackTrace) {
      _logger.error('Failed to create moment', error: e, stackTrace: stackTrace);
      throw Exception('Failed to create moment: $e');
    }
  }

  // Like/Unlike moment
  Future<bool> toggleLike(String momentId, bool isLiked) async {
    try {
      _logger.debug('Toggling like for moment: $momentId, isLiked: $isLiked');

      // TODO: Implement actual API call
      await Future.delayed(const Duration(milliseconds: 500));

      return !isLiked;

    } catch (e, stackTrace) {
      _logger.error('Failed to toggle like', error: e, stackTrace: stackTrace);
      throw Exception('Failed to update like: $e');
    }
  }

  // Save/Unsave moment
  Future<bool> toggleSave(String momentId, bool isSaved) async {
    try {
      _logger.debug('Toggling save for moment: $momentId, isSaved: $isSaved');

      // TODO: Implement actual API call
      await Future.delayed(const Duration(milliseconds: 500));

      return !isSaved;

    } catch (e, stackTrace) {
      _logger.error('Failed to toggle save', error: e, stackTrace: stackTrace);
      throw Exception('Failed to update save: $e');
    }
  }

  // Delete moment
  Future<void> deleteMoment(String momentId) async {
    try {
      _logger.debug('Deleting moment: $momentId');

      // TODO: Implement actual API call
      await Future.delayed(const Duration(seconds: 1));

    } catch (e, stackTrace) {
      _logger.error('Failed to delete moment', error: e, stackTrace: stackTrace);
      throw Exception('Failed to delete moment: $e');
    }
  }

  // Report moment
  Future<void> reportMoment(String momentId, String reason) async {
    try {
      _logger.debug('Reporting moment: $momentId, reason: $reason');

      // TODO: Implement actual API call
      await Future.delayed(const Duration(seconds: 1));

    } catch (e, stackTrace) {
      _logger.error('Failed to report moment', error: e, stackTrace: stackTrace);
      throw Exception('Failed to report moment: $e');
    }
  }

  // Get comments for moment
  Future<List<MomentComment>> getComments(String momentId, {int page = 1, int limit = 20}) async {
    try {
      _logger.debug('Fetching comments for moment: $momentId');

      // TODO: Implement actual API call
      await Future.delayed(const Duration(seconds: 1));

      return _generateMockComments();

    } catch (e, stackTrace) {
      _logger.error('Failed to fetch comments', error: e, stackTrace: stackTrace);
      throw Exception('Failed to load comments: $e');
    }
  }

  // Add comment
  Future<MomentComment> addComment(String momentId, String userId, String userName, String text) async {
    try {
      _logger.debug('Adding comment to moment: $momentId');

      // TODO: Implement actual API call
      await Future.delayed(const Duration(seconds: 1));

      return MomentComment(
        id: 'comment_${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        userName: userName,
        userAvatar: null,
        text: text,
        likes: 0,
        isLiked: false,
        createdAt: DateTime.now(),
        replies: [],
      );

    } catch (e, stackTrace) {
      _logger.error('Failed to add comment', error: e, stackTrace: stackTrace);
      throw Exception('Failed to add comment: $e');
    }
  }

  // Delete comment
  Future<void> deleteComment(String commentId) async {
    try {
      _logger.debug('Deleting comment: $commentId');

      // TODO: Implement actual API call
      await Future.delayed(const Duration(seconds: 1));

    } catch (e, stackTrace) {
      _logger.error('Failed to delete comment', error: e, stackTrace: stackTrace);
      throw Exception('Failed to delete comment: $e');
    }
  }

  // Mock data generators
  List<Moment> _generateMockMoments() {
    return [
      Moment(
        id: 'moment_1',
        userId: 'user_1',
        userName: 'Sarah Rahman',
        userAvatar: null,
        content: 'Just finished an amazing live session! Thank you all for the support! 🎤❤️',
        mediaUrls: ['https://example.com/image1.jpg'],
        mediaType: MediaType.image,
        likes: 1234,
        comments: 89,
        shares: 45,
        isLiked: false,
        isSaved: false,
        createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
        tags: ['music', 'live', 'gratitude'],
        location: 'Dhaka, Bangladesh',
      ),
      Moment(
        id: 'moment_2',
        userId: 'user_2',
        userName: 'Rahim Gaming',
        userAvatar: null,
        content: 'New gaming video coming soon! Guess the game in comments! 🎮',
        mediaUrls: ['https://example.com/video1.mp4'],
        mediaType: MediaType.video,
        likes: 892,
        comments: 156,
        shares: 23,
        isLiked: true,
        isSaved: false,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        tags: ['gaming', 'teaser', 'pubg'],
        location: null,
      ),
      Moment(
        id: 'moment_3',
        userId: 'user_3',
        userName: 'Travel Bangladesh',
        userAvatar: null,
        content: 'Beautiful sunset at Cox\'s Bazar! 🌅 #travel #bangladesh',
        mediaUrls: [
          'https://example.com/image2.jpg',
          'https://example.com/image3.jpg',
        ],
        mediaType: MediaType.carousel,
        likes: 3456,
        comments: 234,
        shares: 567,
        isLiked: false,
        isSaved: true,
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        tags: ['travel', 'sunset', 'coxsbazar'],
        location: 'Cox\'s Bazar, Bangladesh',
      ),
    ];
  }

  List<MomentComment> _generateMockComments() {
    return [
      MomentComment(
        id: 'comment_1',
        userId: 'user_4',
        userName: 'John Doe',
        userAvatar: null,
        text: 'Amazing performance! 🔥',
        likes: 23,
        isLiked: false,
        createdAt: DateTime.now().subtract(const Duration(minutes: 10)),
        replies: [],
      ),
      MomentComment(
        id: 'comment_2',
        userId: 'user_5',
        userName: 'Jane Smith',
        userAvatar: null,
        text: 'When is your next live?',
        likes: 12,
        isLiked: true,
        createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
        replies: [
          MomentComment(
            id: 'reply_1',
            userId: 'user_1',
            userName: 'Sarah Rahman',
            userAvatar: null,
            text: 'Tomorrow at 8 PM!',
            likes: 5,
            isLiked: false,
            createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
            replies: [],
          ),
        ],
      ),
    ];
  }
}

// Moment Model (if not exists, create this in models folder)
enum MediaType { text, image, video, carousel }

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
  });
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
  });
}