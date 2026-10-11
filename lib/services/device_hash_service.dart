import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DeviceHashService {
  static String? _cachedHash;
  static Map<String, dynamic>? _cachedInfo;

  /// Ambil device hash — kombinasi Android ID + model + brand
  static Future<String> getDeviceHash() async {
    if (_cachedHash != null) return _cachedHash!;

    try {
      // Cek cache di shared_preferences
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString('device_hash');
      if (cached != null && cached.isNotEmpty) {
        _cachedHash = cached;
        return cached;
      }

      // Generate hash baru
      final hash = await _generateHash();
      await prefs.setString('device_hash', hash);
      _cachedHash = hash;
      return hash;
    } catch (e) {
      debugPrint('[DeviceHash] Error: $e');
      return 'unknown_${DateTime.now().millisecondsSinceEpoch}';
    }
  }

  static Future<String> _generateHash() async {
    final info = DeviceInfoPlugin();
    String raw = '';

    if (Platform.isAndroid) {
      final android = await info.androidInfo;
      _cachedInfo = {
        'platform': 'android',
        'brand': android.brand,
        'model': android.model,
        'device': android.device,
        'product': android.product,
        'androidId': android.id,
        'sdkInt': android.version.sdkInt,
      };
      raw = [
        android.brand,
        android.model,
        android.device,
        android.product,
        android.id,
      ].join('|');
    } else if (Platform.isIOS) {
      final ios = await info.iosInfo;
      _cachedInfo = {
        'platform': 'ios',
        'name': ios.name,
        'model': ios.model,
        'systemName': ios.systemName,
        'identifierForVendor': ios.identifierForVendor,
      };
      raw = [
        ios.name,
        ios.model,
        ios.systemName,
        ios.identifierForVendor ?? '',
      ].join('|');
    }

    // Hash dengan SHA256
    final bytes = utf8.encode(raw);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Ambil device info untuk dikirim ke worker
  static Future<Map<String, dynamic>> getDeviceInfo() async {
    if (_cachedInfo != null) return _cachedInfo!;
    await getDeviceHash(); // trigger load
    return _cachedInfo ?? {};
  }
}
