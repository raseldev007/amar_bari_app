// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserModel _$UserModelFromJson(Map<String, dynamic> json) => _UserModel(
  uid: json['uid'] as String,
  email: json['email'] as String,
  role: json['role'] as String? ?? 'resident',
  name: json['name'] as String?,
  phoneNumber: json['phoneNumber'] as String?,
  photoUrl: json['photoUrl'] as String?,
  assignedFlatId: json['assignedFlatId'] as String?,
  assignedPropertyId: json['assignedPropertyId'] as String?,
  createdAt: const TimestampConverter().fromJson(
    json['createdAt'] as Timestamp,
  ),
  lastSeenAt: const NullableTimestampConverter().fromJson(
    json['lastSeenAt'] as Timestamp?,
  ),
);

Map<String, dynamic> _$UserModelToJson(
  _UserModel instance,
) => <String, dynamic>{
  'uid': instance.uid,
  'email': instance.email,
  'role': instance.role,
  'name': instance.name,
  'phoneNumber': instance.phoneNumber,
  'photoUrl': instance.photoUrl,
  'assignedFlatId': instance.assignedFlatId,
  'assignedPropertyId': instance.assignedPropertyId,
  'createdAt': const TimestampConverter().toJson(instance.createdAt),
  'lastSeenAt': const NullableTimestampConverter().toJson(instance.lastSeenAt),
};
