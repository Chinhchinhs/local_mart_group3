// features/product/data/repositories/product_repository_impl.dart
import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_local_datasource.dart';
import '../models/product_model.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductLocalDataSource dataSource;

  ProductRepositoryImpl(this.dataSource);

  @override
  Future<List<ProductEntity>> getProducts() async {
    return dataSource.getProducts();
  }

  @override
  Future<ProductEntity> getProductById(String id) async {
    return dataSource.getProductById(id);
  }

  @override
  Future<void> deleteProduct(String id) async {
    dataSource.deleteProduct(id);
  }

  @override
  Future<void> addProduct(ProductEntity product) async {
    final model = ProductModel(
      id: product.id,
      name: product.name,
      price: product.price,
      description: product.description,
      imageUrl: product.imageUrl,
    );
    dataSource.addProduct(model);
  }
}