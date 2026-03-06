
import 'package:intl/intl.dart';

class CurrencyFormatter {
  static String format(double amount) {
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: 'VND', decimalDigits: 0);
    // Customizing the format to match "20.000 VND" exactly if needed, 
    // but vi_VN usually gives "20.000 ₫". 
    // Let's manually do it for the exact string "VND".
    final numberString = NumberFormat("#,###", "vi_VN").format(amount).replaceAll(',', '.');
    return "$numberString VND";

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
