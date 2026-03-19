import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../di/service_locator.dart';

class ModerationService {
  late final SupabaseClient _supabase;

  ModerationService() {
    _supabase = getService<SupabaseClient>();
  }

  // Banned words list
  static const List<String> bannedWords = [
    // English profanity
    'fuck', 'shit', 'asshole', 'bitch', 'cunt', 'dick', 'pussy',
    'motherfucker', 'bastard', 'whore', 'slut', 'damn', 'hell',

    // Bengali profanity (examples - add your actual list)
    'chor', 'gada', 'mara', 'choda', 'magir pola',

    // Hindi profanity
    'madarchod', 'bhosdike', 'chutiya', 'loda', 'gaand',

    // Spam patterns
    'buy followers', 'cheap coins', 'hack',
  ];

  // Extreme slang - auto ban
  static const List<String> extremeSlang = [
    'terrorist', 'bomb', 'kill', 'murder', 'rape', 'suicide',
    'child porn', 'cp', 'sex with', 'underage',
  ];

  // Helper to get current user
  String? get _currentUserId => _supabase.auth.currentSession?.user.id;

  // ==================== TEXT MODERATION ====================
  ModerationResult moderateText(String text) {
    final String lowerText = text.toLowerCase();
    final List<String> words = lowerText.split(RegExp(r'\s+'));

    final List<String> foundBannedWords = [];
    bool hasExtreme = false;

    // Check each word
    for (String word in words) {
      // Remove punctuation
      word = word.replaceAll(RegExp(r'[^\w\s]'), '');

      if (extremeSlang.contains(word)) {
        hasExtreme = true;
        foundBannedWords.add(word);
      } else if (bannedWords.contains(word)) {
        foundBannedWords.add(word);
      }
    }

    // Check for patterns (like leetspeak)
    final String? leetPattern = _checkLeetspeak(lowerText);
    if (leetPattern != null) {
      foundBannedWords.add(leetPattern);
    }

    return ModerationResult(
      isClean: foundBannedWords.isEmpty && !hasExtreme,
      foundWords: foundBannedWords,
      hasExtremeContent: hasExtreme,
      action: hasExtreme ? ModerationAction.ban :
      foundBannedWords.isNotEmpty ? ModerationAction.block :
      ModerationAction.allow,
    );
  }

  String? _checkLeetspeak(String text) {
    // Convert leetspeak to normal
    final Map<String, String> leetMap = {
      '0': 'o', '1': 'i', '3': 'e', '4': 'a', '5': 's',
      '7': 't', '@': 'a', r'$': 's', '!': 'i',
    };

    String normalized = text;
    leetMap.forEach((String leet, String normal) {
      normalized = normalized.replaceAll(leet, normal);
    });

    // Check if normalized contains banned words
    for (String word in bannedWords) {
      if (normalized.contains(word)) {
        return word;
      }
    }

    return null;
  }

  // ==================== IMAGE MODERATION ====================
  Future<ImageModerationResult> moderateImage(String imageUrl) async {
    try {
      // Download image
      final http.Response response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode != 200) {
        throw Exception('Failed to download image');
      }

      // Convert to base64
      final String base64Image = base64Encode(response.bodyBytes);

      // Call Google Vision API
      const String apiKey = 'YOUR_GOOGLE_CLOUD_API_KEY';
      const String url = 'https://vision.googleapis.com/v1/images:annotate?key=$apiKey';

      final http.Response visionResponse = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'requests': [
            {
              'image': {'content': base64Image},
              'features': [
                {'type': 'SAFE_SEARCH_DETECTION', 'maxResults': 1},
                {'type': 'ADULT', 'maxResults': 1},
                {'type': 'VIOLENCE', 'maxResults': 1},
                {'type': 'MEDICAL', 'maxResults': 1},
                {'type': 'SPOOF', 'maxResults': 1},
              ],
            }
          ],
        }),
      );

      if (visionResponse.statusCode == 200) {
        final data = jsonDecode(visionResponse.body);
        final safeSearch = data['responses'][0]['safeSearchAnnotation'];

        // Check likelihood levels
        final Map<String, int> likelihood = {
          'adult': _getLikelihoodLevel(safeSearch['adult']),
          'violence': _getLikelihoodLevel(safeSearch['violence']),
          'racy': _getLikelihoodLevel(safeSearch['racy']),
          'medical': _getLikelihoodLevel(safeSearch['medical']),
          'spoof': _getLikelihoodLevel(safeSearch['spoof']),
        };

        final bool isSafe = likelihood['adult']! < 3 &&
            likelihood['violence']! < 3 &&
            likelihood['racy']! < 3;

        return ImageModerationResult(
          isSafe: isSafe,
          likelihood: likelihood,
          action: isSafe ? ModerationAction.allow : ModerationAction.block,
        );
      }

      return ImageModerationResult(
        isSafe: true,
        likelihood: {},
        action: ModerationAction.allow,
      );
    } catch (e) {
      debugPrint('Image moderation error: $e');
      return ImageModerationResult(
        isSafe: true,
        likelihood: {},
        action: ModerationAction.allow,
        error: e.toString(),
      );
    }
  }

  int _getLikelihoodLevel(String? likelihood) {
    switch (likelihood) {
      case 'VERY_UNLIKELY': return 0;
      case 'UNLIKELY': return 1;
      case 'POSSIBLE': return 2;
      case 'LIKELY': return 3;
      case 'VERY_LIKELY': return 4;
      default: return 0;
    }
  }

  // ==================== SCREEN RECORDING DETECTION ====================
  Future<bool> detectScreenRecording() async {
    // This requires platform-specific implementation
    // For Flutter, you might need to use MethodChannel
    return false; // Placeholder
  }

  // ==================== REPORT SYSTEM - FIXED ====================

  Future<void> submitReport({
    required String reporterId,
    required String reportedUserId,
    required ReportReason reason,
    String? description,
    List<String>? evidence,
    String? screenRecording,
  }) async {
    try {
      await _supabase.from('reports').insert({
        'reporter_id': reporterId,
        'reported_user_id': reportedUserId,
        'reason': reason.toString().split('.').last,
        'description': description,
        'evidence': evidence,
        'screen_recording': screenRecording,
        'status': 'pending',
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('Error submitting report: $e');
    }
  }

  // ==================== AUTO-MODERATION - FIXED ====================

  Future<void> autoModerateUser(String userId, ModerationResult result) async {
    try {
      if (result.action == ModerationAction.ban) {
        // Auto-ban user - FIXED: আলাদা করে updateQuery
        final updateQuery = _supabase
            .from('users')
            .update({
          'is_banned': true,
          'ban_reason': 'Auto-moderation: Extreme content detected',
          'banned_at': DateTime.now().toIso8601String(),
          'banned_by': 'system',
        });
        await updateQuery.eq('id', userId);

        // Send notification
        await _supabase.from('notifications').insert({
          'user_id': userId,
          'type': 'system',
          'title': 'Account Banned',
          'body': 'Your account has been banned due to violation of community guidelines.',
          'created_at': DateTime.now().toIso8601String(),
        });
      } else if (result.action == ModerationAction.block) {
        // Log the block action
        await _supabase.from('moderation_actions').insert({
          'user_id': userId,
          'action': 'block',
          'reason': 'Content moderation',
          'details': result.foundWords.join(', '),
          'created_at': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      debugPrint('Error in autoModerateUser: $e');
    }
  }

  // ==================== SCREEN RECORDING FOR REPORT ====================

  Future<String?> uploadScreenRecording(String filePath, String reportId) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) return null;

      final fileBytes = await file.readAsBytes();
      final fileName = 'screen_recording_${DateTime.now().millisecondsSinceEpoch}.mp4';
      final path = 'reports/$reportId/$fileName';

      await _supabase.storage
          .from('reports')
          .uploadBinary(path, fileBytes);

      final publicUrl = _supabase.storage
          .from('reports')
          .getPublicUrl(path);

      return publicUrl;
    } catch (e) {
      debugPrint('Error uploading screen recording: $e');
      return null;
    }
  }

  // ==================== GET REPORTS - FIXED ====================

  Stream<List<Report>> getReports({ReportStatus? status}) {
    try {
      final stream = _supabase
          .from('reports')
          .stream(primaryKey: ['id']);

      return stream.map((data) {
        // Manual filtering
        var filteredData = data;

        if (status != null) {
          final statusStr = status.toString().split('.').last;
          filteredData = filteredData.where((item) => item['status'] == statusStr).toList();
        }

        // Sort manually
        filteredData.sort((a, b) {
          final aTime = DateTime.parse(a['created_at'] ?? DateTime.now().toIso8601String());
          final bTime = DateTime.parse(b['created_at'] ?? DateTime.now().toIso8601String());
          return bTime.compareTo(aTime);
        });

        return filteredData.map((item) {
          item['id'] = item['id'].toString();
          return Report.fromJson(item);
        }).toList();
      });
    } catch (e) {
      debugPrint('Error getting reports stream: $e');
      return Stream.value([]);
    }
  }

  /// Get reports as future (non-streaming) - FIXED
  Future<List<Report>> getReportsFuture({ReportStatus? status, int limit = 100}) async {
    try {
      // বেস কোয়েরি তৈরি করুন
      var query = _supabase
          .from('reports')
          .select()
          .order('created_at', ascending: false)
          .limit(limit);

      // যদি status দেওয়া থাকে, তাহলে নতুন কোয়েরি তৈরি করুন
      if (status != null) {
        final statusStr = status.toString().split('.').last;
        // FIXED: নতুন কোয়েরি তৈরি করুন এবং execute করুন
        final response = await _supabase
            .from('reports')
            .select()
            .eq('status', statusStr)
            .order('created_at', ascending: false)
            .limit(limit);

        return response.map((item) {
          item['id'] = item['id'].toString();
          return Report.fromJson(item);
        }).toList();
      } else {
        // status না থাকলে original query execute করুন
        final response = await query;

        return response.map((item) {
          item['id'] = item['id'].toString();
          return Report.fromJson(item);
        }).toList();
      }
    } catch (e) {
      debugPrint('Error getting reports: $e');
      return [];
    }
  }

  // ==================== RESOLVE REPORT - FIXED ====================

  Future<void> resolveReport(String reportId, String resolution) async {
    try {
      final updateQuery = _supabase
          .from('reports')
          .update({
        'status': 'resolved',
        'resolution': resolution,
        'resolved_at': DateTime.now().toIso8601String(),
      });
      await updateQuery.eq('id', reportId);
    } catch (e) {
      debugPrint('Error resolving report: $e');
    }
  }

  /// Update report status - FIXED
  Future<void> updateReportStatus(String reportId, ReportStatus status) async {
    try {
      final statusStr = status.toString().split('.').last;
      final updateQuery = _supabase
          .from('reports')
          .update({
        'status': statusStr,
        'updated_at': DateTime.now().toIso8601String(),
      });
      await updateQuery.eq('id', reportId);
    } catch (e) {
      debugPrint('Error updating report status: $e');
    }
  }

  /// Assign report to moderator - FIXED
  Future<void> assignReport(String reportId, String moderatorId) async {
    try {
      final updateQuery = _supabase
          .from('reports')
          .update({
        'assigned_to': moderatorId,
        'status': 'investigating',
        'assigned_at': DateTime.now().toIso8601String(),
      });
      await updateQuery.eq('id', reportId);
    } catch (e) {
      debugPrint('Error assigning report: $e');
    }
  }

  // ==================== USER MODERATION HISTORY ====================

  /// Get user's moderation history
  Future<List<Map<String, dynamic>>> getUserModerationHistory(String userId) async {
    try {
      final response = await _supabase
          .from('moderation_actions')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(50);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error getting user moderation history: $e');
      return [];
    }
  }

  /// Get user's report history (as reporter)
  Future<List<Map<String, dynamic>>> getUserReportsAsReporter(String userId) async {
    try {
      final response = await _supabase
          .from('reports')
          .select()
          .eq('reporter_id', userId)
          .order('created_at', ascending: false)
          .limit(50);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error getting user reports: $e');
      return [];
    }
  }

  /// Get user's report history (as reported)
  Future<List<Map<String, dynamic>>> getUserReportsAsReported(String userId) async {
    try {
      final response = await _supabase
          .from('reports')
          .select()
          .eq('reported_user_id', userId)
          .order('created_at', ascending: false)
          .limit(50);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error getting user reports: $e');
      return [];
    }
  }

  // ==================== BANNED WORDS MANAGEMENT (ADMIN) ====================

  /// Add banned word
  Future<void> addBannedWord(String word, {bool isExtreme = false}) async {
    try {
      await _supabase.from('banned_words').insert({
        'word': word,
        'is_extreme': isExtreme,
        'added_by': _currentUserId,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('Error adding banned word: $e');
    }
  }

  /// Remove banned word
  Future<void> removeBannedWord(String word) async {
    try {
      await _supabase
          .from('banned_words')
          .delete()
          .eq('word', word);
    } catch (e) {
      debugPrint('Error removing banned word: $e');
    }
  }

  /// Get banned words list from database
  Future<List<String>> getBannedWords() async {
    try {
      final response = await _supabase
          .from('banned_words')
          .select('word, is_extreme')
          .order('created_at');

      return response.map<String>((item) => item['word'] as String).toList();
    } catch (e) {
      debugPrint('Error getting banned words: $e');
      return bannedWords; // Fallback to static list
    }
  }
}

// ==================== MODEL CLASSES ====================

enum ModerationAction {
  allow,
  block,
  ban
}

class ModerationResult {
  final bool isClean;
  final List<String> foundWords;
  final bool hasExtremeContent;
  final ModerationAction action;

  ModerationResult({
    required this.isClean,
    required this.foundWords,
    required this.hasExtremeContent,
    required this.action,
  });
}

class ImageModerationResult {
  final bool isSafe;
  final Map<String, int> likelihood;
  final ModerationAction action;
  final String? error;

  ImageModerationResult({
    required this.isSafe,
    required this.likelihood,
    required this.action,
    this.error,
  });
}

enum ReportReason {
  spam,
  harassment,
  nudity,
  violence,
  hate_speech,
  fake_account,
  illegal,
  other
}

enum ReportStatus {
  pending,
  investigating,
  resolved,
  rejected
}

class Report {
  final String id;
  final String reporterId;
  final String reportedUserId;
  final ReportReason reason;
  final String? description;
  final List<String>? evidence;
  final String? screenRecording;
  final ReportStatus status;
  final DateTime createdAt;
  final String? resolution;
  final DateTime? resolvedAt;
  final String? assignedTo;
  final DateTime? assignedAt;

  Report({
    required this.id,
    required this.reporterId,
    required this.reportedUserId,
    required this.reason,
    required this.status,
    required this.createdAt,
    this.description,
    this.evidence,
    this.screenRecording,
    this.resolution,
    this.resolvedAt,
    this.assignedTo,
    this.assignedAt,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['id']?.toString() ?? '',
      reporterId: json['reporter_id'] ?? json['reporterId'] ?? '',
      reportedUserId: json['reported_user_id'] ?? json['reportedUserId'] ?? '',
      reason: _parseReportReason(json['reason']),
      description: json['description'],
      evidence: json['evidence'] != null
          ? List<String>.from(json['evidence'])
          : null,
      screenRecording: json['screen_recording'] ?? json['screenRecording'],
      status: _parseReportStatus(json['status']),
      createdAt: _parseDate(json['created_at'] ?? json['createdAt']),
      resolution: json['resolution'],
      resolvedAt: _parseDate(json['resolved_at'] ?? json['resolvedAt']),
      assignedTo: json['assigned_to'] ?? json['assignedTo'],
      assignedAt: _parseDate(json['assigned_at'] ?? json['assignedAt']),
    );
  }

  static DateTime _parseDate(dynamic date) {
    if (date == null) return DateTime.now();
    if (date is String) return DateTime.parse(date);
    if (date is DateTime) return date;
    return DateTime.now();
  }

  static ReportReason _parseReportReason(String? reason) {
    if (reason == null) return ReportReason.other;
    switch (reason.toLowerCase()) {
      case 'spam':
        return ReportReason.spam;
      case 'harassment':
        return ReportReason.harassment;
      case 'nudity':
        return ReportReason.nudity;
      case 'violence':
        return ReportReason.violence;
      case 'hate_speech':
        return ReportReason.hate_speech;
      case 'fake_account':
        return ReportReason.fake_account;
      case 'illegal':
        return ReportReason.illegal;
      default:
        return ReportReason.other;
    }
  }

  static ReportStatus _parseReportStatus(String? status) {
    if (status == null) return ReportStatus.pending;
    switch (status.toLowerCase()) {
      case 'pending':
        return ReportStatus.pending;
      case 'investigating':
        return ReportStatus.investigating;
      case 'resolved':
        return ReportStatus.resolved;
      case 'rejected':
        return ReportStatus.rejected;
      default:
        return ReportStatus.pending;
    }
  }
}