import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/product_repository.dart';
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

class ToggleOutOfStockEvent extends ProductEvent {
  final String productId;
  ToggleOutOfStockEvent(this.productId);
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
        final bestSellers = await _repository.getBestSellers();
        final categoriesFromApi = await getRemoteCategories.execute();
        
        // ĐẢM BẢO KEY 'name' VÀ 'image' LUÔN CHÍNH XÁC
        final updatedCategories = _buildCategoriesWithBestSeller(bestSellers, categoriesFromApi);
        
        emit(state.copyWith(
          bestSellerProducts: bestSellers,
          categories: updatedCategories,
          isLoading: false
        ));
        
        add(FetchRemoteProductsEvent(category: state.selectedCategory));
      } catch (e) {
        emit(state.copyWith(isLoading: false));
      }
    });

    on<FetchRemoteProductsEvent>((event, emit) async {
      emit(state.copyWith(isLoading: true, selectedCategory: event.category));
      
      final outOfStockIds = await _repository.getOutOfStockIds();
      final localProducts = await getProducts();

      if (event.category == 'Best Seller') {
        final products = state.bestSellerProducts.map((p) {
          return p.copyWith(isOutOfStock: outOfStockIds.contains(p.id));
        }).toList();
        emit(state.copyWith(remoteProducts: products, isLoading: false, localProducts: localProducts));
      } else {
        try {
          final apiProducts = await getRemoteProducts.execute(event.category);
          final updatedProducts = apiProducts.map((p) {
            return p.copyWith(isOutOfStock: outOfStockIds.contains(p.id));
          }).toList();
          
          emit(state.copyWith(remoteProducts: updatedProducts, isLoading: false, localProducts: localProducts));
        } catch (e) {
          emit(state.copyWith(isLoading: false));
        }
      }
    });

    on<ToggleOutOfStockEvent>((event, emit) async {
      await _repository.toggleOutOfStock(event.productId);
      final outOfStockIds = await _repository.getOutOfStockIds();
      
      final updatedRemote = state.remoteProducts.map((p) {
        if (p.id == event.productId) return p.copyWith(isOutOfStock: outOfStockIds.contains(p.id));
        return p;
      }).toList();

      final updatedLocal = state.localProducts.map((p) {
        if (p.id == event.productId) return p.copyWith(isOutOfStock: outOfStockIds.contains(p.id));
        return p;
      }).toList();

      final updatedBestSellers = state.bestSellerProducts.map((p) {
        if (p.id == event.productId) return p.copyWith(isOutOfStock: outOfStockIds.contains(p.id));
        return p;
      }).toList();

      emit(state.copyWith(
        remoteProducts: updatedRemote,
        localProducts: updatedLocal,
        bestSellerProducts: updatedBestSellers,
      ));
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
      final outOfStockIds = await _repository.getOutOfStockIds();
      
      final updatedProducts = products.map((p) {
        return p.copyWith(isOutOfStock: outOfStockIds.contains(p.id));
      }).toList();

      emit(state.copyWith(localProducts: updatedProducts));
    });

    on<AddProductEvent>((event, emit) async {
      await addProduct(event.product);
      add(FetchRemoteProductsEvent(category: state.selectedCategory));
    });

    on<DeleteProductEvent>((event, emit) async {
      await deleteProduct(event.id);
      add(FetchRemoteProductsEvent(category: state.selectedCategory));
    });
  }

  List<Map<String, String>> _buildCategoriesWithBestSeller(List<ProductEntity> bestSellers, List<Map<String, String>> apiCategories) {
    // FIX LỖI ẢNH VÀ CHỮ BEST SELLER
    final String bestSellerImg = bestSellers.isNotEmpty 
        ? bestSellers.first.imageUrl 
        : 'https://images.unsplash.com/photo-1543353071-087092ec393a?q=80&w=1000&auto=format&fit=crop';

    return [
      {'name': 'Best Seller', 'image': bestSellerImg},
      ...apiCategories,
    ];
  }
}
