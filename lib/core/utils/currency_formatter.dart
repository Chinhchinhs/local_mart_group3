import 'package:intl/intl.dart';

class CurrencyFormatter {
  static String format(double amount) {
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: 'VND', decimalDigits: 0);
    // Customizing the format to match "20.000 VND" exactly if needed, 
    // but vi_VN usually gives "20.000 ₫". 
    // Let's manually do it for the exact string "VND".
    final numberString = NumberFormat("#,###", "vi_VN").format(amount).replaceAll(',', '.');
    return "$numberString VND";
  }
}
