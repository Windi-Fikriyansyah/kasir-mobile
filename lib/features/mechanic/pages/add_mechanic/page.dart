import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kasirsuper/core/theme/quickpos_colors.dart';
import 'package:kasirsuper/features/mechanic/blocs/blocs.dart';
import 'package:kasirsuper/features/mechanic/models/mechanic_model.dart';

class AddMechanicPage extends StatefulWidget {
  final MechanicModel? mechanic;

  const AddMechanicPage({super.key, this.mechanic});

  @override
  State<AddMechanicPage> createState() => _AddMechanicPageState();
}

class _AddMechanicPageState extends State<AddMechanicPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _skillsController = TextEditingController();

  bool get isEdit => widget.mechanic != null;

  @override
  void initState() {
    super.initState();
    if (isEdit) {
      _nameController.text = widget.mechanic!.name;
      _phoneController.text = widget.mechanic!.phone ?? '';
      _addressController.text = widget.mechanic!.address ?? '';
      _skillsController.text = widget.mechanic!.skills ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _skillsController.dispose();
    super.dispose();
  }

  void _saveMechanic() {
    if (_formKey.currentState!.validate()) {
      final mechanic = MechanicModel(
        id: widget.mechanic?.id,
        name: _nameController.text,
        phone: _phoneController.text.isNotEmpty ? _phoneController.text : null,
        address: _addressController.text.isNotEmpty ? _addressController.text : null,
        skills: _skillsController.text.isNotEmpty ? _skillsController.text : null,
      );

      if (isEdit) {
        context.read<MechanicBloc>().add(UpdateMechanic(mechanic));
      } else {
        context.read<MechanicBloc>().add(AddMechanic(mechanic));
      }

      Navigator.pop(context);
    }
  }

  void _deleteMechanic() {
    if (isEdit) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Hapus Mekanik?'),
          content: const Text('Apakah Anda yakin ingin menghapus mekanik ini?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                context.read<MechanicBloc>().add(DeleteMechanic(widget.mechanic!.id!));
                Navigator.pop(ctx);
                Navigator.pop(context);
              },
              child: const Text('Hapus', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: QuickPOSColors.surface,
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Mekanik' : 'Tambah Mekanik'),
        backgroundColor: Colors.white,
        foregroundColor: QuickPOSColors.onSurface,
        elevation: 0,
        actions: [
          if (isEdit)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: _deleteMechanic,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTextField(
                controller: _nameController,
                label: 'Nama Mekanik',
                icon: Icons.person,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nama tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _phoneController,
                label: 'Nomor Telepon',
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _addressController,
                label: 'Alamat',
                icon: Icons.home,
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _skillsController,
                label: 'Keahlian (Contoh: Mesin, Kelistrikan)',
                icon: Icons.build,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saveMechanic,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: QuickPOSColors.primary,
                  foregroundColor: QuickPOSColors.onPrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(isEdit ? 'Simpan Perubahan' : 'Simpan Mekanik Baru'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: QuickPOSColors.outline),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: QuickPOSColors.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: QuickPOSColors.outlineVariant),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}
