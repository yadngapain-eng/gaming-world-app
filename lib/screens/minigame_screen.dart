import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../services/firestore_service.dart';

class MinigameScreen extends StatefulWidget {
  final Map<String, dynamic> game;
  const MinigameScreen({super.key, required this.game});
  
  @override
  State<MinigameScreen> createState() => _MinigameScreenState();
}

class _MinigameScreenState extends State<MinigameScreen> {
  late WebViewController _controller;
  String? _token;
  bool _loading = true;
  String _error = '';
  
  @override
  void initState() {
    super.initState();
    _initWebView();
  }
  
  Future<void> _initWebView() async {
    try {
      // Get token from Worker
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not logged in');
      
      final res = await http.post(
        Uri.parse('${AppConfig.apiBase}/minigame/token'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userId': user.uid, 'gameId': widget.game['id']}),
      ).timeout(const Duration(seconds: 15));
      
      final data = jsonDecode(res.body);
      if (data['ok'] == true && data['token'] != null) {
        _token = data['token'];
      } else {
        throw Exception(data['error'] ?? 'Failed to get token');
      }
      
      // Build URL with UID + token
      final baseUrl = widget.game['url'] ?? '';
      final sep = baseUrl.contains('?') ? '&' : '?';
      final fullUrl = '$baseUrl${sep}uid=${user.uid}&token=$_token';
      
      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(const Color(0xFF0f172a))
        ..addJavaScriptChannel(
          'FlutterBridge',
          onMessageReceived: (msg) {
            _handleJsMessage(msg.message);
          },
        )
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageStarted: (_) => setState(() => _loading = true),
            onPageFinished: (_) => setState(() => _loading = false),
            onWebResourceError: (err) {
              setState(() => _error = err.description);
            },
          ),
        )
        ..loadRequest(Uri.parse(fullUrl));
      
      setState(() => _loading = false);
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
        _loading = false;
      });
    }
  }
  
  void _handleJsMessage(String msg) {
    try {
      final data = jsonDecode(msg);
      if (data['type'] == 'reward') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('🎉 +${data['reward']} koin!')),
        );
        // Refresh coin di parent
        final fs = context.read<FirestoreService>();
        fs.notifyListeners();
      }
    } catch (e) {
      debugPrint('[Minigame] JS message error: $e');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.game['icon']} ${widget.game['name']}'),
        backgroundColor: const Color(0xFF7c3aed),
        foregroundColor: Colors.white,
      ),
      body: _error.isNotEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, color: Colors.red, size: 60),
                const SizedBox(height: 16),
                Text(_error, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                ElevatedButton(onPressed: _initWebView, child: const Text('Coba Lagi')),
              ],
            ),
          )
        : _loading
          ? const Center(child: CircularProgressIndicator())
          : WebViewWidget(controller: _controller),
    );
  }
}
