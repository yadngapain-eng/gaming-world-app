import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FcmService {
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    try {
      final fcm = FirebaseMessaging.instance;

      final settings = await fcm.requestPermission(
        alert: true, badge: true, sound: true,
      );
      debugPrint('[FCM] Permission: ${settings.authorizationStatus}');

      final token = await fcm.getToken();
      debugPrint('[FCM] Token: $token');

      if (token != null) {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .set({
            'fcmToken': token,
            'fcmUpdatedAt': DateTime.now().toIso8601String(),
          }, SetOptions(merge: true));
        }
      }

      fcm.onTokenRefresh.listen((newToken) async {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .set({
            'fcmToken': newToken,
            'fcmUpdatedAt': DateTime.now().toIso8601String(),
          }, SetOptions(merge: true));
        }
      });

      FirebaseMessaging.onMessage.listen((msg) {
        debugPrint('[FCM] Foreground: ${msg.notification?.title}');
      });

      FirebaseMessaging.onMessageOpenedApp.listen((msg) {
        debugPrint('[FCM] Opened: ${msg.data}');
      });
    } catch (e) {
      debugPrint('[FCM] Error: $e');
    }
  }
}
