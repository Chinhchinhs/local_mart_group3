import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'add_product_screen.dart';
import 'product_list_screen.dart';
import 'admin_edit_list_screen.dart';
import 'admin_lock_list_screen.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';

class AdminActionScreen extends StatelessWidget {
  const AdminActionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Admin Control Panel", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false, // XÓA DẤU MŨI TÊN QUAY LẠI
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          children: [
            _buildAdminCard(
              context,
              title: "Thêm món mới",
              subtitle: "Thêm sản phẩm mới vào thực đơn",
              icon: Icons.add_circle_outline,
              color: Colors.green,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddProductScreen())),
            ),
            const SizedBox(height: 16),
            _buildAdminCard(
              context,
              title: "Sửa món đã có",
              subtitle: "Cập nhật tên, giá, ảnh hoặc món phụ",
              icon: Icons.edit_note_outlined,
              color: Colors.blue,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminEditListScreen())),
            ),
            const SizedBox(height: 16),
            _buildAdminCard(
              context,
              title: "Quản lý / Xóa món",
              subtitle: "Xóa vĩnh viễn các món khỏi thực đơn",
              icon: Icons.delete_outline,
              color: Colors.redAccent,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProductListScreen(isDeleteMode: true))),
            ),
            const SizedBox(height: 16),
            _buildAdminCard(
              context,
              title: "Khóa món (Hết hàng)",
              subtitle: "Tạm dừng kinh doanh các món đang hết",
              icon: Icons.lock_outline,
              color: Colors.orange,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminLockListScreen())),
            ),
            const SizedBox(height: 16),
            
            // CHỨC NĂNG XEM THỰC ĐƠN MỚI THÊM
            _buildAdminCard(
              context,
              title: "Xem thực đơn",
              subtitle: "Xem giao diện thực đơn như khách hàng",
              icon: Icons.restaurant_menu,
              color: Colors.purple,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProductListScreen(isAdminPreview: true))),
            ),
            
            const SizedBox(height: 40),
            
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () {
                  context.read<AuthBloc>().add(LogoutEvent());
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const ProductListScreen()),
                    (route) => false,
                  );
                },
                icon: const Icon(Icons.logout, color: Colors.red),
                label: const Text("ĐĂNG XUẤT KHỎI ADMIN", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminCard(BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: color.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
