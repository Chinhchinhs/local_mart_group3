import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_local_datasource.dart';
import '../datasources/product_remote_data_source.dart';
import '../models/product_model.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductLocalDataSource dataSource;
  final ProductRemoteDataSource remoteDataSource;

  // Chuyển sang tham số vị trí cho đơn giản
  ProductRepositoryImpl(this.dataSource, this.remoteDataSource);

  @override
  Future<List<ProductEntity>> getRemoteProducts(String category) async {
    return await remoteDataSource.getProductsByCategory(category);
  }

  @override
  Future<List<Map<String, String>>> getRemoteCategories() async {
    return await remoteDataSource.getCategories();
  }

  @override
  Future<List<ProductEntity>> getProducts() async {
    return await dataSource.getProducts();
  }

  @override
  Future<ProductEntity?> getProductById(String id) async {
    return await dataSource.getProductById(id);
  }

  @override
  Future<void> addProduct(ProductEntity product) async {
    final model = ProductModel(
      id: product.id,
      name: product.name,
      price: product.price,
      description: product.description,
      imageUrl: product.imageUrl,
      sideDishes: product.sideDishes,
      category: product.category,
      isAvailable: product.isAvailable,
    );
    await dataSource.addProduct(model);
  }

  @override
  Future<void> deleteProduct(String id) async {
    await dataSource.deleteProduct(id);
  }
}
