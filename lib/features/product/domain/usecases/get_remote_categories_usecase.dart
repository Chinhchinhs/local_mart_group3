import '../repositories/product_repository.dart';

class GetRemoteCategoriesUseCase {
  final ProductRepository repository;
  GetRemoteCategoriesUseCase(this.repository);

  Future<List<Map<String, String>>> execute() async {
    return await repository.getRemoteCategories();
  }
}
