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

class AddItemToCart extends PosEvent {
  final CartItemModel item;
  const AddItemToCart(this.item);
  @override
  List<Object?> get props => [item];
}

class RemoveItemFromCart extends PosEvent {
  final CartItemModel item;
  const RemoveItemFromCart(this.item);
  @override
  List<Object?> get props => [item];
}

class DeleteItemFromCart extends PosEvent {
  final CartItemModel item;
  const DeleteItemFromCart(this.item);
  @override
  List<Object?> get props => [item];
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
    on<AddItemToCart>(_onAddItem);
    on<RemoveItemFromCart>(_onRemoveItem);
    on<DeleteItemFromCart>(_onDeleteItem);
    on<ClearCart>(_onClearCart);
  }

  void _onAddItem(AddItemToCart event, Emitter<PosState> emit) {
    final updatedItems = List<CartItemModel>.from(state.items);
    final existingIndex = updatedItems.indexWhere((i) => i.id == event.item.id && i.itemType == event.item.itemType);

    if (existingIndex >= 0) {
      final existingItem = updatedItems[existingIndex];
      // Check stock if product
      if (existingItem.itemType == 'product') {
        if (existingItem.quantity < existingItem.product!.stock) {
          updatedItems[existingIndex] = existingItem.copyWith(quantity: existingItem.quantity + 1);
        }
      } else {
        // Services have unlimited stock
        updatedItems[existingIndex] = existingItem.copyWith(quantity: existingItem.quantity + 1);
      }
    } else {
      if (event.item.itemType == 'product' && event.item.product!.stock <= 0) {
        // Cannot add out of stock product
      } else {
        updatedItems.add(event.item);
      }
    }

    emit(state.copyWith(items: updatedItems));
  }

  void _onRemoveItem(RemoveItemFromCart event, Emitter<PosState> emit) {
    final updatedItems = List<CartItemModel>.from(state.items);
    final existingIndex = updatedItems.indexWhere((i) => i.id == event.item.id && i.itemType == event.item.itemType);

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

  void _onDeleteItem(DeleteItemFromCart event, Emitter<PosState> emit) {
    final updatedItems = List<CartItemModel>.from(state.items);
    updatedItems.removeWhere((i) => i.id == event.item.id && i.itemType == event.item.itemType);
    emit(state.copyWith(items: updatedItems));
  }

  void _onClearCart(ClearCart event, Emitter<PosState> emit) {
    emit(const PosState());
  }
}
