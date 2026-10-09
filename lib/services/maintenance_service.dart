import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MaintenanceService extends ChangeNotifier {
  bool _isMaintenance = false;
  String _message = 'Kami sedang melakukan perbaikan sistem. Mohon coba lagi beberapa saat lagi.';
  Timer? _timer;

  bool get isMaintenance => _isMaintenance;
  String get message => _message;

  Future<void> check() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('config')
          .doc('maintenance')
          .get();
      if (doc.exists) {
        final data = doc.data() ?? {};
        _isMaintenance = data['enabled'] == true;
        if (data['message'] != null) _message = data['message'];
      } else {
        _isMaintenance = false;
      }
      notifyListeners();
    } catch (e) {
      debugPrint('[Maintenance] Error: $e');
    }
  }

  void startPeriodicCheck() {
    check();
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 60), (_) => check());
  }

  void stopPeriodicCheck() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    stopPeriodicCheck();
    super.dispose();
  }
}
