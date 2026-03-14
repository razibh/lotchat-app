import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

class AgencyService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ==================== AGENCY OPERATIONS ====================
  Future<Agency?> getAgency(String agencyId) async {
    final DocumentSnapshot<Map<String, dynamic>> doc = await _firestore.collection('agencies').doc(agencyId).get();
    if (doc.exists) {
      return Agency.fromJson(doc.data()!, doc.id);
    }
    return null;
  }

  Future<Agency?> getAgencyByOwner(String ownerId) async {
    final QuerySnapshot<Map<String, dynamic>> query = await _firestore
        .collection('agencies')
        .where('ownerId', isEqualTo: ownerId)
        .limit(1)
        .get();
    
    if (query.docs.isNotEmpty) {
      return Agency.fromJson(query.docs.first.data(), query.docs.first.id);
    }
    return null;
  }

  Stream<Agency?> streamAgency(String agencyId) {
    return _firestore
        .collection('agencies')
        .doc(agencyId)
        .snapshots()
        .map((DocumentSnapshot<Map<String, dynamic>> doc) => doc.exists ? Agency.fromJson(doc.data()!, doc.id) : null);
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
      
      transaction.update(agencyRef, <String, >{
        'members': FieldValue.arrayUnion(<String>[userId]),
      });
      
      transaction.update(
        _firestore.collection('users').doc(userId),
        <String, Object>{
          'agencyId': agencyId,
          'role': UserRole.agency.index,
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
      
      transaction.update(agencyRef, <String, >{
        'members': FieldValue.arrayRemove(<String>[userId]),
      });
      
      transaction.update(
        _firestore.collection('users').doc(userId),
        <String, int?>{
          'agencyId': null,
          'role': UserRole.user.index,
        },
      );
    });
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
        .update(<String, >{
          'coOwners': FieldValue.arrayUnion(<String>[userId]),
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
        .update(<String, >{
          'coOwners': FieldValue.arrayRemove(<String>[userId]),
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
      final commissionRate = data['commissionRate'] ?? 0.1; // Default 10%
      
      final int agencyCommission = (amount * commissionRate).round();
      final int userEarnings = amount - agencyCommission;
      
      // Update agency earnings
      final Map<String, int> memberEarnings = Map<String, int>.from(data['memberEarnings'] ?? <dynamic, dynamic>{});
      memberEarnings[userId] = (memberEarnings[userId] ?? 0) + userEarnings;
      
      transaction.update(agencyRef, <String, >{
        'totalEarnings': FieldValue.increment(agencyCommission),
        'memberEarnings': memberEarnings,
      });
      
      // Record transaction
      transaction.set(
        _firestore.collection('agency_transactions').doc(),
        <String, >{
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
        
        transaction.update(agencyRef, <String, Map<String, int>>{
          'memberEarnings': updatedEarnings,
        });
        
        // Record withdrawal
        transaction.set(
          _firestore.collection('withdrawals').doc(),
          <String, >{
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
      print('Withdrawal error: $e');
      return false;
    }
  }

  // ==================== GET AGENCY MEMBERS ====================
  Future<List<UserModel>> getAgencyMembers(String agencyId) async {
    final Agency? agency = await getAgency(agencyId);
    if (agency == null) return <UserModel>[];
    
    final List<UserModel> members = <UserModel>[];
    for (String memberId in agency.members) {
      final DocumentSnapshot<Map<String, dynamic>> userDoc = await _firestore.collection('users').doc(memberId).get();
      if (userDoc.exists) {
        members.add(UserModel.fromJson(userDoc.data()!));
      }
    }
    
    return members;
  }

  // ==================== AGENCY LEADERBOARD ====================
  Stream<List<AgencyMemberRank>> getAgencyLeaderboard(String agencyId) {
    return _firestore
        .collection('agencies')
        .doc(agencyId)
        .snapshots()
        .map((DocumentSnapshot<Map<String, dynamic>> doc) {
          if (!doc.exists) return <dynamic>[];
          
          final Map<String, dynamic>? data = doc.data();
          final Map<String, int> memberEarnings = Map<String, int>.from(data['memberEarnings'] ?? <dynamic, dynamic>{});
          
          final ranks = <AgencyMemberRank><AgencyMemberRank><dynamic>[];
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
      (int sum, QueryDocumentSnapshot<Map<String, dynamic>> doc) => sum + (doc.data()['agencyCommission'] ?? 0),
    );
    
    // Get this month's earnings
    final DateTime startOfMonth = DateTime(today.year, today.month);
    
    final QuerySnapshot<Map<String, dynamic>> monthTransactions = await _firestore
        .collection('agency_transactions')
        .where('agencyId', isEqualTo: agencyId)
        .where('timestamp', isGreaterThanOrEqualTo: startOfMonth)
        .get();
    
    final int monthEarnings = monthTransactions.docs.fold<int>(
      0,
      (int sum, QueryDocumentSnapshot<Map<String, dynamic>> doc) => sum + (doc.data()['agencyCommission'] ?? 0),
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
    final AggregateQuerySnapshot snapshot = await _firestore
        .collection('users')
        .where('agencyId', isEqualTo: agencyId)
        .where('isOnline', isEqualTo: true)
        .count()
        .get();
    
    return snapshot.count ?? 0;
  }
}

// ==================== MODEL CLASSES ====================

class Agency {
  
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
      coOwners: List<String>.from(json['coOwners'] ?? <dynamic>[]),
      members: List<String>.from(json['members'] ?? <dynamic>[]),
      commissionRate: (json['commissionRate'] ?? 0.1).toDouble(),
      totalEarnings: json['totalEarnings'] ?? 0,
      memberEarnings: Map<String, int>.from(json['memberEarnings'] ?? <dynamic, dynamic>{}),
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      status: json['status'] ?? 'active',
    );
  }
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
}

class AgencyMemberRank {
  
  AgencyMemberRank({required this.userId, required this.earnings});
  final String userId;
  final int earnings;
}

class AgencyStats {
  
  AgencyStats({
    required this.totalEarnings,
    required this.todayEarnings,
    required this.monthEarnings,
    required this.memberCount,
    required this.activeMembers,
  });
  final int totalEarnings;
  final int todayEarnings;
  final int monthEarnings;
  final int memberCount;
  final int activeMembers;
}