import 'package:flutter/material.dart';

class Order {
  final int? id;
  final int? userId;
  final int? companyId;
  final int? partyId;
  final int? supplierId;
  final int? transportId;
  final int? agentId;
  final String? orderNumber;
  final DateTime? orderDate;
  final String? deliveryAddress;
  final String? paymentStatus;
  final String? discount;
  final String? subtotal;
  final String? taxAmount;
  final String? grandTotal;
  final bool? status;
  final IconData? icon;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<OrderItem>? items;

  Order({
    this.id,
    this.userId,
    this.companyId,
    this.partyId,
    this.supplierId,
    this.transportId,
    this.agentId,
    this.orderNumber,
    this.orderDate,
    this.deliveryAddress,
    this.paymentStatus,
    this.discount,
    this.subtotal,
    this.taxAmount,
    this.grandTotal,
    this.status,
    this.icon,
    this.createdAt,
    this.updatedAt,
    this.items,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      userId: json['user_id'],
      companyId: json['company_id'],
      partyId: json['party_id'],
      supplierId: json['supplier_id'],
      transportId: json['transport_id'],
      agentId: json['agent_id'],
      orderNumber: json['order_number'],
      orderDate: json['order_date'] != null ? DateTime.tryParse(json['order_date']) : null,
      deliveryAddress: json['delivery_address'] ?? 'N/A',
      paymentStatus: json['payment_status'] ?? 'Unknown',
      discount: json['discount'] ?? '0.00',
      subtotal: json['subtotal'] ?? '0.00',
      taxAmount: json['tax_amount'] ?? '0.00',
      grandTotal: json['grand_total'] ?? '0.00',
      status: json['status'],
      icon: json['icon'] != null ? _getIconData(json['icon']) : Icons.shopping_cart,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at']) : null,
      items: json['items'] != null
          ? (json['items'] as List).map((item) => OrderItem.fromJson(item)).toList()
          : [],
    );
  }

  static IconData _getIconData(dynamic iconData) {
    // Default to Icons.shopping_cart if icon data is not available
    if (iconData == null) return Icons.shopping_cart;
    return Icons.shopping_cart; // Default, as icon is null in JSON
  }
}

class OrderItem {
  final int? id;
  final int? orderId;
  final int? itemId;
  final String? itemName;
  final int? quantity;
  final double? price;
  final double? weight;
  final String? unit;
  final String? description1;
  final String? description2;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  OrderItem({
    this.id,
    this.orderId,
    this.itemId,
    this.itemName,
    this.quantity,
    this.price,
    this.weight,
    this.unit,
    this.description1,
    this.description2,
    this.createdAt,
    this.updatedAt,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'],
      orderId: json['order_id'],
      itemId: json['item_id'],
      itemName: json['item_name'] ?? 'N/A',
      quantity: json['quantity'] ?? 0,
      price: (json['price'] is int) ? (json['price'] as int).toDouble() : (json['price'] ?? 0.0),
      weight: (json['weight'] is int) ? (json['weight'] as int).toDouble() : (json['weight'] ?? 0.0),
      unit: json['unit'] ?? 'N/A',
      description1: json['description_1'] ?? 'N/A',
      description2: json['description_2'] ?? 'N/A',
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }
}
