import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'converters.dart';

part 'flat_model.freezed.dart';
part 'flat_model.g.dart';

@freezed
sealed class FlatModel with _$FlatModel {
  const factory FlatModel({
    required String id,
    required String propertyId,
    required String ownerId,
    required String label, // e.g., "Flat 4B"
    @Default('vacant') String status, // 'vacant' | 'occupied'
    String? currentLeaseId,
    @Default(0.0) double rentBase,
    @Default({}) Map<String, double> utilities, // {gas: 500, water: 200}
    @Default(1) int dueDay, // 1-28
    String? residentId,
    @TimestampConverter() required DateTime createdAt,
    @NullableTimestampConverter() DateTime? updatedAt,
  }) = _FlatModel;

  factory FlatModel.fromJson(Map<String, dynamic> json) => _$FlatModelFromJson(json);
}
