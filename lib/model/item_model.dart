class Item {
  final int? id;
  final String name;
  final String? price;
  final String? weight;
  final int? quantity;
  final String? unit;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Item({
    this.id,
    required this.name,
    this.price,
    this.weight,
    this.quantity,
    this.unit,
    this.createdAt,
    this.updatedAt,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'] as int?,
      name: json['name'] as String,
      price: json['price']?.toString(),
      weight: json['weight']?.toString(),
      quantity: json['quantity'] as int?,
      unit: json['unit'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  // For sending data to the backend (create/update)
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'price': price,
      'weight': weight,
      'quantity': quantity,
      'unit': unit,
    };
  }
}
