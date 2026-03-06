import 'dart:io';
import 'package:flutter/material.dart';

class ProductImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;

  const ProductImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    // Kiểm tra xem là link mạng hay file cục bộ
    final isNetwork = imageUrl.startsWith('http') || imageUrl.startsWith('https');

    if (isNetwork) {
      return Image.network(
        imageUrl,
        width: width,
        height: height,
        fit: fit,
        // Hiển thị loading khi đang tải ảnh từ API
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                    : null,
              ),
            ),
          );
        },
        // Nếu link ảnh API bị hỏng, hiện ảnh lỗi mặc định
        errorBuilder: (context, error, stackTrace) => _buildErrorWidget(),
      );
    } else {
      // Xử lý ảnh file cục bộ (Dành cho Admin tự thêm)
      return Image.file(
        File(imageUrl),
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => _buildErrorWidget(),
      );
    }
  }

  Widget _buildErrorWidget() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[200],
      child: const Icon(Icons.fastfood, color: Colors.grey),
    );
  }
}
