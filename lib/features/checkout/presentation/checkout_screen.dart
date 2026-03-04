import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cart/domain/entities/cart_item_entity.dart';
import '/features/checkout/presentation/bloc/checkout_bloc.dart';
import '/features/checkout/domain/usecases/process_checkout_usecase.dart';
import '/features/cart/presentation/bloc/cart_bloc.dart';

class CheckoutScreen extends StatelessWidget {
  final List<CartItemEntity> items;
  final double totalPrice;

  const CheckoutScreen({
    super.key,
    required this.items,
    required this.totalPrice,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CheckoutBloc(ProcessCheckoutUseCase()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Thanh toán"),
          backgroundColor: Colors.blueAccent,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // ===== DANH SÁCH SẢN PHẨM =====
              Expanded(
                child: ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 3,
                      child: ListTile(
                        leading: const Icon(Icons.shopping_bag),
                        title: Text(
                          item.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text("SL: ${item.quantity}"),
                        trailing: Text(
                          "${item.price * item.quantity} VND",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.red),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 10),

              // ===== TỔNG TIỀN =====
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Tổng thanh toán:",
                        style: TextStyle(fontSize: 16)),
                    Text(
                      "$totalPrice VND",
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.red),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Phương thức thanh toán",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),

              const SizedBox(height: 10),

              const PaymentOption(
                  title: "Thanh toán trực tiếp", icon: Icons.money),
              const PaymentOption(
                  title: "Thanh toán qua thẻ", icon: Icons.credit_card),
              const PaymentOption(
                  title: "Thanh toán qua app ngân hàng",
                  icon: Icons.account_balance),

              const SizedBox(height: 20),

              // ===== NÚT THANH TOÁN =====
              BlocConsumer<CheckoutBloc, CheckoutState>(
                listener: (context, state) {
                  if (state.isSuccess) {
                    context.read<CartBloc>().add(ClearCartEvent());

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text("Thanh toán thành công 🎉")),
                    );

                    Navigator.pop(context);
                  }
                },
                builder: (context, state) {
                  return SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        padding:
                        const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: state.isLoading
                          ? null
                          : () {
                        context
                            .read<CheckoutBloc>()
                            .add(ProcessCheckoutEvent());
                      },
                      child: state.isLoading
                          ? const CircularProgressIndicator(
                          color: Colors.white)
                          : const Text(
                        "XÁC NHẬN THANH TOÁN",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ===== WIDGET CHỌN PHƯƠNG THỨC =====
class PaymentOption extends StatelessWidget {
  final String title;
  final IconData icon;

  const PaymentOption({
    super.key,
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: Icon(icon, color: Colors.blueAccent),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }
}