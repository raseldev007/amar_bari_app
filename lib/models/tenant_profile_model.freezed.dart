// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tenant_profile_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TenantProfileModel {

 String get uid;// Same as user.uid
 String? get nidNumber; String? get nidFrontUrl; String? get photoUrl; String? get birthCertUrl; bool get verified;@TimestampConverter() DateTime get updatedAt;
/// Create a copy of TenantProfileModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TenantProfileModelCopyWith<TenantProfileModel> get copyWith => _$TenantProfileModelCopyWithImpl<TenantProfileModel>(this as TenantProfileModel, _$identity);

  /// Serializes this TenantProfileModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TenantProfileModel&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.nidNumber, nidNumber) || other.nidNumber == nidNumber)&&(identical(other.nidFrontUrl, nidFrontUrl) || other.nidFrontUrl == nidFrontUrl)&&(identical(other.photoUrl, photoUrl) || other.photoUrl == photoUrl)&&(identical(other.birthCertUrl, birthCertUrl) || other.birthCertUrl == birthCertUrl)&&(identical(other.verified, verified) || other.verified == verified)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uid,nidNumber,nidFrontUrl,photoUrl,birthCertUrl,verified,updatedAt);

@override
String toString() {
  return 'TenantProfileModel(uid: $uid, nidNumber: $nidNumber, nidFrontUrl: $nidFrontUrl, photoUrl: $photoUrl, birthCertUrl: $birthCertUrl, verified: $verified, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $TenantProfileModelCopyWith<$Res>  {
  factory $TenantProfileModelCopyWith(TenantProfileModel value, $Res Function(TenantProfileModel) _then) = _$TenantProfileModelCopyWithImpl;
@useResult
$Res call({
 String uid, String? nidNumber, String? nidFrontUrl, String? photoUrl, String? birthCertUrl, bool verified,@TimestampConverter() DateTime updatedAt
});




}
/// @nodoc
class _$TenantProfileModelCopyWithImpl<$Res>
    implements $TenantProfileModelCopyWith<$Res> {
  _$TenantProfileModelCopyWithImpl(this._self, this._then);

  final TenantProfileModel _self;
  final $Res Function(TenantProfileModel) _then;

/// Create a copy of TenantProfileModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uid = null,Object? nidNumber = freezed,Object? nidFrontUrl = freezed,Object? photoUrl = freezed,Object? birthCertUrl = freezed,Object? verified = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,nidNumber: freezed == nidNumber ? _self.nidNumber : nidNumber // ignore: cast_nullable_to_non_nullable
as String?,nidFrontUrl: freezed == nidFrontUrl ? _self.nidFrontUrl : nidFrontUrl // ignore: cast_nullable_to_non_nullable
as String?,photoUrl: freezed == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String?,birthCertUrl: freezed == birthCertUrl ? _self.birthCertUrl : birthCertUrl // ignore: cast_nullable_to_non_nullable
as String?,verified: null == verified ? _self.verified : verified // ignore: cast_nullable_to_non_nullable
as bool,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [TenantProfileModel].
extension TenantProfileModelPatterns on TenantProfileModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TenantProfileModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TenantProfileModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TenantProfileModel value)  $default,){
final _that = this;
switch (_that) {
case _TenantProfileModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TenantProfileModel value)?  $default,){
final _that = this;
switch (_that) {
case _TenantProfileModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String uid,  String? nidNumber,  String? nidFrontUrl,  String? photoUrl,  String? birthCertUrl,  bool verified, @TimestampConverter()  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TenantProfileModel() when $default != null:
return $default(_that.uid,_that.nidNumber,_that.nidFrontUrl,_that.photoUrl,_that.birthCertUrl,_that.verified,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String uid,  String? nidNumber,  String? nidFrontUrl,  String? photoUrl,  String? birthCertUrl,  bool verified, @TimestampConverter()  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _TenantProfileModel():
return $default(_that.uid,_that.nidNumber,_that.nidFrontUrl,_that.photoUrl,_that.birthCertUrl,_that.verified,_that.updatedAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String uid,  String? nidNumber,  String? nidFrontUrl,  String? photoUrl,  String? birthCertUrl,  bool verified, @TimestampConverter()  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _TenantProfileModel() when $default != null:
return $default(_that.uid,_that.nidNumber,_that.nidFrontUrl,_that.photoUrl,_that.birthCertUrl,_that.verified,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TenantProfileModel implements TenantProfileModel {
  const _TenantProfileModel({required this.uid, this.nidNumber, this.nidFrontUrl, this.photoUrl, this.birthCertUrl, this.verified = false, @TimestampConverter() required this.updatedAt});
  factory _TenantProfileModel.fromJson(Map<String, dynamic> json) => _$TenantProfileModelFromJson(json);

@override final  String uid;
// Same as user.uid
@override final  String? nidNumber;
@override final  String? nidFrontUrl;
@override final  String? photoUrl;
@override final  String? birthCertUrl;
@override@JsonKey() final  bool verified;
@override@TimestampConverter() final  DateTime updatedAt;

/// Create a copy of TenantProfileModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TenantProfileModelCopyWith<_TenantProfileModel> get copyWith => __$TenantProfileModelCopyWithImpl<_TenantProfileModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TenantProfileModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TenantProfileModel&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.nidNumber, nidNumber) || other.nidNumber == nidNumber)&&(identical(other.nidFrontUrl, nidFrontUrl) || other.nidFrontUrl == nidFrontUrl)&&(identical(other.photoUrl, photoUrl) || other.photoUrl == photoUrl)&&(identical(other.birthCertUrl, birthCertUrl) || other.birthCertUrl == birthCertUrl)&&(identical(other.verified, verified) || other.verified == verified)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uid,nidNumber,nidFrontUrl,photoUrl,birthCertUrl,verified,updatedAt);

@override
String toString() {
  return 'TenantProfileModel(uid: $uid, nidNumber: $nidNumber, nidFrontUrl: $nidFrontUrl, photoUrl: $photoUrl, birthCertUrl: $birthCertUrl, verified: $verified, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$TenantProfileModelCopyWith<$Res> implements $TenantProfileModelCopyWith<$Res> {
  factory _$TenantProfileModelCopyWith(_TenantProfileModel value, $Res Function(_TenantProfileModel) _then) = __$TenantProfileModelCopyWithImpl;
@override @useResult
$Res call({
 String uid, String? nidNumber, String? nidFrontUrl, String? photoUrl, String? birthCertUrl, bool verified,@TimestampConverter() DateTime updatedAt
});




}
/// @nodoc
class __$TenantProfileModelCopyWithImpl<$Res>
    implements _$TenantProfileModelCopyWith<$Res> {
  __$TenantProfileModelCopyWithImpl(this._self, this._then);

  final _TenantProfileModel _self;
  final $Res Function(_TenantProfileModel) _then;

/// Create a copy of TenantProfileModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? uid = null,Object? nidNumber = freezed,Object? nidFrontUrl = freezed,Object? photoUrl = freezed,Object? birthCertUrl = freezed,Object? verified = null,Object? updatedAt = null,}) {
  return _then(_TenantProfileModel(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,nidNumber: freezed == nidNumber ? _self.nidNumber : nidNumber // ignore: cast_nullable_to_non_nullable
as String?,nidFrontUrl: freezed == nidFrontUrl ? _self.nidFrontUrl : nidFrontUrl // ignore: cast_nullable_to_non_nullable
as String?,photoUrl: freezed == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String?,birthCertUrl: freezed == birthCertUrl ? _self.birthCertUrl : birthCertUrl // ignore: cast_nullable_to_non_nullable
as String?,verified: null == verified ? _self.verified : verified // ignore: cast_nullable_to_non_nullable
as bool,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
