import 'package:flutter/material.dart';
import 'package:kasirsuper/core/core.dart';

import 'package:kasirsuper/core/theme/quickpos_colors.dart';

typedef DashboardColors = QuickPOSColors;

class HomePage extends StatelessWidget {
  const HomePage({super.key});

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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: const [
                    _WelcomeSection(),
              SizedBox(height: 24),
              _SalesSummarySection(),
              SizedBox(height: 16),
              _QuickActionsSection(),
              SizedBox(height: 24),
              _BestSellingSection(),
              SizedBox(height: 24),
              _LowStockSection(),
                  ],
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
  const _SalesSummarySection();

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "RINGKASAN PENJUALAN HARI INI",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: DashboardColors.onSurfaceVariant,
                        letterSpacing: 1.0,
                      ),
                    ),
                    SizedBox(height: 4),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Rp 4.829.500',
                        style: TextStyle(
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
                  children: const [
                    Text(
                      'Transaksi',
                      style: TextStyle(
                        fontSize: 12,
                        color: DashboardColors.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '142',
                      style: TextStyle(
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
                  children: const [
                    Text(
                      'Rata-rata Belanja',
                      style: TextStyle(
                        fontSize: 12,
                        color: DashboardColors.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(height: 4),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Rp 34.010',
                        style: TextStyle(
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

class _BestSellingSection extends StatelessWidget {
  const _BestSellingSection();

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Terlaris',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: DashboardColors.onSurface,
                ),
              ),
              Text(
                'Minggu Ini',
                style: TextStyle(
                  fontSize: 12,
                  color: DashboardColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildItem(
            image: 'https://lh3.googleusercontent.com/aida-public/AB6AXuC7CcKe24_pGCilrPAMwAIZaEZTHzSKKn45SoX0g0kJaBDBjFXuZTUYxCH4EQuyHCBO7MeMAcj6wZu4bTZyPQHJjtrKtBChD-u6lKlG3CqQ8QKRiZ5HdfLYVlOvOVHDNMb83pFEvNF62qp3amWP0iXwLXpY3_LJIeVVlGejmvrBjkEZ-zynqlTXbOo6QWqEyjHfQ_sIqjnt2QsD7GNZTuDKivgSs5wzm2gFg2OT8YrukNEfvwkDbCt2FQ',
            title: 'Voss Glass Bottle',
            sku: 'SKU: VOS-9921',
            units: '42 Unit',
            price: 'Rp 1.050.000',
          ),
          const SizedBox(height: 12),
          _buildItem(
            image: 'https://lh3.googleusercontent.com/aida-public/AB6AXuDKZYpK0jahLv6AqOMSfRs2WKUBokLBjWjgrApABTI-ISxzJoxRLiobILkvV22Q6fXDqU7uTgzlJiYnYQpac37AIYuxTSeyfF6bAkVs-DLXT7ThtjohI54DsJulCZ9LfwafQVPAiiOv1gzn33DfbpSGOTFarVQVhVK9skvAI9VxE8xpxCWzVig2ZLbgEs5ErgpahGVSXjfSqNQ3THjWoRQG0GVczbEXGa9Q026YwY2Cci-IgBu7MIQRQw',
            title: 'Dark Roast Blend',
            sku: 'SKU: COF-1102',
            units: '38 Unit',
            price: 'Rp 722.000',
          ),
          const SizedBox(height: 12),
          _buildItem(
            image: 'https://lh3.googleusercontent.com/aida-public/AB6AXuCOcLW3Xuwa9PQboQqwfg5OJw6TsCKZF3BxVoqbVMC2foookney2F3ziTy7RJVy1W3ntOLPazo9RVgZwcCVOb4c8yboxY36L5ULF1lWrrIOs38_AiOR39tKdNgPVuQbG6e6HUkNdC1TL91JOKafWoka2mc2jhkTCxG8lYb9cCidTs8PTnARodx80pUVXSb0YkrxMiNTVVQT7A2MWarsPJhu0T9a6W47RRvHm3T7P3Uc6uALkFRX0F3eNw',
            title: 'Eco Linen Tote',
            sku: 'SKU: BAG-4581',
            units: '29 Unit',
            price: 'Rp 435.000',
          ),
        ],
      ),
    );
  }

  Widget _buildItem({
    required String image,
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
            child: Image.network(
              image,
              width: 48,
              height: 48,
              fit: BoxFit.cover,
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
                ),
                Text(
                  sku,
                  style: const TextStyle(
                    fontSize: 12,
                    color: DashboardColors.onSurfaceVariant,
                  ),
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
  const _LowStockSection();

  @override
  Widget build(BuildContext context) {
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
                'Stok Menipis',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: DashboardColors.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildAlertItem(
            title: 'Almond Milk 1L',
            status: 'Sisa 2',
            isCritical: true,
          ),
          const SizedBox(height: 12),
          _buildAlertItem(
            title: 'Paper Straws (50pk)',
            status: 'Sisa 5',
            isCritical: true,
          ),
          const SizedBox(height: 12),
          _buildAlertItem(
            title: 'Napkins (White)',
            status: 'Sisa 12',
            isCritical: false,
          ),
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
