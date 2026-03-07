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
class FetchRemoteCategoriesEvent extends ProductEvent {}
class FetchRemoteProductsEvent extends ProductEvent {
  final String category;
  FetchRemoteProductsEvent({required this.category});
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

  ProductBloc({
    required this.getProducts,
    required this.addProduct,
    required this.deleteProduct,
    required this.getRemoteProducts,
    required this.getRemoteCategories,
  }) : super(const ProductState()) {

    // 1. Tải danh mục từ API
    on<FetchRemoteCategoriesEvent>((event, emit) async {
      emit(state.copyWith(isLoading: true));
      try {
        final categories = await getRemoteCategories.execute();
        emit(state.copyWith(categories: categories, isLoading: false));
        // Sau khi có danh mục, tải món ăn của danh mục đầu tiên
        if (categories.isNotEmpty) {
          add(FetchRemoteProductsEvent(category: categories.first['name']!));
        }
      } catch (e) {
        emit(state.copyWith(isLoading: false));
      }
    });

    // 2. Tải món ăn theo danh mục từ API
    on<FetchRemoteProductsEvent>((event, emit) async {
      emit(state.copyWith(isLoading: true, selectedCategory: event.category));
      try {
        final products = await getRemoteProducts.execute(event.category);
        emit(state.copyWith(remoteProducts: List.from(products), isLoading: false));
      } catch (e) {
        emit(state.copyWith(isLoading: false));
      }
    });

    // 3. Tải món ăn từ SQLite (Admin thêm)
    on<LoadProductsEvent>((event, emit) async {
      final products = await getProducts();
      emit(state.copyWith(localProducts: List.from(products)));
    });

    on<AddProductEvent>((event, emit) async {
      emit(state.copyWith(isLoading: true));
      await addProduct(event.product);
      add(LoadProductsEvent());
      emit(state.copyWith(isLoading: false));
    });

    on<UpdateProductEvent>((event, emit) async {
      await addProduct(event.product);
      add(LoadProductsEvent());
    });

    on<DeleteProductEvent>((event, emit) async {
      await deleteProduct(event.id);
      add(LoadProductsEvent());
    });
  }
}
