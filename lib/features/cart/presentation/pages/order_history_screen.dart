import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:local_mart/core/utils/currency_formatter.dart';
import 'package:local_mart/features/product/presentation/widgets/product_image.dart';
import '../../domain/entities/order_entity.dart';
import '../bloc/cart_bloc.dart';

class OrderHistoryScreen extends StatelessWidget {
  final String userId;
  final bool isAdmin;

  const OrderHistoryScreen({super.key, required this.userId, required this.isAdmin});

  @override
  Widget build(BuildContext context) {
    final repository = context.read<CartBloc>().repository;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(isAdmin ? "Quản lý đơn hàng" : "Lịch sử đặt hàng", 
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
        backgroundColor: Colors.white, elevation: 0, iconTheme: const IconThemeData(color: Colors.orange),
      ),
      body: FutureBuilder<List<OrderEntity>>(
        future: repository.getOrders(userId, isAdmin),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: Colors.orange));
          if (!snapshot.hasData || snapshot.data!.isEmpty) return _buildEmptyHistory();
          final orders = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) => _buildOrderCard(context, orders[index]),
          );
        },
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, OrderEntity order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))]),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(color: Colors.orange.withOpacity(0.08), borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(order.orderId, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
                  Text(DateFormat('dd/MM/yyyy HH:mm').format(order.orderDate), style: TextStyle(color: Colors.grey[600], fontSize: 11)),
                ]),
                Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(10)), child: const Text("HOÀN TẤT", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))),
              ],
            ),
          ),
          ...order.items.take(2).map((item) => ListTile(
            leading: ClipRRect(borderRadius: BorderRadius.circular(10), child: ProductImage(imageUrl: item.imageUrl, width: 45, height: 45)),
            title: Text(item.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold), maxLines: 1),
            trailing: Text(CurrencyFormatter.format(item.totalPrice), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
          )),
          if (order.items.length > 2) Padding(padding: const EdgeInsets.only(bottom: 8), child: Text("Và ${order.items.length - 2} món khác...", style: TextStyle(color: Colors.grey[500], fontSize: 11, fontStyle: FontStyle.italic))),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text("Tổng thanh toán", style: TextStyle(color: Colors.grey, fontSize: 11)),
                  Text(CurrencyFormatter.format(order.totalPrice), style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w900, fontSize: 18)),
                ]),
                ElevatedButton.icon(
                  onPressed: () => _showOrderDetail(context, order),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.orange, side: const BorderSide(color: Colors.orange), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
                  icon: const Icon(Icons.receipt_long_outlined, size: 18), label: const Text("CHI TIẾT", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showOrderDetail(BuildContext context, OrderEntity order) {
    // TÍNH TOÁN GIÁ GỐC ĐỂ HIỂN THỊ TẠM TÍNH TRONG LỊCH SỬ
    double originalTotal = order.items.fold(0, (sum, item) => sum + item.totalPrice);
    double discount = 0;
    if (order.voucherCode != null && order.voucherCode!.isNotEmpty) {
      try {
        discount = double.parse(order.voucherCode!.replaceAll(RegExp(r'[^0-9]'), ''));
      } catch (_) {}
    }

    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9, maxChildSize: 0.95, minChildSize: 0.6,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.only(topLeft: Radius.circular(25), topRight: Radius.circular(25))),
          child: ListView(
            controller: scrollController, padding: const EdgeInsets.all(24),
            children: [
              const Center(child: Icon(Icons.remove, color: Colors.grey)),
              const Text("CHI TIẾT ĐƠN HÀNG", textAlign: TextAlign.center, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.orange)),
              const SizedBox(height: 20),
              _buildInfoRow("Mã đơn", order.orderId),
              _buildInfoRow("Thời gian", DateFormat('dd/MM/yyyy HH:mm').format(order.orderDate)),
              _buildInfoRow("Khách hàng", order.userId),
              if (order.shipperNote != null && order.shipperNote!.isNotEmpty)
                _buildInfoRow("📝 Ghi chú Ship", order.shipperNote!, color: Colors.orange),
              
              const Divider(height: 40),
              const Text("DANH SÁCH MÓN ĂN", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 15),
              ...order.items.map((item) {
                final sideNames = item.selectedSideDishes.map((s) => s.name).toList();
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(borderRadius: BorderRadius.circular(8), child: ProductImage(imageUrl: item.imageUrl, width: 50, height: 50)),
                      const SizedBox(width: 12),
                      Expanded(child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text("SL: ${item.quantity}", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                          if (sideNames.isNotEmpty)
                            Text("Món phụ: ${sideNames.join(', ')}", style: const TextStyle(color: Colors.blue, fontSize: 11)),
                          if (item.note.isNotEmpty)
                            Text("Ghi chú: ${item.note}", style: const TextStyle(color: Colors.orange, fontSize: 11, fontStyle: FontStyle.italic)),
                        ],
                      )),
                      Text(CurrencyFormatter.format(item.totalPrice), style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                );
              }),
              
              const Divider(height: 40),
              _buildPriceRow("Tạm tính", CurrencyFormatter.format(originalTotal)),
              if (discount > 0)
                _buildPriceRow("Giảm giá Voucher", "- ${CurrencyFormatter.format(discount)}", color: Colors.green),
              _buildPriceRow("Phí giao hàng", "Miễn phí", color: Colors.green),
              const Divider(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("TỔNG CỘNG", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                  Text(CurrencyFormatter.format(order.totalPrice), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.red)),
                ],
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, minimumSize: const Size(double.infinity, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                child: const Text("ĐÓNG", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color color = Colors.black}) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: const TextStyle(color: Colors.grey)), Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: color))]));
  }

  Widget _buildPriceRow(String label, String value, {Color color = Colors.black}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: const TextStyle(color: Colors.grey)), Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: color))]),
    );
  }

  Widget _buildEmptyHistory() {
    return const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.history, size: 80, color: Colors.grey), SizedBox(height: 16), Text("Chưa có đơn hàng nào", style: TextStyle(color: Colors.grey))]));
  }
}
