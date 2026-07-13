class StockMovementModel {
  final int? id;
  final int productId;
  final String type; // 'in', 'out', 'opname'
  final int quantity;
  final String date;
  final String notes;
  final String? productName;
  final String? productSku;

  StockMovementModel({
    this.id,
    required this.productId,
    required this.type,
    required this.quantity,
    required this.date,
    required this.notes,
    this.productName,
    this.productSku,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'product_id': productId,
      'type': type,
      'quantity': quantity,
      'date': date,
      'notes': notes,
    };
  }

  factory StockMovementModel.fromMap(Map<String, dynamic> map) {
    return StockMovementModel(
      id: map['id'],
      productId: map['product_id'],
      type: map['type'],
      quantity: map['quantity'],
      date: map['date'],
      notes: map['notes'] ?? '',
      productName: map['product_name'],
      productSku: map['product_sku'],
    );
  }
}
