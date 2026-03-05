import 'package:flutter/material.dart';
import '../../data/datasources/auth_database_helper.dart';
import '../../data/repositories/auth_repository_impl.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final userCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final authRepo = AuthRepositoryImpl(AuthDatabaseHelper.instance);

  void _login() async {
    // Logic đăng nhập đơn giản cho Admin
    if (userCtrl.text == "admin" && passCtrl.text == "admin123") {
      Navigator.pop(context, {'isAdmin': true});
      return;
    }

    // Đăng nhập User thường từ Database
    final user = await authRepo.login(userCtrl.text, passCtrl.text);
    if (user != null) {
      if (!mounted) return;
      Navigator.pop(context, {'isAdmin': false, 'username': user.username});
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Sai tài khoản hoặc mật khẩu")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white, elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.fastfood, size: 80, color: Colors.orange),
            const SizedBox(height: 16),
            const Text("LocalMart", textAlign: TextAlign.center, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 40),
            TextField(
              controller: userCtrl,
              decoration: InputDecoration(
                labelText: "Tên đăng nhập",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passCtrl,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Mật khẩu",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _login,
              child: const Text("ĐĂNG NHẬP", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            TextButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
              child: const Text("Đăng ký tài khoản mới"),
            ),
          ],
        ),
      ),
    );
  }
}
