import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// --- Tầng Data (Repository Implementation) ---
import 'features/auth/data/datasources/auth_database_helper.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/cart/data/datasources/cart_database_helper.dart';
import 'features/cart/data/datasources/cart_local_datasource.dart';
import 'features/cart/domain/repositories/cart_repository_impl.dart';
import 'features/product/data/datasources/product_local_datasource.dart';
import 'features/product/data/repositories/product_repository_impl.dart';

// --- Tầng Domain (UseCases) ---
import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/cart/domain/usecases/add_to_cart_usecase.dart';
import 'features/product/domain/usecases/get_products_usecase.dart';
import 'features/product/domain/usecases/add_product_usecase.dart';
import 'features/product/domain/usecases/delete_product_usecase.dart';

// --- Tầng Presentation (Bloc & UI) ---
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/pages/login_screen.dart';
import 'features/cart/presentation/bloc/cart_bloc.dart';
import 'features/product/presentation/bloc/product_bloc.dart';
import 'features/product/presentation/pages/product_list_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Khởi tạo Database & Repository cho Auth
  final authRepo = AuthRepositoryImpl(AuthDatabaseHelper.instance);
  
  // 2. Khởi tạo Database & Repository cho Cart
  final cartRepository = CartRepositoryImpl(CartLocalDataSourceImpl(CartDatabaseHelper.instance));

  // 3. Khởi tạo Database & Repository cho Product
  final productDataSource = ProductLocalDataSource();
  await productDataSource.init();
  final productRepository = ProductRepositoryImpl(productDataSource);

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => AuthBloc(LoginUseCase(authRepo), authRepo),
        ),
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
      // Mặc định vào App là trang chủ (ProductList), nếu cần login thì bấm icon Profile
      home: const ProductListScreen(),
    );
  }
}
