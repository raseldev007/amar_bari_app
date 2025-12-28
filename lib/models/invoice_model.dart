import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'converters.dart';

part 'invoice_model.freezed.dart';
part 'invoice_model.g.dart';

@freezed
sealed class InvoiceItem with _$InvoiceItem {
  const factory InvoiceItem({
    required String key, // 'rent', 'gas', 'water'
    required double amount,
  }) = _InvoiceItem;

  factory InvoiceItem.fromJson(Map<String, dynamic> json) => _$InvoiceItemFromJson(json);
}

@freezed
sealed class InvoiceModel with _$InvoiceModel {
  const factory InvoiceModel({
    required String id,
    required String ownerId,
    required String residentId,
    required String propertyId,
    required String flatId,
    required String leaseId,
    required String monthKey, // "YYYY-MM"
    required List<InvoiceItem> items,
    required double totalAmount,
    @TimestampConverter() required DateTime dueDate,
    @Default('due') String status, // 'due' | 'paid' | 'late'
    @TimestampConverter() required DateTime createdAt,
    @TimestampConverter() DateTime? paidAt,
    @TimestampConverter() DateTime? lastReminderAt,
  }) = _InvoiceModel;

  factory InvoiceModel.fromJson(Map<String, dynamic> json) => _$InvoiceModelFromJson(json);
}
