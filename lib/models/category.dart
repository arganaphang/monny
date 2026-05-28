import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:monny/models/transaction_type.dart';

part 'category.freezed.dart';
part 'category.g.dart';

@freezed
class Category with _$Category {
  const factory Category({
    required String id,
    required String name,
    required TransactionType type,
    required int iconCodePoint,
    required int colorValue,
  }) = _Category;

  factory Category.fromJson(Map<String, dynamic> json) =>
      _$CategoryFromJson(json);
}
