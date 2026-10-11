import 'package:flutter/material.dart';
import '../services/app_update_service.dart';

class UpdateDialog extends StatefulWidget {
  final Map<String, dynamic> updateInfo;
  final VoidCallback? onSkip;

  const UpdateDialog({
    super.key,
    required this.updateInfo,
    this.onSkip,
  });

  @override
  State<UpdateDialog> createState() => _UpdateDialogState();
}

class _UpdateDialogState extends State<UpdateDialog> {
  bool _downloading = false;
  double _progress = 0;
  String _status = '';

  Future<void> _startDownload() async {
    setState(() {
      _downloading = true;
      _progress = 0;
      _status = 'Mendownload...';
    });

    final url = widget.updateInfo['download_url']?.toString() ?? '';
    if (url.isEmpty) {
      setState(() {
        _status = 'URL download tidak valid';
        _downloading = false;
      });
      return;
    }

    final path = await AppUpdateService.downloadApk(
      url,
      onProgress: (p) {
        setState(() => _progress = p);
      },
    );

    if (path == null) {
      setState(() {
        _status = 'Gagal download. Coba lagi.';
        _downloading = false;
      });
      return;
    }

    setState(() {
      _status = 'Menginstall...';
      _progress = 1.0;
    });

    final ok = await AppUpdateService.installApk(path);

    if (!ok) {
      setState(() {
        _status = 'Gagal install. Buka manual dari file manager.';
        _downloading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final latest = widget.updateInfo['latest_version'] ?? '?';
    final current = widget.updateInfo['current_version'] ?? '?';
    final changelog = widget.updateInfo['changelog'] ?? '';
    final mandatory = widget.updateInfo['mandatory'] == true;
    final sizeMb = widget.updateInfo['file_size_mb'] ?? 0;

    return PopScope(
      canPop: !mandatory,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(20),
          constraints: const BoxConstraints(maxHeight: 600),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 50, height: 50,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF3b82f6), Color(0xFF7c3aed)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.system_update,
                          color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            mandatory ? 'Update Wajib' : 'Update Tersedia',
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 18,
                            ),
                          ),
                          if (mandatory)
                            Container(
                              margin: const EdgeInsets.only(top: 4),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'WAJIB UPDATE',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Version info
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Versi saat ini',
                                style: TextStyle(fontSize: 10, color: Colors.grey)),
                            Text(current,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w900, fontSize: 14)),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward, color: Colors.grey),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Versi baru',
                                style: TextStyle(fontSize: 10, color: Colors.grey)),
                            Text(latest,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 14,
                                    color: Color(0xFF10b981))),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Changelog
                if (changelog.isNotEmpty) ...[
                  const Text('Yang Baru',
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      changelog,
                      style: const TextStyle(fontSize: 12, height: 1.5),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // Size
                if (sizeMb > 0)
                  Text('Ukuran file: ~$sizeMb MB',
                      style: const TextStyle(fontSize: 11, color: Colors.grey)),

                // Progress
                if (_downloading) ...[
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: _progress,
                    minHeight: 6,
                    backgroundColor: Colors.grey.shade300,
                    valueColor: const AlwaysStoppedAnimation(Color(0xFF7c3aed)),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _status + (_progress > 0 && _progress < 1
                        ? ' ${(_progress * 100).toStringAsFixed(0)}%'
                        : ''),
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ] else if (_status.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(_status,
                      style: const TextStyle(fontSize: 12, color: Colors.red)),
                ],

                const SizedBox(height: 16),

                // Buttons
                Row(
                  children: [
                    if (!mandatory)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _downloading
                              ? null
                              : () {
                                  Navigator.pop(context);
                                  widget.onSkip?.call();
                                },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            side: BorderSide(color: Colors.grey.shade300),
                          ),
                          child: const Text('Nanti'),
                        ),
                      ),
                    if (!mandatory) const SizedBox(width: 10),
                    Expanded(
                      flex: mandatory ? 1 : 1,
                      child: ElevatedButton(
                        onPressed: _downloading ? null : _startDownload,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF7c3aed),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: _downloading
                            ? const SizedBox(
                                width: 20, height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2,
                                ),
                              )
                            : const Text('Update Sekarang',
                                style: TextStyle(fontWeight: FontWeight.w900)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
