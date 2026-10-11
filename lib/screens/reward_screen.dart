import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import '../services/reward_service.dart';
import '../config/app_config.dart';

class RewardScreen extends StatefulWidget {
  const RewardScreen({super.key});
  @override
  State<RewardScreen> createState() => _RewardScreenState();
}

class _RewardScreenState extends State<RewardScreen> {
  static const String ADSTERRA_URL = 'https://www.profitableratecpmnetwork.com/rnve2ckg?key=f15341dc4ed341cc62411d69d314d518';

  bool _loading = false;

  // Referral state
  String _myReferralCode = '';
  int _referralCount = 0;
  int _referralEarned = 0;
  bool _loadingReferral = false;
  bool _referralUsed = false;
  String? _referredBy;
  List<Map<String, dynamic>> _referralList = [];
  final _referralController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadReferralData();
  }

  @override
  void dispose() {
    _referralController.dispose();
    super.dispose();
  }

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

  Future<void> _loadReferralData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.isAnonymous) return;

    try {
      final res = await http.post(
        Uri.parse('${AppConfig.apiBase}/referral/my'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userId': user.uid}),
      ).timeout(const Duration(seconds: 15));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['ok'] == true && mounted) {
          setState(() {
            _myReferralCode = data['code'] ?? '';
            _referralCount = data['referralCount'] ?? 0;
            _referralEarned = data['referralEarned'] ?? 0;
            _referralUsed = data['referralUsed'] == true;
            _referredBy = data['referredBy'];
          });
        }
      }
    } catch (e) {
      debugPrint('[Referral] Load error: $e');
    }
  }

  Future<void> _loadReferralList() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final res = await http.post(
        Uri.parse('${AppConfig.apiBase}/referral/list'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userId': user.uid}),
      ).timeout(const Duration(seconds: 15));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['ok'] == true && mounted) {
          setState(() {
            _referralList = List<Map<String, dynamic>>.from(data['referrals'] ?? []);
          });
        }
      }
    } catch (e) {
      debugPrint('[Referral] List error: $e');
    }
  }

  Future<void> _applyReferralCode() async {
    final code = _referralController.text.trim().toUpperCase();
    if (code.isEmpty) {
      _showSnack('Masukkan kode dulu', error: true);
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.isAnonymous) {
      _showSnack('Login dulu untuk pakai referral', error: true);
      return;
    }

    setState(() => _loadingReferral = true);

    try {
      final res = await http.post(
        Uri.parse('${AppConfig.apiBase}/referral/apply'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userId': user.uid, 'code': code}),
      ).timeout(const Duration(seconds: 15));

      final data = jsonDecode(res.body);

      if (data['ok'] == true) {
        _showSnack('Berhasil! +${data['newUserBonus']} koin');
        _referralController.clear();
        if (mounted) Navigator.pop(context);
        _loadReferralData();
      } else {
        _showSnack(data['error'] ?? 'Gagal pakai kode', error: true);
      }
    } catch (e) {
      _showSnack('Error: $e', error: true);
    } finally {
      if (mounted) setState(() => _loadingReferral = false);
    }
  }

  Future<void> _showReferral() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.isAnonymous) {
      _showSnack('Login dulu untuk pakai referral', error: true);
      return;
    }

    await _loadReferralList();
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(20),
          constraints: const BoxConstraints(maxHeight: 600),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Text('\u{1F465}', style: TextStyle(fontSize: 28)),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text('Referral',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Kode referral
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [Color(0xFFa855f7), Color(0xFF7c3aed)]),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('KODE REFERRAL SAYA',
                          style: TextStyle(
                              color: Colors.white70,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2)),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              _myReferralCode.isEmpty ? '...' : _myReferralCode,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 2,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: _myReferralCode));
                              _showSnack('Kode disalin!');
                            },
                            icon: const Icon(Icons.copy, color: Colors.white),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Stats
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            Text('$_referralCount',
                                style: const TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.w900)),
                            const Text('Teman diajak',
                                style: TextStyle(fontSize: 10, color: Colors.grey)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            Text('$_referralEarned',
                                style: const TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.w900)),
                            const Text('Koin didapat',
                                style: TextStyle(fontSize: 10, color: Colors.grey)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Input kode
                if (!_referralUsed) ...[
                  const Text('Punya kode dari teman?',
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _referralController,
                          textCapitalization: TextCapitalization.characters,
                          decoration: InputDecoration(
                            hintText: 'Masukkan kode',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10)),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _loadingReferral ? null : _applyReferralCode,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF7c3aed),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                        ),
                        child: const Text('Pakai'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.green.withOpacity(0.3)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green, size: 20),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text('Kamu sudah pakai kode referral',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Daftar referral
                if (_referralList.isNotEmpty) ...[
                  const Text('Teman yang kamu ajak',
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                  const SizedBox(height: 8),
                  ..._referralList.map((r) => ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: const Text('\u{1F464}',
                            style: TextStyle(fontSize: 20)),
                        title: Text(r['refereeName']?.toString() ?? 'User',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 13)),
                        trailing: Text('+${r['referrerBonus']}',
                            style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                                fontSize: 13)),
                      )),
                ],

                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Tutup'),
                  ),
                ),
              ],
            ),
          ),
        ),
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
                        const Text('💰 ', style: TextStyle(fontSize: 32)),
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
