import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'converters.dart';

part 'tenant_profile_model.freezed.dart';
part 'tenant_profile_model.g.dart';

@freezed
sealed class TenantProfileModel with _$TenantProfileModel {
  const factory TenantProfileModel({
    required String uid, // Same as user.uid
    String? nidNumber,
    String? nidFrontUrl,
    String? photoUrl,
    String? birthCertUrl,
    @Default(false) bool verified,
    @TimestampConverter() required DateTime updatedAt,
  }) = _TenantProfileModel;

  factory TenantProfileModel.fromJson(Map<String, dynamic> json) => _$TenantProfileModelFromJson(json);
}
