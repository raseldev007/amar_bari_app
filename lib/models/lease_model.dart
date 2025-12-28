import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'converters.dart';

part 'lease_model.freezed.dart';
part 'lease_model.g.dart';

@freezed
sealed class LeaseModel with _$LeaseModel {
  const factory LeaseModel({
    required String id,
    required String ownerId,
    required String propertyId,
    required String flatId,
    required String residentId,
    @TimestampConverter() required DateTime startDate,
    @NullableTimestampConverter() DateTime? endDate,
    @Default('active') String status, // 'active' | 'ended'
    @TimestampConverter() required DateTime createdAt,
  }) = _LeaseModel;

  factory LeaseModel.fromJson(Map<String, dynamic> json) => _$LeaseModelFromJson(json);
}
