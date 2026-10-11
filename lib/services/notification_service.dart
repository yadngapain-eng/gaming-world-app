import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  
  Future<void> init() async {
    try {
      // Request permission
      await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      
      // Get token
      final token = await _fcm.getToken();
      debugPrint('[FCM] Token: $token');
      
      // Save token to Firestore
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && token != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'fcmToken': token,
          'fcmUpdatedAt': DateTime.now().toIso8601String(),
        }, SetOptions(merge: true));
      }
      
      // Listen foreground
      FirebaseMessaging.onMessage.listen((msg) {
        debugPrint('[FCM] Foreground: ${msg.notification?.title}');
      });
      
      // Listen background click
      FirebaseMessaging.onMessageOpenedApp.listen((msg) {
        debugPrint('[FCM] Opened: ${msg.data}');
      });
    } catch (e) {
      debugPrint('[FCM] Init error: $e');
    }
  }
}
