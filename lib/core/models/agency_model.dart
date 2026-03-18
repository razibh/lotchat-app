// lib/core/models/agency_model.dart

import 'package:flutter/foundation.dart';

enum AgencyStatus {
  active,
  suspended,
  inactive,
  pending,
  verified,
}

class AgencyModel {
  final String id;
  final String name;
  final String ownerId;
  final String ownerName;
  final List<String> memberIds;
  final Map<String, int> memberEarnings;
  final int totalEarnings;
  final double commissionRate;
  final DateTime createdAt;
  final AgencyStatus status;

  // Optional fields
  final String? logo;
  final String? description;
  final DateTime? updatedAt;

  AgencyModel({
    required this.id,
    required this.name,
    required this.ownerId,
    required this.ownerName,
    this.memberIds = const [],
    this.memberEarnings = const {},
    this.totalEarnings = 0,
    this.commissionRate = 0.1, // default 10%
    required this.createdAt,
    this.status = AgencyStatus.pending,
    this.logo,
    this.description,
    this.updatedAt,
  });

  factory AgencyModel.fromJson(Map<String, dynamic> json) {
    return AgencyModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      ownerId: json['ownerId'] ?? '',
      ownerName: json['ownerName'] ?? '',
      memberIds: List<String>.from(json['memberIds'] ?? []),
      memberEarnings: _parseMemberEarnings(json['memberEarnings']),
      totalEarnings: json['totalEarnings'] ?? 0,
      commissionRate: (json['commissionRate'] ?? 0.1).toDouble(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      status: _parseAgencyStatus(json['status']),
      logo: json['logo'],
      description: json['description'],
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  static Map<String, int> _parseMemberEarnings(dynamic earnings) {
    if (earnings == null) return {};
    if (earnings is Map) {
      return earnings.map((key, value) => MapEntry(key.toString(), value as int));
    }
    return {};
  }

  static AgencyStatus _parseAgencyStatus(String? status) {
    if (status == null) return AgencyStatus.pending;
    switch (status.toLowerCase()) {
      case 'active':
        return AgencyStatus.active;
      case 'suspended':
        return AgencyStatus.suspended;
      case 'inactive':
        return AgencyStatus.inactive;
      case 'verified':
        return AgencyStatus.verified;
      default:
        return AgencyStatus.pending;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'ownerId': ownerId,
      'ownerName': ownerName,
      'memberIds': memberIds,
      'memberEarnings': memberEarnings,
      'totalEarnings': totalEarnings,
      'commissionRate': commissionRate,
      'createdAt': createdAt.toIso8601String(),
      'status': status.toString().split('.').last,
      'logo': logo,
      'description': description,
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  AgencyModel copyWith({
    String? id,
    String? name,
    String? ownerId,
    String? ownerName,
    List<String>? memberIds,
    Map<String, int>? memberEarnings,
    int? totalEarnings,
    double? commissionRate,
    DateTime? createdAt,
    AgencyStatus? status,
    String? logo,
    String? description,
    DateTime? updatedAt,
  }) {
    return AgencyModel(
      id: id ?? this.id,
      name: name ?? this.name,
      ownerId: ownerId ?? this.ownerId,
      ownerName: ownerName ?? this.ownerName,
      memberIds: memberIds ?? this.memberIds,
      memberEarnings: memberEarnings ?? this.memberEarnings,
      totalEarnings: totalEarnings ?? this.totalEarnings,
      commissionRate: commissionRate ?? this.commissionRate,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      logo: logo ?? this.logo,
      description: description ?? this.description,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Helper getters
  int get memberCount => memberIds.length;

  bool get isActive => status == AgencyStatus.active;
  bool get isSuspended => status == AgencyStatus.suspended;
  bool get isPending => status == AgencyStatus.pending;
  bool get isVerified => status == AgencyStatus.verified;

  // Get earnings for a specific member
  int getMemberEarnings(String memberId) {
    return memberEarnings[memberId] ?? 0;
  }

  // Add or update member earnings
  AgencyModel updateMemberEarnings(String memberId, int earnings) {
    final updatedEarnings = Map<String, int>.from(memberEarnings);
    updatedEarnings[memberId] = earnings;

    return copyWith(
      memberEarnings: updatedEarnings,
      totalEarnings: totalEarnings + earnings,
    );
  }

  // Add a member
  AgencyModel addMember(String memberId) {
    if (memberIds.contains(memberId)) return this;

    final updatedMembers = List<String>.from(memberIds)..add(memberId);
    return copyWith(memberIds: updatedMembers);
  }

  // Remove a member
  AgencyModel removeMember(String memberId) {
    final updatedMembers = List<String>.from(memberIds)..remove(memberId);

    // Also remove earnings for this member
    final updatedEarnings = Map<String, int>.from(memberEarnings);
    updatedEarnings.remove(memberId);

    return copyWith(
      memberIds: updatedMembers,
      memberEarnings: updatedEarnings,
    );
  }

  // Calculate total earnings from memberEarnings
  int get calculatedTotalEarnings {
    return memberEarnings.values.fold(0, (sum, earnings) => sum + earnings);
  }

  @override
  String toString() {
    return 'AgencyModel(id: $id, name: $name, status: $status, members: $memberCount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AgencyModel &&
        other.id == id &&
        other.name == name &&
        other.ownerId == ownerId;
  }

  @override
  int get hashCode => Object.hash(id, name, ownerId);
}