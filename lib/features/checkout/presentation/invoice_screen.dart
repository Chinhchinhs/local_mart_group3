import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cart/domain/entities/cart_item_entity.dart';
import '../../cart/presentation/bloc/cart_bloc.dart';

class InvoiceScreen extends StatelessWidget {
  final List<CartItemEntity> items;
  final double totalPrice;
  final String name;
  final String phone;
  final String address;
  final String paymentMethod;

  const InvoiceScreen({
    super.key,
    required this.items,
    required this.totalPrice,
    required this.name,
    required this.phone,
    required this.address,
    required this.paymentMethod,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("HÓA ĐƠN"),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const Text("Thông tin khách hàng",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),

            const SizedBox(height: 10),

            Text("Tên: $name"),
            Text("SĐT: $phone"),
            Text("Địa chỉ: $address"),

            const Divider(height: 30),

            const Text("Chi tiết đơn hàng",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),

            const SizedBox(height: 10),

            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return ListTile(
                    title: Text(item.name),
                    subtitle: Text("SL: ${item.quantity}"),
                    trailing: Text(
                        "${item.price * item.quantity} VND"),
                  );
                },
              ),
            ),

            const Divider(),

            Text("Phương thức: $paymentMethod"),

            const SizedBox(height: 10),

            Text(
              "Tổng tiền: $totalPrice VND",
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                onPressed: () {

                  context.read<CartBloc>().add(ClearCartEvent());
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Đơn hàng đã được ghi nhận ✅"),
                    ),
                  );
                  Navigator.popUntil(
                    context,
                        (route) => route.isFirst,
                  );
                },
                child: const Text("HOÀN TẤT"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}