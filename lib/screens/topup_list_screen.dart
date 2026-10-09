import 'package:flutter/material.dart';
import '../services/game_data_service.dart';
import 'topup_screen.dart';

class TopupListScreen extends StatefulWidget {
  const TopupListScreen({super.key});
  @override
  State<TopupListScreen> createState() => _TopupListScreenState();
}

class _TopupListScreenState extends State<TopupListScreen> {
  String _selectedCategory = 'Semua';
  String _searchQuery = '';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // Kalau sudah loaded, tidak perlu fetch lagi
    if (GameDataService.isLoaded) {
      setState(() => _loading = false);
      return;
    }
    await GameDataService.load();
    if (mounted) setState(() => _loading = false);
  }

  List<String> get _categories {
    final cats = <String>{'Semua'};
    for (final g in GameDataService.getGames()) {
      final c = g['category']?.toString() ?? '';
      if (c.isNotEmpty) cats.add(c);
    }
    return cats.toList();
  }

  List<Map<String, dynamic>> _filtered() {
    var games = GameDataService.getGames();
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
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
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
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: _categories.length,
                    itemBuilder: (context, i) {
                      final c = _categories[i];
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
                    },
                  ),
                ),
                const SizedBox(height: 8),
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
    final iconPath = game['icon']?.toString() ?? '';
    final iconUrl = iconPath.isEmpty
        ? ''
        : (iconPath.startsWith('http') ? iconPath : 'https://duniamu.my.id$iconPath');

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
                child: iconUrl.isEmpty
                    ? Center(child: Text(game['name'].toString().substring(0, 1)))
                    : Image.network(
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
                          return const Center(
                            child: SizedBox(
                              width: 20, height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          );
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
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => TopupScreen(gameId: game['id'] as String)),
    );
  }
}
