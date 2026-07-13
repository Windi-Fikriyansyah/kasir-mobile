import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kasirsuper/core/database/database_helper.dart';
import 'package:kasirsuper/features/product/models/stock_movement_model.dart';

part 'stock_event.dart';
part 'stock_state.dart';

class StockBloc extends Bloc<StockEvent, StockState> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  StockBloc() : super(StockInitial()) {
    on<LoadStockHistoryEvent>(_onLoadStockHistory);
    on<AddStockInEvent>(_onAddStockIn);
    on<AddStockOpnameEvent>(_onAddStockOpname);
  }

  Future<void> _onLoadStockHistory(LoadStockHistoryEvent event, Emitter<StockState> emit) async {
    emit(StockLoading());
    try {
      final data = await _databaseHelper.getStockMovements();
      final movements = data.map((map) => StockMovementModel.fromMap(map)).toList();
      emit(StockHistoryLoaded(movements));
    } catch (e) {
      emit(StockError('Gagal memuat riwayat stok: \${e.toString()}'));
    }
  }

  Future<void> _onAddStockIn(AddStockInEvent event, Emitter<StockState> emit) async {
    emit(StockLoading());
    try {
      await _databaseHelper.insertStockMovement(
        event.productId,
        'in',
        event.quantity,
        event.notes,
      );
      emit(const StockSuccess('Stok masuk berhasil ditambahkan.'));
    } catch (e) {
      emit(StockError('Gagal menambahkan stok: \${e.toString()}'));
    }
  }

  Future<void> _onAddStockOpname(AddStockOpnameEvent event, Emitter<StockState> emit) async {
    emit(StockLoading());
    try {
      await _databaseHelper.insertStockMovement(
        event.productId,
        'opname',
        event.quantity,
        event.notes,
      );
      emit(const StockSuccess('Stok opname berhasil disimpan.'));
    } catch (e) {
      emit(StockError('Gagal menyimpan stok opname: \${e.toString()}'));
    }
  }
}
