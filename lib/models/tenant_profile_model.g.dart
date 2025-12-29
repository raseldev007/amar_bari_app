// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tenant_profile_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TenantProfileModel _$TenantProfileModelFromJson(Map<String, dynamic> json) =>
    _TenantProfileModel(
      uid: json['uid'] as String,
      nidNumber: json['nidNumber'] as String?,
      nidFrontUrl: json['nidFrontUrl'] as String?,
      photoUrl: json['photoUrl'] as String?,
      birthCertUrl: json['birthCertUrl'] as String?,
      verified: json['verified'] as bool? ?? false,
      updatedAt: const TimestampConverter().fromJson(
        json['updatedAt'] as Timestamp,
      ),
    );

Map<String, dynamic> _$TenantProfileModelToJson(_TenantProfileModel instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'nidNumber': instance.nidNumber,
      'nidFrontUrl': instance.nidFrontUrl,
      'photoUrl': instance.photoUrl,
      'birthCertUrl': instance.birthCertUrl,
      'verified': instance.verified,
      'updatedAt': const TimestampConverter().toJson(instance.updatedAt),
    };
