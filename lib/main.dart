import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'features/cart/domain/usecases/add_to_cart_usecase.dart';
import 'features/cart/presentation/bloc/cart_bloc.dart';
import 'features/cart/presentation/cart_screen.dart';
import 'features/product/data/datasources/product_local_datasource.dart';
import 'features/product/data/repositories/product_repository_impl.dart';
import 'features/product/domain/usecases/get_products_usecase.dart';
import 'features/product/domain/usecases/add_product_usecase.dart';
import 'features/product/presentation/bloc/product_bloc.dart';
import 'features/product/presentation/pages/product_list_screen.dart';
import 'features/product/domain/usecases/delete_product_usecase.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final productDataSource = ProductLocalDataSource();
  await productDataSource.init();

  final productRepository = ProductRepositoryImpl(productDataSource);

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => CartBloc(AddToCartUseCase()),
        ),
        BlocProvider(
          create: (_) => ProductBloc(
            GetProductsUseCase(productRepository),
            AddProductUseCase(productRepository),
            DeleteProductUseCase(productRepository),
          ),
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