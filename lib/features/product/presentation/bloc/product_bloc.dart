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

class UpdateProductEvent extends ProductEvent {
  final ProductEntity product;
  UpdateProductEvent(this.product);
}

class DeleteProductEvent extends ProductEvent {
  final String id;
  DeleteProductEvent(this.id);
}

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final GetProductsUseCase getProducts;
  final AddProductUseCase addProduct;
  final DeleteProductUseCase deleteProduct;

  ProductBloc(this.getProducts, this.addProduct, this.deleteProduct) 
      : super(const ProductState()) {

    on<LoadProductsEvent>((event, emit) async {
      emit(state.copyWith(isLoading: true));
      try {
        final products = await getProducts();
        emit(state.copyWith(localProducts: List.from(products), isLoading: false));
      } catch (e) {
        emit(state.copyWith(isLoading: false));
      }
    });

    on<AddProductEvent>((event, emit) async {
      emit(state.copyWith(isLoading: true));
      try {
        await addProduct(event.product);
        final newProducts = await getProducts();
        emit(state.copyWith(localProducts: List.from(newProducts), isLoading: false));
      } catch (e) {
        emit(state.copyWith(isLoading: false));
      }
    });

    on<UpdateProductEvent>((event, emit) async {
      emit(state.copyWith(isLoading: true));
      try {
        await addProduct(event.product); // Replace trong SQLite
        final newProducts = await getProducts();
        emit(state.copyWith(localProducts: List.from(newProducts), isLoading: false));
      } catch (e) {
        emit(state.copyWith(isLoading: false));
      }
    });

    on<DeleteProductEvent>((event, emit) async {
      emit(state.copyWith(isLoading: true));
      try {
        await deleteProduct(event.id);
        final newProducts = await getProducts();
        emit(state.copyWith(localProducts: List.from(newProducts), isLoading: false));
      } catch (e) {
        emit(state.copyWith(isLoading: false));
      }
    });
  }
}
