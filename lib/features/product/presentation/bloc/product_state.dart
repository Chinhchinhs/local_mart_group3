import '../../domain/entities/product_entity.dart';

class ProductState {
  final List<ProductEntity> products;
  final bool isLoading;

  const ProductState({
    required this.products,
    this.isLoading = false,
  });

  ProductState copyWith({
    List<ProductEntity>? products,
    bool? isLoading,
  }) {
    return ProductState(
      products: products ?? this.products,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}