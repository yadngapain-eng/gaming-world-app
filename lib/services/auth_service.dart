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
  bool get isLoggedIn => _user != null && !_user!.isAnonymous;
  bool get isGuest => _user?.isAnonymous ?? false;

  AuthService() {
    _auth.authStateChanges().listen((u) async {
      _user = u;
      _userData = null;
      if (u != null) {
        try {
          final doc = await _db.collection('users').doc(u.uid).get();
          _userData = doc.data();
        } catch (e) {
          debugPrint('[AuthService] load user error: $e');
        }
      }
      notifyListeners();
    });
  }

  Future<bool> loginAnonymous() async {
    try {
      await _auth.signInAnonymously();
      return true;
    } catch (e) {
      debugPrint('[AuthService] loginAnonymous error: $e');
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      debugPrint('[AuthService] logout error: $e');
    }
  }
}
