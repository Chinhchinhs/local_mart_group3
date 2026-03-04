// features/product/domain/usecases/get_product_detail_usecase.dart
import '../entities/product_entity.dart';
import '../repositories/product_repository.dart';

class GetProductDetailUseCase {
  final ProductRepository repository;

  GetProductDetailUseCase(this.repository);

  Future<ProductEntity?> call(String id) {
    return repository.getProductById(id);
  }
}