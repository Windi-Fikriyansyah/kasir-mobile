import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kasirsuper/core/theme/quickpos_colors.dart';
import 'package:kasirsuper/features/product/blocs/blocs.dart';
import 'package:kasirsuper/features/product/models/product_model.dart';
import 'package:kasirsuper/features/pos/pages/scanner/page.dart';

class AddProductPage extends StatefulWidget {
  final ProductModel? product;
  const AddProductPage({super.key, this.product});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _skuController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _costController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();
  final TextEditingController _minStockController = TextEditingController(text: '5');
  String? _selectedCategory;

  bool _isSaving = false;
  File? _imageFile;
  String? _existingImageUrl;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _nameController.text = widget.product!.name;
      _skuController.text = widget.product!.sku;
      _priceController.text = widget.product!.price.toString();
      _costController.text = widget.product!.cost.toString();
      _stockController.text = widget.product!.stock.toString();
      _minStockController.text = widget.product!.minStock.toString();
      
      // Ensure the selected category matches one of the items.
      final validCategories = ['Makanan', 'Minuman', 'Elektronik', 'Fashion', 'Aksesoris', 'Peralatan Rumah', 'Pakaian', 'Lainnya'];
      if (validCategories.contains(widget.product!.category)) {
        _selectedCategory = widget.product!.category;
      }

      if (widget.product!.imagePath != null) {
        if (widget.product!.imagePath!.startsWith('http')) {
          _existingImageUrl = widget.product!.imagePath;
        } else {
          _imageFile = File(widget.product!.imagePath!);
        }
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _skuController.dispose();
    _priceController.dispose();
    _costController.dispose();
    _stockController.dispose();
    _minStockController.dispose();
    super.dispose();
  }

  void _saveProduct() async {
    setState(() {
      _isSaving = true;
    });
    
    final product = ProductModel(
      id: widget.product?.id,
      name: _nameController.text,
      sku: _skuController.text,
      category: _selectedCategory ?? 'Lainnya',
      price: int.tryParse(_priceController.text) ?? 0,
      cost: int.tryParse(_costController.text) ?? 0,
      stock: int.tryParse(_stockController.text) ?? 0,
      minStock: int.tryParse(_minStockController.text) ?? 0,
      imagePath: _imageFile != null ? _imageFile!.path : _existingImageUrl,
    );

    if (widget.product == null) {
      context.read<ProductBloc>().add(AddProductEvent(product));
    } else {
      context.read<ProductBloc>().add(UpdateProductEvent(product));
    }

    // Simulate short network delay for UI
    await Future.delayed(const Duration(milliseconds: 600));

    if (!mounted) return;
    
    setState(() {
      _isSaving = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: const [
            Icon(Icons.check_circle, color: QuickPOSColors.onSecondary),
            SizedBox(width: 8),
            Text('Produk berhasil disimpan'),
          ],
        ),
        backgroundColor: QuickPOSColors.secondary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );

    Navigator.pop(context);
  }

  Future<void> _showImageSourceActionSheet() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: QuickPOSColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Buka Kamera'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Pilih dari Galeri'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
          _existingImageUrl = null;
        });
      }
    } catch (e) {
      // ignore
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _AddProductAppBar(isEdit: widget.product != null),
            Expanded(
              child: Container(
                color: QuickPOSColors.surface,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildImageUpload(),
                    const SizedBox(height: 24),
                    _buildBasicInfoCard(),
                    const SizedBox(height: 24),
                    _buildPricingCard(),
                    const SizedBox(height: 24),
                    _buildInventoryCard(),
                    const SizedBox(height: 32), // space for bottom padding
                  ],
                ),
              ),
            ),
            ),
            _buildBottomActionBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildImageUpload() {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: QuickPOSColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: QuickPOSColors.outlineVariant,
          style: BorderStyle.solid,
        ),
        image: _imageFile != null
            ? DecorationImage(
                image: FileImage(_imageFile!),
                fit: BoxFit.cover,
              )
            : (_existingImageUrl != null
                ? DecorationImage(
                    image: NetworkImage(_existingImageUrl!),
                    fit: BoxFit.cover,
                  )
                : null),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _showImageSourceActionSheet,
          borderRadius: BorderRadius.circular(12),
          child: (_imageFile == null && _existingImageUrl == null)
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.add_a_photo, size: 40, color: QuickPOSColors.onSurfaceVariant),
                    SizedBox(height: 8),
                    Text(
                      'Unggah Foto Produk',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: QuickPOSColors.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Format JPG, PNG (Maks. 2MB)',
                      style: TextStyle(
                        fontSize: 12,
                        color: QuickPOSColors.outline,
                      ),
                    ),
                  ],
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildBasicInfoCard() {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextFieldLabel('Nama Produk'),
          _buildTextField(
            controller: _nameController,
            hintText: 'Contoh: Kopi Gayo 250g',
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTextFieldLabel('SKU / Barcode'),
                    _buildTextField(
                      controller: _skuController,
                      hintText: '001-923',
                      suffixWidget: IconButton(
                        icon: const Icon(Icons.qr_code_scanner, color: QuickPOSColors.onSurfaceVariant),
                        onPressed: () async {
                          final sku = await Navigator.push<String>(
                            context,
                            MaterialPageRoute(builder: (context) => const ScannerPage(returnSkuOnly: true)),
                          );
                          if (sku != null && sku.isNotEmpty) {
                            setState(() {
                              _skuController.text = sku;
                            });
                          }
                        },
                      ),
                      fontFamily: 'JetBrains Mono',
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTextFieldLabel('Kategori'),
                    Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: QuickPOSColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: QuickPOSColors.outlineVariant),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedCategory,
                          hint: const Text('Pilih Kategori', style: TextStyle(color: QuickPOSColors.outline)),
                          isExpanded: true,
                          icon: const Icon(Icons.expand_more, color: QuickPOSColors.onSurfaceVariant),
                          items: ['Makanan', 'Minuman', 'Elektronik', 'Fashion', 'Aksesoris', 'Peralatan Rumah', 'Pakaian', 'Lainnya'].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedCategory = newValue;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPricingCard() {
    return _buildCard(
      title: 'Pengaturan Harga',
      child: Column(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextFieldLabel('Harga Jual'),
              _buildTextField(
                controller: _priceController,
                hintText: '0',
                keyboardType: TextInputType.number,
                prefixText: 'Rp',
                fontWeight: FontWeight.bold,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextFieldLabel('Harga Modal'),
              _buildTextField(
                controller: _costController,
                hintText: '0',
                keyboardType: TextInputType.number,
                prefixText: 'Rp',
                prefixColor: QuickPOSColors.outline,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryCard() {
    return _buildCard(
      title: 'Stok & Inventaris',
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTextFieldLabel('Stok Awal'),
                    _buildTextField(
                      controller: _stockController,
                      hintText: '0',
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      fontWeight: FontWeight.bold,
                      suffixWidget: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(width: 1, height: 24, color: QuickPOSColors.outlineVariant),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              InkWell(
                                onTap: () {
                                  int current = int.tryParse(_stockController.text) ?? 0;
                                  _stockController.text = (current + 1).toString();
                                },
                                child: const Icon(Icons.keyboard_arrow_up, size: 16, color: QuickPOSColors.onSurfaceVariant),
                              ),
                              InkWell(
                                onTap: () {
                                  int current = int.tryParse(_stockController.text) ?? 0;
                                  if (current > 0) {
                                    _stockController.text = (current - 1).toString();
                                  }
                                },
                                child: const Icon(Icons.keyboard_arrow_down, size: 16, color: QuickPOSColors.onSurfaceVariant),
                              ),
                            ],
                          ),
                          const SizedBox(width: 8),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTextFieldLabel('Minimum Stok'),
                    _buildTextField(
                      controller: _minStockController,
                      hintText: '5',
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      fontWeight: FontWeight.bold,
                      suffixIcon: Icons.notification_important,
                      suffixIconColor: QuickPOSColors.error,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: QuickPOSColors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: QuickPOSColors.surfaceVariant),
            ),
            child: Row(
              children: const [
                Icon(Icons.info, size: 16, color: QuickPOSColors.secondary),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Kami akan memberikan notifikasi jika stok mencapai batas minimum.',
                    style: TextStyle(
                      fontSize: 12,
                      color: QuickPOSColors.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({String? title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: QuickPOSColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: QuickPOSColors.surfaceContainerHigh),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: QuickPOSColors.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            const Divider(color: QuickPOSColors.surfaceContainerHigh),
            const SizedBox(height: 12),
          ],
          child,
        ],
      ),
    );
  }

  Widget _buildTextFieldLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: QuickPOSColors.onSurfaceVariant,
          fontFamily: 'JetBrains Mono',
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    IconData? suffixIcon,
    Color? suffixIconColor,
    Widget? suffixWidget,
    TextInputType? keyboardType,
    String? prefixText,
    Color? prefixColor,
    FontWeight? fontWeight,
    String? fontFamily,
    TextAlign textAlign = TextAlign.start,
  }) {
    return SizedBox(
      height: 48,
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        textAlign: textAlign,
        style: TextStyle(
          fontSize: 16,
          fontWeight: fontWeight,
          fontFamily: fontFamily,
          color: QuickPOSColors.onSurface,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: QuickPOSColors.outline, fontWeight: FontWeight.normal),
          prefixIcon: prefixText != null
              ? Padding(
                  padding: const EdgeInsets.only(left: 12, right: 8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        prefixText,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: fontWeight,
                          color: prefixColor ?? QuickPOSColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                )
              : null,
          prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
          suffixIcon: suffixWidget ??
              (suffixIcon != null
                  ? Icon(suffixIcon, color: suffixIconColor ?? QuickPOSColors.onSurfaceVariant)
                  : null),
          filled: true,
          fillColor: QuickPOSColors.surfaceContainerLowest,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: QuickPOSColors.outlineVariant),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: QuickPOSColors.primary, width: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomActionBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: QuickPOSColors.surfaceContainerLowest,
        border: Border(top: BorderSide(color: QuickPOSColors.outlineVariant.withOpacity(0.5))),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 48,
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isSaving ? null : _saveProduct,
            style: ElevatedButton.styleFrom(
              backgroundColor: QuickPOSColors.secondary,
              foregroundColor: QuickPOSColors.onSecondary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 4,
            ),
            child: _isSaving
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(color: QuickPOSColors.onSecondary, strokeWidth: 2),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.save, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Simpan Produk',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class _AddProductAppBar extends StatelessWidget {
  final bool isEdit;
  const _AddProductAppBar({required this.isEdit});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      color: QuickPOSColors.surface,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: QuickPOSColors.onSurface),
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(width: 8),
              Text(
                isEdit ? 'Edit Produk' : 'Tambah Produk Baru',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: QuickPOSColors.onSurface,
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.help_outline, color: QuickPOSColors.primary),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
