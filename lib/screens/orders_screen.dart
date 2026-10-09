import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Pesanan'),
          backgroundColor: const Color(0xFF7c3aed),
          foregroundColor: Colors.white,
        ),
        body: const Center(child: Text('Login dulu')),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('📦 Pesanan Saya'),
        backgroundColor: const Color(0xFF7c3aed),
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
          .collection('orders')
          .where('userId', isEqualTo: user.uid)
          .snapshots(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snap.hasData || snap.data!.docs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('📦', style: TextStyle(fontSize: 60)),
                  SizedBox(height: 12),
                  Text('Belum ada pesanan', style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }
          
          final orders = snap.data!.docs.toList();
          orders.sort((a, b) {
            final aData = a.data() as Map<String, dynamic>;
            final bData = b.data() as Map<String, dynamic>;
            final aDate = aData['createdAt'] ?? aData['date'] ?? '';
            final bDate = bData['createdAt'] ?? bData['date'] ?? '';
            DateTime aDt, bDt;
            try {
              aDt = aDate is Timestamp
                  ? aDate.toDate()
                  : DateTime.parse(aDate.toString());
            } catch (_) {
              aDt = DateTime.fromMillisecondsSinceEpoch(0);
            }
            try {
              bDt = bDate is Timestamp
                  ? bDate.toDate()
                  : DateTime.parse(bDate.toString());
            } catch (_) {
              bDt = DateTime.fromMillisecondsSinceEpoch(0);
            }
            return bDt.compareTo(aDt);
          });
          
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, i) {
              final o = orders[i].data() as Map<String, dynamic>;
              final status = o['status'] ?? 'pending';
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(o['item'] ?? 'Game',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: _statusColor(status).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(status.toUpperCase(),
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _statusColor(status))),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('Order ID: ${o['id']}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                    const SizedBox(height: 4),
                    Text('Produk: ${o['product']}', style: const TextStyle(fontSize: 13)),
                    const SizedBox(height: 4),
                    Text('Total: Rp ${o['total']}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('Bayar: ${o['payment']}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
  
  Color _statusColor(String s) {
    if (s == 'success') return Colors.green;
    if (s == 'rejected') return Colors.red;
    if (s == 'processing') return Colors.orange;
    return Colors.blue;
  }
}
