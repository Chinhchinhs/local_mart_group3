// features/product/data/datasources/product_local_datasource.dart
import '../models/product_model.dart';

class ProductLocalDataSource {
  final List<ProductModel> _products = [
    ProductModel(
      id: '1',
      name: 'Burger',
      price: 50000,
      description: 'Delicious beef burger',
      imageUrl: 'https://via.placeholder.com/150',
    ),
    ProductModel(
      id: '2',
      name: 'Pizza',
      price: 120000,
      description: 'Cheese pizza',
      imageUrl: 'https://via.placeholder.com/150',
    ),
  ];

  List<ProductModel> getProducts() => _products;

  ProductModel getProductById(String id) =>
      _products.firstWhere((e) => e.id == id);

  void addProduct(ProductModel product) {
    _products.add(product);
  }
}