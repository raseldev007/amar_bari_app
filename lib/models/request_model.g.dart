// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RequestModel _$RequestModelFromJson(Map<String, dynamic> json) =>
    _RequestModel(
      id: json['id'] as String,
      type: json['type'] as String,
      tenantId: json['tenantId'] as String,
      flatId: json['flatId'] as String?,
      propertyId: json['propertyId'] as String?,
      ownerId: json['ownerId'] as String?,
      title: json['title'] as String,
      message: json['message'] as String,
      status: json['status'] as String? ?? 'open',
      createdAt: const TimestampConverter().fromJson(
        json['createdAt'] as Timestamp,
      ),
      response: json['response'] as String?,
      respondedAt: _$JsonConverterFromJson<Timestamp, DateTime>(
        json['respondedAt'],
        const TimestampConverter().fromJson,
      ),
      invoiceId: json['invoiceId'] as String?,
    );

Map<String, dynamic> _$RequestModelToJson(_RequestModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'tenantId': instance.tenantId,
      'flatId': instance.flatId,
      'propertyId': instance.propertyId,
      'ownerId': instance.ownerId,
      'title': instance.title,
      'message': instance.message,
      'status': instance.status,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
      'response': instance.response,
      'respondedAt': _$JsonConverterToJson<Timestamp, DateTime>(
        instance.respondedAt,
        const TimestampConverter().toJson,
      ),
      'invoiceId': instance.invoiceId,
    };

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);
