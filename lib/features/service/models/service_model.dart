class ServiceModel {
  final int? id;
  final String name;
  final String? sku; // Optional for services, can act as a code
  final String category;
  final double price;
  final String? description;

  ServiceModel({
    this.id,
    required this.name,
    this.sku,
    this.category = 'Service',
    required this.price,
    this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'sku': sku,
      'category': category,
      'price': price,
      'description': description,
    };
  }

  factory ServiceModel.fromMap(Map<String, dynamic> map) {
    return ServiceModel(
      id: map['id'],
      name: map['name'],
      sku: map['sku'],
      category: map['category'] ?? 'Service',
      price: (map['price'] ?? 0).toDouble(),
      description: map['description'],
    );
  }

  ServiceModel copyWith({
    int? id,
    String? name,
    String? sku,
    String? category,
    double? price,
    String? description,
  }) {
    return ServiceModel(
      id: id ?? this.id,
      name: name ?? this.name,
      sku: sku ?? this.sku,
      category: category ?? this.category,
      price: price ?? this.price,
      description: description ?? this.description,
    );
  }
}
