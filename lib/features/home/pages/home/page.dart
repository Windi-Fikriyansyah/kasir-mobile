import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:kasirsuper/core/core.dart';
import 'package:kasirsuper/core/theme/quickpos_colors.dart';
import 'package:kasirsuper/features/transaction/blocs/transaction_bloc.dart';
import 'package:kasirsuper/features/product/blocs/blocs.dart';
import 'package:kasirsuper/features/product/models/product_model.dart';
import 'package:kasirsuper/features/service/blocs/blocs.dart';
import 'package:kasirsuper/features/home/home.dart';
import 'package:kasirsuper/features/service/pages/index/page.dart';
import 'package:kasirsuper/features/notification/blocs/notification_bloc.dart';
import 'package:kasirsuper/features/notification/pages/index/page.dart';
import 'package:kasirsuper/features/mechanic/mechanic.dart';
import 'package:kasirsuper/features/mechanic/pages/commission/page.dart';
import 'package:kasirsuper/features/product/pages/sparepart_menu/page.dart';
import 'package:kasirsuper/features/report/pages/index/page.dart';
import 'package:kasirsuper/core/widgets/notification_bell.dart';

typedef DashboardColors = QuickPOSColors;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    context.read<TransactionBloc>().add(LoadTransactions());
    context.read<ProductBloc>().add(LoadProducts());
    context.read<ServiceBloc>().add(LoadServices());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Fixed Header
            const _HomeAppBar(),
            // Scrollable Content
            Expanded(
              child: Container(
                color: DashboardColors.surface,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 24),
                  child: BlocBuilder<TransactionBloc, TransactionState>(
                    builder: (context, txState) {
                      return BlocBuilder<ProductBloc, ProductState>(
                        builder: (context, prodState) {
                          return BlocBuilder<ServiceBloc, ServiceState>(
                            builder: (context, serviceState) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _SalesSummarySection(txState: txState, prodState: prodState),
                                  const SizedBox(height: 16),
                                  const _MenuGridSection(),
                                  const SizedBox(height: 16),
                                  const _QuickActionsSection(),
                                  const SizedBox(height: 24),
                                  _BestSellingSection(txState: txState, prodState: prodState, serviceState: serviceState),
                                  const SizedBox(height: 24),
                                  _LowStockSection(prodState: prodState),
                                ],
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeAppBar extends StatelessWidget {
  const _HomeAppBar();

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
              Icon(Icons.storefront, color: DashboardColors.primary),
              SizedBox(width: 8),
              Text(
                'BengkelPro',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: DashboardColors.onSurface,
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


class _SalesSummarySection extends StatelessWidget {
  final TransactionState txState;
  final ProductState prodState;
  const _SalesSummarySection({required this.txState, required this.prodState});

  @override
  Widget build(BuildContext context) {
    double todaySales = 0;
    double todayProfit = 0;
    int todayCount = 0;
    
    if (txState is TransactionLoaded && prodState is ProductLoaded) {
      final now = DateTime.now();
      final products = (prodState as ProductLoaded).products;
      
      for (var txn in (txState as TransactionLoaded).transactions) {
        final dt = DateTime.parse(txn.date);
        if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
          todaySales += txn.totalAmount;
          todayCount++;
          
          if (txn.items != null) {
            double txSubTotal = 0;
            double txCost = 0;
            double txCommission = 0;

            for (var item in txn.items!) {
              txSubTotal += item.price * item.quantity;
              txCommission += item.commissionAmount;

              if (item.itemType == 'product') {
                final product = products.firstWhere(
                  (p) => p.id == item.productId,
                  orElse: () => ProductModel(name: '', sku: '', category: '', price: 0, cost: 0, stock: 0, minStock: 0),
                );
                txCost += product.cost * item.quantity;
              }
            }

            double discountAmount = txSubTotal * (txn.discountPercent ?? 0) / 100;
            double netRevenue = txSubTotal - discountAmount;
            todayProfit += (netRevenue - txCost - txCommission);
          }
        }
      }
    }
    double avgSales = todayCount > 0 ? todaySales / todayCount : 0;
    final formatCurrency = NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: DashboardColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: DashboardColors.outlineVariant.withOpacity(0.2)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "RINGKASAN PENJUALAN HARI INI",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: DashboardColors.onSurfaceVariant,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 4),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        formatCurrency.format(todaySales),
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: DashboardColors.onSurface,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: DashboardColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.payments_outlined, color: DashboardColors.onSurfaceVariant),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildMiniCard('Transaksi', todayCount.toString(), Icons.receipt_long, null),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildMiniCard('Laba Bersih', formatCurrency.format(todayProfit), Icons.trending_up, DashboardColors.secondary),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildMiniCard('Rata-rata', formatCurrency.format(avgSales), Icons.analytics, null),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMiniCard(String title, String value, IconData icon, Color? valueColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: DashboardColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: DashboardColors.outlineVariant.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: DashboardColors.onSurfaceVariant),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 10, color: DashboardColors.onSurfaceVariant, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: valueColor ?? DashboardColors.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuGridSection extends StatelessWidget {
  const _MenuGridSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: DashboardColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: DashboardColors.outlineVariant.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Menu Utama',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: DashboardColors.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 0.65,
            children: [
              _buildMenuItem(context, Icons.point_of_sale, 'POS', DashboardColors.primary, () {
                context.read<BottomNavBloc>().add(const TapBottomNavEvent(2));
              }),
              _buildMenuItem(context, Icons.build_circle_outlined, 'Sparepart', DashboardColors.secondary, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SparepartMenuPage()),
                );
              }),
              _buildMenuItem(context, Icons.handyman, 'Service', Colors.teal, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ServiceListPage()),
                );
              }),
              _buildMenuItem(context, Icons.history, 'Riwayat', Colors.orange, () {
                context.read<BottomNavBloc>().add(const TapBottomNavEvent(1));
              }),
              _buildMenuItem(context, Icons.engineering, 'Mekanik', Colors.brown, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MechanicListPage()),
                );
              }),
              _buildMenuItem(context, Icons.request_quote, 'Komisi', Colors.deepOrange, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MechanicCommissionPage()),
                );
              }),
              _buildMenuItem(context, Icons.bar_chart, 'Laporan', Colors.purple, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ReportPage()),
                );
              }),
              _buildMenuItem(context, Icons.settings, 'Pengaturan', Colors.grey, () {
                context.read<BottomNavBloc>().add(const TapBottomNavEvent(4));
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, IconData icon, String label, Color color, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: DashboardColors.onSurface,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickActionsSection extends StatelessWidget {
  const _QuickActionsSection();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 56,
            child: ElevatedButton.icon(
              onPressed: () {
                context.read<BottomNavBloc>().add(const TapBottomNavEvent(2));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: DashboardColors.secondary,
                foregroundColor: DashboardColors.onSecondary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              icon: const Icon(Icons.add_circle),
              label: const FittedBox(
                child: Text(
                  'Penjualan Baru',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: SizedBox(
            height: 56,
            child: OutlinedButton.icon(
              onPressed: () {
                context.read<BottomNavBloc>().add(const TapBottomNavEvent(3));
              },
              style: OutlinedButton.styleFrom(
                backgroundColor: DashboardColors.surfaceContainerHighest,
                foregroundColor: DashboardColors.onSurfaceVariant,
                side: const BorderSide(color: DashboardColors.outlineVariant),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.inventory_2_outlined),
              label: const Text('Inventaris'),
            ),
          ),
        ),
      ],
    );
  }
}

class _BestSellingSection extends StatefulWidget {
  final TransactionState txState;
  final ProductState prodState;
  final ServiceState serviceState;
  const _BestSellingSection({required this.txState, required this.prodState, required this.serviceState});

  @override
  State<_BestSellingSection> createState() => _BestSellingSectionState();
}

class _BestSellingSectionState extends State<_BestSellingSection> {
  String _activeFilter = 'Sepanjang Waktu';
  bool _isExpanded = false;

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            Widget buildFilterOption(String label) {
              return RadioListTile<String>(
                value: label,
                groupValue: _activeFilter,
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _activeFilter = value;
                    });
                    setModalState(() {
                      _activeFilter = value;
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
                  const Text('Filter Penjualan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  buildFilterOption('Hari Ini'),
                  buildFilterOption('Minggu Ini'),
                  buildFilterOption('Bulan Ini'),
                  buildFilterOption('Sepanjang Waktu'),
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
  Widget build(BuildContext context) {
    List<Widget> productItems = [];
    List<Widget> serviceItems = [];

    if (widget.txState is TransactionLoaded && widget.prodState is ProductLoaded && widget.serviceState is ServiceLoaded) {
      Map<int, int> soldProducts = {};
      Map<int, int> soldServices = {};
      final now = DateTime.now();
      
      for (var txn in (widget.txState as TransactionLoaded).transactions) {
        final dt = DateTime.parse(txn.date);
        bool matchDate = true;
        if (_activeFilter == 'Hari Ini') {
          matchDate = dt.year == now.year && dt.month == now.month && dt.day == now.day;
        } else if (_activeFilter == 'Minggu Ini') {
          matchDate = now.difference(dt).inDays <= 7;
        } else if (_activeFilter == 'Bulan Ini') {
          matchDate = dt.year == now.year && dt.month == now.month;
        }

        if (matchDate && txn.items != null) {
          for (var item in txn.items!) {
            if (item.itemType == 'service') {
              soldServices[item.productId] = (soldServices[item.productId] ?? 0) + item.quantity;
            } else {
              soldProducts[item.productId] = (soldProducts[item.productId] ?? 0) + item.quantity;
            }
          }
        }
      }

      var sortedProductIds = soldProducts.keys.toList()..sort((a, b) => soldProducts[b]!.compareTo(soldProducts[a]!));
      var sortedServiceIds = soldServices.keys.toList()..sort((a, b) => soldServices[b]!.compareTo(soldServices[a]!));
      
      var limit = _isExpanded ? 10 : 3;
      var topProductIds = sortedProductIds.take(limit).toList();
      var topServiceIds = sortedServiceIds.take(limit).toList();
      
      final formatCurrency = NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);

      for (var id in topProductIds) {
        try {
          var prod = (widget.prodState as ProductLoaded).products.firstWhere((p) => p.id == id);
          productItems.add(_buildItem(
            imagePath: prod.imagePath,
            title: prod.name,
            sku: 'SKU: ${prod.sku}',
            units: '${soldProducts[id]} Terjual',
            price: formatCurrency.format(prod.price),
          ));
          productItems.add(const SizedBox(height: 12));
        } catch (_) {}
      }

      for (var id in topServiceIds) {
        try {
          var srv = (widget.serviceState as ServiceLoaded).services.firstWhere((s) => s.id == id);
          serviceItems.add(_buildItem(
            imagePath: null,
            title: srv.name,
            sku: 'Service',
            units: '${soldServices[id]} Order',
            price: formatCurrency.format(srv.price),
          ));
          serviceItems.add(const SizedBox(height: 12));
        } catch (_) {}
      }
      
      int totalAvailable = sortedProductIds.length > sortedServiceIds.length ? sortedProductIds.length : sortedServiceIds.length;
      if (totalAvailable > 3) {
        productItems.add(
          Center(
            child: TextButton(
              onPressed: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              style: TextButton.styleFrom(
                foregroundColor: DashboardColors.secondary,
              ),
              child: Text(
                _isExpanded ? 'Tampilkan Lebih Sedikit' : 'Tampilkan Lebih Banyak (${totalAvailable > 10 ? '10' : totalAvailable})',
              ),
            ),
          )
        );
      }
    }

    if (productItems.isEmpty && serviceItems.isEmpty) {
      productItems.add(const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Text('Belum ada data penjualan', style: TextStyle(color: DashboardColors.outline)),
      ));
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: DashboardColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: DashboardColors.outlineVariant.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Terlaris',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: DashboardColors.onSurface,
                ),
              ),
              Row(
                children: [
                  Text(
                    _activeFilter,
                    style: const TextStyle(
                      fontSize: 12,
                      color: DashboardColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: const BoxDecoration(
                      color: DashboardColors.surfaceContainerHigh,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.filter_list, size: 16, color: DashboardColors.onSurfaceVariant),
                      onPressed: _showFilterDialog,
                      splashRadius: 16,
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(6),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (productItems.isNotEmpty) ...[
            const Text(
              'Sparepart',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: DashboardColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            ...productItems,
          ],
          if (serviceItems.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text(
              'Service',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: DashboardColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            ...serviceItems,
          ],
        ],
      ),
    );
  }

  Widget _buildItem({
    String? imagePath,
    required String title,
    required String sku,
    required String units,
    required String price,
  }) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: DashboardColors.surfaceContainerLowest,
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: imagePath != null
                ? Image.file(
                    File(imagePath),
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 48,
                        height: 48,
                        color: DashboardColors.surfaceContainerHighest,
                        child: const Icon(Icons.image_not_supported, color: DashboardColors.outline),
                      );
                    },
                  )
                : Container(
                    width: 48,
                    height: 48,
                    color: DashboardColors.surfaceContainerHighest,
                    child: const Icon(Icons.image, color: DashboardColors.outline),
                  ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: DashboardColors.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  sku,
                  style: const TextStyle(
                    fontSize: 12,
                    color: DashboardColors.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                units,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: DashboardColors.onSurface,
                ),
              ),
              Text(
                price,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: DashboardColors.secondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LowStockSection extends StatelessWidget {
  final ProductState prodState;
  const _LowStockSection({required this.prodState});

  @override
  Widget build(BuildContext context) {
    List<Widget> items = [];
    if (prodState is ProductLoaded) {
      final allProds = (prodState as ProductLoaded).products;
      final lowProds = allProds.where((p) => p.stock <= p.minStock).take(5).toList();
      
      for (var p in lowProds) {
        bool isCritical = p.stock == 0;
        items.add(_buildAlertItem(
          context: context,
          title: p.name,
          status: 'Sisa ${p.stock}',
          isCritical: isCritical,
        ));
        items.add(const SizedBox(height: 12));
      }
    }
    if (items.isEmpty) {
      items.add(const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Text('Semua stok aman', style: TextStyle(color: DashboardColors.outline)),
      ));
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: DashboardColors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: DashboardColors.error.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.warning_amber_rounded, color: DashboardColors.error),
              SizedBox(width: 8),
              Text(
                'Peringatan Stok',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: DashboardColors.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...items,
        ],
      ),
    );
  }

  Widget _buildAlertItem({
    required BuildContext context,
    required String title,
    required String status,
    required bool isCritical,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: DashboardColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: DashboardColors.outlineVariant.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 40,
            decoration: BoxDecoration(
              color: DashboardColors.error,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: DashboardColors.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      status,
                      style: TextStyle(
                        fontSize: 12,
                        color: isCritical ? DashboardColors.error : DashboardColors.onSurfaceVariant,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        context.read<BottomNavBloc>().add(const TapBottomNavEvent(3));
                      },
                      child: const Text(
                        'Isi Ulang',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: DashboardColors.secondary,
                          decoration: TextDecoration.underline,
                        ),
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
