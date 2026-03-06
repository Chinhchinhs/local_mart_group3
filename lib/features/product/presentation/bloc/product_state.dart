import 'package:equatable/equatable.dart';
import '../../domain/entities/product_entity.dart';

class ProductState extends Equatable {
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

  @override
  List<Object?> get props => [products, isLoading];
}
