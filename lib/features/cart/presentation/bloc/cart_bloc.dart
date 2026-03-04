import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/cart_item_entity.dart';
import '../../domain/usecases/add_to_cart_usecase.dart';
import '../../domain/repositories/cart_repository.dart';

// --- 1. EVENT ---
abstract class CartEvent {}

class LoadCartEvent extends CartEvent {} // Đã thêm: Event gọi khi vừa mở app
class AddItemEvent extends CartEvent { final CartItemEntity item; AddItemEvent(this.item); }
class RemoveItemEvent extends CartEvent { final String itemId; RemoveItemEvent(this.itemId); }
class UpdateQuantityEvent extends CartEvent { final String itemId; final int newQuantity; UpdateQuantityEvent(this.itemId, this.newQuantity); }

// 3 Event mới cho tính năng Chọn để xóa
class ToggleSelectionModeEvent extends CartEvent {}
class ToggleItemSelectionEvent extends CartEvent { final String itemId; ToggleItemSelectionEvent(this.itemId); }
class DeleteSelectedItemsEvent extends CartEvent {}
class ClearCartEvent extends CartEvent {}

// --- 2. STATE ---
class CartState {
  final List<CartItemEntity> items;
  final int updateTrigger;
  final bool isSelectionMode; // Bật/tắt giao diện chọn xóa
  final List<String> selectedItemIds; // Danh sách ID các món đang bị tích chọn

  CartState({
    this.items = const [],
    this.updateTrigger = 0,
    this.isSelectionMode = false,
    this.selectedItemIds = const [],
  });

  double get totalPrice => items.fold(0, (sum, item) => sum + (item.price * item.quantity));

  // Hàm hỗ trợ copy trạng thái cũ và thay đổi vài chỗ
  CartState copyWith({
    List<CartItemEntity>? items,
    int? updateTrigger,
    bool? isSelectionMode,
    List<String>? selectedItemIds,
  }) {
    return CartState(
      items: items ?? this.items,
      updateTrigger: updateTrigger ?? this.updateTrigger,
      isSelectionMode: isSelectionMode ?? this.isSelectionMode,
      selectedItemIds: selectedItemIds ?? this.selectedItemIds,
    );
  }
}

// --- 3. BLOC ---
class CartBloc extends Bloc<CartEvent, CartState> {
  final AddToCartUseCase addToCartUseCase;
  final CartRepository repository; // Đã thêm: Bộ nhớ SQLite

  CartBloc(this.addToCartUseCase, this.repository) : super(CartState()) {

    // Đã thêm: Xử lý sự kiện LoadCart khi mở app
    on<LoadCartEvent>((event, emit) async {
      final savedCart = await repository.getCart();
      emit(state.copyWith(items: savedCart, updateTrigger: DateTime.now().millisecondsSinceEpoch));
    });

    on<AddItemEvent>((event, emit) async {
      // Đề phòng trường hợp app vừa mở, LoadCart chưa xong mà người dùng đã bấm thêm đồ.
      final currentCart = await repository.getCart();

      // 2. Nhét món đồ mới vào danh sách chuẩn vừa lấy từ DB
      final updatedCart = addToCartUseCase.execute(currentCart, event.item);

      // 3. Cất lại vào kho và báo cho màn hình vẽ lại
      await repository.saveCart(updatedCart);
      emit(state.copyWith(items: updatedCart, updateTrigger: DateTime.now().millisecondsSinceEpoch));
    });

    on<RemoveItemEvent>((event, emit) async {
      final updatedCart = state.items.where((item) => item.id != event.itemId).toList();
      await repository.saveCart(updatedCart); // Đã thêm: Lưu vào DB
      emit(state.copyWith(items: updatedCart, updateTrigger: DateTime.now().millisecondsSinceEpoch));
    });

    on<UpdateQuantityEvent>((event, emit) async {
      List<CartItemEntity> updatedCart;
      if (event.newQuantity <= 0) {
        updatedCart = state.items.where((item) => item.id != event.itemId).toList();
      } else {
        updatedCart = state.items.map((item) {
          if (item.id == event.itemId) return item.copyWith(quantity: event.newQuantity);
          return item;
        }).toList();
      }
      await repository.saveCart(updatedCart); // Đã thêm: Lưu vào DB
      emit(state.copyWith(items: updatedCart, updateTrigger: DateTime.now().millisecondsSinceEpoch));
    });

    // Bật/tắt chế độ chọn xóa (Không đổi dữ liệu hàng hóa nên không cần lưu DB)
    on<ToggleSelectionModeEvent>((event, emit) {
      emit(state.copyWith(
          isSelectionMode: !state.isSelectionMode,
          selectedItemIds: [], // Khi tắt đi bật lại thì xóa sạch các tích chọn cũ
          updateTrigger: DateTime.now().millisecondsSinceEpoch
      ));
    });

    // Tích/Bỏ tích 1 món (Không đổi dữ liệu hàng hóa nên không cần lưu DB)
    on<ToggleItemSelectionEvent>((event, emit) {
      final currentSelected = List<String>.from(state.selectedItemIds);
      if (currentSelected.contains(event.itemId)) {
        currentSelected.remove(event.itemId); // Bỏ tích
      } else {
        currentSelected.add(event.itemId); // Tích vào
      }
      emit(state.copyWith(selectedItemIds: currentSelected, updateTrigger: DateTime.now().millisecondsSinceEpoch));
    });

    // Xóa tất cả các món đã tích
    on<DeleteSelectedItemsEvent>((event, emit) async {
      final remainingItems = state.items.where((item) => !state.selectedItemIds.contains(item.id)).toList();
      await repository.saveCart(remainingItems); // Đã thêm: Lưu vào DB
      emit(state.copyWith(
        items: remainingItems,
        isSelectionMode: false, // Xóa xong thì tự động thoát chế độ chọn
        selectedItemIds: [],
        updateTrigger: DateTime.now().millisecondsSinceEpoch,
      ));
    });

    // Sự kiện Clear toàn bộ giỏ hàng của bạn
    on<ClearCartEvent>((event, emit) async {
      await repository.saveCart([]); // Đã thêm: Lưu một danh sách rỗng vào DB (xóa sạch DB)
      emit(state.copyWith(
        items: [],
        selectedItemIds: [],
        isSelectionMode: false,
        updateTrigger: DateTime.now().millisecondsSinceEpoch,
      ));
    });
  }
}