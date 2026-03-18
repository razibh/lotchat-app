// lib/core/models/report_model.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart'; // Color এর জন্য

enum ReportStatus {
  pending,
  resolved,
  rejected,
  underReview,
  investigating,
  closed,
}

enum ReportType {
  user,
  message,
  room,
  comment,
  gift,
  game,
  clan,
  other,
}

enum ReportPriority {
  low,
  normal,
  high,
  urgent,
  critical,
}

class ReportModel {
  final String id;
  final String reporterId;
  final String reportedUserId;
  final String reason;
  final String? description;
  final List<String>? evidence;       // screenshot URLs
  final String? screenRecording;
  final ReportStatus status;          // pending, resolved, rejected
  final DateTime timestamp;
  final String? resolvedBy;
  final DateTime? resolvedAt;

  // Additional fields
  final String? reportedUserName;
  final String? reportedUserAvatar;
  final String? reporterName;
  final String? reporterAvatar;
  final ReportType type;
  final ReportPriority priority;
  final String? targetId; // ID of reported content (message, room, etc.)
  final String? targetType; // 'message', 'room', 'comment', etc.
  final Map<String, dynamic>? context; // Additional context data
  final List<String>? actionTaken;
  final String? adminNotes;
  final int? reviewCount;
  final List<String>? reviewers;
  final DateTime? underReviewAt;
  final DateTime? lastUpdatedAt;
  final Map<String, dynamic>? metadata;

  ReportModel({
    required this.id,
    required this.reporterId,
    required this.reportedUserId,
    required this.reason,
    required this.timestamp,
    this.description,
    this.evidence,
    this.screenRecording,
    this.status = ReportStatus.pending,
    this.resolvedBy,
    this.resolvedAt,
    this.reportedUserName,
    this.reportedUserAvatar,
    this.reporterName,
    this.reporterAvatar,
    this.type = ReportType.user,
    this.priority = ReportPriority.normal,
    this.targetId,
    this.targetType,
    this.context,
    this.actionTaken,
    this.adminNotes,
    this.reviewCount = 0,
    this.reviewers,
    this.underReviewAt,
    this.lastUpdatedAt,
    this.metadata,
  });

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      id: json['id'] ?? '',
      reporterId: json['reporterId'] ?? '',
      reportedUserId: json['reportedUserId'] ?? '',
      reason: json['reason'] ?? '',
      description: json['description'],
      evidence: json['evidence'] != null
          ? List<String>.from(json['evidence'])
          : null,
      screenRecording: json['screenRecording'],
      status: _parseReportStatus(json['status']),
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
      resolvedBy: json['resolvedBy'],
      resolvedAt: json['resolvedAt'] != null
          ? DateTime.parse(json['resolvedAt'])
          : null,
      reportedUserName: json['reportedUserName'],
      reportedUserAvatar: json['reportedUserAvatar'],
      reporterName: json['reporterName'],
      reporterAvatar: json['reporterAvatar'],
      type: _parseReportType(json['type']),
      priority: _parseReportPriority(json['priority']),
      targetId: json['targetId'],
      targetType: json['targetType'],
      context: json['context'],
      actionTaken: json['actionTaken'] != null
          ? List<String>.from(json['actionTaken'])
          : null,
      adminNotes: json['adminNotes'],
      reviewCount: json['reviewCount'] ?? 0,
      reviewers: json['reviewers'] != null
          ? List<String>.from(json['reviewers'])
          : null,
      underReviewAt: json['underReviewAt'] != null
          ? DateTime.parse(json['underReviewAt'])
          : null,
      lastUpdatedAt: json['lastUpdatedAt'] != null
          ? DateTime.parse(json['lastUpdatedAt'])
          : null,
      metadata: json['metadata'],
    );
  }

  static ReportStatus _parseReportStatus(String? status) {
    if (status == null) return ReportStatus.pending;
    switch (status.toLowerCase()) {
      case 'pending':
        return ReportStatus.pending;
      case 'resolved':
        return ReportStatus.resolved;
      case 'rejected':
        return ReportStatus.rejected;
      case 'underreview':
      case 'under_review':
        return ReportStatus.underReview;
      case 'investigating':
        return ReportStatus.investigating;
      case 'closed':
        return ReportStatus.closed;
      default:
        return ReportStatus.pending;
    }
  }

  static ReportType _parseReportType(String? type) {
    if (type == null) return ReportType.user;
    switch (type.toLowerCase()) {
      case 'user':
        return ReportType.user;
      case 'message':
        return ReportType.message;
      case 'room':
        return ReportType.room;
      case 'comment':
        return ReportType.comment;
      case 'gift':
        return ReportType.gift;
      case 'game':
        return ReportType.game;
      case 'clan':
        return ReportType.clan;
      case 'other':
        return ReportType.other;
      default:
        return ReportType.other;
    }
  }

  static ReportPriority _parseReportPriority(String? priority) {
    if (priority == null) return ReportPriority.normal;
    switch (priority.toLowerCase()) {
      case 'low':
        return ReportPriority.low;
      case 'normal':
        return ReportPriority.normal;
      case 'high':
        return ReportPriority.high;
      case 'urgent':
        return ReportPriority.urgent;
      case 'critical':
        return ReportPriority.critical;
      default:
        return ReportPriority.normal;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reporterId': reporterId,
      'reportedUserId': reportedUserId,
      'reason': reason,
      'description': description,
      'evidence': evidence,
      'screenRecording': screenRecording,
      'status': status.toString().split('.').last,
      'timestamp': timestamp.toIso8601String(),
      'resolvedBy': resolvedBy,
      'resolvedAt': resolvedAt?.toIso8601String(),
      'reportedUserName': reportedUserName,
      'reportedUserAvatar': reportedUserAvatar,
      'reporterName': reporterName,
      'reporterAvatar': reporterAvatar,
      'type': type.toString().split('.').last,
      'priority': priority.toString().split('.').last,
      'targetId': targetId,
      'targetType': targetType,
      'context': context,
      'actionTaken': actionTaken,
      'adminNotes': adminNotes,
      'reviewCount': reviewCount,
      'reviewers': reviewers,
      'underReviewAt': underReviewAt?.toIso8601String(),
      'lastUpdatedAt': lastUpdatedAt?.toIso8601String(),
      'metadata': metadata,
    };
  }

  ReportModel copyWith({
    String? id,
    String? reporterId,
    String? reportedUserId,
    String? reason,
    String? description,
    List<String>? evidence,
    String? screenRecording,
    ReportStatus? status,
    DateTime? timestamp,
    String? resolvedBy,
    DateTime? resolvedAt,
    String? reportedUserName,
    String? reportedUserAvatar,
    String? reporterName,
    String? reporterAvatar,
    ReportType? type,
    ReportPriority? priority,
    String? targetId,
    String? targetType,
    Map<String, dynamic>? context,
    List<String>? actionTaken,
    String? adminNotes,
    int? reviewCount,
    List<String>? reviewers,
    DateTime? underReviewAt,
    DateTime? lastUpdatedAt,
    Map<String, dynamic>? metadata,
  }) {
    return ReportModel(
      id: id ?? this.id,
      reporterId: reporterId ?? this.reporterId,
      reportedUserId: reportedUserId ?? this.reportedUserId,
      reason: reason ?? this.reason,
      description: description ?? this.description,
      evidence: evidence ?? this.evidence,
      screenRecording: screenRecording ?? this.screenRecording,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
      resolvedBy: resolvedBy ?? this.resolvedBy,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      reportedUserName: reportedUserName ?? this.reportedUserName,
      reportedUserAvatar: reportedUserAvatar ?? this.reportedUserAvatar,
      reporterName: reporterName ?? this.reporterName,
      reporterAvatar: reporterAvatar ?? this.reporterAvatar,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      targetId: targetId ?? this.targetId,
      targetType: targetType ?? this.targetType,
      context: context ?? this.context,
      actionTaken: actionTaken ?? this.actionTaken,
      adminNotes: adminNotes ?? this.adminNotes,
      reviewCount: reviewCount ?? this.reviewCount,
      reviewers: reviewers ?? this.reviewers,
      underReviewAt: underReviewAt ?? this.underReviewAt,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
      metadata: metadata ?? this.metadata,
    );
  }

  // Helper getters
  bool get isPending => status == ReportStatus.pending;
  bool get isResolved => status == ReportStatus.resolved;
  bool get isRejected => status == ReportStatus.rejected;
  bool get isUnderReview => status == ReportStatus.underReview;
  bool get isInvestigating => status == ReportStatus.investigating;
  bool get isClosed => status == ReportStatus.closed;

  bool get hasEvidence => evidence != null && evidence!.isNotEmpty;
  bool get hasScreenRecording => screenRecording != null && screenRecording!.isNotEmpty;
  bool get hasActionTaken => actionTaken != null && actionTaken!.isNotEmpty;

  int get evidenceCount => evidence?.length ?? 0;

  Duration get timeSinceReport {
    return DateTime.now().difference(timestamp);
  }

  Duration? get timeToResolution {
    if (resolvedAt == null) return null;
    return resolvedAt!.difference(timestamp);
  }

  String get timeAgo {
    final diff = timeSinceReport;
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }

  // Status color
  Color get statusColor {
    switch (status) {
      case ReportStatus.pending:
        return Colors.orange;
      case ReportStatus.resolved:
        return Colors.green;
      case ReportStatus.rejected:
        return Colors.red;
      case ReportStatus.underReview:
        return Colors.blue;
      case ReportStatus.investigating:
        return Colors.purple;
      case ReportStatus.closed:
        return Colors.grey;
    }
  }

  // Priority color
  Color get priorityColor {
    switch (priority) {
      case ReportPriority.low:
        return Colors.green;
      case ReportPriority.normal:
        return Colors.blue;
      case ReportPriority.high:
        return Colors.orange;
      case ReportPriority.urgent:
        return Colors.red;
      case ReportPriority.critical:
        return Colors.purple;
    }
  }

  // Resolve the report
  ReportModel resolve(String adminId, {String? action, String? notes}) {
    return copyWith(
      status: ReportStatus.resolved,
      resolvedBy: adminId,
      resolvedAt: DateTime.now(),
      actionTaken: action != null ? [action] : null,
      adminNotes: notes ?? adminNotes,
      lastUpdatedAt: DateTime.now(),
    );
  }

  // Reject the report
  ReportModel reject(String adminId, {String? reason, String? notes}) {
    return copyWith(
      status: ReportStatus.rejected,
      resolvedBy: adminId,
      resolvedAt: DateTime.now(),
      adminNotes: notes ?? adminNotes,
      lastUpdatedAt: DateTime.now(),
    );
  }

  // Start review
  ReportModel startReview(String reviewerId) {
    final updatedReviewers = List<String>.from(reviewers ?? [])..add(reviewerId);

    return copyWith(
      status: ReportStatus.underReview,
      underReviewAt: DateTime.now(),
      reviewers: updatedReviewers,
      reviewCount: (reviewCount ?? 0) + 1,
      lastUpdatedAt: DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'ReportModel(id: $id, reporter: $reporterId, reported: $reportedUserId, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ReportModel &&
        other.id == id &&
        other.reporterId == reporterId &&
        other.reportedUserId == reportedUserId;
  }

  @override
  int get hashCode => Object.hash(id, reporterId, reportedUserId);
}