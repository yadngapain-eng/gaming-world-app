import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/reward_service.dart';

class RewardScreen extends StatefulWidget {
  const RewardScreen({super.key});
  @override
  State<RewardScreen> createState() => _RewardScreenState();
}

class _RewardScreenState extends State<RewardScreen> {
  static const String ADSTERRA_URL = 'https://www.profitableratecpmnetwork.com/rnve2ckg?key=f15341dc4ed341cc62411d69d314d518';

  bool _loading = false;

  Future<void> _showSnack(String msg, {bool error = false}) async {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: error ? Colors.red : Colors.green,
      duration: const Duration(seconds: 3),
    ));
  }

  Future<void> _watchAd() async {
    setState(() => _loading = true);
    try {
      final uri = Uri.parse(ADSTERRA_URL);

      // Strategi: COBA LANGSUNG launch, jangan cek canLaunchUrl dulu
      // (canLaunchUrl di Android 11+ return false tanpa <queries>)
      bool launched = false;

      // Coba mode external (buka browser lain)
      try {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        launched = true;
        debugPrint('[Ad] Launched via externalApplication');
      } catch (e1) {
        debugPrint('[Ad] externalApplication gagal: $e1');
      }

      // Fallback: coba platformDefault
      if (!launched) {
        try {
          await launchUrl(uri, mode: LaunchMode.platformDefault);
          launched = true;
          debugPrint('[Ad] Launched via platformDefault');
        } catch (e2) {
          debugPrint('[Ad] platformDefault gagal: $e2');
        }
      }

      // Kalau dua-duanya gagal, cek canLaunchUrl untuk pesan error jelas
      if (!launched) {
        final can = await canLaunchUrl(uri);
        await _showSnack(
          can
              ? 'Gagal buka browser. Coba lagi.'
              : 'Tidak ada browser terinstall. Install Chrome/Firefox dulu.',
          error: true,
        );
        return;
      }

      // User buka iklan — tunggu 8 detik untuk kembali
      await Future.delayed(const Duration(seconds: 8));

      final result = await RewardService.claimAdReward();
      if (result['ok'] == true) {
        await _showSnack(result['message']);
      } else {
        await _showSnack(result['message'] ?? 'Gagal klaim', error: true);
      }
    } catch (e) {
      await _showSnack('Error: ' + e.toString(), error: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _claimDaily() async {
    setState(() => _loading = true);
    try {
      final result = await RewardService.claimDaily();
      if (result['ok'] == true) {
        await _showSnack(result['message']);
      } else {
        await _showSnack(result['message'] ?? 'Gagal', error: true);
      }
    } catch (e) {
      await _showSnack('Error: ' + e.toString(), error: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _showReferral() async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(children: [
          Text('👥 ', style: TextStyle(fontSize: 24)),
          Text('Referral'),
        ]),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Ajak teman dan dapat 500 koin!', style: TextStyle(fontSize: 14)),
            const SizedBox(height: 12),
            const Text('Bagikan aplikasi ini ke teman, mereka daftar, kamu dapat koin.', style: TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.purple.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text('Fitur referral akan segera hadir!', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Tutup')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('💰 Kumpulkan Koin'),
        backgroundColor: const Color(0xFF7c3aed),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Saldo Card
          StreamBuilder<num>(
            stream: RewardService.streamBalance(),
            builder: (context, snap) {
              final balance = snap.data ?? 0;
              return Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFfbbf24), Color(0xFFf59e0b)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.orange.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8))],
                ),
                child: Column(
                  children: [
                    const Text('SALDO KOIN', style: TextStyle(color: Color(0xFF78350f), fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.2)),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('🪙 ', style: TextStyle(fontSize: 32)),
                        Text(balance.toStringAsFixed(0), style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: Color(0xFF78350f))),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('= Rp ' + balance.toStringAsFixed(0), style: const TextStyle(fontSize: 14, color: Color(0xFF78350f))),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 20),

          // Mission Cards
          _missionCard('📺', 'Tonton Iklan', 'Dapat 1-10.000 koin', _watchAd, const Color(0xFF1cb0f6)),
          const SizedBox(height: 12),
          _missionCard('📅', 'Absen Harian', 'Bonus 15 koin tiap hari', _claimDaily, const Color(0xFF58cc02)),
          const SizedBox(height: 12),
          _missionCard('👥', 'Ajak Teman', '500 koin per teman', _showReferral, const Color(0xFFa855f7)),
          const SizedBox(height: 20),

          // Info card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFFfef3c7), Color(0xFFfde68a)]),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFf59e0b), width: 2),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('💡 Tips', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Color(0xFF78350f))),
                SizedBox(height: 8),
                Text('• Koin dipakai untuk top up & beli item game', style: TextStyle(fontSize: 12, color: Color(0xFF78350f))),
                Text('• 1 koin = Rp 1', style: TextStyle(fontSize: 12, color: Color(0xFF78350f))),
                Text('• Tonton iklan berulang untuk koin lebih banyak', style: TextStyle(fontSize: 12, color: Color(0xFF78350f))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _missionCard(String icon, String title, String subtitle, VoidCallback onTap, Color color) {
    return InkWell(
      onTap: _loading ? null : onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
          border: Border(left: BorderSide(color: color, width: 4)),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(child: Text(icon, style: const TextStyle(fontSize: 26))),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}
