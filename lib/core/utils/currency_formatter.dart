class CurrencyFormatter {
  /// Định dạng số tiền thành VND (ví dụ: 20000 -> 20.000)
  static String formatVND(double price) {
    int value = price.toInt();
    String result = value.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
    return result;
  }

  /// Hàm rút gọn để các bạn bên Product dùng tiện hơn
  static String format(double price) => formatVND(price);
}
