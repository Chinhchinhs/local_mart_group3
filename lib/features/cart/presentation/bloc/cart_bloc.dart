import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/cart_item_entity.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/usecases/add_to_cart_usecase.dart';
import '../../domain/repositories/cart_repository.dart';
import '../../../product/domain/entities/product_entity.dart';

abstract class CartEvent {}

class LoadCartEvent extends CartEvent {}
class AddItemEvent extends CartEvent { final CartItemEntity item; AddItemEvent(this.item); }
class RemoveItemEvent extends CartEvent { final String itemId; RemoveItemEvent(this.itemId); }
class UpdateQuantityEvent extends CartEvent { final String itemId; final int newQuantity; UpdateQuantityEvent(this.itemId, this.newQuantity); }
class ToggleSelectionModeEvent extends CartEvent {}
class ToggleItemSelectionEvent extends CartEvent { final String itemId; ToggleItemSelectionEvent(this.itemId); }
class DeleteSelectedItemsEvent extends CartEvent {}
class ClearCartEvent extends CartEvent {}

class PlaceOrderEvent extends CartEvent {
  final String userId;
  final String? voucherCode;
  final String? shipperNote;
  final double? finalPrice; // THÊM TRƯỜNG GIÁ CUỐI CÙNG
  PlaceOrderEvent(this.userId, {this.voucherCode, this.shipperNote, this.finalPrice});
}

class UpdateItemDetailsEvent extends CartEvent {
  final String oldItemId;
  final List<SideDishEntity> newSideDishes;
  final String newNote;
  final double newPrice;

  UpdateItemDetailsEvent({
    required this.oldItemId,
    required this.newSideDishes,
    required this.newNote,
    required this.newPrice,
  });
}

class CartState {
  final List<CartItemEntity> items;
  final bool isSelectionMode;
  final List<String> selectedItemIds;
  final bool isOrderSuccess;

  CartState({
    this.items = const [],
    this.isSelectionMode = false,
    this.selectedItemIds = const [],
    this.isOrderSuccess = false,
  });

  double get totalPrice {
    return items.fold(0, (sum, item) => sum + item.totalPrice);
  }

  CartState copyWith({
    List<CartItemEntity>? items,
    bool? isSelectionMode,
    List<String>? selectedItemIds,
    bool? isOrderSuccess,
  }) {
    return CartState(
      items: items ?? this.items,
      isSelectionMode: isSelectionMode ?? this.isSelectionMode,
      selectedItemIds: selectedItemIds ?? this.selectedItemIds,
      isOrderSuccess: isOrderSuccess ?? this.isOrderSuccess,
    );
  }
}

class CartBloc extends Bloc<CartEvent, CartState> {
  final AddToCartUseCase addToCartUseCase;
  final CartRepository repository;

  CartBloc(this.addToCartUseCase, this.repository) : super(CartState()) {

    on<LoadCartEvent>((event, emit) async {
      final savedCart = await repository.getCart();
      emit(state.copyWith(items: savedCart, isOrderSuccess: false));
    });

    on<AddItemEvent>((event, emit) async {
      final currentCart = List<CartItemEntity>.from(state.items);
      final updatedCart = addToCartUseCase.execute(currentCart, event.item);
      await repository.saveCart(updatedCart);
      emit(state.copyWith(items: updatedCart));
    });

    on<PlaceOrderEvent>((event, emit) async {
      if (state.items.isEmpty) return;

      final newOrder = OrderEntity(
        orderId: "ORDER_${DateTime.now().millisecondsSinceEpoch}",
        userId: event.userId,
        items: List.from(state.items),
        totalPrice: event.finalPrice ?? state.totalPrice, // SỬ DỤNG GIÁ ĐÃ GIẢM NẾU CÓ
        orderDate: DateTime.now(),
        voucherCode: event.voucherCode,
        shipperNote: event.shipperNote,
      );

      await repository.placeOrder(newOrder);
      emit(state.copyWith(items: [], selectedItemIds: [], isOrderSuccess: true));
    });

    on<ClearCartEvent>((event, emit) async {
      await repository.saveCart([]);
      emit(state.copyWith(items: [], selectedItemIds: [], isSelectionMode: false));
    });

    on<UpdateItemDetailsEvent>((event, emit) async {
      final List<CartItemEntity> currentItems = List.from(state.items);
      final index = currentItems.indexWhere((item) => item.id == event.oldItemId);
      
      if (index != -1) {
        final oldItem = currentItems[index];
        currentItems[index] = oldItem.copyWith(
          selectedSideDishes: event.newSideDishes,
          note: event.newNote,
          price: event.newPrice
        );
        await repository.saveCart(currentItems);
        emit(state.copyWith(items: currentItems));
      }
    });

    on<RemoveItemEvent>((event, emit) async {
      final updatedCart = state.items.where((item) => item.id != event.itemId).toList();
      await repository.saveCart(updatedCart);
      emit(state.copyWith(items: updatedCart));
    });

    on<UpdateQuantityEvent>((event, emit) async {
      final updatedCart = state.items.map((item) {
        if (item.id == event.itemId) return item.copyWith(quantity: event.newQuantity);
        return item;
      }).toList();
      await repository.saveCart(updatedCart);
      emit(state.copyWith(items: updatedCart));
    });

    on<ToggleSelectionModeEvent>((event, emit) {
      emit(state.copyWith(isSelectionMode: !state.isSelectionMode, selectedItemIds: []));
    });

    on<ToggleItemSelectionEvent>((event, emit) {
      final currentSelected = List<String>.from(state.selectedItemIds);
      if (currentSelected.contains(event.itemId)) {
        currentSelected.remove(event.itemId);
      } else {
        currentSelected.add(event.itemId);
      }
      emit(state.copyWith(selectedItemIds: currentSelected));
    });

    on<DeleteSelectedItemsEvent>((event, emit) async {
      final remainingItems = state.items.where((item) => !state.selectedItemIds.contains(item.id)).toList();
      await repository.saveCart(remainingItems);
      emit(state.copyWith(items: remainingItems, isSelectionMode: false, selectedItemIds: []));
    });
  }
}
