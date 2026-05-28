import 'package:freezed_annotation/freezed_annotation.dart';

part 'account.freezed.dart';
part 'account.g.dart';

@JsonEnum()
enum AccountType { cash, bank, eWallet, other }

@freezed
class Account with _$Account {
  const factory Account({
    required String id,
    required String name,
    required double balance,
    required AccountType type,
    @Default(0xFF2196F3) int colorValue,
    @Default(0xe191) int iconCodePoint,
  }) = _Account;

  factory Account.fromJson(Map<String, dynamic> json) =>
      _$AccountFromJson(json);
}
