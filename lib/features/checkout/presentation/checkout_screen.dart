import 'package:flutter/material.dart';
import '../../cart/domain/entities/cart_item_entity.dart';
import '../../product/presentation/widgets/product_image.dart';
import 'payment_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final List<CartItemEntity> items; 
  final double totalPrice; 
  final String? voucherCode; 
  final String? shipperNote; 
  
  const CheckoutScreen({
    super.key,
    required this.items,
    required this.totalPrice,
    this.voucherCode,
    this.shipperNote,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();

  final TransformationController _transformationController = TransformationController();
  Offset? _pinPosition; 
  bool _locationSelected = false;

  @override
  void initState() {
    super.initState();
    // Đặt vị trí ban đầu của bản đồ vào trung tâm Ngọc Lãng
    _transformationController.value = Matrix4.identity()..translate(-800.0, -800.0);
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    _transformationController.dispose();
    super.dispose();
  }

  void _handleZoom(double scaleFactor) {
    final Matrix4 currentMatrix = _transformationController.value;
    final double currentScale = currentMatrix.getMaxScaleOnAxis();
    final double newScale = (currentScale * scaleFactor).clamp(0.5, 4.0);
    _transformationController.value = Matrix4.identity()..scale(newScale);
  }

  String _formatCurrency(double amount) {
    return amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }

  double _parseVoucher(String? voucher) {
    if (voucher == null || voucher.isEmpty) return 0.0;
    try {
      return double.parse(voucher.replaceAll(RegExp(r'[^0-9]'), ''));
    } catch (e) {
      return 0.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final double voucherDiscount = _parseVoucher(widget.voucherCode);
    final double finalPrice = widget.totalPrice - voucherDiscount;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("XÁC NHẬN ĐƠN HÀNG", 
          style: TextStyle(fontWeight: FontWeight.w900, color: Colors.orange, fontSize: 20)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle("Thông tin người mua", Icons.person_outline),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5))],
              ),
              child: Column(
                children: [
                  _buildTextField(nameController, "Họ và tên", Icons.person_outline),
                  const SizedBox(height: 12),
                  _buildTextField(phoneController, "Số điện thoại", Icons.phone_outlined, keyboardType: TextInputType.phone),
                  const SizedBox(height: 12),
                  _buildTextField(addressController, "Địa chỉ: Ngọc Lãng, Tuy Hòa", Icons.location_on_outlined),
                  const SizedBox(height: 20),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Bản đồ Ngọc Lãng (Lướt & Zoom)", 
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black54)),
                      if (_locationSelected) const Icon(Icons.check_circle, color: Colors.green, size: 18),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  Container(
                    height: 300, 
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.orange.withOpacity(0.2)),
                      color: const Color(0xFFF5F5F5),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Stack(
                        children: [
                          InteractiveViewer(
                            transformationController: _transformationController,
                            boundaryMargin: const EdgeInsets.all(1500),
                            minScale: 0.5,
                            maxScale: 4.0,
                            child: GestureDetector(
                              onTapDown: (details) {
                                setState(() {
                                  _pinPosition = _transformationController.toScene(details.localPosition);
                                  _locationSelected = true;
                                });
                              },
                              child: Stack(
                                children: [
                                  // NỀN BẢN ĐỒ NGỌC LÃNG (2000x2000)
                                  CustomPaint(
                                    size: const Size(2000, 2000), 
                                    painter: NgocLangPainter(),
                                  ),
                                  if (_pinPosition != null)
                                    Positioned(
                                      left: _pinPosition!.dx - 15,
                                      top: _pinPosition!.dy - 35,
                                      child: const Icon(Icons.location_on, color: Colors.red, size: 40),
                                    ),
                                ],
                              ),
                            ),
                          ),
                          
                          Positioned(
                            right: 15,
                            bottom: 15,
                            child: Column(
                              children: [
                                _zoomButton(Icons.add, () => _handleZoom(1.2)),
                                const SizedBox(height: 10),
                                _zoomButton(Icons.remove, () => _handleZoom(0.8)),
                              ],
                            ),
                          ),

                          if (!_locationSelected)
                            IgnorePointer(
                              child: Center(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                  decoration: BoxDecoration(color: Colors.black.withOpacity(0.7), borderRadius: BorderRadius.circular(25)),
                                  child: const Text("Ghim đúng chỗ nhận tại Ngọc Lãng", 
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),
            _buildSectionTitle("Chi tiết đơn hàng", Icons.restaurant_menu),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.items.length,
              itemBuilder: (context, index) {
                final item = widget.items[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.grey.withOpacity(0.1))),
                  child: Row(
                    children: [
                      ClipRRect(borderRadius: BorderRadius.circular(12), child: ProductImage(imageUrl: item.imageUrl, width: 50, height: 50)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            Text("Số lượng: ${item.quantity}", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                          ],
                        ),
                      ),
                      Text("${_formatCurrency(item.totalPrice)} VND", style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                );
              },
            ),

            if ((widget.voucherCode != null && widget.voucherCode!.trim().isNotEmpty) || (widget.shipperNote != null && widget.shipperNote!.trim().isNotEmpty))
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(vertical: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.orange.withOpacity(0.05), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.orange.withOpacity(0.1))),
                child: Column(
                  children: [
                    if (widget.voucherCode != null && widget.voucherCode!.trim().isNotEmpty)
                      _buildExtraRow(Icons.confirmation_number_outlined, "Voucher shop:", widget.voucherCode!),
                    if (widget.shipperNote != null && widget.shipperNote!.trim().isNotEmpty)
                      _buildExtraRow(Icons.delivery_dining_outlined, "Ghi chú shipper:", widget.shipperNote!),
                  ],
                ),
              ),

            const Divider(height: 40),
            _buildPriceRow("Tạm tính:", _formatCurrency(widget.totalPrice), color: Colors.grey[600]!),
            if (voucherDiscount > 0)
              _buildPriceRow("Giảm giá Voucher:", "- ${_formatCurrency(voucherDiscount)} VND", color: Colors.green),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Tổng cộng:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text("${_formatCurrency(finalPrice)} VND", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.red)),
              ],
            ),
            const SizedBox(height: 30),
            
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                onPressed: () {
                  if (nameController.text.isEmpty || phoneController.text.isEmpty || addressController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Vui lòng điền đủ thông tin giao hàng"), backgroundColor: Colors.red));
                    return;
                  }
                  if (!_locationSelected) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Vui lòng ghim vị trí nhận hàng"), backgroundColor: Colors.red));
                    return;
                  }
                  Navigator.push(context, MaterialPageRoute(builder: (_) => PaymentScreen(
                    items: widget.items, totalPrice: widget.totalPrice, name: nameController.text, phone: phoneController.text, address: addressController.text, voucherCode: widget.voucherCode, shipperNote: widget.shipperNote,
                  )));
                },
                child: const Text("TIẾP TỤC THANH TOÁN", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _zoomButton(IconData icon, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)]),
      child: IconButton(icon: Icon(icon, color: Colors.orange, size: 24), onPressed: onPressed),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(children: [Icon(icon, size: 20, color: Colors.orange), const SizedBox(width: 8), Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))]),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {TextInputType? keyboardType}) {
    return TextField(
      controller: controller, keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label, filled: true, fillColor: Colors.grey[50], prefixIcon: Icon(icon, color: Colors.orange),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildExtraRow(IconData icon, String label, String value) {
    return Row(children: [Icon(icon, size: 18, color: Colors.orange), const SizedBox(width: 8), Text(label, style: const TextStyle(color: Colors.black54, fontSize: 13)), const SizedBox(width: 6), Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)))]);
  }

  Widget _buildPriceRow(String label, String value, {Color color = Colors.black}) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 2.0), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: TextStyle(color: Colors.grey[600])), Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold))]));
  }
}

/// VẼ BẢN ĐỒ MÔ PHỎNG KHU NGỌC LÃNG, TUY HÒA
class NgocLangPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    
    // 1. Nền bản đồ (Màu trắng xám nhạt của giấy)
    paint.color = const Color(0xFFF1F1F1);
    canvas.drawRect(Offset.zero & size, paint);

    // 2. Vẽ Sông Đà Rằng (Xanh dương uốn lượn)
    paint.color = const Color(0xFFB3E5FC);
    final riverPath = Path();
    riverPath.moveTo(0, size.height * 0.15);
    riverPath.quadraticBezierTo(size.width * 0.4, size.height * 0.1, size.width, size.height * 0.4);
    riverPath.lineTo(size.width, size.height * 0.55);
    riverPath.quadraticBezierTo(size.width * 0.4, size.height * 0.25, 0, size.height * 0.3);
    riverPath.close();
    canvas.drawPath(riverPath, paint);

    // 3. Vẽ đường HL21 (Đường chính màu xám đậm hơn)
    paint.color = Colors.grey[400]!;
    paint.strokeWidth = 25;
    paint.style = PaintingStyle.stroke;
    canvas.drawLine(Offset(size.width * 0.1, 0), Offset(size.width * 0.4, size.height), paint);

    // 4. Vẽ các con đường nhỏ trong khu Ngọc Lãng
    paint.color = Colors.white;
    paint.strokeWidth = 8;
    for (int i = 0; i < 15; i++) {
      canvas.drawLine(Offset(size.width * 0.4, 200 + i * 100), Offset(size.width * 0.9, 300 + i * 80), paint);
      canvas.drawLine(Offset(400 + i * 120, 200), Offset(350 + i * 100, 800), paint);
    }

    // 5. Vẽ khu vực Tháp Nhạn (Góc trên trái)
    paint.style = PaintingStyle.fill;
    paint.color = const Color(0xFFC8E6C9); // Công viên xanh quanh tháp
    canvas.drawCircle(Offset(size.width * 0.15, size.height * 0.1), 100, paint);
    
    // Biểu tượng Tháp (Hình tam giác)
    paint.color = Colors.orange[800]!;
    final towerPath = Path();
    towerPath.moveTo(size.width * 0.15, size.height * 0.05);
    towerPath.lineTo(size.width * 0.12, size.height * 0.15);
    towerPath.lineTo(size.width * 0.18, size.height * 0.15);
    towerPath.close();
    canvas.drawPath(towerPath, paint);

    // 6. Viết Text địa danh
    const textStyle = TextStyle(color: Colors.black87, fontSize: 40, fontWeight: FontWeight.bold);
    const subTextStyle = TextStyle(color: Colors.black54, fontSize: 30, fontWeight: FontWeight.w600);

    _drawText(canvas, "NGỌC LÃNG", Offset(size.width * 0.5, size.height * 0.5), textStyle);
    _drawText(canvas, "Tháp Nhạn", Offset(size.width * 0.15, size.height * 0.2), subTextStyle);
    
    // Vẽ nhãn đường HL21
    paint.color = Colors.blue[800]!;
    paint.style = PaintingStyle.fill;
    canvas.drawRRect(RRect.fromLTRBR(size.width * 0.1, size.height * 0.8, size.width * 0.25, size.height * 0.88, const Radius.circular(5)), paint);
    _drawText(canvas, "HL21", Offset(size.width * 0.17, size.height * 0.84), const TextStyle(color: Colors.white, fontSize: 25));
  }

  void _drawText(Canvas canvas, String text, Offset offset, TextStyle style) {
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, offset - Offset(textPainter.width / 2, textPainter.height / 2));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
