import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/game_model.dart';
import '../models/payment_model.dart';
import '../services/order_telegram_service.dart';

class TopupScreen extends StatefulWidget {
  final Game game;
  const TopupScreen({super.key, required this.game});
  
  @override
  State<TopupScreen> createState() => _TopupScreenState();
}

class _TopupScreenState extends State<TopupScreen> {
  int _step = 0; // 0: form, 1: payment, 2: upload proof, 3: success
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};
  Map<String, dynamic>? _selectedProduct;
  PaymentMethod? _selectedPayment;
  File? _proofImage;
  String? _orderId;
  bool _loading = false;
  String _error = '';
  
  @override
  void initState() {
    super.initState();
    // Init form fields dari game
    final fields = widget.game.toMap()['fields'] ?? [];
    for (var f in (fields as List)) {
      _controllers[f['id']] = TextEditingController();
    }
    if (_controllers.isEmpty) {
      _controllers['user_id'] = TextEditingController();
    }
  }
  
  @override
  void dispose() {
    for (var c in _controllers.values) c.dispose();
    super.dispose();
  }
  
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (picked != null) {
      setState(() => _proofImage = File(picked.path));
    }
  }
  
  Future<void> _submitOrder() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedProduct == null || _selectedPayment == null) {
      setState(() => _error = 'Pilih produk dan pembayaran dulu');
      return;
    }
    if (_proofImage == null) {
      setState(() => _error = 'Upload bukti transfer dulu');
      return;
    }
    
    setState(() { _loading = true; _error = ''; });
    
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User belum login');
      
      final orderId = 'YDS' + DateTime.now().millisecondsSinceEpoch.toRadixString(36).toUpperCase();
      final userData = <String, dynamic>{};
      _controllers.forEach((k, c) => userData[k] = c.text.trim());
      
      // Convert image to base64
      final bytes = await _proofImage!.readAsBytes();
      final base64Image = base64Encode(bytes);
      
      final order = {
        'id': orderId,
        'userId': user.uid,
        'item': widget.game.name,
        'product': _selectedProduct!['name'],
        'price': _selectedProduct!['price'],
        'total': _selectedProduct!['price'] + (_selectedPayment!.fee),
        'userData': userData,
        'payment': _selectedPayment!.name,
        'paymentId': _selectedPayment!.id,
        'status': 'pending',
        'proof': base64Image,
        'date': DateTime.now().toIso8601String(),
      };
      
      // Save to Firestore
      await FirebaseFirestore.instance.collection('orders').doc(orderId).set(order);
      
      // Send to Worker for Telegram notif
      try {
        await http.post(
          Uri.parse('${AppConfig.apiBase}/order'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(order),
        ).timeout(const Duration(seconds: 15));
      } catch (e) {
        debugPrint('[TopUp] Worker notify error: $e');
      }
      
      setState(() {
        _orderId = orderId;
        _step = 3;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
        _loading = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.game.icon} ${widget.game.name}'),
        backgroundColor: const Color(0xFF7c3aed),
        foregroundColor: Colors.white,
      ),
      body: _step == 3 ? _successView() : _formView(),
    );
  }
  
  Widget _successView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🎉', style: TextStyle(fontSize: 80)),
            const SizedBox(height: 16),
            const Text('Pesanan Dikirim!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            Text('Order ID: $_orderId',
              style: const TextStyle(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 24),
            const Text('Admin akan verifikasi pembayaran kamu. Cek pesanan di tab Pesanan.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Selesai'),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _formView() {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('config').doc('payments').get(),
      builder: (context, snap) {
        // Parse payments
        final payments = <PaymentMethod>[];
        if (snap.hasData && snap.data!.exists) {
          final data = snap.data!.data() as Map<String, dynamic>;
          final methods = data['methods'] as List? ?? [];
          for (var m in methods) {
            if (m['active'] != false) {
              payments.add(PaymentMethod.fromMap(Map<String, dynamic>.from(m)));
            }
          }
        }
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Text(widget.game.icon, style: const TextStyle(fontSize: 40)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.game.name,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                            const SizedBox(height: 4),
                            Text(widget.game.description,
                              style: const TextStyle(color: Colors.grey, fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                
                // Form fields
                const Text('Data Akun', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                const SizedBox(height: 12),
                ..._controllers.entries.map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: TextFormField(
                    controller: e.value,
                    decoration: InputDecoration(
                      labelText: e.key.replaceAll('_', ' ').toUpperCase(),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
                  ),
                )),
                const SizedBox(height: 20),
                
                // Pilih produk
                const Text('Pilih Nominal', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                const SizedBox(height: 12),
                _productPicker(),
                const SizedBox(height: 20),
                
                // Pilih payment
                const Text('Pilih Pembayaran', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                const SizedBox(height: 12),
                payments.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : _paymentPicker(payments),
                const SizedBox(height: 20),
                
                
                // ===== BAYAR DENGAN KOIN =====
                if (_selectedProduct != null && _selectedPayment != null) ...[
                  const SizedBox(height: 20),
                  const Text('Atau Bayar dengan Koin',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                  const SizedBox(height: 8),
                  _koinButton(),
                  const SizedBox(height: 16),
                  const Center(child: Text('--- ATAU ---',
                    style: TextStyle(color: Colors.grey, fontSize: 12))),
                ],
                
                // Upload bukti
                if (_selectedPayment != null) ...[
                  const Text('Upload Bukti Transfer', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                  const SizedBox(height: 12),
                  _proofPicker(),
                ],
                
                if (_error.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(_error, style: const TextStyle(color: Colors.red)),
                  ),
                
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _submitOrder,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7c3aed),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _loading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Kirim Pesanan', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  

  Widget _koinButton() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const SizedBox.shrink();
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
      builder: (context, snap) {
        final balance = ((snap.data?.data() as Map?)?['balance'] ?? 0) as num;
        final hargaFinal = (_selectedProduct!['price'] as num) + (_selectedPayment?.fee ?? 0);
        final koinDibutuhkan = hargaFinal;
        final bisa = balance >= koinDibutuhkan;
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFFfef3c7), Color(0xFFfde68a)]),
            border: Border.all(color: const Color(0xFFf59e0b), width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Saldo Koin', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF78350f))),
                      Text(balance.toString(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF92400e))),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('Butuh', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF78350f))),
                      Text(koinDibutuhkan.toString(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF92400e))),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: !bisa ? null : () => _payWithKoin(koinDibutuhkan),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: bisa ? const Color(0xFFf59e0b) : const Color(0xFF94a3b8),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(
                    bisa ? ('Bayar ' + koinDibutuhkan.toString() + ' Koin') : ('Koin Kurang ' + (koinDibutuhkan - balance).toString()),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                bisa ? 'Tanpa upload bukti transfer' : 'Kumpulkan koin lagi',
                style: const TextStyle(fontSize: 11, color: Color(0xFF78350f)),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _payWithKoin(num koinDibutuhkan) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    setState(() { _loading = true; _error = ''; });
    try {
      final orderId = 'YDS' + DateTime.now().millisecondsSinceEpoch.toRadixString(36).toUpperCase();
      final userData = <String, dynamic>{};
      _controllers.forEach((k, c) => userData[k] = c.text.trim());

      await FirebaseFirestore.instance.runTransaction((tx) async {
        final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
        final userDoc = await tx.get(userRef);
        final currentBalance = ((userDoc.data()?['balance'] ?? 0) as num);
        if (currentBalance < koinDibutuhkan) {
          throw Exception('Saldo tidak cukup');
        }
        tx.update(userRef, {
          'balance': currentBalance - koinDibutuhkan,
          'totalSpent': (((userDoc.data()?['totalSpent'] ?? 0) as num) + koinDibutuhkan),
          'updatedAt': DateTime.now().toIso8601String(),
        });
        tx.set(FirebaseFirestore.instance.collection('orders').doc(orderId), {
          'id': orderId,
          'userId': user.uid,
          'item': widget.game.name,
          'itemIcon': widget.game.icon,
          'product': _selectedProduct!['name'],
          'price': _selectedProduct!['price'],
          'total': koinDibutuhkan,
          'userData': userData,
          'payment': 'Koin',
          'paymentMethod': 'koin',
          'koinDipakai': koinDibutuhkan,
          'status': 'success',
          'paidWithCoins': true,
          'date': DateTime.now().toIso8601String(),
        });
      });

      try {
        await OrderTelegramService.notifyOrder({
          'id': orderId,
          'userId': user.uid,
          'item': widget.game.name,
          'product': _selectedProduct!['name'],
          'total': koinDibutuhkan,
          'payment': 'Koin',
          'koinDipakai': koinDibutuhkan,
          'userData': userData,
          'status': 'success',
        });
      } catch (_) {}

      if (!mounted) return;
      setState(() {
        _orderId = orderId;
        _step = 3;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Gagal bayar koin: ' + e.toString();
        _loading = false;
      });
    }
  }

  Widget _productPicker() {
    // Dummy products — nanti bisa dari Firestore
    final products = [
      {'id': 'p1', 'name': '10 Diamond', 'price': 3000},
      {'id': 'p2', 'name': '20 Diamond', 'price': 6000},
      {'id': 'p3', 'name': '50 Diamond', 'price': 15000},
      {'id': 'p4', 'name': '100 Diamond', 'price': 30000},
    ];
    
    return Wrap(
      spacing: 8, runSpacing: 8,
      children: products.map((p) {
        final selected = _selectedProduct?['id'] == p['id'];
        return GestureDetector(
          onTap: () => setState(() => _selectedProduct = p),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: selected ? const Color(0xFF7c3aed) : Colors.white,
              border: Border.all(color: selected ? const Color(0xFF7c3aed) : Colors.grey.shade300, width: 2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(p['name'].toString(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: selected ? Colors.white : Colors.black,
                  )),
                const SizedBox(height: 4),
                Text('Rp ${p['price']}',
                  style: TextStyle(
                    fontSize: 12,
                    color: selected ? Colors.white70 : Colors.grey,
                  )),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
  
  Widget _paymentPicker(List<PaymentMethod> payments) {
    return Column(
      children: payments.map((p) {
        final selected = _selectedPayment?.id == p.id;
        return GestureDetector(
          onTap: () => setState(() => _selectedPayment = p),
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: selected ? const Color(0xFF7c3aed).withOpacity(0.1) : Colors.white,
              border: Border.all(color: selected ? const Color(0xFF7c3aed) : Colors.grey.shade300, width: 2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(p.account, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),
                if (selected) const Icon(Icons.check_circle, color: Color(0xFF7c3aed)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
  
  Widget _proofPicker() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade300, width: 2, style: BorderStyle.solid),
          borderRadius: BorderRadius.circular(12),
        ),
        child: _proofImage != null
          ? Column(
              children: [
                Image.file(_proofImage!, height: 150),
                const SizedBox(height: 8),
                TextButton(onPressed: _pickImage, child: const Text('Ganti Gambar')),
              ],
            )
          : const Column(
              children: [
                Icon(Icons.cloud_upload, size: 48, color: Colors.grey),
                SizedBox(height: 8),
                Text('Tap untuk upload bukti', style: TextStyle(color: Colors.grey)),
              ],
            ),
      ),
    );
  }
}
