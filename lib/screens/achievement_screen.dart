import 'package:flutter/material.dart';
import '../services/achievement_service.dart';

class AchievementScreen extends StatefulWidget {
  const AchievementScreen({super.key});
  @override
  State<AchievementScreen> createState() => _AchievementScreenState();
}

class _AchievementScreenState extends State<AchievementScreen> {
  List<Achievement> _list = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await AchievementService.getUserAchievements();
    if (!mounted) return;
    setState(() { _list = list; _loading = false; });
  }

  Color _tierColor(String tier) {
    switch (tier) {
      case 'rare': return const Color(0xFF3b82f6);
      case 'epic': return const Color(0xFFa855f7);
      case 'legendary': return const Color(0xFFf59e0b);
      case 'mythic': return const Color(0xFFef4444);
      default: return const Color(0xFF94a3b8);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('\u{1F3C6} Achievement'),
        backgroundColor: const Color(0xFF7c3aed),
        foregroundColor: Colors.white,
      ),
      body: _loading
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: _load,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _list.length,
              itemBuilder: (context, i) {
                final a = _list[i];
                final color = _tierColor(a.tier);
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border(left: BorderSide(color: color, width: 4)),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
                  ),
                  child: Row(
                    children: [
                      Text(a.icon, style: const TextStyle(fontSize: 32)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(a.title,
                                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: color,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(a.tier.toUpperCase(),
                                    style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(a.description,
                              style: const TextStyle(color: Colors.grey, fontSize: 12)),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: a.unlocked ? const Color(0xFFfbbf24) : Colors.grey[300],
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text('+${a.reward} koin',
                                    style: TextStyle(
                                      fontSize: 10, fontWeight: FontWeight.bold,
                                      color: a.unlocked ? Colors.white : Colors.grey[600],
                                    )),
                                ),
                                const SizedBox(width: 8),
                                if (a.unlocked)
                                  const Row(children: [
                                    Icon(Icons.check_circle, color: Colors.green, size: 14),
                                    SizedBox(width: 3),
                                    Text('Unlocked', style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
                                  ])
                                else
                                  const Row(children: [
                                    Icon(Icons.lock, color: Colors.grey, size: 14),
                                    SizedBox(width: 3),
                                    Text('Belum', style: TextStyle(color: Colors.grey, fontSize: 10)),
                                  ]),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
    );
  }
}
