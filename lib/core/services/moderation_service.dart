import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ModerationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  
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

  // ==================== TEXT MODERATION ====================
  ModerationResult moderateText(String text) {
    final lowerText = text.toLowerCase();
    final words = lowerText.split(RegExp(r'\s+'));
    
    List<String> foundBannedWords = [];
    bool hasExtreme = false;
    
    // Check each word
    for (var word in words) {
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
    final leetPattern = _checkLeetspeak(lowerText);
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
    final leetMap = {
      r'0': 'o', r'1': 'i', r'3': 'e', r'4': 'a', r'5': 's',
      r'7': 't', r'@': 'a', r'$': 's', r'!': 'i',
    };
    
    String normalized = text;
    leetMap.forEach((leet, normal) {
      normalized = normalized.replaceAll(leet, normal);
    });
    
    // Check if normalized contains banned words
    for (var word in bannedWords) {
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
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode != 200) {
        throw Exception('Failed to download image');
      }
      
      // Convert to base64
      final base64Image = base64Encode(response.bodyBytes);
      
      // Call Google Vision API
      final apiKey = 'YOUR_GOOGLE_CLOUD_API_KEY';
      final url = 'https://vision.googleapis.com/v1/images:annotate?key=$apiKey';
      
      final visionResponse = await http.post(
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
        final likelihood = {
          'adult': _getLikelihoodLevel(safeSearch['adult']),
          'violence': _getLikelihoodLevel(safeSearch['violence']),
          'racy': _getLikelihoodLevel(safeSearch['racy']),
          'medical': _getLikelihoodLevel(safeSearch['medical']),
          'spoof': _getLikelihoodLevel(safeSearch['spoof']),
        };
        
        bool isSafe = likelihood['adult']! < 3 &&
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
      print('Image moderation error: $e');
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

  // ==================== REPORT SYSTEM ====================
  Future<void> submitReport({
    required String reporterId,
    required String reportedUserId,
    required ReportReason reason,
    String? description,
    List<String>? evidence,
    String? screenRecording,
  }) async {
    await _firestore.collection('reports').add({
      'reporterId': reporterId,
      'reportedUserId': reportedUserId,
      'reason': reason.toString(),
      'description': description,
      'evidence': evidence,
      'screenRecording': screenRecording,
      'status': 'pending',
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // ==================== AUTO-MODERATION ====================
  Future<void> autoModerateUser(String userId, ModerationResult result) async {
    if (result.action == ModerationAction.ban) {
      // Auto-ban user
      await _firestore.collection('users').doc(userId).update({
        'isBanned': true,
        'banReason': 'Auto-moderation: Extreme content detected',
        'bannedAt': FieldValue.serverTimestamp(),
        'bannedBy': 'system',
      });
      
      // Send notification
      await _firestore.collection('notifications').add({
        'userId': userId,
        'type': 'system',
        'title': 'Account Banned',
        'body': 'Your account has been banned due to violation of community guidelines.',
        'timestamp': FieldValue.serverTimestamp(),
      });
    } else if (result.action == ModerationAction.block) {
      // Just block the content, don't ban user
      // Implementation depends on what was being moderated
    }
  }

  // ==================== SCREEN RECORDING FOR REPORT ====================
  Future<String?> uploadScreenRecording(String filePath, String reportId) async {
    try {
      final ref = _storage.ref().child('reports/$reportId/screen_recording.mp4');
      await ref.putFile(File(filePath));
      return await ref.getDownloadURL();
    } catch (e) {
      print('Error uploading screen recording: $e');
      return null;
    }
  }

  // ==================== GET REPORTS ====================
  Stream<List<Report>> getReports({ReportStatus? status}) {
    Query query = _firestore.collection('reports').orderBy('timestamp', descending: true);
    
    if (status != null) {
      query = query.where('status', isEqualTo: status.toString());
    }
    
    return query.snapshots().map((snapshot) => snapshot.docs
        .map((doc) => Report.fromJson(doc.data(), doc.id))
        .toList());
  }

  // ==================== RESOLVE REPORT ====================
  Future<void> resolveReport(String reportId, String resolution) async {
    await _firestore.collection('reports').doc(reportId).update({
      'status': 'resolved',
      'resolution': resolution,
      'resolvedAt': FieldValue.serverTimestamp(),
    });
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
  final DateTime timestamp;
  final String? resolution;
  final DateTime? resolvedAt;
  
  Report({
    required this.id,
    required this.reporterId,
    required this.reportedUserId,
    required this.reason,
    this.description,
    this.evidence,
    this.screenRecording,
    required this.status,
    required this.timestamp,
    this.resolution,
    this.resolvedAt,
  });
  
  factory Report.fromJson(Map<String, dynamic> json, String id) {
    return Report(
      id: id,
      reporterId: json['reporterId'] ?? '',
      reportedUserId: json['reportedUserId'] ?? '',
      reason: ReportReason.values.firstWhere(
        (e) => e.toString() == json['reason'],
        orElse: () => ReportReason.other,
      ),
      description: json['description'],
      evidence: json['evidence']?.cast<String>(),
      screenRecording: json['screenRecording'],
      status: ReportStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
        orElse: () => ReportStatus.pending,
      ),
      timestamp: (json['timestamp'] as Timestamp).toDate(),
      resolution: json['resolution'],
      resolvedAt: json['resolvedAt'] != null 
          ? (json['resolvedAt'] as Timestamp).toDate() 
          : null,
    );
  }
}