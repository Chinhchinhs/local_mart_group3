import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../cart/domain/entities/cart_item_entity.dart';
import '../../cart/presentation/bloc/cart_bloc.dart';
import '../../product/presentation/widgets/product_image.dart';

class InvoiceScreen extends StatelessWidget {
  final List<CartItemEntity> items;
  final double totalPrice;
  final String name;
  final String phone;
  final String address;
  final String paymentMethod;
  final String? voucherCode;
  final String? shipperNote;

  const InvoiceScreen({
    super.key,
    required this.items,
    required this.totalPrice,
    required this.name,
    required this.phone,
    required this.address,
    required this.paymentMethod,
    this.voucherCode,
    this.shipperNote,
  });

  String _formatCurrency(double amount) {
    return amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }

  String _getPaymentMethodText(String method) {
    switch (method) {
      case 'cash':
        return 'Thanh toán khi nhận hàng (COD)';
      case 'card':
        return 'Thanh toán qua thẻ';
      case 'bank':
        return 'Chuyển khoản ngân hàng';
      default:
        return method;
    }
  }
  /// Hàm tạo file PDF hóa đơn
  Future<Uint8List> _generatePdf(PdfPageFormat format) async {
    final pdf = pw.Document();
    // Tải font hỗ trợ tiếng Việt
    final font = await PdfGoogleFonts.robotoRegular();
    final fontBold = await PdfGoogleFonts.robotoBold();

    pdf.addPage(
      pw.Page(
        pageFormat: format,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Text("LOCAL MART - HÓA ĐƠN ĐẶT HÀNG", 
                  style: pw.TextStyle(font: fontBold, fontSize: 20)),
              ),
              pw.SizedBox(height: 20),
              
              pw.Text("Thông tin khách hàng:", style: pw.TextStyle(font: fontBold, fontSize: 14)),
              pw.Text("Tên: $name", style: pw.TextStyle(font: font)),
              pw.Text("SĐT: $phone", style: pw.TextStyle(font: font)),
              pw.Text("Địa chỉ: $address", style: pw.TextStyle(font: font)),
              pw.SizedBox(height: 20),

              pw.Text("Chi tiết đơn hàng:", style: pw.TextStyle(font: fontBold, fontSize: 14)),
              pw.Divider(),
              
              pw.Column(
                children: items.map((item) {
                  return pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(vertical: 4),
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Expanded(
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(item.name, style: pw.TextStyle(font: fontBold)),
                              pw.Text("Số lượng: ${item.quantity}", style: pw.TextStyle(font: font, fontSize: 10)),
                              if (item.selectedSideDishes.isNotEmpty)
                                pw.Text("Món phụ: ${item.selectedSideDishes.map((e) => e.name).join(', ')}", 
                                  style: pw.TextStyle(font: font, fontSize: 9)),
                            ],
                          ),
                        ),
                        pw.Text("${_formatCurrency(item.totalPrice)} VND", style: pw.TextStyle(font: font)),
                      ],
                    ),
                  );
                }).toList(),
              ),
              
              pw.Divider(),
              if (voucherCode != null && voucherCode!.isNotEmpty)
                pw.Text("Voucher: $voucherCode", style: pw.TextStyle(font: font)),
              pw.Text("Phương thức: ${_getPaymentMethodText(paymentMethod)}", style: pw.TextStyle(font: font)),
              pw.SizedBox(height: 10),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text("TỔNG CỘNG:", style: pw.TextStyle(font: fontBold, fontSize: 16)),
                  pw.Text("${_formatCurrency(totalPrice)} VND", 
                    style: pw.TextStyle(font: fontBold, fontSize: 16, color: PdfColors.red)),
                ],
              ),
              pw.SizedBox(height: 40),
              pw.Center(
                child: pw.Text("Cảm ơn quý khách đã mua sắm!", style: pw.TextStyle(font: font, fontStyle: pw.FontStyle.italic)),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("HÓA ĐƠN CHI TIẾT", 
          style: TextStyle(fontWeight: FontWeight.w900, color: Colors.orange, fontSize: 20)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          // Nút In hóa đơn
          IconButton(
            icon: const Icon(Icons.print, color: Colors.orange),
            onPressed: () async {
              await Printing.layoutPdf(
                onLayout: (PdfPageFormat format) => _generatePdf(format),
                name: 'HoaDon_LocalMart_$name',
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 80),
            const SizedBox(height: 10),
            const Text(
              "Đặt hàng thành công!",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const Text("Cảm ơn bạn đã mua sắm tại Local Mart", style: TextStyle(color: Colors.grey)),
            const Divider(height: 40),

            _buildSectionTitle("Thông tin khách hàng"),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.grey.withOpacity(0.1)),
              ),
              child: Column(
                children: [
                  _infoRow(Icons.person_outline, "Tên khách hàng:", name),
                  const SizedBox(height: 10),
                  _infoRow(Icons.phone_outlined, "Số điện thoại:", phone),
                  const SizedBox(height: 10),
                  _infoRow(Icons.location_on_outlined, "Địa chỉ nhận:", address),
                ],
              ),
            ),
            const SizedBox(height: 25),

            _buildSectionTitle("Chi tiết đơn hàng"),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final sideNames = item.selectedSideDishes.map((s) => s.name).toList();

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: ProductImage(imageUrl: item.imageUrl, width: 50, height: 50),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.name, 
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text("Số lượng: ${item.quantity}", style: const TextStyle(color: Colors.grey, fontSize: 13)),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text("${_formatCurrency(item.totalPrice)} VND", style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      if (sideNames.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(left: 62, top: 4),
                          child: Text("Món phụ: ${sideNames.join(', ')}", 
                            style: TextStyle(fontSize: 12, color: Colors.blue[700])),
                        ),
                      if (item.note.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(left: 62, top: 2),
                          child: Text("Ghi chú: ${item.note}", 
                            style: const TextStyle(fontSize: 12, color: Colors.orange, fontStyle: FontStyle.italic)),
                        ),
                    ],
                  ),
                );
              },
            ),

            if ((voucherCode != null && voucherCode!.isNotEmpty) || (shipperNote != null && shipperNote!.isNotEmpty))
              Container(
                margin: const EdgeInsets.only(top: 15, bottom: 15),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.withOpacity(0.1)),
                ),
                child: Column(
                  children: [
                    if (voucherCode != null && voucherCode!.isNotEmpty)
                      _infoRow(Icons.confirmation_number_outlined, "Voucher shop:", voucherCode!),
                    if (voucherCode != null && voucherCode!.isNotEmpty && shipperNote != null && shipperNote!.isNotEmpty)
                      const Divider(height: 16),
                    if (shipperNote != null && shipperNote!.isNotEmpty)
                      _infoRow(Icons.delivery_dining_outlined, "Ghi chú shipper:", shipperNote!),
                  ],
                ),
              ),

            const Divider(height: 30),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Phương thức thanh toán:", style: TextStyle(color: Colors.grey)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _getPaymentMethodText(paymentMethod), 
                    textAlign: TextAlign.right,
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("TỔNG THANH TOÁN:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text(
                  "${_formatCurrency(totalPrice)} VND",
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.red),
                ),
              ],
            ),
            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  context.read<CartBloc>().add(ClearCartEvent());
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Cảm ơn bạn đã ủng hộ Local Mart! ✅"),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                child: const Text("QUAY VỀ TRANG CHỦ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.orange)),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.orange),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
        const SizedBox(width: 6),
        Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
      ],
    );
  }
}
