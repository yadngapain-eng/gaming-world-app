import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'minigame_list_screen.dart';
import 'topup_list_screen.dart';
import 'orders_screen.dart';
import 'profile_screen.dart';
import '../widgets/floating_chat_button.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});
  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _index = 0;

  final List<Widget> _pages = const [
    HomeScreen(),
    MinigameListScreen(),
    TopupListScreen(),
    OrdersScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(index: _index, children: _pages),
          const FloatingChatButton(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFF7c3aed).withOpacity(0.15),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: Color(0xFF7c3aed)),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.videogame_asset_outlined),
            selectedIcon: Icon(Icons.videogame_asset, color: Color(0xFF7c3aed)),
            label: 'Mini Game',
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_cart_outlined),
            selectedIcon: Icon(Icons.shopping_cart, color: Color(0xFF7c3aed)),
            label: 'Top Up',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long, color: Color(0xFF7c3aed)),
            label: 'Pesanan',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person, color: Color(0xFF7c3aed)),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
