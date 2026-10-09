import 'package:flutter/material.dart';

class LegalDialogs {
  static void showAbout(BuildContext context) {
    _showDialog(
      context,
      title: 'Tentang Gaming World',
      icon: '\u{2139}',
      content: 'Gaming World adalah platform top up game, pulsa, dan voucher termurah di Indonesia.\n\n'
          'Kami juga menyediakan mini game seru dengan reward koin yang bisa ditukar jadi diamond, voucher, atau item game lainnya.\n\n'
          'Versi: 1.1.0\n'
          '© 2026 Gaming World',
    );
  }

  static void showPrivacy(BuildContext context) {
    _showDialog(
      context,
      title: 'Kebijakan Privasi',
      icon: '\u{1F512}',
      content: 'Kami menghargai privasi kamu. Data yang kami kumpulkan:\n\n'
          '• Nama & email (untuk login)\n'
          '• Data order (untuk proses top up)\n'
          '• Koin & achievement (untuk reward)\n\n'
          'Kami TIDAK menjual data kamu ke pihak ketiga. Semua data disimpan di Firebase dengan enkripsi HTTPS.',
    );
  }

  static void showTerms(BuildContext context) {
    _showDialog(
      context,
      title: 'Syarat & Ketentuan',
      icon: '\u{1F4DC}',
      content: 'Dengan menggunakan aplikasi ini, kamu setuju:\n\n'
          '• Tidak melakukan kecurangan (bot, multiple account)\n'
          '• Data akun yang diisi benar dan valid\n'
          '• Refund hanya jika order gagal dari pihak kami\n'
          '• Koin bisa dipakai untuk top up & beli item\n\n'
          'Pelanggaran akan mengakibatkan penghapusan akun.',
    );
  }

  static void showHelp(BuildContext context) {
    _showDialog(
      context,
      title: 'Bantuan',
      icon: '\u{2753}',
      content: 'Cara Top Up:\n'
          '1. Pilih game / pulsa / voucher\n'
          '2. Isi data akun (User ID / nomor)\n'
          '3. Pilih nominal\n'
          '4. Pilih metode pembayaran\n'
          '5. Transfer sesuai nominal\n'
          '6. Upload bukti transfer\n'
          '7. Order diproses dalam 1-5 menit\n\n'
          'Metode Pembayaran:\n'
          'SEABANK, GoPay, DANA, OVO, ShopeePay, QRIS\n\n'
          'Butuh bantuan? Chat kami via tombol Chat AI di halaman utama.',
    );
  }

  static void _showDialog(
    BuildContext context, {
    required String title,
    required String icon,
    required String content,
  }) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(20),
          constraints: const BoxConstraints(maxHeight: 500),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(icon, style: const TextStyle(fontSize: 28)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Flexible(
                child: SingleChildScrollView(
                  child: Text(
                    content,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.6,
                      color: Color(0xFF444444),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7c3aed),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Tutup',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
