import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/product_repository.dart'; // Thêm import này
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

class ToggleBestSellerEvent extends ProductEvent {
  final ProductEntity product;
  ToggleBestSellerEvent(this.product);
}

class AddProductEvent extends ProductEvent {
  final ProductEntity product;
  AddProductEvent(this.product);
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

  // Lấy repository từ một trong các usecase
  ProductRepository get _repository => getProducts.repository;

  ProductBloc({
    required this.getProducts,
    required this.addProduct,
    required this.deleteProduct,
    required this.getRemoteProducts,
    required this.getRemoteCategories,
  }) : super(const ProductState()) {

    on<FetchRemoteCategoriesEvent>((event, emit) async {
      try {
        // Nạp Best Sellers từ Database trước khi load Category
        final bestSellers = await _repository.getBestSellers();
        
        final categoriesFromApi = await getRemoteCategories.execute();
        final updatedCategories = _buildCategoriesWithBestSeller(bestSellers, categoriesFromApi);
        
        emit(state.copyWith(
          bestSellerProducts: bestSellers,
          categories: updatedCategories,
          isLoading: false
        ));
        
        // Load món ăn cho danh mục hiện tại (thường là Best Seller khi mới mở)
        add(FetchRemoteProductsEvent(category: state.selectedCategory));
      } catch (e) {
        emit(state.copyWith(isLoading: false));
      }
    });

    on<FetchRemoteProductsEvent>((event, emit) async {
      emit(state.copyWith(isLoading: true, selectedCategory: event.category));
      
      if (event.category == 'Best Seller') {
        if (state.bestSellerProducts.isEmpty) {
          final products = await getRemoteProducts.execute('Beef');
          emit(state.copyWith(remoteProducts: List.from(products), isLoading: false));
        } else {
          emit(state.copyWith(remoteProducts: List.from(state.bestSellerProducts), isLoading: false));
        }
      } else {
        try {
          final products = await getRemoteProducts.execute(event.category);
          emit(state.copyWith(remoteProducts: List.from(products), isLoading: false));
        } catch (e) {
          emit(state.copyWith(isLoading: false));
        }
      }
    });

    on<ToggleBestSellerEvent>((event, emit) async {
      final List<ProductEntity> currentList = List.from(state.bestSellerProducts);
      final index = currentList.indexWhere((p) => p.id == event.product.id);
      
      bool isAdding = index < 0;
      if (isAdding) {
        currentList.add(event.product);
      } else {
        currentList.removeAt(index);
      }
      
      // LƯU VÀO DATABASE VĨNH VIỄN
      await _repository.toggleBestSeller(event.product, isAdding);

      final apiCategoriesOnly = state.categories.where((c) => c['name'] != 'Best Seller').toList();
      final updatedCategories = _buildCategoriesWithBestSeller(currentList, apiCategoriesOnly);
      
      emit(state.copyWith(
        bestSellerProducts: currentList,
        categories: updatedCategories,
      ));

      if (state.selectedCategory == 'Best Seller') {
        emit(state.copyWith(remoteProducts: currentList));
      }
    });

    on<LoadProductsEvent>((event, emit) async {
      final products = await getProducts();
      emit(state.copyWith(localProducts: List.from(products)));
    });

    on<AddProductEvent>((event, emit) async {
      await addProduct(event.product);
      add(LoadProductsEvent());
    });

    on<DeleteProductEvent>((event, emit) async {
      await deleteProduct(event.id);
      add(LoadProductsEvent());
    });
  }

  List<Map<String, String>> _buildCategoriesWithBestSeller(List<ProductEntity> bestSellers, List<Map<String, String>> apiCategories) {
    final String bestSellerImg = bestSellers.isNotEmpty 
        ? bestSellers.first.imageUrl 
        : 'https://images.unsplash.com/photo-1543353071-087092ec393a?q=80&w=1000&auto=format&fit=crop';

    return [
      {'name': 'Best Seller', 'image': bestSellerImg},
      ...apiCategories,
    ];
  }
}
