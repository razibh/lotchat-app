import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../../../core/models/clan_model.dart';
import '../models/clan_member_model.dart';

class ClanService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ==================== CLAN OPERATIONS ====================

  Future<ClanModel?> createClan({
    required String name,
    String? description,
    String? rules,
    String? emblem,
    ClanJoinType joinType = ClanJoinType.open,
    List<String> tags = const [],
  }) async {
    final User? user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    try {
      final clanData = ClanModel(
        id: '',
        name: name,
        description: description,
        rules: rules,
        emblem: emblem,
        leaderId: user.uid,
        members: [
          ClanMember(
            userId: user.uid,
            username: user.displayName ?? 'User',
            avatar: user.photoURL,
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

      final docRef = await _firestore.collection('clans').add(clanData.toJson());

      // Update user's clan ID
      await _firestore.collection('users').doc(user.uid).update({
        'clanId': docRef.id,
      });

      return clanData.copyWith(id: docRef.id);
    } catch (e) {
      debugPrint('Error creating clan: $e');
      return null;
    }
  }

  Future<ClanModel?> getClan(String clanId) async {
    try {
      final doc = await _firestore.collection('clans').doc(clanId).get();
      if (doc.exists) {
        return ClanModel.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting clan: $e');
      return null;
    }
  }

  Stream<ClanModel?> streamClan(String clanId) {
    return _firestore
        .collection('clans')
        .doc(clanId)
        .snapshots()
        .map((doc) => doc.exists ? ClanModel.fromJson(doc.data()!) : null);
  }

  Future<List<ClanModel>> searchClans(String query) async {
    try {
      final snapshot = await _firestore
          .collection('clans')
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThanOrEqualTo: '$query\uf8ff')
          .limit(20)
          .get();

      return snapshot.docs
          .map((doc) => ClanModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      debugPrint('Error searching clans: $e');
      return [];
    }
  }

  // ==================== MEMBER MANAGEMENT ====================

  Future<bool> joinClan(String clanId) async {
    final User? user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    try {
      final clanRef = _firestore.collection('clans').doc(clanId);

      await _firestore.runTransaction((transaction) async {
        final clanDoc = await transaction.get(clanRef);
        if (!clanDoc.exists) throw Exception('Clan not found');

        final clan = ClanModel.fromJson(clanDoc.data()!);

        if (clan.isFull) throw Exception('Clan is full');
        if (clan.members.any((m) => m.userId == user.uid)) {
          throw Exception('Already a member');
        }

        if (clan.joinType == ClanJoinType.approval) {
          // Add to join requests
          transaction.set(
            _firestore.collection('clan_requests').doc(),
            {
              'clanId': clanId,
              'userId': user.uid,
              'username': user.displayName,
              'avatar': user.photoURL,
              'status': 'pending',
              'timestamp': FieldValue.serverTimestamp(),
            },
          );
        } else {
          // Direct join
          final newMember = ClanMember(
            userId: user.uid,
            username: user.displayName ?? 'User',
            avatar: user.photoURL,
            role: ClanRole.member,
            joinedAt: DateTime.now(),
          );

          transaction.update(clanRef, {
            'members': FieldValue.arrayUnion([newMember.toJson()]),
            'memberCount': FieldValue.increment(1),
            'lastActive': FieldValue.serverTimestamp(),
          });

          // Update user's clan ID
          transaction.update(
            _firestore.collection('users').doc(user.uid),
            {'clanId': clanId},
          );
        }
      });

      return true;
    } catch (e) {
      debugPrint('Error joining clan: $e');
      return false;
    }
  }

  Future<bool> leaveClan(String clanId) async {
    final User? user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    try {
      final clanRef = _firestore.collection('clans').doc(clanId);

      await _firestore.runTransaction((transaction) async {
        final clanDoc = await transaction.get(clanRef);
        if (!clanDoc.exists) throw Exception('Clan not found');

        final clan = ClanModel.fromJson(clanDoc.data()!);

        if (clan.isLeader(user.uid)) {
          throw Exception('Leader cannot leave. Transfer leadership first.');
        }

        final member = clan.getMember(user.uid);
        if (member == null) throw Exception('Member not found');

        // Remove member
        transaction.update(clanRef, {
          'members': FieldValue.arrayRemove([member.toJson()]),
          'memberCount': FieldValue.increment(-1),
        });

        // Update user's clan ID
        transaction.update(
          _firestore.collection('users').doc(user.uid),
          {'clanId': FieldValue.delete()},
        );
      });

      return true;
    } catch (e) {
      debugPrint('Error leaving clan: $e');
      return false;
    }
  }

  Future<bool> kickMember(String clanId, String memberId) async {
    final User? user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    try {
      final clanRef = _firestore.collection('clans').doc(clanId);

      await _firestore.runTransaction((transaction) async {
        final clanDoc = await transaction.get(clanRef);
        if (!clanDoc.exists) throw Exception('Clan not found');

        final clan = ClanModel.fromJson(clanDoc.data()!);

        if (!clan.canManage(user.uid)) {
          throw Exception('Not authorized to kick members');
        }

        final member = clan.getMember(memberId);
        if (member == null) throw Exception('Member not found');

        if (member.role == ClanRole.leader) {
          throw Exception('Cannot kick leader');
        }

        if (member.role == ClanRole.coLeader && !clan.isLeader(user.uid)) {
          throw Exception('Only leader can kick co-leaders');
        }

        // Remove member
        transaction.update(clanRef, {
          'members': FieldValue.arrayRemove([member.toJson()]),
          'memberCount': FieldValue.increment(-1),
        });

        // Update user's clan ID
        transaction.update(
          _firestore.collection('users').doc(memberId),
          {'clanId': FieldValue.delete()},
        );
      });

      return true;
    } catch (e) {
      debugPrint('Error kicking member: $e');
      return false;
    }
  }

  Future<bool> changeMemberRole(String clanId, String memberId, ClanRole newRole) async {
    final User? user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    try {
      final clanRef = _firestore.collection('clans').doc(clanId);

      await _firestore.runTransaction((transaction) async {
        final clanDoc = await transaction.get(clanRef);
        if (!clanDoc.exists) throw Exception('Clan not found');

        final clan = ClanModel.fromJson(clanDoc.data()!);

        if (!clan.canManage(user.uid)) {
          throw Exception('Not authorized to change roles');
        }

        final member = clan.getMember(memberId);
        if (member == null) throw Exception('Member not found');

        // Update member role
        final updatedMember = member.copyWith(role: newRole);

        // Remove old and add updated
        transaction.update(clanRef, {
          'members': FieldValue.arrayRemove([member.toJson()]),
        });

        transaction.update(clanRef, {
          'members': FieldValue.arrayUnion([updatedMember.toJson()]),
        });
      });

      return true;
    } catch (e) {
      debugPrint('Error changing role: $e');
      return false;
    }
  }

  // ==================== JOIN REQUESTS ====================

  Stream<List<Map<String, dynamic>>> getJoinRequests(String clanId) {
    return _firestore
        .collection('clan_requests')
        .where('clanId', isEqualTo: clanId)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  Future<bool> approveRequest(String requestId, String clanId) async {
    final User? user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    try {
      final requestRef = _firestore.collection('clan_requests').doc(requestId);
      final requestDoc = await requestRef.get();

      if (!requestDoc.exists) throw Exception('Request not found');

      final requestData = requestDoc.data();
      if (requestData == null) throw Exception('Request data not found');

      final userId = requestData['userId'] as String;

      await _firestore.runTransaction((transaction) async {
        // Update request status
        transaction.update(requestRef, {'status': 'approved'});

        // Add to clan members
        final clanRef = _firestore.collection('clans').doc(clanId);
        final clanDoc = await transaction.get(clanRef);

        if (!clanDoc.exists) throw Exception('Clan not found');

        final newMember = ClanMember(
          userId: userId,
          username: requestData['username'] ?? '',
          avatar: requestData['avatar'],
          role: ClanRole.member,
          joinedAt: DateTime.now(),
        );

        transaction.update(clanRef, {
          'members': FieldValue.arrayUnion([newMember.toJson()]),
          'memberCount': FieldValue.increment(1),
        });

        // Update user's clan ID
        transaction.update(
          _firestore.collection('users').doc(userId),
          {'clanId': clanId},
        );
      });

      return true;
    } catch (e) {
      debugPrint('Error approving request: $e');
      return false;
    }
  }

  Future<bool> rejectRequest(String requestId) async {
    try {
      await _firestore
          .collection('clan_requests')
          .doc(requestId)
          .update({'status': 'rejected'});
      return true;
    } catch (e) {
      debugPrint('Error rejecting request: $e');
      return false;
    }
  }

  // ==================== CLAN ACTIVITY ====================

  Future<void> addActivityPoints(String clanId, String userId, int points) async {
    try {
      final clanRef = _firestore.collection('clans').doc(clanId);

      await _firestore.runTransaction((transaction) async {
        final clanDoc = await transaction.get(clanRef);
        if (!clanDoc.exists) return;

        final clan = ClanModel.fromJson(clanDoc.data()!);
        final member = clan.getMember(userId);

        if (member == null) return;

        final updatedMember = member.copyWith(
          activityPoints: member.activityPoints + points,
          lastActive: DateTime.now().millisecondsSinceEpoch,
        );

        // Update member
        transaction.update(clanRef, {
          'members': FieldValue.arrayRemove([member.toJson()]),
        });

        transaction.update(clanRef, {
          'members': FieldValue.arrayUnion([updatedMember.toJson()]),
          'xp': FieldValue.increment(points),
          'lastActive': FieldValue.serverTimestamp(),
        });

        // Check for level up
        final int newXp = clan.xp + points;
        if (newXp >= clan.xpToNextLevel) {
          transaction.update(clanRef, {
            'level': FieldValue.increment(1),
            'xp': newXp - clan.xpToNextLevel,
            'xpToNextLevel': clan.xpToNextLevel * 2,
          });
        }
      });
    } catch (e) {
      debugPrint('Error adding activity points: $e');
    }
  }

  Future<void> addDonation(String clanId, String userId, int amount) async {
    try {
      final clanRef = _firestore.collection('clans').doc(clanId);

      await _firestore.runTransaction((transaction) async {
        final clanDoc = await transaction.get(clanRef);
        if (!clanDoc.exists) return;

        final clan = ClanModel.fromJson(clanDoc.data()!);
        final member = clan.getMember(userId);

        if (member == null) return;

        final updatedMember = member.copyWith(
          donations: member.donations + amount,
          lastActive: DateTime.now().millisecondsSinceEpoch,
        );

        transaction.update(clanRef, {
          'members': FieldValue.arrayRemove([member.toJson()]),
        });

        transaction.update(clanRef, {
          'members': FieldValue.arrayUnion([updatedMember.toJson()]),
          'clanCoins': FieldValue.increment(amount),
        });
      });
    } catch (e) {
      debugPrint('Error adding donation: $e');
    }
  }

  // ==================== CLAN LEADERBOARD ====================

  Stream<List<ClanModel>> getTopClans() {
    return _firestore
        .collection('clans')
        .where('isActive', isEqualTo: true)
        .orderBy('level', descending: true)
        .orderBy('xp', descending: true)
        .limit(100)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => ClanModel.fromJson(doc.data()))
        .toList());
  }

  Stream<List<ClanMember>> getTopMembers(String clanId) {
    return _firestore
        .collection('clans')
        .doc(clanId)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return [];
      final clan = ClanModel.fromJson(doc.data()!);
      final members = clan.members;
      members.sort((a, b) => b.activityPoints.compareTo(a.activityPoints));
      return members;
    });
  }

  // ==================== CLAN SETTINGS ====================

  Future<bool> updateClanSettings(String clanId, Map<String, dynamic> settings) async {
    final User? user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    try {
      final clanRef = _firestore.collection('clans').doc(clanId);
      final clanDoc = await clanRef.get();

      if (!clanDoc.exists) throw Exception('Clan not found');

      final clan = ClanModel.fromJson(clanDoc.data()!);

      if (!clan.canManage(user.uid)) {
        throw Exception('Not authorized to update settings');
      }

      await clanRef.update({
        'settings': settings,
      });

      return true;
    } catch (e) {
      debugPrint('Error updating clan settings: $e');
      return false;
    }
  }

  Future<bool> transferLeadership(String clanId, String newLeaderId) async {
    final User? user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    try {
      final clanRef = _firestore.collection('clans').doc(clanId);

      await _firestore.runTransaction((transaction) async {
        final clanDoc = await transaction.get(clanRef);
        if (!clanDoc.exists) throw Exception('Clan not found');

        final clan = ClanModel.fromJson(clanDoc.data()!);

        if (!clan.isLeader(user.uid)) {
          throw Exception('Only leader can transfer leadership');
        }

        final oldLeader = clan.getMember(user.uid);
        final newLeader = clan.getMember(newLeaderId);

        if (oldLeader == null || newLeader == null) {
          throw Exception('Members not found');
        }

        // Update roles
        final updatedOldLeader = oldLeader.copyWith(role: ClanRole.member);
        final updatedNewLeader = newLeader.copyWith(role: ClanRole.leader);

        // Remove both members
        transaction.update(clanRef, {
          'members': FieldValue.arrayRemove([oldLeader.toJson(), newLeader.toJson()]),
        });

        // Add updated members
        transaction.update(clanRef, {
          'members': FieldValue.arrayUnion([updatedOldLeader.toJson(), updatedNewLeader.toJson()]),
          'leaderId': newLeaderId,
        });
      });

      return true;
    } catch (e) {
      debugPrint('Error transferring leadership: $e');
      return false;
    }
  }

  Future<bool> disbandClan(String clanId) async {
    final User? user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    try {
      final clanRef = _firestore.collection('clans').doc(clanId);
      final clanDoc = await clanRef.get();

      if (!clanDoc.exists) throw Exception('Clan not found');

      final clan = ClanModel.fromJson(clanDoc.data()!);

      if (!clan.isLeader(user.uid)) {
        throw Exception('Only leader can disband clan');
      }

      // Update all members' clanId to null
      final batch = _firestore.batch();

      for (final member in clan.members) {
        batch.update(
          _firestore.collection('users').doc(member.userId),
          {'clanId': FieldValue.delete()},
        );
      }

      // Delete the clan
      batch.delete(clanRef);

      await batch.commit();

      return true;
    } catch (e) {
      debugPrint('Error disbanding clan: $e');
      return false;
    }
  }
}