import 'dart:io';
import 'package:flutter/foundation.dart';

class AntiCheat {
  static Future<Map<String, dynamic>> scan() async {
    final result = {
      'isRooted': false,
      'isEmulator': false,
      'isDebug': false,
      'isJailbroken': false,
      'suspiciousFiles': <String>[],
    };

    // Debug mode
    if (kDebugMode) {
      result['isDebug'] = true;
    }

    // Emulator detection (basic)
    if (Platform.isAndroid) {
      final emulatorIndicators = [
        '/dev/socket/qemud',
        '/dev/qemu_pipe',
        '/system/lib/libc_malloc_debug_qemu.so',
        '/sys/qemu_trace',
        '/system/bin/qemu-props',
      ];
      for (final path in emulatorIndicators) {
        try {
          if (File(path).existsSync()) {
            result['isEmulator'] = true;
            (result['suspiciousFiles'] as List).add(path);
          }
        } catch (_) {}
      }

      // Root detection
      final rootIndicators = [
        '/system/app/Superuser.apk',
        '/sbin/su',
        '/system/bin/su',
        '/system/xbin/su',
        '/data/local/xbin/su',
        '/data/local/bin/su',
        '/system/sd/xbin/su',
        '/system/bin/failsafe/su',
        '/data/local/su',
        '/su/bin/su',
      ];
      for (final path in rootIndicators) {
        try {
          if (File(path).existsSync()) {
            result['isRooted'] = true;
            (result['suspiciousFiles'] as List).add(path);
          }
        } catch (_) {}
      }
    }

    debugPrint('[AntiCheat] Scan result: $result');
    return result;
  }

  static Future<bool> isCompromised() async {
    final r = await scan();
    return r['isRooted'] == true || r['isEmulator'] == true;
  }
}
