import 'package:flutter/material.dart';
import '../services/topup_service.dart';

class TopupListScreen extends StatefulWidget {
  const TopupListScreen({super.key});
  @override
  State<TopupListScreen> createState() => _TopupListScreenState();
}

class _TopupListScreenState extends State<TopupListScreen> {
  String _selectedCategory = 'Semua';
  String _searchQuery = '';

  final List<String> _categories = [
    'Semua', 'MOBA', 'Battle Royale', 'Gacha/RPG', 'Shooter', 'Populer', 'Voucher'
  ];

  List<Map<String, dynamic>> _filtered() {
    var games = TopupService.getGames();
    if (_selectedCategory != 'Semua') {
      games = games.where((g) => g['category'] == _selectedCategory).toList();
    }
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      games = games.where((g) =>
        g['name'].toString().toLowerCase().contains(q) ||
        g['id'].toString().toLowerCase().contains(q)
      ).toList();
    }
    return games;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('\u{1F6D2} Top Up Game'),
        backgroundColor: const Color(0xFF7c3aed),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Search
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: 'Cari game...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),

          // Category chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: _categories.map((c) {
                final selected = _selectedCategory == c;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(c),
                    selected: selected,
                    onSelected: (_) => setState(() => _selectedCategory = c),
                    selectedColor: const Color(0xFF7c3aed),
                    labelStyle: TextStyle(
                      color: selected ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                    backgroundColor: Colors.grey.shade100,
                  ),
                );
              }).toList(),
            ),
          ),

          // Grid game
          Expanded(
            child: _filtered().isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 60, color: Colors.grey),
                        SizedBox(height: 12),
                        Text('Game tidak ditemukan', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(12),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: _filtered().length,
                    itemBuilder: (context, i) {
                      return _gameCard(_filtered()[i]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _gameCard(Map<String, dynamic> game) {
    final iconUrl = TopupService.iconUrl(game['icon_file'] as String);
    return InkWell(
      onTap: () => _openTopup(game),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  iconUrl,
                  width: 56,
                  height: 56,
                  fit: BoxFit.contain,
                  errorBuilder: (context, err, stack) => Center(
                    child: Text(
                      game['name'].toString().substring(0, 1),
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey),
                    ),
                  ),
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return const Center(child: SizedBox(
                      width: 20, height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ));
                  },
                ),
              ),
            ),
            const SizedBox(height: 6),
            Flexible(
              child: Text(
                game['name'] as String,
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 10),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openTopup(Map<String, dynamic> game) {
    // Nanti integrasi dengan TopupScreen yang sudah ada
    // Untuk sekarang, tampilkan info dialog
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(game['name'] as String),
        content: Text('Top up ${game['name']}. Halaman produk akan dibuka.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Tutup')),
        ],
      ),
    );
  }
}
