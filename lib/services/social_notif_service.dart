import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class SocialNotifService {
  static final _random = Random();
  static Timer? _timer;
  static OverlayEntry? _currentEntry;

  static final _names = [
    'Ilham', 'Sari', 'Budi', 'Dewi', 'Andi', 'Rina', 'Rizki', 'Putri',
    'Ahmad', 'Fitri', 'Bayu', 'Maya', 'Dimas', 'Intan', 'Fajar', 'Lina',
    'Agus', 'Wulan', 'Bagas', 'Ayu', 'Eko', 'Nadia', 'Rudi', 'Sinta',
  ];

  static final _activities = [
    'baru dapat {n} koin',
    'baru tukar {item}',
    'streak {n} hari',
    'selesaikan misi, dapat {n} koin',
  ];

  static final _items = [
    '5 Diamond MLBB',
    '12 Diamond FF',
    '60 UC PUBG',
    '100 Genesis',
    'Pulsa 10.000',
  ];

  static void start(BuildContext context) {
    _timer?.cancel();
    _scheduleNext(context);
  }

  static void stop() {
    _timer?.cancel();
    _timer = null;
    _currentEntry?.remove();
    _currentEntry = null;
  }

  static void _scheduleNext(BuildContext context) {
    final delay = Duration(seconds: 15 + _random.nextInt(25));
    _timer = Timer(delay, () {
      if (context.mounted) {
        _showNotification(context);
        _scheduleNext(context);
      }
    });
  }

  static void _showNotification(BuildContext context) {
    final name = _names[_random.nextInt(_names.length)];
    final activity = _activities[_random.nextInt(_activities.length)];
    final koin = _random.nextInt(5000) + 100;
    final item = _items[_random.nextInt(_items.length)];

    final text = activity
        .replaceAll('{n}', koin.toString())
        .replaceAll('{item}', item);

    final overlay = Overlay.of(context);
    _currentEntry?.remove();

    _currentEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 70,
        left: 12,
        right: 12,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
              border: const Border(
                left: BorderSide(color: Color(0xFFa855f7), width: 4),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFFa855f7).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Text('\u{1F3C6}', style: TextStyle(fontSize: 18)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                          color: Color(0xFF1e1b4b),
                        ),
                      ),
                      Text(
                        text,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF4c4585),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    overlay.insert(_currentEntry!);

    Future.delayed(const Duration(seconds: 4), () {
      _currentEntry?.remove();
      _currentEntry = null;
    });
  }
}
