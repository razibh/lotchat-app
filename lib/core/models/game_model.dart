// lib/core/models/game_model.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart'; // Color এর জন্য

enum GameType {
  roulette,
  threePatti,
  ludo,
  carrom,
  greedyCat,
  werewolf,
  trivia,
  pictionary,
  chess,
  snakeLadder,
  poker,
  blackjack,
  slot,
  dice,
  custom,
}

enum GameStatus {
  active,
  inactive,
  maintenance,
  comingSoon,
}

enum GameDifficulty {
  beginner,
  easy,
  medium,
  hard,
  expert,
}

class GameModel {
  final String id;
  final String name;                  // Roulette, 3 Patti, Ludo etc.
  final GameType type;
  final int minBet;
  final int maxBet;
  final double winRate;
  final Map<String, dynamic> rules;
  final String? animationPath;

  // Additional fields
  final String? description;
  final String? iconPath;
  final String? bannerPath;
  final String? thumbnailPath;
  final GameStatus status;
  final GameDifficulty difficulty;
  final int maxPlayers;
  final int minPlayers;
  final Duration averageGameTime;
  final bool isMultiplayer;
  final bool isSinglePlayer;
  final bool isFree;
  final int entryFee;
  final Map<String, dynamic>? prizes;
  final Map<String, dynamic>? leaderboard;
  final List<String>? achievements;
  final Map<String, dynamic>? settings;
  final List<String>? tutorials;
  final Map<String, dynamic>? statistics;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isActive;

  GameModel({
    required this.id,
    required this.name,
    required this.type,
    required this.minBet,
    required this.maxBet,
    required this.winRate,
    required this.rules,
    this.animationPath,
    this.description,
    this.iconPath,
    this.bannerPath,
    this.thumbnailPath,
    this.status = GameStatus.active,
    this.difficulty = GameDifficulty.medium,
    this.maxPlayers = 2,
    this.minPlayers = 2,
    this.averageGameTime = const Duration(minutes: 5),
    this.isMultiplayer = true,
    this.isSinglePlayer = false,
    this.isFree = true,
    this.entryFee = 0,
    this.prizes,
    this.leaderboard,
    this.achievements,
    this.settings,
    this.tutorials,
    this.statistics,
    this.createdAt,
    this.updatedAt,
    this.isActive = true,
  });

  factory GameModel.fromJson(Map<String, dynamic> json) {
    return GameModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      type: _parseGameType(json['type']),
      minBet: json['minBet'] ?? 0,
      maxBet: json['maxBet'] ?? 0,
      winRate: (json['winRate'] ?? 0.0).toDouble(),
      rules: json['rules'] ?? {},
      animationPath: json['animationPath'],
      description: json['description'],
      iconPath: json['iconPath'],
      bannerPath: json['bannerPath'],
      thumbnailPath: json['thumbnailPath'],
      status: _parseGameStatus(json['status']),
      difficulty: _parseGameDifficulty(json['difficulty']),
      maxPlayers: json['maxPlayers'] ?? 2,
      minPlayers: json['minPlayers'] ?? 2,
      averageGameTime: json['averageGameTime'] != null
          ? Duration(seconds: json['averageGameTime'])
          : const Duration(minutes: 5),
      isMultiplayer: json['isMultiplayer'] ?? true,
      isSinglePlayer: json['isSinglePlayer'] ?? false,
      isFree: json['isFree'] ?? true,
      entryFee: json['entryFee'] ?? 0,
      prizes: json['prizes'],
      leaderboard: json['leaderboard'],
      achievements: json['achievements'] != null
          ? List<String>.from(json['achievements'])
          : null,
      settings: json['settings'],
      tutorials: json['tutorials'] != null
          ? List<String>.from(json['tutorials'])
          : null,
      statistics: json['statistics'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
      isActive: json['isActive'] ?? true,
    );
  }

  static GameType _parseGameType(String? type) {
    if (type == null) return GameType.custom;
    switch (type.toLowerCase()) {
      case 'roulette':
        return GameType.roulette;
      case 'threepatti':
      case '3patti':
      case 'three_patti':
        return GameType.threePatti;
      case 'ludo':
        return GameType.ludo;
      case 'carrom':
        return GameType.carrom;
      case 'greedycat':
      case 'greedy_cat':
        return GameType.greedyCat;
      case 'werewolf':
        return GameType.werewolf;
      case 'trivia':
        return GameType.trivia;
      case 'pictionary':
        return GameType.pictionary;
      case 'chess':
        return GameType.chess;
      case 'snakeladder':
      case 'snake_ladder':
        return GameType.snakeLadder;
      case 'poker':
        return GameType.poker;
      case 'blackjack':
        return GameType.blackjack;
      case 'slot':
        return GameType.slot;
      case 'dice':
        return GameType.dice;
      default:
        return GameType.custom;
    }
  }

  static GameStatus _parseGameStatus(String? status) {
    if (status == null) return GameStatus.active;
    switch (status.toLowerCase()) {
      case 'active':
        return GameStatus.active;
      case 'inactive':
        return GameStatus.inactive;
      case 'maintenance':
        return GameStatus.maintenance;
      case 'comingsoon':
      case 'coming_soon':
        return GameStatus.comingSoon;
      default:
        return GameStatus.active;
    }
  }

  static GameDifficulty _parseGameDifficulty(String? difficulty) {
    if (difficulty == null) return GameDifficulty.medium;
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        return GameDifficulty.beginner;
      case 'easy':
        return GameDifficulty.easy;
      case 'medium':
        return GameDifficulty.medium;
      case 'hard':
        return GameDifficulty.hard;
      case 'expert':
        return GameDifficulty.expert;
      default:
        return GameDifficulty.medium;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.toString().split('.').last,
      'minBet': minBet,
      'maxBet': maxBet,
      'winRate': winRate,
      'rules': rules,
      'animationPath': animationPath,
      'description': description,
      'iconPath': iconPath,
      'bannerPath': bannerPath,
      'thumbnailPath': thumbnailPath,
      'status': status.toString().split('.').last,
      'difficulty': difficulty.toString().split('.').last,
      'maxPlayers': maxPlayers,
      'minPlayers': minPlayers,
      'averageGameTime': averageGameTime.inSeconds,
      'isMultiplayer': isMultiplayer,
      'isSinglePlayer': isSinglePlayer,
      'isFree': isFree,
      'entryFee': entryFee,
      'prizes': prizes,
      'leaderboard': leaderboard,
      'achievements': achievements,
      'settings': settings,
      'tutorials': tutorials,
      'statistics': statistics,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'isActive': isActive,
    };
  }

  GameModel copyWith({
    String? id,
    String? name,
    GameType? type,
    int? minBet,
    int? maxBet,
    double? winRate,
    Map<String, dynamic>? rules,
    String? animationPath,
    String? description,
    String? iconPath,
    String? bannerPath,
    String? thumbnailPath,
    GameStatus? status,
    GameDifficulty? difficulty,
    int? maxPlayers,
    int? minPlayers,
    Duration? averageGameTime,
    bool? isMultiplayer,
    bool? isSinglePlayer,
    bool? isFree,
    int? entryFee,
    Map<String, dynamic>? prizes,
    Map<String, dynamic>? leaderboard,
    List<String>? achievements,
    Map<String, dynamic>? settings,
    List<String>? tutorials,
    Map<String, dynamic>? statistics,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return GameModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      minBet: minBet ?? this.minBet,
      maxBet: maxBet ?? this.maxBet,
      winRate: winRate ?? this.winRate,
      rules: rules ?? this.rules,
      animationPath: animationPath ?? this.animationPath,
      description: description ?? this.description,
      iconPath: iconPath ?? this.iconPath,
      bannerPath: bannerPath ?? this.bannerPath,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      status: status ?? this.status,
      difficulty: difficulty ?? this.difficulty,
      maxPlayers: maxPlayers ?? this.maxPlayers,
      minPlayers: minPlayers ?? this.minPlayers,
      averageGameTime: averageGameTime ?? this.averageGameTime,
      isMultiplayer: isMultiplayer ?? this.isMultiplayer,
      isSinglePlayer: isSinglePlayer ?? this.isSinglePlayer,
      isFree: isFree ?? this.isFree,
      entryFee: entryFee ?? this.entryFee,
      prizes: prizes ?? this.prizes,
      leaderboard: leaderboard ?? this.leaderboard,
      achievements: achievements ?? this.achievements,
      settings: settings ?? this.settings,
      tutorials: tutorials ?? this.tutorials,
      statistics: statistics ?? this.statistics,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }

  // Helper getters
  bool get isBettable => minBet > 0 && maxBet > 0;
  bool get hasEntryFee => entryFee > 0;
  bool get hasPrizes => prizes != null && prizes!.isNotEmpty;
  bool get hasLeaderboard => leaderboard != null && leaderboard!.isNotEmpty;

  String get betRange => '$minBet - $maxBet coins';

  Color get difficultyColor {
    switch (difficulty) {
      case GameDifficulty.beginner:
        return Colors.green;
      case GameDifficulty.easy:
        return Colors.lightGreen;
      case GameDifficulty.medium:
        return Colors.orange;
      case GameDifficulty.hard:
        return Colors.red;
      case GameDifficulty.expert:
        return Colors.purple;
    }
  }

  String get difficultyName {
    switch (difficulty) {
      case GameDifficulty.beginner:
        return 'Beginner';
      case GameDifficulty.easy:
        return 'Easy';
      case GameDifficulty.medium:
        return 'Medium';
      case GameDifficulty.hard:
        return 'Hard';
      case GameDifficulty.expert:
        return 'Expert';
    }
  }

  // Validate bet amount
  bool isValidBet(int bet) {
    return bet >= minBet && bet <= maxBet;
  }

  // Calculate potential winnings
  int calculateWinnings(int bet) {
    return (bet * winRate).round();
  }

  // Check if game is playable
  bool canPlay(int currentPlayers) {
    if (status != GameStatus.active) return false;
    if (!isActive) return false;
    if (currentPlayers < minPlayers) return false;
    if (currentPlayers >= maxPlayers) return false;
    return true;
  }

  @override
  String toString() {
    return 'GameModel(id: $id, name: $name, type: $type, players: $minPlayers-$maxPlayers)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GameModel &&
        other.id == id &&
        other.name == name &&
        other.type == type;
  }

  @override
  int get hashCode => Object.hash(id, name, type);
}