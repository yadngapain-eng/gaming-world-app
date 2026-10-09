import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Achievement {
  final String id;
  final String title;
  final String description;
  final String icon;
  final String tier; // common | rare | epic | legendary | mythic
  final int reward;
  final bool unlocked;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.tier,
    required this.reward,
    required this.unlocked,
  });

  factory Achievement.fromMap(Map<String, dynamic> m, {bool unlocked = false}) {
    return Achievement(
      id: m['id'] ?? '',
      title: m['title'] ?? '',
      description: m['description'] ?? '',
      icon: m['icon'] ?? '\u{1F3C6}',
      tier: m['tier'] ?? 'common',
      reward: (m['reward'] ?? 0) as int,
      unlocked: unlocked,
    );
  }
}

class AchievementService {
  static Future<List<Achievement>> getUserAchievements() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return _defaultList();
    try {
      final unlockedSnap = await FirebaseFirestore.instance
          .collection('users').doc(user.uid)
          .collection('achievements').get();
      final unlockedIds = unlockedSnap.docs.map((d) => d.id).toSet();
      final all = _defaultList();
      return all.map((a) => Achievement(
        id: a.id, title: a.title, description: a.description,
        icon: a.icon, tier: a.tier, reward: a.reward,
        unlocked: unlockedIds.contains(a.id),
      )).toList();
    } catch (e) {
      debugPrint('[Achievement] Error: $e');
      return _defaultList();
    }
  }

  static List<Achievement> _defaultList() {
    return [
      Achievement(id: 'first_topup', title: 'Pembeli Pertama', description: 'Lakukan top up pertama', icon: '\u{1F6CD}', tier: 'common', reward: 50, unlocked: false),
      Achievement(id: 'topup_5x', title: 'Pelanggan Setia', description: 'Top up 5 kali', icon: '\u{1F48E}', tier: 'rare', reward: 200, unlocked: false),
      Achievement(id: 'topup_20x', title: 'Sultan Top Up', description: 'Top up 20 kali', icon: '\u{1F451}', tier: 'epic', reward: 1000, unlocked: false),
      Achievement(id: 'first_game', title: 'Gamer Sejati', description: 'Main mini game pertama', icon: '\u{1F3AE}', tier: 'common', reward: 30, unlocked: false),
      Achievement(id: 'watch_10ads', title: 'Pengumpul Koin', description: 'Tonton 10 iklan', icon: '\u{1F4FA}', tier: 'rare', reward: 150, unlocked: false),
      Achievement(id: 'refer_1', title: 'Ajak Teman', description: 'Refer 1 teman', icon: '\u{1F465}', tier: 'epic', reward: 500, unlocked: false),
      Achievement(id: 'jackpot', title: 'Jackpot Winner', description: 'Menang jackpot mini game', icon: '\u{1F3B0}', tier: 'legendary', reward: 5000, unlocked: false),
      Achievement(id: 'topup_100x', title: 'Legenda Gaming World', description: 'Top up 100 kali', icon: '\u{1F409}', tier: 'mythic', reward: 10000, unlocked: false),
    ];
  }
}
