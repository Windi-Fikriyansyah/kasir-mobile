import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:kasirsuper/core/theme/quickpos_colors.dart';
import 'package:kasirsuper/features/pos/blocs/pos_bloc.dart';
import 'package:kasirsuper/features/pos/pages/checkout/page.dart';
import 'package:kasirsuper/features/pos/pages/scanner/page.dart';
import 'package:kasirsuper/features/product/blocs/blocs.dart';
import 'package:kasirsuper/features/product/models/product_model.dart';
import 'package:kasirsuper/features/service/blocs/blocs.dart';
import 'package:kasirsuper/core/widgets/notification_bell.dart';
import 'package:kasirsuper/features/service/models/service_model.dart';
import 'package:kasirsuper/features/pos/models/cart_item_model.dart';

class POSPage extends StatefulWidget {
  const POSPage({super.key});

  @override
  State<POSPage> createState() => _POSPageState();
}

class _POSPageState extends State<POSPage> {
  String activeCategory = 'Semua Item';
  String searchQuery = '';
  String activeTab = 'Sparepart'; // 'Sparepart' or 'Service'

  void filterCategory(String category) {
    setState(() {
      activeCategory = category;
    });
  }

  void onSearchChanged(String query) {
    setState(() {
      searchQuery = query;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const _POSAppBar(),
            Expanded(
              child: Container(
                color: QuickPOSColors.surface,
                child: Column(
                  children: [
                    _SearchBarSection(onChanged: onSearchChanged),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => setState(() { activeTab = 'Sparepart'; activeCategory = 'Semua Item'; }),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                border: Border(bottom: BorderSide(color: activeTab == 'Sparepart' ? QuickPOSColors.primary : Colors.transparent, width: 2)),
                              ),
                              child: Text('Sparepart', textAlign: TextAlign.center, style: TextStyle(fontWeight: activeTab == 'Sparepart' ? FontWeight.bold : FontWeight.normal, color: activeTab == 'Sparepart' ? QuickPOSColors.primary : QuickPOSColors.outline)),
                            ),
                          ),
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: () => setState(() { activeTab = 'Service'; activeCategory = 'Semua Item'; }),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                border: Border(bottom: BorderSide(color: activeTab == 'Service' ? QuickPOSColors.primary : Colors.transparent, width: 2)),
                              ),
                              child: Text('Service', textAlign: TextAlign.center, style: TextStyle(fontWeight: activeTab == 'Service' ? FontWeight.bold : FontWeight.normal, color: activeTab == 'Service' ? QuickPOSColors.primary : QuickPOSColors.outline)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (activeTab == 'Sparepart')
                      BlocBuilder<ProductBloc, ProductState>(
                        builder: (context, state) {
                          List<String> categories = ['Semua Item'];
                          if (state is ProductLoaded) {
                            final uniqueCategories = state.products.map((p) => p.category).toSet().toList();
                            uniqueCategories.removeWhere((c) => c.trim().isEmpty || c == 'Semua Item');
                            uniqueCategories.sort();
                            categories.addAll(uniqueCategories);
                          }
                          return _CategoryChips(
                            categories: categories,
                            activeCategory: activeCategory,
                            onCategoryTap: filterCategory,
                          );
                        },
                      ),
                    if (activeTab == 'Service')
                      BlocBuilder<ServiceBloc, ServiceState>(
                        builder: (context, state) {
                          List<String> categories = ['Semua Item'];
                          if (state is ServiceLoaded) {
                            final uniqueCategories = state.services.map((s) => s.category).toSet().toList();
                            uniqueCategories.removeWhere((c) => c.trim().isEmpty || c == 'Semua Item');
                            uniqueCategories.sort();
                            categories.addAll(uniqueCategories);
                          }
                          return _CategoryChips(
                            categories: categories,
                            activeCategory: activeCategory,
                            onCategoryTap: filterCategory,
                          );
                        },
                      ),
                    Expanded(
                      child: _ProductGrid(
                        activeCategory: activeCategory,
                        searchQuery: searchQuery,
                        activeTab: activeTab,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BlocBuilder<PosBloc, PosState>(
        builder: (context, state) {
          return _CheckoutBottomBar(
            count: state.totalQuantity,
            total: state.totalAmount,
          );
        },
      ),
    );
  }
}

class _POSAppBar extends StatelessWidget {
  const _POSAppBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: const [
              Icon(Icons.storefront, color: QuickPOSColors.primary),
              SizedBox(width: 8),
              Text(
                'QuickPOS',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: QuickPOSColors.onSurface,
                ),
              ),
            ],
          ),
          const NotificationBell(),
        ],
      ),
    );
  }
}

class _SearchBarSection extends StatelessWidget {
  final ValueChanged<String> onChanged;
  
  const _SearchBarSection({required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: 'Cari produk atau SKU...',
          hintStyle: const TextStyle(color: QuickPOSColors.outline, fontSize: 16),
          prefixIcon: const Icon(Icons.search, color: QuickPOSColors.outline),
          suffixIcon: IconButton(
            icon: const Icon(Icons.qr_code_scanner, color: QuickPOSColors.onSurfaceVariant),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ScannerPage()),
              );
            },
          ),
          filled: true,
          fillColor: QuickPOSColors.surfaceContainerLow,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: QuickPOSColors.outlineVariant),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: QuickPOSColors.primary, width: 2),
          ),
        ),
      ),
    );
  }
}

class _CategoryChips extends StatelessWidget {
  final List<String> categories;
  final String activeCategory;
  final Function(String) onCategoryTap;

  const _CategoryChips({required this.categories, required this.activeCategory, required this.onCategoryTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = categories[index];
          final isActive = category == activeCategory;
          
          return GestureDetector(
            onTap: () => onCategoryTap(category),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isActive ? QuickPOSColors.primary : QuickPOSColors.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Text(
                category,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isActive ? QuickPOSColors.onPrimary : QuickPOSColors.onSurface,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ProductGrid extends StatelessWidget {
  final String activeCategory;
  final String searchQuery;
  final String activeTab;

  const _ProductGrid({
    required this.activeCategory,
    required this.searchQuery,
    required this.activeTab,
  });

  @override
  Widget build(BuildContext context) {
    if (activeTab == 'Sparepart') {
      return BlocBuilder<ProductBloc, ProductState>(
        builder: (context, state) {
          if (state is ProductLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ProductLoaded) {
            final filteredProducts = state.products.where((p) {
              final matchesCategory = activeCategory == 'Semua Item' || p.category == activeCategory;
              final matchesSearch = p.name.toLowerCase().contains(searchQuery.toLowerCase()) || 
                                    p.sku.toLowerCase().contains(searchQuery.toLowerCase());
              return matchesCategory && matchesSearch;
            }).toList();

            if (filteredProducts.isEmpty) {
              return const Center(
                child: Text('Tidak ada produk', style: TextStyle(color: QuickPOSColors.outline)),
              );
            }

            return GridView.builder(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 32),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.65,
              ),
              itemCount: filteredProducts.length,
              itemBuilder: (context, index) {
                final product = filteredProducts[index];
                final isOut = product.stock == 0;
                final isLow = product.stock > 0 && product.stock <= product.minStock;
                
                String? tag;
                Color? tagColor;
                Color? tagTextColor;
                
                if (isOut) {
                  tag = 'Habis';
                  tagColor = QuickPOSColors.error;
                  tagTextColor = Colors.white;
                } else if (isLow) {
                  tag = 'Menipis';
                  tagColor = QuickPOSColors.errorContainer;
                  tagTextColor = QuickPOSColors.onErrorContainer;
                } else {
                  tag = 'Tersedia';
                  tagColor = QuickPOSColors.secondaryContainer;
                  tagTextColor = QuickPOSColors.onSecondaryContainer;
                }

                return _buildProductCard(
                  context: context,
                  product: product,
                  tag: tag,
                  tagColor: tagColor,
                  tagTextColor: tagTextColor,
                );
              },
            );
          } else if (state is ProductError) {
            return Center(child: Text(state.message, style: const TextStyle(color: QuickPOSColors.error)));
          }
          return const SizedBox();
        },
      );
    } else {
      return BlocBuilder<ServiceBloc, ServiceState>(
        builder: (context, state) {
          if (state is ServiceLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ServiceLoaded) {
            final filteredServices = state.services.where((s) {
              final matchesCategory = activeCategory == 'Semua Item' || s.category == activeCategory;
              final matchesSearch = s.name.toLowerCase().contains(searchQuery.toLowerCase()) || 
                                    (s.sku != null && s.sku!.toLowerCase().contains(searchQuery.toLowerCase()));
              return matchesCategory && matchesSearch;
            }).toList();

            if (filteredServices.isEmpty) {
              return const Center(
                child: Text('Tidak ada service', style: TextStyle(color: QuickPOSColors.outline)),
              );
            }

            return GridView.builder(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 32),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.65,
              ),
              itemCount: filteredServices.length,
              itemBuilder: (context, index) {
                final service = filteredServices[index];

                return _buildServiceCard(
                  context: context,
                  service: service,
                );
              },
            );
          } else if (state is ServiceError) {
            return Center(child: Text(state.message, style: const TextStyle(color: QuickPOSColors.error)));
          }
          return const SizedBox();
        },
      );
    }
  }

  Widget _buildProductCard({
    required BuildContext context,
    required ProductModel product,
    String? tag,
    Color? tagColor,
    Color? tagTextColor,
  }) {
    final formattedPrice = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(product.price);
    
    final imageUrl = product.imagePath ?? 'https://via.placeholder.com/150';
    
    return Container(
      decoration: BoxDecoration(
        color: QuickPOSColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: imageUrl.startsWith('http')
                      ? Image.network(imageUrl, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => Container(color: QuickPOSColors.surfaceContainerHigh))
                      : Image.file(File(imageUrl), fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => Container(color: QuickPOSColors.surfaceContainerHigh)),
                ),
                if (tag != null)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: tagColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        tag.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: tagTextColor,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  product.category.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10,
                    color: QuickPOSColors.outline,
                    letterSpacing: 1.0,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: QuickPOSColors.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        formattedPrice,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: QuickPOSColors.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    InkWell(
                      onTap: () {
                        if (product.stock > 0) {
                          context.read<PosBloc>().add(AddItemToCart(CartItemModel(product: product, itemType: 'product')));
                          ScaffoldMessenger.of(context).clearSnackBars();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${product.name} ditambahkan ke keranjang!'),
                              duration: const Duration(milliseconds: 1500),
                              backgroundColor: QuickPOSColors.secondary,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Stok habis!'),
                              backgroundColor: QuickPOSColors.error,
                            ),
                          );
                        }
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: product.stock > 0 ? QuickPOSColors.primary : QuickPOSColors.surfaceContainerHigh,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.add, color: product.stock > 0 ? QuickPOSColors.onPrimary : QuickPOSColors.outline, size: 18),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard({
    required BuildContext context,
    required ServiceModel service,
  }) {
    final formattedPrice = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(service.price);
    
    return Container(
      decoration: BoxDecoration(
        color: QuickPOSColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: QuickPOSColors.primaryContainer,
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: const Icon(Icons.handyman, size: 64, color: QuickPOSColors.primary),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  service.category.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10,
                    color: QuickPOSColors.outline,
                    letterSpacing: 1.0,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  service.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: QuickPOSColors.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        formattedPrice,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: QuickPOSColors.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    InkWell(
                      onTap: () {
                        context.read<PosBloc>().add(AddItemToCart(CartItemModel(service: service, itemType: 'service')));
                        ScaffoldMessenger.of(context).clearSnackBars();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${service.name} ditambahkan ke keranjang!'),
                            duration: const Duration(milliseconds: 1500),
                            backgroundColor: QuickPOSColors.secondary,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: const BoxDecoration(
                          color: QuickPOSColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.add, color: QuickPOSColors.onPrimary, size: 18),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CheckoutBottomBar extends StatelessWidget {
  final int count;
  final double total;

  const _CheckoutBottomBar({required this.count, required this.total});

  @override
  Widget build(BuildContext context) {
    final formattedTotal = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(total);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: QuickPOSColors.surfaceContainerLowest,
        border: Border(top: BorderSide(color: QuickPOSColors.outlineVariant.withOpacity(0.5))),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.shopping_basket, color: QuickPOSColors.secondary, size: 32),
                if (count > 0)
                  Positioned(
                    top: -4,
                    right: -4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: QuickPOSColors.secondary,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '$count',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: QuickPOSColors.onSecondary,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'TOTAL',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: QuickPOSColors.outline,
                    ),
                  ),
                  Text(
                    formattedTotal,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: QuickPOSColors.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: count > 0 
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CheckoutPage(),
                        ),
                      );
                    }
                  : null,
              icon: const Icon(Icons.payment, size: 18),
              label: const Text('Bayar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: QuickPOSColors.primary,
                foregroundColor: QuickPOSColors.onPrimary,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
