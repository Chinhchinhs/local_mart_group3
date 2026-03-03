import 'package:flutter_test/flutter_test.dart';
import 'package:local_mart/main.dart';

void main() {
  testWidgets('Kiem tra man hinh gio hang khoi dong thanh cong', (WidgetTester tester) async {
    // Bơm ứng dụng LocalMartApp để vào để test
    await tester.pumpWidget(const LocalMartApp());

    // Kiểm tra xem trên màn hình có xuất hiện dòng chữ này không
    expect(find.text('Giỏ hàng LocalMart'), findsOneWidget);
  });
}