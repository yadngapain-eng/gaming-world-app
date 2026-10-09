import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;
  bool _showEmailForm = false;
  String _error = '';

  @override
  void initState() {
    super.initState();
    // Guard: kalau sudah login (bukan anonymous), langsung ke home
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && !user.isAnonymous && mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    });
  }

  Future<void> _loginAnonymous() async {
    setState(() { _loading = true; _error = ''; });
    final ok = await context.read<AuthService>().loginAnonymous();
    setState(() => _loading = false);
    if (!mounted) return;
    if (ok) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      setState(() => _error = 'Gagal login anonymous');
    }
  }

  Future<void> _loginGoogle() async {
    setState(() { _loading = true; _error = ''; });
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(scopes: ['email']);
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        setState(() { _loading = false; });
        return;
      }
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home');
    } on FirebaseAuthException catch (e) {
      String msg = 'Google login gagal';
      if (e.code == 'account-exists-with-different-credential') {
        msg = 'Email sudah terdaftar dengan password';
      }
      setState(() { _error = msg; _loading = false; });
    } catch (e) {
      String msg = 'Google login gagal';
      if (e.toString().contains('ApiException: 10')) {
        msg = 'Google Sign-In belum dikonfigurasi. Hubungi admin.';
      } else if (e.toString().contains('sign_in_failed')) {
        msg = 'Google Sign-In belum dikonfigurasi. Hubungi admin.';
      }
      setState(() { _error = msg; _loading = false; });
    }
  }

  Future<void> _loginEmail() async {
    if (_emailCtrl.text.isEmpty || _passCtrl.text.isEmpty) {
      setState(() => _error = 'Email & password wajib diisi');
      return;
    }
    setState(() { _loading = true; _error = ''; });
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
      );
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home');
    } on FirebaseAuthException catch (e) {
      String msg = 'Login gagal';
      if (e.code == 'user-not-found') msg = 'Email tidak terdaftar';
      else if (e.code == 'wrong-password') msg = 'Password salah';
      else if (e.code == 'invalid-email') msg = 'Email tidak valid';
      setState(() { _error = msg; _loading = false; });
    } catch (e) {
      setState(() { _error = 'Error: $e'; _loading = false; });
    }
  }

  Future<void> _registerEmail() async {
    if (_emailCtrl.text.isEmpty || _passCtrl.text.isEmpty) {
      setState(() => _error = 'Email & password wajib diisi');
      return;
    }
    if (_passCtrl.text.length < 6) {
      setState(() => _error = 'Password minimal 6 karakter');
      return;
    }
    setState(() { _loading = true; _error = ''; });
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
      );
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home');
    } on FirebaseAuthException catch (e) {
      String msg = 'Pendaftaran gagal';
      if (e.code == 'email-already-in-use') msg = 'Email sudah terdaftar';
      else if (e.code == 'weak-password') msg = 'Password terlalu lemah';
      setState(() { _error = msg; _loading = false; });
    } catch (e) {
      setState(() { _error = 'Error: $e'; _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [Color(0xFF6366f1), Color(0xFFa855f7)]),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('GW',
                    style: TextStyle(fontSize: 72, fontWeight: FontWeight.w900, color: Colors.white)),
                  const SizedBox(height: 8),
                  const Text('Gaming World',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white)),
                  const SizedBox(height: 4),
                  const Text('Kumpulkan koin, tukar hadiah',
                    style: TextStyle(fontSize: 13, color: Colors.white70)),
                  const SizedBox(height: 40),

                  if (!_showEmailForm) ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _loading ? null : _loginGoogle,
                        icon: const Icon(Icons.g_mobiledata, size: 28),
                        label: const Text('Lanjutkan dengan Google',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF1f2937),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => setState(() => _showEmailForm = true),
                        icon: const Icon(Icons.email_outlined, color: Colors.white),
                        label: const Text('Login Email/Password',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.white70),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: _loading ? null : _loginAnonymous,
                        child: const Text('Masuk sebagai Guest',
                          style: TextStyle(color: Colors.white70, fontSize: 14)),
                      ),
                    ),
                  ] else ...[
                    TextField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Email',
                        hintStyle: const TextStyle(color: Colors.white54),
                        prefixIcon: const Icon(Icons.email, color: Colors.white70),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.15),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _passCtrl,
                      obscureText: true,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Password',
                        hintStyle: const TextStyle(color: Colors.white54),
                        prefixIcon: const Icon(Icons.lock, color: Colors.white70),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.15),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _loading ? null : _loginEmail,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF7c3aed),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: _loading
                              ? const SizedBox(height: 20, width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2))
                              : const Text('Masuk', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _loading ? null : _registerEmail,
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.white70),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: const Text('Daftar',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => setState(() => _showEmailForm = false),
                      child: const Text('Kembali',
                        style: TextStyle(color: Colors.white70)),
                    ),
                  ],

                  if (_error.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Text(_error,
                        style: const TextStyle(color: Colors.yellow, fontSize: 13),
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
