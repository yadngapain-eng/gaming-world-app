import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'config/firebase_config.dart';
import 'services/auth_service.dart';
import 'services/firestore_service.dart';
import 'services/worker_service.dart';
import 'services/notification_service.dart';
import 'services/coin_sync_service.dart';
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
  
  @override
  void initState() {
    super.initState();
    _notifService.init();
    _coinSync.start();
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
          '/home': (c) => const HomeScreen(),
        },
      ),
    );
  }
}
