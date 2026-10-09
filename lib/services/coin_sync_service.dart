import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CoinSyncService {
  StreamSubscription? _sub;
  num _balance = 0;
  final _controller = StreamController<num>.broadcast();
  
  Stream<num> get balanceStream => _controller.stream;
  num get balance => _balance;
  
  void start() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    
    _sub?.cancel();
    _sub = FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .snapshots()
      .listen((doc) {
        final bal = (doc.data()?['balance'] ?? 0) as num;
        _balance = bal;
        _controller.add(bal);
      });
  }
  
  void stop() {
    _sub?.cancel();
    _sub = null;
  }
  
  void dispose() {
    stop();
    _controller.close();
  }
}
