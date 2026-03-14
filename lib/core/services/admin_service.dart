import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import 'database_service.dart';

class AdminService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseService _databaseService = DatabaseService();

  // ==================== CHECK ADMIN ====================
  Future<bool> isAdmin(String userId) async {
    final UserModel? user = await _databaseService.getUser(userId);
    return user?.role == UserRole.admin || user?.role == UserRole.superAdmin;
  }

  Future<void> _checkAdmin() async {
    final User? user = _auth.currentUser;
    if (user == null) throw Exception('Not logged in');
    
    final bool isAdminUser = await isAdmin(user.uid);
    if (!isAdminUser) throw Exception('Unauthorized: Admin access required');
  }

  // ==================== USER MANAGEMENT ====================
  Future<List<UserModel>> getAllUsers({
    int limit = 100,
    String? lastDocId,
  }) async {
    await _checkAdmin();
    
    Query<Map<String, dynamic>> query = _firestore
        .collection('users')
        .orderBy('createdAt', descending: true)
        .limit(limit);
    
    if (lastDocId != null) {
      final DocumentSnapshot<Map<String, dynamic>> lastDoc = await _firestore.collection('users').doc(lastDocId).get();
      query = query.startAfterDocument(lastDoc);
    }
    
    final QuerySnapshot<Map<String, dynamic>> snapshot = await query.get();
    return snapshot.docs
        .map((QueryDocumentSnapshot<Map<String, dynamic>> doc) => UserModel.fromJson(doc.data()))
        .toList();
  }

  Future<List<UserModel>> searchUsers(String query) async {
    await _checkAdmin();
    
    // Search by username, email, or phone
    final QuerySnapshot<Map<String, dynamic>> usernameQuery = await _firestore
        .collection('users')
        .where('username', isGreaterThanOrEqualTo: query)
        .where('username', isLessThanOrEqualTo: '$query\uf8ff')
        .limit(20)
        .get();
    
    final QuerySnapshot<Map<String, dynamic>> emailQuery = await _firestore
        .collection('users')
        .where('email', isEqualTo: query)
        .get();
    
    final QuerySnapshot<Map<String, dynamic>> phoneQuery = await _firestore
        .collection('users')
        .where('phone', isEqualTo: query)
        .get();
    
    final results = <String, UserModel><String;
    final UserModel><dynamic, dynamic>{};
    
    for (final QueryDocumentSnapshot<Map<String, dynamic>> doc in usernameQuery.docs) {
      results[doc.id] = UserModel.fromJson(doc.data());
    }
    
    for (final QueryDocumentSnapshot<Map<String, dynamic>> doc in emailQuery.docs) {
      if (!results.containsKey(doc.id)) {
        results[doc.id] = UserModel.fromJson(doc.data());
      }
    }
    
    for (final QueryDocumentSnapshot<Map<String, dynamic>> doc in phoneQuery.docs) {
      if (!results.containsKey(doc.id)) {
        results[doc.id] = UserModel.fromJson(doc.data());
      }
    }
    
    return results.values.toList();
  }

  // ==================== BAN/UNBAN USER ====================
  Future<void> banUser({
    required String userId,
    required String reason,
    int durationDays = 0, // 0 = permanent
  }) async {
    await _checkAdmin();
    
    final User? admin = _auth.currentUser;
    
    DateTime? banUntil;
    if (durationDays > 0) {
      banUntil = DateTime.now().add(Duration(days: durationDays));
    }
    
    await _firestore.collection('users').doc(userId).update(<String, >{
      'isBanned': true,
      'banReason': reason,
      'bannedAt': FieldValue.serverTimestamp(),
      'bannedBy': admin.uid,
      'banUntil': banUntil,
    });
    
    // Log admin action
    await _logAdminAction(
      action: 'ban_user',
      targetId: userId,
      details: <String, dynamic>{'reason': reason, 'duration': durationDays},
    );
  }

  Future<void> unbanUser(String userId) async {
    await _checkAdmin();
    
    await _firestore.collection('users').doc(userId).update(<String, bool?>{
      'isBanned': false,
      'banReason': null,
      'bannedAt': null,
      'bannedBy': null,
      'banUntil': null,
    });
    
    await _logAdminAction(
      action: 'unban_user',
      targetId: userId,
    );
  }

  // ==================== ADD/REMOVE COINS ====================
  Future<void> addCoinsToUser({
    required String userId,
    required int amount,
    required String reason,
  }) async {
    await _checkAdmin();
    
    final User? admin = _auth.currentUser;
    
    await _firestore.runTransaction((Transaction transaction) async {
      final DocumentReference<Map<String, dynamic>> userRef = _firestore.collection('users').doc(userId);
      final DocumentSnapshot<Map<String, dynamic>> userDoc = await transaction.get(userRef);
      
      if (!userDoc.exists) throw Exception('User not found');
      
      final currentCoins = userDoc.data()!['coins'] ?? 0;
      
      transaction.update(userRef, <String, dynamic>{
        'coins': currentCoins + amount,
      });
      
      // Log transaction
      transaction.set(
        _firestore.collection('admin_transactions').doc(),
        <String, >{
          'adminId': admin.uid,
          'userId': userId,
          'amount': amount,
          'type': 'add',
          'reason': reason,
          'timestamp': FieldValue.serverTimestamp(),
        },
      );
    });
    
    await _logAdminAction(
      action: 'add_coins',
      targetId: userId,
      details: <String, dynamic>{'amount': amount, 'reason': reason},
    );
  }

  Future<void> removeCoinsFromUser({
    required String userId,
    required int amount,
    required String reason,
  }) async {
    await _checkAdmin();
    
    final User? admin = _auth.currentUser;
    
    await _firestore.runTransaction((Transaction transaction) async {
      final DocumentReference<Map<String, dynamic>> userRef = _firestore.collection('users').doc(userId);
      final DocumentSnapshot<Map<String, dynamic>> userDoc = await transaction.get(userRef);
      
      if (!userDoc.exists) throw Exception('User not found');
      
      final currentCoins = userDoc.data()!['coins'] ?? 0;
      if (currentCoins < amount) throw Exception('Insufficient coins');
      
      transaction.update(userRef, <String, dynamic>{
        'coins': currentCoins - amount,
      });
      
      // Log transaction
      transaction.set(
        _firestore.collection('admin_transactions').doc(),
        <String, >{
          'adminId': admin.uid,
          'userId': userId,
          'amount': amount,
          'type': 'remove',
          'reason': reason,
          'timestamp': FieldValue.serverTimestamp(),
        },
      );
    });
    
    await _logAdminAction(
      action: 'remove_coins',
      targetId: userId,
      details: <String, dynamic>{'amount': amount, 'reason': reason},
    );
  }

  // ==================== USER ROLE MANAGEMENT ====================
  Future<void> changeUserRole({
    required String userId,
    required UserRole newRole,
  }) async {
    await _checkAdmin();
    
    await _firestore.collection('users').doc(userId).update(<String, int>{
      'role': newRole.index,
    });
    
    await _logAdminAction(
      action: 'change_role',
      targetId: userId,
      details: <String, dynamic>{'newRole': newRole.toString()},
    );
  }

  // ==================== AGENCY MANAGEMENT ====================
  Future<void> createAgency({
    required String name,
    required String ownerId,
    required double commissionRate,
  }) async {
    await _checkAdmin();
    
    final DocumentReference<Map<String, dynamic>> agencyRef = await _firestore.collection('agencies').add(<String, >{
      'name': name,
      'ownerId': ownerId,
      'commissionRate': commissionRate,
      'members': <String>[ownerId],
      'totalEarnings': 0,
      'createdAt': FieldValue.serverTimestamp(),
      'status': 'active',
    });
    
    // Update owner's role
    await _firestore.collection('users').doc(ownerId).update(<String, >{
      'role': UserRole.agency.index,
      'agencyId': agencyRef.id,
    });
    
    await _logAdminAction(
      action: 'create_agency',
      targetId: agencyRef.id,
      details: <String, dynamic>{'name': name, 'ownerId': ownerId},
    );
  }

  Future<void> deleteAgency(String agencyId) async {
    await _checkAdmin();
    
    // Get agency members
    final DocumentSnapshot<Map<String, dynamic>> agencyDoc = await _firestore.collection('agencies').doc(agencyId).get();
    final members = agencyDoc.data()?['members'] ?? <dynamic>[];
    
    // Update all members' roles
    for (final memberId in members) {
      await _firestore.collection('users').doc(memberId).update(<String, int?>{
        'role': UserRole.user.index,
        'agencyId': null,
      });
    }
    
    // Delete agency
    await _firestore.collection('agencies').doc(agencyId).delete();
    
    await _logAdminAction(
      action: 'delete_agency',
      targetId: agencyId,
    );
  }

  // ==================== SELLER MANAGEMENT ====================
  Future<void> createSeller({
    required String userId,
    required double commissionRate,
    required int initialCoins,
  }) async {
    await _checkAdmin();
    
    await _firestore.collection('sellers').doc(userId).set(<String, >{
      'userId': userId,
      'commissionRate': commissionRate,
      'coinBalance': initialCoins,
      'totalCoinsSold': 0,
      'totalEarnings': 0,
      'createdAt': FieldValue.serverTimestamp(),
      'isActive': true,
    });
    
    // Update user's role
    await _firestore.collection('users').doc(userId).update(<String, int>{
      'role': UserRole.seller.index,
    });
    
    await _logAdminAction(
      action: 'create_seller',
      targetId: userId,
      details: <String, dynamic>{'commissionRate': commissionRate, 'initialCoins': initialCoins},
    );
  }

  Future<void> addCoinsToSeller({
    required String sellerId,
    required int amount,
  }) async {
    await _checkAdmin();
    
    await _firestore
        .collection('sellers')
        .doc(sellerId)
        .update(<String, >{
          'coinBalance': FieldValue.increment(amount),
        });
    
    await _logAdminAction(
      action: 'add_coins_to_seller',
      targetId: sellerId,
      details: <String, dynamic>{'amount': amount},
    );
  }

  // ==================== GIFT MANAGEMENT ====================
  Future<void> addGift(Map<String, dynamic> giftData) async {
    await _checkAdmin();
    
    await _firestore.collection('gifts').add(<String, dynamic>{
      ...giftData,
      'createdAt': FieldValue.serverTimestamp(),
      'createdBy': _auth.currentUser!.uid,
    });
    
    await _logAdminAction(
      action: 'add_gift',
      details: <String, dynamic>{'giftData': giftData},
    );
  }

  Future<void> updateGift(String giftId, Map<String, dynamic> giftData) async {
    await _checkAdmin();
    
    await _firestore.collection('gifts').doc(giftId).update(<String, dynamic>{
      ...giftData,
      'updatedAt': FieldValue.serverTimestamp(),
      'updatedBy': _auth.currentUser!.uid,
    });
    
    await _logAdminAction(
      action: 'update_gift',
      targetId: giftId,
      details: giftData,
    );
  }

  Future<void> deleteGift(String giftId) async {
    await _checkAdmin();
    
    await _firestore.collection('gifts').doc(giftId).delete();
    
    await _logAdminAction(
      action: 'delete_gift',
      targetId: giftId,
    );
  }

  // ==================== DASHBOARD STATS ====================
  Future<AdminDashboardStats> getDashboardStats() async {
    await _checkAdmin();
    
    final AggregateQuerySnapshot usersCount = await _firestore.collection('users').count().get();
    final AggregateQuerySnapshot activeNow = await _firestore
        .collection('users')
        .where('isOnline', isEqualTo: true)
        .count()
        .get();
    
    final DateTime today = DateTime.now();
    final DateTime startOfDay = DateTime(today.year, today.month, today.day);
    
    final QuerySnapshot<Map<String, dynamic>> todayTransactions = await _firestore
        .collection('transactions')
        .where('timestamp', isGreaterThanOrEqualTo: startOfDay)
        .get();
    
    final double totalRevenue = todayTransactions.docs.fold<double>(
      0,
      (double sum, QueryDocumentSnapshot<Map<String, dynamic>> doc) => sum + (doc.data()['amount'] ?? 0),
    );
    
    final AggregateQuerySnapshot roomsActive = await _firestore
        .collection('rooms')
        .where('isActive', isEqualTo: true)
        .count()
        .get();
    
    return AdminDashboardStats(
      totalUsers: usersCount.count ?? 0,
      activeNow: activeNow.count ?? 0,
      todayRevenue: totalRevenue,
      activeRooms: roomsActive.count ?? 0,
      totalGifts: await _getTotalGifts(),
      pendingReports: await _getPendingReports(),
    );
  }

  Future<int> _getTotalGifts() async {
    final AggregateQuerySnapshot snapshot = await _firestore.collection('gifts').count().get();
    return snapshot.count ?? 0;
  }

  Future<int> _getPendingReports() async {
    final AggregateQuerySnapshot snapshot = await _firestore
        .collection('reports')
        .where('status', isEqualTo: 'pending')
        .count()
        .get();
    return snapshot.count ?? 0;
  }

  // ==================== LOGGING ====================
  Future<void> _logAdminAction({
    required String action,
    String? targetId,
    Map<String, dynamic>? details,
  }) async {
    final User? admin = _auth.currentUser;
    
    await _firestore.collection('admin_logs').add(<String, >{
      'adminId': admin.uid,
      'adminEmail': admin.email,
      'action': action,
      'targetId': targetId,
      'details': details,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // Get admin logs
  Stream<List<AdminLog>> getAdminLogs({int limit = 100}) {
    return _firestore
        .collection('admin_logs')
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots()
        .map((QuerySnapshot<Map<String, dynamic>> snapshot) => snapshot.docs
            .map((QueryDocumentSnapshot<Map<String, dynamic>> doc) => AdminLog.fromJson(doc.data(), doc.id))
            .toList(),);
  }
}

// ==================== MODEL CLASSES ====================

class AdminDashboardStats {
  
  AdminDashboardStats({
    required this.totalUsers,
    required this.activeNow,
    required this.todayRevenue,
    required this.activeRooms,
    required this.totalGifts,
    required this.pendingReports,
  });
  final int totalUsers;
  final int activeNow;
  final double todayRevenue;
  final int activeRooms;
  final int totalGifts;
  final int pendingReports;
}

class AdminLog {
  
  AdminLog({
    required this.id,
    required this.adminId,
    required this.adminEmail,
    required this.action,
    required this.timestamp, this.targetId,
    this.details,
  });
  
  factory AdminLog.fromJson(Map<String, dynamic> json, String id) {
    return AdminLog(
      id: id,
      adminId: json['adminId'] ?? '',
      adminEmail: json['adminEmail'] ?? '',
      action: json['action'] ?? '',
      targetId: json['targetId'],
      details: json['details'],
      timestamp: (json['timestamp'] as Timestamp).toDate(),
    );
  }
  final String id;
  final String adminId;
  final String adminEmail;
  final String action;
  final String? targetId;
  final Map<String, dynamic>? details;
  final DateTime timestamp;
}