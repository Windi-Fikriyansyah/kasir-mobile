import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kasirsuper/core/theme/quickpos_colors.dart';
import 'package:kasirsuper/features/service/blocs/blocs.dart';
import 'package:kasirsuper/features/service/models/service_model.dart';

class AddServicePage extends StatefulWidget {
  final ServiceModel? service;

  const AddServicePage({super.key, this.service});

  @override
  State<AddServicePage> createState() => _AddServicePageState();
}

class _AddServicePageState extends State<AddServicePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _commissionController = TextEditingController();
  final _descriptionController = TextEditingController();

  bool get isEdit => widget.service != null;

  @override
  void initState() {
    super.initState();
    if (isEdit) {
      _nameController.text = widget.service!.name;
      _priceController.text = widget.service!.price.toInt().toString();
      _commissionController.text = widget.service!.commissionPercent.toString();
      _descriptionController.text = widget.service!.description ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _commissionController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _saveService() {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text;
      final price = double.parse(_priceController.text);
      final commissionPercent = double.tryParse(_commissionController.text) ?? 0.0;
      final description = _descriptionController.text;

      if (isEdit) {
        context.read<ServiceBloc>().add(UpdateService(
          id: widget.service!.id!,
          name: name,
          price: price,
          commissionPercent: commissionPercent,
          description: description,
        ));
      } else {
        context.read<ServiceBloc>().add(AddService(
          name: name,
          price: price,
          commissionPercent: commissionPercent,
          description: description,
        ));
      }

      Navigator.pop(context);
    }
  }

  void _deleteService() {
    if (isEdit) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Hapus Service?'),
          content: const Text('Apakah Anda yakin ingin menghapus jasa service ini?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                context.read<ServiceBloc>().add(DeleteService(widget.service!.id!));
                Navigator.pop(ctx); // Close dialog
                Navigator.pop(context); // Close page
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
        title: Text(isEdit ? 'Edit Service' : 'Tambah Service'),
        backgroundColor: Colors.white,
        foregroundColor: QuickPOSColors.onSurface,
        elevation: 0,
        actions: [
          if (isEdit)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: _deleteService,
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
                label: 'Nama Jasa Service',
                icon: Icons.handyman,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Nama tidak boleh kosong';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _priceController,
                label: 'Harga/Biaya (Rp)',
                icon: Icons.attach_money,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Harga tidak boleh kosong';
                  if (double.tryParse(value) == null) return 'Harga tidak valid';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _commissionController,
                label: 'Komisi Mekanik (%)',
                icon: Icons.percent,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _descriptionController,
                label: 'Deskripsi / Keterangan',
                icon: Icons.description,
                maxLines: 3,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saveService,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: QuickPOSColors.primary,
                  foregroundColor: QuickPOSColors.onPrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(isEdit ? 'Simpan Perubahan' : 'Simpan Service Baru'),
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
