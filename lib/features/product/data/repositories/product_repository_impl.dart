import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_local_datasource.dart';
import '../datasources/product_remote_data_source.dart';
import '../models/product_model.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductLocalDataSource localDataSource;
  final ProductRemoteDataSource remoteDataSource;

  ProductRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  @override
  Future<List<ProductEntity>> getProducts() async {
    return await localDataSource.getProducts();
  }

  @override
  Future<ProductEntity?> getProductById(String id) async {
    return await localDataSource.getProductById(id);
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
      isAvailable: product.isAvailable,
      category: product.category,
    );
    await localDataSource.addProduct(model);
  }

  @override
  Future<void> deleteProduct(String id) async {
    await localDataSource.deleteProduct(id);
  }

  @override
  Future<List<ProductEntity>> getRemoteProducts(String category) async {
    return await remoteDataSource.getProductsByCategory(category);
  }

  @override
  Future<List<Map<String, String>>> getRemoteCategories() async {
    return await remoteDataSource.getCategories();
  }
}
