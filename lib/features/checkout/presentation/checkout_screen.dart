import 'package:flutter/material.dart';
import '../../cart/domain/entities/cart_item_entity.dart';
import 'payment_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final List<CartItemEntity> items;
  final double totalPrice;

  const CheckoutScreen({
    super.key,
    required this.items,
    required this.totalPrice,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {

  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Xác nhận đơn hàng"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              const Text("Thông tin người mua",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),

              const SizedBox(height: 10),

              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: "Họ và tên",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 10),

              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: "Số điện thoại",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 10),

              TextField(
                controller: addressController,
                decoration: const InputDecoration(
                  labelText: "Địa chỉ",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 20),

              const Text("Sản phẩm",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),

              const SizedBox(height: 10),

              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.items.length,
                itemBuilder: (context, index) {
                  final item = widget.items[index];
                  return ListTile(
                    title: Text(item.name),
                    subtitle: Text("SL: ${item.quantity}"),
                    trailing: Text(
                        "${item.price * item.quantity} VND"),
                  );
                },
              ),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Tổng tiền:",
                      style: TextStyle(fontSize: 16)),
                  Text("${widget.totalPrice} VND",
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.red)),
                ],
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {

                    if (nameController.text.isEmpty ||
                        phoneController.text.isEmpty ||
                        addressController.text.isEmpty) {

                      ScaffoldMessenger.of(context)
                          .showSnackBar(
                        const SnackBar(
                          content: Text(
                              "Vui lòng nhập đầy đủ thông tin"),
                        ),
                      );
                      return;
                    }

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PaymentScreen(
                          items: widget.items,
                          totalPrice: widget.totalPrice,
                          name: nameController.text,
                          phone: phoneController.text,
                          address: addressController.text,
                        ),
                      ),
                    );
                  },
                  child: const Text("TIẾP TỤC THANH TOÁN"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}