import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'converters.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
sealed class UserModel with _$UserModel {
  const factory UserModel({
    required String uid,
    required String email,
    @Default('resident') String role, // 'owner' | 'resident'
    String? name,
    String? phoneNumber,
    String? photoUrl,
    String? assignedFlatId,
    String? assignedPropertyId,
    @TimestampConverter() required DateTime createdAt,
    @NullableTimestampConverter() DateTime? lastSeenAt,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);
}
