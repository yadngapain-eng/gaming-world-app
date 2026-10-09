import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService extends ChangeNotifier {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Stream<List<Map<String, dynamic>>> streamMinigames() {
    return _db.collection('config').doc('minigames').snapshots().map((doc) {
      if (!doc.exists) return [];
      final games = doc.data()?['games'] as List? ?? [];
      return games.where((g) => g['active'] != false).map((g) => Map<String, dynamic>.from(g)).toList();
    });
  }

  Stream<List<Map<String, dynamic>>> streamPayments() {
    return _db.collection('config').doc('payments').snapshots().map((doc) {
      if (!doc.exists) return [];
      final methods = doc.data()?['methods'] as List? ?? [];
      return methods.where((m) => m['active'] != false).map((m) => Map<String, dynamic>.from(m)).toList();
    });
  }

  Stream<num> streamBalance() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value(0);
    return _db.collection('users').doc(user.uid).snapshots().map((doc) {
      return (doc.data()?['balance'] ?? 0) as num;
    });
  }

  Stream<List<Map<String, dynamic>>> streamUserOrders() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);
    return _db
        .collection('orders')
        .where('userId', isEqualTo: user.uid)
        .snapshots()
        .map((snap) {
      final list = snap.docs.map((d) => {'id': d.id, ...d.data()}).toList();
      list.sort((a, b) {
        final da = a['date']?.toString() ?? '';
        final db = b['date']?.toString() ?? '';
        return db.compareTo(da);
      });
      return list;
    });
  }

  Future<List<Map<String, dynamic>>> getUserOrders() async {
    final user = _auth.currentUser;
    if (user == null) return [];
    try {
      final snap = await _db
          .collection('orders')
          .where('userId', isEqualTo: user.uid)
          .limit(50)
          .get();
      return snap.docs.map((d) => {'id': d.id, ...d.data()}).toList();
    } catch (e) {
      return [];
    }
  }
}
