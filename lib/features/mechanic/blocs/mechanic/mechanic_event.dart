import 'package:equatable/equatable.dart';
import 'package:kasirsuper/features/mechanic/models/mechanic_model.dart';

abstract class MechanicEvent extends Equatable {
  const MechanicEvent();

  @override
  List<Object> get props => [];
}

class LoadMechanics extends MechanicEvent {}

class AddMechanic extends MechanicEvent {
  final MechanicModel mechanic;

  const AddMechanic(this.mechanic);

  @override
  List<Object> get props => [mechanic];
}

class UpdateMechanic extends MechanicEvent {
  final MechanicModel mechanic;

  const UpdateMechanic(this.mechanic);

  @override
  List<Object> get props => [mechanic];
}

class DeleteMechanic extends MechanicEvent {
  final int id;

  const DeleteMechanic(this.id);

  @override
  List<Object> get props => [id];
}
