import 'package:flutter/material.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Giỏ hàng LocalMart'),
        backgroundColor: Colors.blue,
      ),
      body: const Center(
        child: Text(
          'Chỗ này mốt sẽ chứa các món hàng của Chinh nè!',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}