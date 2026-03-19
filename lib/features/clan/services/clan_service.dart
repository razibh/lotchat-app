import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/models/clan_model.dart';
import '../models/clan_member_model.dart';
import '../../../core/di/service_locator.dart';


class ClanService {
  late final SupabaseClient _supabase;

  ClanService() {
    _supabase = getService<SupabaseClient>();
  }

  // Helper to get current user
  String? get _currentUserId => _supabase.auth.currentSession?.user.id;

  // Helper methods
  int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  DateTime _parseDate(dynamic date) {
    if (date == null) return DateTime.now();
    if (date is String) return DateTime.parse(date);
    if (date is DateTime) return date;
    return DateTime.now();
  }

  // ==================== CLAN OPERATIONS ====================

  /// Create clan
  Future<ClanModel?> createClan({
    required String name,
    String? description,
    String? rules,
    String? emblem,
    ClanJoinType joinType = ClanJoinType.open,
    List<String> tags = const [],
  }) async {
    final userId = _currentUserId;
    if (userId == null) throw Exception('User not logged in');

    try {
      // Get current user info
      final userData = await _supabase
          .from('users')
          .select('username, avatar_url')
          .eq('id', userId)
          .maybeSingle();

      final clanData = ClanModel(
        id: '',
        name: name,
        description: description,
        rules: rules,
        emblem: emblem,
        leaderId: userId,
        members: [
          ClanMember(
            userId: userId,
            username: userData?['username'] ?? 'User',
            avatar: userData?['avatar_url'],
            role: ClanRole.leader,
            joinedAt: DateTime.now(),
          ),
        ],
        level: 1,
        xp: 0,
        xpToNextLevel: 1000,
        clanCoins: 0,
        memberCount: 1,
        maxMembers: 50,
        joinType: joinType,
        tags: tags,
        createdAt: DateTime.now(),
        lastActive: DateTime.now(),
        isActive: true,
        warWins: 0,
        warLosses: 0,
        warDraws: 0,
        settings: {},
      );

      final response = await _supabase
          .from('clans')
          .insert(clanData.toJson())
          .select()
          .single();

      // Update user's clan ID
      final updateUserQuery = _supabase
          .from('users')
          .update({
        'clan_id': response['id'],
        'updated_at': DateTime.now().toIso8601String(),
      });
      await updateUserQuery.eq('id', userId);

      return ClanModel.fromJson(response);
    } catch (e) {
      debugPrint('Error creating clan: $e');
      return null;
    }
  }

  /// Get clan
  Future<ClanModel?> getClan(String clanId) async {
    try {
      final response = await _supabase
          .from('clans')
          .select()
          .eq('id', clanId)
          .maybeSingle();

      if (response != null) {
        return ClanModel.fromJson(response);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting clan: $e');
      return null;
    }
  }

  /// Stream clan
  Stream<ClanModel?> streamClan(String clanId) {
    try {
      final stream = _supabase
          .from('clans')
          .stream(primaryKey: ['id']);

      return stream.map((data) {
        for (var item in data) {
          if (item['id'].toString() == clanId) {
            return ClanModel.fromJson(item);
          }
        }
        return null;
      });
    } catch (e) {
      debugPrint('Error streaming clan: $e');
      return Stream.value(null);
    }
  }

  /// Search clans
  Future<List<ClanModel>> searchClans(String query) async {
    try {
      final response = await _supabase
          .from('clans')
          .select()
          .ilike('name', '%$query%')
          .limit(20);

      return response.map((json) => ClanModel.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error searching clans: $e');
      return [];
    }
  }

  // ==================== MEMBER MANAGEMENT ====================

  /// Join clan
  Future<bool> joinClan(String clanId) async {
    final userId = _currentUserId;
    if (userId == null) throw Exception('User not logged in');

    try {
      // Get clan info
      final clanData = await _supabase
          .from('clans')
          .select()
          .eq('id', clanId)
          .maybeSingle();

      if (clanData == null) throw Exception('Clan not found');

      final clan = ClanModel.fromJson(clanData);

      if (clan.isFull) throw Exception('Clan is full');
      if (clan.members.any((m) => m.userId == userId)) {
        throw Exception('Already a member');
      }

      if (clan.joinType == ClanJoinType.approval) {
        // Add to join requests
        await _supabase.from('clan_requests').insert({
          'clan_id': clanId,
          'user_id': userId,
          'username': _supabase.auth.currentUser?.userMetadata?['username'] ?? 'User',
          'avatar': _supabase.auth.currentUser?.userMetadata?['avatar_url'],
          'status': 'pending',
          'created_at': DateTime.now().toIso8601String(),
        });
      } else {
        // Direct join
        final newMember = ClanMember(
          userId: userId,
          username: _supabase.auth.currentUser?.userMetadata?['username'] ?? 'User',
          avatar: _supabase.auth.currentUser?.userMetadata?['avatar_url'],
          role: ClanRole.member,
          joinedAt: DateTime.now(),
        );

        final updatedMembers = [...clan.members, newMember];

        // Update clan
        final updateClanQuery = _supabase
            .from('clans')
            .update({
          'members': updatedMembers.map((m) => m.toJson()).toList(),
          'member_count': clan.memberCount + 1,
          'last_active': DateTime.now().toIso8601String(),
        });
        await updateClanQuery.eq('id', clanId);

        // Update user's clan ID
        final updateUserQuery = _supabase
            .from('users')
            .update({
          'clan_id': clanId,
          'updated_at': DateTime.now().toIso8601String(),
        });
        await updateUserQuery.eq('id', userId);
      }

      return true;
    } catch (e) {
      debugPrint('Error joining clan: $e');
      return false;
    }
  }

  /// Leave clan
  Future<bool> leaveClan(String clanId) async {
    final userId = _currentUserId;
    if (userId == null) throw Exception('User not logged in');

    try {
      // Get clan info
      final clanData = await _supabase
          .from('clans')
          .select()
          .eq('id', clanId)
          .maybeSingle();

      if (clanData == null) throw Exception('Clan not found');

      final clan = ClanModel.fromJson(clanData);

      if (clan.isLeader(userId)) {
        throw Exception('Leader cannot leave. Transfer leadership first.');
      }

      final member = clan.getMember(userId);
      if (member == null) throw Exception('Member not found');

      // Remove member
      final updatedMembers = clan.members.where((m) => m.userId != userId).toList();

      // Update clan
      final updateClanQuery = _supabase
          .from('clans')
          .update({
        'members': updatedMembers.map((m) => m.toJson()).toList(),
        'member_count': clan.memberCount - 1,
        'last_active': DateTime.now().toIso8601String(),
      });
      await updateClanQuery.eq('id', clanId);

      // Update user's clan ID
      final updateUserQuery = _supabase
          .from('users')
          .update({
        'clan_id': null,
        'updated_at': DateTime.now().toIso8601String(),
      });
      await updateUserQuery.eq('id', userId);

      return true;
    } catch (e) {
      debugPrint('Error leaving clan: $e');
      return false;
    }
  }

  /// Kick member
  Future<bool> kickMember(String clanId, String memberId) async {
    final userId = _currentUserId;
    if (userId == null) throw Exception('User not logged in');

    try {
      // Get clan info
      final clanData = await _supabase
          .from('clans')
          .select()
          .eq('id', clanId)
          .maybeSingle();

      if (clanData == null) throw Exception('Clan not found');

      final clan = ClanModel.fromJson(clanData);

      if (!clan.canManage(userId)) {
        throw Exception('Not authorized to kick members');
      }

      final member = clan.getMember(memberId);
      if (member == null) throw Exception('Member not found');

      if (member.role == ClanRole.leader) {
        throw Exception('Cannot kick leader');
      }

      if (member.role == ClanRole.coLeader && !clan.isLeader(userId)) {
        throw Exception('Only leader can kick co-leaders');
      }

      // Remove member
      final updatedMembers = clan.members.where((m) => m.userId != memberId).toList();

      // Update clan
      final updateClanQuery = _supabase
          .from('clans')
          .update({
        'members': updatedMembers.map((m) => m.toJson()).toList(),
        'member_count': clan.memberCount - 1,
        'last_active': DateTime.now().toIso8601String(),
      });
      await updateClanQuery.eq('id', clanId);

      // Update user's clan ID
      final updateUserQuery = _supabase
          .from('users')
          .update({
        'clan_id': null,
        'updated_at': DateTime.now().toIso8601String(),
      });
      await updateUserQuery.eq('id', memberId);

      return true;
    } catch (e) {
      debugPrint('Error kicking member: $e');
      return false;
    }
  }

  /// Change member role
  Future<bool> changeMemberRole(String clanId, String memberId, ClanRole newRole) async {
    final userId = _currentUserId;
    if (userId == null) throw Exception('User not logged in');

    try {
      // Get clan info
      final clanData = await _supabase
          .from('clans')
          .select()
          .eq('id', clanId)
          .maybeSingle();

      if (clanData == null) throw Exception('Clan not found');

      final clan = ClanModel.fromJson(clanData);

      if (!clan.canManage(userId)) {
        throw Exception('Not authorized to change roles');
      }

      final member = clan.getMember(memberId);
      if (member == null) throw Exception('Member not found');

      // Update member role
      final updatedMember = member.copyWith(role: newRole);

      // Replace member in list
      final updatedMembers = clan.members.map((m) {
        if (m.userId == memberId) {
          return updatedMember;
        }
        return m;
      }).toList();

      // Update clan
      final updateClanQuery = _supabase
          .from('clans')
          .update({
        'members': updatedMembers.map((m) => m.toJson()).toList(),
        'last_active': DateTime.now().toIso8601String(),
      });
      await updateClanQuery.eq('id', clanId);

      return true;
    } catch (e) {
      debugPrint('Error changing role: $e');
      return false;
    }
  }

  // ==================== JOIN REQUESTS ====================

  /// Get join requests stream
  Stream<List<Map<String, dynamic>>> getJoinRequests(String clanId) {
    try {
      final stream = _supabase
          .from('clan_requests')
          .stream(primaryKey: ['id']);

      return stream.map((data) {
        // Filter pending requests for this clan
        final filtered = data.where((item) =>
        item['clan_id'] == clanId &&
            item['status'] == 'pending'
        ).toList();

        // Sort by created_at
        filtered.sort((a, b) {
          final aTime = _parseDate(a['created_at']);
          final bTime = _parseDate(b['created_at']);
          return bTime.compareTo(aTime);
        });

        return filtered.map((item) {
          return {
            'id': item['id'].toString(),
            'user_id': item['user_id'],
            'username': item['username'] ?? 'Unknown',
            'avatar': item['avatar'],
            'message': item['message'],
            'created_at': item['created_at'],
            'status': item['status'],
          };
        }).toList();
      });
    } catch (e) {
      debugPrint('Error getting join requests: $e');
      return Stream.value([]);
    }
  }

  /// Approve join request - FIXED: 2 parameters
  Future<bool> approveRequest(String requestId, String clanId) async {
    final userId = _currentUserId;
    if (userId == null) throw Exception('User not logged in');

    try {
      // Get request details
      final requestData = await _supabase
          .from('clan_requests')
          .select()
          .eq('id', requestId)
          .maybeSingle();

      if (requestData == null) throw Exception('Request not found');

      final requestUserId = requestData['user_id'];

      // Update request status
      final updateRequestQuery = _supabase
          .from('clan_requests')
          .update({
        'status': 'approved',
        'updated_at': DateTime.now().toIso8601String(),
      });
      await updateRequestQuery.eq('id', requestId);

      // Get clan info
      final clanData = await _supabase
          .from('clans')
          .select()
          .eq('id', clanId)
          .maybeSingle();

      if (clanData == null) throw Exception('Clan not found');

      final clan = ClanModel.fromJson(clanData);

      // Add to clan members
      final newMember = ClanMember(
        userId: requestUserId,
        username: requestData['username'] ?? 'User',
        avatar: requestData['avatar'],
        role: ClanRole.member,
        joinedAt: DateTime.now(),
      );

      final updatedMembers = [...clan.members, newMember];

      // Update clan
      final updateClanQuery = _supabase
          .from('clans')
          .update({
        'members': updatedMembers.map((m) => m.toJson()).toList(),
        'member_count': clan.memberCount + 1,
        'last_active': DateTime.now().toIso8601String(),
      });
      await updateClanQuery.eq('id', clanId);

      // Update user's clan ID
      final updateUserQuery = _supabase
          .from('users')
          .update({
        'clan_id': clanId,
        'updated_at': DateTime.now().toIso8601String(),
      });
      await updateUserQuery.eq('id', requestUserId);

      return true;
    } catch (e) {
      debugPrint('Error approving request: $e');
      return false;
    }
  }

  /// Reject join request
  Future<bool> rejectRequest(String requestId) async {
    try {
      final updateRequestQuery = _supabase
          .from('clan_requests')
          .update({
        'status': 'rejected',
        'updated_at': DateTime.now().toIso8601String(),
      });
      await updateRequestQuery.eq('id', requestId);
      return true;
    } catch (e) {
      debugPrint('Error rejecting request: $e');
      return false;
    }
  }

  // ==================== CLAN ACTIVITY ====================

  /// Add activity points
  Future<void> addActivityPoints(String clanId, String userId, int points) async {
    try {
      // Get clan info
      final clanData = await _supabase
          .from('clans')
          .select()
          .eq('id', clanId)
          .maybeSingle();

      if (clanData == null) return;

      final clan = ClanModel.fromJson(clanData);
      final member = clan.getMember(userId);

      if (member == null) return;

      final updatedMember = member.copyWith(
        activityPoints: member.activityPoints + points,
        lastActive: DateTime.now().millisecondsSinceEpoch,
      );

      // Replace member in list
      final updatedMembers = clan.members.map((m) {
        if (m.userId == userId) {
          return updatedMember;
        }
        return m;
      }).toList();

      int newXp = clan.xp + points;
      int newLevel = clan.level;
      int newXpToNextLevel = clan.xpToNextLevel;

      // Check for level up
      if (newXp >= clan.xpToNextLevel) {
        newLevel = clan.level + 1;
        newXp = newXp - clan.xpToNextLevel;
        newXpToNextLevel = clan.xpToNextLevel * 2;
      }

      // Update clan
      final updateClanQuery = _supabase
          .from('clans')
          .update({
        'members': updatedMembers.map((m) => m.toJson()).toList(),
        'xp': newXp,
        'level': newLevel,
        'xp_to_next_level': newXpToNextLevel,
        'last_active': DateTime.now().toIso8601String(),
      });
      await updateClanQuery.eq('id', clanId);
    } catch (e) {
      debugPrint('Error adding activity points: $e');
    }
  }

  /// Add donation
  Future<void> addDonation(String clanId, String userId, int amount) async {
    try {
      // Get clan info
      final clanData = await _supabase
          .from('clans')
          .select()
          .eq('id', clanId)
          .maybeSingle();

      if (clanData == null) return;

      final clan = ClanModel.fromJson(clanData);
      final member = clan.getMember(userId);

      if (member == null) return;

      final updatedMember = member.copyWith(
        donations: member.donations + amount,
        lastActive: DateTime.now().millisecondsSinceEpoch,
      );

      // Replace member in list
      final updatedMembers = clan.members.map((m) {
        if (m.userId == userId) {
          return updatedMember;
        }
        return m;
      }).toList();

      // Update clan
      final updateClanQuery = _supabase
          .from('clans')
          .update({
        'members': updatedMembers.map((m) => m.toJson()).toList(),
        'clan_coins': clan.clanCoins + amount,
        'last_active': DateTime.now().toIso8601String(),
      });
      await updateClanQuery.eq('id', clanId);
    } catch (e) {
      debugPrint('Error adding donation: $e');
    }
  }

  // ==================== CLAN LEADERBOARD ====================

  /// Get top clans stream
  Stream<List<ClanModel>> getTopClans() {
    try {
      final stream = _supabase
          .from('clans')
          .stream(primaryKey: ['id']);

      return stream.map((data) {
        final filtered = data.where((item) => item['is_active'] == true).toList();

        // Sort by level and xp
        filtered.sort((a, b) {
          final aLevel = _toInt(a['level']);
          final bLevel = _toInt(b['level']);
          if (aLevel != bLevel) {
            return bLevel.compareTo(aLevel);
          }
          final aXp = _toInt(a['xp']);
          final bXp = _toInt(b['xp']);
          return bXp.compareTo(aXp);
        });

        return filtered.take(100).map((json) => ClanModel.fromJson(json)).toList();
      });
    } catch (e) {
      debugPrint('Error getting top clans: $e');
      return Stream.value([]);
    }
  }

  /// Get top members stream
  Stream<List<ClanMember>> getTopMembers(String clanId) {
    try {
      final stream = _supabase
          .from('clans')
          .stream(primaryKey: ['id']);

      return stream.map((data) {
        for (var item in data) {
          if (item['id'].toString() == clanId) {
            final clan = ClanModel.fromJson(item);
            final members = clan.members;
            members.sort((a, b) => b.activityPoints.compareTo(a.activityPoints));
            return members;
          }
        }
        return [];
      });
    } catch (e) {
      debugPrint('Error getting top members: $e');
      return Stream.value([]);
    }
  }

  // ==================== CLAN SETTINGS ====================

  /// Update clan settings
  Future<bool> updateClanSettings(String clanId, Map<String, dynamic> settings) async {
    final userId = _currentUserId;
    if (userId == null) throw Exception('User not logged in');

    try {
      // Get clan info
      final clanData = await _supabase
          .from('clans')
          .select()
          .eq('id', clanId)
          .maybeSingle();

      if (clanData == null) throw Exception('Clan not found');

      final clan = ClanModel.fromJson(clanData);

      if (!clan.canManage(userId)) {
        throw Exception('Not authorized to update settings');
      }

      final updateClanQuery = _supabase
          .from('clans')
          .update({
        'settings': settings,
        'updated_at': DateTime.now().toIso8601String(),
      });
      await updateClanQuery.eq('id', clanId);

      return true;
    } catch (e) {
      debugPrint('Error updating clan settings: $e');
      return false;
    }
  }

  /// Transfer leadership
  Future<bool> transferLeadership(String clanId, String newLeaderId) async {
    final userId = _currentUserId;
    if (userId == null) throw Exception('User not logged in');

    try {
      // Get clan info
      final clanData = await _supabase
          .from('clans')
          .select()
          .eq('id', clanId)
          .maybeSingle();

      if (clanData == null) throw Exception('Clan not found');

      final clan = ClanModel.fromJson(clanData);

      if (!clan.isLeader(userId)) {
        throw Exception('Only leader can transfer leadership');
      }

      final oldLeader = clan.getMember(userId);
      final newLeader = clan.getMember(newLeaderId);

      if (oldLeader == null || newLeader == null) {
        throw Exception('Members not found');
      }

      // Update roles
      final updatedOldLeader = oldLeader.copyWith(role: ClanRole.member);
      final updatedNewLeader = newLeader.copyWith(role: ClanRole.leader);

      // Update members list
      final updatedMembers = clan.members.map((m) {
        if (m.userId == userId) return updatedOldLeader;
        if (m.userId == newLeaderId) return updatedNewLeader;
        return m;
      }).toList();

      // Update clan
      final updateClanQuery = _supabase
          .from('clans')
          .update({
        'members': updatedMembers.map((m) => m.toJson()).toList(),
        'leader_id': newLeaderId,
        'updated_at': DateTime.now().toIso8601String(),
      });
      await updateClanQuery.eq('id', clanId);

      return true;
    } catch (e) {
      debugPrint('Error transferring leadership: $e');
      return false;
    }
  }

  /// Disband clan
  Future<bool> disbandClan(String clanId) async {
    final userId = _currentUserId;
    if (userId == null) throw Exception('User not logged in');

    try {
      // Get clan info
      final clanData = await _supabase
          .from('clans')
          .select()
          .eq('id', clanId)
          .maybeSingle();

      if (clanData == null) throw Exception('Clan not found');

      final clan = ClanModel.fromJson(clanData);

      if (!clan.isLeader(userId)) {
        throw Exception('Only leader can disband clan');
      }

      // Update all members' clan_id to null
      for (final member in clan.members) {
        final updateUserQuery = _supabase
            .from('users')
            .update({
          'clan_id': null,
          'updated_at': DateTime.now().toIso8601String(),
        });
        await updateUserQuery.eq('id', member.userId);
      }

      // Delete the clan
      await _supabase
          .from('clans')
          .delete()
          .eq('id', clanId);

      return true;
    } catch (e) {
      debugPrint('Error disbanding clan: $e');
      return false;
    }
  }
}