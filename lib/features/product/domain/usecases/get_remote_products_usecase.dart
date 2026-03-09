import '../entities/product_entity.dart';
import '../repositories/product_repository.dart';

class GetRemoteProductsUseCase {
  final ProductRepository repository;

  GetRemoteProductsUseCase(this.repository);

  Future<List<ProductEntity>> execute(String category) async {
    return await repository.getRemoteProducts(category);
  }
}
