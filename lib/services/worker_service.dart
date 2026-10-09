import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class WorkerService extends ChangeNotifier {
  final String _base = AppConfig.apiBase;
  
  Future<Map<String, dynamic>> health() async {
    try {
      final res = await http.get(Uri.parse('$_base/health')).timeout(const Duration(seconds: 10));
      return jsonDecode(res.body);
    } catch (e) {
      debugPrint('[Worker] health error: $e');
      return {'ok': false};
    }
  }
  
  Future<Map<String, dynamic>> aiReply(String ticketId, String msg, String userName) async {
    try {
      final res = await http.post(
        Uri.parse('$_base/ai-reply'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'ticketId': ticketId, 'userMessage': msg, 'userName': userName}),
      ).timeout(const Duration(seconds: 30));
      return jsonDecode(res.body);
    } catch (e) {
      debugPrint('[Worker] aiReply error: $e');
      return {'ok': false};
    }
  }
  
  Future<Map<String, dynamic>> notify(String title, String message, {String? orderId}) async {
    try {
      final res = await http.post(
        Uri.parse('$_base/notify'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'title': title,
          'message': message,
          if (orderId != null) 'orderId': orderId,
        }),
      ).timeout(const Duration(seconds: 15));
      return jsonDecode(res.body);
    } catch (e) {
      debugPrint('[Worker] notify error: $e');
      return {'ok': false};
    }
  }
  
  Future<Map<String, dynamic>> submitOrder(Map<String, dynamic> order) async {
    try {
      final res = await http.post(
        Uri.parse('$_base/order'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(order),
      ).timeout(const Duration(seconds: 30));
      return jsonDecode(res.body);
    } catch (e) {
      debugPrint('[Worker] submitOrder error: $e');
      return {'ok': false};
    }
  }
  
  Future<Map<String, dynamic>> claimReward(String userId, String gameId, String token, num score) async {
    try {
      final res = await http.post(
        Uri.parse('$_base/minigame/claim'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userId': userId, 'gameId': gameId, 'token': token, 'score': score}),
      ).timeout(const Duration(seconds: 30));
      return jsonDecode(res.body);
    } catch (e) {
      debugPrint('[Worker] claimReward error: $e');
      return {'ok': false};
    }
  }
  
  Future<Map<String, dynamic>> getToken(String userId, String gameId) async {
    try {
      final res = await http.post(
        Uri.parse('$_base/minigame/token'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userId': userId, 'gameId': gameId}),
      ).timeout(const Duration(seconds: 15));
      return jsonDecode(res.body);
    } catch (e) {
      debugPrint('[Worker] getToken error: $e');
      return {'ok': false};
    }
  }
}
