// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'curiosity_reading_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CuriosityReadingModel {

 bool get success; CuriosityReadingData get data;
/// Create a copy of CuriosityReadingModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CuriosityReadingModelCopyWith<CuriosityReadingModel> get copyWith => _$CuriosityReadingModelCopyWithImpl<CuriosityReadingModel>(this as CuriosityReadingModel, _$identity);

  /// Serializes this CuriosityReadingModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CuriosityReadingModel&&(identical(other.success, success) || other.success == success)&&(identical(other.data, data) || other.data == data));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,success,data);

@override
String toString() {
  return 'CuriosityReadingModel(success: $success, data: $data)';
}


}

/// @nodoc
abstract mixin class $CuriosityReadingModelCopyWith<$Res>  {
  factory $CuriosityReadingModelCopyWith(CuriosityReadingModel value, $Res Function(CuriosityReadingModel) _then) = _$CuriosityReadingModelCopyWithImpl;
@useResult
$Res call({
 bool success, CuriosityReadingData data
});


$CuriosityReadingDataCopyWith<$Res> get data;

}
/// @nodoc
class _$CuriosityReadingModelCopyWithImpl<$Res>
    implements $CuriosityReadingModelCopyWith<$Res> {
  _$CuriosityReadingModelCopyWithImpl(this._self, this._then);

  final CuriosityReadingModel _self;
  final $Res Function(CuriosityReadingModel) _then;

/// Create a copy of CuriosityReadingModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? success = null,Object? data = null,}) {
  return _then(_self.copyWith(
success: null == success ? _self.success : success // ignore: cast_nullable_to_non_nullable
as bool,data: null == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as CuriosityReadingData,
  ));
}
/// Create a copy of CuriosityReadingModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CuriosityReadingDataCopyWith<$Res> get data {
  
  return $CuriosityReadingDataCopyWith<$Res>(_self.data, (value) {
    return _then(_self.copyWith(data: value));
  });
}
}


/// Adds pattern-matching-related methods to [CuriosityReadingModel].
extension CuriosityReadingModelPatterns on CuriosityReadingModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CuriosityReadingModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CuriosityReadingModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CuriosityReadingModel value)  $default,){
final _that = this;
switch (_that) {
case _CuriosityReadingModel():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CuriosityReadingModel value)?  $default,){
final _that = this;
switch (_that) {
case _CuriosityReadingModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool success,  CuriosityReadingData data)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CuriosityReadingModel() when $default != null:
return $default(_that.success,_that.data);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool success,  CuriosityReadingData data)  $default,) {final _that = this;
switch (_that) {
case _CuriosityReadingModel():
return $default(_that.success,_that.data);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool success,  CuriosityReadingData data)?  $default,) {final _that = this;
switch (_that) {
case _CuriosityReadingModel() when $default != null:
return $default(_that.success,_that.data);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CuriosityReadingModel implements CuriosityReadingModel {
  const _CuriosityReadingModel({required this.success, required this.data});
  factory _CuriosityReadingModel.fromJson(Map<String, dynamic> json) => _$CuriosityReadingModelFromJson(json);

@override final  bool success;
@override final  CuriosityReadingData data;

/// Create a copy of CuriosityReadingModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CuriosityReadingModelCopyWith<_CuriosityReadingModel> get copyWith => __$CuriosityReadingModelCopyWithImpl<_CuriosityReadingModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CuriosityReadingModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CuriosityReadingModel&&(identical(other.success, success) || other.success == success)&&(identical(other.data, data) || other.data == data));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,success,data);

@override
String toString() {
  return 'CuriosityReadingModel(success: $success, data: $data)';
}


}

/// @nodoc
abstract mixin class _$CuriosityReadingModelCopyWith<$Res> implements $CuriosityReadingModelCopyWith<$Res> {
  factory _$CuriosityReadingModelCopyWith(_CuriosityReadingModel value, $Res Function(_CuriosityReadingModel) _then) = __$CuriosityReadingModelCopyWithImpl;
@override @useResult
$Res call({
 bool success, CuriosityReadingData data
});


@override $CuriosityReadingDataCopyWith<$Res> get data;

}
/// @nodoc
class __$CuriosityReadingModelCopyWithImpl<$Res>
    implements _$CuriosityReadingModelCopyWith<$Res> {
  __$CuriosityReadingModelCopyWithImpl(this._self, this._then);

  final _CuriosityReadingModel _self;
  final $Res Function(_CuriosityReadingModel) _then;

/// Create a copy of CuriosityReadingModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? success = null,Object? data = null,}) {
  return _then(_CuriosityReadingModel(
success: null == success ? _self.success : success // ignore: cast_nullable_to_non_nullable
as bool,data: null == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as CuriosityReadingData,
  ));
}

/// Create a copy of CuriosityReadingModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CuriosityReadingDataCopyWith<$Res> get data {
  
  return $CuriosityReadingDataCopyWith<$Res>(_self.data, (value) {
    return _then(_self.copyWith(data: value));
  });
}
}


/// @nodoc
mixin _$CuriosityReadingData {

 List<Reading> get readings; ReadingMeta get meta;
/// Create a copy of CuriosityReadingData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CuriosityReadingDataCopyWith<CuriosityReadingData> get copyWith => _$CuriosityReadingDataCopyWithImpl<CuriosityReadingData>(this as CuriosityReadingData, _$identity);

  /// Serializes this CuriosityReadingData to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CuriosityReadingData&&const DeepCollectionEquality().equals(other.readings, readings)&&(identical(other.meta, meta) || other.meta == meta));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(readings),meta);

@override
String toString() {
  return 'CuriosityReadingData(readings: $readings, meta: $meta)';
}


}

/// @nodoc
abstract mixin class $CuriosityReadingDataCopyWith<$Res>  {
  factory $CuriosityReadingDataCopyWith(CuriosityReadingData value, $Res Function(CuriosityReadingData) _then) = _$CuriosityReadingDataCopyWithImpl;
@useResult
$Res call({
 List<Reading> readings, ReadingMeta meta
});


$ReadingMetaCopyWith<$Res> get meta;

}
/// @nodoc
class _$CuriosityReadingDataCopyWithImpl<$Res>
    implements $CuriosityReadingDataCopyWith<$Res> {
  _$CuriosityReadingDataCopyWithImpl(this._self, this._then);

  final CuriosityReadingData _self;
  final $Res Function(CuriosityReadingData) _then;

/// Create a copy of CuriosityReadingData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? readings = null,Object? meta = null,}) {
  return _then(_self.copyWith(
readings: null == readings ? _self.readings : readings // ignore: cast_nullable_to_non_nullable
as List<Reading>,meta: null == meta ? _self.meta : meta // ignore: cast_nullable_to_non_nullable
as ReadingMeta,
  ));
}
/// Create a copy of CuriosityReadingData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ReadingMetaCopyWith<$Res> get meta {
  
  return $ReadingMetaCopyWith<$Res>(_self.meta, (value) {
    return _then(_self.copyWith(meta: value));
  });
}
}


/// Adds pattern-matching-related methods to [CuriosityReadingData].
extension CuriosityReadingDataPatterns on CuriosityReadingData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CuriosityReadingData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CuriosityReadingData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CuriosityReadingData value)  $default,){
final _that = this;
switch (_that) {
case _CuriosityReadingData():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CuriosityReadingData value)?  $default,){
final _that = this;
switch (_that) {
case _CuriosityReadingData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<Reading> readings,  ReadingMeta meta)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CuriosityReadingData() when $default != null:
return $default(_that.readings,_that.meta);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<Reading> readings,  ReadingMeta meta)  $default,) {final _that = this;
switch (_that) {
case _CuriosityReadingData():
return $default(_that.readings,_that.meta);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<Reading> readings,  ReadingMeta meta)?  $default,) {final _that = this;
switch (_that) {
case _CuriosityReadingData() when $default != null:
return $default(_that.readings,_that.meta);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CuriosityReadingData implements CuriosityReadingData {
  const _CuriosityReadingData({required final  List<Reading> readings, required this.meta}): _readings = readings;
  factory _CuriosityReadingData.fromJson(Map<String, dynamic> json) => _$CuriosityReadingDataFromJson(json);

 final  List<Reading> _readings;
@override List<Reading> get readings {
  if (_readings is EqualUnmodifiableListView) return _readings;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_readings);
}

@override final  ReadingMeta meta;

/// Create a copy of CuriosityReadingData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CuriosityReadingDataCopyWith<_CuriosityReadingData> get copyWith => __$CuriosityReadingDataCopyWithImpl<_CuriosityReadingData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CuriosityReadingDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CuriosityReadingData&&const DeepCollectionEquality().equals(other._readings, _readings)&&(identical(other.meta, meta) || other.meta == meta));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_readings),meta);

@override
String toString() {
  return 'CuriosityReadingData(readings: $readings, meta: $meta)';
}


}

/// @nodoc
abstract mixin class _$CuriosityReadingDataCopyWith<$Res> implements $CuriosityReadingDataCopyWith<$Res> {
  factory _$CuriosityReadingDataCopyWith(_CuriosityReadingData value, $Res Function(_CuriosityReadingData) _then) = __$CuriosityReadingDataCopyWithImpl;
@override @useResult
$Res call({
 List<Reading> readings, ReadingMeta meta
});


@override $ReadingMetaCopyWith<$Res> get meta;

}
/// @nodoc
class __$CuriosityReadingDataCopyWithImpl<$Res>
    implements _$CuriosityReadingDataCopyWith<$Res> {
  __$CuriosityReadingDataCopyWithImpl(this._self, this._then);

  final _CuriosityReadingData _self;
  final $Res Function(_CuriosityReadingData) _then;

/// Create a copy of CuriosityReadingData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? readings = null,Object? meta = null,}) {
  return _then(_CuriosityReadingData(
readings: null == readings ? _self._readings : readings // ignore: cast_nullable_to_non_nullable
as List<Reading>,meta: null == meta ? _self.meta : meta // ignore: cast_nullable_to_non_nullable
as ReadingMeta,
  ));
}

/// Create a copy of CuriosityReadingData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ReadingMetaCopyWith<$Res> get meta {
  
  return $ReadingMetaCopyWith<$Res>(_self.meta, (value) {
    return _then(_self.copyWith(meta: value));
  });
}
}


/// @nodoc
mixin _$Reading {

 String get id; String get title; String get question; String get imgUrl; String get interestId; String get interestName; String get ageBand; String get language; String get previewCardType;// List<String>? previewFacts,
 DateTime get publishedAt; int get estimatedReadTimeMinutes; ReadingBody get body; bool get hasBody; bool get isTranslated; bool get isRecycled; String get recommendationReason; double get rankScore;
/// Create a copy of Reading
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReadingCopyWith<Reading> get copyWith => _$ReadingCopyWithImpl<Reading>(this as Reading, _$identity);

  /// Serializes this Reading to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Reading&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.question, question) || other.question == question)&&(identical(other.imgUrl, imgUrl) || other.imgUrl == imgUrl)&&(identical(other.interestId, interestId) || other.interestId == interestId)&&(identical(other.interestName, interestName) || other.interestName == interestName)&&(identical(other.ageBand, ageBand) || other.ageBand == ageBand)&&(identical(other.language, language) || other.language == language)&&(identical(other.previewCardType, previewCardType) || other.previewCardType == previewCardType)&&(identical(other.publishedAt, publishedAt) || other.publishedAt == publishedAt)&&(identical(other.estimatedReadTimeMinutes, estimatedReadTimeMinutes) || other.estimatedReadTimeMinutes == estimatedReadTimeMinutes)&&(identical(other.body, body) || other.body == body)&&(identical(other.hasBody, hasBody) || other.hasBody == hasBody)&&(identical(other.isTranslated, isTranslated) || other.isTranslated == isTranslated)&&(identical(other.isRecycled, isRecycled) || other.isRecycled == isRecycled)&&(identical(other.recommendationReason, recommendationReason) || other.recommendationReason == recommendationReason)&&(identical(other.rankScore, rankScore) || other.rankScore == rankScore));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,question,imgUrl,interestId,interestName,ageBand,language,previewCardType,publishedAt,estimatedReadTimeMinutes,body,hasBody,isTranslated,isRecycled,recommendationReason,rankScore);

@override
String toString() {
  return 'Reading(id: $id, title: $title, question: $question, imgUrl: $imgUrl, interestId: $interestId, interestName: $interestName, ageBand: $ageBand, language: $language, previewCardType: $previewCardType, publishedAt: $publishedAt, estimatedReadTimeMinutes: $estimatedReadTimeMinutes, body: $body, hasBody: $hasBody, isTranslated: $isTranslated, isRecycled: $isRecycled, recommendationReason: $recommendationReason, rankScore: $rankScore)';
}


}

/// @nodoc
abstract mixin class $ReadingCopyWith<$Res>  {
  factory $ReadingCopyWith(Reading value, $Res Function(Reading) _then) = _$ReadingCopyWithImpl;
@useResult
$Res call({
 String id, String title, String question, String imgUrl, String interestId, String interestName, String ageBand, String language, String previewCardType, DateTime publishedAt, int estimatedReadTimeMinutes, ReadingBody body, bool hasBody, bool isTranslated, bool isRecycled, String recommendationReason, double rankScore
});


$ReadingBodyCopyWith<$Res> get body;

}
/// @nodoc
class _$ReadingCopyWithImpl<$Res>
    implements $ReadingCopyWith<$Res> {
  _$ReadingCopyWithImpl(this._self, this._then);

  final Reading _self;
  final $Res Function(Reading) _then;

/// Create a copy of Reading
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? question = null,Object? imgUrl = null,Object? interestId = null,Object? interestName = null,Object? ageBand = null,Object? language = null,Object? previewCardType = null,Object? publishedAt = null,Object? estimatedReadTimeMinutes = null,Object? body = null,Object? hasBody = null,Object? isTranslated = null,Object? isRecycled = null,Object? recommendationReason = null,Object? rankScore = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,question: null == question ? _self.question : question // ignore: cast_nullable_to_non_nullable
as String,imgUrl: null == imgUrl ? _self.imgUrl : imgUrl // ignore: cast_nullable_to_non_nullable
as String,interestId: null == interestId ? _self.interestId : interestId // ignore: cast_nullable_to_non_nullable
as String,interestName: null == interestName ? _self.interestName : interestName // ignore: cast_nullable_to_non_nullable
as String,ageBand: null == ageBand ? _self.ageBand : ageBand // ignore: cast_nullable_to_non_nullable
as String,language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String,previewCardType: null == previewCardType ? _self.previewCardType : previewCardType // ignore: cast_nullable_to_non_nullable
as String,publishedAt: null == publishedAt ? _self.publishedAt : publishedAt // ignore: cast_nullable_to_non_nullable
as DateTime,estimatedReadTimeMinutes: null == estimatedReadTimeMinutes ? _self.estimatedReadTimeMinutes : estimatedReadTimeMinutes // ignore: cast_nullable_to_non_nullable
as int,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as ReadingBody,hasBody: null == hasBody ? _self.hasBody : hasBody // ignore: cast_nullable_to_non_nullable
as bool,isTranslated: null == isTranslated ? _self.isTranslated : isTranslated // ignore: cast_nullable_to_non_nullable
as bool,isRecycled: null == isRecycled ? _self.isRecycled : isRecycled // ignore: cast_nullable_to_non_nullable
as bool,recommendationReason: null == recommendationReason ? _self.recommendationReason : recommendationReason // ignore: cast_nullable_to_non_nullable
as String,rankScore: null == rankScore ? _self.rankScore : rankScore // ignore: cast_nullable_to_non_nullable
as double,
  ));
}
/// Create a copy of Reading
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ReadingBodyCopyWith<$Res> get body {
  
  return $ReadingBodyCopyWith<$Res>(_self.body, (value) {
    return _then(_self.copyWith(body: value));
  });
}
}


/// Adds pattern-matching-related methods to [Reading].
extension ReadingPatterns on Reading {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Reading value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Reading() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Reading value)  $default,){
final _that = this;
switch (_that) {
case _Reading():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Reading value)?  $default,){
final _that = this;
switch (_that) {
case _Reading() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String question,  String imgUrl,  String interestId,  String interestName,  String ageBand,  String language,  String previewCardType,  DateTime publishedAt,  int estimatedReadTimeMinutes,  ReadingBody body,  bool hasBody,  bool isTranslated,  bool isRecycled,  String recommendationReason,  double rankScore)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Reading() when $default != null:
return $default(_that.id,_that.title,_that.question,_that.imgUrl,_that.interestId,_that.interestName,_that.ageBand,_that.language,_that.previewCardType,_that.publishedAt,_that.estimatedReadTimeMinutes,_that.body,_that.hasBody,_that.isTranslated,_that.isRecycled,_that.recommendationReason,_that.rankScore);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String question,  String imgUrl,  String interestId,  String interestName,  String ageBand,  String language,  String previewCardType,  DateTime publishedAt,  int estimatedReadTimeMinutes,  ReadingBody body,  bool hasBody,  bool isTranslated,  bool isRecycled,  String recommendationReason,  double rankScore)  $default,) {final _that = this;
switch (_that) {
case _Reading():
return $default(_that.id,_that.title,_that.question,_that.imgUrl,_that.interestId,_that.interestName,_that.ageBand,_that.language,_that.previewCardType,_that.publishedAt,_that.estimatedReadTimeMinutes,_that.body,_that.hasBody,_that.isTranslated,_that.isRecycled,_that.recommendationReason,_that.rankScore);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String question,  String imgUrl,  String interestId,  String interestName,  String ageBand,  String language,  String previewCardType,  DateTime publishedAt,  int estimatedReadTimeMinutes,  ReadingBody body,  bool hasBody,  bool isTranslated,  bool isRecycled,  String recommendationReason,  double rankScore)?  $default,) {final _that = this;
switch (_that) {
case _Reading() when $default != null:
return $default(_that.id,_that.title,_that.question,_that.imgUrl,_that.interestId,_that.interestName,_that.ageBand,_that.language,_that.previewCardType,_that.publishedAt,_that.estimatedReadTimeMinutes,_that.body,_that.hasBody,_that.isTranslated,_that.isRecycled,_that.recommendationReason,_that.rankScore);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Reading implements Reading {
  const _Reading({required this.id, required this.title, required this.question, required this.imgUrl, required this.interestId, required this.interestName, required this.ageBand, required this.language, required this.previewCardType, required this.publishedAt, required this.estimatedReadTimeMinutes, required this.body, required this.hasBody, required this.isTranslated, required this.isRecycled, required this.recommendationReason, required this.rankScore});
  factory _Reading.fromJson(Map<String, dynamic> json) => _$ReadingFromJson(json);

@override final  String id;
@override final  String title;
@override final  String question;
@override final  String imgUrl;
@override final  String interestId;
@override final  String interestName;
@override final  String ageBand;
@override final  String language;
@override final  String previewCardType;
// List<String>? previewFacts,
@override final  DateTime publishedAt;
@override final  int estimatedReadTimeMinutes;
@override final  ReadingBody body;
@override final  bool hasBody;
@override final  bool isTranslated;
@override final  bool isRecycled;
@override final  String recommendationReason;
@override final  double rankScore;

/// Create a copy of Reading
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReadingCopyWith<_Reading> get copyWith => __$ReadingCopyWithImpl<_Reading>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReadingToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Reading&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.question, question) || other.question == question)&&(identical(other.imgUrl, imgUrl) || other.imgUrl == imgUrl)&&(identical(other.interestId, interestId) || other.interestId == interestId)&&(identical(other.interestName, interestName) || other.interestName == interestName)&&(identical(other.ageBand, ageBand) || other.ageBand == ageBand)&&(identical(other.language, language) || other.language == language)&&(identical(other.previewCardType, previewCardType) || other.previewCardType == previewCardType)&&(identical(other.publishedAt, publishedAt) || other.publishedAt == publishedAt)&&(identical(other.estimatedReadTimeMinutes, estimatedReadTimeMinutes) || other.estimatedReadTimeMinutes == estimatedReadTimeMinutes)&&(identical(other.body, body) || other.body == body)&&(identical(other.hasBody, hasBody) || other.hasBody == hasBody)&&(identical(other.isTranslated, isTranslated) || other.isTranslated == isTranslated)&&(identical(other.isRecycled, isRecycled) || other.isRecycled == isRecycled)&&(identical(other.recommendationReason, recommendationReason) || other.recommendationReason == recommendationReason)&&(identical(other.rankScore, rankScore) || other.rankScore == rankScore));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,question,imgUrl,interestId,interestName,ageBand,language,previewCardType,publishedAt,estimatedReadTimeMinutes,body,hasBody,isTranslated,isRecycled,recommendationReason,rankScore);

@override
String toString() {
  return 'Reading(id: $id, title: $title, question: $question, imgUrl: $imgUrl, interestId: $interestId, interestName: $interestName, ageBand: $ageBand, language: $language, previewCardType: $previewCardType, publishedAt: $publishedAt, estimatedReadTimeMinutes: $estimatedReadTimeMinutes, body: $body, hasBody: $hasBody, isTranslated: $isTranslated, isRecycled: $isRecycled, recommendationReason: $recommendationReason, rankScore: $rankScore)';
}


}

/// @nodoc
abstract mixin class _$ReadingCopyWith<$Res> implements $ReadingCopyWith<$Res> {
  factory _$ReadingCopyWith(_Reading value, $Res Function(_Reading) _then) = __$ReadingCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String question, String imgUrl, String interestId, String interestName, String ageBand, String language, String previewCardType, DateTime publishedAt, int estimatedReadTimeMinutes, ReadingBody body, bool hasBody, bool isTranslated, bool isRecycled, String recommendationReason, double rankScore
});


@override $ReadingBodyCopyWith<$Res> get body;

}
/// @nodoc
class __$ReadingCopyWithImpl<$Res>
    implements _$ReadingCopyWith<$Res> {
  __$ReadingCopyWithImpl(this._self, this._then);

  final _Reading _self;
  final $Res Function(_Reading) _then;

/// Create a copy of Reading
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? question = null,Object? imgUrl = null,Object? interestId = null,Object? interestName = null,Object? ageBand = null,Object? language = null,Object? previewCardType = null,Object? publishedAt = null,Object? estimatedReadTimeMinutes = null,Object? body = null,Object? hasBody = null,Object? isTranslated = null,Object? isRecycled = null,Object? recommendationReason = null,Object? rankScore = null,}) {
  return _then(_Reading(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,question: null == question ? _self.question : question // ignore: cast_nullable_to_non_nullable
as String,imgUrl: null == imgUrl ? _self.imgUrl : imgUrl // ignore: cast_nullable_to_non_nullable
as String,interestId: null == interestId ? _self.interestId : interestId // ignore: cast_nullable_to_non_nullable
as String,interestName: null == interestName ? _self.interestName : interestName // ignore: cast_nullable_to_non_nullable
as String,ageBand: null == ageBand ? _self.ageBand : ageBand // ignore: cast_nullable_to_non_nullable
as String,language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String,previewCardType: null == previewCardType ? _self.previewCardType : previewCardType // ignore: cast_nullable_to_non_nullable
as String,publishedAt: null == publishedAt ? _self.publishedAt : publishedAt // ignore: cast_nullable_to_non_nullable
as DateTime,estimatedReadTimeMinutes: null == estimatedReadTimeMinutes ? _self.estimatedReadTimeMinutes : estimatedReadTimeMinutes // ignore: cast_nullable_to_non_nullable
as int,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as ReadingBody,hasBody: null == hasBody ? _self.hasBody : hasBody // ignore: cast_nullable_to_non_nullable
as bool,isTranslated: null == isTranslated ? _self.isTranslated : isTranslated // ignore: cast_nullable_to_non_nullable
as bool,isRecycled: null == isRecycled ? _self.isRecycled : isRecycled // ignore: cast_nullable_to_non_nullable
as bool,recommendationReason: null == recommendationReason ? _self.recommendationReason : recommendationReason // ignore: cast_nullable_to_non_nullable
as String,rankScore: null == rankScore ? _self.rankScore : rankScore // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

/// Create a copy of Reading
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ReadingBodyCopyWith<$Res> get body {
  
  return $ReadingBodyCopyWith<$Res>(_self.body, (value) {
    return _then(_self.copyWith(body: value));
  });
}
}


/// @nodoc
mixin _$ReadingBody {

 String get article; List<String> get keyFacts; String get quote; String get readingLevel;
/// Create a copy of ReadingBody
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReadingBodyCopyWith<ReadingBody> get copyWith => _$ReadingBodyCopyWithImpl<ReadingBody>(this as ReadingBody, _$identity);

  /// Serializes this ReadingBody to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReadingBody&&(identical(other.article, article) || other.article == article)&&const DeepCollectionEquality().equals(other.keyFacts, keyFacts)&&(identical(other.quote, quote) || other.quote == quote)&&(identical(other.readingLevel, readingLevel) || other.readingLevel == readingLevel));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,article,const DeepCollectionEquality().hash(keyFacts),quote,readingLevel);

@override
String toString() {
  return 'ReadingBody(article: $article, keyFacts: $keyFacts, quote: $quote, readingLevel: $readingLevel)';
}


}

/// @nodoc
abstract mixin class $ReadingBodyCopyWith<$Res>  {
  factory $ReadingBodyCopyWith(ReadingBody value, $Res Function(ReadingBody) _then) = _$ReadingBodyCopyWithImpl;
@useResult
$Res call({
 String article, List<String> keyFacts, String quote, String readingLevel
});




}
/// @nodoc
class _$ReadingBodyCopyWithImpl<$Res>
    implements $ReadingBodyCopyWith<$Res> {
  _$ReadingBodyCopyWithImpl(this._self, this._then);

  final ReadingBody _self;
  final $Res Function(ReadingBody) _then;

/// Create a copy of ReadingBody
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? article = null,Object? keyFacts = null,Object? quote = null,Object? readingLevel = null,}) {
  return _then(_self.copyWith(
article: null == article ? _self.article : article // ignore: cast_nullable_to_non_nullable
as String,keyFacts: null == keyFacts ? _self.keyFacts : keyFacts // ignore: cast_nullable_to_non_nullable
as List<String>,quote: null == quote ? _self.quote : quote // ignore: cast_nullable_to_non_nullable
as String,readingLevel: null == readingLevel ? _self.readingLevel : readingLevel // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ReadingBody].
extension ReadingBodyPatterns on ReadingBody {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReadingBody value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReadingBody() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReadingBody value)  $default,){
final _that = this;
switch (_that) {
case _ReadingBody():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReadingBody value)?  $default,){
final _that = this;
switch (_that) {
case _ReadingBody() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String article,  List<String> keyFacts,  String quote,  String readingLevel)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReadingBody() when $default != null:
return $default(_that.article,_that.keyFacts,_that.quote,_that.readingLevel);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String article,  List<String> keyFacts,  String quote,  String readingLevel)  $default,) {final _that = this;
switch (_that) {
case _ReadingBody():
return $default(_that.article,_that.keyFacts,_that.quote,_that.readingLevel);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String article,  List<String> keyFacts,  String quote,  String readingLevel)?  $default,) {final _that = this;
switch (_that) {
case _ReadingBody() when $default != null:
return $default(_that.article,_that.keyFacts,_that.quote,_that.readingLevel);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ReadingBody implements ReadingBody {
  const _ReadingBody({required this.article, required final  List<String> keyFacts, required this.quote, required this.readingLevel}): _keyFacts = keyFacts;
  factory _ReadingBody.fromJson(Map<String, dynamic> json) => _$ReadingBodyFromJson(json);

@override final  String article;
 final  List<String> _keyFacts;
@override List<String> get keyFacts {
  if (_keyFacts is EqualUnmodifiableListView) return _keyFacts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_keyFacts);
}

@override final  String quote;
@override final  String readingLevel;

/// Create a copy of ReadingBody
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReadingBodyCopyWith<_ReadingBody> get copyWith => __$ReadingBodyCopyWithImpl<_ReadingBody>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReadingBodyToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReadingBody&&(identical(other.article, article) || other.article == article)&&const DeepCollectionEquality().equals(other._keyFacts, _keyFacts)&&(identical(other.quote, quote) || other.quote == quote)&&(identical(other.readingLevel, readingLevel) || other.readingLevel == readingLevel));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,article,const DeepCollectionEquality().hash(_keyFacts),quote,readingLevel);

@override
String toString() {
  return 'ReadingBody(article: $article, keyFacts: $keyFacts, quote: $quote, readingLevel: $readingLevel)';
}


}

/// @nodoc
abstract mixin class _$ReadingBodyCopyWith<$Res> implements $ReadingBodyCopyWith<$Res> {
  factory _$ReadingBodyCopyWith(_ReadingBody value, $Res Function(_ReadingBody) _then) = __$ReadingBodyCopyWithImpl;
@override @useResult
$Res call({
 String article, List<String> keyFacts, String quote, String readingLevel
});




}
/// @nodoc
class __$ReadingBodyCopyWithImpl<$Res>
    implements _$ReadingBodyCopyWith<$Res> {
  __$ReadingBodyCopyWithImpl(this._self, this._then);

  final _ReadingBody _self;
  final $Res Function(_ReadingBody) _then;

/// Create a copy of ReadingBody
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? article = null,Object? keyFacts = null,Object? quote = null,Object? readingLevel = null,}) {
  return _then(_ReadingBody(
article: null == article ? _self.article : article // ignore: cast_nullable_to_non_nullable
as String,keyFacts: null == keyFacts ? _self._keyFacts : keyFacts // ignore: cast_nullable_to_non_nullable
as List<String>,quote: null == quote ? _self.quote : quote // ignore: cast_nullable_to_non_nullable
as String,readingLevel: null == readingLevel ? _self.readingLevel : readingLevel // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$ReadingMeta {

 String get userId; String get ageBand; String get language; String get languageCode; List<String> get interestsUsed; bool get isColdStart; int get totalCandidates; int get returnedCount; ReadingPool get pool; Pagination get pagination; TranslationMeta get translation;
/// Create a copy of ReadingMeta
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReadingMetaCopyWith<ReadingMeta> get copyWith => _$ReadingMetaCopyWithImpl<ReadingMeta>(this as ReadingMeta, _$identity);

  /// Serializes this ReadingMeta to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReadingMeta&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.ageBand, ageBand) || other.ageBand == ageBand)&&(identical(other.language, language) || other.language == language)&&(identical(other.languageCode, languageCode) || other.languageCode == languageCode)&&const DeepCollectionEquality().equals(other.interestsUsed, interestsUsed)&&(identical(other.isColdStart, isColdStart) || other.isColdStart == isColdStart)&&(identical(other.totalCandidates, totalCandidates) || other.totalCandidates == totalCandidates)&&(identical(other.returnedCount, returnedCount) || other.returnedCount == returnedCount)&&(identical(other.pool, pool) || other.pool == pool)&&(identical(other.pagination, pagination) || other.pagination == pagination)&&(identical(other.translation, translation) || other.translation == translation));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,ageBand,language,languageCode,const DeepCollectionEquality().hash(interestsUsed),isColdStart,totalCandidates,returnedCount,pool,pagination,translation);

@override
String toString() {
  return 'ReadingMeta(userId: $userId, ageBand: $ageBand, language: $language, languageCode: $languageCode, interestsUsed: $interestsUsed, isColdStart: $isColdStart, totalCandidates: $totalCandidates, returnedCount: $returnedCount, pool: $pool, pagination: $pagination, translation: $translation)';
}


}

/// @nodoc
abstract mixin class $ReadingMetaCopyWith<$Res>  {
  factory $ReadingMetaCopyWith(ReadingMeta value, $Res Function(ReadingMeta) _then) = _$ReadingMetaCopyWithImpl;
@useResult
$Res call({
 String userId, String ageBand, String language, String languageCode, List<String> interestsUsed, bool isColdStart, int totalCandidates, int returnedCount, ReadingPool pool, Pagination pagination, TranslationMeta translation
});


$ReadingPoolCopyWith<$Res> get pool;$PaginationCopyWith<$Res> get pagination;$TranslationMetaCopyWith<$Res> get translation;

}
/// @nodoc
class _$ReadingMetaCopyWithImpl<$Res>
    implements $ReadingMetaCopyWith<$Res> {
  _$ReadingMetaCopyWithImpl(this._self, this._then);

  final ReadingMeta _self;
  final $Res Function(ReadingMeta) _then;

/// Create a copy of ReadingMeta
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userId = null,Object? ageBand = null,Object? language = null,Object? languageCode = null,Object? interestsUsed = null,Object? isColdStart = null,Object? totalCandidates = null,Object? returnedCount = null,Object? pool = null,Object? pagination = null,Object? translation = null,}) {
  return _then(_self.copyWith(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,ageBand: null == ageBand ? _self.ageBand : ageBand // ignore: cast_nullable_to_non_nullable
as String,language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String,languageCode: null == languageCode ? _self.languageCode : languageCode // ignore: cast_nullable_to_non_nullable
as String,interestsUsed: null == interestsUsed ? _self.interestsUsed : interestsUsed // ignore: cast_nullable_to_non_nullable
as List<String>,isColdStart: null == isColdStart ? _self.isColdStart : isColdStart // ignore: cast_nullable_to_non_nullable
as bool,totalCandidates: null == totalCandidates ? _self.totalCandidates : totalCandidates // ignore: cast_nullable_to_non_nullable
as int,returnedCount: null == returnedCount ? _self.returnedCount : returnedCount // ignore: cast_nullable_to_non_nullable
as int,pool: null == pool ? _self.pool : pool // ignore: cast_nullable_to_non_nullable
as ReadingPool,pagination: null == pagination ? _self.pagination : pagination // ignore: cast_nullable_to_non_nullable
as Pagination,translation: null == translation ? _self.translation : translation // ignore: cast_nullable_to_non_nullable
as TranslationMeta,
  ));
}
/// Create a copy of ReadingMeta
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ReadingPoolCopyWith<$Res> get pool {
  
  return $ReadingPoolCopyWith<$Res>(_self.pool, (value) {
    return _then(_self.copyWith(pool: value));
  });
}/// Create a copy of ReadingMeta
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PaginationCopyWith<$Res> get pagination {
  
  return $PaginationCopyWith<$Res>(_self.pagination, (value) {
    return _then(_self.copyWith(pagination: value));
  });
}/// Create a copy of ReadingMeta
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TranslationMetaCopyWith<$Res> get translation {
  
  return $TranslationMetaCopyWith<$Res>(_self.translation, (value) {
    return _then(_self.copyWith(translation: value));
  });
}
}


/// Adds pattern-matching-related methods to [ReadingMeta].
extension ReadingMetaPatterns on ReadingMeta {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReadingMeta value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReadingMeta() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReadingMeta value)  $default,){
final _that = this;
switch (_that) {
case _ReadingMeta():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReadingMeta value)?  $default,){
final _that = this;
switch (_that) {
case _ReadingMeta() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String userId,  String ageBand,  String language,  String languageCode,  List<String> interestsUsed,  bool isColdStart,  int totalCandidates,  int returnedCount,  ReadingPool pool,  Pagination pagination,  TranslationMeta translation)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReadingMeta() when $default != null:
return $default(_that.userId,_that.ageBand,_that.language,_that.languageCode,_that.interestsUsed,_that.isColdStart,_that.totalCandidates,_that.returnedCount,_that.pool,_that.pagination,_that.translation);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String userId,  String ageBand,  String language,  String languageCode,  List<String> interestsUsed,  bool isColdStart,  int totalCandidates,  int returnedCount,  ReadingPool pool,  Pagination pagination,  TranslationMeta translation)  $default,) {final _that = this;
switch (_that) {
case _ReadingMeta():
return $default(_that.userId,_that.ageBand,_that.language,_that.languageCode,_that.interestsUsed,_that.isColdStart,_that.totalCandidates,_that.returnedCount,_that.pool,_that.pagination,_that.translation);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String userId,  String ageBand,  String language,  String languageCode,  List<String> interestsUsed,  bool isColdStart,  int totalCandidates,  int returnedCount,  ReadingPool pool,  Pagination pagination,  TranslationMeta translation)?  $default,) {final _that = this;
switch (_that) {
case _ReadingMeta() when $default != null:
return $default(_that.userId,_that.ageBand,_that.language,_that.languageCode,_that.interestsUsed,_that.isColdStart,_that.totalCandidates,_that.returnedCount,_that.pool,_that.pagination,_that.translation);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ReadingMeta implements ReadingMeta {
  const _ReadingMeta({required this.userId, required this.ageBand, required this.language, required this.languageCode, required final  List<String> interestsUsed, required this.isColdStart, required this.totalCandidates, required this.returnedCount, required this.pool, required this.pagination, required this.translation}): _interestsUsed = interestsUsed;
  factory _ReadingMeta.fromJson(Map<String, dynamic> json) => _$ReadingMetaFromJson(json);

@override final  String userId;
@override final  String ageBand;
@override final  String language;
@override final  String languageCode;
 final  List<String> _interestsUsed;
@override List<String> get interestsUsed {
  if (_interestsUsed is EqualUnmodifiableListView) return _interestsUsed;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_interestsUsed);
}

@override final  bool isColdStart;
@override final  int totalCandidates;
@override final  int returnedCount;
@override final  ReadingPool pool;
@override final  Pagination pagination;
@override final  TranslationMeta translation;

/// Create a copy of ReadingMeta
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReadingMetaCopyWith<_ReadingMeta> get copyWith => __$ReadingMetaCopyWithImpl<_ReadingMeta>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReadingMetaToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReadingMeta&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.ageBand, ageBand) || other.ageBand == ageBand)&&(identical(other.language, language) || other.language == language)&&(identical(other.languageCode, languageCode) || other.languageCode == languageCode)&&const DeepCollectionEquality().equals(other._interestsUsed, _interestsUsed)&&(identical(other.isColdStart, isColdStart) || other.isColdStart == isColdStart)&&(identical(other.totalCandidates, totalCandidates) || other.totalCandidates == totalCandidates)&&(identical(other.returnedCount, returnedCount) || other.returnedCount == returnedCount)&&(identical(other.pool, pool) || other.pool == pool)&&(identical(other.pagination, pagination) || other.pagination == pagination)&&(identical(other.translation, translation) || other.translation == translation));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,ageBand,language,languageCode,const DeepCollectionEquality().hash(_interestsUsed),isColdStart,totalCandidates,returnedCount,pool,pagination,translation);

@override
String toString() {
  return 'ReadingMeta(userId: $userId, ageBand: $ageBand, language: $language, languageCode: $languageCode, interestsUsed: $interestsUsed, isColdStart: $isColdStart, totalCandidates: $totalCandidates, returnedCount: $returnedCount, pool: $pool, pagination: $pagination, translation: $translation)';
}


}

/// @nodoc
abstract mixin class _$ReadingMetaCopyWith<$Res> implements $ReadingMetaCopyWith<$Res> {
  factory _$ReadingMetaCopyWith(_ReadingMeta value, $Res Function(_ReadingMeta) _then) = __$ReadingMetaCopyWithImpl;
@override @useResult
$Res call({
 String userId, String ageBand, String language, String languageCode, List<String> interestsUsed, bool isColdStart, int totalCandidates, int returnedCount, ReadingPool pool, Pagination pagination, TranslationMeta translation
});


@override $ReadingPoolCopyWith<$Res> get pool;@override $PaginationCopyWith<$Res> get pagination;@override $TranslationMetaCopyWith<$Res> get translation;

}
/// @nodoc
class __$ReadingMetaCopyWithImpl<$Res>
    implements _$ReadingMetaCopyWith<$Res> {
  __$ReadingMetaCopyWithImpl(this._self, this._then);

  final _ReadingMeta _self;
  final $Res Function(_ReadingMeta) _then;

/// Create a copy of ReadingMeta
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userId = null,Object? ageBand = null,Object? language = null,Object? languageCode = null,Object? interestsUsed = null,Object? isColdStart = null,Object? totalCandidates = null,Object? returnedCount = null,Object? pool = null,Object? pagination = null,Object? translation = null,}) {
  return _then(_ReadingMeta(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,ageBand: null == ageBand ? _self.ageBand : ageBand // ignore: cast_nullable_to_non_nullable
as String,language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String,languageCode: null == languageCode ? _self.languageCode : languageCode // ignore: cast_nullable_to_non_nullable
as String,interestsUsed: null == interestsUsed ? _self._interestsUsed : interestsUsed // ignore: cast_nullable_to_non_nullable
as List<String>,isColdStart: null == isColdStart ? _self.isColdStart : isColdStart // ignore: cast_nullable_to_non_nullable
as bool,totalCandidates: null == totalCandidates ? _self.totalCandidates : totalCandidates // ignore: cast_nullable_to_non_nullable
as int,returnedCount: null == returnedCount ? _self.returnedCount : returnedCount // ignore: cast_nullable_to_non_nullable
as int,pool: null == pool ? _self.pool : pool // ignore: cast_nullable_to_non_nullable
as ReadingPool,pagination: null == pagination ? _self.pagination : pagination // ignore: cast_nullable_to_non_nullable
as Pagination,translation: null == translation ? _self.translation : translation // ignore: cast_nullable_to_non_nullable
as TranslationMeta,
  ));
}

/// Create a copy of ReadingMeta
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ReadingPoolCopyWith<$Res> get pool {
  
  return $ReadingPoolCopyWith<$Res>(_self.pool, (value) {
    return _then(_self.copyWith(pool: value));
  });
}/// Create a copy of ReadingMeta
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PaginationCopyWith<$Res> get pagination {
  
  return $PaginationCopyWith<$Res>(_self.pagination, (value) {
    return _then(_self.copyWith(pagination: value));
  });
}/// Create a copy of ReadingMeta
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TranslationMetaCopyWith<$Res> get translation {
  
  return $TranslationMetaCopyWith<$Res>(_self.translation, (value) {
    return _then(_self.copyWith(translation: value));
  });
}
}


/// @nodoc
mixin _$ReadingPool {

 int get sameAgeUnseen; int get crossAgeInterestUnseen; int get crossAgeBroadUnseen; int get recycled; bool get expandedBeyondAgeBand; bool get includesRecycled;
/// Create a copy of ReadingPool
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReadingPoolCopyWith<ReadingPool> get copyWith => _$ReadingPoolCopyWithImpl<ReadingPool>(this as ReadingPool, _$identity);

  /// Serializes this ReadingPool to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReadingPool&&(identical(other.sameAgeUnseen, sameAgeUnseen) || other.sameAgeUnseen == sameAgeUnseen)&&(identical(other.crossAgeInterestUnseen, crossAgeInterestUnseen) || other.crossAgeInterestUnseen == crossAgeInterestUnseen)&&(identical(other.crossAgeBroadUnseen, crossAgeBroadUnseen) || other.crossAgeBroadUnseen == crossAgeBroadUnseen)&&(identical(other.recycled, recycled) || other.recycled == recycled)&&(identical(other.expandedBeyondAgeBand, expandedBeyondAgeBand) || other.expandedBeyondAgeBand == expandedBeyondAgeBand)&&(identical(other.includesRecycled, includesRecycled) || other.includesRecycled == includesRecycled));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,sameAgeUnseen,crossAgeInterestUnseen,crossAgeBroadUnseen,recycled,expandedBeyondAgeBand,includesRecycled);

@override
String toString() {
  return 'ReadingPool(sameAgeUnseen: $sameAgeUnseen, crossAgeInterestUnseen: $crossAgeInterestUnseen, crossAgeBroadUnseen: $crossAgeBroadUnseen, recycled: $recycled, expandedBeyondAgeBand: $expandedBeyondAgeBand, includesRecycled: $includesRecycled)';
}


}

/// @nodoc
abstract mixin class $ReadingPoolCopyWith<$Res>  {
  factory $ReadingPoolCopyWith(ReadingPool value, $Res Function(ReadingPool) _then) = _$ReadingPoolCopyWithImpl;
@useResult
$Res call({
 int sameAgeUnseen, int crossAgeInterestUnseen, int crossAgeBroadUnseen, int recycled, bool expandedBeyondAgeBand, bool includesRecycled
});




}
/// @nodoc
class _$ReadingPoolCopyWithImpl<$Res>
    implements $ReadingPoolCopyWith<$Res> {
  _$ReadingPoolCopyWithImpl(this._self, this._then);

  final ReadingPool _self;
  final $Res Function(ReadingPool) _then;

/// Create a copy of ReadingPool
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? sameAgeUnseen = null,Object? crossAgeInterestUnseen = null,Object? crossAgeBroadUnseen = null,Object? recycled = null,Object? expandedBeyondAgeBand = null,Object? includesRecycled = null,}) {
  return _then(_self.copyWith(
sameAgeUnseen: null == sameAgeUnseen ? _self.sameAgeUnseen : sameAgeUnseen // ignore: cast_nullable_to_non_nullable
as int,crossAgeInterestUnseen: null == crossAgeInterestUnseen ? _self.crossAgeInterestUnseen : crossAgeInterestUnseen // ignore: cast_nullable_to_non_nullable
as int,crossAgeBroadUnseen: null == crossAgeBroadUnseen ? _self.crossAgeBroadUnseen : crossAgeBroadUnseen // ignore: cast_nullable_to_non_nullable
as int,recycled: null == recycled ? _self.recycled : recycled // ignore: cast_nullable_to_non_nullable
as int,expandedBeyondAgeBand: null == expandedBeyondAgeBand ? _self.expandedBeyondAgeBand : expandedBeyondAgeBand // ignore: cast_nullable_to_non_nullable
as bool,includesRecycled: null == includesRecycled ? _self.includesRecycled : includesRecycled // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ReadingPool].
extension ReadingPoolPatterns on ReadingPool {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReadingPool value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReadingPool() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReadingPool value)  $default,){
final _that = this;
switch (_that) {
case _ReadingPool():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReadingPool value)?  $default,){
final _that = this;
switch (_that) {
case _ReadingPool() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int sameAgeUnseen,  int crossAgeInterestUnseen,  int crossAgeBroadUnseen,  int recycled,  bool expandedBeyondAgeBand,  bool includesRecycled)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReadingPool() when $default != null:
return $default(_that.sameAgeUnseen,_that.crossAgeInterestUnseen,_that.crossAgeBroadUnseen,_that.recycled,_that.expandedBeyondAgeBand,_that.includesRecycled);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int sameAgeUnseen,  int crossAgeInterestUnseen,  int crossAgeBroadUnseen,  int recycled,  bool expandedBeyondAgeBand,  bool includesRecycled)  $default,) {final _that = this;
switch (_that) {
case _ReadingPool():
return $default(_that.sameAgeUnseen,_that.crossAgeInterestUnseen,_that.crossAgeBroadUnseen,_that.recycled,_that.expandedBeyondAgeBand,_that.includesRecycled);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int sameAgeUnseen,  int crossAgeInterestUnseen,  int crossAgeBroadUnseen,  int recycled,  bool expandedBeyondAgeBand,  bool includesRecycled)?  $default,) {final _that = this;
switch (_that) {
case _ReadingPool() when $default != null:
return $default(_that.sameAgeUnseen,_that.crossAgeInterestUnseen,_that.crossAgeBroadUnseen,_that.recycled,_that.expandedBeyondAgeBand,_that.includesRecycled);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ReadingPool implements ReadingPool {
  const _ReadingPool({required this.sameAgeUnseen, required this.crossAgeInterestUnseen, required this.crossAgeBroadUnseen, required this.recycled, required this.expandedBeyondAgeBand, required this.includesRecycled});
  factory _ReadingPool.fromJson(Map<String, dynamic> json) => _$ReadingPoolFromJson(json);

@override final  int sameAgeUnseen;
@override final  int crossAgeInterestUnseen;
@override final  int crossAgeBroadUnseen;
@override final  int recycled;
@override final  bool expandedBeyondAgeBand;
@override final  bool includesRecycled;

/// Create a copy of ReadingPool
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReadingPoolCopyWith<_ReadingPool> get copyWith => __$ReadingPoolCopyWithImpl<_ReadingPool>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReadingPoolToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReadingPool&&(identical(other.sameAgeUnseen, sameAgeUnseen) || other.sameAgeUnseen == sameAgeUnseen)&&(identical(other.crossAgeInterestUnseen, crossAgeInterestUnseen) || other.crossAgeInterestUnseen == crossAgeInterestUnseen)&&(identical(other.crossAgeBroadUnseen, crossAgeBroadUnseen) || other.crossAgeBroadUnseen == crossAgeBroadUnseen)&&(identical(other.recycled, recycled) || other.recycled == recycled)&&(identical(other.expandedBeyondAgeBand, expandedBeyondAgeBand) || other.expandedBeyondAgeBand == expandedBeyondAgeBand)&&(identical(other.includesRecycled, includesRecycled) || other.includesRecycled == includesRecycled));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,sameAgeUnseen,crossAgeInterestUnseen,crossAgeBroadUnseen,recycled,expandedBeyondAgeBand,includesRecycled);

@override
String toString() {
  return 'ReadingPool(sameAgeUnseen: $sameAgeUnseen, crossAgeInterestUnseen: $crossAgeInterestUnseen, crossAgeBroadUnseen: $crossAgeBroadUnseen, recycled: $recycled, expandedBeyondAgeBand: $expandedBeyondAgeBand, includesRecycled: $includesRecycled)';
}


}

/// @nodoc
abstract mixin class _$ReadingPoolCopyWith<$Res> implements $ReadingPoolCopyWith<$Res> {
  factory _$ReadingPoolCopyWith(_ReadingPool value, $Res Function(_ReadingPool) _then) = __$ReadingPoolCopyWithImpl;
@override @useResult
$Res call({
 int sameAgeUnseen, int crossAgeInterestUnseen, int crossAgeBroadUnseen, int recycled, bool expandedBeyondAgeBand, bool includesRecycled
});




}
/// @nodoc
class __$ReadingPoolCopyWithImpl<$Res>
    implements _$ReadingPoolCopyWith<$Res> {
  __$ReadingPoolCopyWithImpl(this._self, this._then);

  final _ReadingPool _self;
  final $Res Function(_ReadingPool) _then;

/// Create a copy of ReadingPool
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? sameAgeUnseen = null,Object? crossAgeInterestUnseen = null,Object? crossAgeBroadUnseen = null,Object? recycled = null,Object? expandedBeyondAgeBand = null,Object? includesRecycled = null,}) {
  return _then(_ReadingPool(
sameAgeUnseen: null == sameAgeUnseen ? _self.sameAgeUnseen : sameAgeUnseen // ignore: cast_nullable_to_non_nullable
as int,crossAgeInterestUnseen: null == crossAgeInterestUnseen ? _self.crossAgeInterestUnseen : crossAgeInterestUnseen // ignore: cast_nullable_to_non_nullable
as int,crossAgeBroadUnseen: null == crossAgeBroadUnseen ? _self.crossAgeBroadUnseen : crossAgeBroadUnseen // ignore: cast_nullable_to_non_nullable
as int,recycled: null == recycled ? _self.recycled : recycled // ignore: cast_nullable_to_non_nullable
as int,expandedBeyondAgeBand: null == expandedBeyondAgeBand ? _self.expandedBeyondAgeBand : expandedBeyondAgeBand // ignore: cast_nullable_to_non_nullable
as bool,includesRecycled: null == includesRecycled ? _self.includesRecycled : includesRecycled // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$Pagination {

 int get page; int get limit; int get offset; int get total; int get totalPages; bool get hasMore;
/// Create a copy of Pagination
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PaginationCopyWith<Pagination> get copyWith => _$PaginationCopyWithImpl<Pagination>(this as Pagination, _$identity);

  /// Serializes this Pagination to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Pagination&&(identical(other.page, page) || other.page == page)&&(identical(other.limit, limit) || other.limit == limit)&&(identical(other.offset, offset) || other.offset == offset)&&(identical(other.total, total) || other.total == total)&&(identical(other.totalPages, totalPages) || other.totalPages == totalPages)&&(identical(other.hasMore, hasMore) || other.hasMore == hasMore));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,page,limit,offset,total,totalPages,hasMore);

@override
String toString() {
  return 'Pagination(page: $page, limit: $limit, offset: $offset, total: $total, totalPages: $totalPages, hasMore: $hasMore)';
}


}

/// @nodoc
abstract mixin class $PaginationCopyWith<$Res>  {
  factory $PaginationCopyWith(Pagination value, $Res Function(Pagination) _then) = _$PaginationCopyWithImpl;
@useResult
$Res call({
 int page, int limit, int offset, int total, int totalPages, bool hasMore
});




}
/// @nodoc
class _$PaginationCopyWithImpl<$Res>
    implements $PaginationCopyWith<$Res> {
  _$PaginationCopyWithImpl(this._self, this._then);

  final Pagination _self;
  final $Res Function(Pagination) _then;

/// Create a copy of Pagination
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? page = null,Object? limit = null,Object? offset = null,Object? total = null,Object? totalPages = null,Object? hasMore = null,}) {
  return _then(_self.copyWith(
page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,limit: null == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as int,offset: null == offset ? _self.offset : offset // ignore: cast_nullable_to_non_nullable
as int,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,totalPages: null == totalPages ? _self.totalPages : totalPages // ignore: cast_nullable_to_non_nullable
as int,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [Pagination].
extension PaginationPatterns on Pagination {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Pagination value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Pagination() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Pagination value)  $default,){
final _that = this;
switch (_that) {
case _Pagination():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Pagination value)?  $default,){
final _that = this;
switch (_that) {
case _Pagination() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int page,  int limit,  int offset,  int total,  int totalPages,  bool hasMore)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Pagination() when $default != null:
return $default(_that.page,_that.limit,_that.offset,_that.total,_that.totalPages,_that.hasMore);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int page,  int limit,  int offset,  int total,  int totalPages,  bool hasMore)  $default,) {final _that = this;
switch (_that) {
case _Pagination():
return $default(_that.page,_that.limit,_that.offset,_that.total,_that.totalPages,_that.hasMore);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int page,  int limit,  int offset,  int total,  int totalPages,  bool hasMore)?  $default,) {final _that = this;
switch (_that) {
case _Pagination() when $default != null:
return $default(_that.page,_that.limit,_that.offset,_that.total,_that.totalPages,_that.hasMore);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Pagination implements Pagination {
  const _Pagination({required this.page, required this.limit, required this.offset, required this.total, required this.totalPages, required this.hasMore});
  factory _Pagination.fromJson(Map<String, dynamic> json) => _$PaginationFromJson(json);

@override final  int page;
@override final  int limit;
@override final  int offset;
@override final  int total;
@override final  int totalPages;
@override final  bool hasMore;

/// Create a copy of Pagination
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PaginationCopyWith<_Pagination> get copyWith => __$PaginationCopyWithImpl<_Pagination>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PaginationToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Pagination&&(identical(other.page, page) || other.page == page)&&(identical(other.limit, limit) || other.limit == limit)&&(identical(other.offset, offset) || other.offset == offset)&&(identical(other.total, total) || other.total == total)&&(identical(other.totalPages, totalPages) || other.totalPages == totalPages)&&(identical(other.hasMore, hasMore) || other.hasMore == hasMore));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,page,limit,offset,total,totalPages,hasMore);

@override
String toString() {
  return 'Pagination(page: $page, limit: $limit, offset: $offset, total: $total, totalPages: $totalPages, hasMore: $hasMore)';
}


}

/// @nodoc
abstract mixin class _$PaginationCopyWith<$Res> implements $PaginationCopyWith<$Res> {
  factory _$PaginationCopyWith(_Pagination value, $Res Function(_Pagination) _then) = __$PaginationCopyWithImpl;
@override @useResult
$Res call({
 int page, int limit, int offset, int total, int totalPages, bool hasMore
});




}
/// @nodoc
class __$PaginationCopyWithImpl<$Res>
    implements _$PaginationCopyWith<$Res> {
  __$PaginationCopyWithImpl(this._self, this._then);

  final _Pagination _self;
  final $Res Function(_Pagination) _then;

/// Create a copy of Pagination
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? page = null,Object? limit = null,Object? offset = null,Object? total = null,Object? totalPages = null,Object? hasMore = null,}) {
  return _then(_Pagination(
page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,limit: null == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as int,offset: null == offset ? _self.offset : offset // ignore: cast_nullable_to_non_nullable
as int,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,totalPages: null == totalPages ? _self.totalPages : totalPages // ignore: cast_nullable_to_non_nullable
as int,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$TranslationMeta {

 String get contentLanguage; bool get isTranslatedInResponse; List<String> get translatableLanguages; String get note;
/// Create a copy of TranslationMeta
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TranslationMetaCopyWith<TranslationMeta> get copyWith => _$TranslationMetaCopyWithImpl<TranslationMeta>(this as TranslationMeta, _$identity);

  /// Serializes this TranslationMeta to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TranslationMeta&&(identical(other.contentLanguage, contentLanguage) || other.contentLanguage == contentLanguage)&&(identical(other.isTranslatedInResponse, isTranslatedInResponse) || other.isTranslatedInResponse == isTranslatedInResponse)&&const DeepCollectionEquality().equals(other.translatableLanguages, translatableLanguages)&&(identical(other.note, note) || other.note == note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,contentLanguage,isTranslatedInResponse,const DeepCollectionEquality().hash(translatableLanguages),note);

@override
String toString() {
  return 'TranslationMeta(contentLanguage: $contentLanguage, isTranslatedInResponse: $isTranslatedInResponse, translatableLanguages: $translatableLanguages, note: $note)';
}


}

/// @nodoc
abstract mixin class $TranslationMetaCopyWith<$Res>  {
  factory $TranslationMetaCopyWith(TranslationMeta value, $Res Function(TranslationMeta) _then) = _$TranslationMetaCopyWithImpl;
@useResult
$Res call({
 String contentLanguage, bool isTranslatedInResponse, List<String> translatableLanguages, String note
});




}
/// @nodoc
class _$TranslationMetaCopyWithImpl<$Res>
    implements $TranslationMetaCopyWith<$Res> {
  _$TranslationMetaCopyWithImpl(this._self, this._then);

  final TranslationMeta _self;
  final $Res Function(TranslationMeta) _then;

/// Create a copy of TranslationMeta
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? contentLanguage = null,Object? isTranslatedInResponse = null,Object? translatableLanguages = null,Object? note = null,}) {
  return _then(_self.copyWith(
contentLanguage: null == contentLanguage ? _self.contentLanguage : contentLanguage // ignore: cast_nullable_to_non_nullable
as String,isTranslatedInResponse: null == isTranslatedInResponse ? _self.isTranslatedInResponse : isTranslatedInResponse // ignore: cast_nullable_to_non_nullable
as bool,translatableLanguages: null == translatableLanguages ? _self.translatableLanguages : translatableLanguages // ignore: cast_nullable_to_non_nullable
as List<String>,note: null == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [TranslationMeta].
extension TranslationMetaPatterns on TranslationMeta {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TranslationMeta value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TranslationMeta() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TranslationMeta value)  $default,){
final _that = this;
switch (_that) {
case _TranslationMeta():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TranslationMeta value)?  $default,){
final _that = this;
switch (_that) {
case _TranslationMeta() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String contentLanguage,  bool isTranslatedInResponse,  List<String> translatableLanguages,  String note)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TranslationMeta() when $default != null:
return $default(_that.contentLanguage,_that.isTranslatedInResponse,_that.translatableLanguages,_that.note);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String contentLanguage,  bool isTranslatedInResponse,  List<String> translatableLanguages,  String note)  $default,) {final _that = this;
switch (_that) {
case _TranslationMeta():
return $default(_that.contentLanguage,_that.isTranslatedInResponse,_that.translatableLanguages,_that.note);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String contentLanguage,  bool isTranslatedInResponse,  List<String> translatableLanguages,  String note)?  $default,) {final _that = this;
switch (_that) {
case _TranslationMeta() when $default != null:
return $default(_that.contentLanguage,_that.isTranslatedInResponse,_that.translatableLanguages,_that.note);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TranslationMeta implements TranslationMeta {
  const _TranslationMeta({required this.contentLanguage, required this.isTranslatedInResponse, required final  List<String> translatableLanguages, required this.note}): _translatableLanguages = translatableLanguages;
  factory _TranslationMeta.fromJson(Map<String, dynamic> json) => _$TranslationMetaFromJson(json);

@override final  String contentLanguage;
@override final  bool isTranslatedInResponse;
 final  List<String> _translatableLanguages;
@override List<String> get translatableLanguages {
  if (_translatableLanguages is EqualUnmodifiableListView) return _translatableLanguages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_translatableLanguages);
}

@override final  String note;

/// Create a copy of TranslationMeta
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TranslationMetaCopyWith<_TranslationMeta> get copyWith => __$TranslationMetaCopyWithImpl<_TranslationMeta>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TranslationMetaToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TranslationMeta&&(identical(other.contentLanguage, contentLanguage) || other.contentLanguage == contentLanguage)&&(identical(other.isTranslatedInResponse, isTranslatedInResponse) || other.isTranslatedInResponse == isTranslatedInResponse)&&const DeepCollectionEquality().equals(other._translatableLanguages, _translatableLanguages)&&(identical(other.note, note) || other.note == note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,contentLanguage,isTranslatedInResponse,const DeepCollectionEquality().hash(_translatableLanguages),note);

@override
String toString() {
  return 'TranslationMeta(contentLanguage: $contentLanguage, isTranslatedInResponse: $isTranslatedInResponse, translatableLanguages: $translatableLanguages, note: $note)';
}


}

/// @nodoc
abstract mixin class _$TranslationMetaCopyWith<$Res> implements $TranslationMetaCopyWith<$Res> {
  factory _$TranslationMetaCopyWith(_TranslationMeta value, $Res Function(_TranslationMeta) _then) = __$TranslationMetaCopyWithImpl;
@override @useResult
$Res call({
 String contentLanguage, bool isTranslatedInResponse, List<String> translatableLanguages, String note
});




}
/// @nodoc
class __$TranslationMetaCopyWithImpl<$Res>
    implements _$TranslationMetaCopyWith<$Res> {
  __$TranslationMetaCopyWithImpl(this._self, this._then);

  final _TranslationMeta _self;
  final $Res Function(_TranslationMeta) _then;

/// Create a copy of TranslationMeta
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? contentLanguage = null,Object? isTranslatedInResponse = null,Object? translatableLanguages = null,Object? note = null,}) {
  return _then(_TranslationMeta(
contentLanguage: null == contentLanguage ? _self.contentLanguage : contentLanguage // ignore: cast_nullable_to_non_nullable
as String,isTranslatedInResponse: null == isTranslatedInResponse ? _self.isTranslatedInResponse : isTranslatedInResponse // ignore: cast_nullable_to_non_nullable
as bool,translatableLanguages: null == translatableLanguages ? _self._translatableLanguages : translatableLanguages // ignore: cast_nullable_to_non_nullable
as List<String>,note: null == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$CacheMeta {

 bool get hit; int get ttlSeconds;
/// Create a copy of CacheMeta
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CacheMetaCopyWith<CacheMeta> get copyWith => _$CacheMetaCopyWithImpl<CacheMeta>(this as CacheMeta, _$identity);

  /// Serializes this CacheMeta to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CacheMeta&&(identical(other.hit, hit) || other.hit == hit)&&(identical(other.ttlSeconds, ttlSeconds) || other.ttlSeconds == ttlSeconds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,hit,ttlSeconds);

@override
String toString() {
  return 'CacheMeta(hit: $hit, ttlSeconds: $ttlSeconds)';
}


}

/// @nodoc
abstract mixin class $CacheMetaCopyWith<$Res>  {
  factory $CacheMetaCopyWith(CacheMeta value, $Res Function(CacheMeta) _then) = _$CacheMetaCopyWithImpl;
@useResult
$Res call({
 bool hit, int ttlSeconds
});




}
/// @nodoc
class _$CacheMetaCopyWithImpl<$Res>
    implements $CacheMetaCopyWith<$Res> {
  _$CacheMetaCopyWithImpl(this._self, this._then);

  final CacheMeta _self;
  final $Res Function(CacheMeta) _then;

/// Create a copy of CacheMeta
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? hit = null,Object? ttlSeconds = null,}) {
  return _then(_self.copyWith(
hit: null == hit ? _self.hit : hit // ignore: cast_nullable_to_non_nullable
as bool,ttlSeconds: null == ttlSeconds ? _self.ttlSeconds : ttlSeconds // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [CacheMeta].
extension CacheMetaPatterns on CacheMeta {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CacheMeta value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CacheMeta() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CacheMeta value)  $default,){
final _that = this;
switch (_that) {
case _CacheMeta():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CacheMeta value)?  $default,){
final _that = this;
switch (_that) {
case _CacheMeta() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool hit,  int ttlSeconds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CacheMeta() when $default != null:
return $default(_that.hit,_that.ttlSeconds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool hit,  int ttlSeconds)  $default,) {final _that = this;
switch (_that) {
case _CacheMeta():
return $default(_that.hit,_that.ttlSeconds);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool hit,  int ttlSeconds)?  $default,) {final _that = this;
switch (_that) {
case _CacheMeta() when $default != null:
return $default(_that.hit,_that.ttlSeconds);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CacheMeta implements CacheMeta {
  const _CacheMeta({required this.hit, required this.ttlSeconds});
  factory _CacheMeta.fromJson(Map<String, dynamic> json) => _$CacheMetaFromJson(json);

@override final  bool hit;
@override final  int ttlSeconds;

/// Create a copy of CacheMeta
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CacheMetaCopyWith<_CacheMeta> get copyWith => __$CacheMetaCopyWithImpl<_CacheMeta>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CacheMetaToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CacheMeta&&(identical(other.hit, hit) || other.hit == hit)&&(identical(other.ttlSeconds, ttlSeconds) || other.ttlSeconds == ttlSeconds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,hit,ttlSeconds);

@override
String toString() {
  return 'CacheMeta(hit: $hit, ttlSeconds: $ttlSeconds)';
}


}

/// @nodoc
abstract mixin class _$CacheMetaCopyWith<$Res> implements $CacheMetaCopyWith<$Res> {
  factory _$CacheMetaCopyWith(_CacheMeta value, $Res Function(_CacheMeta) _then) = __$CacheMetaCopyWithImpl;
@override @useResult
$Res call({
 bool hit, int ttlSeconds
});




}
/// @nodoc
class __$CacheMetaCopyWithImpl<$Res>
    implements _$CacheMetaCopyWith<$Res> {
  __$CacheMetaCopyWithImpl(this._self, this._then);

  final _CacheMeta _self;
  final $Res Function(_CacheMeta) _then;

/// Create a copy of CacheMeta
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? hit = null,Object? ttlSeconds = null,}) {
  return _then(_CacheMeta(
hit: null == hit ? _self.hit : hit // ignore: cast_nullable_to_non_nullable
as bool,ttlSeconds: null == ttlSeconds ? _self.ttlSeconds : ttlSeconds // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
