import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'achievement_screen.dart';
import 'reward_screen.dart';
import 'game_store_screen.dart';
import '../widgets/legal_dialogs.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final isGuest = user == null || user.isAnonymous;
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profil')),
        body: const Center(child: Text('Login dulu')),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('👤 Profil Saya'),
        backgroundColor: const Color(0xFF7c3aed),
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
        builder: (context, snap) {
          final data = snap.data?.data() as Map<String, dynamic>? ?? {};
          
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Avatar card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                ),
                child: Column(
                  children: [
                    Text(data['avatar'] ?? '👤', style: const TextStyle(fontSize: 72)),
                    const SizedBox(height: 12),
                    Text(data['displayName'] ?? 'Guest',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 4),
                    Text(user.isAnonymous ? 'Guest Mode' : (user.email ?? ''),
                      style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // Stats
              Row(
                children: [
                  Expanded(child: _statCard('🪙', '${data['balance'] ?? 0}', 'Koin')),
                  const SizedBox(width: 12),
                  Expanded(child: _statCard('💰', 'Rp ${data['totalSpent'] ?? 0}', 'Belanja')),
                ],
              ),
              const SizedBox(height: 16),
              
              // Menu
              _menuItem(context, Icons.monetization_on, 'Kumpulkan Koin', () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const RewardScreen()));
                }),
                _menuItem(context, Icons.shopping_cart, 'Tukar Hadiah', () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const GameStoreScreen()));
                }),
                _menuItem(context, Icons.emoji_events, 'Achievement', () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const AchievementScreen()));
                }),
                _menuItem(context, Icons.person, 'Ganti Nama', () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('🚧 Fitur dikembangkan')),
                );
              }),
              _menuItem(context, Icons.help_outline, 'Bantuan', () => LegalDialogs.showHelp(context)),
              _menuItem(context, Icons.info_outline, 'Tentang', () => LegalDialogs.showAbout(context)),
                _menuItem(context, Icons.privacy_tip_outlined, 'Kebijakan Privasi', () => LegalDialogs.showPrivacy(context)),
                _menuItem(context, Icons.description_outlined, 'Syarat & Ketentuan', () => LegalDialogs.showTerms(context)),
              if (!isGuest) if (!isGuest) _menuItem(context, Icons.logout, 'Logout', () async {
                await FirebaseAuth.instance.signOut();
                if (context.mounted) Navigator.pushReplacementNamed(context, '/login');
              }, color: Colors.red),
            ],
          );
        },
      ),
    );
  }
  
  Widget _statCard(String icon, String value, String label) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
        ],
      ),
    );
  }
  
  Widget _menuItem(BuildContext context, IconData icon, String title, VoidCallback onTap, {Color? color}) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title, style: TextStyle(color: color)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
