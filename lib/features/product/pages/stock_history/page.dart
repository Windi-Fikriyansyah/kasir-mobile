import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kasirsuper/core/theme/quickpos_colors.dart';
import 'package:kasirsuper/features/product/blocs/blocs.dart';
import 'package:kasirsuper/features/product/models/product_model.dart';
import 'package:kasirsuper/features/product/pages/stock_history/product_history_page.dart';

class StockHistoryPage extends StatefulWidget {
  const StockHistoryPage({super.key});

  @override
  State<StockHistoryPage> createState() => _StockHistoryPageState();
}

class _StockHistoryPageState extends State<StockHistoryPage> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    context.read<ProductBloc>().add(LoadProducts());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: QuickPOSColors.surface,
      appBar: AppBar(
        title: const Text('Pilih Produk'),
        backgroundColor: Colors.white,
        foregroundColor: QuickPOSColors.onSurface,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Cari Nama, SKU, atau Kode...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: QuickPOSColors.surfaceContainerHigh,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
        ),
      ),
      body: BlocBuilder<ProductBloc, ProductState>(
        builder: (context, state) {
          if (state is ProductLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ProductLoaded) {
            final filteredProducts = state.products.where((p) {
              return p.name.toLowerCase().contains(_searchQuery) ||
                     p.sku.toLowerCase().contains(_searchQuery) ||
                     (p.sparepartCode?.toLowerCase().contains(_searchQuery) ?? false);
            }).toList();

            if (filteredProducts.isEmpty) {
              return Center(
                child: Text('Tidak ada produk ditemukan.', style: TextStyle(color: QuickPOSColors.outline)),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: filteredProducts.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final product = filteredProducts[index];
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductStockHistoryPage(product: product),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: QuickPOSColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: QuickPOSColors.surfaceContainerHigh),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: QuickPOSColors.surfaceContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          clipBehavior: Clip.hardEdge,
                          child: product.imagePath != null
                              ? (product.imagePath!.startsWith('http')
                                  ? Image.network(
                                      product.imagePath!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.inventory_2, color: QuickPOSColors.outlineVariant),
                                    )
                                  : Image.file(
                                      File(product.imagePath!),
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.inventory_2, color: QuickPOSColors.outlineVariant),
                                    ))
                              : const Icon(Icons.inventory_2, color: QuickPOSColors.outlineVariant),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.name,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${product.sparepartCode ?? product.sku} (Stok: ${product.stock})',
                                style: const TextStyle(color: QuickPOSColors.outline, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right, color: QuickPOSColors.outlineVariant),
                      ],
                    ),
                  ),
                );
              },
            );
          } else if (state is ProductError) {
            return Center(child: Text(state.message, style: const TextStyle(color: QuickPOSColors.error)));
          }
          return const SizedBox();
        },
      ),
    );
  }
}
