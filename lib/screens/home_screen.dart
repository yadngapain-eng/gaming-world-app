import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/firestore_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gaming World'),
        backgroundColor: const Color(0xFF7c3aed),
        foregroundColor: Colors.white,
      ),
      body: Consumer<FirestoreService>(
        builder: (context, fs, _) {
          return StreamBuilder<List<Map<String, dynamic>>>(
            stream: fs.streamMinigames(),
            builder: (context, snap) {
              if (!snap.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final games = snap.data!;
              if (games.isEmpty) {
                return const Center(child: Text('Belum ada game'));
              }
              return GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, childAspectRatio: 1.1, crossAxisSpacing: 12, mainAxisSpacing: 12,
                ),
                itemCount: games.length,
                itemBuilder: (context, i) {
                  final g = games[i];
                  return Card(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(g['icon'] ?? '🎮', style: const TextStyle(fontSize: 40)),
                        const SizedBox(height: 8),
                        Text(g['name'] ?? 'Game', style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
