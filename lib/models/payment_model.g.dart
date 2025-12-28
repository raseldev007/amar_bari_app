// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PaymentModel _$PaymentModelFromJson(Map<String, dynamic> json) =>
    _PaymentModel(
      id: json['id'] as String,
      ownerId: json['ownerId'] as String,
      residentId: json['residentId'] as String,
      invoiceId: json['invoiceId'] as String,
      amount: (json['amount'] as num).toDouble(),
      method: json['method'] as String,
      providerRef: json['providerRef'] as String?,
      attachmentUrl: json['attachmentUrl'] as String?,
      status: json['status'] as String,
      createdAt: const TimestampConverter().fromJson(
        json['createdAt'] as Timestamp,
      ),
      confirmedAt: const NullableTimestampConverter().fromJson(
        json['confirmedAt'] as Timestamp?,
      ),
    );

Map<String, dynamic> _$PaymentModelToJson(_PaymentModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'ownerId': instance.ownerId,
      'residentId': instance.residentId,
      'invoiceId': instance.invoiceId,
      'amount': instance.amount,
      'method': instance.method,
      'providerRef': instance.providerRef,
      'attachmentUrl': instance.attachmentUrl,
      'status': instance.status,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
      'confirmedAt': const NullableTimestampConverter().toJson(
        instance.confirmedAt,
      ),
    };
