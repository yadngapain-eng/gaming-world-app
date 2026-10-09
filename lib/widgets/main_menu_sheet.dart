import 'package:flutter/material.dart';
import '../screens/reward_screen.dart';
import '../screens/game_store_screen.dart';
import '../screens/achievement_screen.dart';
import '../screens/chat_screen.dart';
import '../widgets/legal_dialogs.dart';

class MainMenuSheet {
  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.only(bottom: 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Text('Menu', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20)),
              const SizedBox(height: 16),
              _menuItem(ctx, '💰', 'Kumpulkan Koin', 'Tonton iklan, absen harian', () {
                Navigator.pop(ctx);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const RewardScreen()));
              }),
              _menuItem(ctx, '🛒', 'Tukar Hadiah', 'Tukar koin jadi item game', () {
                Navigator.pop(ctx);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const GameStoreScreen()));
              }),
              _menuItem(ctx, '🏆', 'Achievement', 'Lihat pencapaianmu', () {
                Navigator.pop(ctx);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const AchievementScreen()));
              }),
              _menuItem(ctx, '💬', 'Chat AI', 'Tanya apa saja', () {
                Navigator.pop(ctx);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatScreen()));
              }),
              const Divider(height: 1, indent: 20, endIndent: 20),
              _menuItem(ctx, '❓', 'Bantuan', 'Cara pakai aplikasi', () {
                Navigator.pop(ctx);
                LegalDialogs.showHelp(context);
              }),
              _menuItem(ctx, 'ℹ️', 'Tentang', 'Info aplikasi', () {
                Navigator.pop(ctx);
                LegalDialogs.showAbout(context);
              }),
              _menuItem(ctx, '🔒', 'Kebijakan Privasi', '', () {
                Navigator.pop(ctx);
                LegalDialogs.showPrivacy(context);
              }),
              _menuItem(ctx, '📜', 'Syarat & Ketentuan', '', () {
                Navigator.pop(ctx);
                LegalDialogs.showTerms(context);
              }),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _menuItem(BuildContext sheetCtx, String icon, String title, String subtitle, VoidCallback onTap) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 44, height: 44,
        decoration: BoxDecoration(
          color: const Color(0xFF7c3aed).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(child: Text(icon, style: const TextStyle(fontSize: 22))),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
      subtitle: subtitle.isNotEmpty
          ? Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12))
          : null,
      trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
    );
  }
}
