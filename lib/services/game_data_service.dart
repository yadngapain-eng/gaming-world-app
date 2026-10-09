import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GameDataService {
  static Map<String, dynamic> _metadata = {};
  static Map<String, num> _prices = {};
  static num _globalMarkup = 0;
  static Map<String, num> _gameMarkups = {};
  static bool _loaded = false;
  static final _listeners = <VoidCallback>[];

  // ============================================
  //  GETTERS
  // ============================================
  static bool get isLoaded => _loaded;
  static Map<String, dynamic> get gameMetadata => _metadata;
  static Map<String, dynamic> get allGames => _metadata;
  static Map<String, num> get prices => _prices;
  static num get globalMarkup => _globalMarkup;

  // ============================================
  //  LISTENERS
  // ============================================
  static void addListener(VoidCallback cb) => _listeners.add(cb);
  static void removeListener(VoidCallback cb) => _listeners.remove(cb);
  static void _notify() { for (var cb in _listeners) cb(); }

  // ============================================
  //  LOAD
  // ============================================
  static Future<void> load() async {
    try {
      final db = FirebaseFirestore.instance;

      // 1. Load metadata (games + produk)
      final metaDoc = await db.collection('config').doc('game_metadata').get();
      if (metaDoc.exists) {
        final data = metaDoc.data() ?? {};
        final games = data['games'] as Map? ?? {};
        _metadata = Map<String, dynamic>.from(games);
        debugPrint('[GameData] Metadata: ' + _metadata.length.toString() + ' games');
      }

      // 2. Load prices
      final pricesDoc = await db.collection('config').doc('prices').get();
      if (pricesDoc.exists) {
        _prices = Map<String, num>.from(
          (pricesDoc.data() ?? {}).map((k, v) => MapEntry(k.toString(), (v ?? 0) as num))
        );
        debugPrint('[GameData] Prices: ' + _prices.length.toString() + ' products');
      }

      // 3. Load markup
      final markupDoc = await db.collection('config').doc('markup').get();
      if (markupDoc.exists) {
        final d = markupDoc.data() ?? {};
        _globalMarkup = (d['global_markup'] ?? 0) as num;
        if (d['game_markups'] != null) {
          _gameMarkups = Map<String, num>.from(
            (d['game_markups'] as Map).map((k, v) => MapEntry(k.toString(), (v ?? 0) as num))
          );
        }
        debugPrint('[GameData] Markup: +' + _globalMarkup.toString());
      }

      _loaded = true;
      _notify();
    } catch (e) {
      debugPrint('[GameData] Error: ' + e.toString());
    }
  }

  // ============================================
  //  GET GAMES (untuk TopupListScreen)
  // ============================================
  static List<Map<String, dynamic>> getGames() {
    final list = <Map<String, dynamic>>[];
    _metadata.forEach((gid, g) {
      if (g is Map) {
        final m = Map<String, dynamic>.from(g);
        m['id'] = gid;
        list.add(m);
      }
    });
    return list;
  }

  // ============================================
  //  GET PRODUCTS (dengan harga final markup)
  // ============================================
  static List<Map<String, dynamic>> getProducts(String gameId) {
    if (!_metadata.containsKey(gameId)) return [];
    final g = _metadata[gameId];
    if (g is! Map) return [];
    final products = (g['products'] ?? []) as List;
    return products.map((p) {
      final m = Map<String, dynamic>.from(p);
      final basePrice = (m['price'] ?? 0) as num;
      m['basePrice'] = basePrice;
      m['finalPrice'] = getFinalPrice(gameId, m['id']?.toString() ?? '', basePrice);
      return m;
    }).toList();
  }

  // ============================================
  //  HARGA FINAL = harga dasar + markup
  //  (Harga di Firestore sudah final, tidak perlu tambah markup lagi)
  // ============================================
  static num getFinalPrice(String gameId, String productId, num basePrice) {
    // Kalau ada harga di Firestore, pakai itu langsung
    // (Karena Firestore sudah final dari website)
    if (_prices.containsKey(productId)) {
      return _prices[productId]!;
    }
    // Fallback: harga dasar + markup
    final gameMarkup = _gameMarkups[gameId] ?? 0;
    return basePrice + _globalMarkup + gameMarkup;
  }

  // ============================================
  //  HELPER
  // ============================================
  static String getGameName(String gameId) {
    if (!_metadata.containsKey(gameId)) return 'Game';
    return _metadata[gameId]['name']?.toString() ?? 'Game';
  }

  static String getGameIcon(String gameId) {
    if (!_metadata.containsKey(gameId)) return '';
    return _metadata[gameId]['icon']?.toString() ?? '';
  }

  static Map<String, dynamic>? getGame(String gameId) {
    if (!_metadata.containsKey(gameId)) return null;
    final g = _metadata[gameId];
    if (g is! Map) return null;
    return Map<String, dynamic>.from(g);
  }
}
