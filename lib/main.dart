import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// --- Import phần Cart (Giỏ hàng) ---
import 'features/cart/data/datasources/cart_database_helper.dart';
import 'features/cart/data/datasources/cart_local_datasource.dart';
import 'features/cart/domain/repositories/cart_repository_impl.dart';
import 'features/cart/domain/usecases/add_to_cart_usecase.dart';
import 'features/cart/presentation/bloc/cart_bloc.dart';

// --- Import phần Product (Sản phẩm) ---
import 'features/product/data/datasources/product_local_datasource.dart';
import 'features/product/data/repositories/product_repository_impl.dart';
import 'features/product/domain/usecases/get_products_usecase.dart';
import 'features/product/domain/usecases/add_product_usecase.dart';
import 'features/product/domain/usecases/delete_product_usecase.dart';
import 'features/product/presentation/bloc/product_bloc.dart';

// --- Import trang chính ---
import 'features/product/presentation/pages/product_list_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // --- KHỞI TẠO SQLITE CHO GIỎ HÀNG ---
  final cartDbHelper = CartDatabaseHelper.instance;
  final cartDataSource = CartLocalDataSourceImpl(cartDbHelper);
  final cartRepository = CartRepositoryImpl(cartDataSource);

  // --- KHỞI TẠO PHẦN SẢN PHẨM ---
  final productDataSource = ProductLocalDataSource();
  await productDataSource.init();
  final productRepository = ProductRepositoryImpl(productDataSource);

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => CartBloc(AddToCartUseCase(), cartRepository)..add(LoadCartEvent()),
        ),
        BlocProvider(
          create: (_) => ProductBloc(
            GetProductsUseCase(productRepository),
            AddProductUseCase(productRepository),
            DeleteProductUseCase(productRepository),
          )..add(LoadProductsEvent()),
        ),
      ],
      child: const LocalMartApp(),
    ),
  );
}

class LocalMartApp extends StatelessWidget {
  const LocalMartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LocalMart Food',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.orange,
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      // Đổi lại trang chính khi vào app là ProductListScreen
      home: const ProductListScreen(),
    );
  }
}
