import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

class GameDataService {
  // Data game + produk dari Firestore
  static Map<String, dynamic> _gameMetadata = {};
  static Map<String, num> _prices = {};
  static num _globalMarkup = 0;
  static Map<String, num> _gameMarkups = {};
  static bool _loaded = false;

  static bool get isLoaded => _loaded;
  static Map<String, dynamic> get gameMetadata => _gameMetadata;
  static Map<String, num> get prices => _prices;

  static Future<void> load() async {
    try {
      final db = FirebaseFirestore.instance;

      // 1. Load config/game_metadata
      final metaDoc = await db.collection('config').doc('game_metadata').get();
      if (metaDoc.exists) {
        _gameMetadata = Map<String, dynamic>.from(metaDoc.data()?['games'] ?? {});
        debugPrint('[GameData] Metadata loaded: ' + _gameMetadata.length.toString() + ' games');
      }

      // 2. Load config/prices
      final pricesDoc = await db.collection('config').doc('prices').get();
      if (pricesDoc.exists) {
        _prices = Map<String, num>.from(
          (pricesDoc.data() ?? {}).map((k, v) => MapEntry(k.toString(), (v ?? 0) as num))
        );
        debugPrint('[GameData] Prices loaded: ' + _prices.length.toString() + ' products');
      }

      // 3. Load config/markup
      final markupDoc = await db.collection('config').doc('markup').get();
      if (markupDoc.exists) {
        final data = markupDoc.data() ?? {};
        _globalMarkup = (data['global_markup'] ?? 0) as num;
        if (data['game_markups'] != null) {
          _gameMarkups = Map<String, num>.from(
            (data['game_markups'] as Map).map((k, v) => MapEntry(k.toString(), (v ?? 0) as num))
          );
        }
        debugPrint('[GameData] Markup: ' + _globalMarkup.toString());
      }

      _loaded = true;
    } catch (e) {
      debugPrint('[GameData] Error: ' + e.toString());
    }
  }

  // Harga final untuk ditampilkan ke user
  // = harga dasar + global markup + game markup
  // ATAU custom price kalau ada
  static num getFinalPrice(String gameId, String productId, num basePrice) {
    // 1. Cek custom price (override)
    final key = productId;
    if (_prices.containsKey(key)) {
      final customPrice = _prices[key]!;
      // Kalau custom price = base price, artinya ini base price
      // Tetap tambah markup
      if (customPrice == basePrice) {
        return basePrice + _globalMarkup + (_gameMarkups[gameId] ?? 0);
      }
      // Kalau custom price berbeda dari base, berarti harga sudah final
      return customPrice;
    }
    // 2. Harga dasar + markup
    return basePrice + _globalMarkup + (_gameMarkups[gameId] ?? 0);
  }

  // Ambil produk untuk game tertentu
  static List<Map<String, dynamic>> getProducts(String gameId) {
    if (!_gameMetadata.containsKey(gameId)) return [];
    final g = _gameMetadata[gameId];
    final products = (g['products'] ?? []) as List;
    return products.map((p) {
      final m = Map<String, dynamic>.from(p);
      // Hitung harga final
      final basePrice = (m['price'] ?? 0) as num;
      m['finalPrice'] = getFinalPrice(gameId, m['id'] ?? '', basePrice);
      return m;
    }).toList();
  }

  // Ambil nama game
  static String getGameName(String gameId) {
    if (!_gameMetadata.containsKey(gameId)) return 'Game';
    return _gameMetadata[gameId]['name'] ?? 'Game';
  }
}
