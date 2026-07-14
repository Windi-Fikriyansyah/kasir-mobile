import 'package:kasirsuper/features/mechanic/models/mechanic_model.dart';
import 'package:kasirsuper/features/product/models/product_model.dart';
import 'package:kasirsuper/features/service/models/service_model.dart';

class CartItemModel {
  final ProductModel? product;
  final ServiceModel? service;
  int quantity;
  final String itemType;
  MechanicModel? assignedMechanic;

  CartItemModel({
    this.product,
    this.service,
    this.quantity = 1,
    required this.itemType,
    this.assignedMechanic,
  }) : assert(product != null || service != null);

  String get name => itemType == 'product' ? product!.name : service!.name;
  double get price => itemType == 'product' ? product!.price.toDouble() : service!.price;
  int get id => itemType == 'product' ? product!.id! : service!.id!;
  String? get sku => itemType == 'product' ? product!.sku : service!.sku;

  double get total => price * quantity;

  CartItemModel copyWith({
    ProductModel? product,
    ServiceModel? service,
    int? quantity,
    String? itemType,
    MechanicModel? assignedMechanic,
  }) {
    return CartItemModel(
      product: product ?? this.product,
      service: service ?? this.service,
      quantity: quantity ?? this.quantity,
      itemType: itemType ?? this.itemType,
      assignedMechanic: assignedMechanic ?? this.assignedMechanic,
    );
  }
}
