import '../entities/product_entity.dart';
import '../repositories/product_repository.dart';

class AddProductUseCase {
  final ProductRepository repository;

  AddProductUseCase(this.repository);

  // Dùng hàm call để Bloc có thể gọi: await addProduct(product)
  Future<void> call(ProductEntity product) async {
    return await repository.addProduct(product);
  }
}
