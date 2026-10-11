import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:open_filex/open_filex.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import '../config/app_config.dart';

class AppUpdateService {
  /// Cek versi terbaru dari server
  static Future<Map<String, dynamic>?> checkUpdate() async {
    try {
      final pkgInfo = await PackageInfo.fromPlatform();
      final currentVersion = pkgInfo.version;

      final res = await http.get(
        Uri.parse('${AppConfig.apiBase}/app/version'),
      ).timeout(const Duration(seconds: 15));

      if (res.statusCode != 200) return null;

      final data = jsonDecode(res.body);
      if (data['ok'] != true) return null;

      final latestVersion = data['latest_version']?.toString() ?? '1.0.0';

      // Bandingkan versi
      if (_compareVersions(latestVersion, currentVersion) > 0) {
        return {
          'current_version': currentVersion,
          'latest_version': latestVersion,
          'download_url': data['download_url']?.toString() ?? '',
          'changelog': data['changelog']?.toString() ?? '',
          'mandatory': data['mandatory'] == true,
          'file_size_mb': data['file_size_mb'] ?? 0,
        };
      }

      return null; // sudah versi terbaru
    } catch (e) {
      debugPrint('[Update] Check error: $e');
      return null;
    }
  }

  /// Bandingkan versi (semver-like)
  /// Return >0 kalau a > b
  static int _compareVersions(String a, String b) {
    final aParts = a.split('.').map((s) => int.tryParse(s) ?? 0).toList();
    final bParts = b.split('.').map((s) => int.tryParse(s) ?? 0).toList();
    final maxLen = aParts.length > bParts.length ? aParts.length : bParts.length;

    for (var i = 0; i < maxLen; i++) {
      final av = i < aParts.length ? aParts[i] : 0;
      final bv = i < bParts.length ? bParts[i] : 0;
      if (av != bv) return av - bv;
    }
    return 0;
  }

  /// Download APK dengan progress
  static Future<String?> downloadApk(
    String url, {
    Function(double progress)? onProgress,
  }) async {
    try {
      final dir = await getExternalStorageDirectory() ??
          await getApplicationDocumentsDirectory();
      final filePath = '${dir.path}/gaming_world_update.apk';

      // Hapus file lama kalau ada
      final oldFile = File(filePath);
      if (await oldFile.exists()) {
        await oldFile.delete();
      }

      final dio = Dio();
      await dio.download(
        url,
        filePath,
        onReceiveProgress: (received, total) {
          if (total > 0 && onProgress != null) {
            onProgress(received / total);
          }
        },
        options: Options(
          followRedirects: true,
          validateStatus: (status) => status != null && status < 400,
        ),
      );

      debugPrint('[Update] Downloaded: $filePath');
      return filePath;
    } catch (e) {
      debugPrint('[Update] Download error: $e');
      return null;
    }
  }

  /// Install APK
  static Future<bool> installApk(String filePath) async {
    try {
      final result = await OpenFilex.open(filePath);
      return result.type == ResultType.done;
    } catch (e) {
      debugPrint('[Update] Install error: $e');
      return false;
    }
  }
}
