import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kasirsuper/core/theme/quickpos_colors.dart';
import 'package:kasirsuper/features/product/blocs/blocs.dart';
import 'package:kasirsuper/features/product/models/product_model.dart';
import 'package:kasirsuper/core/widgets/notification_bell.dart';
import 'package:kasirsuper/features/product/pages/add_product/page.dart';
import 'package:intl/intl.dart';
class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  String _activeCategory = 'Semua Item';
  String _searchQuery = '';
  String _activeSort = 'Terbaru';

  void _showSortFilterDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            Widget buildSortOption(String label) {
              return RadioListTile<String>(
                value: label,
                groupValue: _activeSort,
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _activeSort = value;
                    });
                    setModalState(() {
                      _activeSort = value;
                    });
                    Navigator.pop(context);
                  }
                },
                title: Text(label),
                contentPadding: EdgeInsets.zero,
              );
            }

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Urutkan Berdasarkan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  buildSortOption('Terbaru'),
                  buildSortOption('Nama (A-Z)'),
                  buildSortOption('Nama (Z-A)'),
                  buildSortOption('Harga Tertinggi'),
                  buildSortOption('Harga Terendah'),
                  const SizedBox(height: 16),
                ],
              ),
            );
          }
        );
      },
    );
  }

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
        title: const Text('Data Sparepart'),
        backgroundColor: Colors.white,
        foregroundColor: QuickPOSColors.onSurface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(left: 16, right: 16, top: 24, bottom: 80),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeroSection(),
              const SizedBox(height: 24),
              _buildSearchAndFilters(),
              const SizedBox(height: 16),
              _buildProductList(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddProductPage()),
          );
        },
        backgroundColor: QuickPOSColors.secondary,
        foregroundColor: QuickPOSColors.onSecondary,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }

  Widget _buildHeroSection() {
    return BlocBuilder<ProductBloc, ProductState>(
      builder: (context, state) {
        int totalSku = 0;
        double totalValue = 0;
        int lowStock = 0;
        int outStock = 0;

        if (state is ProductLoaded) {
          totalSku = state.products.length;
          for (var p in state.products) {
            totalValue += p.price * p.stock;
            if (p.stock == 0) {
              outStock++;
            } else if (p.stock <= p.minStock) {
              lowStock++;
            }
          }
        }

        String formattedValue;
        if (totalValue >= 1000000) {
          formattedValue = 'Rp ${(totalValue / 1000000).toStringAsFixed(1)}jt';
        } else if (totalValue >= 1000) {
          formattedValue = 'Rp ${(totalValue / 1000).toStringAsFixed(1)}rb';
        } else {
          formattedValue = 'Rp ${totalValue.toInt()}';
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Ringkasan Inventaris',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: QuickPOSColors.onSurface,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Data Produk',
                      style: TextStyle(
                        fontSize: 14,
                        color: QuickPOSColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: QuickPOSColors.surfaceContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: QuickPOSColors.secondary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'Online',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: QuickPOSColors.onSurface,
                          fontFamily: 'JetBrains Mono',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildSummaryCard('TOTAL SKU', '$totalSku')),
                const SizedBox(width: 8),
                Expanded(child: _buildSummaryCard('NILAI', formattedValue)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _buildSummaryCard('STOK MENIPIS', '$lowStock', isError: true)),
                const SizedBox(width: 8),
                Expanded(child: _buildSummaryCard('STOK HABIS', '$outStock')),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildSummaryCard(String title, String value, {bool isError = false}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isError ? QuickPOSColors.errorContainer.withOpacity(0.2) : QuickPOSColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isError ? QuickPOSColors.error.withOpacity(0.1) : QuickPOSColors.outlineVariant.withOpacity(0.3),
        ),
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
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isError ? QuickPOSColors.error : QuickPOSColors.onSurfaceVariant,
              fontFamily: 'JetBrains Mono',
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isError ? QuickPOSColors.error : QuickPOSColors.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Column(
      children: [
        TextField(
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
          decoration: InputDecoration(
            hintText: 'Cari nama produk, SKU atau kategori...',
            hintStyle: const TextStyle(color: QuickPOSColors.outline),
            prefixIcon: const Icon(Icons.search, color: QuickPOSColors.outline),
            filled: true,
            fillColor: QuickPOSColors.surfaceContainerLowest,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: QuickPOSColors.outlineVariant),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: QuickPOSColors.outlineVariant),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: QuickPOSColors.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
        const SizedBox(height: 12),
        BlocBuilder<ProductBloc, ProductState>(
          builder: (context, state) {
            List<String> categories = ['Semua Item'];
            if (state is ProductLoaded) {
              final uniqueCategories = state.products.map((p) => p.category).toSet().toList();
              uniqueCategories.removeWhere((c) => c.trim().isEmpty || c == 'Semua Item');
              uniqueCategories.sort();
              categories.addAll(uniqueCategories);
            }
            
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ...categories.map((c) => _buildCategoryChip(c)),
                  const SizedBox(width: 4),
                  Container(
                    decoration: const BoxDecoration(
                      color: QuickPOSColors.surfaceContainerHigh,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.filter_list, size: 20, color: QuickPOSColors.onSurfaceVariant),
                      onPressed: _showSortFilterDialog,
                      splashRadius: 20,
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(8),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildCategoryChip(String label) {
    final isActive = _activeCategory == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: () => setState(() => _activeCategory = label),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? QuickPOSColors.primary : QuickPOSColors.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isActive ? QuickPOSColors.onPrimary : QuickPOSColors.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductList() {
    return BlocBuilder<ProductBloc, ProductState>(
      builder: (context, state) {
        if (state is ProductLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is ProductLoaded) {
          final filteredProducts = state.products.where((p) {
            final matchesCategory = _activeCategory == 'Semua Item' || p.category == _activeCategory;
            final matchesSearch = p.name.toLowerCase().contains(_searchQuery.toLowerCase()) || 
                                  p.sku.toLowerCase().contains(_searchQuery.toLowerCase());
            return matchesCategory && matchesSearch;
          }).toList();

          if (_activeSort == 'Nama (A-Z)') {
            filteredProducts.sort((a, b) => a.name.compareTo(b.name));
          } else if (_activeSort == 'Nama (Z-A)') {
            filteredProducts.sort((a, b) => b.name.compareTo(a.name));
          } else if (_activeSort == 'Harga Tertinggi') {
            filteredProducts.sort((a, b) => b.price.compareTo(a.price));
          } else if (_activeSort == 'Harga Terendah') {
            filteredProducts.sort((a, b) => a.price.compareTo(b.price));
          } else {
            filteredProducts.sort((a, b) => (b.id ?? 0).compareTo(a.id ?? 0));
          }

          if (filteredProducts.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Text('Belum ada produk', style: TextStyle(color: QuickPOSColors.outline)),
              ),
            );
          }
          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filteredProducts.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final product = filteredProducts[index];
              return _buildProductItem(product);
            },
          );
        } else if (state is ProductError) {
          return Center(child: Text(state.message, style: const TextStyle(color: QuickPOSColors.error)));
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildProductItem(ProductModel product) {
    final isOut = product.stock == 0;
    final isLow = product.stock > 0 && product.stock <= product.minStock;
    final stockStatus = isOut ? 'Stok Habis' : (isLow ? 'Stok Menipis' : 'Tersedia');
    final stockCount = isOut ? 'STOK HABIS' : (isLow ? 'Sisa ${product.stock}' : '${product.stock} Tersedia');
    return Dismissible(
      key: Key(product.id.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: QuickPOSColors.error,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Konfirmasi Hapus'),
              content: Text('Apakah Anda yakin ingin menghapus produk "${product.name}"?'),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Batal', style: TextStyle(color: QuickPOSColors.outline)),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: QuickPOSColors.error,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Hapus'),
                ),
              ],
            );
          },
        );
      },
      onDismissed: (direction) {
        if (product.id != null) {
          context.read<ProductBloc>().add(DeleteProductEvent(product.id!));
        }
      },
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddProductPage(product: product),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: QuickPOSColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: QuickPOSColors.outlineVariant.withOpacity(0.3)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 4,
              ),
            ],
          ),
          child: Opacity(
            opacity: isOut ? 0.6 : 1.0,
            child: Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: QuickPOSColors.surfaceContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: product.imagePath != null
                      ? (isOut
                          ? ColorFiltered(
                              colorFilter: const ColorFilter.mode(
                                Colors.grey,
                                BlendMode.saturation,
                              ),
                              child: product.imagePath!.startsWith('http')
                                  ? Image.network(
                                      product.imagePath!, 
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.inventory_2, color: QuickPOSColors.outlineVariant, size: 32),
                                    )
                                  : Image.file(
                                      File(product.imagePath!), 
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.inventory_2, color: QuickPOSColors.outlineVariant, size: 32),
                                    ),
                            )
                          : (product.imagePath!.startsWith('http')
                              ? Image.network(
                                  product.imagePath!, 
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.inventory_2, color: QuickPOSColors.outlineVariant, size: 32),
                                )
                              : Image.file(
                                  File(product.imagePath!), 
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.inventory_2, color: QuickPOSColors.outlineVariant, size: 32),
                                )))
                      : const Icon(Icons.inventory_2, color: QuickPOSColors.outlineVariant, size: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: QuickPOSColors.onSurface,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              product.sparepartCode != null && product.sparepartCode!.isNotEmpty 
                                  ? '${product.sparepartCode} • ${product.sku}' 
                                  : product.sku,
                              style: const TextStyle(
                                fontSize: 12,
                                fontFamily: 'JetBrains Mono',
                                color: QuickPOSColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(product.price),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: QuickPOSColors.onSurface,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: QuickPOSColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            product.category,
                            style: const TextStyle(
                              fontSize: 12,
                              fontFamily: 'JetBrains Mono',
                              color: QuickPOSColors.onSurfaceVariant,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isLow || isOut) ...[
                              const Icon(Icons.error_outline, size: 16, color: QuickPOSColors.error),
                              const SizedBox(width: 4),
                            ],
                            Flexible(
                              child: Text(
                                stockCount.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: isLow || isOut ? QuickPOSColors.error : QuickPOSColors.secondary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
    ),
    );
  }
}

