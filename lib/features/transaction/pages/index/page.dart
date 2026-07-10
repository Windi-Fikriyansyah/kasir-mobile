import 'package:flutter/material.dart';
import 'package:kasirsuper/core/theme/quickpos_colors.dart';

class TransactionPage extends StatefulWidget {
  const TransactionPage({super.key});

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  String _activeFilter = 'Hari Ini';

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
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: [
        _buildDateHeader('Hari Ini — 24 Okt 2023'),
        _buildTransactionItem(
          id: 'TXN-89021',
          timeAndItems: '14:32 • 3 item',
          price: 'Rp 142.500',
          isRefunded: false,
        ),
        const SizedBox(height: 8),
        _buildTransactionItem(
          id: 'TXN-89018',
          timeAndItems: '11:15 • 1 item',
          price: 'Rp 24.000',
          isRefunded: true,
        ),
        const SizedBox(height: 8),
        _buildTransactionItem(
          id: 'TXN-89015',
          timeAndItems: '09:45 • 12 item',
          price: 'Rp 892.120',
          isRefunded: false,
        ),
        const SizedBox(height: 24),
        _buildDateHeader('Kemarin — 23 Okt 2023'),
        _buildTransactionItem(
          id: 'TXN-88950',
          timeAndItems: '18:12 • 2 item',
          price: 'Rp 56.000',
          isRefunded: false,
        ),
      ],
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
  }) {
    return InkWell(
      onTap: () => _showReceiptModal(id),
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

  void _showReceiptModal(String txnId) {
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
                      const Text(
                        'QuickPOS Retail',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: QuickPOSColors.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Store #4421 • Downtown Hub',
                        style: TextStyle(
                          fontSize: 14,
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
                        _buildReceiptItem('Organic Espresso Beans (500g)', 'Rp 18.500'),
                        const SizedBox(height: 8),
                        _buildReceiptItem('Ceramic Pour-over Kit', 'Rp 45.000'),
                        const SizedBox(height: 8),
                        _buildReceiptItem('Barista Grade Oat Milk (x4)', 'Rp 14.000'),
                        const SizedBox(height: 24),
                        const Divider(color: QuickPOSColors.outlineVariant),
                        const SizedBox(height: 16),
                        _buildReceiptRow('Subtotal', 'Rp 77.500'),
                        const SizedBox(height: 8),
                        _buildReceiptRow('Pajak (8%)', 'Rp 6.200'),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text(
                              'Total',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Rp 83.700',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'DIBAYAR VIA VISA **** 4242',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: QuickPOSColors.outline,
                            letterSpacing: 1.0,
                          ),
                        ),
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

  Widget _buildReceiptItem(String name, String price) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            name,
            style: const TextStyle(
              fontSize: 14,
              color: QuickPOSColors.onSurfaceVariant,
            ),
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
                'QuickPOS',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: QuickPOSColors.onSurface,
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none, color: QuickPOSColors.onSurfaceVariant),
            onPressed: () {},
            splashRadius: 24,
          ),
        ],
      ),
    );
  }
}
