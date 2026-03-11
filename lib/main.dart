import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

// --- Tầng Data ---
import 'features/auth/data/datasources/auth_database_helper.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/cart/data/datasources/cart_database_helper.dart';
import 'features/cart/data/datasources/cart_local_datasource.dart';
import 'features/cart/domain/repositories/cart_repository_impl.dart';
import 'features/product/data/datasources/product_local_datasource.dart';
import 'features/product/data/datasources/product_remote_data_source.dart';
import 'features/product/data/repositories/product_repository_impl.dart';

// --- Tầng Domain ---
import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/cart/domain/usecases/add_to_cart_usecase.dart';
import 'features/product/domain/usecases/get_products_usecase.dart';
import 'features/product/domain/usecases/add_product_usecase.dart';
import 'features/product/domain/usecases/delete_product_usecase.dart';
import 'features/product/domain/usecases/get_remote_products_usecase.dart';
import 'features/product/domain/usecases/get_remote_categories_usecase.dart';

// --- Tầng Presentation ---
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/cart/presentation/bloc/cart_bloc.dart';
import 'features/product/presentation/bloc/product_bloc.dart';
import 'features/product/presentation/pages/product_list_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final authRepo = AuthRepositoryImpl(AuthDatabaseHelper.instance);
  final cartRepository = CartRepositoryImpl(CartLocalDataSourceImpl(CartDatabaseHelper.instance));
  final productLocalDataSource = ProductLocalDataSource();
  await productLocalDataSource.init();
  final productRemoteDataSource = ProductRemoteDataSourceImpl(client: http.Client());
  
  final productRepository = ProductRepositoryImpl(
    dataSource: productLocalDataSource,
    remoteDataSource: productRemoteDataSource,
  );

  runApp(
    MultiBlocProvider(
      providers: [
        // 1. TỰ ĐỘNG KIỂM TRA PHIÊN ĐĂNG NHẬP KHI MỞ APP
        BlocProvider(
          create: (_) => AuthBloc(LoginUseCase(authRepo), authRepo)..add(CheckAuthStatusEvent()),
        ),
        BlocProvider(
          create: (_) => CartBloc(AddToCartUseCase(), cartRepository)..add(LoadCartEvent()),
        ),
        BlocProvider(
          create: (_) => ProductBloc(
            getProducts: GetProductsUseCase(productRepository),
            addProduct: AddProductUseCase(productRepository),
            deleteProduct: DeleteProductUseCase(productRepository),
            getRemoteProducts: GetRemoteProductsUseCase(productRepository),
            getRemoteCategories: GetRemoteCategoriesUseCase(productRepository),
          )
          ..add(FetchRemoteCategoriesEvent()) 
          ..add(LoadProductsEvent()),
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
      home: const ProductListScreen(),
    );
  }
}
