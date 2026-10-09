import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService extends ChangeNotifier {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;
  
  User? _user;
  Map<String, dynamic>? _userData;
  
  User? get user => _user;
  Map<String, dynamic>? get userData => _userData;
  bool get isLoggedIn => _user != null;
  
  AuthService() {
    _auth.authStateChanges().listen((u) async {
      _user = u;
      if (u != null) {
        try {
          final doc = await _db.collection('users').doc(u.uid).get();
          _userData = doc.data();
        } catch (e) {}
      }
      notifyListeners();
    });
  }
  
  Future<bool> loginAnonymous() async {
    try {
      await _auth.signInAnonymously();
      return true;
    } catch (e) {
      return false;
    }
  }
  
  Future<void> logout() async {
    await _auth.signOut();
  }
}
