// features/product/domain/repositories/product_repository.dart
import '../entities/product_entity.dart';

abstract class ProductRepository {
  Future<List<ProductEntity>> getProducts();
  Future<ProductEntity> getProductById(String id);
  Future<void> addProduct(ProductEntity product);
}