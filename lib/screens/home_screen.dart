import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/firestore_service.dart';
import '../services/reward_service.dart';
import '../models/game_model.dart';
import 'topup_screen.dart';
import 'minigame_screen.dart';
import 'orders_screen.dart';
import 'profile_screen.dart';
import '../widgets/live_users_counter.dart';
import '../widgets/floating_chat_button.dart';
import '../widgets/main_menu_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: const [
          _HomeTab(),
          OrdersScreen(),
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.receipt_long), label: 'Pesanan'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gaming World'),
        backgroundColor: const Color(0xFF7c3aed),
        foregroundColor: Colors.white,
        actions: [
          // Coin Badge
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
                      const Text('🪙', style: TextStyle(fontSize: 14)),
                      const SizedBox(width: 4),
                      Text(
                        balance.toStringAsFixed(0),
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          // Live Users
          const Padding(
            padding: EdgeInsets.only(right: 4),
            child: Center(child: LiveUsersCounter()),
          ),
          // Menu
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => MainMenuSheet.show(context),
          ),
        ],
      ),
      body: Stack(
        children: [
          Consumer<FirestoreService>(
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
                          Text('Belum ada game', style: TextStyle(color: Colors.grey, fontSize: 15)),
                          SizedBox(height: 8),
                          Text('Admin sedang menyiapkan game seru untukmu', style: TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                    );
                  }
                  final games = snap.data!.map((m) => Game.fromMap(m)).toList();
                  return GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1.05,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: games.length,
                    itemBuilder: (context, i) {
                      final g = games[i];
                      return _gameCard(context, g);
                    },
                  );
                },
              );
            },
          ),
          const FloatingChatButton(),
        ],
      ),
    );
  }

  Widget _gameCard(BuildContext context, Game g) {
    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => TopupScreen(game: g)));
      },
      onLongPress: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => MinigameScreen(game: g.toMap())));
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12)],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(g.icon, style: const TextStyle(fontSize: 44)),
            const SizedBox(height: 8),
            Text(g.name,
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFF7c3aed).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text('Tap / Hold', style: TextStyle(fontSize: 9, color: Color(0xFF7c3aed), fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
