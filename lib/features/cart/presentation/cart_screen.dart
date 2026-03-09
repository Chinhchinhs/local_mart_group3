import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_mart/features/product/presentation/bloc/product_bloc.dart';
import '../domain/entities/cart_item_entity.dart';
import 'bloc/cart_bloc.dart';
import 'pages/edit_cart_item_screen.dart';
import 'widgets/cart_item_tile.dart';
import 'widgets/freeship_progress_bar.dart';
import 'widgets/cart_bottom_bar.dart';
import 'widgets/cart_recommendations.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  String voucherCode = "";
  String shipperNote = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('GIỎ HÀNG', 
          style: TextStyle(fontWeight: FontWeight.w900, color: Colors.orange, fontSize: 22, letterSpacing: 1.2)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [_buildSelectionAction()],
      ),
      body: BlocBuilder<CartBloc, CartState>(
        builder: (context, state) {
          if (state.items.isEmpty) return _buildEmptyCart();

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              FreeShipProgressBar(totalPrice: state.totalPrice),
              const SizedBox(height: 10),
              ...state.items.map((item) => CartItemTile(
                item: item,
                isSelected: state.selectedItemIds.contains(item.id),
                isSelectionMode: state.isSelectionMode,
                onEdit: () => _navigateToEdit(context, item),
              )),
              const CartRecommendations(),
              const SizedBox(height: 20),
            ],
          );
        },
      ),
      bottomNavigationBar: _buildBottomSection(),
    );
  }

  Widget _buildSelectionAction() {
    return BlocBuilder<CartBloc, CartState>(
      builder: (context, state) {
        if (state.items.isEmpty) return const SizedBox.shrink();
        return IconButton(
          icon: Icon(state.isSelectionMode ? Icons.close : Icons.delete_sweep_outlined, 
            color: state.isSelectionMode ? Colors.red : Colors.blue),
          onPressed: () => context.read<CartBloc>().add(ToggleSelectionModeEvent()),
        );
      },
    );
  }

  Widget _buildBottomSection() {
    return BlocBuilder<CartBloc, CartState>(
      builder: (context, state) {
        if (state.items.isEmpty) return const SizedBox.shrink();
        return CartBottomBar(
          state: state,
          voucherCode: voucherCode,
          shipperNote: shipperNote,
          onVoucherChanged: (code) => setState(() => voucherCode = code),
          onNoteChanged: (note) => shipperNote = note,
        );
      },
    );
  }

  Widget _buildEmptyCart() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_bag_outlined, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text("Giỏ hàng của bạn đang trống", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _navigateToEdit(BuildContext context, CartItemEntity item) {
    final productState = context.read<ProductBloc>().state;
    final allProducts = [...productState.remoteProducts, ...productState.localProducts];
    
    final originalProduct = allProducts.firstWhere(
      (p) => p.name == item.name,
      orElse: () => allProducts.first
    );

    Navigator.push(context, MaterialPageRoute(
      builder: (_) => EditCartItemScreen(
        item: item, 
        allAvailableSideDishes: originalProduct.sideDishes
      )
    ));
  }
}
