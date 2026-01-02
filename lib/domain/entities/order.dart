import 'package:equatable/equatable.dart';

class OrderItem extends Equatable {
  final String id;
  final String orderId;
  final String variantId;
  final int quantity;
  final double salePrice;
  final double costPrice;

  const OrderItem({
    required this.id,
    required this.orderId,
    required this.variantId,
    required this.quantity,
    required this.salePrice,
    required this.costPrice,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] as String,
      orderId: json['order_id'] as String,
      variantId: json['variant_id'] as String,
      quantity: (json['quantity'] as num).toInt(),
      salePrice: (json['sale_price'] as num).toDouble(),
      costPrice: (json['cost_price'] as num).toDouble(),
    );
  }

  @override
  List<Object?> get props => [
    id,
    orderId,
    variantId,
    quantity,
    salePrice,
    costPrice,
  ];
}

class Order extends Equatable {
  final String id;
  final double totalAmount;
  final double taxAmount;
  final double shippingCost;
  final String status;
  final DateTime createdAt;
  final List<OrderItem> items;
  final String customerName;
  final String customerEmail;
  final String customerPhone;
  final String deliveryAddress;
  final double deliveryCharges;

  const Order({
    required this.id,
    required this.totalAmount,
    required this.taxAmount,
    required this.shippingCost,
    required this.status,
    required this.createdAt,
    this.items = const [],
    this.customerName = 'Unknown',
    this.customerEmail = 'unknown@example.com',
    this.customerPhone = '',
    this.deliveryAddress = '',
    this.deliveryCharges = 0,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as String,
      totalAmount: (json['total_amount'] as num).toDouble(),
      taxAmount: (json['tax_amount'] as num).toDouble(),
      shippingCost: (json['shipping_cost'] as num).toDouble(),
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      customerName: json['customer_name'] as String? ?? 'Unknown',
      customerEmail: json['customer_email'] as String? ?? 'unknown@example.com',
      customerPhone: json['customer_phone'] as String? ?? '',
      deliveryAddress: json['delivery_address'] as String? ?? '',
      deliveryCharges: (json['delivery_charges'] as num?)?.toDouble() ?? 0,
      items:
          (json['order_items'] as List<dynamic>?)
              ?.map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'total_amount': totalAmount,
      'tax_amount': taxAmount,
      'shipping_cost': shippingCost,
      'delivery_charges': deliveryCharges,
      'status': status,
      'customer_name': customerName,
      'customer_email': customerEmail,
      'customer_phone': customerPhone,
      'delivery_address': deliveryAddress,
    };
  }

  @override
  List<Object?> get props => [
    id,
    totalAmount,
    taxAmount,
    shippingCost,
    status,
    createdAt,
    items,
    customerName,
    customerEmail,
    customerPhone,
    deliveryAddress,
    deliveryCharges,
  ];
}
