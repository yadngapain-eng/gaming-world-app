import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RewardsScreen extends StatelessWidget {
  const RewardsScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(body: Center(child: Text('Login dulu')));
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('🎁 Reward'),
        backgroundColor: const Color(0xFF7c3aed),
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
        builder: (context, snap) {
          final data = snap.data?.data() as Map<String, dynamic>? ?? {};
          final balance = data['balance'] ?? 0;
          
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Balance card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFfbbf24), Color(0xFFf59e0b)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    const Text('SALDO KOIN', style: TextStyle(color: Color(0xFF78350f), fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('💰 ', style: TextStyle(fontSize: 32)),
                        Text('$balance',
                          style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: Color(0xFF78350f))),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              
              // Menu
              _menuCard(context, '📺', 'Tonton Iklan', 'Dapat hingga 10.000 koin', () {
                _showComingSoon(context);
              }),
              const SizedBox(height: 12),
              _menuCard(context, '📅', 'Absen Harian', 'Bonus koin tiap hari', () {
                _showComingSoon(context);
              }),
              const SizedBox(height: 12),
              _menuCard(context, '👥', 'Referral', '500 koin per teman', () {
                _showComingSoon(context);
              }),
            ],
          );
        },
      ),
    );
  }
  
  Widget _menuCard(BuildContext context, String icon, String title, String sub, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
        ),
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 32)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 4),
                  Text(sub, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
  
  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('🚧 Fitur sedang dikembangkan')),
    );
  }
}
