import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/entities/product_entity.dart';
import 'dart:math';

abstract class ProductRemoteDataSource {
  Future<List<ProductEntity>> getProductsByCategory(String category);
  Future<List<Map<String, String>>> getCategories(); // Cập nhật kiểu trả về
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final http.Client client;

  ProductRemoteDataSourceImpl({required this.client});

  @override
  Future<List<Map<String, String>>> getCategories() async {
    final response = await client.get(
      Uri.parse('https://www.themealdb.com/api/json/v1/1/categories.php'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> categories = data['categories'];
      return categories.map((c) => {
        'name': c['strCategory'] as String,
        'image': c['strCategoryThumb'] as String,
      }).toList();
    } else {
      throw Exception('Không thể tải danh mục');
    }
  }

  @override
  Future<List<ProductEntity>> getProductsByCategory(String category) async {
    final response = await client.get(
      Uri.parse('https://www.themealdb.com/api/json/v1/1/filter.php?c=$category'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> meals = data['meals'];

      return meals.map((meal) {
        final randomPrice = (Random().nextInt(12) + 3) * 10000.0;

        return ProductEntity(
          id: meal['idMeal'],
          name: meal['strMeal'],
          price: randomPrice,
          description: "Món ăn ngon từ danh mục $category. Được chế biến sạch sẽ, đảm bảo vệ sinh thực phẩm.",
          imageUrl: meal['strMealThumb'],
          category: category,
          sideDishes: [
            const SideDishEntity(id: 's1', name: 'Thêm trứng', price: 5000),
            const SideDishEntity(id: 's2', name: 'Size lớn', price: 10000),
          ],
        );
      }).toList();
    } else {
      throw Exception('Không thể tải danh sách món ăn');
    }
  }
}
