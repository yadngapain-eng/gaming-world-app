import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/firestore_service.dart';
import '../services/reward_service.dart';
import '../services/topup_service.dart';
import '../models/game_model.dart';
import 'minigame_screen.dart';
import 'topup_list_screen.dart';
import 'minigame_list_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gaming World'),
        backgroundColor: const Color(0xFF7c3aed),
        foregroundColor: Colors.white,
        actions: [
          StreamBuilder<num>(
            stream: RewardService.streamBalance(),
            builder: (context, snap) {
              final balance = snap.data ?? 0;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('\u{1F4B0}', style: TextStyle(fontSize: 14)),
                      const SizedBox(width: 4),
                      Text(balance.toStringAsFixed(0),
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
                    ],
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => (context as Element).markNeedsBuild(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ============================================
            //  SECTION 1: MINI GAME (UTAMA)
            // ============================================
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('\u{1F3AE} Mini Game',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                  TextButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(
                        builder: (_) => const MinigameListScreen()));
                    },
                    child: const Text('Lihat Semua \u2192',
                      style: TextStyle(color: Color(0xFF7c3aed), fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            Consumer<FirestoreService>(
              builder: (context, fs, _) {
                return StreamBuilder<List<Map<String, dynamic>>>(
                  stream: fs.streamMinigames(),
                  builder: (context, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return const Padding(
                        padding: EdgeInsets.all(20),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    if (!snap.hasData || snap.data!.isEmpty) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Center(
                          child: Column(
                            children: [
                              Icon(Icons.videogame_asset, size: 50, color: Colors.grey),
                              SizedBox(height: 8),
                              Text('Belum ada mini game', style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                        ),
                      );
                    }
                    final games = snap.data!.map((m) => Game.fromMap(m)).toList();
                    return SizedBox(
                      height: 170,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        itemCount: games.length,
                        itemBuilder: (context, i) => _miniGameCard(context, games[i]),
                      ),
                    );
                  },
                );
              },
            ),

            const SizedBox(height: 20),

            // ============================================
            //  SECTION 2: TOP UP GAME (GRID BAWAH)
            // ============================================
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('\u{1F6D2} Top Up Game',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                  TextButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(
                        builder: (_) => const TopupListScreen()));
                    },
                    child: const Text('Lihat Semua \u2192',
                      style: TextStyle(color: Color(0xFF7c3aed), fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  childAspectRatio: 0.85,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: TopupService.getGames().take(8).length,
                itemBuilder: (context, i) {
                  return _topupIconCard(context, TopupService.getGames()[i]);
                },
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _miniGameCard(BuildContext context, Game g) {
    return Container(
      width: 150,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10)],
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(
            builder: (_) => MinigameScreen(game: g.toMap())));
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(g.icon, style: const TextStyle(fontSize: 44)),
              const SizedBox(height: 6),
              Text(g.name,
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFF58cc02),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('\u25B6 MAIN',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 10)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _topupIconCard(BuildContext context, Map<String, dynamic> game) {
    final iconUrl = TopupService.iconUrl(game['icon_file'] as String);
    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(
          builder: (_) => const TopupListScreen()));
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6)],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  iconUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (context, err, stack) => Container(
                    color: Colors.grey.shade100,
                    child: Center(
                      child: Text(
                        game['name'].toString().substring(0, 1),
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              game['name'] as String,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 8),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
