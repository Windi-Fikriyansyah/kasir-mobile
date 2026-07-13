import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:kasirsuper/core/theme/quickpos_colors.dart';
import 'package:kasirsuper/features/service/blocs/blocs.dart';
import 'package:kasirsuper/features/service/models/service_model.dart';
import 'package:kasirsuper/features/service/pages/add_service/page.dart';

class ServiceListPage extends StatefulWidget {
  const ServiceListPage({super.key});

  @override
  State<ServiceListPage> createState() => _ServiceListPageState();
}

class _ServiceListPageState extends State<ServiceListPage> {
  @override
  void initState() {
    super.initState();
    context.read<ServiceBloc>().add(LoadServices());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: QuickPOSColors.surface,
      appBar: AppBar(
        title: const Text('Daftar Service'),
        backgroundColor: Colors.white,
        foregroundColor: QuickPOSColors.onSurface,
        elevation: 0,
      ),
      body: BlocBuilder<ServiceBloc, ServiceState>(
        builder: (context, state) {
          if (state is ServiceLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ServiceLoaded) {
            final services = state.services;
            
            if (services.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.handyman, size: 80, color: QuickPOSColors.outline),
                    const SizedBox(height: 16),
                    const Text('Belum ada jasa service', style: TextStyle(color: QuickPOSColors.onSurfaceVariant)),
                  ],
                ),
              );
            }

            final formatCurrency = NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: services.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final service = services[index];
                return _buildServiceItem(context, service, formatCurrency);
              },
            );
          } else if (state is ServiceError) {
            return Center(child: Text(state.message));
          }
          return const SizedBox();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddServicePage()),
          );
        },
        backgroundColor: QuickPOSColors.primary,
        icon: const Icon(Icons.add),
        label: const Text('Tambah Service'),
      ),
    );
  }

  Widget _buildServiceItem(BuildContext context, ServiceModel service, NumberFormat formatCurrency) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: QuickPOSColors.outlineVariant.withOpacity(0.5)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: QuickPOSColors.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.build_circle, color: QuickPOSColors.primary),
        ),
        title: Text(
          service.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          service.description ?? 'Jasa service',
          style: const TextStyle(color: QuickPOSColors.onSurfaceVariant),
        ),
        trailing: Text(
          formatCurrency.format(service.price),
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: QuickPOSColors.secondary,
            fontSize: 16,
          ),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddServicePage(service: service),
            ),
          );
        },
      ),
    );
  }
}
