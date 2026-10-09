import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FcmService {
  static Future<void> init() async {
    try {
      final fcm = FirebaseMessaging.instance;
      await fcm.requestPermission(alert: true, badge: true, sound: true);
      final token = await fcm.getToken();
      debugPrint('[FCM] Token: $token');
      if (token != null) {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
            'fcmToken': token,
            'fcmUpdatedAt': DateTime.now().toIso8601String(),
          }, SetOptions(merge: true));
        }
      }
      FirebaseMessaging.onMessage.listen((msg) {
        debugPrint('[FCM] Foreground: ${msg.notification?.title}');
      });
    } catch (e) {
      debugPrint('[FCM] Error: $e');
    }
  }
}
