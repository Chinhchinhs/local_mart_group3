import 'package:flutter/material.dart';
import '../../cart/domain/entities/cart_item_entity.dart';
import '../../product/presentation/widgets/product_image.dart';
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

  String _formatCurrency(double amount) {
    return amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Phương thức thanh toán"),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thông tin giao hàng & Tổng tiền
              const Text("Thông tin giao hàng",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blueAccent.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Tên: ${widget.name}", style: const TextStyle(fontSize: 15)),
                    Text("SĐT: ${widget.phone}", style: const TextStyle(fontSize: 15)),
                    Text("Địa chỉ: ${widget.address}", style: const TextStyle(fontSize: 15)),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Tổng thanh toán:",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text("${_formatCurrency(widget.totalPrice)} VND",
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                                fontSize: 16)),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Danh sách sản phẩm (thu nhỏ)
              const Text("Sản phẩm đã chọn",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 10),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.items.length,
                itemBuilder: (context, index) {
                  final item = widget.items[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      dense: true,
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: ProductImage(
                          imageUrl: item.imageUrl,
                          width: 40,
                          height: 40,
                        ),
                      ),
                      title: Text(item.name, style: const TextStyle(fontSize: 14)),
                      trailing: Text("x${item.quantity}",
                          style: const TextStyle(color: Colors.grey)),
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              // Chọn phương thức thanh toán
              const Text("Chọn phương thức thanh toán",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 10),
              _buildPaymentOption(
                title: "Thanh toán khi nhận hàng (COD)",
                value: "cash",
                icon: Icons.money,
              ),
              _buildPaymentOption(
                title: "Thanh toán qua thẻ",
                value: "card",
                icon: Icons.credit_card,
              ),
              _buildPaymentOption(
                title: "Chuyển khoản ngân hàng",
                value: "bank",
                icon: Icons.account_balance,
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
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
                  child: const Text("XÁC NHẬN THANH TOÁN",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentOption({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return RadioListTile(
      secondary: Icon(icon, color: Colors.blueAccent),
      title: Text(title),
      value: value,
      groupValue: selectedMethod,
      onChanged: (newValue) {
        setState(() {
          selectedMethod = newValue!;
        });
      },
    );
  }
}
