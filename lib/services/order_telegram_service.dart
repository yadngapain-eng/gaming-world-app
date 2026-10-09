import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class OrderTelegramService {
  static Future<bool> notifyOrder(Map<String, dynamic> order) async {
    try {
      final res = await http.post(
        Uri.parse('${AppConfig.apiBase}/order'),
        headers: {'Content-Type': 'application/json; charset=utf-8'},
        body: utf8.encode(jsonEncode(order)),
      ).timeout(const Duration(seconds: 15));
      debugPrint('[Order TG] Status: ${res.statusCode}');
      return res.statusCode == 200;
    } catch (e) {
      debugPrint('[Order TG] Error: $e');
      return false;
    }
  }
}
