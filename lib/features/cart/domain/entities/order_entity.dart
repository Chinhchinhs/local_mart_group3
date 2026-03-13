import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'cart_item_entity.dart';

class OrderEntity extends Equatable {
  final String orderId;
  final String userId;
  final List<CartItemEntity> items;
  final double totalPrice;
  final DateTime orderDate;
  final String? voucherCode; // THÊM
  final String? shipperNote; // THÊM

  const OrderEntity({
    required this.orderId,
    required this.userId,
    required this.items,
    required this.totalPrice,
    required this.orderDate,
    this.voucherCode,
    this.shipperNote,
  });

  @override
  List<Object?> get props => [orderId, userId, items, totalPrice, orderDate, voucherCode, shipperNote];

  Map<String, dynamic> toMap() {
    return {
      'orderId': orderId,
      'userId': userId,
      'itemsJson': jsonEncode(items.map((x) => x.toMap()).toList()),
      'totalPrice': totalPrice,
      'orderDate': orderDate.toIso8601String(),
      'voucherCode': voucherCode,
      'shipperNote': shipperNote,
    };
  }

  factory OrderEntity.fromMap(Map<String, dynamic> map) {
    final List<dynamic> itemsList = jsonDecode(map['itemsJson']);
    return OrderEntity(
      orderId: map['orderId'],
      userId: map['userId'],
      items: itemsList.map((x) => CartItemEntity.fromMap(x)).toList(),
      totalPrice: map['totalPrice'],
      orderDate: DateTime.parse(map['orderDate']),
      voucherCode: map['voucherCode'],
      shipperNote: map['shipperNote'],
    );
  }
}
