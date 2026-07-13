import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kasirsuper/core/theme/quickpos_colors.dart';
import 'package:kasirsuper/features/product/blocs/blocs.dart';
import 'package:kasirsuper/features/product/models/product_model.dart';

class StockInPage extends StatefulWidget {
  const StockInPage({super.key});

  @override
  State<StockInPage> createState() => _StockInPageState();
}

class _StockInPageState extends State<StockInPage> {
  ProductModel? _selectedProduct;
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    context.read<ProductBloc>().add(LoadProducts());
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _saveStockIn() async {
    if (_selectedProduct == null || _selectedProduct!.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih produk terlebih dahulu.')),
      );
      return;
    }

    final qty = int.tryParse(_quantityController.text) ?? 0;
    if (qty <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Jumlah stok masuk harus lebih dari 0.')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    context.read<StockBloc>().add(
      AddStockInEvent(
        productId: _selectedProduct!.id!,
        quantity: qty,
        notes: _notesController.text,
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<StockBloc, StockState>(
      listener: (context, state) {
        if (state is StockSuccess) {
          // Refresh products to get updated stock
          context.read<ProductBloc>().add(LoadProducts());
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: QuickPOSColors.onSecondary),
                  const SizedBox(width: 8),
                  Text(state.message),
                ],
              ),
              backgroundColor: QuickPOSColors.secondary,
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.pop(context);
        } else if (state is StockError) {
          setState(() {
            _isSaving = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: QuickPOSColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: QuickPOSColors.surface,
        appBar: AppBar(
          title: const Text('Stok Masuk'),
          backgroundColor: Colors.white,
          foregroundColor: QuickPOSColors.onSurface,
          elevation: 0,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildProductSelection(),
                const SizedBox(height: 24),
                _buildQuantityInput(),
                const SizedBox(height: 24),
                _buildNotesInput(),
                const SizedBox(height: 40),
                _buildSaveButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductSelection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: QuickPOSColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: QuickPOSColors.surfaceContainerHigh),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'PILIH PRODUK / SPAREPART',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: QuickPOSColors.onSurfaceVariant,
              fontFamily: 'JetBrains Mono',
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 8),
          BlocBuilder<ProductBloc, ProductState>(
            builder: (context, state) {
              if (state is ProductLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is ProductLoaded) {
                final products = state.products;
                if (products.isEmpty) {
                  return const Text('Belum ada produk terdaftar.');
                }
                
                // Make sure the selected product still exists in the list
                if (_selectedProduct != null) {
                  final exists = products.any((p) => p.id == _selectedProduct!.id);
                  if (!exists) _selectedProduct = null;
                }

                return InkWell(
                  onTap: () => _showProductSearchBottomSheet(products),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    decoration: BoxDecoration(
                      color: QuickPOSColors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            _selectedProduct != null
                                ? '${_selectedProduct!.name} (Stok: ${_selectedProduct!.stock})'
                                : 'Pilih Produk (Ketuk untuk mencari)...',
                            style: TextStyle(
                              color: _selectedProduct != null ? QuickPOSColors.onSurface : QuickPOSColors.outline,
                              fontSize: 16,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Icon(Icons.search, color: QuickPOSColors.outline),
                      ],
                    ),
                  ),
                );
              }
              return const SizedBox();
            },
          ),
        ],
      ),
    );
  }

  void _showProductSearchBottomSheet(List<ProductModel> products) {
    List<ProductModel> filteredProducts = List.from(products);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
              decoration: const BoxDecoration(
                color: QuickPOSColors.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: QuickPOSColors.outlineVariant,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Pilih Produk',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: 'Cari Nama, SKU, atau Kode...',
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: QuickPOSColors.surfaceContainerHigh,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: (value) {
                        setModalState(() {
                          final query = value.toLowerCase();
                          filteredProducts = products.where((p) {
                            return p.name.toLowerCase().contains(query) ||
                                   p.sku.toLowerCase().contains(query) ||
                                   (p.sparepartCode?.toLowerCase().contains(query) ?? false);
                          }).toList();
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredProducts.length,
                      separatorBuilder: (context, index) => const Divider(),
                      itemBuilder: (context, index) {
                        final product = filteredProducts[index];
                        return ListTile(
                          title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('${product.sparepartCode ?? product.sku} (Stok: ${product.stock})'),
                          onTap: () {
                            setState(() {
                              _selectedProduct = product;
                            });
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildQuantityInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: QuickPOSColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: QuickPOSColors.surfaceContainerHigh),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'JUMLAH MASUK',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: QuickPOSColors.onSurfaceVariant,
              fontFamily: 'JetBrains Mono',
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _quantityController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'Contoh: 10',
              filled: true,
              fillColor: QuickPOSColors.surfaceContainerHigh,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              prefixIcon: const Icon(Icons.add_box, color: QuickPOSColors.outline),
            ),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: QuickPOSColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: QuickPOSColors.surfaceContainerHigh),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'CATATAN / SUPPLIER (OPSIONAL)',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: QuickPOSColors.onSurfaceVariant,
              fontFamily: 'JetBrains Mono',
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _notesController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Contoh: Dari Supplier A, Faktur #1234',
              filled: true,
              fillColor: QuickPOSColors.surfaceContainerHigh,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      height: 48,
      child: ElevatedButton(
        onPressed: _isSaving ? null : _saveStockIn,
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
            : const Text(
                'Simpan Stok Masuk',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }
}
