import 'order_item_model.dart';

class OrderModel {
  final int oid;
  final double totalAmount;
  final String status;
  final String date;
  final List<OrderItemModel> items;

  OrderModel({
    required this.oid,
    required this.totalAmount,
    required this.status,
    required this.date,
    required this.items,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      oid: json['oid'],
      totalAmount: double.tryParse(json['total_amount'].toString()) ?? 0.0,
      status: json['status'] ?? 'Unknown',
      date: json['created_at']?.substring(0, 10) ?? 'N/A',
      items: (json['items'] as List)
          .map((item) => OrderItemModel.fromJson(item))
          .toList(),
    );
  }
}
