// features/product/presentation/bloc/product_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/usecases/get_products_usecase.dart';
import '../../domain/usecases/add_product_usecase.dart';

abstract class ProductEvent {}

class LoadProductsEvent extends ProductEvent {}

class AddProductEvent extends ProductEvent {
  final ProductEntity product;
  AddProductEvent(this.product);
}

class ProductState {
  final List<ProductEntity> products;
  const ProductState(this.products);
}

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final GetProductsUseCase getProducts;
  final AddProductUseCase addProduct;

  ProductBloc(this.getProducts, this.addProduct)
      : super(const ProductState([])) {
    on<LoadProductsEvent>((event, emit) async {
      final products = await getProducts();
      emit(ProductState(products));
    });

    on<AddProductEvent>((event, emit) async {
      await addProduct(event.product);
      final products = await getProducts();
      emit(ProductState(products));
    });
  }
}