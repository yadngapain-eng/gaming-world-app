import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/reward_service.dart';

class GameStoreScreen extends StatefulWidget {
  const GameStoreScreen({super.key});
  @override
  State<GameStoreScreen> createState() => _GameStoreScreenState();
}

class _GameStoreScreenState extends State<GameStoreScreen> {
  List<Map<String, dynamic>> _games = [];
  bool _loading = true;
  num _markup = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final db = FirebaseFirestore.instance;
      // Load markup
      final markupDoc = await db.collection('config').doc('markup').get();
      _markup = (markupDoc.data()?['global_markup'] ?? 0) as num;

      // Load minigames dari Firestore
      final mgDoc = await db.collection('config').doc('minigames').get();
      final games = (mgDoc.data()?['games'] as List? ?? [])
          .where((g) => g['active'] != false)
          .map((g) => Map<String, dynamic>.from(g))
          .toList();
      if (mounted) setState(() { _games = games; _loading = false; });
    } catch (e) {
      debugPrint('[GameStore] error: ' + e.toString());
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🛒 Tukar Hadiah'),
        backgroundColor: const Color(0xFF7c3aed),
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _games.isEmpty
              ? _emptyState()
              : _content(),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🛒', style: TextStyle(fontSize: 80)),
            const SizedBox(height: 16),
            const Text('Belum Ada Item', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            const Text('Item akan muncul setelah admin upload game via Telegram.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _content() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Saldo
        StreamBuilder<num>(
          stream: RewardService.streamBalance(),
          builder: (context, snap) {
            final balance = snap.data ?? 0;
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFFa855f7), Color(0xFF7c3aed)]),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Text('🪙', style: TextStyle(fontSize: 32)),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Saldo Koin', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
                      Text(balance.toStringAsFixed(0), style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900)),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 20),
        const Text('Pilih Game', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
        const SizedBox(height: 12),
        ..._games.map((g) => _gameCard(g)),
      ],
    );
  }

  Widget _gameCard(Map<String, dynamic> game) {
    final name = game['name'] ?? 'Game';
    final icon = game['icon'] ?? '🎮';
    final desc = game['description'] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 36)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
                    if (desc.isNotEmpty) Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(desc, style: const TextStyle(color: Colors.grey, fontSize: 11), maxLines: 2, overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Tukar di halaman game (via webview)',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
