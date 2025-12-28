// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'lease_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$LeaseModel {

 String get id; String get ownerId; String get propertyId; String get flatId; String get residentId;@TimestampConverter() DateTime get startDate;@NullableTimestampConverter() DateTime? get endDate; String get status;// 'active' | 'ended'
@TimestampConverter() DateTime get createdAt;
/// Create a copy of LeaseModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LeaseModelCopyWith<LeaseModel> get copyWith => _$LeaseModelCopyWithImpl<LeaseModel>(this as LeaseModel, _$identity);

  /// Serializes this LeaseModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LeaseModel&&(identical(other.id, id) || other.id == id)&&(identical(other.ownerId, ownerId) || other.ownerId == ownerId)&&(identical(other.propertyId, propertyId) || other.propertyId == propertyId)&&(identical(other.flatId, flatId) || other.flatId == flatId)&&(identical(other.residentId, residentId) || other.residentId == residentId)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,ownerId,propertyId,flatId,residentId,startDate,endDate,status,createdAt);

@override
String toString() {
  return 'LeaseModel(id: $id, ownerId: $ownerId, propertyId: $propertyId, flatId: $flatId, residentId: $residentId, startDate: $startDate, endDate: $endDate, status: $status, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $LeaseModelCopyWith<$Res>  {
  factory $LeaseModelCopyWith(LeaseModel value, $Res Function(LeaseModel) _then) = _$LeaseModelCopyWithImpl;
@useResult
$Res call({
 String id, String ownerId, String propertyId, String flatId, String residentId,@TimestampConverter() DateTime startDate,@NullableTimestampConverter() DateTime? endDate, String status,@TimestampConverter() DateTime createdAt
});




}
/// @nodoc
class _$LeaseModelCopyWithImpl<$Res>
    implements $LeaseModelCopyWith<$Res> {
  _$LeaseModelCopyWithImpl(this._self, this._then);

  final LeaseModel _self;
  final $Res Function(LeaseModel) _then;

/// Create a copy of LeaseModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? ownerId = null,Object? propertyId = null,Object? flatId = null,Object? residentId = null,Object? startDate = null,Object? endDate = freezed,Object? status = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,ownerId: null == ownerId ? _self.ownerId : ownerId // ignore: cast_nullable_to_non_nullable
as String,propertyId: null == propertyId ? _self.propertyId : propertyId // ignore: cast_nullable_to_non_nullable
as String,flatId: null == flatId ? _self.flatId : flatId // ignore: cast_nullable_to_non_nullable
as String,residentId: null == residentId ? _self.residentId : residentId // ignore: cast_nullable_to_non_nullable
as String,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [LeaseModel].
extension LeaseModelPatterns on LeaseModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LeaseModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LeaseModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LeaseModel value)  $default,){
final _that = this;
switch (_that) {
case _LeaseModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LeaseModel value)?  $default,){
final _that = this;
switch (_that) {
case _LeaseModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String ownerId,  String propertyId,  String flatId,  String residentId, @TimestampConverter()  DateTime startDate, @NullableTimestampConverter()  DateTime? endDate,  String status, @TimestampConverter()  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LeaseModel() when $default != null:
return $default(_that.id,_that.ownerId,_that.propertyId,_that.flatId,_that.residentId,_that.startDate,_that.endDate,_that.status,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String ownerId,  String propertyId,  String flatId,  String residentId, @TimestampConverter()  DateTime startDate, @NullableTimestampConverter()  DateTime? endDate,  String status, @TimestampConverter()  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _LeaseModel():
return $default(_that.id,_that.ownerId,_that.propertyId,_that.flatId,_that.residentId,_that.startDate,_that.endDate,_that.status,_that.createdAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String ownerId,  String propertyId,  String flatId,  String residentId, @TimestampConverter()  DateTime startDate, @NullableTimestampConverter()  DateTime? endDate,  String status, @TimestampConverter()  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _LeaseModel() when $default != null:
return $default(_that.id,_that.ownerId,_that.propertyId,_that.flatId,_that.residentId,_that.startDate,_that.endDate,_that.status,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LeaseModel implements LeaseModel {
  const _LeaseModel({required this.id, required this.ownerId, required this.propertyId, required this.flatId, required this.residentId, @TimestampConverter() required this.startDate, @NullableTimestampConverter() this.endDate, this.status = 'active', @TimestampConverter() required this.createdAt});
  factory _LeaseModel.fromJson(Map<String, dynamic> json) => _$LeaseModelFromJson(json);

@override final  String id;
@override final  String ownerId;
@override final  String propertyId;
@override final  String flatId;
@override final  String residentId;
@override@TimestampConverter() final  DateTime startDate;
@override@NullableTimestampConverter() final  DateTime? endDate;
@override@JsonKey() final  String status;
// 'active' | 'ended'
@override@TimestampConverter() final  DateTime createdAt;

/// Create a copy of LeaseModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LeaseModelCopyWith<_LeaseModel> get copyWith => __$LeaseModelCopyWithImpl<_LeaseModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LeaseModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LeaseModel&&(identical(other.id, id) || other.id == id)&&(identical(other.ownerId, ownerId) || other.ownerId == ownerId)&&(identical(other.propertyId, propertyId) || other.propertyId == propertyId)&&(identical(other.flatId, flatId) || other.flatId == flatId)&&(identical(other.residentId, residentId) || other.residentId == residentId)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,ownerId,propertyId,flatId,residentId,startDate,endDate,status,createdAt);

@override
String toString() {
  return 'LeaseModel(id: $id, ownerId: $ownerId, propertyId: $propertyId, flatId: $flatId, residentId: $residentId, startDate: $startDate, endDate: $endDate, status: $status, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$LeaseModelCopyWith<$Res> implements $LeaseModelCopyWith<$Res> {
  factory _$LeaseModelCopyWith(_LeaseModel value, $Res Function(_LeaseModel) _then) = __$LeaseModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String ownerId, String propertyId, String flatId, String residentId,@TimestampConverter() DateTime startDate,@NullableTimestampConverter() DateTime? endDate, String status,@TimestampConverter() DateTime createdAt
});




}
/// @nodoc
class __$LeaseModelCopyWithImpl<$Res>
    implements _$LeaseModelCopyWith<$Res> {
  __$LeaseModelCopyWithImpl(this._self, this._then);

  final _LeaseModel _self;
  final $Res Function(_LeaseModel) _then;

/// Create a copy of LeaseModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? ownerId = null,Object? propertyId = null,Object? flatId = null,Object? residentId = null,Object? startDate = null,Object? endDate = freezed,Object? status = null,Object? createdAt = null,}) {
  return _then(_LeaseModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,ownerId: null == ownerId ? _self.ownerId : ownerId // ignore: cast_nullable_to_non_nullable
as String,propertyId: null == propertyId ? _self.propertyId : propertyId // ignore: cast_nullable_to_non_nullable
as String,flatId: null == flatId ? _self.flatId : flatId // ignore: cast_nullable_to_non_nullable
as String,residentId: null == residentId ? _self.residentId : residentId // ignore: cast_nullable_to_non_nullable
as String,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
