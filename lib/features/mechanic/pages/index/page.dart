import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kasirsuper/core/theme/quickpos_colors.dart';
import 'package:kasirsuper/features/mechanic/blocs/blocs.dart';
import 'package:kasirsuper/features/mechanic/models/mechanic_model.dart';
import 'package:kasirsuper/features/mechanic/pages/add_mechanic/page.dart';

class MechanicListPage extends StatefulWidget {
  const MechanicListPage({super.key});

  @override
  State<MechanicListPage> createState() => _MechanicListPageState();
}

class _MechanicListPageState extends State<MechanicListPage> {
  @override
  void initState() {
    super.initState();
    context.read<MechanicBloc>().add(LoadMechanics());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: QuickPOSColors.surface,
      appBar: AppBar(
        title: const Text('Daftar Mekanik'),
        backgroundColor: Colors.white,
        foregroundColor: QuickPOSColors.onSurface,
        elevation: 0,
      ),
      body: BlocBuilder<MechanicBloc, MechanicState>(
        builder: (context, state) {
          if (state is MechanicLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is MechanicLoaded) {
            final mechanics = state.mechanics;
            
            if (mechanics.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.engineering, size: 80, color: QuickPOSColors.outline),
                    const SizedBox(height: 16),
                    const Text('Belum ada data mekanik', style: TextStyle(color: QuickPOSColors.onSurfaceVariant)),
                  ],
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: mechanics.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final mechanic = mechanics[index];
                return _buildMechanicItem(context, mechanic);
              },
            );
          } else if (state is MechanicError) {
            return Center(child: Text(state.message));
          }
          return const SizedBox();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddMechanicPage()),
          );
        },
        backgroundColor: QuickPOSColors.primary,
        icon: const Icon(Icons.add),
        label: const Text('Tambah Mekanik'),
      ),
    );
  }

  Widget _buildMechanicItem(BuildContext context, MechanicModel mechanic) {
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
            color: QuickPOSColors.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.engineering, color: QuickPOSColors.primary),
        ),
        title: Text(
          mechanic.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          mechanic.skills ?? 'Mekanik',
          style: const TextStyle(color: QuickPOSColors.onSurfaceVariant),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: const Icon(Icons.chevron_right, color: QuickPOSColors.outline),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddMechanicPage(mechanic: mechanic),
            ),
          );
        },
      ),
    );
  }
}
