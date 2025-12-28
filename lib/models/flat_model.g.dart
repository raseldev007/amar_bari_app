// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'flat_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FlatModel _$FlatModelFromJson(Map<String, dynamic> json) => _FlatModel(
  id: json['id'] as String,
  propertyId: json['propertyId'] as String,
  ownerId: json['ownerId'] as String,
  label: json['label'] as String,
  status: json['status'] as String? ?? 'vacant',
  currentLeaseId: json['currentLeaseId'] as String?,
  rentBase: (json['rentBase'] as num?)?.toDouble() ?? 0.0,
  utilities:
      (json['utilities'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ) ??
      const {},
  dueDay: (json['dueDay'] as num?)?.toInt() ?? 1,
  createdAt: const TimestampConverter().fromJson(
    json['createdAt'] as Timestamp,
  ),
);

Map<String, dynamic> _$FlatModelToJson(_FlatModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'propertyId': instance.propertyId,
      'ownerId': instance.ownerId,
      'label': instance.label,
      'status': instance.status,
      'currentLeaseId': instance.currentLeaseId,
      'rentBase': instance.rentBase,
      'utilities': instance.utilities,
      'dueDay': instance.dueDay,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
    };
