part of 'stock_bloc.dart';

abstract class StockEvent extends Equatable {
  const StockEvent();

  @override
  List<Object> get props => [];
}

class LoadStockHistoryEvent extends StockEvent {}

class AddStockInEvent extends StockEvent {
  final int productId;
  final int quantity;
  final String notes;

  const AddStockInEvent({
    required this.productId,
    required this.quantity,
    required this.notes,
  });

  @override
  List<Object> get props => [productId, quantity, notes];
}

class AddStockOpnameEvent extends StockEvent {
  final int productId;
  final int quantity; // The actual physical stock
  final String notes;

  const AddStockOpnameEvent({
    required this.productId,
    required this.quantity,
    required this.notes,
  });

  @override
  List<Object> get props => [productId, quantity, notes];
}
