import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import 'config/firebase_config.dart';
import 'services/auth_service.dart';
import 'services/firestore_service.dart';
import 'services/worker_service.dart';
import 'services/notification_service.dart';
import 'services/coin_sync_service.dart';
import 'services/maintenance_service.dart';
import 'services/anti_cheat.dart';
import 'services/fcm_service.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    debugPrint('[App] Firebase initialized');
  } catch (e) {
    debugPrint('[App] Firebase error: $e');
  }

  runApp(const GamingWorldApp());
}

class GamingWorldApp extends StatefulWidget {
  const GamingWorldApp({super.key});
  @override
  State<GamingWorldApp> createState() => _GamingWorldAppState();
}

class _GamingWorldAppState extends State<GamingWorldApp> {
  final _notifService = NotificationService();
  final _coinSync = CoinSyncService();
  final _maintenance = MaintenanceService();

  @override
  void initState() {
    super.initState();
    _notifService.init();
    _coinSync.start();
    _maintenance.startPeriodicCheck();
    _initSecurity();
  }

  Future<void> _initSecurity() async {
    try {
      final result = await AntiCheat.scan();
      debugPrint('[App] Security scan: $result');
      await FcmService.init();
    } catch (e) {
      debugPrint('[App] Security init error: $e');
  }

  @override
  void dispose() {
    _coinSync.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => FirestoreService()),
        ChangeNotifierProvider(create: (_) => WorkerService()),
        ChangeNotifierProvider.value(value: _maintenance),
      ],
      child: MaterialApp(
        title: 'Gaming World',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF7c3aed)),
          useMaterial3: true,
        ),
        initialRoute: '/',
        routes: {
          '/': (c) => const SplashScreen(),
          '/login': (c) => const LoginScreen(),
          '/home': (c) => const MaintenanceGate(child: HomeScreen()),
        },
      ),
    );
  }
}

class MaintenanceGate extends StatelessWidget {
  final Widget child;
  const MaintenanceGate({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final m = context.watch<MaintenanceService>();
    if (m.isMaintenance) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [Color(0xFF6366f1), Color(0xFFa855f7)]),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('\u{1F527}', style: TextStyle(fontSize: 80)),
                  const SizedBox(height: 16),
                  const Text('Maintenance',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white)),
                  const SizedBox(height: 12),
                  Text(m.message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 15, color: Colors.white70)),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () => context.read<MaintenanceService>().check(),
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
    return child;
  }
}
