import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import '../config/app_config.dart';

class AppNotification {
  final String id;
  final String title;
  final String message;
  final String type;
  final String icon;
  final String actionUrl;
  final DateTime publishedAt;
  bool read;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.icon,
    required this.actionUrl,
    required this.publishedAt,
    required this.read,
  });

  factory AppNotification.fromMap(Map<String, dynamic> m) {
    return AppNotification(
      id: m['id'] ?? '',
      title: m['title'] ?? '',
      message: m['message'] ?? '',
      type: m['type'] ?? 'info',
      icon: m['icon'] ?? 'ℹ️',
      actionUrl: m['actionUrl'] ?? '',
      publishedAt: DateTime.tryParse(m['publishedAt']?.toString() ?? '') ?? DateTime.now(),
      read: m['read'] == true,
    );
  }
}

class NotificationService {
  static final _listeners = <Function(List<AppNotification>, int)>[];
  static List<AppNotification> _cached = [];
  static int _unreadCount = 0;
  static Timer? _pollTimer;

  static List<AppNotification> get cached => _cached;
  static int get unreadCount => _unreadCount;

  static void addListener(Function(List<AppNotification>, int) cb) {
    _listeners.add(cb);
  }

  static void removeListener(Function(List<AppNotification>, int) cb) {
    _listeners.remove(cb);
  }

  static void _notifyListeners() {
    for (final cb in _listeners) {
      try {
        cb(_cached, _unreadCount);
      } catch (_) {}
    }
  }

  /// Start polling
  static void start() {
    refresh();
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      refresh();
    });
  }

  static void stop() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  /// Fetch notifikasi
  static Future<void> refresh() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final res = await http.post(
        Uri.parse('${AppConfig.apiBase}/notifications/list'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userId': user.uid}),
      ).timeout(const Duration(seconds: 15));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['ok'] == true) {
          final list = (data['notifications'] as List? ?? [])
              .map((m) => AppNotification.fromMap(Map<String, dynamic>.from(m)))
              .toList();
          _cached = list;
          _unreadCount = data['unreadCount'] ?? 0;
          _notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('[Notif] Refresh error: $e');
    }
  }

  /// Mark read
  static Future<void> markAsRead(List<String> notifIds) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await http.post(
        Uri.parse('${AppConfig.apiBase}/notifications/read'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': user.uid,
          'notifIds': notifIds,
        }),
      ).timeout(const Duration(seconds: 15));

      // Update lokal
      for (final n in _cached) {
        if (notifIds.contains(n.id)) n.read = true;
      }
      _unreadCount = _cached.where((n) => !n.read).length;
      _notifyListeners();
    } catch (e) {
      debugPrint('[Notif] Mark read error: $e');
    }
  }
}
