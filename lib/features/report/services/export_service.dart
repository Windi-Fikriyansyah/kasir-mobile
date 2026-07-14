import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:excel/excel.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import 'package:kasirsuper/features/transaction/models/transaction_model.dart';
import 'package:kasirsuper/features/product/models/product_model.dart';

class ExportService {
  static final _currencyFormat = NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);
  
  static Future<String?> generateExcel({
    required List<TransactionModel> transactions,
    required List<ProductModel> products,
    required String period,
  }) async {
    try {
      var excel = Excel.createExcel();
      var sheet = excel['Laporan Penjualan'];
      excel.setDefaultSheet('Laporan Penjualan');

      // Title
      sheet.appendRow([TextCellValue('Laporan Penjualan')]);
      sheet.appendRow([TextCellValue('Periode: $period')]);
      sheet.appendRow([TextCellValue('Dibuat pada: ${DateFormat('dd MMM yyyy HH:mm').format(DateTime.now())}')]);
      sheet.appendRow([TextCellValue('')]);

      // Headers
      sheet.appendRow([
        TextCellValue('Tanggal'),
        TextCellValue('ID Transaksi'),
        TextCellValue('Item'),
        TextCellValue('Kuantitas'),
        TextCellValue('Harga Satuan'),
        TextCellValue('Subtotal'),
      ]);

      // Data
      double grandTotal = 0;
      for (var tx in transactions) {
        if (tx.items != null) {
          for (var item in tx.items!) {
            final subtotal = item.price * item.quantity;
            grandTotal += subtotal;
            sheet.appendRow([
              TextCellValue(DateFormat('dd-MM-yyyy HH:mm').format(DateTime.parse(tx.date))),
              TextCellValue('TXN-${tx.id.toString().padLeft(4, '0')}'),
              TextCellValue(item.productName),
              IntCellValue(item.quantity),
              TextCellValue(_currencyFormat.format(item.price)),
              TextCellValue(_currencyFormat.format(subtotal)),
            ]);
          }
        }
      }

      sheet.appendRow([TextCellValue('')]);
      sheet.appendRow([
        TextCellValue(''),
        TextCellValue(''),
        TextCellValue(''),
        TextCellValue(''),
        TextCellValue('TOTAL PENDAPATAN'),
        TextCellValue(_currencyFormat.format(grandTotal)),
      ]);

      // Save file
      Directory? directory;
      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Download');
      } else {
        directory = await getDownloadsDirectory();
        directory ??= await getApplicationDocumentsDirectory();
      }
      
      final filePath = '${directory.path}/Laporan_Penjualan_${DateTime.now().millisecondsSinceEpoch}.xlsx';
      final file = File(filePath);
      
      final fileBytes = excel.save();
      if (fileBytes != null) {
        await file.writeAsBytes(fileBytes);
        return filePath;
      }
      return null;
    } catch (e) {
      print('Failed to generate Excel: $e');
      return null;
    }
  }

  static Future<String?> generatePdf({
    required List<TransactionModel> transactions,
    required List<ProductModel> products,
    required String period,
  }) async {
    try {
      final pdf = pw.Document();

      double grandTotal = 0;
      double totalProfit = 0;

      for (var tx in transactions) {
        grandTotal += tx.totalAmount;
        if (tx.items != null) {
          for (var item in tx.items!) {
            final product = products.firstWhere(
              (p) => p.id == item.productId,
              orElse: () => ProductModel(name: '', sku: '', category: '', price: 0, cost: 0, stock: 0, minStock: 0),
            );
            totalProfit += (item.price - product.cost) * item.quantity;
          }
        }
      }

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (context) {
            return [
              pw.Header(
                level: 0,
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Laporan Penjualan', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                    pw.Text(DateFormat('dd MMM yyyy').format(DateTime.now()), style: const pw.TextStyle(fontSize: 12)),
                  ],
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Text('Periode: $period', style: const pw.TextStyle(fontSize: 14)),
              pw.SizedBox(height: 24),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  _buildPdfSummaryCard('Total Pendapatan', _currencyFormat.format(grandTotal)),
                  _buildPdfSummaryCard('Laba Bersih', _currencyFormat.format(totalProfit)),
                  _buildPdfSummaryCard('Total Transaksi', '${transactions.length} Txn'),
                ],
              ),
              pw.SizedBox(height: 24),
              pw.Text('Rincian Transaksi', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 8),
              pw.TableHelper.fromTextArray(
                context: context,
                border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey800),
                cellAlignment: pw.Alignment.centerLeft,
                headers: ['Tgl', 'No. Txn', 'Item', 'Qty', 'Harga', 'Subtotal'],
                data: [
                  for (var tx in transactions)
                    if (tx.items != null)
                      for (var item in tx.items!)
                        [
                          DateFormat('dd/MM').format(DateTime.parse(tx.date)),
                          'TXN-${tx.id.toString().padLeft(4, '0')}',
                          item.productName,
                          item.quantity.toString(),
                          _currencyFormat.format(item.price),
                          _currencyFormat.format(item.price * item.quantity),
                        ]
                ],
              ),
            ];
          },
        ),
      );

      Directory? directory;
      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Download');
      } else {
        directory = await getDownloadsDirectory();
        directory ??= await getApplicationDocumentsDirectory();
      }
      
      final filePath = '${directory.path}/Laporan_Penjualan_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());

      return filePath;
    } catch (e) {
      print('Failed to generate PDF: $e');
      return null;
    }
  }

  static pw.Widget _buildPdfSummaryCard(String title, String value) {
    return pw.Container(
      width: 150,
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(title, style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700)),
          pw.SizedBox(height: 4),
          pw.Text(value, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
        ],
      ),
    );
  }
}
