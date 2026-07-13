class ProductModel {
  final int? id;
  final String name;
  final String sku;
  final String category;
  final int price;
  final int cost;
  final int stock;
  final int minStock;
  final String? imagePath;
  final String? sparepartCode;

  ProductModel({
    this.id,
    required this.name,
    required this.sku,
    required this.category,
    required this.price,
    required this.cost,
    required this.stock,
    required this.minStock,
    this.imagePath,
    this.sparepartCode,
  });

  ProductModel copyWith({
    int? id,
    String? name,
    String? sku,
    String? category,
    int? price,
    int? cost,
    int? stock,
    int? minStock,
    String? imagePath,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      sku: sku ?? this.sku,
      category: category ?? this.category,
      price: price ?? this.price,
      cost: cost ?? this.cost,
      stock: stock ?? this.stock,
      minStock: minStock ?? this.minStock,
      imagePath: imagePath ?? this.imagePath,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'sku': sku,
      'category': category,
      'price': price,
      'cost': cost,
      'stock': stock,
      'minStock': minStock,
      'imagePath': imagePath,
      'sparepart_code': sparepartCode,
    };
  }

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id']?.toInt(),
      name: map['name'] ?? '',
      sku: map['sku'] ?? '',
      category: map['category'] ?? '',
      price: map['price']?.toInt() ?? 0,
      cost: map['cost']?.toInt() ?? 0,
      stock: map['stock']?.toInt() ?? 0,
      minStock: map['minStock']?.toInt() ?? 0,
      imagePath: map['imagePath'],
      sparepartCode: map['sparepart_code'],
    );
  }
}
