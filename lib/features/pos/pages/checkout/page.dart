import 'package:flutter/material.dart';
import 'package:kasirsuper/core/theme/quickpos_colors.dart';

class CheckoutPage extends StatefulWidget {
  final int cartCount;
  final double cartTotal;

  const CheckoutPage({
    super.key,
    required this.cartCount,
    required this.cartTotal,
  });

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  String? selectedPaymentMethod;
  final TextEditingController _amountController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _selectPayment(String method) {
    setState(() {
      selectedPaymentMethod = method;
    });
  }

  void _handlePayment() {
    if (selectedPaymentMethod == 'cash') {
      double? paidAmount = double.tryParse(_amountController.text);
      if (paidAmount == null || paidAmount < widget.cartTotal) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Nominal bayar kurang atau tidak valid!'),
            backgroundColor: QuickPOSColors.error,
          ),
        );
        return;
      }
    }
    
    // Payment Successful
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pembayaran Berhasil!'),
        backgroundColor: QuickPOSColors.secondary,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const _CheckoutAppBar(),
            Expanded(
              child: Container(
                color: QuickPOSColors.surface,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _OrderSummarySection(
                      cartCount: widget.cartCount,
                      cartTotal: widget.cartTotal,
                    ),
                    const SizedBox(height: 24),
                    _PaymentCategoriesSection(
                      selectedMethod: selectedPaymentMethod,
                      onSelect: _selectPayment,
                    ),
                  ],
                ),
              ),
            ),
            ),
            _BottomActionBar(
              selectedMethod: selectedPaymentMethod,
              cartTotal: widget.cartTotal,
              amountController: _amountController,
              onPayPressed: _handlePayment,
            ),
          ],
        ),
      ),
    );
  }
}

class _CheckoutAppBar extends StatelessWidget {
  const _CheckoutAppBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: QuickPOSColors.primary),
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(width: 8),
              const Text(
                'Metode Pembayaran',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: QuickPOSColors.onSurface,
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Icon(Icons.storefront, color: QuickPOSColors.primary),
          ),
        ],
      ),
    );
  }
}

class _OrderSummarySection extends StatelessWidget {
  final int cartCount;
  final double cartTotal;

  const _OrderSummarySection({
    required this.cartCount,
    required this.cartTotal,
  });

  @override
  Widget build(BuildContext context) {
    final formattedTotal = '\$${cartTotal.toStringAsFixed(2)}'; // using $ based on previous design, or Rp based on HTML
    final realFormat = 'Rp ${cartTotal.toStringAsFixed(0)}';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: QuickPOSColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: QuickPOSColors.outlineVariant),
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
          const Text(
            'Total Pembayaran',
            style: TextStyle(
              fontSize: 14,
              color: QuickPOSColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            realFormat, // Reverted to real format to match state
            style: const TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: QuickPOSColors.secondary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 16),
          _buildDummyItem('Blue Volt Energy (1x)', 'Rp 3.500'),
          const SizedBox(height: 8),
          _buildDummyItem('Sea Salt Crisps (2x)', 'Rp 4.500'),
          const SizedBox(height: 16),
          const Divider(color: QuickPOSColors.outlineVariant),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'ORDER ID: #POS-20231024',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: QuickPOSColors.onSurfaceVariant,
                  letterSpacing: 1.0,
                ),
              ),
              Text(
                '$cartCount Item${cartCount != 1 ? 's' : ''}',
                style: const TextStyle(
                  fontSize: 14,
                  color: QuickPOSColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDummyItem(String name, String price) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          name,
          style: const TextStyle(
            fontSize: 14,
            color: QuickPOSColors.onSurfaceVariant,
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
}

class _PaymentCategoriesSection extends StatelessWidget {
  final String? selectedMethod;
  final Function(String) onSelect;

  const _PaymentCategoriesSection({
    required this.selectedMethod,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCategoryTitle('TUNAI'),
        _buildPaymentOption(
          id: 'cash',
          icon: Icons.payments,
          title: 'Tunai (Cash)',
          subtitle: 'Paling sering digunakan',
          iconBgColor: QuickPOSColors.secondaryContainer,
          iconColor: QuickPOSColors.onSecondaryContainer,
        ),
        const SizedBox(height: 24),
        _buildCategoryTitle('PEMBAYARAN DIGITAL'),
        _buildPaymentOption(
          id: 'qris',
          icon: Icons.qr_code_2,
          title: 'QRIS',
          subtitle: 'Scan QR Code apa saja',
          iconBgColor: QuickPOSColors.surfaceContainer,
          iconColor: QuickPOSColors.primary,
        ),
        const SizedBox(height: 8),
        _buildPaymentOption(
          id: 'ewallet',
          icon: Icons.account_balance_wallet,
          title: 'E-Wallet',
          subtitle: 'GoPay, OVO, ShopeePay',
          iconBgColor: QuickPOSColors.surfaceContainer,
          iconColor: QuickPOSColors.primary,
        ),
        const SizedBox(height: 24),
        _buildCategoryTitle('KARTU'),
        _buildPaymentOption(
          id: 'card',
          icon: Icons.credit_card,
          title: 'Kartu Kredit/Debit',
          subtitle: 'Visa, Mastercard, GPN',
          iconBgColor: QuickPOSColors.surfaceContainer,
          iconColor: QuickPOSColors.primary,
        ),
      ],
    );
  }

  Widget _buildCategoryTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: QuickPOSColors.onSurfaceVariant,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildPaymentOption({
    required String id,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconBgColor,
    required Color iconColor,
  }) {
    final isSelected = selectedMethod == id;

    return GestureDetector(
      onTap: () => onSelect(id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: QuickPOSColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? QuickPOSColors.secondary : QuickPOSColors.outlineVariant,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: QuickPOSColors.secondary.withOpacity(0.1),
                blurRadius: 8,
                spreadRadius: 2,
              ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: iconColor),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: QuickPOSColors.onSurface,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: QuickPOSColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? QuickPOSColors.secondary : QuickPOSColors.outlineVariant,
                  width: 2,
                ),
                color: Colors.transparent,
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: QuickPOSColors.secondary, // The mockup uses white inner but with solid green background. We'll adapt it.
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomActionBar extends StatelessWidget {
  final String? selectedMethod;
  final double cartTotal;
  final TextEditingController amountController;
  final VoidCallback onPayPressed;

  const _BottomActionBar({
    required this.selectedMethod,
    required this.cartTotal,
    required this.amountController,
    required this.onPayPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isPaymentSelected = selectedMethod != null;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: QuickPOSColors.surfaceContainerLowest,
        border: Border(top: BorderSide(color: QuickPOSColors.outlineVariant.withOpacity(0.5))),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (selectedMethod == 'cash') ...[
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                child: Text(
                  'NOMINAL BAYAR',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: QuickPOSColors.onSurfaceVariant,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
              TextField(
                controller: amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: QuickPOSColors.onSurface),
                decoration: InputDecoration(
                  prefixText: 'Rp ',
                  prefixStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: QuickPOSColors.onSurfaceVariant),
                  hintText: '0.00',
                  contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: QuickPOSColors.outlineVariant),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: QuickPOSColors.secondary, width: 2),
                  ),
                  filled: true,
                  fillColor: QuickPOSColors.surfaceContainerLow,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                decoration: BoxDecoration(
                  color: QuickPOSColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Kembalian',
                      style: TextStyle(fontSize: 14, color: QuickPOSColors.onSurfaceVariant),
                    ),
                    ValueListenableBuilder<TextEditingValue>(
                      valueListenable: amountController,
                      builder: (context, value, child) {
                        double paidAmount = double.tryParse(value.text) ?? 0.0;
                        double change = paidAmount - cartTotal;
                        if (change < 0) change = 0;
                        
                        return Text(
                          'Rp ${change.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: QuickPOSColors.secondary,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            ElevatedButton(
              onPressed: isPaymentSelected ? onPayPressed : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: isPaymentSelected ? QuickPOSColors.secondary : QuickPOSColors.outlineVariant,
                foregroundColor: isPaymentSelected ? QuickPOSColors.onSecondary : QuickPOSColors.onSurfaceVariant,
                disabledBackgroundColor: QuickPOSColors.outlineVariant,
                disabledForegroundColor: QuickPOSColors.onSurfaceVariant,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: isPaymentSelected ? 2 : 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text(
                    'Bayar Sekarang',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
