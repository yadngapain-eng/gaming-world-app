import 'package:flutter/material.dart';

class MaterialIconHelper {
  /// Convert icon code string → IconData
  static IconData getIcon(String? code, {IconData fallback = Icons.notifications}) {
    if (code == null || code.isEmpty) return fallback;

    final map = <String, IconData>{
      // Notification icons
      'celebration': Icons.celebration,
      'info': Icons.info,
      'promo': Icons.card_giftcard,
      'update': Icons.system_update,
      'warning': Icons.warning,
      'notifications': Icons.notifications,
      'star': Icons.star,
      'campaign': Icons.campaign,

      // Achievement icons
      'military_tech': Icons.military_tech,
      'workspace_premium': Icons.workspace_premium,
      'emoji_events': Icons.emoji_events,
      'verified': Icons.verified,
      'diamond': Icons.diamond,
      'local_fire_department': Icons.local_fire_department,
      'sports_esports': Icons.sports_esports,
    };

    if (map.containsKey(code)) return map[code]!;

    final lower = code.toLowerCase();
    if (map.containsKey(lower)) return map[lower]!;

    return fallback;
  }

  /// Warna berdasarkan tipe notifikasi
  static Color getColor(String? type) {
    switch (type) {
      case 'promo':   return const Color(0xFFf59e0b);
      case 'update':  return const Color(0xFF10b981);
      case 'warning': return const Color(0xFFef4444);
      default:        return const Color(0xFF3b82f6);
    }
  }
}
