class ReportModel {
  String id;
  String reporterId;
  String reportedUserId;
  String reason;
  String? description;
  List<String>? evidence;       // screenshot URLs
  String? screenRecording;
  ReportStatus status;          // pending, resolved, rejected
  DateTime timestamp;
  String? resolvedBy;
  DateTime? resolvedAt;
}