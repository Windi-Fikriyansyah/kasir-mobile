import 'package:flutter/material.dart';
import 'package:kasirsuper/core/theme/quickpos_colors.dart';
import 'package:kasirsuper/features/pos/pages/checkout/page.dart';

class POSPage extends StatefulWidget {
  const POSPage({super.key});

  @override
  State<POSPage> createState() => _POSPageState();
}

class _POSPageState extends State<POSPage> {
  int cartCount = 0;
  double cartTotal = 0.0;
  String activeCategory = 'Semua Item';

  void addToCart(String name, double price) {
    setState(() {
      cartCount++;
      cartTotal += price;
    });

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$name ditambahkan ke keranjang!'),
        duration: const Duration(milliseconds: 1500),
        backgroundColor: QuickPOSColors.secondary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void filterCategory(String category) {
    setState(() {
      activeCategory = category;
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
            const _SearchBarSection(),
            _CategoryChips(
              activeCategory: activeCategory,
              onCategoryTap: filterCategory,
            ),
                    Expanded(
                      child: _ProductGrid(onAddToCart: addToCart),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _CheckoutBottomBar(
        count: cartCount,
        total: cartTotal,
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

class _SearchBarSection extends StatelessWidget {
  const _SearchBarSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Cari produk atau SKU...',
          hintStyle: const TextStyle(color: QuickPOSColors.outline, fontSize: 16),
          prefixIcon: const Icon(Icons.search, color: QuickPOSColors.outline),
          suffixIcon: IconButton(
            icon: const Icon(Icons.qr_code_scanner, color: QuickPOSColors.onSurfaceVariant),
            onPressed: () {},
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
  final String activeCategory;
  final Function(String) onCategoryTap;

  const _CategoryChips({required this.activeCategory, required this.onCategoryTap});

  @override
  Widget build(BuildContext context) {
    final categories = ['Semua Item', 'Cemilan', 'Minuman', 'Rumah Tangga', 'Elektronik', 'Kesehatan'];
    
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
  final Function(String, double) onAddToCart;

  const _ProductGrid({required this.onAddToCart});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 32),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 0.65, 
      children: [
        _buildProductCard(
          image: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBcR7wo7SYKIHXOGEtPGpCKt0UMSxscZvUE3ftXSekf8ebzTyaiJmsILJuUlvEmlXyHLkO_DR0zWUtR-YeZRLch8ArXQ6wP5paA6_9ctGRZvAQCgsPen_RggSDEyzHgv2qxZg7j4Ic7lIh4iv6rXf7lMvHkBhjgo6yIWTZ10yowiXMJzKSK60TKSUNfwNp7TIYKHec678b6tLa5bwkXtm6IDuw1sGwV7uoD__xI0rp4O85SxD8bWsnJIg',
          category: 'Minuman',
          title: 'Blue Volt Energy',
          price: 3.50,
          tag: 'TERSEDIA',
          tagColor: QuickPOSColors.secondaryContainer,
          tagTextColor: QuickPOSColors.onSecondaryContainer,
        ),
        _buildProductCard(
          image: 'https://lh3.googleusercontent.com/aida-public/AB6AXuAFfsi8de6V88l0PeeXzDFDKf0P6o5Fv6PHoDUs-tpCgUAGBxssWlG1JGh4BpC6lI_l2yMU2MvkpbXglq1OmWi2G7aXwmoieLSk3PtLH-h8ZwNldeBfjSufoPg9eaqXRh5PFYP-2qNi6A7EucxKoufzr92ABDjyOr-KN07WRnPatiPsERiN_zqm6XaDA9dhfsmB7IwRFUWOx5kC44QkWowgXYH0Ta7-I6USJrhfO2o31OUIRXa1hTGO7w',
          category: 'Cemilan',
          title: 'Sea Salt Crisps',
          price: 2.25,
        ),
        _buildProductCard(
          image: 'https://lh3.googleusercontent.com/aida-public/AB6AXuCKdbMsXyY4umpgjcClkd_DrA_qTZXF2mCREaAWp8rUgb_fuEsZZafSgXBTuqcBKnHQIRrRiMluCJsZEBRLWxY4O0HSwv6SZGWIL1xvp2WzzZ4nZUy_mAc4AJlB6VwBxPQwj3nlQdPM9nX3yKAKLuobQ5CF25q3IZyTc3hSrIYJJOdjc9tBNn5p1V7yDaXyUO6xNXOI2eKT32p8qU75jtunirWFLSUaJ58KI_kDVuFRDpDD2vZnsghqWA',
          category: 'Rumah Tangga',
          title: 'Eco Glass Cleaner',
          price: 5.99,
        ),
        _buildProductCard(
          image: 'https://lh3.googleusercontent.com/aida-public/AB6AXuDNC4kNb1RQdIQOntLpbFHvFHfu833fwoUDTRPhhZtKC8lNPjjgoFTAW-9KkAcmXP46h-AZz9zh4L8Oj_Tr09KW-8Spp7LrxzIh23ecAlnMo_Mf0J48JqqunBOW6VHladc6Yoyk0DZXWXBOTXH7iGrBrsSgnZ0vulKPDmg0pCr7fhcoRQmRjAFTVxVjpqVKayDVnKiAWnxoUSZD_zhxH7EjeFzal2AznI00hGnoRSx6wdguw5OA5X84LQ',
          category: 'Elektronik',
          title: 'Sonic Buds Lite',
          price: 29.00,
        ),
        _buildProductCard(
          image: 'https://lh3.googleusercontent.com/aida-public/AB6AXuCKBLA5dM9yufcxPph8N0hIqQh7mjtelCCw0d3C3SBWTf3HF55-eoeMjz70hFeKAMJyQeQY1XqJ7a3AMcQ1AGu0mSjsKZ-nhVnZ1U6WwjahKp5uzyp4Mfici-Zp-2a32NpzTF4cKA_ESUqkntwddeLuNQ8rA07A3DXVpqbLKuAZ01FCYTaPfIAO0L3UjMD0AgNryG8uJPvHafM-K-OPxi37vUXKcrdVlNnneSGOjtB-QiItRVcpKNjffQ',
          category: 'Minuman',
          title: 'Sparkling Water',
          price: 1.50,
        ),
        _buildProductCard(
          image: 'https://lh3.googleusercontent.com/aida-public/AB6AXuAoE2Hb2M93H-BgQRU3Xnl9Y9rp4pHyJSSqeU-tIwQEIReA6Xxnq98ERZdEJKeCnstAS9lQtP2YW5cIXyF9XjfwjV_BELuG8Tft15Xa4bNRqe3Lb6Vcgf49en_UIb16FLvIE3fzSW7R-Y8TLwVQs4SzcjX6wAaXO9832kZ2znHreK-3cuE4vHSzrU3Zxqwjo2us9aEJa7idWJ35SP7eQUO7GB38cfZ9aJ4g4IBlxbncYrpWF81kEosmYg',
          category: 'Kesehatan',
          title: 'Daily Multivitamins',
          price: 14.99,
          tag: 'Stok Menipis',
          tagColor: QuickPOSColors.errorContainer,
          tagTextColor: QuickPOSColors.onErrorContainer,
        ),
      ],
    );
  }

  Widget _buildProductCard({
    required String image,
    required String category,
    required String title,
    required double price,
    String? tag,
    Color? tagColor,
    Color? tagTextColor,
  }) {
    // Custom price formatter
    final formattedPrice = 'Rp ${price.toStringAsFixed(0)}';
    
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
            flex: 4,
            child: Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: Image.network(image, fit: BoxFit.cover),
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
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 10,
                          color: QuickPOSColors.outline,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: QuickPOSColors.onSurface,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        formattedPrice,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: QuickPOSColors.onSurface,
                        ),
                      ),
                      InkWell(
                        onTap: () => onAddToCart(title, price),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: const BoxDecoration(
                            color: QuickPOSColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.add, color: QuickPOSColors.onPrimary, size: 20),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
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
    final formattedTotal = 'Rp ${total.toStringAsFixed(0)}';
    
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
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
                  const SizedBox(width: 12),
                  Flexible(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'RINGKASAN KERANJANG',
                          style: TextStyle(
                            fontSize: 10,
                            color: QuickPOSColors.outline,
                          ),
                        ),
                        Text(
                          '$count Item',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: QuickPOSColors.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'TOTAL',
                      style: TextStyle(
                        fontSize: 10,
                        color: QuickPOSColors.outline,
                      ),
                    ),
                    Text(
                      formattedTotal,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: QuickPOSColors.onSurface,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: count > 0 
                      ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CheckoutPage(
                                cartCount: count,
                                cartTotal: total,
                              ),
                            ),
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: QuickPOSColors.secondary,
                    foregroundColor: QuickPOSColors.onSecondary,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Text('BAYAR', style: TextStyle(fontWeight: FontWeight.bold)),
                  label: const Icon(Icons.arrow_forward, size: 20),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
