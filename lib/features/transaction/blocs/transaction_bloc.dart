import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:kasirsuper/core/database/database_helper.dart';
import 'package:kasirsuper/features/transaction/models/transaction_model.dart';

// --- Events ---
abstract class TransactionEvent extends Equatable {
  const TransactionEvent();
  @override
  List<Object?> get props => [];
}

class SaveTransaction extends TransactionEvent {
  final TransactionModel transaction;
  const SaveTransaction(this.transaction);
  @override
  List<Object?> get props => [transaction];
}

class LoadTransactions extends TransactionEvent {}

// --- State ---
abstract class TransactionState extends Equatable {
  const TransactionState();
  @override
  List<Object?> get props => [];
}

class TransactionInitial extends TransactionState {}
class TransactionLoading extends TransactionState {}
class TransactionLoaded extends TransactionState {
  // Can be extended if we load transactions history
  final List<TransactionModel> transactions;
  const TransactionLoaded(this.transactions);
  @override
  List<Object?> get props => [transactions];
}
class TransactionSuccess extends TransactionState {}
class TransactionError extends TransactionState {
  final String message;
  const TransactionError(this.message);
  @override
  List<Object?> get props => [message];
}

// --- BLoC ---
class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final DatabaseHelper databaseHelper;

  TransactionBloc({required this.databaseHelper}) : super(TransactionInitial()) {
    on<SaveTransaction>(_onSaveTransaction);
    on<LoadTransactions>(_onLoadTransactions);
  }

  Future<void> _onSaveTransaction(SaveTransaction event, Emitter<TransactionState> emit) async {
    emit(TransactionLoading());
    try {
      await databaseHelper.insertTransaction(event.transaction);
      emit(TransactionSuccess());
    } catch (e) {
      emit(TransactionError('Gagal menyimpan transaksi: $e'));
    }
  }

  Future<void> _onLoadTransactions(LoadTransactions event, Emitter<TransactionState> emit) async {
    emit(TransactionLoading());
    try {
      final transactions = await databaseHelper.getAllTransactions();
      emit(TransactionLoaded(transactions));
    } catch (e) {
      emit(TransactionError('Gagal memuat transaksi: $e'));
    }
  }
}
