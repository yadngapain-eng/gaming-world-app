import 'package:flutter/material.dart';
import '../screens/chat_screen.dart';

class FloatingChatButton extends StatelessWidget {
  const FloatingChatButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 20,
      right: 16,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ChatScreen()),
            );
          },
          borderRadius: BorderRadius.circular(30),
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF229ED9), Color(0xFF0088cc)],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF229ED9).withOpacity(0.5),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.chat_bubble,
              color: Colors.white,
              size: 26,
            ),
          ),
        ),
      ),
    );
  }
}
