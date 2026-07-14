abstract class ServiceEvent {}

class LoadServices extends ServiceEvent {}

class AddService extends ServiceEvent {
  final String name;
  final String? sku;
  final double price;
  final double commissionPercent;
  final String? description;

  AddService({
    required this.name,
    this.sku,
    required this.price,
    this.commissionPercent = 0.0,
    this.description,
  });
}

class UpdateService extends ServiceEvent {
  final int id;
  final String name;
  final String? sku;
  final double price;
  final double commissionPercent;
  final String? description;

  UpdateService({
    required this.id,
    required this.name,
    this.sku,
    required this.price,
    this.commissionPercent = 0.0,
    this.description,
  });
}

class DeleteService extends ServiceEvent {
  final int id;
  DeleteService(this.id);
}
