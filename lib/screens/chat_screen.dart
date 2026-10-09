import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final List<Map<String, dynamic>> _messages = [];
  bool _loading = false;
  String _ticketId = '';

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    _ticketId = 'CHAT-${user?.uid.substring(0, 8) ?? "guest"}-${DateTime.now().millisecondsSinceEpoch}';
    _messages.add({
      'role': 'assistant',
      'text': 'Hai kak! \u{1F44B} Ada yang bisa aku bantu hari ini? \u{1F60A}',
      'time': DateTime.now().toIso8601String(),
    });
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _loading) return;

    _controller.clear();
    setState(() {
      _messages.add({
        'role': 'user',
        'text': text,
        'time': DateTime.now().toIso8601String(),
      });
      _loading = true;
    });
    _scrollDown();

    try {
      final user = FirebaseAuth.instance.currentUser;
      final res = await http.post(
        Uri.parse('${AppConfig.apiBase}/ai-reply'),
        headers: {'Content-Type': 'application/json; charset=utf-8'},
        body: utf8.encode(jsonEncode({
          'ticketId': _ticketId,
          'userMessage': text,
          'userName': user?.displayName ?? 'User',
          'conversationHistory': _messages,
        })),
      ).timeout(const Duration(seconds: 30));

      final data = jsonDecode(utf8.decode(res.bodyBytes));
      final reply = data['reply'] ?? 'Maaf, aku tidak bisa balas sekarang.';

      setState(() {
        _messages.add({
          'role': 'assistant',
          'text': reply,
          'time': DateTime.now().toIso8601String(),
        });
        _loading = false;
      });
      _scrollDown();
    } catch (e) {
      setState(() {
        _messages.add({
          'role': 'assistant',
          'text': '\u274C Error koneksi. Coba lagi ya.',
          'time': DateTime.now().toIso8601String(),
        });
        _loading = false;
      });
    }
  }

  void _scrollDown() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Text('\u{1F916} ', style: TextStyle(fontSize: 20)),
            Text('Chat AI'),
          ],
        ),
        backgroundColor: const Color(0xFF7c3aed),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_loading ? 1 : 0),
              itemBuilder: (context, i) {
                if (i == _messages.length) return _typingIndicator();
                return _bubble(_messages[i]);
              },
            ),
          ),
          _inputBar(),
        ],
      ),
    );
  }

  Widget _bubble(Map<String, dynamic> m) {
    final isUser = m['role'] == 'user';
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isUser ? const Color(0xFF7c3aed) : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isUser ? const Radius.circular(16) : Radius.zero,
            bottomRight: isUser ? Radius.zero : const Radius.circular(16),
          ),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6)],
        ),
        child: Text(
          m['text'],
          style: TextStyle(color: isUser ? Colors.white : Colors.black87, fontSize: 14),
        ),
      ),
    );
  }

  Widget _typingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(width: 8, height: 8, child: CircularProgressIndicator(strokeWidth: 2)),
            SizedBox(width: 8),
            Text('AI sedang mengetik...', style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _inputBar() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Ketik pesan...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
              ),
              onSubmitted: (_) => _send(),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: _loading ? null : _send,
            icon: const Icon(Icons.send),
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xFF7c3aed),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.all(12),
            ),
          ),
        ],
      ),
    );
  }
}
