import 'product_model.dart';

class OrderItemModel {
  final int tid;
  final int orderId;
  final int productId;
  final int quantity;
  final double price;
  final ProductModel product;

  OrderItemModel({
    required this.tid,
    required this.orderId,
    required this.productId,
    required this.quantity,
    required this.price,
    required this.product,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      tid: json['tid'],
      orderId: json['order_id'],
      productId: json['product_id'],
      quantity: json['quantity'],
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      product: ProductModel.fromJson(json['product']),
    );
  }
}