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
  // Đảm bảo các ràng buộc của Flutter được khởi tạo trước khi thực hiện các tác vụ async
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Khởi tạo Auth (Phần của thành viên khác)
  final authRepo = AuthRepositoryImpl(AuthDatabaseHelper.instance);
  
  // 2. Khởi tạo Cart (Phần của thành viên khác)
  final cartRepository = CartRepositoryImpl(CartLocalDataSourceImpl(CartDatabaseHelper.instance));

  // 3. Khởi tạo Product (Phần của thành viên khác)
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
        // Quản lý trạng thái xác thực
        BlocProvider(
          create: (_) => AuthBloc(LoginUseCase(authRepo), authRepo),
        ),
        // Quản lý trạng thái giỏ hàng
        BlocProvider(
          create: (_) => CartBloc(AddToCartUseCase(), cartRepository)..add(LoadCartEvent()),
        ),
        // Quản lý trạng thái sản phẩm
        BlocProvider(
          create: (_) => ProductBloc(
            getProducts: GetProductsUseCase(productRepository),
            addProduct: AddProductUseCase(productRepository),
            deleteProduct: DeleteProductUseCase(productRepository),
            getRemoteProducts: GetRemoteProductsUseCase(productRepository),
            getRemoteCategories: GetRemoteCategoriesUseCase(productRepository),
          )
          ..add(FetchRemoteCategoriesEvent()) // Lấy danh mục & Món ăn từ API
          ..add(LoadProductsEvent()),        // Lấy món ăn từ Local
        ),
      ],
      child: const LocalMartApp(),
    ),
  );
}

/// LocalMartApp là điểm bắt đầu của ứng dụng, cấu hình Theme và Router
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
        fontFamily: 'Roboto', // Sử dụng font chữ đồng bộ cho toàn app
      ),
      home: const ProductListScreen(), // Màn hình mặc định khi mở app
    );
  }
}
