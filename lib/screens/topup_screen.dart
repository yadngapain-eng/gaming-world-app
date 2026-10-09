import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../services/game_data_service.dart';
import '../services/order_telegram_service.dart';

class TopupScreen extends StatefulWidget {
  final String gameId;
  const TopupScreen({super.key, required this.gameId});

  @override
  State<TopupScreen> createState() => _TopupScreenState();
}

class _TopupScreenState extends State<TopupScreen> {
  Map<String, dynamic>? _game;
  List<Map<String, dynamic>> _products = [];
  Map<String, String> _userData = {};
  Map<String, dynamic>? _selectedProduct;
  Map<String, dynamic>? _selectedPayment;
  List<Map<String, dynamic>> _payments = [];
  bool _loading = true;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    // Pastikan data game loaded
    if (!GameDataService.isLoaded) {
      await GameDataService.load();
    }

    final games = GameDataService.allGames;
    _game = games[widget.gameId];
    _products = GameDataService.getProducts(widget.gameId);

    // Load payments dari Firestore
    try {
      final payDoc = await FirebaseFirestore.instance.collection('config').doc('payments').get();
      if (payDoc.exists) {
        final methods = payDoc.data()?['methods'] as List? ?? [];
        _payments = methods
            .where((m) => m['active'] != false)
            .map((m) => Map<String, dynamic>.from(m))
            .toList();
      }
    } catch (e) {
      debugPrint('[Topup] Payments error: ' + e.toString());
    }

    if (mounted) setState(() => _loading = false);
  }

  num _getFinalPrice(Map<String, dynamic> product) {
    final basePrice = (product['price'] ?? 0) as num;
    final productId = product['id']?.toString() ?? '';
    return GameDataService.getFinalPrice(widget.gameId, productId, basePrice);
  }

  String _fmt(num n) {
    try {
      return n.toInt().toString().replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
        (m) => m[1]! + '.',
      );
    } catch (e) {
      return n.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_game == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(child: Text('Game tidak ditemukan')),
      );
    }

    final fields = (_game!['fields'] as List?) ?? [];
    final iconPath = _game!['icon']?.toString() ?? '';
    final iconUrl = iconPath.isEmpty
        ? ''
        : (iconPath.startsWith('http') ? iconPath : 'https://duniamu.my.id$iconPath');

    return Scaffold(
      appBar: AppBar(
        title: Text(_game!['name']?.toString() ?? 'Top Up'),
        backgroundColor: const Color(0xFF7c3aed),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
            ),
            child: Row(
              children: [
                Container(
                  width: 60, height: 60,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: iconUrl.isEmpty
                        ? Center(child: Text(_game!['name'].toString().substring(0, 1)))
                        : Image.network(iconUrl, fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => const Icon(Icons.gamepad, size: 30)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_game!['name']?.toString() ?? '',
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                      const SizedBox(height: 4),
                      Text(_game!['description']?.toString() ?? '',
                        style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Data Akun
          if (fields.isNotEmpty) ...[
            const Text('Data Akun', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
            const SizedBox(height: 8),
            ...fields.map((f) {
              final fid = f['id']?.toString() ?? '';
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: TextField(
                  onChanged: (v) => _userData[fid] = v,
                  decoration: InputDecoration(
                    labelText: f['label']?.toString() ?? fid,
                    hintText: f['placeholder']?.toString() ?? '',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              );
            }).toList(),
          ],

          // Produk
          const Text('Pilih Nominal', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 2.5,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: _products.length,
            itemBuilder: (context, i) {
              final p = _products[i];
              final isSelected = _selectedProduct?['id'] == p['id'];
              final finalPrice = _getFinalPrice(p);
              return InkWell(
                onTap: () => setState(() => _selectedProduct = p),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF7c3aed) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? const Color(0xFF7c3aed) : Colors.grey.shade300,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(p['name']?.toString() ?? '',
                        style: TextStyle(
                          fontSize: 11, fontWeight: FontWeight.w900,
                          color: isSelected ? Colors.white : Colors.black,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text('Rp ${_fmt(finalPrice)}',
                        style: TextStyle(
                          fontSize: 12, fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white70 : const Color(0xFF7c3aed),
                        )),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20),

          // Payment
          const Text('Pilih Pembayaran', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
          const SizedBox(height: 8),
          ..._payments.map((p) {
            final isSelected = _selectedPayment?['id'] == p['id'];
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: InkWell(
                onTap: () => setState(() => _selectedPayment = p),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF7c3aed).withOpacity(0.1) : Colors.white,
                    border: Border.all(
                      color: isSelected ? const Color(0xFF7c3aed) : Colors.grey.shade300,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(p['name']?.toString() ?? '',
                              style: const TextStyle(fontWeight: FontWeight.w900)),
                            if (p['account'] != null)
                              Text(p['account'].toString(),
                                style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                      ),
                      if (isSelected) const Icon(Icons.check_circle, color: Color(0xFF7c3aed)),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),

          const SizedBox(height: 20),

          // Submit
          ElevatedButton(
            onPressed: (_selectedProduct == null || _selectedPayment == null || _submitting)
                ? null
                : _submitOrder,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7c3aed),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: _submitting
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('Kirim Pesanan', style: TextStyle(fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }

  Future<void> _submitOrder() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Login dulu')));
      return;
    }

    setState(() => _submitting = true);

    try {
      final basePrice = (_selectedProduct!['price'] ?? 0) as num;
      final finalPrice = _getFinalPrice(_selectedProduct!);
      final orderId = 'YDS' + DateTime.now().millisecondsSinceEpoch.toRadixString(36).toUpperCase();

      final order = {
        'id': orderId,
        'userId': user.uid,
        'item': _game!['name'],
        'product': _selectedProduct!['name'],
        'price': finalPrice,
        'total': finalPrice,
        'userData': _userData,
        'payment': _selectedPayment!['name'],
        'status': 'pending',
        'date': DateTime.now().toIso8601String(),
        'createdAt': DateTime.now().toIso8601String(),
      };

      await FirebaseFirestore.instance.collection('orders').doc(orderId).set(order);

      // Notif Telegram
      try {
        await OrderTelegramService.notifyOrder(order);
      } catch (_) {}

      if (!mounted) return;

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('\u2705 Berhasil'),
          content: Text('Order $orderId berhasil dibuat. Total: Rp ${_fmt(finalPrice)}'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ' + e.toString())));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }
}
