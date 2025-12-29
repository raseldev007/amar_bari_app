// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'flat_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$FlatModel {

 String get id; String get propertyId; String get ownerId; String get label;// e.g., "Flat 4B"
 String get status;// 'vacant' | 'occupied'
 String? get currentLeaseId; double get rentBase; Map<String, double> get utilities;// {gas: 500, water: 200}
 int get dueDay;// 1-28
 String? get residentId;@TimestampConverter() DateTime get createdAt;@NullableTimestampConverter() DateTime? get updatedAt;
/// Create a copy of FlatModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FlatModelCopyWith<FlatModel> get copyWith => _$FlatModelCopyWithImpl<FlatModel>(this as FlatModel, _$identity);

  /// Serializes this FlatModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FlatModel&&(identical(other.id, id) || other.id == id)&&(identical(other.propertyId, propertyId) || other.propertyId == propertyId)&&(identical(other.ownerId, ownerId) || other.ownerId == ownerId)&&(identical(other.label, label) || other.label == label)&&(identical(other.status, status) || other.status == status)&&(identical(other.currentLeaseId, currentLeaseId) || other.currentLeaseId == currentLeaseId)&&(identical(other.rentBase, rentBase) || other.rentBase == rentBase)&&const DeepCollectionEquality().equals(other.utilities, utilities)&&(identical(other.dueDay, dueDay) || other.dueDay == dueDay)&&(identical(other.residentId, residentId) || other.residentId == residentId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,propertyId,ownerId,label,status,currentLeaseId,rentBase,const DeepCollectionEquality().hash(utilities),dueDay,residentId,createdAt,updatedAt);

@override
String toString() {
  return 'FlatModel(id: $id, propertyId: $propertyId, ownerId: $ownerId, label: $label, status: $status, currentLeaseId: $currentLeaseId, rentBase: $rentBase, utilities: $utilities, dueDay: $dueDay, residentId: $residentId, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $FlatModelCopyWith<$Res>  {
  factory $FlatModelCopyWith(FlatModel value, $Res Function(FlatModel) _then) = _$FlatModelCopyWithImpl;
@useResult
$Res call({
 String id, String propertyId, String ownerId, String label, String status, String? currentLeaseId, double rentBase, Map<String, double> utilities, int dueDay, String? residentId,@TimestampConverter() DateTime createdAt,@NullableTimestampConverter() DateTime? updatedAt
});




}
/// @nodoc
class _$FlatModelCopyWithImpl<$Res>
    implements $FlatModelCopyWith<$Res> {
  _$FlatModelCopyWithImpl(this._self, this._then);

  final FlatModel _self;
  final $Res Function(FlatModel) _then;

/// Create a copy of FlatModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? propertyId = null,Object? ownerId = null,Object? label = null,Object? status = null,Object? currentLeaseId = freezed,Object? rentBase = null,Object? utilities = null,Object? dueDay = null,Object? residentId = freezed,Object? createdAt = null,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,propertyId: null == propertyId ? _self.propertyId : propertyId // ignore: cast_nullable_to_non_nullable
as String,ownerId: null == ownerId ? _self.ownerId : ownerId // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,currentLeaseId: freezed == currentLeaseId ? _self.currentLeaseId : currentLeaseId // ignore: cast_nullable_to_non_nullable
as String?,rentBase: null == rentBase ? _self.rentBase : rentBase // ignore: cast_nullable_to_non_nullable
as double,utilities: null == utilities ? _self.utilities : utilities // ignore: cast_nullable_to_non_nullable
as Map<String, double>,dueDay: null == dueDay ? _self.dueDay : dueDay // ignore: cast_nullable_to_non_nullable
as int,residentId: freezed == residentId ? _self.residentId : residentId // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [FlatModel].
extension FlatModelPatterns on FlatModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FlatModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FlatModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FlatModel value)  $default,){
final _that = this;
switch (_that) {
case _FlatModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FlatModel value)?  $default,){
final _that = this;
switch (_that) {
case _FlatModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String propertyId,  String ownerId,  String label,  String status,  String? currentLeaseId,  double rentBase,  Map<String, double> utilities,  int dueDay,  String? residentId, @TimestampConverter()  DateTime createdAt, @NullableTimestampConverter()  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FlatModel() when $default != null:
return $default(_that.id,_that.propertyId,_that.ownerId,_that.label,_that.status,_that.currentLeaseId,_that.rentBase,_that.utilities,_that.dueDay,_that.residentId,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String propertyId,  String ownerId,  String label,  String status,  String? currentLeaseId,  double rentBase,  Map<String, double> utilities,  int dueDay,  String? residentId, @TimestampConverter()  DateTime createdAt, @NullableTimestampConverter()  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _FlatModel():
return $default(_that.id,_that.propertyId,_that.ownerId,_that.label,_that.status,_that.currentLeaseId,_that.rentBase,_that.utilities,_that.dueDay,_that.residentId,_that.createdAt,_that.updatedAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String propertyId,  String ownerId,  String label,  String status,  String? currentLeaseId,  double rentBase,  Map<String, double> utilities,  int dueDay,  String? residentId, @TimestampConverter()  DateTime createdAt, @NullableTimestampConverter()  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _FlatModel() when $default != null:
return $default(_that.id,_that.propertyId,_that.ownerId,_that.label,_that.status,_that.currentLeaseId,_that.rentBase,_that.utilities,_that.dueDay,_that.residentId,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FlatModel implements FlatModel {
  const _FlatModel({required this.id, required this.propertyId, required this.ownerId, required this.label, this.status = 'vacant', this.currentLeaseId, this.rentBase = 0.0, final  Map<String, double> utilities = const {}, this.dueDay = 1, this.residentId, @TimestampConverter() required this.createdAt, @NullableTimestampConverter() this.updatedAt}): _utilities = utilities;
  factory _FlatModel.fromJson(Map<String, dynamic> json) => _$FlatModelFromJson(json);

@override final  String id;
@override final  String propertyId;
@override final  String ownerId;
@override final  String label;
// e.g., "Flat 4B"
@override@JsonKey() final  String status;
// 'vacant' | 'occupied'
@override final  String? currentLeaseId;
@override@JsonKey() final  double rentBase;
 final  Map<String, double> _utilities;
@override@JsonKey() Map<String, double> get utilities {
  if (_utilities is EqualUnmodifiableMapView) return _utilities;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_utilities);
}

// {gas: 500, water: 200}
@override@JsonKey() final  int dueDay;
// 1-28
@override final  String? residentId;
@override@TimestampConverter() final  DateTime createdAt;
@override@NullableTimestampConverter() final  DateTime? updatedAt;

/// Create a copy of FlatModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FlatModelCopyWith<_FlatModel> get copyWith => __$FlatModelCopyWithImpl<_FlatModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FlatModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FlatModel&&(identical(other.id, id) || other.id == id)&&(identical(other.propertyId, propertyId) || other.propertyId == propertyId)&&(identical(other.ownerId, ownerId) || other.ownerId == ownerId)&&(identical(other.label, label) || other.label == label)&&(identical(other.status, status) || other.status == status)&&(identical(other.currentLeaseId, currentLeaseId) || other.currentLeaseId == currentLeaseId)&&(identical(other.rentBase, rentBase) || other.rentBase == rentBase)&&const DeepCollectionEquality().equals(other._utilities, _utilities)&&(identical(other.dueDay, dueDay) || other.dueDay == dueDay)&&(identical(other.residentId, residentId) || other.residentId == residentId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,propertyId,ownerId,label,status,currentLeaseId,rentBase,const DeepCollectionEquality().hash(_utilities),dueDay,residentId,createdAt,updatedAt);

@override
String toString() {
  return 'FlatModel(id: $id, propertyId: $propertyId, ownerId: $ownerId, label: $label, status: $status, currentLeaseId: $currentLeaseId, rentBase: $rentBase, utilities: $utilities, dueDay: $dueDay, residentId: $residentId, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$FlatModelCopyWith<$Res> implements $FlatModelCopyWith<$Res> {
  factory _$FlatModelCopyWith(_FlatModel value, $Res Function(_FlatModel) _then) = __$FlatModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String propertyId, String ownerId, String label, String status, String? currentLeaseId, double rentBase, Map<String, double> utilities, int dueDay, String? residentId,@TimestampConverter() DateTime createdAt,@NullableTimestampConverter() DateTime? updatedAt
});




}
/// @nodoc
class __$FlatModelCopyWithImpl<$Res>
    implements _$FlatModelCopyWith<$Res> {
  __$FlatModelCopyWithImpl(this._self, this._then);

  final _FlatModel _self;
  final $Res Function(_FlatModel) _then;

/// Create a copy of FlatModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? propertyId = null,Object? ownerId = null,Object? label = null,Object? status = null,Object? currentLeaseId = freezed,Object? rentBase = null,Object? utilities = null,Object? dueDay = null,Object? residentId = freezed,Object? createdAt = null,Object? updatedAt = freezed,}) {
  return _then(_FlatModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,propertyId: null == propertyId ? _self.propertyId : propertyId // ignore: cast_nullable_to_non_nullable
as String,ownerId: null == ownerId ? _self.ownerId : ownerId // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,currentLeaseId: freezed == currentLeaseId ? _self.currentLeaseId : currentLeaseId // ignore: cast_nullable_to_non_nullable
as String?,rentBase: null == rentBase ? _self.rentBase : rentBase // ignore: cast_nullable_to_non_nullable
as double,utilities: null == utilities ? _self._utilities : utilities // ignore: cast_nullable_to_non_nullable
as Map<String, double>,dueDay: null == dueDay ? _self.dueDay : dueDay // ignore: cast_nullable_to_non_nullable
as int,residentId: freezed == residentId ? _self.residentId : residentId // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
