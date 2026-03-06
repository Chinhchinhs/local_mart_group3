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
import 'features/product/presentation/pages/product_list_screen.dart';


void main() async {
  // 1. Đảm bảo Flutter đã sẵn sàng để gọi các dịch vụ Native (như SQLite)
  WidgetsFlutterBinding.ensureInitialized();

  // --- KHỞI TẠO SQLITE CHO GIỎ HÀNG ---
  // 2. Gọi file cấu hình DB
  final cartDbHelper = CartDatabaseHelper.instance;
  // 3. Giao DB cho anh Thợ đào vàng
  final cartDataSource = CartLocalDataSourceImpl(cartDbHelper);
  // 4. Giao anh Thợ đào vàng cho Quản lý kho
  final cartRepository = CartRepositoryImpl(cartDataSource);

  // --- KHỞI TẠO PHẦN SẢN PHẨM ---

  final productDataSource = ProductLocalDataSource();
  await productDataSource.init();
  final productRepository = ProductRepositoryImpl(productDataSource);

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          // 5. Truyền Repository vào Bloc VÀ gọi luôn sự kiện tải giỏ hàng cũ (LoadCartEvent)
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
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ProductListScreen(),
    );
  }
}