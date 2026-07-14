import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:kasirsuper/core/theme/quickpos_colors.dart';
import 'package:kasirsuper/features/transaction/blocs/transaction_bloc.dart';
import 'package:kasirsuper/features/transaction/models/transaction_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kasirsuper/core/widgets/notification_bell.dart';

class TransactionPage extends StatefulWidget {
  const TransactionPage({super.key});

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  String _activeFilter = 'Hari Ini';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<TransactionBloc>().add(LoadTransactions());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const _TransactionAppBar(),
            Expanded(
              child: Container(
                color: QuickPOSColors.surface,
                child: Column(
                  children: [
                    _buildSearchAndFilter(),
                    Expanded(
                      child: _buildTransactionList(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      color: QuickPOSColors.surface,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Riwayat Transaksi',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: QuickPOSColors.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Tinjau dan kelola pesanan pelanggan lalu.',
            style: TextStyle(
              fontSize: 14,
              color: QuickPOSColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          // Search Bar
          TextField(
            controller: _searchController,
            onChanged: (val) {
              setState(() {
                _searchQuery = val;
              });
            },
            decoration: InputDecoration(
              hintText: 'Cari ID Transaksi...',
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
          const SizedBox(height: 16),
          // Filters
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('Hari Ini'),
                _buildFilterChip('Kemarin'),
                _buildFilterChip('7 Hari Terakhir'),
                _buildCustomRangeChip(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isActive = _activeFilter == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: () => setState(() => _activeFilter = label),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? QuickPOSColors.primary : QuickPOSColors.surfaceContainer,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isActive ? QuickPOSColors.primary : QuickPOSColors.outlineVariant,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isActive ? QuickPOSColors.onPrimary : QuickPOSColors.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomRangeChip() {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: QuickPOSColors.surfaceContainer,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: QuickPOSColors.outlineVariant),
        ),
        child: Row(
          children: const [
            Icon(Icons.calendar_month, size: 18, color: QuickPOSColors.onSurfaceVariant),
            SizedBox(width: 4),
            Text(
              'Rentang Khusus',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: QuickPOSColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionList() {
    return BlocBuilder<TransactionBloc, TransactionState>(
      builder: (context, state) {
        if (state is TransactionLoading || state is TransactionInitial) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (state is TransactionLoaded) {
          final formatCurrency = NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);
          final now = DateTime.now();
          
          var filtered = state.transactions.where((txn) {
            final dt = DateTime.parse(txn.date);
            bool matchDate = true;
            if (_activeFilter == 'Hari Ini') {
              matchDate = dt.year == now.year && dt.month == now.month && dt.day == now.day;
            } else if (_activeFilter == 'Kemarin') {
              final yesterday = now.subtract(const Duration(days: 1));
              matchDate = dt.year == yesterday.year && dt.month == yesterday.month && dt.day == yesterday.day;
            } else if (_activeFilter == '7 Hari Terakhir') {
              matchDate = now.difference(dt).inDays <= 7;
            }
            
            bool matchSearch = true;
            if (_searchQuery.isNotEmpty) {
              final txnId = 'TXN-${txn.id.toString().padLeft(4, '0')}';
              matchSearch = txnId.toLowerCase().contains(_searchQuery.toLowerCase());
            }
            
            return matchDate && matchSearch;
          }).toList();
          
          if (filtered.isEmpty) {
            return const Center(
              child: Text('Tidak ada transaksi', style: TextStyle(color: QuickPOSColors.outline)),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final txn = filtered[index];
              final dt = DateTime.parse(txn.date);
              final timeStr = DateFormat('HH:mm').format(dt);
              final dateStr = DateFormat('dd MMM yyyy').format(dt);
              
              int totalItems = txn.items?.fold<int>(0, (sum, i) => sum + i.quantity) ?? 0;
              final txnId = 'TXN-${txn.id.toString().padLeft(4, '0')}';

              bool showHeader = false;
              if (index == 0) {
                showHeader = true;
              } else {
                final prevDt = DateTime.parse(filtered[index-1].date);
                if (DateFormat('dd MMM yyyy').format(prevDt) != dateStr) {
                  showHeader = true;
                }
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (showHeader) _buildDateHeader(dateStr),
                  _buildTransactionItem(
                    id: txnId,
                    timeAndItems: '$timeStr • $totalItems item',
                    price: formatCurrency.format(txn.totalAmount),
                    isRefunded: false,
                    transaction: txn,
                  ),
                  const SizedBox(height: 8),
                ],
              );
            },
          );
        }
        
        return const Center(child: Text('Gagal memuat transaksi', style: TextStyle(color: QuickPOSColors.error)));
      },
    );
  }

  Widget _buildDateHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: QuickPOSColors.outline,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildTransactionItem({
    required String id,
    required String timeAndItems,
    required String price,
    required bool isRefunded,
    required TransactionModel transaction,
  }) {
    return InkWell(
      onTap: () => _showReceiptModal(id, transaction),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: QuickPOSColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.transparent),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 4,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isRefunded ? QuickPOSColors.errorContainer : QuickPOSColors.secondaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isRefunded ? Icons.keyboard_return : Icons.shopping_bag,
                    color: isRefunded ? QuickPOSColors.onErrorContainer : QuickPOSColors.onSecondaryContainer,
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      id,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: QuickPOSColors.onSurface,
                        decoration: isRefunded ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    Text(
                      timeAndItems,
                      style: const TextStyle(
                        fontSize: 12,
                        color: QuickPOSColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  price,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: QuickPOSColors.onSurface,
                    decoration: isRefunded ? TextDecoration.lineThrough : null,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: isRefunded ? QuickPOSColors.error : QuickPOSColors.secondary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isRefunded ? 'DIKEMBALIKAN' : 'SUKSES',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isRefunded ? QuickPOSColors.error : QuickPOSColors.secondary,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showReceiptModal(String txnId, TransactionModel txn) async {
    final prefs = await SharedPreferences.getInstance();
    final storeName = prefs.getString('receipt_store_name') ?? 'BengkelPro';
    final storeAddress = prefs.getString('receipt_store_address') ?? 'Alamat Toko';
    final storePhone = prefs.getString('receipt_store_phone') ?? '08123456789';
    final footer = prefs.getString('receipt_footer') ?? 'Terima kasih telah berbelanja!';
    final showMechanic = prefs.getBool('receipt_show_mechanic') ?? true;

    final formatCurrency = NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);
    
    if (!mounted) return;
    
    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(16),
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 400),
            decoration: BoxDecoration(
              color: QuickPOSColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: QuickPOSColors.outlineVariant,
                        style: BorderStyle.solid,
                      ),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        storeName,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: QuickPOSColors.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        storeAddress,
                        style: const TextStyle(
                          fontSize: 14,
                          color: QuickPOSColors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Telp: $storePhone',
                        style: const TextStyle(
                          fontSize: 12,
                          color: QuickPOSColors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: QuickPOSColors.surfaceContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          txnId,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Body
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        if (txn.items != null)
                          ...txn.items!.map((item) {
                            String subtitleText = item.itemType == 'service' ? 'Jasa' : 'Sparepart';
                            if (showMechanic && item.itemType == 'service' && item.mechanicName != null) {
                              subtitleText += ' • Mekanik: ${item.mechanicName}';
                            }
                            return Column(
                              children: [
                                _buildReceiptItem(
                                  '${item.productName} (${item.quantity}x)',
                                  formatCurrency.format(item.price * item.quantity),
                                  subtitle: subtitleText,
                                ),
                                const SizedBox(height: 8),
                              ],
                            );
                          }),
                        const SizedBox(height: 16),
                        const Divider(color: QuickPOSColors.outlineVariant),
                        const SizedBox(height: 16),
                        Builder(
                          builder: (context) {
                            final subtotal = (txn.items ?? []).fold<double>(
                              0.0,
                              (sum, item) => sum + (item.price * item.quantity),
                            );
                            
                            final hasDiscount = txn.discountPercent != null && txn.discountPercent! > 0;
                            final discountAmount = hasDiscount ? subtotal * (txn.discountPercent! / 100) : 0.0;
                            
                            final hasTax = txn.taxPercent != null && txn.taxPercent! > 0;
                            final taxAmount = hasTax ? (subtotal - discountAmount) * (txn.taxPercent! / 100) : 0.0;
                            
                            return Column(
                              children: [
                                _buildReceiptRow('Subtotal', formatCurrency.format(subtotal)),
                                if (hasDiscount) ...[
                                  const SizedBox(height: 8),
                                  _buildReceiptRow('Diskon (${txn.discountPercent}%)', '- ${formatCurrency.format(discountAmount)}'),
                                ],
                                if (hasTax) ...[
                                  const SizedBox(height: 8),
                                  _buildReceiptRow('PPN (${txn.taxPercent}%)', '+ ${formatCurrency.format(taxAmount)}'),
                                ],
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Total',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      formatCurrency.format(txn.totalAmount),
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'DIBAYAR VIA ${txn.paymentMethod.toUpperCase()}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: QuickPOSColors.outline,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildReceiptRow('Tunai / Bayar', formatCurrency.format(txn.amountGiven)),
                        _buildReceiptRow('Kembali', formatCurrency.format(txn.change)),
                        const SizedBox(height: 16),
                        // Fake barcode
                        SizedBox(
                          height: 64,
                          width: double.infinity,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(40, (index) {
                              final width = (index % 3 == 0) ? 4.0 : (index % 2 == 0 ? 2.0 : 6.0);
                              return Container(
                                width: width,
                                margin: const EdgeInsets.only(right: 2),
                                color: Colors.black87,
                              );
                            }),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          footer,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                            color: QuickPOSColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Footer
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: QuickPOSColors.surfaceContainerLow,
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(ctx),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: const BorderSide(color: QuickPOSColors.outlineVariant),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text(
                            'Tutup',
                            style: TextStyle(
                              color: QuickPOSColors.onSurface,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: QuickPOSColors.secondary,
                            foregroundColor: QuickPOSColors.onSecondary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          icon: const Icon(Icons.print, size: 20),
                          label: const Text(
                            'Cetak',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildReceiptItem(String name, String price, {String? subtitle}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 14,
                  color: QuickPOSColors.onSurfaceVariant,
                ),
              ),
              if (subtitle != null)
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: QuickPOSColors.outline,
                  ),
                ),
            ],
          ),
        ),
        Text(
          price,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: QuickPOSColors.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildReceiptRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: QuickPOSColors.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            color: QuickPOSColors.onSurface,
          ),
        ),
      ],
    );
  }
}

class _TransactionAppBar extends StatelessWidget {
  const _TransactionAppBar();

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
                'BengkelPro',
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
