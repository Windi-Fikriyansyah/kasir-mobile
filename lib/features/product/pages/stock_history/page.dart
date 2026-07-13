import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kasirsuper/core/theme/quickpos_colors.dart';
import 'package:kasirsuper/features/product/blocs/blocs.dart';
import 'package:kasirsuper/features/product/models/stock_movement_model.dart';
import 'package:intl/intl.dart';

class StockHistoryPage extends StatefulWidget {
  const StockHistoryPage({super.key});

  @override
  State<StockHistoryPage> createState() => _StockHistoryPageState();
}

class _StockHistoryPageState extends State<StockHistoryPage> {
  @override
  void initState() {
    super.initState();
    context.read<StockBloc>().add(LoadStockHistoryEvent());
  }

  String _formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      return DateFormat('dd MMM yyyy, HH:mm').format(date);
    } catch (e) {
      return isoDate;
    }
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'in':
        return Icons.arrow_downward;
      case 'out':
        return Icons.arrow_upward;
      case 'opname':
        return Icons.sync_alt;
      default:
        return Icons.history;
    }
  }

  Color _getColorForType(String type) {
    switch (type) {
      case 'in':
        return Colors.green;
      case 'out':
        return Colors.red;
      case 'opname':
        return Colors.orange;
      default:
        return QuickPOSColors.outline;
    }
  }

  String _getLabelForType(String type) {
    switch (type) {
      case 'in':
        return 'Stok Masuk';
      case 'out':
        return 'Stok Keluar (Terjual)';
      case 'opname':
        return 'Stok Opname';
      default:
        return 'Lainnya';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: QuickPOSColors.surface,
      appBar: AppBar(
        title: const Text('Riwayat Stok'),
        backgroundColor: Colors.white,
        foregroundColor: QuickPOSColors.onSurface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<StockBloc>().add(LoadStockHistoryEvent());
            },
          ),
        ],
      ),
      body: BlocBuilder<StockBloc, StockState>(
        builder: (context, state) {
          if (state is StockLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is StockError) {
            return Center(child: Text(state.message, style: const TextStyle(color: QuickPOSColors.error)));
          } else if (state is StockHistoryLoaded) {
            final movements = state.movements;

            if (movements.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.history_toggle_off, size: 64, color: QuickPOSColors.outlineVariant),
                    SizedBox(height: 16),
                    Text(
                      'Belum ada riwayat pergerakan stok',
                      style: TextStyle(fontSize: 16, color: QuickPOSColors.onSurfaceVariant),
                    ),
                  ],
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: movements.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final movement = movements[index];
                final color = _getColorForType(movement.type);

                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: QuickPOSColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: QuickPOSColors.surfaceContainerHigh),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _getIconForType(movement.type),
                          color: color,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              movement.productName ?? 'Produk Tidak Diketahui',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: QuickPOSColors.onSurface,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "${movement.productSku ?? '-'} • ${_getLabelForType(movement.type)}",
                              style: const TextStyle(
                                fontSize: 14,
                                color: QuickPOSColors.onSurfaceVariant,
                              ),
                            ),
                            if (movement.notes.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                '"${movement.notes}"',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                  color: QuickPOSColors.outline,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            movement.type == 'opname' 
                                ? '=${movement.quantity}' 
                                : "${movement.type == 'in' ? '+' : '-'}${movement.quantity}",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: color,
                              fontFamily: 'JetBrains Mono',
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatDate(movement.date),
                            style: const TextStyle(
                              fontSize: 10,
                              color: QuickPOSColors.outline,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          }

          return const SizedBox();
        },
      ),
    );
  }
}
