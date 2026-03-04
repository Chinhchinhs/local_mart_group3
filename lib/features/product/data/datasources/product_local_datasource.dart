import '../models/product_model.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ProductLocalDataSource {
  List<ProductModel> _products = [];

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('products');
    if (data != null) {
      final decoded = json.decode(data) as List;
      _products = decoded.map((e) => ProductModel(
        id: e['id'],
        name: e['name'],
        price: e['price'],
        description: e['description'],
        imageUrl: e['imageUrl'],
      )).toList();
    }
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    final data = json.encode(_products.map((e) => {
      'id': e.id,
      'name': e.name,
      'price': e.price,
      'description': e.description,
      'imageUrl': e.imageUrl,
    }).toList());
    await prefs.setString('products', data);
  }

  List<ProductModel> getProducts() => _products;

  ProductModel getProductById(String id) =>
      _products.firstWhere((e) => e.id == id);

  void addProduct(ProductModel product) {
    _products.add(product);
  }

  void deleteProduct(String id) {
    _products.removeWhere((e) => e.id == id);
  }
}