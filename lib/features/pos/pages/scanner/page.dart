import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:kasirsuper/core/theme/quickpos_colors.dart';
import 'package:kasirsuper/features/pos/blocs/pos_bloc.dart';
import 'package:kasirsuper/features/pos/pages/checkout/page.dart';
import 'package:kasirsuper/features/product/blocs/blocs.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScannerPage extends StatefulWidget {
  final bool returnSkuOnly;
  const ScannerPage({super.key, this.returnSkuOnly = false});

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  final MobileScannerController cameraController = MobileScannerController();
  bool isProcessing = false;
  static const platform = MethodChannel('com.example.kasirsuper/beep');

  void _onDetect(BarcodeCapture capture) {
    if (isProcessing) return;

    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        setState(() {
          isProcessing = true;
        });

        final sku = barcode.rawValue!;
        
        if (widget.returnSkuOnly) {
          try {
            platform.invokeMethod('playBeep');
          } catch (_) {}
          HapticFeedback.vibrate();
          
          Navigator.pop(context, sku);
          return;
        }

        final productBloc = context.read<ProductBloc>();
        
        if (productBloc.state is ProductLoaded) {
          final products = (productBloc.state as ProductLoaded).products;
          final matchedProduct = products.where((p) => p.sku == sku || p.sku.contains(sku)).firstOrNull;

          if (matchedProduct != null) {
            try {
              platform.invokeMethod('playBeep');
            } catch (_) {}
            HapticFeedback.vibrate();

            context.read<PosBloc>().add(AddProductToCart(matchedProduct));
            
            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${matchedProduct.name} ditambahkan ke keranjang!'),
                backgroundColor: QuickPOSColors.secondary,
                duration: const Duration(milliseconds: 1000),
              ),
            );
            
            // Allow scanning again after 1.5 seconds
            Future.delayed(const Duration(milliseconds: 1500), () {
              if (mounted) {
                setState(() {
                  isProcessing = false;
                });
              }
            });
          } else {
            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Produk dengan SKU $sku tidak ditemukan'),
                backgroundColor: QuickPOSColors.error,
                duration: const Duration(milliseconds: 1000),
              ),
            );
            // Allow scanning again after 1.5 seconds
            Future.delayed(const Duration(milliseconds: 1500), () {
              if (mounted) {
                setState(() {
                  isProcessing = false;
                });
              }
            });
          }
        }
        break; // Only process the first barcode
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Barcode', style: TextStyle(color: QuickPOSColors.onSurface)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: QuickPOSColors.onSurface),
        elevation: 0,
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: cameraController,
            onDetect: _onDetect,
          ),
          if (!widget.returnSkuOnly)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: BlocBuilder<PosBloc, PosState>(
                builder: (context, posState) {
                  if (posState.totalQuantity == 0) return const SizedBox();
                  
                  final formattedTotal = NumberFormat.currency(
                    locale: 'id',
                    symbol: 'Rp ',
                    decimalDigits: 0,
                  ).format(posState.totalAmount);

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
                        children: [
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              const Icon(Icons.shopping_basket, color: QuickPOSColors.secondary, size: 32),
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
                                    '${posState.totalQuantity}',
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
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'TOTAL',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: QuickPOSColors.outline,
                                  ),
                                ),
                                Text(
                                  formattedTotal,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: QuickPOSColors.onSurface,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const CheckoutPage(),
                                ),
                              ).then((_) {
                                // If cart is empty after returning (e.g. checkout success), 
                                // we can pop back to home or let them scan again.
                                // In this case, let them continue scanning.
                              });
                            },
                            icon: const Icon(Icons.payment, size: 18),
                            label: const Text('Bayar'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: QuickPOSColors.primary,
                              foregroundColor: QuickPOSColors.onPrimary,
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
