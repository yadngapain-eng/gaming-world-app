import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RewardService {
  static final _db = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  static String? get _uid => _auth.currentUser?.uid;

  static Stream<num> streamBalance() {
    if (_uid == null) return Stream.value(0);
    return _db.collection('users').doc(_uid).snapshots().map((d) {
      return (d.data()?['balance'] ?? 0) as num;
    });
  }

  static Future<num> getBalance() async {
    if (_uid == null) return 0;
    final doc = await _db.collection('users').doc(_uid).get();
    return (doc.data()?['balance'] ?? 0) as num;
  }

  static Future<bool> addCoin(num amount, String reason) async {
    if (_uid == null || amount <= 0) return false;
    try {
      await _db.runTransaction((tx) async {
        final ref = _db.collection('users').doc(_uid);
        final doc = await tx.get(ref);
        final current = (doc.data()?['balance'] ?? 0) as num;
        final totalEarned = (doc.data()?['totalEarned'] ?? 0) as num;
        tx.update(ref, {
          'balance': current + amount,
          'totalEarned': totalEarned + amount,
          'updatedAt': DateTime.now().toIso8601String(),
        });
      });
      debugPrint('[Reward] +' + amount.toString() + ' koin: ' + reason);
      return true;
    } catch (e) {
      debugPrint('[Reward] addCoin error: ' + e.toString());
      return false;
    }
  }

  static Future<bool> spendCoin(num amount, String reason) async {
    if (_uid == null || amount <= 0) return false;
    try {
      await _db.runTransaction((tx) async {
        final ref = _db.collection('users').doc(_uid);
        final doc = await tx.get(ref);
        final current = (doc.data()?['balance'] ?? 0) as num;
        if (current < amount) throw Exception('Saldo tidak cukup');
        final totalSpent = (doc.data()?['totalSpent'] ?? 0) as num;
        tx.update(ref, {
          'balance': current - amount,
          'totalSpent': totalSpent + amount,
          'updatedAt': DateTime.now().toIso8601String(),
        });
      });
      debugPrint('[Reward] -' + amount.toString() + ' koin: ' + reason);
      return true;
    } catch (e) {
      debugPrint('[Reward] spendCoin error: ' + e.toString());
      return false;
    }
  }

  // ============================================
  // ABSEN HARIAN
  // ============================================
  static Future<Map<String, dynamic>> claimDaily() async {
    if (_uid == null) return {'ok': false, 'message': 'Login dulu'};
    try {
      final ref = _db.collection('users').doc(_uid);
      final doc = await ref.get();
      final lastClaim = doc.data()?['lastDailyClaim'];
      final now = DateTime.now();
      if (lastClaim != null) {
        final last = DateTime.parse(lastClaim.toString());
        final diff = now.difference(last).inHours;
        if (diff < 24) {
          final remaining = 24 - diff;
          return {'ok': false, 'message': 'Sudah absen hari ini. Coba lagi ' + remaining.toString() + ' jam lagi.'};
        }
      }
      final reward = 15;
      await ref.update({
        'balance': FieldValue.increment(reward),
        'totalEarned': FieldValue.increment(reward),
        'lastDailyClaim': now.toIso8601String(),
      });
      return {'ok': true, 'reward': reward, 'message': 'Berhasil absen! +' + reward.toString() + ' koin'};
    } catch (e) {
      return {'ok': false, 'message': e.toString()};
    }
  }

  // ============================================
  // TONTON IKLAN (setelah return dari smartlink)
  // ============================================
  static Future<Map<String, dynamic>> claimAdReward() async {
    if (_uid == null) return {'ok': false, 'message': 'Login dulu'};
    try {
      final ref = _db.collection('users').doc(_uid);
      final doc = await ref.get();
      final lastWatch = doc.data()?['lastAdWatch'];
      final now = DateTime.now();
      if (lastWatch != null) {
        final last = DateTime.parse(lastWatch.toString());
        final diff = now.difference(last).inSeconds;
        if (diff < 30) {
          return {'ok': false, 'message': 'Tunggu ' + (30 - diff).toString() + ' detik lagi'};
        }
      }
      // Random reward
      final roll = (DateTime.now().millisecondsSinceEpoch % 10000) / 100;
      int reward;
      if (roll < 30) reward = 1 + (DateTime.now().microsecond % 5);          // 1-5
      else if (roll < 55) reward = 5 + (DateTime.now().microsecond % 6);     // 5-10
      else if (roll < 75) reward = 10 + (DateTime.now().microsecond % 16);   // 10-25
      else if (roll < 87) reward = 25 + (DateTime.now().microsecond % 26);   // 25-50
      else if (roll < 95) reward = 50 + (DateTime.now().microsecond % 51);   // 50-100
      else if (roll < 99) reward = 250 + (DateTime.now().microsecond % 251); // 250-500
      else if (roll < 99.9) reward = 1000 + (DateTime.now().microsecond % 1501); // 1000-2500
      else reward = 5000 + (DateTime.now().microsecond % 5001);              // 5000-10000

      await ref.update({
        'balance': FieldValue.increment(reward),
        'totalEarned': FieldValue.increment(reward),
        'lastAdWatch': now.toIso8601String(),
        'totalAdsWatched': FieldValue.increment(1),
      });
      return {'ok': true, 'reward': reward, 'message': 'Dapat ' + reward.toString() + ' koin!'};
    } catch (e) {
      return {'ok': false, 'message': e.toString()};
    }
  }
}
