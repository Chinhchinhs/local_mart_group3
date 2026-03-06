import '../repositories/product_repository.dart';

class GetRemoteCategoriesUseCase {
  final ProductRepository repository;

  GetRemoteCategoriesUseCase(this.repository);

  // Cập nhật kiểu trả về cho UseCase
  Future<List<Map<String, String>>> execute() async {
    return await repository.getRemoteCategories();
  }
}
