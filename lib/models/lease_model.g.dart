// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lease_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LeaseModel _$LeaseModelFromJson(Map<String, dynamic> json) => _LeaseModel(
  id: json['id'] as String,
  ownerId: json['ownerId'] as String,
  propertyId: json['propertyId'] as String,
  flatId: json['flatId'] as String,
  residentId: json['residentId'] as String,
  startDate: const TimestampConverter().fromJson(
    json['startDate'] as Timestamp,
  ),
  endDate: const NullableTimestampConverter().fromJson(
    json['endDate'] as Timestamp?,
  ),
  status: json['status'] as String? ?? 'active',
  createdAt: const TimestampConverter().fromJson(
    json['createdAt'] as Timestamp,
  ),
);

Map<String, dynamic> _$LeaseModelToJson(_LeaseModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'ownerId': instance.ownerId,
      'propertyId': instance.propertyId,
      'flatId': instance.flatId,
      'residentId': instance.residentId,
      'startDate': const TimestampConverter().toJson(instance.startDate),
      'endDate': const NullableTimestampConverter().toJson(instance.endDate),
      'status': instance.status,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
    };
