import 'package:flutter/material.dart';
import 'features/cart/presentation/cart_screen.dart'; // Import màn hình giỏ hàng của bạn vào

void main() {
  // Điểm bắt đầu của toàn bộ ứng dụng
  runApp(const LocalMartApp());
}

class LocalMartApp extends StatelessWidget {
  const LocalMartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Local Mart',
      debugShowCheckedModeBanner: false, // Tắt cái chữ "DEBUG" góc phải màn hình cho đỡ vướng
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      // Tạm thời cài đặt trang chủ là màn hình Giỏ hàng để bạn dễ làm việc
      home: const CartScreen(),
    );
  }
}