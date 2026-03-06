import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/usecases/get_products_usecase.dart';
import '../../domain/usecases/add_product_usecase.dart';
import '../../domain/usecases/delete_product_usecase.dart';
import 'product_state.dart';

abstract class ProductEvent {}

class LoadProductsEvent extends ProductEvent {}

class AddProductEvent extends ProductEvent {
  final ProductEntity product;
  AddProductEvent(this.product);
}

class UpdateProductEvent extends ProductEvent {
  final ProductEntity product;
  UpdateProductEvent(this.product);
}

class DeleteProductEvent extends ProductEvent {
  final String id;
  DeleteProductEvent(this.id);
}

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final GetProductsUseCase getProducts;
  final AddProductUseCase addProduct;
  final DeleteProductUseCase deleteProduct;

  ProductBloc(this.getProducts, this.addProduct, this.deleteProduct) 
      : super(const ProductState(products: [])) {

    // 1. Tải danh sách sản phẩm
    on<LoadProductsEvent>((event, emit) async {
      emit(state.copyWith(isLoading: true));
      final products = await getProducts();
      emit(state.copyWith(products: List.from(products), isLoading: false));
    });

    // 2. Thêm sản phẩm mới
    on<AddProductEvent>((event, emit) async {
      emit(state.copyWith(isLoading: true));
      await addProduct(event.product);
      final newProducts = await getProducts();
      emit(state.copyWith(products: List.from(newProducts), isLoading: false));
    });

    // 3. Cập nhật sản phẩm (Xử lý xóa món phụ)
    on<UpdateProductEvent>((event, emit) async {
      print("--- ĐANG CẬP NHẬT SẢN PHẨM: ${event.product.name} ---");
      
      // Lưu vào SQLite
      await addProduct(event.product);
      
      // Lấy lại danh sách mới nhất từ DB
      final newProducts = await getProducts();
      
      // Cập nhật lại State của Bloc
      emit(state.copyWith(products: List.from(newProducts)));
      
      print("--- CẬP NHẬT DATABASE THÀNH CÔNG ---");
    });

    // 4. Xóa toàn bộ sản phẩm
    on<DeleteProductEvent>((event, emit) async {
      emit(state.copyWith(isLoading: true));
      await deleteProduct(event.id);
      final newProducts = await getProducts();
      emit(state.copyWith(products: List.from(newProducts), isLoading: false));
    });
  }
}
