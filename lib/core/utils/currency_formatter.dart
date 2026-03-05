class CurrencyFormatter {
  /// Định dạng số tiền thành VND (ví dụ: 20000 -> 20.000)
  /// Sử dụng logic Dart thuần để đảm bảo không bị lỗi package.
  static String formatVND(double price) {
    int value = price.toInt();
    
    // Regex thêm dấu chấm sau mỗi 3 chữ số
    String result = value.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
    
    return result;
  }
}
