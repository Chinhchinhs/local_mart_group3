import 'package:equatable/equatable.dart';
import '../../domain/entities/product_entity.dart';

class ProductState extends Equatable {
  final List<ProductEntity> localProducts; // Món ăn Admin thêm (SQLite)
  final List<ProductEntity> remoteProducts; // Món ăn từ API (TheMealDB)
  final List<Map<String, String>> categories; // Danh mục từ API
  final String selectedCategory; // Danh mục đang chọn
  final bool isLoading;

  const ProductState({
    this.localProducts = const [],
    this.remoteProducts = const [],
    this.categories = const [],
    this.selectedCategory = "Beef", // Mặc định chọn Beef
    this.isLoading = false,
  });

  // Getter tổng hợp để dùng cho các màn hình cũ không bị lỗi build
  List<ProductEntity> get products => [...localProducts, ...remoteProducts];

  ProductState copyWith({
    List<ProductEntity>? localProducts,
    List<ProductEntity>? remoteProducts,
    List<Map<String, String>>? categories,
    String? selectedCategory,
    bool? isLoading,
  }) {
    return ProductState(
      localProducts: localProducts ?? this.localProducts,
      remoteProducts: remoteProducts ?? this.remoteProducts,
      categories: categories ?? this.categories,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [localProducts, remoteProducts, categories, selectedCategory, isLoading];
}
