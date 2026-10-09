import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class WorkerService {
  final String _base = AppConfig.apiBase;
  
  Future<Map<String, dynamic>> health() async {
    try {
      final res = await http.get(Uri.parse('$_base/health')).timeout(const Duration(seconds: 10));
      return jsonDecode(res.body);
    } catch (e) {
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
      return {'ok': false};
    }
  }
}
