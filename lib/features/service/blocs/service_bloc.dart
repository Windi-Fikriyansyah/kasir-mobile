import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kasirsuper/core/database/database_helper.dart';
import '../models/service_model.dart';
import 'service_event.dart';
import 'service_state.dart';

class ServiceBloc extends Bloc<ServiceEvent, ServiceState> {
  final DatabaseHelper dbHelper;

  ServiceBloc({required this.dbHelper}) : super(ServiceInitial()) {
    on<LoadServices>((event, emit) async {
      emit(ServiceLoading());
      try {
        final services = await dbHelper.getServices();
        emit(ServiceLoaded(services));
      } catch (e) {
        emit(ServiceError(e.toString()));
      }
    });

    on<AddService>((event, emit) async {
      try {
        final service = ServiceModel(
          name: event.name,
          sku: event.sku,
          price: event.price,
          description: event.description,
        );
        await dbHelper.insertService(service);
        add(LoadServices());
      } catch (e) {
        emit(ServiceError(e.toString()));
      }
    });

    on<UpdateService>((event, emit) async {
      try {
        final service = ServiceModel(
          id: event.id,
          name: event.name,
          sku: event.sku,
          price: event.price,
          description: event.description,
        );
        await dbHelper.updateService(service);
        add(LoadServices());
      } catch (e) {
        emit(ServiceError(e.toString()));
      }
    });

    on<DeleteService>((event, emit) async {
      try {
        await dbHelper.deleteService(event.id);
        add(LoadServices());
      } catch (e) {
        emit(ServiceError(e.toString()));
      }
    });
  }
}
