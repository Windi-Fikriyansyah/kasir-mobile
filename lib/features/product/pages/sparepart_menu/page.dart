import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kasirsuper/core/theme/quickpos_colors.dart';
import 'package:kasirsuper/features/home/blocs/blocs.dart';
import 'package:kasirsuper/features/product/pages/index/page.dart';
import 'package:kasirsuper/features/product/pages/stock_in/page.dart';
import 'package:kasirsuper/features/product/pages/stock_opname/page.dart';
import 'package:kasirsuper/features/product/pages/stock_history/page.dart';
import 'package:kasirsuper/core/widgets/notification_bell.dart';

class SparepartMenuPage extends StatelessWidget {
  const SparepartMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const _SparepartMenuAppBar(),
            Expanded(
              child: Container(
                color: QuickPOSColors.surface,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
        child: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.9,
          children: [
            _buildMenuCard(
              context,
              icon: Icons.inventory_2,
              title: 'Data Sparepart',
              color: Colors.blue,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProductPage()),
                );
              },
            ),
            _buildMenuCard(
              context,
              icon: Icons.add_box,
              title: 'Stok Masuk',
              color: Colors.green,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const StockInPage()),
                );
              },
            ),
            _buildMenuCard(
              context,
              icon: Icons.inventory,
              title: 'Stok Opname',
              color: Colors.orange,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const StockOpnamePage()),
                );
              },
            ),
            _buildMenuCard(
              context,
              icon: Icons.history,
              title: 'Riwayat Stok',
              color: Colors.purple,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const StockHistoryPage()),
                );
              },
            ),
          ],
        ),
      ),
    ),
  ),
],
        ),
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, {required IconData icon, required String title, required Color color, required VoidCallback onTap}) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 2,
      shadowColor: Colors.black12,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 40),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: QuickPOSColors.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PlaceholderPage extends StatelessWidget {
  final String title;
  const PlaceholderPage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: QuickPOSColors.surface,
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.white,
        foregroundColor: QuickPOSColors.onSurface,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.construction, size: 80, color: QuickPOSColors.outline),
            const SizedBox(height: 16),
            Text(
              'Halaman $title',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: QuickPOSColors.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Sedang dalam pengembangan',
              style: TextStyle(
                color: QuickPOSColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SparepartMenuAppBar extends StatelessWidget {
  const _SparepartMenuAppBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 8),
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
