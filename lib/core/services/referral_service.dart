import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../di/service_locator.dart';
import 'notification_service.dart';

class ReferralService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final NotificationService _notificationService = ServiceLocator().get<NotificationService>();

  // Generate referral code
  Future<String?> generateReferralCode() async {
    final User? user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    try {
      // Check if user already has a code
      final DocumentSnapshot<Map<String, dynamic>> userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists && userDoc.data()!['referralCode'] != null) {
        return userDoc.data()!['referralCode'];
      }

      // Generate unique code
      String code;
      bool exists;
      do {
        code = _generateCode();
        final DocumentSnapshot<Map<String, dynamic>> existing = await _firestore
            .collection('referral_codes')
            .doc(code)
            .get();
        exists = existing.exists;
      } while (exists);

      // Save code
      await _firestore.collection('referral_codes').doc(code).set(<String, >{
        'userId': user.uid,
        'createdAt': FieldValue.serverTimestamp(),
      });

      await _firestore.collection('users').doc(user.uid).update(<String, String>{
        'referralCode': code,
      });

      return code;
    } catch (e) {
      print('Error generating referral code: $e');
      return null;
    }
  }

  // Get referral code
  Future<String?> getReferralCode(String userId) async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return doc.data()!['referralCode'];
      }
      return null;
    } catch (e) {
      print('Error getting referral code: $e');
      return null;
    }
  }

  // Apply referral code
  Future<bool> applyReferralCode(String code) async {
    final User? user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    try {
      // Check if code exists
      final DocumentSnapshot<Map<String, dynamic>> codeDoc = await _firestore.collection('referral_codes').doc(code).get();
      if (!codeDoc.exists) throw Exception('Invalid referral code');

      final referrerId = codeDoc.data()!['userId'];

      // Check if trying to refer self
      if (referrerId == user.uid) {
        throw Exception('Cannot use your own referral code');
      }

      // Check if already used
      final DocumentSnapshot<Map<String, dynamic>> userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists && userDoc.data()!['referredBy'] != null) {
        throw Exception('Referral code already used');
      }

      return await _firestore.runTransaction((Transaction transaction) async {
        // Update user
        transaction.update(
          _firestore.collection('users').doc(user.uid),
          <String, >{
            'referredBy': referrerId,
            'referredAt': FieldValue.serverTimestamp(),
            'coins': FieldValue.increment(500), // Welcome bonus
          },
        );

        // Update referrer
        transaction.update(
          _firestore.collection('users').doc(referrerId),
          <String, >{
            'totalReferrals': FieldValue.increment(1),
            'coins': FieldValue.increment(1000), // Referral bonus
          },
        );

        // Record referral
        transaction.set(
          _firestore.collection('referrals').doc(),
          <String, >{
            'referrerId': referrerId,
            'referredId': user.uid,
            'code': code,
            'timestamp': FieldValue.serverTimestamp(),
          },
        );

        // Send notification to referrer
        await _notificationService.sendNotification(
          userId: referrerId,
          type: 'referral',
          title: 'New Referral! 🎉',
          body: 'Someone used your referral code. You earned 1000 coins!',
          data: <String, >{'referredId': user.uid},
        );

        return true;
      });
    } catch (e) {
      print('Error applying referral code: $e');
      return false;
    }
  }

  // Get referral stats
  Future<Map<String, dynamic>> getReferralStats() async {
    final User? user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    try {
      // Get total referrals
      final QuerySnapshot<Map<String, dynamic>> referralsSnapshot = await _firestore
          .collection('referrals')
          .where('referrerId', isEqualTo: user.uid)
          .get();

      // Get this month's referrals
      final DateTime startOfMonth = DateTime(DateTime.now().year, DateTime.now().month);
      final QuerySnapshot<Map<String, dynamic>> monthReferrals = await _firestore
          .collection('referrals')
          .where('referrerId', isEqualTo: user.uid)
          .where('timestamp', isGreaterThanOrEqualTo: startOfMonth)
          .get();

      // Get this week's referrals
      final DateTime startOfWeek = DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1));
      final QuerySnapshot<Map<String, dynamic>> weekReferrals = await _firestore
          .collection('referrals')
          .where('referrerId', isEqualTo: user.uid)
          .where('timestamp', isGreaterThanOrEqualTo: startOfWeek)
          .get();

      // Get user's code
      final String? code = await getReferralCode(user.uid);

      // Calculate earnings
      final int totalEarnings = referralsSnapshot.docs.length * 1000;
      const int bonusPerReferral = 1000;

      return <String, dynamic>{
        'code': code,
        'totalReferrals': referralsSnapshot.docs.length,
        'monthReferrals': monthReferrals.docs.length,
        'weekReferrals': weekReferrals.docs.length,
        'totalEarnings': totalEarnings,
        'bonusPerReferral': bonusPerReferral,
        'nextMilestone': _getNextMilestone(referralsSnapshot.docs.length),
      };
    } catch (e) {
      print('Error getting referral stats: $e');
      return <String, dynamic>{};
    }
  }

  // Get referral history
  Stream<List<Map<String, dynamic>>> getReferralHistory() {
    final User? user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    return _firestore
        .collection('referrals')
        .where('referrerId', isEqualTo: user.uid)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .asyncMap((QuerySnapshot<Map<String, dynamic>> snapshot) async {
          final List<Map<String, dynamic>> history = <Map<String, dynamic>>[];
          
          for (final QueryDocumentSnapshot<Map<String, dynamic>> doc in snapshot.docs) {
            final Map<String, dynamic> data = doc.data();
            final DocumentSnapshot<Map<String, dynamic>> referredUser = await _firestore
                .collection('users')
                .doc(data['referredId'])
                .get();

            history.add(<String, dynamic>{
              'id': doc.id,
              'referredName': referredUser.data()?['username'] ?? 'User',
              'referredAvatar': referredUser.data()?['photoURL'],
              'timestamp': (data['timestamp'] as Timestamp).toDate(),
              'bonus': 1000,
            });
          }

          return history;
        });
  }

  // Get referred by info
  Future<Map<String, dynamic>?> getReferredBy() async {
    final User? user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    try {
      final DocumentSnapshot<Map<String, dynamic>> userDoc = await _firestore.collection('users').doc(user.uid).get();
      final referredBy = userDoc.data()?['referredBy'];

      if (referredBy == null) return null;

      final DocumentSnapshot<Map<String, dynamic>> referrerDoc = await _firestore.collection('users').doc(referredBy).get();

      return <String, dynamic>{
        'userId': referredBy,
        'name': referrerDoc.data()?['username'] ?? 'User',
        'avatar': referrerDoc.data()?['photoURL'],
        'referredAt': userDoc.data()!['referredAt']?.toDate(),
      };
    } catch (e) {
      print('Error getting referred by: $e');
      return null;
    }
  }

  // Get referral leaderboard
  Future<List<Map<String, dynamic>>> getReferralLeaderboard({int limit = 10}) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
          .collection('users')
          .orderBy('totalReferrals', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((QueryDocumentSnapshot<Map<String, dynamic>> doc) {
        final Map<String, dynamic> data = doc.data();
        return <String, dynamic>{
          'userId': doc.id,
          'name': data['username'] ?? 'User',
          'avatar': data['photoURL'],
          'totalReferrals': data['totalReferrals'] ?? 0,
        };
      }).toList();
    } catch (e) {
      print('Error getting referral leaderboard: $e');
      return <Map<String, dynamic>>[];
    }
  }

  // Generate random code
  String _generateCode() {
    const String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final int random = DateTime.now().millisecondsSinceEpoch;
    var code = '';
    for (var i = 0; i < 8; i++) {
      code += chars[(random + i) % chars.length];
    }
    return code;
  }

  // Get next milestone
  Map<String, dynamic> _getNextMilestone(int current) {
    const List<int> milestones = <int>[1, 5, 10, 25, 50, 100, 250, 500, 1000];
    
    for (int milestone in milestones) {
      if (current < milestone) {
        return <String, dynamic>{
          'next': milestone,
          'remaining': milestone - current,
          'bonus': milestone * 1000,
        };
      }
    }
    
    return <String, dynamic>{
      'next': 1000,
      'remaining': 1000 - current,
      'bonus': 1000000,
    };
  }

  // Get referral link
  Future<String?> getReferralLink() async {
    final String? code = await getReferralCode(_auth.currentUser?.uid ?? '');
    if (code == null) return null;
    
    return 'https://lotchat.app/ref/$code';
  }

  // Share referral
  Future<void> shareReferral() async {
    final String? link = await getReferralLink();
    if (link == null) return;

    // Share implementation using share_plus
    // await Share.share('Join me on LotChat! Use my referral code: $link');
  }
}