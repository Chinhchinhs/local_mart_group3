import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/cart_item_entity.dart';
import '../../domain/usecases/add_to_cart_usecase.dart';

// --- 1. EVENT ---
abstract class CartEvent {}

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

  CartBloc(this.addToCartUseCase) : super(CartState()) {

    on<AddItemEvent>((event, emit) {
      final updatedCart = addToCartUseCase.execute(state.items, event.item);
      emit(state.copyWith(items: updatedCart, updateTrigger: DateTime.now().millisecondsSinceEpoch));
    });

    on<RemoveItemEvent>((event, emit) {
      final updatedCart = state.items.where((item) => item.id != event.itemId).toList();
      emit(state.copyWith(items: updatedCart, updateTrigger: DateTime.now().millisecondsSinceEpoch));
    });

    on<UpdateQuantityEvent>((event, emit) {
      if (event.newQuantity <= 0) {
        final updatedCart = state.items.where((item) => item.id != event.itemId).toList();
        emit(state.copyWith(items: updatedCart, updateTrigger: DateTime.now().millisecondsSinceEpoch));
      } else {
        final updatedCart = state.items.map((item) {
          if (item.id == event.itemId) return item.copyWith(quantity: event.newQuantity);
          return item;
        }).toList();
        emit(state.copyWith(items: updatedCart, updateTrigger: DateTime.now().millisecondsSinceEpoch));
      }
    });

    // Bật/tắt chế độ chọn xóa
    on<ToggleSelectionModeEvent>((event, emit) {
      emit(state.copyWith(
          isSelectionMode: !state.isSelectionMode,
          selectedItemIds: [], // Khi tắt đi bật lại thì xóa sạch các tích chọn cũ
          updateTrigger: DateTime.now().millisecondsSinceEpoch
      ));
    });

    // Tích/Bỏ tích 1 món
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
    on<DeleteSelectedItemsEvent>((event, emit) {
      final remainingItems = state.items.where((item) => !state.selectedItemIds.contains(item.id)).toList();
      emit(state.copyWith(
        items: remainingItems,
        isSelectionMode: false, // Xóa xong thì tự động thoát chế độ chọn
        selectedItemIds: [],
        updateTrigger: DateTime.now().millisecondsSinceEpoch,
      ));
    });
    on<ClearCartEvent>((event, emit) {
      emit(state.copyWith(
        items: [],
        selectedItemIds: [],
        isSelectionMode: false,
        updateTrigger: DateTime.now().millisecondsSinceEpoch,
      ));
    });
  }
}