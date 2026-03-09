import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/usecases/get_products_usecase.dart';
import '../../domain/usecases/add_product_usecase.dart';
import '../../domain/usecases/delete_product_usecase.dart';
import '../../domain/usecases/get_remote_products_usecase.dart';
import '../../domain/usecases/get_remote_categories_usecase.dart';
import 'product_state.dart';

abstract class ProductEvent {}

class LoadProductsEvent extends ProductEvent {}

class ChangeCategoryEvent extends ProductEvent {
  final String category;
  ChangeCategoryEvent(this.category);
}

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
  final GetRemoteProductsUseCase getRemoteProducts;
  final GetRemoteCategoriesUseCase getRemoteCategories;

  ProductBloc(
    this.getProducts, 
    this.addProduct, 
    this.deleteProduct,
    this.getRemoteProducts,
    this.getRemoteCategories,
  ) : super(const ProductState()) {

    on<LoadProductsEvent>((event, emit) async {
      emit(state.copyWith(isLoading: true));
      try {
        // 1. Lấy danh mục từ API nếu chưa có
        List<Map<String, String>> categories = state.categories;
        if (categories.isEmpty) {
          categories = await getRemoteCategories.execute();
        }

        // 2. Lấy sản phẩm Local (SQLite)
        final localProducts = await getProducts();

        // 3. Lấy sản phẩm Remote (API) theo danh mục hiện tại
        final remoteProducts = await getRemoteProducts.execute(state.selectedCategory);

        emit(state.copyWith(
          localProducts: List.from(localProducts),
          remoteProducts: List.from(remoteProducts),
          categories: categories,
          isLoading: false,
        ));
      } catch (e) {
        emit(state.copyWith(isLoading: false));
      }
    });

    on<ChangeCategoryEvent>((event, emit) async {
      emit(state.copyWith(isLoading: true, selectedCategory: event.category));
      try {
        final remoteProducts = await getRemoteProducts.execute(event.category);
        emit(state.copyWith(remoteProducts: List.from(remoteProducts), isLoading: false));
      } catch (e) {
        emit(state.copyWith(isLoading: false));
      }
    });

    on<AddProductEvent>((event, emit) async {
      emit(state.copyWith(isLoading: true));
      try {
        await addProduct(event.product);
        final newLocal = await getProducts();
        emit(state.copyWith(localProducts: List.from(newLocal), isLoading: false));
      } catch (e) {
        emit(state.copyWith(isLoading: false));
      }
    });

    on<UpdateProductEvent>((event, emit) async {
      emit(state.copyWith(isLoading: true));
      try {
        await addProduct(event.product);
        final newLocal = await getProducts();
        emit(state.copyWith(localProducts: List.from(newLocal), isLoading: false));
      } catch (e) {
        emit(state.copyWith(isLoading: false));
      }
    });

    on<DeleteProductEvent>((event, emit) async {
      emit(state.copyWith(isLoading: true));
      try {
        await deleteProduct(event.id);
        final newLocal = await getProducts();
        emit(state.copyWith(localProducts: List.from(newLocal), isLoading: false));
      } catch (e) {
        emit(state.copyWith(isLoading: false));
      }
    });
  }
}
