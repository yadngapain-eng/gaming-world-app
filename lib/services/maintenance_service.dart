import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MaintenanceService extends ChangeNotifier {
  bool _isMaintenance = false;
  String _message = 'Kami sedang melakukan perbaikan sistem. Mohon coba lagi beberapa saat lagi.';

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
      }
      notifyListeners();
    } catch (e) {
      debugPrint('[Maintenance] Error: $e');
    }
  }

  void startPeriodicCheck() {
    check();
    // Cek tiap 60 detik
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 60));
      await check();
      return true;
    });
  }
}
