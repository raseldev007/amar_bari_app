// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'request_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RequestModel {

 String get id; String get type;// 'invoice_request' | 'support' | 'service'
 String get tenantId; String? get flatId; String? get propertyId; String? get ownerId; String get title; String get message; String get status;// 'open' | 'in_progress' | 'closed'
@TimestampConverter() DateTime get createdAt; String? get response;@TimestampConverter() DateTime? get respondedAt;
/// Create a copy of RequestModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RequestModelCopyWith<RequestModel> get copyWith => _$RequestModelCopyWithImpl<RequestModel>(this as RequestModel, _$identity);

  /// Serializes this RequestModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RequestModel&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.tenantId, tenantId) || other.tenantId == tenantId)&&(identical(other.flatId, flatId) || other.flatId == flatId)&&(identical(other.propertyId, propertyId) || other.propertyId == propertyId)&&(identical(other.ownerId, ownerId) || other.ownerId == ownerId)&&(identical(other.title, title) || other.title == title)&&(identical(other.message, message) || other.message == message)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.response, response) || other.response == response)&&(identical(other.respondedAt, respondedAt) || other.respondedAt == respondedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,tenantId,flatId,propertyId,ownerId,title,message,status,createdAt,response,respondedAt);

@override
String toString() {
  return 'RequestModel(id: $id, type: $type, tenantId: $tenantId, flatId: $flatId, propertyId: $propertyId, ownerId: $ownerId, title: $title, message: $message, status: $status, createdAt: $createdAt, response: $response, respondedAt: $respondedAt)';
}


}

/// @nodoc
abstract mixin class $RequestModelCopyWith<$Res>  {
  factory $RequestModelCopyWith(RequestModel value, $Res Function(RequestModel) _then) = _$RequestModelCopyWithImpl;
@useResult
$Res call({
 String id, String type, String tenantId, String? flatId, String? propertyId, String? ownerId, String title, String message, String status,@TimestampConverter() DateTime createdAt, String? response,@TimestampConverter() DateTime? respondedAt
});




}
/// @nodoc
class _$RequestModelCopyWithImpl<$Res>
    implements $RequestModelCopyWith<$Res> {
  _$RequestModelCopyWithImpl(this._self, this._then);

  final RequestModel _self;
  final $Res Function(RequestModel) _then;

/// Create a copy of RequestModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? type = null,Object? tenantId = null,Object? flatId = freezed,Object? propertyId = freezed,Object? ownerId = freezed,Object? title = null,Object? message = null,Object? status = null,Object? createdAt = null,Object? response = freezed,Object? respondedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,tenantId: null == tenantId ? _self.tenantId : tenantId // ignore: cast_nullable_to_non_nullable
as String,flatId: freezed == flatId ? _self.flatId : flatId // ignore: cast_nullable_to_non_nullable
as String?,propertyId: freezed == propertyId ? _self.propertyId : propertyId // ignore: cast_nullable_to_non_nullable
as String?,ownerId: freezed == ownerId ? _self.ownerId : ownerId // ignore: cast_nullable_to_non_nullable
as String?,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,response: freezed == response ? _self.response : response // ignore: cast_nullable_to_non_nullable
as String?,respondedAt: freezed == respondedAt ? _self.respondedAt : respondedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [RequestModel].
extension RequestModelPatterns on RequestModel {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RequestModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RequestModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RequestModel value)  $default,){
final _that = this;
switch (_that) {
case _RequestModel():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RequestModel value)?  $default,){
final _that = this;
switch (_that) {
case _RequestModel() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String type,  String tenantId,  String? flatId,  String? propertyId,  String? ownerId,  String title,  String message,  String status, @TimestampConverter()  DateTime createdAt,  String? response, @TimestampConverter()  DateTime? respondedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RequestModel() when $default != null:
return $default(_that.id,_that.type,_that.tenantId,_that.flatId,_that.propertyId,_that.ownerId,_that.title,_that.message,_that.status,_that.createdAt,_that.response,_that.respondedAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String type,  String tenantId,  String? flatId,  String? propertyId,  String? ownerId,  String title,  String message,  String status, @TimestampConverter()  DateTime createdAt,  String? response, @TimestampConverter()  DateTime? respondedAt)  $default,) {final _that = this;
switch (_that) {
case _RequestModel():
return $default(_that.id,_that.type,_that.tenantId,_that.flatId,_that.propertyId,_that.ownerId,_that.title,_that.message,_that.status,_that.createdAt,_that.response,_that.respondedAt);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String type,  String tenantId,  String? flatId,  String? propertyId,  String? ownerId,  String title,  String message,  String status, @TimestampConverter()  DateTime createdAt,  String? response, @TimestampConverter()  DateTime? respondedAt)?  $default,) {final _that = this;
switch (_that) {
case _RequestModel() when $default != null:
return $default(_that.id,_that.type,_that.tenantId,_that.flatId,_that.propertyId,_that.ownerId,_that.title,_that.message,_that.status,_that.createdAt,_that.response,_that.respondedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RequestModel implements RequestModel {
  const _RequestModel({required this.id, required this.type, required this.tenantId, this.flatId, this.propertyId, this.ownerId, required this.title, required this.message, this.status = 'open', @TimestampConverter() required this.createdAt, this.response, @TimestampConverter() this.respondedAt});
  factory _RequestModel.fromJson(Map<String, dynamic> json) => _$RequestModelFromJson(json);

@override final  String id;
@override final  String type;
// 'invoice_request' | 'support' | 'service'
@override final  String tenantId;
@override final  String? flatId;
@override final  String? propertyId;
@override final  String? ownerId;
@override final  String title;
@override final  String message;
@override@JsonKey() final  String status;
// 'open' | 'in_progress' | 'closed'
@override@TimestampConverter() final  DateTime createdAt;
@override final  String? response;
@override@TimestampConverter() final  DateTime? respondedAt;

/// Create a copy of RequestModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RequestModelCopyWith<_RequestModel> get copyWith => __$RequestModelCopyWithImpl<_RequestModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RequestModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RequestModel&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.tenantId, tenantId) || other.tenantId == tenantId)&&(identical(other.flatId, flatId) || other.flatId == flatId)&&(identical(other.propertyId, propertyId) || other.propertyId == propertyId)&&(identical(other.ownerId, ownerId) || other.ownerId == ownerId)&&(identical(other.title, title) || other.title == title)&&(identical(other.message, message) || other.message == message)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.response, response) || other.response == response)&&(identical(other.respondedAt, respondedAt) || other.respondedAt == respondedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,tenantId,flatId,propertyId,ownerId,title,message,status,createdAt,response,respondedAt);

@override
String toString() {
  return 'RequestModel(id: $id, type: $type, tenantId: $tenantId, flatId: $flatId, propertyId: $propertyId, ownerId: $ownerId, title: $title, message: $message, status: $status, createdAt: $createdAt, response: $response, respondedAt: $respondedAt)';
}


}

/// @nodoc
abstract mixin class _$RequestModelCopyWith<$Res> implements $RequestModelCopyWith<$Res> {
  factory _$RequestModelCopyWith(_RequestModel value, $Res Function(_RequestModel) _then) = __$RequestModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String type, String tenantId, String? flatId, String? propertyId, String? ownerId, String title, String message, String status,@TimestampConverter() DateTime createdAt, String? response,@TimestampConverter() DateTime? respondedAt
});




}
/// @nodoc
class __$RequestModelCopyWithImpl<$Res>
    implements _$RequestModelCopyWith<$Res> {
  __$RequestModelCopyWithImpl(this._self, this._then);

  final _RequestModel _self;
  final $Res Function(_RequestModel) _then;

/// Create a copy of RequestModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? type = null,Object? tenantId = null,Object? flatId = freezed,Object? propertyId = freezed,Object? ownerId = freezed,Object? title = null,Object? message = null,Object? status = null,Object? createdAt = null,Object? response = freezed,Object? respondedAt = freezed,}) {
  return _then(_RequestModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,tenantId: null == tenantId ? _self.tenantId : tenantId // ignore: cast_nullable_to_non_nullable
as String,flatId: freezed == flatId ? _self.flatId : flatId // ignore: cast_nullable_to_non_nullable
as String?,propertyId: freezed == propertyId ? _self.propertyId : propertyId // ignore: cast_nullable_to_non_nullable
as String?,ownerId: freezed == ownerId ? _self.ownerId : ownerId // ignore: cast_nullable_to_non_nullable
as String?,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,response: freezed == response ? _self.response : response // ignore: cast_nullable_to_non_nullable
as String?,respondedAt: freezed == respondedAt ? _self.respondedAt : respondedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
