import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kasirsuper/core/theme/quickpos_colors.dart';
import 'package:kasirsuper/core/widgets/notification_bell.dart';
import 'package:kasirsuper/features/product/blocs/blocs.dart';
import 'package:kasirsuper/features/transaction/blocs/transaction_bloc.dart';
import 'package:kasirsuper/features/product/models/product_model.dart';
import 'package:intl/intl.dart';
import 'package:kasirsuper/features/report/services/export_service.dart';
import 'package:kasirsuper/features/transaction/models/transaction_model.dart';
import 'package:open_filex/open_filex.dart';
import 'dart:io';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  String _selectedPeriod = 'Semua Data';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: QuickPOSColors.surface,
      appBar: AppBar(
        backgroundColor: QuickPOSColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: QuickPOSColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Laporan Penjualan',
          style: TextStyle(
            color: QuickPOSColors.onSurface,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: QuickPOSColors.onSurfaceVariant),
            onPressed: () {},
          ),
          const NotificationBell(iconColor: QuickPOSColors.primary),
        ],
      ),
      body: SafeArea(
        child: BlocBuilder<TransactionBloc, TransactionState>(
          builder: (context, txState) {
            return BlocBuilder<ProductBloc, ProductState>(
              builder: (context, prodState) {
                if (txState is TransactionLoaded && prodState is ProductLoaded) {
                  return _buildContent(context, txState, prodState);
                }
                return const Center(child: CircularProgressIndicator());
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, TransactionLoaded txState, ProductLoaded prodState) {
    final now = DateTime.now();
    var filteredTransactions = txState.transactions.where((txn) {
      final dt = DateTime.parse(txn.date);
      if (_selectedPeriod == 'Hari Ini') {
        return dt.year == now.year && dt.month == now.month && dt.day == now.day;
      } else if (_selectedPeriod == 'Kemarin') {
        final yesterday = now.subtract(const Duration(days: 1));
        return dt.year == yesterday.year && dt.month == yesterday.month && dt.day == yesterday.day;
      } else if (_selectedPeriod == '7 Hari Terakhir') {
        return now.difference(dt).inDays <= 7;
      } else if (_selectedPeriod == 'Bulan Ini') {
        return dt.year == now.year && dt.month == now.month;
      }
      return true; // Semua Data
    }).toList();

    // Kalkulasi Pendapatan, Laba, Margin
    double totalPendapatan = 0;
    double labaBersih = 0;

    for (var tx in filteredTransactions) {
      totalPendapatan += tx.totalAmount;
      if (tx.items != null) {
        for (var item in tx.items!) {
          // Find product cost
          final product = prodState.products.firstWhere(
            (p) => p.id == item.productId,
            orElse: () => ProductModel(name: '', sku: '', category: '', price: 0, cost: 0, stock: 0, minStock: 0),
          );
          labaBersih += (item.price - product.cost) * item.quantity;
        }
      }
    }
    
    double margin = totalPendapatan > 0 ? (labaBersih / totalPendapatan) * 100 : 0;
    
    // Top Categories
    Map<String, double> categoryRevenue = {};
    Map<String, int> categoryTransactions = {}; 
    
    for (var tx in filteredTransactions) {
      if (tx.items != null) {
        for (var item in tx.items!) {
          final product = prodState.products.firstWhere(
            (p) => p.id == item.productId,
            orElse: () => ProductModel(name: '', sku: '', category: 'Lainnya', price: 0, cost: 0, stock: 0, minStock: 0),
          );
          String cat = product.category.isNotEmpty ? product.category : 'Lainnya';
          categoryRevenue[cat] = (categoryRevenue[cat] ?? 0) + (item.price * item.quantity);
          categoryTransactions[cat] = (categoryTransactions[cat] ?? 0) + 1;
        }
      }
    }

    var sortedCategories = categoryRevenue.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
      
    // Top Products
    Map<int, double> productRevenue = {};
    Map<int, int> productUnits = {};
    for (var tx in filteredTransactions) {
      if (tx.items != null) {
        for (var item in tx.items!) {
          productRevenue[item.productId] = (productRevenue[item.productId] ?? 0) + (item.price * item.quantity);
          productUnits[item.productId] = (productUnits[item.productId] ?? 0) + item.quantity;
        }
      }
    }
    
    var sortedProducts = productRevenue.entries.toList()
      ..sort((a, b) {
        int unitsA = productUnits[a.key] ?? 0;
        int unitsB = productUnits[b.key] ?? 0;
        return unitsB.compareTo(unitsA);
      });

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildDateFilter(),
          const SizedBox(height: 16),
          _buildKeyMetrics(totalPendapatan, labaBersih, margin),
          const SizedBox(height: 16),
          if (sortedCategories.isNotEmpty) _buildTopCategories(sortedCategories, categoryTransactions),
          if (sortedCategories.isNotEmpty) const SizedBox(height: 16),
          if (sortedProducts.isNotEmpty) _buildTopProducts(sortedProducts, productUnits, prodState.products, totalPendapatan),
          if (sortedProducts.isNotEmpty) const SizedBox(height: 24),
          _buildExportActions(filteredTransactions, prodState.products),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildDateFilter() {
    return InkWell(
      onTap: () => _showFilterDialog(context),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: QuickPOSColors.surfaceContainerLowest,
          border: Border.all(color: QuickPOSColors.outlineVariant),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2))
          ]
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.calendar_today, color: QuickPOSColors.secondary),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('PERIODE', style: TextStyle(fontSize: 12, color: QuickPOSColors.onSurfaceVariant, fontWeight: FontWeight.bold, letterSpacing: 1)),
                    Text(_selectedPeriod, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                  ],
                )
              ],
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: QuickPOSColors.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.tune, color: Colors.white, size: 20),
            )
          ],
        ),
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    final periods = ['Hari Ini', 'Kemarin', '7 Hari Terakhir', 'Bulan Ini', 'Semua Data'];
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Text('Pilih Periode', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 16),
              ...periods.map((period) => ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                title: Text(
                  period,
                  style: TextStyle(
                    fontWeight: _selectedPeriod == period ? FontWeight.bold : FontWeight.normal,
                    color: _selectedPeriod == period ? QuickPOSColors.primary : QuickPOSColors.onSurface,
                  ),
                ),
                trailing: _selectedPeriod == period 
                    ? const Icon(Icons.check, color: QuickPOSColors.primary)
                    : null,
                onTap: () {
                  setState(() {
                    _selectedPeriod = period;
                  });
                  Navigator.pop(context);
                },
              )),
            ],
          ),
        );
      }
    );
  }

  Widget _buildKeyMetrics(double revenue, double profit, double margin) {
    String formattedRevenue = NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(revenue);
    String formattedProfit = NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(profit);
    
    return Column(
      children: [
        // Total Pendapatan
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: QuickPOSColors.surfaceContainerLowest,
            border: Border.all(color: QuickPOSColors.outlineVariant),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2))]
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Pendapatan', style: TextStyle(color: QuickPOSColors.onSurfaceVariant, fontSize: 14)),
                  const Icon(Icons.payments, color: QuickPOSColors.secondary),
                ],
              ),
              const SizedBox(height: 8),
              Text(formattedRevenue, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.trending_up, color: QuickPOSColors.secondary, size: 16),
                  const SizedBox(width: 4),
                  const Text('+12.4% vs bln lalu', style: TextStyle(color: QuickPOSColors.secondary, fontSize: 12, fontWeight: FontWeight.w500)),
                ],
              )
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            // Laba Bersih
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: QuickPOSColors.surfaceContainerLowest,
                  border: Border.all(color: QuickPOSColors.outlineVariant),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2))]
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Laba Bersih', style: TextStyle(color: QuickPOSColors.onSurfaceVariant, fontSize: 14)),
                    const SizedBox(height: 4),
                    Text(formattedProfit, style: const TextStyle(color: QuickPOSColors.secondary, fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Container(
                      height: 4,
                      width: double.infinity,
                      decoration: BoxDecoration(color: QuickPOSColors.surfaceContainer, borderRadius: BorderRadius.circular(2)),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: revenue > 0 ? (profit / revenue).clamp(0.0, 1.0) : 0,
                        child: Container(
                          decoration: BoxDecoration(color: QuickPOSColors.secondary, borderRadius: BorderRadius.circular(2)),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Margin
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: QuickPOSColors.surfaceContainerLowest,
                  border: Border.all(color: QuickPOSColors.outlineVariant),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2))]
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Margin', style: TextStyle(color: QuickPOSColors.onSurfaceVariant, fontSize: 14)),
                    const SizedBox(height: 4),
                    Text('${margin.toStringAsFixed(1)}%', style: const TextStyle(color: QuickPOSColors.primary, fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.trending_up, color: QuickPOSColors.secondary, size: 16),
                        const SizedBox(width: 4),
                        const Text('+0.5%', style: TextStyle(color: QuickPOSColors.secondary, fontSize: 12, fontWeight: FontWeight.w500)),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildTopCategories(List<MapEntry<String, double>> sortedCategories, Map<String, int> transactionsCount) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: QuickPOSColors.surfaceContainerLowest,
        border: Border.all(color: QuickPOSColors.outlineVariant),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2))]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Kategori Terlaris', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ...sortedCategories.take(3).toList().asMap().entries.map((entry) {
            int idx = entry.key;
            String cat = entry.value.key;
            double rev = entry.value.value;
            int txCount = transactionsCount[cat] ?? 0;
            String formattedRev = NumberFormat.compactCurrency(locale: 'id', symbol: 'Rp ', decimalDigits: 1).format(rev);
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                children: [
                  Text('0${idx + 1}', style: const TextStyle(color: QuickPOSColors.outline, fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 16),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(color: QuickPOSColors.surfaceContainerHigh, borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.category, color: QuickPOSColors.secondary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(cat, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                        Text('$txCount Transaksi', style: const TextStyle(fontSize: 12, color: QuickPOSColors.onSurfaceVariant)),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(formattedRev, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                      const Text('Top Profit', style: TextStyle(fontSize: 12, color: QuickPOSColors.secondary)),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildTopProducts(List<MapEntry<int, double>> sortedProducts, Map<int, int> productUnits, List<ProductModel> allProducts, double totalPendapatan) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: QuickPOSColors.surfaceContainerLowest,
        border: Border.all(color: QuickPOSColors.outlineVariant),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2))]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Produk Terlaris', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ...sortedProducts.take(3).map((entry) {
            int pId = entry.key;
            double rev = entry.value;
            int units = productUnits[pId] ?? 0;
            final product = allProducts.firstWhere((p) => p.id == pId, orElse: () => ProductModel(name: 'Unknown', sku: '-', category: '', price: 0, cost: 0, stock: 0, minStock: 0));
            String formattedRev = NumberFormat.compactCurrency(locale: 'id', symbol: 'Rp ', decimalDigits: 1).format(rev);
            
            double widthFactor = totalPendapatan > 0 ? (rev / totalPendapatan) : 0;
            widthFactor = (widthFactor * 3).clamp(0.1, 1.0);

            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(color: QuickPOSColors.surfaceContainer, borderRadius: BorderRadius.circular(8)),
                    clipBehavior: Clip.hardEdge,
                    child: (product.imagePath != null && product.imagePath!.isNotEmpty)
                        ? (product.imagePath!.startsWith('http')
                            ? Image.network(
                                product.imagePath!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => const Icon(Icons.inventory_2, color: QuickPOSColors.outline),
                              )
                            : Image.file(
                                File(product.imagePath!),
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => const Icon(Icons.inventory_2, color: QuickPOSColors.outline),
                              ))
                        : const Icon(Icons.inventory_2, color: QuickPOSColors.outline),
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
                                  Text(product.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis),
                                  Text('SKU: ${product.sku}', style: const TextStyle(fontSize: 12, color: QuickPOSColors.onSurfaceVariant)),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(formattedRev, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                                Text('$units Unit', style: const TextStyle(fontSize: 12, color: QuickPOSColors.secondary)),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 6,
                          width: double.infinity,
                          decoration: BoxDecoration(color: QuickPOSColors.surfaceContainer, borderRadius: BorderRadius.circular(3)),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: widthFactor,
                            child: Container(
                              decoration: BoxDecoration(color: QuickPOSColors.secondary, borderRadius: BorderRadius.circular(3)),
                            ),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildExportActions(List<TransactionModel> transactions, List<ProductModel> products) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              side: const BorderSide(color: QuickPOSColors.outlineVariant),
              backgroundColor: QuickPOSColors.surfaceContainerLowest,
              foregroundColor: QuickPOSColors.onSurface,
            ),
            icon: const Icon(Icons.table_chart),
            label: const Text('Unduh Excel', style: TextStyle(fontWeight: FontWeight.bold)),
            onPressed: () async {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Menyimpan Excel...'), duration: Duration(seconds: 1)),
              );
              final path = await ExportService.generateExcel(
                transactions: transactions,
                products: products,
                period: _selectedPeriod,
              );
              if (context.mounted && path != null) {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('File Excel berhasil diunduh'),
                    duration: const Duration(seconds: 5),
                    action: SnackBarAction(
                      label: 'Buka',
                      onPressed: () {
                        OpenFilex.open(path);
                      },
                    ),
                  ),
                );
              }
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              backgroundColor: QuickPOSColors.secondary,
              foregroundColor: Colors.white,
              elevation: 4,
            ),
            icon: const Icon(Icons.picture_as_pdf),
            label: const Text('Unduh PDF', style: TextStyle(fontWeight: FontWeight.bold)),
            onPressed: () async {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Menyimpan PDF...'), duration: Duration(seconds: 1)),
              );
              final path = await ExportService.generatePdf(
                transactions: transactions,
                products: products,
                period: _selectedPeriod,
              );
              if (context.mounted && path != null) {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('File PDF berhasil diunduh'),
                    duration: const Duration(seconds: 5),
                    action: SnackBarAction(
                      label: 'Buka',
                      onPressed: () {
                        OpenFilex.open(path);
                      },
                    ),
                  ),
                );
              }
            },
          ),
        ),
      ],
    );
  }
}
