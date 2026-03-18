import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/user_models.dart' as app;

// AgencyRole enum
enum AgencyRole {
  leader,
  coLeader,
  elder,
  member,
}

class AgencyService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ==================== AGENCY OPERATIONS ====================
  Future<Agency?> getAgency(String agencyId) async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> doc = await _firestore.collection('agencies').doc(agencyId).get();
      if (doc.exists) {
        return Agency.fromJson(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting agency: $e');
      return null;
    }
  }

  Future<Agency?> getAgencyByOwner(String ownerId) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> query = await _firestore
          .collection('agencies')
          .where('ownerId', isEqualTo: ownerId)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        return Agency.fromJson(query.docs.first.data(), query.docs.first.id);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting agency by owner: $e');
      return null;
    }
  }

  Stream<Agency?> streamAgency(String agencyId) {
    return _firestore
        .collection('agencies')
        .doc(agencyId)
        .snapshots()
        .map((DocumentSnapshot<Map<String, dynamic>> doc) {
      if (doc.exists) {
        return Agency.fromJson(doc.data()!, doc.id);
      }
      return null;
    });
  }

  // ==================== MEMBER MANAGEMENT ====================
  Future<void> addMember(String agencyId, String userId) async {
    final Agency? agency = await getAgency(agencyId);
    if (agency == null) throw Exception('Agency not found');

    final User? currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception('Not logged in');

    // Check if current user is owner or co-owner
    if (currentUser.uid != agency.ownerId && !agency.coOwners.contains(currentUser.uid)) {
      throw Exception('Unauthorized');
    }

    await _firestore.runTransaction((Transaction transaction) async {
      final DocumentReference<Map<String, dynamic>> agencyRef = _firestore.collection('agencies').doc(agencyId);

      transaction.update(agencyRef, {
        'members': FieldValue.arrayUnion([userId]),
      });

      transaction.update(
        _firestore.collection('users').doc(userId),
        {
          'agencyId': agencyId,
          'role': 'agency',
        },
      );
    });
  }

  Future<void> removeMember(String agencyId, String userId) async {
    final Agency? agency = await getAgency(agencyId);
    if (agency == null) throw Exception('Agency not found');

    final User? currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception('Not logged in');

    // Check if current user is owner or co-owner
    if (currentUser.uid != agency.ownerId && !agency.coOwners.contains(currentUser.uid)) {
      throw Exception('Unauthorized');
    }

    await _firestore.runTransaction((Transaction transaction) async {
      final DocumentReference<Map<String, dynamic>> agencyRef = _firestore.collection('agencies').doc(agencyId);

      transaction.update(agencyRef, {
        'members': FieldValue.arrayRemove([userId]),
      });

      transaction.update(
        _firestore.collection('users').doc(userId),
        {
          'agencyId': null,
          'role': 'user',
        },
      );
    });
  }

  // 🟢 ADD: Change member role
  Future<void> changeMemberRole(
      String agencyId,
      String userId,
      AgencyRole newRole,
      ) async {
    try {
      final Agency? agency = await getAgency(agencyId);
      if (agency == null) throw Exception('Agency not found');

      final User? currentUser = _auth.currentUser;
      if (currentUser == null) throw Exception('Not logged in');

      // Check if current user is owner or co-owner
      if (currentUser.uid != agency.ownerId && !agency.coOwners.contains(currentUser.uid)) {
        throw Exception('Unauthorized');
      }

      // Update user's role in users collection
      await _firestore.collection('users').doc(userId).update({
        'agencyRole': newRole.toString().split('.').last,
      });

      debugPrint('Changed role for user $userId in agency $agencyId to $newRole');
    } catch (e) {
      debugPrint('Error changing member role: $e');
      rethrow;
    }
  }

  // ==================== CO-OWNER MANAGEMENT ====================
  Future<void> addCoOwner(String agencyId, String userId) async {
    final Agency? agency = await getAgency(agencyId);
    if (agency == null) throw Exception('Agency not found');

    final User? currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception('Not logged in');

    // Only owner can add co-owners
    if (currentUser.uid != agency.ownerId) {
      throw Exception('Only owner can add co-owners');
    }

    await _firestore
        .collection('agencies')
        .doc(agencyId)
        .update({
      'coOwners': FieldValue.arrayUnion([userId]),
    });
  }

  Future<void> removeCoOwner(String agencyId, String userId) async {
    final Agency? agency = await getAgency(agencyId);
    if (agency == null) throw Exception('Agency not found');

    final User? currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception('Not logged in');

    // Only owner can remove co-owners
    if (currentUser.uid != agency.ownerId) {
      throw Exception('Only owner can remove co-owners');
    }

    await _firestore
        .collection('agencies')
        .doc(agencyId)
        .update({
      'coOwners': FieldValue.arrayRemove([userId]),
    });
  }

  // ==================== EARNINGS MANAGEMENT ====================
  Future<void> recordEarnings({
    required String agencyId,
    required String userId,
    required int amount,
    required String source,
  }) async {
    await _firestore.runTransaction((Transaction transaction) async {
      final DocumentReference<Map<String, dynamic>> agencyRef = _firestore.collection('agencies').doc(agencyId);
      final DocumentSnapshot<Map<String, dynamic>> agencyDoc = await transaction.get(agencyRef);

      if (!agencyDoc.exists) return;

      final Map<String, dynamic>? data = agencyDoc.data();
      final commissionRate = data?['commissionRate'] ?? 0.1; // Default 10%

      final int agencyCommission = (amount * commissionRate).round();
      final int userEarnings = amount - agencyCommission;

      // Update agency earnings
      final Map<String, int> memberEarnings = Map<String, int>.from(data?['memberEarnings'] ?? {});
      memberEarnings[userId] = (memberEarnings[userId] ?? 0) + userEarnings;

      transaction.update(agencyRef, {
        'totalEarnings': FieldValue.increment(agencyCommission),
        'memberEarnings': memberEarnings,
      });

      // Record transaction
      transaction.set(
        _firestore.collection('agency_transactions').doc(),
        {
          'agencyId': agencyId,
          'userId': userId,
          'amount': amount,
          'agencyCommission': agencyCommission,
          'userEarnings': userEarnings,
          'source': source,
          'timestamp': FieldValue.serverTimestamp(),
        },
      );
    });
  }

  // ==================== WITHDRAW EARNINGS ====================
  Future<bool> withdrawEarnings({
    required String agencyId,
    required String userId,
    required int amount,
  }) async {
    try {
      final Agency? agency = await getAgency(agencyId);
      if (agency == null) throw Exception('Agency not found');

      final int userEarnings = agency.memberEarnings[userId] ?? 0;
      if (userEarnings < amount) throw Exception('Insufficient earnings');

      await _firestore.runTransaction((Transaction transaction) async {
        final DocumentReference<Map<String, dynamic>> agencyRef = _firestore.collection('agencies').doc(agencyId);

        // Update member earnings
        final Map<String, int> updatedEarnings = Map<String, int>.from(agency.memberEarnings);
        updatedEarnings[userId] = userEarnings - amount;

        transaction.update(agencyRef, {
          'memberEarnings': updatedEarnings,
        });

        // Record withdrawal
        transaction.set(
          _firestore.collection('withdrawals').doc(),
          {
            'agencyId': agencyId,
            'userId': userId,
            'amount': amount,
            'status': 'pending',
            'timestamp': FieldValue.serverTimestamp(),
          },
        );
      });

      return true;
    } catch (e) {
      debugPrint('Withdrawal error: $e');
      return false;
    }
  }

  // 🟢 ADD: Get member earnings history
  Future<List<Map<String, dynamic>>> getMemberEarnings(
      String agencyId,
      String userId,
      ) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> earnings = await _firestore
          .collection('agency_transactions')
          .where('agencyId', isEqualTo: agencyId)
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .limit(20)
          .get();

      return earnings.docs.map((doc) {
        final data = doc.data();
        return {
          'amount': data['userEarnings'] ?? 0,
          'description': data['source'] ?? 'Earning',
          'timestamp': (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
        };
      }).toList();
    } catch (e) {
      debugPrint('Error getting member earnings: $e');

      // Return mock data for testing
      return [
        {
          'amount': 5000,
          'description': 'Commission from hosting',
          'timestamp': DateTime.now().subtract(const Duration(days: 1)),
        },
        {
          'amount': 3000,
          'description': 'Gift received',
          'timestamp': DateTime.now().subtract(const Duration(days: 3)),
        },
        {
          'amount': 2000,
          'description': 'Game winnings',
          'timestamp': DateTime.now().subtract(const Duration(days: 5)),
        },
      ];
    }
  }

  // ==================== GET AGENCY MEMBERS ====================
  Future<List<app.User>> getAgencyMembers(String agencyId) async {
    try {
      final Agency? agency = await getAgency(agencyId);
      if (agency == null) return [];

      final List<app.User> members = [];
      for (String memberId in agency.members) {
        final DocumentSnapshot<Map<String, dynamic>> userDoc = await _firestore.collection('users').doc(memberId).get();
        if (userDoc.exists) {
          final data = userDoc.data()!;
          data['id'] = userDoc.id;
          members.add(app.User.fromJson(data));
        }
      }

      return members;
    } catch (e) {
      debugPrint('Error getting agency members: $e');
      return [];
    }
  }

  // ==================== AGENCY LEADERBOARD ====================
  Stream<List<AgencyMemberRank>> getAgencyLeaderboard(String agencyId) {
    return _firestore
        .collection('agencies')
        .doc(agencyId)
        .snapshots()
        .map((DocumentSnapshot<Map<String, dynamic>> doc) {
      if (!doc.exists) return [];

      final Map<String, dynamic>? data = doc.data();
      final Map<String, int> memberEarnings = Map<String, int>.from(data?['memberEarnings'] ?? {});

      final List<AgencyMemberRank> ranks = [];
      memberEarnings.forEach((String userId, int earnings) {
        ranks.add(AgencyMemberRank(userId: userId, earnings: earnings));
      });

      ranks.sort((AgencyMemberRank a, AgencyMemberRank b) => b.earnings.compareTo(a.earnings));
      return ranks;
    });
  }

  // ==================== AGENCY STATS ====================
  Future<AgencyStats> getAgencyStats(String agencyId) async {
    final Agency? agency = await getAgency(agencyId);
    if (agency == null) throw Exception('Agency not found');

    // Get today's earnings
    final DateTime today = DateTime.now();
    final DateTime startOfDay = DateTime(today.year, today.month, today.day);

    final QuerySnapshot<Map<String, dynamic>> todayTransactions = await _firestore
        .collection('agency_transactions')
        .where('agencyId', isEqualTo: agencyId)
        .where('timestamp', isGreaterThanOrEqualTo: startOfDay)
        .get();

    final int todayEarnings = todayTransactions.docs.fold<int>(
      0,
          (int sum, QueryDocumentSnapshot<Map<String, dynamic>> doc) {
        final num value = doc.data()['agencyCommission'] ?? 0;
        return sum + value.toInt();
      },
    );

    // Get this month's earnings
    final DateTime startOfMonth = DateTime(today.year, today.month, 1);

    final QuerySnapshot<Map<String, dynamic>> monthTransactions = await _firestore
        .collection('agency_transactions')
        .where('agencyId', isEqualTo: agencyId)
        .where('timestamp', isGreaterThanOrEqualTo: startOfMonth)
        .get();

    final int monthEarnings = monthTransactions.docs.fold<int>(
      0,
          (int sum, QueryDocumentSnapshot<Map<String, dynamic>> doc) {
        final num value = doc.data()['agencyCommission'] ?? 0;
        return sum + value.toInt();
      },
    );

    return AgencyStats(
      totalEarnings: agency.totalEarnings,
      todayEarnings: todayEarnings,
      monthEarnings: monthEarnings,
      memberCount: agency.members.length,
      activeMembers: await _getActiveMembers(agencyId),
    );
  }

  Future<int> _getActiveMembers(String agencyId) async {
    try {
      final AggregateQuerySnapshot snapshot = await _firestore
          .collection('users')
          .where('agencyId', isEqualTo: agencyId)
          .where('isOnline', isEqualTo: true)
          .count()
          .get();

      return snapshot.count ?? 0;
    } catch (e) {
      debugPrint('Error getting active members: $e');
      return 0;
    }
  }
}

// ==================== MODEL CLASSES ====================

class Agency {
  final String id;
  final String name;
  final String ownerId;
  final List<String> coOwners;
  final List<String> members;
  final double commissionRate;
  final int totalEarnings;
  final Map<String, int> memberEarnings;
  final DateTime createdAt;
  final String status;

  Agency({
    required this.id,
    required this.name,
    required this.ownerId,
    required this.coOwners,
    required this.members,
    required this.commissionRate,
    required this.totalEarnings,
    required this.memberEarnings,
    required this.createdAt,
    required this.status,
  });

  factory Agency.fromJson(Map<String, dynamic> json, String id) {
    return Agency(
      id: id,
      name: json['name'] ?? '',
      ownerId: json['ownerId'] ?? '',
      coOwners: List<String>.from(json['coOwners'] ?? []),
      members: List<String>.from(json['members'] ?? []),
      commissionRate: (json['commissionRate'] ?? 0.1).toDouble(),
      totalEarnings: json['totalEarnings'] ?? 0,
      memberEarnings: Map<String, int>.from(json['memberEarnings'] ?? {}),
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      status: json['status'] ?? 'active',
    );
  }
}

class AgencyMemberRank {
  final String userId;
  final int earnings;

  AgencyMemberRank({required this.userId, required this.earnings});
}

class AgencyStats {
  final int totalEarnings;
  final int todayEarnings;
  final int monthEarnings;
  final int memberCount;
  final int activeMembers;

  AgencyStats({
    required this.totalEarnings,
    required this.todayEarnings,
    required this.monthEarnings,
    required this.memberCount,
    required this.activeMembers,
  });
}