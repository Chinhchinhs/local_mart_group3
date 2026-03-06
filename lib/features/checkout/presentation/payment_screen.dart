import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cart/domain/entities/cart_item_entity.dart';
import '../../cart/presentation/bloc/cart_bloc.dart';
import 'invoice_screen.dart';

class PaymentScreen extends StatefulWidget {
  final List<CartItemEntity> items;
  final double totalPrice;
  final String name;
  final String phone;
  final String address;

  const PaymentScreen({
    super.key,
    required this.items,
    required this.totalPrice,
    required this.name,
    required this.phone,
    required this.address,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {

  String selectedMethod = "cash";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Phương thức thanh toán"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const Text("Thông tin giao hàng",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),

            const SizedBox(height: 10),

            Text("Tên: ${widget.name}"),
            Text("SĐT: ${widget.phone}"),
            Text("Địa chỉ: ${widget.address}"),

            const SizedBox(height: 20),

            const Text("Chọn phương thức",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),

            RadioListTile(
              title: const Text("Thanh toán khi nhận hàng"),
              value: "cash",
              groupValue: selectedMethod,
              onChanged: (value) {
                setState(() {
                  selectedMethod = value!;
                });
              },
            ),

            RadioListTile(
              title: const Text("Thanh toán qua thẻ"),
              value: "card",
              groupValue: selectedMethod,
              onChanged: (value) {
                setState(() {
                  selectedMethod = value!;
                });
              },
            ),

            RadioListTile(
              title: const Text("Chuyển khoản ngân hàng"),
              value: "bank",
              groupValue: selectedMethod,
              onChanged: (value) {
                setState(() {
                  selectedMethod = value!;
                });
              },
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => InvoiceScreen(
                        items: widget.items,
                        totalPrice: widget.totalPrice,
                        name: widget.name,
                        phone: widget.phone,
                        address: widget.address,
                        paymentMethod: selectedMethod,
                      ),
                    ),
                  );
                },
                child: const Text("THANH TOÁN"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}