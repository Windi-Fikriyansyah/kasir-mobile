part of 'stock_bloc.dart';

abstract class StockState extends Equatable {
  const StockState();
  
  @override
  List<Object> get props => [];
}

class StockInitial extends StockState {}

class StockLoading extends StockState {}

class StockHistoryLoaded extends StockState {
  final List<StockMovementModel> movements;

  const StockHistoryLoaded(this.movements);

  @override
  List<Object> get props => [movements];
}

class StockSuccess extends StockState {
  final String message;

  const StockSuccess(this.message);

  @override
  List<Object> get props => [message];
}

class StockError extends StockState {
  final String message;

  const StockError(this.message);

  @override
  List<Object> get props => [message];
}
