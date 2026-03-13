import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/clan_model.dart';

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
    List<String> tags = const <String>[],
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    try {
      final ClanModel clanData = ClanModel(
        id: '', // Will be set after creation
        name: name,
        description: description,
        rules: rules,
        emblem: emblem,
        leaderId: user.uid,
        members: <ClanMember>[
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
      );

      final docRef = await _firestore.collection('clans').add(clanData.toJson());
      
      // Update user's clan ID
      await _firestore.collection('users').doc(user.uid).update(<String, >{
        'clanId': docRef.id,
      });

      return clanData.copyWith(id: docRef.id);
    } catch (e) {
      print('Error creating clan: $e');
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
      print('Error getting clan: $e');
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
      print('Error searching clans: $e');
      return <ClanModel>[];
    }
  }

  // ==================== MEMBER MANAGEMENT ====================

  Future<bool> joinClan(String clanId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    try {
      final clanRef = _firestore.collection('clans').doc(clanId);
      
      await _firestore.runTransaction((transaction) async {
        final clanDoc = await transaction.get(clanRef);
        if (!clanDoc.exists) throw Exception('Clan not found');

        final ClanModel clan = ClanModel.fromJson(clanDoc.data()!);
        
        if (clan.isFull) throw Exception('Clan is full');
        if (clan.members.any((ClanMember m) => m.userId == user.uid)) {
          throw Exception('Already a member');
        }

        if (clan.joinType == ClanJoinType.approval) {
          // Add to join requests
          transaction.set(
            _firestore.collection('clan_requests').doc(),
            <String, >{
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
          final ClanMember newMember = ClanMember(
            userId: user.uid,
            username: user.displayName ?? 'User',
            avatar: user.photoURL,
            role: ClanRole.member,
            joinedAt: DateTime.now(),
          );

          transaction.update(clanRef, <String, >{
            'members': FieldValue.arrayUnion(<Map<String, dynamic>>[newMember.toJson()]),
            'memberCount': FieldValue.increment(1),
            'lastActive': FieldValue.serverTimestamp(),
          });

          // Update user's clan ID
          transaction.update(
            _firestore.collection('users').doc(user.uid),
            <String, String>{'clanId': clanId},
          );
        }
      });

      return true;
    } catch (e) {
      print('Error joining clan: $e');
      return false;
    }
  }

  Future<bool> leaveClan(String clanId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    try {
      final clanRef = _firestore.collection('clans').doc(clanId);
      
      await _firestore.runTransaction((transaction) async {
        final clanDoc = await transaction.get(clanRef);
        if (!clanDoc.exists) throw Exception('Clan not found');

        final ClanModel clan = ClanModel.fromJson(clanDoc.data()!);
        
        if (clan.isLeader(user.uid)) {
          // Leader can't leave, must transfer leadership or disband
          throw Exception('Leader cannot leave. Transfer leadership first.');
        }

        // Remove member
        transaction.update(clanRef, <String, >{
          'members': FieldValue.arrayRemove(<Map<String, dynamic>>[clan.getMember(user.uid)!.toJson()]),
          'memberCount': FieldValue.increment(-1),
        });

        // Update user's clan ID
        transaction.update(
          _firestore.collection('users').doc(user.uid),
          <String, Null>{'clanId': null},
        );
      });

      return true;
    } catch (e) {
      print('Error leaving clan: $e');
      return false;
    }
  }

  Future<bool> kickMember(String clanId, String memberId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    try {
      final clanRef = _firestore.collection('clans').doc(clanId);
      
      await _firestore.runTransaction((transaction) async {
        final clanDoc = await transaction.get(clanRef);
        if (!clanDoc.exists) throw Exception('Clan not found');

        final ClanModel clan = ClanModel.fromJson(clanDoc.data()!);
        
        if (!clan.canManage(user.uid)) {
          throw Exception('Not authorized to kick members');
        }

        final ClanMember? member = clan.getMember(memberId);
        if (member == null) throw Exception('Member not found');

        if (member.role == ClanRole.leader) {
          throw Exception('Cannot kick leader');
        }

        if (member.role == ClanRole.coLeader && !clan.isLeader(user.uid)) {
          throw Exception('Only leader can kick co-leaders');
        }

        // Remove member
        transaction.update(clanRef, <String, >{
          'members': FieldValue.arrayRemove(<Map<String, dynamic>>[member.toJson()]),
          'memberCount': FieldValue.increment(-1),
        });

        // Update user's clan ID
        transaction.update(
          _firestore.collection('users').doc(memberId),
          <String, Null>{'clanId': null},
        );
      });

      return true;
    } catch (e) {
      print('Error kicking member: $e');
      return false;
    }
  }

  Future<bool> changeMemberRole(String clanId, String memberId, ClanRole newRole) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    try {
      final clanRef = _firestore.collection('clans').doc(clanId);
      
      await _firestore.runTransaction((transaction) async {
        final clanDoc = await transaction.get(clanRef);
        if (!clanDoc.exists) throw Exception('Clan not found');

        final ClanModel clan = ClanModel.fromJson(clanDoc.data()!);
        
        if (!clan.canManage(user.uid)) {
          throw Exception('Not authorized to change roles');
        }

        final ClanMember? member = clan.getMember(memberId);
        if (member == null) throw Exception('Member not found');

        // Update member role
        final ClanMember updatedMember = ClanMember(
          userId: member.userId,
          username: member.username,
          avatar: member.avatar,
          role: newRole,
          joinedAt: member.joinedAt,
          activityPoints: member.activityPoints,
          donations: member.donations,
          lastActive: member.lastActive,
          warPoints: member.warPoints,
          stats: member.stats,
        );

        // Remove old and add updated
        transaction.update(clanRef, <String, >{
          'members': FieldValue.arrayRemove(<Map<String, dynamic>>[member.toJson()]),
        });
        
        transaction.update(clanRef, <String, >{
          'members': FieldValue.arrayUnion(<Map<String, dynamic>>[updatedMember.toJson()]),
        });
      });

      return true;
    } catch (e) {
      print('Error changing role: $e');
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
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    try {
      final requestRef = _firestore.collection('clan_requests').doc(requestId);
      final requestDoc = await requestRef.get();
      
      if (!requestDoc.exists) throw Exception('Request not found');

      final requestData = requestDoc.data();
      final userId = requestData['userId'];

      await _firestore.runTransaction((transaction) async {
        // Update request status
        transaction.update(requestRef, <String, String>{'status': 'approved'});

        // Add to clan members
        final clanRef = _firestore.collection('clans').doc(clanId);
        final clanDoc = await transaction.get(clanRef);
        
        if (!clanDoc.exists) throw Exception('Clan not found');

        final ClanMember newMember = ClanMember(
          userId: userId,
          username: requestData['username'],
          avatar: requestData['avatar'],
          role: ClanRole.member,
          joinedAt: DateTime.now(),
        );

        transaction.update(clanRef, <String, >{
          'members': FieldValue.arrayUnion(<Map<String, dynamic>>[newMember.toJson()]),
          'memberCount': FieldValue.increment(1),
        });

        // Update user's clan ID
        transaction.update(
          _firestore.collection('users').doc(userId),
          <String, String>{'clanId': clanId},
        );
      });

      return true;
    } catch (e) {
      print('Error approving request: $e');
      return false;
    }
  }

  Future<bool> rejectRequest(String requestId) async {
    try {
      await _firestore
          .collection('clan_requests')
          .doc(requestId)
          .update(<String, String>{'status': 'rejected'});
      return true;
    } catch (e) {
      print('Error rejecting request: $e');
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

        final ClanModel clan = ClanModel.fromJson(clanDoc.data()!);
        final ClanMember? member = clan.getMember(userId);
        
        if (member == null) return;

        final ClanMember updatedMember = ClanMember(
          userId: member.userId,
          username: member.username,
          avatar: member.avatar,
          role: member.role,
          joinedAt: member.joinedAt,
          activityPoints: member.activityPoints + points,
          donations: member.donations,
          lastActive: DateTime.now().millisecondsSinceEpoch,
          warPoints: member.warPoints,
          stats: member.stats,
        );

        // Update member
        transaction.update(clanRef, <String, >{
          'members': FieldValue.arrayRemove(<Map<String, dynamic>>[member.toJson()]),
        });
        
        transaction.update(clanRef, <String, >{
          'members': FieldValue.arrayUnion(<Map<String, dynamic>>[updatedMember.toJson()]),
          'xp': FieldValue.increment(points),
          'lastActive': FieldValue.serverTimestamp(),
        });

        // Check for level up
        final int newXp = clan.xp + points;
        if (newXp >= clan.xpToNextLevel) {
          transaction.update(clanRef, <String, >{
            'level': FieldValue.increment(1),
            'xp': newXp - clan.xpToNextLevel,
            'xpToNextLevel': clan.xpToNextLevel * 2, // Double required XP
          });
        }
      });
    } catch (e) {
      print('Error adding activity points: $e');
    }
  }

  Future<void> addDonation(String clanId, String userId, int amount) async {
    try {
      final clanRef = _firestore.collection('clans').doc(clanId);
      
      await _firestore.runTransaction((transaction) async {
        final clanDoc = await transaction.get(clanRef);
        if (!clanDoc.exists) return;

        final ClanModel clan = ClanModel.fromJson(clanDoc.data()!);
        final ClanMember? member = clan.getMember(userId);
        
        if (member == null) return;

        final ClanMember updatedMember = ClanMember(
          userId: member.userId,
          username: member.username,
          avatar: member.avatar,
          role: member.role,
          joinedAt: member.joinedAt,
          activityPoints: member.activityPoints,
          donations: member.donations + amount,
          lastActive: DateTime.now().millisecondsSinceEpoch,
          warPoints: member.warPoints,
          stats: member.stats,
        );

        transaction.update(clanRef, <String, >{
          'members': FieldValue.arrayRemove(<Map<String, dynamic>>[member.toJson()]),
        });
        
        transaction.update(clanRef, <String, >{
          'members': FieldValue.arrayUnion(<Map<String, dynamic>>[updatedMember.toJson()]),
          'clanCoins': FieldValue.increment(amount),
        });
      });
    } catch (e) {
      print('Error adding donation: $e');
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
          if (!doc.exists) return <dynamic>[];
          final ClanModel clan = ClanModel.fromJson(doc.data()!);
          final List<ClanMember> members = clan.members;
          members.sort((ClanMember a, ClanMember b) => b.activityPoints.compareTo(a.activityPoints));
          return members;
        });
  }
}