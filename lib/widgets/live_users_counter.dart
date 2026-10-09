import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class LiveUsersCounter extends StatefulWidget {
  const LiveUsersCounter({super.key});

  @override
  State<LiveUsersCounter> createState() => _LiveUsersCounterState();
}

class _LiveUsersCounterState extends State<LiveUsersCounter> {
  final _random = Random();
  int _count = 250;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _count = 200 + _random.nextInt(800);
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;
      setState(() {
        _count += _random.nextInt(40) - 20;
        if (_count < 150) _count = 150;
        if (_count > 1500) _count = 1500;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF10b981).withOpacity(0.12),
        border: Border.all(color: const Color(0xFF10b981).withOpacity(0.3)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: const BoxDecoration(
              color: Color(0xFF10b981),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            _count.toString(),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: Color(0xFF059669),
            ),
          ),
        ],
      ),
    );
  }
}
