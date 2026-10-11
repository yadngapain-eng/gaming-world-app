import 'package:flutter/material.dart';
import '../services/in_app_notification_service.dart';

class NotificationPanel extends StatefulWidget {
  const NotificationPanel({super.key});

  @override
  State<NotificationPanel> createState() => _NotificationPanelState();
}

class _NotificationPanelState extends State<NotificationPanel> {
  List<AppNotification> _notifs = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await NotificationService.refresh();
    if (!mounted) return;
    setState(() {
      _notifs = NotificationService.cached;
      _loading = false;
    });
  }

  Color _typeColor(String t) {
    switch (t) {
      case 'promo': return const Color(0xFFf59e0b);
      case 'update': return const Color(0xFF10b981);
      case 'warning': return const Color(0xFFef4444);
      default: return const Color(0xFF3b82f6);
    }
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m lalu';
    if (diff.inHours < 24) return '${diff.inHours}j lalu';
    if (diff.inDays < 30) return '${diff.inDays}h lalu';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🔔 Notifikasi'),
        backgroundColor: const Color(0xFF7c3aed),
        foregroundColor: Colors.white,
        actions: [
          if (_notifs.any((n) => !n.read))
            TextButton.icon(
              onPressed: () async {
                final ids = _notifs.where((n) => !n.read).map((n) => n.id).toList();
                await NotificationService.markAsRead(ids);
                _load();
              },
              icon: const Icon(Icons.done_all, color: Colors.white, size: 18),
              label: const Text('Tandai dibaca',
                  style: TextStyle(color: Colors.white, fontSize: 12)),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _notifs.isEmpty
              ? _empty()
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _notifs.length,
                    itemBuilder: (context, i) {
                      final n = _notifs[i];
                      final color = _typeColor(n.type);
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: n.read ? Colors.white : color.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border(
                            left: BorderSide(color: color, width: 4),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: InkWell(
                          onTap: () async {
                            if (!n.read) {
                              await NotificationService.markAsRead([n.id]);
                              _load();
                            }
                            // Kalau ada action URL, bisa dibuka di sini
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: color.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                    child: Text(n.icon,
                                        style: const TextStyle(fontSize: 20)),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              n.title,
                                              style: TextStyle(
                                                fontWeight: n.read
                                                    ? FontWeight.w700
                                                    : FontWeight.w900,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                          if (!n.read)
                                            Container(
                                              width: 8,
                                              height: 8,
                                              decoration: BoxDecoration(
                                                color: color,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        n.message,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.black54,
                                          height: 1.4,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        _timeAgo(n.publishedAt),
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  Widget _empty() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('🔕', style: TextStyle(fontSize: 60)),
          SizedBox(height: 12),
          Text('Belum ada notifikasi',
              style: TextStyle(color: Colors.grey, fontSize: 14)),
        ],
      ),
    );
  }
}
