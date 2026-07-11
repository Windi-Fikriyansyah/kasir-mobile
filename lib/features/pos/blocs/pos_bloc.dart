import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:kasirsuper/features/pos/models/cart_item_model.dart';
import 'package:kasirsuper/features/product/models/product_model.dart';

// --- Events ---
abstract class PosEvent extends Equatable {
  const PosEvent();
  @override
  List<Object?> get props => [];
}

class AddProductToCart extends PosEvent {
  final ProductModel product;
  const AddProductToCart(this.product);
  @override
  List<Object?> get props => [product];
}

class RemoveProductFromCart extends PosEvent {
  final ProductModel product;
  const RemoveProductFromCart(this.product);
  @override
  List<Object?> get props => [product];
}

class DeleteProductFromCart extends PosEvent {
  final ProductModel product;
  const DeleteProductFromCart(this.product);
  @override
  List<Object?> get props => [product];
}

class ClearCart extends PosEvent {}

// --- State ---
class PosState extends Equatable {
  final List<CartItemModel> items;

  const PosState({this.items = const []});

  int get totalQuantity => items.fold(0, (sum, item) => sum + item.quantity);
  double get totalAmount => items.fold(0, (sum, item) => sum + item.total);

  PosState copyWith({List<CartItemModel>? items}) {
    return PosState(items: items ?? this.items);
  }

  @override
  List<Object?> get props => [items];
}

// --- BLoC ---
class PosBloc extends Bloc<PosEvent, PosState> {
  PosBloc() : super(const PosState()) {
    on<AddProductToCart>(_onAddProduct);
    on<RemoveProductFromCart>(_onRemoveProduct);
    on<DeleteProductFromCart>(_onDeleteProduct);
    on<ClearCart>(_onClearCart);
  }

  void _onAddProduct(AddProductToCart event, Emitter<PosState> emit) {
    final updatedItems = List<CartItemModel>.from(state.items);
    final existingIndex = updatedItems.indexWhere((item) => item.product.id == event.product.id);

    if (existingIndex >= 0) {
      final existingItem = updatedItems[existingIndex];
      // Check stock
      if (existingItem.quantity < event.product.stock) {
        updatedItems[existingIndex] = existingItem.copyWith(quantity: existingItem.quantity + 1);
      }
    } else {
      if (event.product.stock > 0) {
        updatedItems.add(CartItemModel(product: event.product));
      }
    }

    emit(state.copyWith(items: updatedItems));
  }

  void _onRemoveProduct(RemoveProductFromCart event, Emitter<PosState> emit) {
    final updatedItems = List<CartItemModel>.from(state.items);
    final existingIndex = updatedItems.indexWhere((item) => item.product.id == event.product.id);

    if (existingIndex >= 0) {
      final existingItem = updatedItems[existingIndex];
      if (existingItem.quantity > 1) {
        updatedItems[existingIndex] = existingItem.copyWith(quantity: existingItem.quantity - 1);
      } else {
        updatedItems.removeAt(existingIndex);
      }
      emit(state.copyWith(items: updatedItems));
    }
  }

  void _onDeleteProduct(DeleteProductFromCart event, Emitter<PosState> emit) {
    final updatedItems = List<CartItemModel>.from(state.items);
    updatedItems.removeWhere((item) => item.product.id == event.product.id);
    emit(state.copyWith(items: updatedItems));
  }

  void _onClearCart(ClearCart event, Emitter<PosState> emit) {
    emit(const PosState());
  }
}
