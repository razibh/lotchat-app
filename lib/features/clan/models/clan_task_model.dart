enum TaskType { daily, weekly, monthly, special, event }
enum TaskCategory { activity, donation, war, chat, gift, game }
enum TaskDifficulty { easy, medium, hard, expert, legendary }
enum TaskStatus { locked, available, inProgress, completed, claimed }

class ClanTaskModel {

  ClanTaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.category,
    required this.difficulty,
    required this.xpReward,
    required this.coinReward,
    required this.requirements, required this.progress, required this.target, required this.status, this.gemReward,
    this.badgeReward,
    this.startDate,
    this.endDate,
    this.isRepeatable = false,
    this.repeatCooldown,
    this.requiredLevel,
    this.requiredTasks,
    this.metadata = const <String, dynamic>{},
  });

  factory ClanTaskModel.fromJson(Map<String, dynamic> json) {
    return ClanTaskModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      type: TaskType.values[json['type']],
      category: TaskCategory.values[json['category']],
      difficulty: TaskDifficulty.values[json['difficulty']],
      xpReward: json['xpReward'],
      coinReward: json['coinReward'],
      gemReward: json['gemReward'],
      badgeReward: json['badgeReward'],
      requirements: json['requirements'] ?? <String, dynamic>{},
      progress: json['progress'] ?? 0,
      target: json['target'],
      status: TaskStatus.values[json['status']],
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'])
          : null,
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'])
          : null,
      isRepeatable: json['isRepeatable'] ?? false,
      repeatCooldown: json['repeatCooldown'],
      requiredLevel: json['requiredLevel'],
      requiredTasks: json['requiredTasks']?.cast<String>(),
      metadata: json['metadata'] ?? <String, dynamic>{},
    );
  }
  final String id;
  final String title;
  final String description;
  final TaskType type;
  final TaskCategory category;
  final TaskDifficulty difficulty;
  final int xpReward;
  final int coinReward;
  final int? gemReward;
  final String? badgeReward;
  final Map<String, dynamic> requirements;
  final int progress;
  final int target;
  final TaskStatus status;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isRepeatable;
  final int? repeatCooldown; // in hours
  final int? requiredLevel;
  final List<String>? requiredTasks;
  final Map<String, dynamic> metadata;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'title': title,
    'description': description,
    'type': type.index,
    'category': category.index,
    'difficulty': difficulty.index,
    'xpReward': xpReward,
    'coinReward': coinReward,
    'gemReward': gemReward,
    'badgeReward': badgeReward,
    'requirements': requirements,
    'progress': progress,
    'target': target,
    'status': status.index,
    'startDate': startDate?.toIso8601String(),
    'endDate': endDate?.toIso8601String(),
    'isRepeatable': isRepeatable,
    'repeatCooldown': repeatCooldown,
    'requiredLevel': requiredLevel,
    'requiredTasks': requiredTasks,
    'metadata': metadata,
  };

  // Computed properties
  double get progressPercentage => progress / target;
  
  bool get isCompleted => progress >= target;
  
  bool get isClaimable => isCompleted && status == TaskStatus.completed;
  
  bool get isExpired => endDate != null && DateTime.now().isAfter(endDate!);
  
  bool get isAvailable {
    if (status != TaskStatus.locked) return false;
    if (isExpired) return false;
    if (startDate != null && DateTime.now().isBefore(startDate!)) return false;
    return true;
  }

  String get timeRemaining {
    if (endDate == null) return 'No time limit';
    
    final Duration remaining = endDate!.difference(DateTime.now());
    
    if (remaining.inDays > 0) {
      return '${remaining.inDays}d ${remaining.inHours % 24}h';
    } else if (remaining.inHours > 0) {
      return '${remaining.inHours}h ${remaining.inMinutes % 60}m';
    } else if (remaining.inMinutes > 0) {
      return '${remaining.inMinutes}m';
    } else {
      return 'Expired';
    }
  }

  Color get difficultyColor {
    switch (difficulty) {
      case TaskDifficulty.easy:
        return const Color(0xFF10B981); // Green
      case TaskDifficulty.medium:
        return const Color(0xFFF59E0B); // Orange
      case TaskDifficulty.hard:
        return const Color(0xFFEF4444); // Red
      case TaskDifficulty.expert:
        return const Color(0xFF8B5CF6); // Purple
      case TaskDifficulty.legendary:
        return const Color(0xFFFFD700); // Gold
    }
  }

  IconData get categoryIcon {
    switch (category) {
      case TaskCategory.activity:
        return Icons.flash_on;
      case TaskCategory.donation:
        return Icons.attach_money;
      case TaskCategory.war:
        return Icons.emoji_events;
      case TaskCategory.chat:
        return Icons.chat;
      case TaskCategory.gift:
        return Icons.card_giftcard;
      case TaskCategory.game:
        return Icons.sports_esports;
    }
  }

  // Update progress
  ClanTaskModel updateProgress(int newProgress) {
    final int updatedProgress = progress + newProgress;
    final TaskStatus newStatus = updatedProgress >= target 
        ? TaskStatus.completed 
        : TaskStatus.inProgress;
    
    return copyWith(
      progress: updatedProgress.clamp(0, target),
      status: newStatus,
    );
  }

  // Claim task
  ClanTaskModel claim() {
    if (!isClaimable) return this;
    
    return copyWith(
      status: TaskStatus.claimed,
    );
  }

  // Reset for repeatable tasks
  ClanTaskModel reset() {
    if (!isRepeatable) return this;
    
    return copyWith(
      progress: 0,
      status: TaskStatus.available,
    );
  }

  // Copy with modifications
  ClanTaskModel copyWith({
    String? id,
    String? title,
    String? description,
    TaskType? type,
    TaskCategory? category,
    TaskDifficulty? difficulty,
    int? xpReward,
    int? coinReward,
    int? gemReward,
    String? badgeReward,
    Map<String, dynamic>? requirements,
    int? progress,
    int? target,
    TaskStatus? status,
    DateTime? startDate,
    DateTime? endDate,
    bool? isRepeatable,
    int? repeatCooldown,
    int? requiredLevel,
    List<String>? requiredTasks,
    Map<String, dynamic>? metadata,
  }) {
    return ClanTaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      category: category ?? this.category,
      difficulty: difficulty ?? this.difficulty,
      xpReward: xpReward ?? this.xpReward,
      coinReward: coinReward ?? this.coinReward,
      gemReward: gemReward ?? this.gemReward,
      badgeReward: badgeReward ?? this.badgeReward,
      requirements: requirements ?? this.requirements,
      progress: progress ?? this.progress,
      target: target ?? this.target,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isRepeatable: isRepeatable ?? this.isRepeatable,
      repeatCooldown: repeatCooldown ?? this.repeatCooldown,
      requiredLevel: requiredLevel ?? this.requiredLevel,
      requiredTasks: requiredTasks ?? this.requiredTasks,
      metadata: metadata ?? this.metadata,
    );
  }
}

class ClanTaskProgress {

  ClanTaskProgress({
    required this.taskId,
    required this.userId,
    required this.progress,
    required this.lastUpdated,
    this.completedAt,
    this.claimedAt,
  });

  factory ClanTaskProgress.fromJson(Map<String, dynamic> json) {
    return ClanTaskProgress(
      taskId: json['taskId'],
      userId: json['userId'],
      progress: json['progress'],
      lastUpdated: DateTime.parse(json['lastUpdated']),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
      claimedAt: json['claimedAt'] != null
          ? DateTime.parse(json['claimedAt'])
          : null,
    );
  }
  final String taskId;
  final String userId;
  final int progress;
  final DateTime lastUpdated;
  final DateTime? completedAt;
  final DateTime? claimedAt;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'taskId': taskId,
    'userId': userId,
    'progress': progress,
    'lastUpdated': lastUpdated.toIso8601String(),
    'completedAt': completedAt?.toIso8601String(),
    'claimedAt': claimedAt?.toIso8601String(),
  };

  bool get isCompleted => progress >= 100;
  bool get isClaimed => claimedAt != null;
}