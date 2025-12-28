import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'converters.dart';

part 'request_model.freezed.dart';
part 'request_model.g.dart';

@freezed
sealed class RequestModel with _$RequestModel {
  const factory RequestModel({
    required String id,
    required String type, // 'invoice_request' | 'support' | 'service'
    required String tenantId,
    String? flatId,
    String? propertyId,
    String? ownerId,
    required String title,
    required String message,
    @Default('open') String status, // 'open' | 'in_progress' | 'closed'
    @TimestampConverter() required DateTime createdAt,
    String? response,
    @TimestampConverter() DateTime? respondedAt,
  }) = _RequestModel;

  factory RequestModel.fromJson(Map<String, dynamic> json) => _$RequestModelFromJson(json);
}
