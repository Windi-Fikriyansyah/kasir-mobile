import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:kasirsuper/core/core.dart';
import 'package:kasirsuper/core/theme/quickpos_colors.dart';
import 'package:kasirsuper/features/transaction/blocs/transaction_bloc.dart';
import 'package:kasirsuper/features/product/blocs/blocs.dart';

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
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const _WelcomeSection(),
                              const SizedBox(height: 24),
                              _SalesSummarySection(txState: txState),
                              const SizedBox(height: 16),
                              const _QuickActionsSection(),
                              const SizedBox(height: 24),
                              _BestSellingSection(txState: txState, prodState: prodState),
                              const SizedBox(height: 24),
                              _LowStockSection(prodState: prodState),
                            ],
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: DashboardColors.primary,
        foregroundColor: DashboardColors.onPrimary,
        shape: const CircleBorder(),
        onPressed: () {},
        child: const Icon(Icons.add),
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
                'QuickPOS',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: DashboardColors.onSurface,
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none, color: DashboardColors.onSurfaceVariant),
            onPressed: () {},
            splashRadius: 24,
          ),
        ],
      ),
    );
  }
}

class _WelcomeSection extends StatelessWidget {
  const _WelcomeSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Selamat pagi, Shift #421',
          style: TextStyle(
            fontSize: 14,
            color: DashboardColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Selamat datang kembali, Jane',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: DashboardColors.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: DashboardColors.surfaceContainer,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: DashboardColors.outlineVariant.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: DashboardColors.secondaryContainer,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Terminal POS 01 Online',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: DashboardColors.secondary,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SalesSummarySection extends StatelessWidget {
  final TransactionState txState;
  const _SalesSummarySection({required this.txState});

  @override
  Widget build(BuildContext context) {
    double todaySales = 0;
    int todayCount = 0;
    if (txState is TransactionLoaded) {
      final now = DateTime.now();
      for (var txn in (txState as TransactionLoaded).transactions) {
        final dt = DateTime.parse(txn.date);
        if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
          todaySales += txn.totalAmount;
          todayCount++;
        }
      }
    }
    double avgSales = todayCount > 0 ? todaySales / todayCount : 0;
    final formatCurrency = NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);

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
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Transaksi',
                      style: TextStyle(
                        fontSize: 12,
                        color: DashboardColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      todayCount.toString(),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: DashboardColors.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Rata-rata Belanja',
                      style: TextStyle(
                        fontSize: 12,
                        color: DashboardColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        formatCurrency.format(avgSales),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: DashboardColors.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: const [
                    Icon(Icons.trending_up, color: DashboardColors.secondary, size: 16),
                    SizedBox(width: 2),
                    Flexible(
                      child: Text(
                        '+12% vs yest.',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: DashboardColors.secondary,
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
}

class _QuickActionsSection extends StatelessWidget {
  const _QuickActionsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: DashboardColors.secondary,
              foregroundColor: DashboardColors.onSecondary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            icon: const Icon(Icons.add_circle),
            label: const Text(
              'Penjualan Baru',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DashboardColors.primaryContainer,
                    foregroundColor: DashboardColors.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.qr_code_scanner),
                  label: const Text('Pindai'),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: SizedBox(
                height: 56,
                child: OutlinedButton.icon(
                  onPressed: () {},
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
        ),
      ],
    );
  }
}

class _BestSellingSection extends StatefulWidget {
  final TransactionState txState;
  final ProductState prodState;
  const _BestSellingSection({required this.txState, required this.prodState});

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
    List<Widget> items = [];
    if (widget.txState is TransactionLoaded && widget.prodState is ProductLoaded) {
      Map<int, int> soldCounts = {};
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
            soldCounts[item.productId] = (soldCounts[item.productId] ?? 0) + item.quantity;
          }
        }
      }
      var sortedIds = soldCounts.keys.toList()..sort((a, b) => soldCounts[b]!.compareTo(soldCounts[a]!));
      
      var totalAvailable = sortedIds.length;
      var limit = _isExpanded ? 10 : 3;
      var topIds = sortedIds.take(limit).toList();
      
      final formatCurrency = NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);

      for (var id in topIds) {
        try {
          var prod = (widget.prodState as ProductLoaded).products.firstWhere((p) => p.id == id);
          items.add(_buildItem(
            imagePath: prod.imagePath,
            title: prod.name,
            sku: 'SKU: ${prod.sku}',
            units: '${soldCounts[id]} Terjual',
            price: formatCurrency.format(prod.price),
          ));
          items.add(const SizedBox(height: 12));
        } catch (_) {}
      }
      
      if (totalAvailable > 3) {
        items.add(
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

    if (items.isEmpty) {
      items.add(const Padding(
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
          ...items,
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
              color: isCritical ? DashboardColors.error : DashboardColors.surfaceDim,
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
                    Text(
                      'Isi Ulang',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: DashboardColors.secondary,
                        decoration: TextDecoration.underline,
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
