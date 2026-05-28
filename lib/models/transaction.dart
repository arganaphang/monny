import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:monny/models/transaction_type.dart';

part 'transaction.freezed.dart';
part 'transaction.g.dart';

@freezed
class Transaction with _$Transaction {
  const factory Transaction({
    required String id,
    required String title,
    required double amount,
    required TransactionType type,
    required String categoryId,
    required String accountId,
    required DateTime date,
    String? note,
  }) = _Transaction;

  factory Transaction.fromJson(Map<String, dynamic> json) =>
      _$TransactionFromJson(json);
}
