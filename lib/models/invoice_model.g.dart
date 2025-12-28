// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invoice_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_InvoiceItem _$InvoiceItemFromJson(Map<String, dynamic> json) => _InvoiceItem(
  key: json['key'] as String,
  amount: (json['amount'] as num).toDouble(),
);

Map<String, dynamic> _$InvoiceItemToJson(_InvoiceItem instance) =>
    <String, dynamic>{'key': instance.key, 'amount': instance.amount};

_InvoiceModel _$InvoiceModelFromJson(Map<String, dynamic> json) =>
    _InvoiceModel(
      id: json['id'] as String,
      ownerId: json['ownerId'] as String,
      residentId: json['residentId'] as String,
      propertyId: json['propertyId'] as String,
      flatId: json['flatId'] as String,
      leaseId: json['leaseId'] as String,
      monthKey: json['monthKey'] as String,
      items: (json['items'] as List<dynamic>)
          .map((e) => InvoiceItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      dueDate: const TimestampConverter().fromJson(
        json['dueDate'] as Timestamp,
      ),
      status: json['status'] as String? ?? 'due',
      createdAt: const TimestampConverter().fromJson(
        json['createdAt'] as Timestamp,
      ),
      paidAt: _$JsonConverterFromJson<Timestamp, DateTime>(
        json['paidAt'],
        const TimestampConverter().fromJson,
      ),
      lastReminderAt: _$JsonConverterFromJson<Timestamp, DateTime>(
        json['lastReminderAt'],
        const TimestampConverter().fromJson,
      ),
    );

Map<String, dynamic> _$InvoiceModelToJson(_InvoiceModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'ownerId': instance.ownerId,
      'residentId': instance.residentId,
      'propertyId': instance.propertyId,
      'flatId': instance.flatId,
      'leaseId': instance.leaseId,
      'monthKey': instance.monthKey,
      'items': instance.items,
      'totalAmount': instance.totalAmount,
      'dueDate': const TimestampConverter().toJson(instance.dueDate),
      'status': instance.status,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
      'paidAt': _$JsonConverterToJson<Timestamp, DateTime>(
        instance.paidAt,
        const TimestampConverter().toJson,
      ),
      'lastReminderAt': _$JsonConverterToJson<Timestamp, DateTime>(
        instance.lastReminderAt,
        const TimestampConverter().toJson,
      ),
    };

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);
