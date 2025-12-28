import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'converters.dart';

part 'payment_model.freezed.dart';
part 'payment_model.g.dart';

@freezed
sealed class PaymentModel with _$PaymentModel {
  const factory PaymentModel({
    required String id,
    required String ownerId,
    required String residentId,
    required String invoiceId,
    required double amount,
    required String method, // 'bkash', 'cash', etc.
    required String? providerRef, // Transaction ID
    required String? attachmentUrl, // Screenshot URL
    required String status, // 'submitted', 'confirmed'
    @TimestampConverter() required DateTime createdAt,
    @NullableTimestampConverter() DateTime? confirmedAt,
  }) = _PaymentModel;

  factory PaymentModel.fromJson(Map<String, dynamic> json) => _$PaymentModelFromJson(json);
}
