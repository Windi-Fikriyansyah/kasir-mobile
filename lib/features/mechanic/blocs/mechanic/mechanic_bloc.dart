import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kasirsuper/core/database/database_helper.dart';
import 'package:kasirsuper/features/mechanic/blocs/mechanic/mechanic_event.dart';
import 'package:kasirsuper/features/mechanic/blocs/mechanic/mechanic_state.dart';

class MechanicBloc extends Bloc<MechanicEvent, MechanicState> {
  final DatabaseHelper dbHelper;

  MechanicBloc({required this.dbHelper}) : super(MechanicInitial()) {
    on<LoadMechanics>(_onLoadMechanics);
    on<AddMechanic>(_onAddMechanic);
    on<UpdateMechanic>(_onUpdateMechanic);
    on<DeleteMechanic>(_onDeleteMechanic);
  }

  Future<void> _onLoadMechanics(LoadMechanics event, Emitter<MechanicState> emit) async {
    emit(MechanicLoading());
    try {
      final mechanics = await dbHelper.getMechanics();
      emit(MechanicLoaded(mechanics));
    } catch (e) {
      emit(MechanicError('Failed to load mechanics: ${e.toString()}'));
    }
  }

  Future<void> _onAddMechanic(AddMechanic event, Emitter<MechanicState> emit) async {
    try {
      await dbHelper.insertMechanic(event.mechanic);
      add(LoadMechanics());
    } catch (e) {
      emit(MechanicError('Failed to add mechanic: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateMechanic(UpdateMechanic event, Emitter<MechanicState> emit) async {
    try {
      await dbHelper.updateMechanic(event.mechanic);
      add(LoadMechanics());
    } catch (e) {
      emit(MechanicError('Failed to update mechanic: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteMechanic(DeleteMechanic event, Emitter<MechanicState> emit) async {
    try {
      await dbHelper.deleteMechanic(event.id);
      add(LoadMechanics());
    } catch (e) {
      emit(MechanicError('Failed to delete mechanic: ${e.toString()}'));
    }
  }
}
