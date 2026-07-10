import 'package:equatable/equatable.dart';
import 'package:kasirsuper/features/product/models/product_model.dart';

abstract class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object?> get props => [];
}

class LoadProducts extends ProductEvent {}

class AddProductEvent extends ProductEvent {
  final ProductModel product;

  const AddProductEvent(this.product);

  @override
  List<Object?> get props => [product];
}

class UpdateProductEvent extends ProductEvent {
  final ProductModel product;

  const UpdateProductEvent(this.product);

  @override
  List<Object?> get props => [product];
}

class DeleteProductEvent extends ProductEvent {
  final int id;

  const DeleteProductEvent(this.id);

  @override
  List<Object?> get props => [id];
}
