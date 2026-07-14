import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kasirsuper/core/theme/quickpos_colors.dart';
import 'package:kasirsuper/features/transaction/blocs/transaction_bloc.dart';
import 'package:intl/intl.dart';

class MechanicCommissionPage extends StatefulWidget {
  const MechanicCommissionPage({super.key});

  @override
  State<MechanicCommissionPage> createState() => _MechanicCommissionPageState();
}

class _MechanicCommissionPageState extends State<MechanicCommissionPage> {
  String _selectedPeriod = 'Bulan Ini';

  @override
  void initState() {
    super.initState();
    context.read<TransactionBloc>().add(LoadTransactions());
  }

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
          'Komisi Mekanik',
          style: TextStyle(
            color: QuickPOSColors.onSurface,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: BlocBuilder<TransactionBloc, TransactionState>(
          builder: (context, txState) {
            if (txState is TransactionLoaded) {
              return _buildContent(context, txState);
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, TransactionLoaded txState) {
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

    // Grouping Komisi
    double totalKomisiKeseluruhan = 0;
    Map<int, double> mechanicCommission = {};
    Map<int, String> mechanicNames = {};
    Map<int, int> mechanicJobsCount = {};
    Map<int, List<Map<String, dynamic>>> mechanicServices = {};

    for (var tx in filteredTransactions) {
      if (tx.items != null) {
        for (var item in tx.items!) {
          if (item.mechanicId != null) {
            int mId = item.mechanicId!;
            double comm = item.commissionAmount;
            
            mechanicCommission[mId] = (mechanicCommission[mId] ?? 0) + comm;
            mechanicNames[mId] = item.mechanicName ?? 'Mekanik Unknown';
            mechanicJobsCount[mId] = (mechanicJobsCount[mId] ?? 0) + item.quantity;
            totalKomisiKeseluruhan += comm;
            
            if (mechanicServices[mId] == null) {
              mechanicServices[mId] = [];
            }
            mechanicServices[mId]!.add({
              'name': item.productName,
              'qty': item.quantity,
              'comm': comm,
              'date': tx.date,
            });
          }
        }
      }
    }

    var sortedMechanics = mechanicCommission.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final NumberFormat currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Filter Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Pilih Periode',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: QuickPOSColors.onSurface,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: QuickPOSColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedPeriod,
                    icon: const Icon(Icons.arrow_drop_down, color: QuickPOSColors.primary),
                    style: const TextStyle(
                      color: QuickPOSColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                    items: <String>['Hari Ini', 'Kemarin', '7 Hari Terakhir', 'Bulan Ini', 'Semua Data']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedPeriod = newValue;
                        });
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Total Keseluruhan Card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [QuickPOSColors.primary, QuickPOSColors.secondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: QuickPOSColors.primary.withValues(alpha: 0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total Komisi Dibayarkan',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  currencyFormat.format(totalKomisiKeseluruhan),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // List Mekanik
          const Text(
            'Rincian per Mekanik',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: QuickPOSColors.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          
          if (sortedMechanics.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              alignment: Alignment.center,
              child: const Text(
                'Tidak ada data komisi pada periode ini.',
                style: TextStyle(color: QuickPOSColors.onSurfaceVariant),
              ),
            )
          else
            ...sortedMechanics.map((entry) {
              int mId = entry.key;
              double comm = entry.value;
              String name = mechanicNames[mId] ?? '-';
              int jobs = mechanicJobsCount[mId] ?? 0;

              return Card(
                elevation: 0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: QuickPOSColors.outline.withValues(alpha: 0.1)),
                ),
                margin: const EdgeInsets.only(bottom: 12),
                child: Theme(
                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    tilePadding: const EdgeInsets.all(16),
                    leading: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: QuickPOSColors.secondary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.engineering, color: QuickPOSColors.secondary),
                    ),
                    title: Text(
                      name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: QuickPOSColors.onSurface,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        '$jobs Pekerjaan Diselesaikan',
                        style: const TextStyle(
                          fontSize: 13,
                          color: QuickPOSColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                    trailing: Text(
                      currencyFormat.format(comm),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: QuickPOSColors.primary,
                      ),
                    ),
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: QuickPOSColors.surface.withValues(alpha: 0.5),
                          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                        ),
                        child: Column(
                          children: (mechanicServices[mId] ?? []).map((service) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          service['name'] ?? '',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w500,
                                            color: QuickPOSColors.onSurface,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${service['qty']}x • ${service['date']?.substring(0, 10) ?? ''}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: QuickPOSColors.onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    currencyFormat.format(service['comm'] ?? 0),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: QuickPOSColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      )
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}
