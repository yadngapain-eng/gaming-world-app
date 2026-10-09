import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'achievement_screen.dart';
import 'reward_screen.dart';
import 'game_store_screen.dart';
import '../widgets/legal_dialogs.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  String _fmtRupiah(dynamic n) {
    try {
      final v = (n ?? 0).toInt();
      return v.toString().replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
        (m) => m[1]! + '.',
      );
    } catch (_) {
      return n.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('\u{1F464} Profil'),
          backgroundColor: const Color(0xFF7c3aed),
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('\u{1F512}', style: TextStyle(fontSize: 60)),
              const SizedBox(height: 12),
              const Text('Login dulu untuk lihat profil',
                  style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () =>
                    Navigator.pushReplacementNamed(context, '/login'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7c3aed),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Login'),
              ),
            ],
          ),
        ),
      );
    }

    final isGuest = user.isAnonymous;

    return Scaffold(
      appBar: AppBar(
        title: const Text('\u{1F464} Profil Saya'),
        backgroundColor: const Color(0xFF7c3aed),
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .snapshots(),
        builder: (context, snap) {
          final data = snap.data?.data() as Map<String, dynamic>? ?? {};

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (isGuest) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFfbbf24), Color(0xFFf59e0b)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('\u{1F3AE} ', style: TextStyle(fontSize: 18)),
                          Text(
                            'Mode Guest',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                              color: Color(0xFF78350f),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Login untuk simpan koin & order ke akun permanen',
                        textAlign: TextAlign.center,
                        style:
                            TextStyle(fontSize: 12, color: Color(0xFF78350f)),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            try {
                              await FirebaseAuth.instance.signOut();
                            } catch (_) {}
                            if (context.mounted) {
                              Navigator.pushReplacementNamed(context, '/login');
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF78350f),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            '\u{1F511} Login / Daftar',
                            style: TextStyle(fontWeight: FontWeight.w900),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.05), blurRadius: 10),
                  ],
                ),
                child: Column(
                  children: [
                    Text(data['avatar'] ?? '\u{1F464}',
                        style: const TextStyle(fontSize: 72)),
                    const SizedBox(height: 12),
                    Text(
                      data['displayName'] ?? (isGuest ? 'Guest' : 'User'),
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isGuest ? 'Guest Mode' : (user.email ?? ''),
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isGuest
                            ? Colors.orange.withOpacity(0.15)
                            : Colors.green.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        isGuest ? 'BELUM LOGIN' : 'TERVERIFIKASI',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isGuest
                              ? Colors.orange[800]
                              : Colors.green[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                      child: _statCard(
                          '\u{1FA99}', '${data['balance'] ?? 0}', 'Koin')),
                  const SizedBox(width: 12),
                  Expanded(
                      child: _statCard('\u{1F4B0}',
                          'Rp ${_fmtRupiah(data['totalSpent'])}', 'Belanja')),
                ],
              ),
              const SizedBox(height: 16),
              _menuItem(context, Icons.monetization_on, 'Kumpulkan Koin', () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const RewardScreen()));
              }),
              _menuItem(context, Icons.shopping_cart, 'Tukar Hadiah', () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const GameStoreScreen()));
              }),
              _menuItem(context, Icons.emoji_events, 'Achievement', () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const AchievementScreen()));
              }),
              _menuItem(context, Icons.person, 'Ganti Nama', () {
                _showRenameDialog(
                    context, data['displayName']?.toString() ?? '');
              }),
              _menuItem(context, Icons.help_outline, 'Bantuan',
                  () => LegalDialogs.showHelp(context)),
              _menuItem(context, Icons.info_outline, 'Tentang',
                  () => LegalDialogs.showAbout(context)),
              _menuItem(context, Icons.privacy_tip_outlined,
                  'Kebijakan Privasi', () => LegalDialogs.showPrivacy(context)),
              _menuItem(context, Icons.description_outlined,
                  'Syarat & Ketentuan', () => LegalDialogs.showTerms(context)),
              if (!isGuest)
                _menuItem(context, Icons.logout, 'Logout', () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      title: const Text('Logout?'),
                      content: const Text('Yakin mau logout dari akun ini?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Batal'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: TextButton.styleFrom(
                              foregroundColor: Colors.red),
                          child: const Text('Logout'),
                        ),
                      ],
                    ),
                  );
                  if (confirm != true) return;
                  await FirebaseAuth.instance.signOut();
                  if (context.mounted) {
                    Navigator.pushReplacementNamed(context, '/login');
                  }
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
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
        ],
      ),
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 8),
          Text(value,
              style:
                  const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
          const SizedBox(height: 4),
          Text(label,
              style: const TextStyle(color: Colors.grey, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _menuItem(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap, {
    Color? color,
  }) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title,
          style: TextStyle(color: color, fontWeight: FontWeight.w600)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  Future<void> _showRenameDialog(
      BuildContext context, String current) async {
    final ctrl = TextEditingController(text: current);
    final result = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Ganti Nama'),
        content: TextField(
          controller: ctrl,
          maxLength: 20,
          decoration: const InputDecoration(
            hintText: 'Nama baru...',
            counterText: '',
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal')),
          TextButton(
              onPressed: () => Navigator.pop(context, ctrl.text.trim()),
              child: const Text('Simpan')),
        ],
      ),
    );

    if (result == null || result.isEmpty) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set({'displayName': result}, SetOptions(merge: true));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nama berhasil diubah')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal: $e')),
        );
      }
    }
  }
}
