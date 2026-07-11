class TransactionItemModel {
  final int? id;
  final int? transactionId;
  final int productId;
  final String productName;
  final double price;
  final int quantity;

  TransactionItemModel({
    this.id,
    this.transactionId,
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      if (transactionId != null) 'transaction_id': transactionId,
      'product_id': productId,
      'product_name': productName,
      'price': price,
      'quantity': quantity,
    };
  }

  factory TransactionItemModel.fromMap(Map<String, dynamic> map) {
    return TransactionItemModel(
      id: map['id'],
      transactionId: map['transaction_id'],
      productId: map['product_id'],
      productName: map['product_name'],
      price: (map['price'] as num).toDouble(),
      quantity: map['quantity'],
    );
  }
}
