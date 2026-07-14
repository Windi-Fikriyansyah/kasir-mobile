import 'package:flutter/material.dart';
import 'package:kasirsuper/core/core.dart';
import 'package:kasirsuper/core/theme/quickpos_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReceiptSettingsPage extends StatefulWidget {
  const ReceiptSettingsPage({super.key});

  @override
  State<ReceiptSettingsPage> createState() => _ReceiptSettingsPageState();
}

class _ReceiptSettingsPageState extends State<ReceiptSettingsPage> {
  final TextEditingController _storeNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _footerController = TextEditingController();
  
  bool _showMechanic = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    setState(() {
      _storeNameController.text = prefs.getString('receipt_store_name') ?? 'Store #4421 • Downtown Hub';
      _addressController.text = prefs.getString('receipt_store_address') ?? 'Jl. Raya Perkotaan No. 1';
      _phoneController.text = prefs.getString('receipt_store_phone') ?? '08123456789';
      _footerController.text = prefs.getString('receipt_footer') ?? 'Terima kasih telah berbelanja!';
      _showMechanic = prefs.getBool('receipt_show_mechanic') ?? true;
      _isLoading = false;
    });
  }

  Future<void> _saveSettings() async {
    setState(() {
      _isLoading = true;
    });
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('receipt_store_name', _storeNameController.text);
    await prefs.setString('receipt_store_address', _addressController.text);
    await prefs.setString('receipt_store_phone', _phoneController.text);
    await prefs.setString('receipt_footer', _footerController.text);
    await prefs.setBool('receipt_show_mechanic', _showMechanic);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pengaturan struk berhasil disimpan!'),
          backgroundColor: QuickPOSColors.secondary,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _storeNameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _footerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: QuickPOSColors.surface,
      appBar: AppBar(
        title: const Text('Atur Struk'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: QuickPOSColors.onSurface,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Informasi Toko',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: QuickPOSColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),
                  RegularTextInput(
                    controller: _storeNameController,
                    label: 'Nama Toko',
                    hintText: 'Contoh: Kios Bintang',
                  ),
                  const SizedBox(height: 16),
                  RegularTextInput(
                    controller: _addressController,
                    label: 'Alamat Toko',
                    hintText: 'Contoh: Jl. Sudirman No 123',
                  ),
                  const SizedBox(height: 16),
                  RegularTextInput(
                    controller: _phoneController,
                    label: 'Nomor Telepon',
                    hintText: 'Contoh: 081234567890',
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Pesan Penutup (Footer)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: QuickPOSColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),
                  RegularTextInput(
                    controller: _footerController,
                    label: 'Catatan Kaki',
                    hintText: 'Contoh: Terima kasih atas kunjungan Anda',
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Pengaturan Tambahan',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: QuickPOSColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: QuickPOSColors.outlineVariant),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: SwitchListTile(
                      title: const Text('Tampilkan Mekanik di Struk', style: TextStyle(fontWeight: FontWeight.w500)),
                      subtitle: const Text('Jika aktif, nama mekanik akan dicetak pada struk untuk item Jasa', style: TextStyle(fontSize: 12, color: QuickPOSColors.outline)),
                      value: _showMechanic,
                      onChanged: (val) {
                        setState(() {
                          _showMechanic = val;
                        });
                      },
                      activeColor: QuickPOSColors.primary,
                    ),
                  ),
                  const SizedBox(height: 48),
                  ElevatedButton(
                    onPressed: _saveSettings,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: QuickPOSColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Simpan Pengaturan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
