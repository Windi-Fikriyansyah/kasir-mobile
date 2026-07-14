import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:kasirsuper/core/theme/quickpos_colors.dart';
import 'package:kasirsuper/features/pos/blocs/pos_bloc.dart';
import 'package:kasirsuper/features/pos/models/cart_item_model.dart';
import 'package:kasirsuper/features/transaction/blocs/transaction_bloc.dart';
import 'package:kasirsuper/features/transaction/models/transaction_model.dart';
import 'package:kasirsuper/features/transaction/models/transaction_item_model.dart';
import 'package:kasirsuper/features/notification/blocs/notification_bloc.dart';
import 'package:kasirsuper/features/notification/models/notification_model.dart';
import 'package:kasirsuper/core/services/notification_service.dart';
import 'package:kasirsuper/features/mechanic/blocs/mechanic/mechanic_bloc.dart';
import 'package:kasirsuper/features/mechanic/blocs/mechanic/mechanic_state.dart';
import 'package:kasirsuper/features/mechanic/blocs/mechanic/mechanic_event.dart';
import 'package:kasirsuper/features/mechanic/models/mechanic_model.dart';

class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    String digitsOnly = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    if (digitsOnly.isEmpty) return newValue.copyWith(text: '');

    final number = int.parse(digitsOnly);
    final formatter = NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0);
    final newText = formatter.format(number).trim();

    return newValue.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  String? selectedPaymentMethod;
  final TextEditingController _amountController = TextEditingController();
  
  double discountPercent = 0.0;
  bool applyTax = false;

  @override
  void initState() {
    super.initState();
    context.read<MechanicBloc>().add(LoadMechanics());
  }

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

  void _handlePayment(BuildContext context) {
    final posState = context.read<PosBloc>().state;
    
    final subTotal = posState.totalAmount;
    final discountAmount = subTotal * (discountPercent / 100);
    final afterDiscount = subTotal - discountAmount;
    final taxAmount = applyTax ? afterDiscount * 0.11 : 0.0;
    final total = afterDiscount + taxAmount;
    
    double amountGiven = total;

    if (selectedPaymentMethod == 'cash') {
      double? paidAmount = double.tryParse(_amountController.text.replaceAll('.', ''));
      if (paidAmount == null || paidAmount < total) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Nominal bayar kurang atau tidak valid!'),
            backgroundColor: QuickPOSColors.error,
          ),
        );
        return;
      }
      amountGiven = paidAmount;
    }
    
    final change = amountGiven - total;
    
    final items = posState.items.map((cartItem) {
      double commAmount = 0.0;
      if (cartItem.itemType == 'service' && cartItem.service != null && cartItem.assignedMechanic != null) {
        commAmount = (cartItem.service!.price * cartItem.quantity) * (cartItem.service!.commissionPercent / 100);
      }
      return TransactionItemModel(
        productId: cartItem.id, // Using generic id
        productName: cartItem.name, // Using generic name
        price: cartItem.price, // Using generic price
        quantity: cartItem.quantity,
        itemType: cartItem.itemType, // Using generic itemType
        mechanicId: cartItem.assignedMechanic?.id,
        mechanicName: cartItem.assignedMechanic?.name,
        commissionAmount: commAmount,
      );
    }).toList();
    
    final transaction = TransactionModel(
      date: DateTime.now().toIso8601String(),
      totalAmount: total,
      amountGiven: amountGiven,
      change: change > 0 ? change : 0,
      paymentMethod: selectedPaymentMethod!,
      discountPercent: discountPercent > 0 ? discountPercent : null,
      taxPercent: applyTax ? 11.0 : null,
      items: items,
    );

    context.read<TransactionBloc>().add(SaveTransaction(transaction));
    
    // Check for low stock warnings
    for (var cartItem in posState.items) {
      if (cartItem.itemType == 'product' && cartItem.product != null) {
        final remainingStock = cartItem.product!.stock - cartItem.quantity;
        if (remainingStock <= cartItem.product!.minStock) {
          final title = 'Peringatan Stok: ${cartItem.name}';
          final body = 'Sisa stok tinggal $remainingStock. Segera restock!';
          
          // Show Push Notification
          NotificationService().showNotification(title: title, body: body);
          
          // Save In-App Notification
          context.read<NotificationBloc>().add(AddNotification(
            NotificationModel(
              title: title,
              body: body,
              date: DateTime.now().toIso8601String(),
            ),
          ));
        }
      }
    }
    
    context.read<PosBloc>().add(ClearCart());
    
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
    return BlocBuilder<PosBloc, PosState>(
      builder: (context, posState) {
        final subTotal = posState.totalAmount;
        final discountAmount = subTotal * (discountPercent / 100);
        final afterDiscount = subTotal - discountAmount;
        final taxAmount = applyTax ? afterDiscount * 0.11 : 0.0;
        final finalTotal = afterDiscount + taxAmount;

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
                            cartCount: posState.totalQuantity,
                            cartTotal: finalTotal,
                            subTotal: subTotal,
                            discountAmount: discountAmount,
                            taxAmount: taxAmount,
                            items: posState.items,
                            discountPercent: discountPercent,
                            applyTax: applyTax,
                            onDiscountChanged: (val) {
                              setState(() {
                                discountPercent = double.tryParse(val) ?? 0.0;
                              });
                            },
                            onTaxChanged: (val) {
                              setState(() {
                                applyTax = val;
                              });
                            },
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
                  cartTotal: finalTotal,
                  amountController: _amountController,
                  onPayPressed: () => _handlePayment(context),
                ),
              ],
            ),
          ),
        );
      },
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
  final List<CartItemModel> items;
  final double subTotal;
  final double discountAmount;
  final double taxAmount;
  final double discountPercent;
  final bool applyTax;
  final ValueChanged<String> onDiscountChanged;
  final ValueChanged<bool> onTaxChanged;

  const _OrderSummarySection({
    required this.cartCount,
    required this.cartTotal,
    required this.items,
    required this.subTotal,
    required this.discountAmount,
    required this.taxAmount,
    required this.discountPercent,
    required this.applyTax,
    required this.onDiscountChanged,
    required this.onTaxChanged,
  });

  @override
  Widget build(BuildContext context) {
    final formatCurrency = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    final realFormat = formatCurrency.format(cartTotal);

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
            realFormat,
            style: const TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: QuickPOSColors.secondary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 16),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: _buildOrderItem(context, item, formatCurrency.format(item.total)),
          )),
          const SizedBox(height: 8),
          const Divider(color: QuickPOSColors.outlineVariant),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ORDER ID: #POS-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
                style: const TextStyle(
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
          const SizedBox(height: 24),
          const Divider(color: QuickPOSColors.outlineVariant),
          const SizedBox(height: 16),
          // Subtotal
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Subtotal', style: TextStyle(color: QuickPOSColors.onSurfaceVariant)),
              Text(formatCurrency.format(subTotal), style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          // Discount Info
          if (discountAmount > 0)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Diskon ($discountPercent%)', style: const TextStyle(color: QuickPOSColors.error)),
                Text('- ${formatCurrency.format(discountAmount)}', style: const TextStyle(color: QuickPOSColors.error, fontWeight: FontWeight.bold)),
              ],
            ),
          if (discountAmount > 0) const SizedBox(height: 8),
          // Tax Info
          if (applyTax)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('PPN (11%)', style: TextStyle(color: QuickPOSColors.primary)),
                Text('+ ${formatCurrency.format(taxAmount)}', style: const TextStyle(color: QuickPOSColors.primary, fontWeight: FontWeight.bold)),
              ],
            ),
          if (applyTax) const SizedBox(height: 8),
          
          const SizedBox(height: 16),
          // Discount Input
          Row(
            children: [
              const Icon(Icons.discount_outlined, color: QuickPOSColors.outline, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Diskon (%)',
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: QuickPOSColors.outlineVariant),
                    ),
                  ),
                  onChanged: onDiscountChanged,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Tax Toggle
          Row(
            children: [
              const Icon(Icons.receipt_long, color: QuickPOSColors.outline, size: 20),
              const SizedBox(width: 12),
              const Expanded(
                child: Text('Gunakan PPN 11%', style: TextStyle(color: QuickPOSColors.onSurface)),
              ),
              Switch(
                value: applyTax,
                onChanged: onTaxChanged,
                activeColor: QuickPOSColors.primary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItem(BuildContext context, CartItemModel item, String price) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(item.itemType == 'service' ? Icons.handyman : Icons.inventory_2, size: 14, color: QuickPOSColors.outline),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        item.name,
                        style: const TextStyle(
                          fontSize: 14,
                          color: QuickPOSColors.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    InkWell(
                      onTap: () {
                        context.read<PosBloc>().add(RemoveItemFromCart(item));
                        Future.delayed(const Duration(milliseconds: 100), () {
                          if (context.mounted && context.read<PosBloc>().state.items.isEmpty) {
                            Navigator.pop(context);
                          }
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: QuickPOSColors.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Icon(Icons.remove, size: 16, color: QuickPOSColors.error),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(width: 12),
                    InkWell(
                      onTap: () {
                        if (item.itemType == 'service' || item.quantity < item.product!.stock) {
                          context.read<PosBloc>().add(AddItemToCart(item));
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Stok habis!'),
                              backgroundColor: QuickPOSColors.error,
                              duration: Duration(milliseconds: 1000),
                            ),
                          );
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: QuickPOSColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Icon(Icons.add, size: 16, color: QuickPOSColors.primary),
                      ),
                    ),
                  ],
                ),
                if (item.itemType == 'service') ...[
                  const SizedBox(height: 8),
                  BlocBuilder<MechanicBloc, MechanicState>(
                    builder: (context, mechanicState) {
                      if (mechanicState is MechanicLoaded && mechanicState.mechanics.isNotEmpty) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: QuickPOSColors.outlineVariant),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<MechanicModel>(
                              value: item.assignedMechanic,
                              hint: const Text('Pilih Mekanik (Opsional)', style: TextStyle(fontSize: 12)),
                              isExpanded: true,
                              icon: const Icon(Icons.arrow_drop_down, size: 20),
                              items: mechanicState.mechanics.map((mechanic) {
                                return DropdownMenuItem<MechanicModel>(
                                  value: mechanic,
                                  child: Text(mechanic.name, style: const TextStyle(fontSize: 12)),
                                );
                              }).toList(),
                              onChanged: (MechanicModel? newValue) {
                                context.read<PosBloc>().add(UpdateCartItemMechanic(item, newValue));
                              },
                            ),
                          ),
                        );
                      }
                      return const SizedBox();
                    },
                  ),
                ],
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                price,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: QuickPOSColors.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: () {
                  context.read<PosBloc>().add(DeleteItemFromCart(item));
                  Future.delayed(const Duration(milliseconds: 100), () {
                    if (context.mounted && context.read<PosBloc>().state.items.isEmpty) {
                      Navigator.pop(context);
                    }
                  });
                },
                child: const Icon(Icons.delete_outline, size: 20, color: QuickPOSColors.error),
              ),
            ],
          ),
        ],
      ),
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
            Expanded(
              child: Row(
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: QuickPOSColors.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            fontSize: 12,
                            color: QuickPOSColors.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
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
                          color: QuickPOSColors.secondary,
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
                keyboardType: const TextInputType.numberWithOptions(decimal: false),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  CurrencyInputFormatter(),
                ],
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: QuickPOSColors.onSurface),
                decoration: InputDecoration(
                  prefixText: 'Rp ',
                  prefixStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: QuickPOSColors.onSurfaceVariant),
                  hintText: '0',
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
                        double paidAmount = double.tryParse(value.text.replaceAll('.', '')) ?? 0.0;
                        double change = paidAmount - cartTotal;
                        if (change < 0) change = 0;
                        
                        return Text(
                          NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(change),
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
