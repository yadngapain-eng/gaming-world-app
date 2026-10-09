import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';

class ConfettiHelper {
  static void show(BuildContext context) {
    final controller = ConfettiController(duration: const Duration(seconds: 3));
    controller.play();

    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) => IgnorePointer(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: controller,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            numberOfParticles: 30,
            gravity: 0.3,
            emissionFrequency: 0.05,
            colors: const [
              Color(0xFF58cc02),
              Color(0xFF1cb0f6),
              Color(0xFFce82ff),
              Color(0xFFffc800),
              Color(0xFFff4081),
              Color(0xFF7c3aed),
            ],
          ),
        ),
      ),
    );

    overlay.insert(entry);

    Future.delayed(const Duration(seconds: 4), () {
      controller.dispose();
      entry.remove();
    });
  }

  static void showBig(BuildContext context) {
    final controller = ConfettiController(duration: const Duration(seconds: 5));
    controller.play();

    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) => IgnorePointer(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: controller,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: true,
            numberOfParticles: 50,
            gravity: 0.2,
            emissionFrequency: 0.03,
            colors: const [
              Color(0xFFfbbf24),
              Color(0xFFf59e0b),
              Color(0xFFef4444),
              Color(0xFFa855f7),
              Color(0xFF7c3aed),
              Color(0xFFec4899),
            ],
          ),
        ),
      ),
    );

    overlay.insert(entry);

    Future.delayed(const Duration(seconds: 6), () {
      controller.dispose();
      entry.remove();
    });
  }
}
