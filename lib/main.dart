import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'features/cart/domain/usecases/add_to_cart_usecase.dart';
import 'features/cart/presentation/bloc/cart_bloc.dart';
import 'features/cart/presentation/cart_screen.dart';

void main() {
  runApp(const LocalMartApp());
}

class LocalMartApp extends StatelessWidget {
  const LocalMartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Local Mart',
      debugShowCheckedModeBanner: false,
      // Dùng BlocProvider để cung cấp CartBloc cho toàn bộ ứng dụng
      home: BlocProvider(
        create: (context) => CartBloc(AddToCartUseCase()),
        child: const CartScreen(),
      ),
    );
  }
}