// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AccountImpl _$$AccountImplFromJson(Map<String, dynamic> json) =>
    _$AccountImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      balance: (json['balance'] as num).toDouble(),
      type: $enumDecode(_$AccountTypeEnumMap, json['type']),
      colorValue: (json['colorValue'] as num?)?.toInt() ?? 0xFF2196F3,
      iconCodePoint: (json['iconCodePoint'] as num?)?.toInt() ?? 0xe191,
    );

Map<String, dynamic> _$$AccountImplToJson(_$AccountImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'balance': instance.balance,
      'type': _$AccountTypeEnumMap[instance.type]!,
      'colorValue': instance.colorValue,
      'iconCodePoint': instance.iconCodePoint,
    };

const _$AccountTypeEnumMap = {
  AccountType.cash: 'cash',
  AccountType.bank: 'bank',
  AccountType.eWallet: 'eWallet',
  AccountType.other: 'other',
};
