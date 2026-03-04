import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/usecases/get_products_usecase.dart';
import '../../domain/usecases/add_product_usecase.dart';
import '../../domain/usecases/delete_product_usecase.dart';
import 'product_state.dart';

abstract class ProductEvent {}

class LoadProductsEvent extends ProductEvent {}

class AddProductEvent extends ProductEvent {
  final ProductEntity product;
  AddProductEvent(this.product);
}

class DeleteProductEvent extends ProductEvent {
  final String id;
  DeleteProductEvent(this.id);
}

/// ================= BLOC =================

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final GetProductsUseCase getProducts;
  final AddProductUseCase addProduct;
  final DeleteProductUseCase deleteProduct;

  ProductBloc(
      this.getProducts,
      this.addProduct,
      this.deleteProduct,
      ) : super(const ProductState(products: [])) {

    /// LOAD PRODUCTS
    on<LoadProductsEvent>((event, emit) async {
      emit(state.copyWith(isLoading: true));

      final products = await getProducts();

      emit(ProductState(
        products: products,
        isLoading: false,
      ));
    });

    /// ADD PRODUCT
    on<AddProductEvent>((event, emit) async {
      print("ADDING PRODUCT: ${event.product.name}");

      await addProduct(event.product);

      print("ADD DONE");

      add(LoadProductsEvent());
    });

    /// DELETE PRODUCT
    on<DeleteProductEvent>((event, emit) async {
      await deleteProduct(event.id);

      // Reload lại danh sách
      add(LoadProductsEvent());
    });
  }
}