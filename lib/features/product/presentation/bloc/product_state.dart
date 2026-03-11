import 'package:equatable/equatable.dart';
import '../../domain/entities/product_entity.dart';

class ProductState extends Equatable {
  final List<ProductEntity> localProducts;
  final List<ProductEntity> remoteProducts;
  final List<ProductEntity> bestSellerProducts; 
  final List<Map<String, String>> categories; 
  final String selectedCategory;
  final bool isLoading;

  const ProductState({
    this.localProducts = const [],
    this.remoteProducts = const [],
    this.bestSellerProducts = const [],
    this.categories = const [],
    this.selectedCategory = "Best Seller", 
    this.isLoading = false,
  });

  // CHỈ TRẢ VỀ REMOTE PRODUCTS ĐỂ HIỂN THỊ TRONG GRID DƯỚI (API)
  List<ProductEntity> get currentDisplayProducts => remoteProducts;

  ProductState copyWith({
    List<ProductEntity>? localProducts,
    List<ProductEntity>? remoteProducts,
    List<ProductEntity>? bestSellerProducts,
    List<Map<String, String>>? categories,
    String? selectedCategory,
    bool? isLoading,
  }) {
    return ProductState(
      localProducts: localProducts ?? this.localProducts,
      remoteProducts: remoteProducts ?? this.remoteProducts,
      bestSellerProducts: bestSellerProducts ?? this.bestSellerProducts,
      categories: categories ?? this.categories,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [localProducts, remoteProducts, bestSellerProducts, categories, selectedCategory, isLoading];
}
