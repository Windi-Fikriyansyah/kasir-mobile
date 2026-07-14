import 'package:kasirsuper/features/transaction/models/transaction_item_model.dart';

class TransactionModel {
  final int? id;
  final String date;
  final double totalAmount;
  final double amountGiven;
  final double change;
  final String paymentMethod;
  final double? discountPercent;
  final double? taxPercent;
  final List<TransactionItemModel>? items;

  TransactionModel({
    this.id,
    required this.date,
    required this.totalAmount,
    required this.amountGiven,
    required this.change,
    required this.paymentMethod,
    this.discountPercent,
    this.taxPercent,
    this.items,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'date': date,
      'total_amount': totalAmount,
      'amount_given': amountGiven,
      'change': change,
      'payment_method': paymentMethod,
      'discount_percent': discountPercent,
      'tax_percent': taxPercent,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map, {List<TransactionItemModel>? items}) {
    return TransactionModel(
      id: map['id'],
      date: map['date'],
      totalAmount: (map['total_amount'] as num).toDouble(),
      amountGiven: (map['amount_given'] as num).toDouble(),
      change: (map['change'] as num).toDouble(),
      paymentMethod: map['payment_method'],
      discountPercent: map['discount_percent'] != null ? (map['discount_percent'] as num).toDouble() : null,
      taxPercent: map['tax_percent'] != null ? (map['tax_percent'] as num).toDouble() : null,
      items: items,
    );
  }
}
