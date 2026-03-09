import '../entities/product_entity.dart';

abstract class ProductRepository {
  // --- REMOTE API ---
  Future<List<ProductEntity>> getRemoteProducts(String category);
  Future<List<Map<String, String>>> getRemoteCategories();

  // --- LOCAL SQLITE (ADMIN ONLY) ---
  Future<List<ProductEntity>> getProducts();
  Future<ProductEntity?> getProductById(String id);
  Future<void> addProduct(ProductEntity product);
  Future<void> deleteProduct(String id);

  // --- BEST SELLERS (MỚI - LƯU VĨNH VIỄN) ---
  Future<List<ProductEntity>> getBestSellers();
  Future<void> toggleBestSeller(ProductEntity product, bool isAdd);
}
