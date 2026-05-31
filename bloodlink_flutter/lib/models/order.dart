import 'product.dart';

class OrderItem {
  final int id;
  final Product product;
  final int quantity;
  final double totalPrice;
  OrderItem({
    required this.id,
    required this.product,
    required this.quantity,
    required this.totalPrice,
  });
  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'],
      product: Product.fromJson(json['product']),
      quantity: json['quantity'],
      totalPrice: (json['total_price'] as num).toDouble(),
    );
  }
}

class Order {
  final int id;
  final DateTime dateOrdered;
  final bool complete;
  final String status;
  final double totalPrice;
  final int totalItems;
  final List<OrderItem> items;
  Order({
    required this.id,
    required this.dateOrdered,
    required this.complete,
    required this.status,
    required this.totalPrice,
    required this.totalItems,
    required this.items,
  });
  factory Order.fromJson(Map<String, dynamic> json) {
    var itemsList = json['order_items'] as List;
    return Order(
      id: json['id'],
      dateOrdered: DateTime.parse(json['date_ordered']),
      complete: json['complete'],
      status: json['status'],
      totalPrice: (json['total_price'] as num).toDouble(),
      totalItems: json['total_items'],
      items: itemsList.map((i) => OrderItem.fromJson(i)).toList(),
    );
  }
}
