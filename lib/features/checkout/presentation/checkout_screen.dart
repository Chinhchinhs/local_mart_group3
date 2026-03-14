import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
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

  LatLng _selectedLatLng = const LatLng(10.762622, 106.660172); 
  final MapController _mapController = MapController();
  bool _locationSelected = false;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _determinePosition(); 
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    super.dispose();
  }

  /// TỰ ĐỘNG TÌM TỌA ĐỘ TỪ ĐỊA CHỈ (GEOCODING MIỄN PHÍ)
  Future<void> _searchAddress(String query) async {
    if (query.isEmpty) return;
    
    setState(() => _isSearching = true);
    
    try {
      final url = Uri.parse("https://nominatim.openstreetmap.org/search?q=$query&format=json&limit=1");
      final response = await http.get(url, headers: {'User-Agent': 'local_mart_app'});

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          final lat = double.parse(data[0]['lat']);
          final lon = double.parse(data[0]['lon']);
          
          setState(() {
            _selectedLatLng = LatLng(lat, lon);
            _mapController.move(_selectedLatLng, 16.0);
            _locationSelected = true;
          });
        }
      }
    } catch (e) {
      debugPrint("Lỗi tìm địa chỉ: $e");
    } finally {
      setState(() => _isSearching = false);
    }
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    final position = await Geolocator.getCurrentPosition();
    setState(() {
      _selectedLatLng = LatLng(position.latitude, position.longitude);
      _mapController.move(_selectedLatLng, 15.0);
      _locationSelected = true;
    });
  }

  String _formatCurrency(double amount) => amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');

  @override
  Widget build(BuildContext context) {
    final double voucherDiscount = (widget.voucherCode != null) ? double.tryParse(widget.voucherCode!.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0.0 : 0.0;
    final double finalPrice = widget.totalPrice - voucherDiscount;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("XÁC NHẬN ĐƠN HÀNG", style: TextStyle(fontWeight: FontWeight.w900, color: Colors.orange, fontSize: 20)),
        centerTitle: true, elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Thông tin người mua", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            _buildTextField(nameController, "Họ và tên", Icons.person_outline),
            const SizedBox(height: 12),
            _buildTextField(phoneController, "Số điện thoại", Icons.phone_outlined, keyboardType: TextInputType.phone),
            const SizedBox(height: 12),
            
            // Ô NHẬP ĐỊA CHỈ CÓ NÚT TÌM KIẾM
            TextField(
              controller: addressController,
              decoration: InputDecoration(
                labelText: "Địa chỉ nhận hàng",
                filled: true, fillColor: Colors.grey[50],
                prefixIcon: const Icon(Icons.location_on_outlined, color: Colors.orange), // Đã sửa lỗi ở đây
                suffixIcon: _isSearching 
                  ? const Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator(strokeWidth: 2))
                  : IconButton(icon: const Icon(Icons.search, color: Colors.blue), onPressed: () => _searchAddress(addressController.text)),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
              onSubmitted: (value) => _searchAddress(value),
            ),
            
            const SizedBox(height: 20),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Vị trí trên bản đồ", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
                TextButton.icon(icon: const Icon(Icons.my_location, size: 16), label: const Text("Vị trí hiện tại", style: TextStyle(fontSize: 12)), onPressed: _determinePosition)
              ],
            ),
            Container(
              height: 250, width: double.infinity,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.orange.withOpacity(0.3))),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _selectedLatLng, initialZoom: 15.0,
                    onTap: (_, latLng) => setState(() { _selectedLatLng = latLng; _locationSelected = true; }),
                  ),
                  children: [
                    TileLayer(urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png", userAgentPackageName: 'com.local_mart_group3.app'),
                    MarkerLayer(markers: [Marker(point: _selectedLatLng, width: 40, height: 40, child: const Icon(Icons.location_on, color: Colors.red, size: 40))]),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),
            const Text("Chi tiết đơn hàng", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            ListView.builder(
              shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.items.length,
              itemBuilder: (context, index) {
                final item = widget.items[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.grey.withOpacity(0.1))),
                  child: ListTile(
                    leading: ClipRRect(borderRadius: BorderRadius.circular(8), child: ProductImage(imageUrl: item.imageUrl, width: 50, height: 50)),
                    title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    trailing: Text("${_formatCurrency(item.totalPrice)} VND"),
                  ),
                );
              },
            ),

            const Divider(height: 40),
            _buildPriceRow("Tổng cộng:", "${_formatCurrency(finalPrice)} VND", color: Colors.red, fontSize: 22),
            const SizedBox(height: 30),
            
            SizedBox(
              width: double.infinity, height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                onPressed: () {
                  if (nameController.text.isEmpty || phoneController.text.isEmpty || addressController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Vui lòng nhập đầy đủ thông tin")));
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

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {TextInputType? keyboardType}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller, keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label, filled: true, fillColor: Colors.grey[50], prefixIcon: Icon(icon, color: Colors.orange),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, {Color color = Colors.black, double fontSize = 16}) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: const TextStyle(fontWeight: FontWeight.bold)), Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: fontSize))]);
  }
}
