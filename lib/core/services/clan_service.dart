import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/clan_model.dart';
import '../models/user_model.dart';
import '../di/service_locator.dart';
import 'database_service.dart';
import 'upload_service.dart';
import 'notification_service.dart';

class ClanService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseService _databaseService = ServiceLocator().get<DatabaseService>();
  final UploadService _uploadService = ServiceLocator().get<UploadService>();
  final NotificationService _notificationService = ServiceLocator().get<NotificationService>();

  // Create clan
  Future<ClanModel?> createClan({
    required String name,
    String? description,
    String? rules,
    String? emblemPath,
    ClanJoinType joinType = ClanJoinType.open,
    List<String> tags = const <String>[],
    int maxMembers = 50,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    try {
      String? emblemUrl;
      if (emblemPath != null) {
        emblemUrl = await _uploadService.uploadFile(
          filePath: emblemPath,
          folder: 'clans/${user.uid}',
          fileName: 'emblem_${DateTime.now().millisecondsSinceEpoch}',
        );
      }

      final ClanModel clanData = ClanModel(
        id: '',
        name: name,
        description: description,
        rules: rules,
        emblem: emblemUrl,
        leaderId: user.uid,
        members: <>[
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
        maxMembers: maxMembers,
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

      // Log activity
      await _addActivityLog(
        clanId: docRef.id,
        userId: user.uid,
        action: 'created_clan',
        details: <String, dynamic>{'name': name},
      );

      return clanData.copyWith(id: docRef.id);
    } catch (e) {
      print('Error creating clan: $e');
      return null;
    }
  }

  // Get clan
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

  // Stream clan
  Stream<ClanModel?> streamClan(String clanId) {
    return _firestore
        .collection('clans')
        .doc(clanId)
        .snapshots()
        .map((doc) => doc.exists ? ClanModel.fromJson(doc.data()!) : null);
  }

  // Update clan
  Future<bool> updateClan(String clanId, Map<String, dynamic> updates) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    try {
      final ClanModel? clan = await getClan(clanId);
      if (clan == null) throw Exception('Clan not found');

      // Check permission
      if (!clan.canManage(user.uid)) {
        throw Exception('Not authorized to update clan');
      }

      await _firestore.collection('clans').doc(clanId).update(updates);
      
      await _addActivityLog(
        clanId: clanId,
        userId: user.uid,
        action: 'updated_clan',
        details: updates,
      );

      return true;
    } catch (e) {
      print('Error updating clan: $e');
      return false;
    }
  }

  // Search clans
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

  // Get recommended clans
  Future<List<ClanModel>> getRecommendedClans(String userId, {int limit = 10}) async {
    try {
      final UserModel? user = await _databaseService.getUser(userId);
      if (user == null) return <ClanModel>[];

      // Get clans with matching tags or from same country
      final snapshot = await _firestore
          .collection('clans')
          .where('isActive', isEqualTo: true)
          .orderBy('level', descending: true)
          .limit(limit * 2)
          .get();

      final clans = snapshot.docs
          .map((doc) => ClanModel.fromJson(doc.data()))
          .where((c) => !c.members.any((m) => m.userId == userId))
          .toList();

      // Score and sort
      clans.sort((a, b) {
        var scoreA = _calculateClanScore(a, user);
        var scoreB = _calculateClanScore(b, user);
        return scoreB.compareTo(scoreA);
      });

      return clans.take(limit).toList();
    } catch (e) {
      print('Error getting recommended clans: $e');
      return <ClanModel>[];
    }
  }

  int _calculateClanScore(ClanModel clan, UserModel user) {
    var score = 0;
    
    // Match by country
    if (clan.members.any((String m) => m.country == user.country)) {
      score += 30;
    }
    
    // Match by interests
    for (String member in clan.members) {
      final commonInterests = member.interests
          .where((i) => user.interests.contains(i))
          .length;
      score += commonInterests * 5;
    }
    
    // Clan level
    score += clan.level * 2;
    
    // Activity
    score += clan.totalActivity ~/ 1000;
    
    return score;
  }

  // Join clan
  Future<bool> joinClan(String clanId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    try {
      final clanRef = _firestore.collection('clans').doc(clanId);
      
      return await _firestore.runTransaction((transaction) async {
        final clanDoc = await transaction.get(clanRef);
        if (!clanDoc.exists) throw Exception('Clan not found');

        final clan = ClanModel.fromJson(clanDoc.data()!);
        
        if (clan.isFull) throw Exception('Clan is full');
        if (clan.members.any((m) => m.userId == user.uid)) {
          throw Exception('Already a member');
        }

        if (clan.joinType == ClanJoinType.approval) {
          // Add to join requests
          await _firestore.collection('clan_requests').add(<String, >{
            'clanId': clanId,
            'userId': user.uid,
            'username': user.displayName,
            'avatar': user.photoURL,
            'status': 'pending',
            'timestamp': FieldValue.serverTimestamp(),
          });
          
          // Notify clan leaders
          await _notifyClanLeaders(clanId, 'new_join_request', <String, dynamic>{
            'userId': user.uid,
            'username': user.displayName,
          });
          
          return true;
        } else if (clan.joinType == ClanJoinType.open) {
          // Direct join
          final UserModel? userData = await _databaseService.getUser(user.uid);
          
          final newMember = ClanMember(
            userId: user.uid,
            username: user.displayName ?? 'User',
            avatar: user.photoURL,
            role: ClanRole.member,
            joinedAt: DateTime.now(),
            interests: userData?.interests ?? <String>[],
            country: userData?.country ?? '',
          );

          transaction.update(clanRef, <String, >{
            'members': FieldValue.arrayUnion(<>[newMember.toJson()]),
            'memberCount': FieldValue.increment(1),
            'lastActive': FieldValue.serverTimestamp(),
          });

          // Update user's clan ID
          transaction.update(
            _firestore.collection('users').doc(user.uid),
            <String, String>{'clanId': clanId},
          );

          await _addActivityLog(
            clanId: clanId,
            userId: user.uid,
            action: 'joined_clan',
          );

          return true;
        } else {
          throw Exception('This clan is invite only');
        }
      });
    } catch (e) {
      print('Error joining clan: $e');
      return false;
    }
  }

  // Leave clan
  Future<bool> leaveClan(String clanId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    try {
      final clanRef = _firestore.collection('clans').doc(clanId);
      
      return await _firestore.runTransaction((transaction) async {
        final clanDoc = await transaction.get(clanRef);
        if (!clanDoc.exists) throw Exception('Clan not found');

        final clan = ClanModel.fromJson(clanDoc.data()!);
        
        if (clan.isLeader(user.uid)) {
          // Leader can't leave, must transfer leadership
          throw Exception('Leader cannot leave. Transfer leadership first.');
        }

        // Remove member
        final member = clan.getMember(user.uid);
        if (member == null) throw Exception('Not a member');

        transaction.update(clanRef, <String, >{
          'members': FieldValue.arrayRemove(<>[member.toJson()]),
          'memberCount': FieldValue.increment(-1),
        });

        // Update user's clan ID
        transaction.update(
          _firestore.collection('users').doc(user.uid),
          <String, Null>{'clanId': null},
        );

        await _addActivityLog(
          clanId: clanId,
          userId: user.uid,
          action: 'left_clan',
        );

        return true;
      });
    } catch (e) {
      print('Error leaving clan: $e');
      return false;
    }
  }

  // Kick member
  Future<bool> kickMember(String clanId, String memberId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    try {
      final clanRef = _firestore.collection('clans').doc(clanId);
      
      return await _firestore.runTransaction((transaction) async {
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

        transaction.update(clanRef, <String, >{
          'members': FieldValue.arrayRemove(<>[member.toJson()]),
          'memberCount': FieldValue.increment(-1),
        });

        transaction.update(
          _firestore.collection('users').doc(memberId),
          <String, Null>{'clanId': null},
        );

        await _addActivityLog(
          clanId: clanId,
          userId: user.uid,
          action: 'kicked_member',
          details: <String, dynamic>{'memberId': memberId},
        );

        return true;
      });
    } catch (e) {
      print('Error kicking member: $e');
      return false;
    }
  }

  // Change member role
  Future<bool> changeMemberRole(String clanId, String memberId, ClanRole newRole) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    try {
      final clanRef = _firestore.collection('clans').doc(clanId);
      
      return await _firestore.runTransaction((transaction) async {
        final clanDoc = await transaction.get(clanRef);
        if (!clanDoc.exists) throw Exception('Clan not found');

        final clan = ClanModel.fromJson(clanDoc.data()!);
        
        if (!clan.canManage(user.uid)) {
          throw Exception('Not authorized to change roles');
        }

        final member = clan.getMember(memberId);
        if (member == null) throw Exception('Member not found');

        final updatedMember = ClanMember(
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
          interests: member.interests,
          country: member.country,
        );

        transaction.update(clanRef, <String, >{
          'members': FieldValue.arrayRemove(<>[member.toJson()]),
        });
        
        transaction.update(clanRef, <String, >{
          'members': FieldValue.arrayUnion(<>[updatedMember.toJson()]),
        });

        await _addActivityLog(
          clanId: clanId,
          userId: user.uid,
          action: 'changed_role',
          details: <String, dynamic>{'memberId': memberId, 'newRole': newRole.toString()},
        );

        return true;
      });
    } catch (e) {
      print('Error changing role: $e');
      return false;
    }
  }

  // Transfer leadership
  Future<bool> transferLeadership(String clanId, String newLeaderId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    try {
      final clanRef = _firestore.collection('clans').doc(clanId);
      
      return await _firestore.runTransaction((transaction) async {
        final clanDoc = await transaction.get(clanRef);
        if (!clanDoc.exists) throw Exception('Clan not found');

        final clan = ClanModel.fromJson(clanDoc.data()!);
        
        if (!clan.isLeader(user.uid)) {
          throw Exception('Only leader can transfer leadership');
        }

        final currentLeader = clan.getMember(user.uid);
        final newLeader = clan.getMember(newLeaderId);
        
        if (currentLeader == null || newLeader == null) {
          throw Exception('Member not found');
        }

        // Remove current leader
        transaction.update(clanRef, <String, >{
          'members': FieldValue.arrayRemove(<>[currentLeader.toJson()]),
        });

        // Remove new leader
        transaction.update(clanRef, <String, >{
          'members': FieldValue.arrayRemove(<>[newLeader.toJson()]),
        });

        // Add updated members
        final updatedCurrentLeader = ClanMember(
          userId: currentLeader.userId,
          username: currentLeader.username,
          avatar: currentLeader.avatar,
          role: ClanRole.coLeader,
          joinedAt: currentLeader.joinedAt,
          activityPoints: currentLeader.activityPoints,
          donations: currentLeader.donations,
          lastActive: currentLeader.lastActive,
          warPoints: currentLeader.warPoints,
          stats: currentLeader.stats,
          interests: currentLeader.interests,
          country: currentLeader.country,
        );

        final updatedNewLeader = ClanMember(
          userId: newLeader.userId,
          username: newLeader.username,
          avatar: newLeader.avatar,
          role: ClanRole.leader,
          joinedAt: newLeader.joinedAt,
          activityPoints: newLeader.activityPoints,
          donations: newLeader.donations,
          lastActive: newLeader.lastActive,
          warPoints: newLeader.warPoints,
          stats: newLeader.stats,
          interests: newLeader.interests,
          country: newLeader.country,
        );

        transaction.update(clanRef, <String, >{
          'members': FieldValue.arrayUnion(<>[updatedCurrentLeader.toJson()]),
        });
        
        transaction.update(clanRef, <String, >{
          'members': FieldValue.arrayUnion(<>[updatedNewLeader.toJson()]),
        });

        await _addActivityLog(
          clanId: clanId,
          userId: user.uid,
          action: 'transferred_leadership',
          details: <String, dynamic>{'newLeaderId': newLeaderId},
        );

        return true;
      });
    } catch (e) {
      print('Error transferring leadership: $e');
      return false;
    }
  }

  // Join requests
  Stream<List<Map<String, dynamic>>> getJoinRequests(String clanId) {
    return _firestore
        .collection('clan_requests')
        .where('clanId', isEqualTo: clanId)
        .where('status', isEqualTo: 'pending')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
          final data = doc.data();
          data['requestId'] = doc.id;
          return data;
        }).toList());
  }

  // Approve request
  Future<bool> approveRequest(String requestId, String clanId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    try {
      final requestRef = _firestore.collection('clan_requests').doc(requestId);
      final requestDoc = await requestRef.get();
      
      if (!requestDoc.exists) throw Exception('Request not found');

      final requestData = requestDoc.data();
      final userId = requestData['userId'];

      return await _firestore.runTransaction((transaction) async {
        // Update request status
        transaction.update(requestRef, <String, String>{'status': 'approved'});

        // Get user data
        final userDoc = await transaction.get(
          _firestore.collection('users').doc(userId)
        );
        final userData = userDoc.data();

        // Add to clan members
        final clanRef = _firestore.collection('clans').doc(clanId);
        final clanDoc = await transaction.get(clanRef);
        
        if (!clanDoc.exists) throw Exception('Clan not found');

        final newMember = ClanMember(
          userId: userId,
          username: requestData['username'] ?? userData['username'],
          avatar: requestData['avatar'] ?? userData['photoURL'],
          role: ClanRole.member,
          joinedAt: DateTime.now(),
          interests: userData['interests']?.cast<String>() ?? <dynamic>[],
          country: userData['country'] ?? '',
        );

        transaction.update(clanRef, <String, >{
          'members': FieldValue.arrayUnion(<>[newMember.toJson()]),
          'memberCount': FieldValue.increment(1),
        });

        // Update user's clan ID
        transaction.update(
          _firestore.collection('users').doc(userId),
          <String, String>{'clanId': clanId},
        );

        // Send notification
        await _notificationService.sendNotification(
          userId: userId,
          type: 'clan',
          title: 'Request Approved',
          body: 'Your request to join the clan has been approved!',
          data: <String, String>{'clanId': clanId},
        );

        return true;
      });
    } catch (e) {
      print('Error approving request: $e');
      return false;
    }
  }

  // Reject request
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

  // Add activity points
  Future<void> addActivityPoints(String clanId, String userId, int points) async {
    try {
      final clanRef = _firestore.collection('clans').doc(clanId);
      
      await _firestore.runTransaction((transaction) async {
        final clanDoc = await transaction.get(clanRef);
        if (!clanDoc.exists) return;

        final clan = ClanModel.fromJson(clanDoc.data()!);
        final member = clan.getMember(userId);
        
        if (member == null) return;

        final updatedMember = ClanMember(
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
          interests: member.interests,
          country: member.country,
        );

        transaction.update(clanRef, <String, >{
          'members': FieldValue.arrayRemove(<>[member.toJson()]),
        });
        
        transaction.update(clanRef, <String, >{
          'members': FieldValue.arrayUnion(<>[updatedMember.toJson()]),
          'xp': FieldValue.increment(points),
          'lastActive': FieldValue.serverTimestamp(),
        });

        // Check for level up
        final newXp = clan.xp + points;
        if (newXp >= clan.xpToNextLevel) {
          transaction.update(clanRef, <String, >{
            'level': FieldValue.increment(1),
            'xp': newXp - clan.xpToNextLevel,
            'xpToNextLevel': clan.xpToNextLevel * 2,
          });

          // Notify members about level up
          await _notifyClanMembers(clanId, 'clan_level_up', <String, dynamic>{
            'newLevel': clan.level + 1,
          });
        }
      });
    } catch (e) {
      print('Error adding activity points: $e');
    }
  }

  // Add donation
  Future<void> addDonation(String clanId, String userId, int amount) async {
    try {
      final clanRef = _firestore.collection('clans').doc(clanId);
      
      await _firestore.runTransaction((transaction) async {
        final clanDoc = await transaction.get(clanRef);
        if (!clanDoc.exists) return;

        final clan = ClanModel.fromJson(clanDoc.data()!);
        final member = clan.getMember(userId);
        
        if (member == null) return;

        final updatedMember = ClanMember(
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
          interests: member.interests,
          country: member.country,
        );

        transaction.update(clanRef, <String, >{
          'members': FieldValue.arrayRemove(<>[member.toJson()]),
        });
        
        transaction.update(clanRef, <String, >{
          'members': FieldValue.arrayUnion(<>[updatedMember.toJson()]),
          'clanCoins': FieldValue.increment(amount),
        });
      });
    } catch (e) {
      print('Error adding donation: $e');
    }
  }

  // Get top clans
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

  // Get top members
  Stream<List<ClanMember>> getTopMembers(String clanId) {
    return _firestore
        .collection('clans')
        .doc(clanId)
        .snapshots()
        .map((doc) {
          if (!doc.exists) return <dynamic>[];
          final clan = ClanModel.fromJson(doc.data()!);
          final members = List<ClanMember>.from(clan.members);
          members.sort((Object? a, Object? b) => b.activityPoints.compareTo(a.activityPoints));
          return members;
        });
  }

  // Add activity log
  Future<void> _addActivityLog({
    required String clanId,
    required String userId,
    required String action,
    Map<String, dynamic>? details,
  }) async {
    await _firestore.collection('clan_activity').add(<String, >{
      'clanId': clanId,
      'userId': userId,
      'action': action,
      'details': details,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // Get activity logs
  Stream<List<Map<String, dynamic>>> getActivityLogs(String clanId, {int limit = 50}) {
    return _firestore
        .collection('clan_activity')
        .where('clanId', isEqualTo: clanId)
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  // Notify clan leaders
  Future<void> _notifyClanLeaders(String clanId, String type, Map<String, dynamic> data) async {
    final ClanModel? clan = await getClan(clanId);
    if (clan == null) return;

    final List<String> leaders = clan.members
        .where((String m) => m.role == ClanRole.leader || m.role == ClanRole.coLeader)
        .toList();

    for (String leader in leaders) {
      await _notificationService.sendNotification(
        userId: leader.userId,
        type: 'clan',
        title: 'Clan Update',
        body: _getNotificationMessage(type, data),
        data: <String, dynamic>{'clanId': clanId, ...data},
      );
    }
  }

  // Notify all clan members
  Future<void> _notifyClanMembers(String clanId, String type, Map<String, dynamic> data) async {
    final ClanModel? clan = await getClan(clanId);
    if (clan == null) return;

    for (String member in clan.members) {
      await _notificationService.sendNotification(
        userId: member.userId,
        type: 'clan',
        title: 'Clan Update',
        body: _getNotificationMessage(type, data),
        data: <String, dynamic>{'clanId': clanId, ...data},
      );
    }
  }

  String _getNotificationMessage(String type, Map<String, dynamic> data) {
    switch (type) {
      case 'new_join_request':
        return '${data['username']} wants to join the clan';
      case 'clan_level_up':
        return 'Clan reached level ${data['newLevel']}!';
      case 'war_started':
        return 'Clan war has started!';
      case 'war_victory':
        return 'Clan won the war!';
      default:
        return 'Clan update';
    }
  }
}