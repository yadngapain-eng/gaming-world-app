import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/firestore_service.dart';
import '../models/game_model.dart';
import 'minigame_screen.dart';

class MinigameListScreen extends StatelessWidget {
  const MinigameListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('\u{1F3AE} Mini Game'),
        backgroundColor: const Color(0xFF7c3aed),
        foregroundColor: Colors.white,
      ),
      body: Consumer<FirestoreService>(
        builder: (context, fs, _) {
          return StreamBuilder<List<Map<String, dynamic>>>(
            stream: fs.streamMinigames(),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snap.hasData || snap.data!.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.videogame_asset, size: 80, color: Colors.grey),
                      SizedBox(height: 12),
                      Text('Belum ada mini game', style: TextStyle(color: Colors.grey, fontSize: 15)),
                      SizedBox(height: 8),
                      Text('Admin sedang menyiapkan game seru', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                );
              }
              final games = snap.data!.map((m) => Game.fromMap(m)).toList();
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: games.length,
                itemBuilder: (context, i) {
                  return _gameCard(context, games[i]);
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _gameCard(BuildContext context, Game g) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => MinigameScreen(game: g.toMap())),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: const Color(0xFF7c3aed).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(g.icon, style: const TextStyle(fontSize: 36)),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(g.name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
                    const SizedBox(height: 4),
                    Text(
                      g.description.isEmpty ? 'Main & dapat koin' : g.description,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF58cc02),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  '\u25B6 MAIN',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
