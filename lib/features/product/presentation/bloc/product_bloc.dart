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

class DeleteProductEvent extends ProductEvent {
  final String id;
  DeleteProductEvent(this.id);
}

/// ================= BLOC =================

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final GetProductsUseCase getProducts;
  final AddProductUseCase addProduct;
  final DeleteProductUseCase deleteProduct;

  ProductBloc(
      this.getProducts,
      this.addProduct,
      this.deleteProduct,
      ) : super(const ProductState(products: [])) {

    /// LOAD PRODUCTS
    on<LoadProductsEvent>((event, emit) async {
      emit(state.copyWith(isLoading: true));

      final products = await getProducts();

      // Dùng List.from() để ép Bloc nhận diện sự thay đổi
      emit(state.copyWith(
        products: List.from(products),
        isLoading: false,
      ));
    });

    /// ADD PRODUCT
    on<AddProductEvent>((event, emit) async {
      print("ĐANG THÊM SẢN PHẨM: ${event.product.name}");
      emit(state.copyWith(isLoading: true)); // Bật xoay vòng vòng

      try {
        // 1. Thêm sản phẩm vào Database
        await addProduct(event.product);
        print("THÊM VÀO DATABASE THÀNH CÔNG!");

        // 2. Lấy lại danh sách mới nhất
        final newProducts = await getProducts();

        // 3. Tắt xoay vòng vòng và cập nhật màn hình
        emit(state.copyWith(
          products: List.from(newProducts),
          isLoading: false,
        ));
      } catch (e) {
        // BẮT LỖI Ở ĐÂY!
        print("❌ LỖI NGHIÊM TRỌNG KHI THÊM SẢN PHẨM: $e");

        // Tắt xoay vòng vòng để màn hình không bị kẹt
        emit(state.copyWith(isLoading: false));
      }
    });

    /// DELETE PRODUCT
    on<DeleteProductEvent>((event, emit) async {
      emit(state.copyWith(isLoading: true));

      // 1. Xóa sản phẩm
      await deleteProduct(event.id);

      // 2. Lấy lại danh sách và cập nhật
      final newProducts = await getProducts();
      emit(state.copyWith(
        products: List.from(newProducts),
        isLoading: false,
      ));
    });
  }
}