import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'converters.dart';

part 'property_model.freezed.dart';
part 'property_model.g.dart';

@freezed
sealed class PropertyModel with _$PropertyModel {
  const factory PropertyModel({
    required String id,
    required String ownerId,
    required String name,
    required String address,
    required String city,
    @TimestampConverter() required DateTime createdAt,
  }) = _PropertyModel;

  factory PropertyModel.fromJson(Map<String, dynamic> json) => _$PropertyModelFromJson(json);
}
