// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'friend_details_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$FriendDetailsResponse {

 bool get success; String get message; FriendDetailsData get data;
/// Create a copy of FriendDetailsResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FriendDetailsResponseCopyWith<FriendDetailsResponse> get copyWith => _$FriendDetailsResponseCopyWithImpl<FriendDetailsResponse>(this as FriendDetailsResponse, _$identity);

  /// Serializes this FriendDetailsResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FriendDetailsResponse&&(identical(other.success, success) || other.success == success)&&(identical(other.message, message) || other.message == message)&&(identical(other.data, data) || other.data == data));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,success,message,data);

@override
String toString() {
  return 'FriendDetailsResponse(success: $success, message: $message, data: $data)';
}


}

/// @nodoc
abstract mixin class $FriendDetailsResponseCopyWith<$Res>  {
  factory $FriendDetailsResponseCopyWith(FriendDetailsResponse value, $Res Function(FriendDetailsResponse) _then) = _$FriendDetailsResponseCopyWithImpl;
@useResult
$Res call({
 bool success, String message, FriendDetailsData data
});


$FriendDetailsDataCopyWith<$Res> get data;

}
/// @nodoc
class _$FriendDetailsResponseCopyWithImpl<$Res>
    implements $FriendDetailsResponseCopyWith<$Res> {
  _$FriendDetailsResponseCopyWithImpl(this._self, this._then);

  final FriendDetailsResponse _self;
  final $Res Function(FriendDetailsResponse) _then;

/// Create a copy of FriendDetailsResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? success = null,Object? message = null,Object? data = null,}) {
  return _then(_self.copyWith(
success: null == success ? _self.success : success // ignore: cast_nullable_to_non_nullable
as bool,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,data: null == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as FriendDetailsData,
  ));
}
/// Create a copy of FriendDetailsResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FriendDetailsDataCopyWith<$Res> get data {
  
  return $FriendDetailsDataCopyWith<$Res>(_self.data, (value) {
    return _then(_self.copyWith(data: value));
  });
}
}


/// Adds pattern-matching-related methods to [FriendDetailsResponse].
extension FriendDetailsResponsePatterns on FriendDetailsResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FriendDetailsResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FriendDetailsResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FriendDetailsResponse value)  $default,){
final _that = this;
switch (_that) {
case _FriendDetailsResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FriendDetailsResponse value)?  $default,){
final _that = this;
switch (_that) {
case _FriendDetailsResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool success,  String message,  FriendDetailsData data)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FriendDetailsResponse() when $default != null:
return $default(_that.success,_that.message,_that.data);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool success,  String message,  FriendDetailsData data)  $default,) {final _that = this;
switch (_that) {
case _FriendDetailsResponse():
return $default(_that.success,_that.message,_that.data);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool success,  String message,  FriendDetailsData data)?  $default,) {final _that = this;
switch (_that) {
case _FriendDetailsResponse() when $default != null:
return $default(_that.success,_that.message,_that.data);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FriendDetailsResponse implements FriendDetailsResponse {
  const _FriendDetailsResponse({required this.success, required this.message, required this.data});
  factory _FriendDetailsResponse.fromJson(Map<String, dynamic> json) => _$FriendDetailsResponseFromJson(json);

@override final  bool success;
@override final  String message;
@override final  FriendDetailsData data;

/// Create a copy of FriendDetailsResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FriendDetailsResponseCopyWith<_FriendDetailsResponse> get copyWith => __$FriendDetailsResponseCopyWithImpl<_FriendDetailsResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FriendDetailsResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FriendDetailsResponse&&(identical(other.success, success) || other.success == success)&&(identical(other.message, message) || other.message == message)&&(identical(other.data, data) || other.data == data));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,success,message,data);

@override
String toString() {
  return 'FriendDetailsResponse(success: $success, message: $message, data: $data)';
}


}

/// @nodoc
abstract mixin class _$FriendDetailsResponseCopyWith<$Res> implements $FriendDetailsResponseCopyWith<$Res> {
  factory _$FriendDetailsResponseCopyWith(_FriendDetailsResponse value, $Res Function(_FriendDetailsResponse) _then) = __$FriendDetailsResponseCopyWithImpl;
@override @useResult
$Res call({
 bool success, String message, FriendDetailsData data
});


@override $FriendDetailsDataCopyWith<$Res> get data;

}
/// @nodoc
class __$FriendDetailsResponseCopyWithImpl<$Res>
    implements _$FriendDetailsResponseCopyWith<$Res> {
  __$FriendDetailsResponseCopyWithImpl(this._self, this._then);

  final _FriendDetailsResponse _self;
  final $Res Function(_FriendDetailsResponse) _then;

/// Create a copy of FriendDetailsResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? success = null,Object? message = null,Object? data = null,}) {
  return _then(_FriendDetailsResponse(
success: null == success ? _self.success : success // ignore: cast_nullable_to_non_nullable
as bool,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,data: null == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as FriendDetailsData,
  ));
}

/// Create a copy of FriendDetailsResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FriendDetailsDataCopyWith<$Res> get data {
  
  return $FriendDetailsDataCopyWith<$Res>(_self.data, (value) {
    return _then(_self.copyWith(data: value));
  });
}
}


/// @nodoc
mixin _$FriendDetailsData {

 FriendProfile get profile; FriendsPreview get friendsPreview; GroupsPreview get groupsPreview; TopicsPreview get topicsPreview; FriendDetailsFilters get filters;
/// Create a copy of FriendDetailsData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FriendDetailsDataCopyWith<FriendDetailsData> get copyWith => _$FriendDetailsDataCopyWithImpl<FriendDetailsData>(this as FriendDetailsData, _$identity);

  /// Serializes this FriendDetailsData to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FriendDetailsData&&(identical(other.profile, profile) || other.profile == profile)&&(identical(other.friendsPreview, friendsPreview) || other.friendsPreview == friendsPreview)&&(identical(other.groupsPreview, groupsPreview) || other.groupsPreview == groupsPreview)&&(identical(other.topicsPreview, topicsPreview) || other.topicsPreview == topicsPreview)&&(identical(other.filters, filters) || other.filters == filters));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,profile,friendsPreview,groupsPreview,topicsPreview,filters);

@override
String toString() {
  return 'FriendDetailsData(profile: $profile, friendsPreview: $friendsPreview, groupsPreview: $groupsPreview, topicsPreview: $topicsPreview, filters: $filters)';
}


}

/// @nodoc
abstract mixin class $FriendDetailsDataCopyWith<$Res>  {
  factory $FriendDetailsDataCopyWith(FriendDetailsData value, $Res Function(FriendDetailsData) _then) = _$FriendDetailsDataCopyWithImpl;
@useResult
$Res call({
 FriendProfile profile, FriendsPreview friendsPreview, GroupsPreview groupsPreview, TopicsPreview topicsPreview, FriendDetailsFilters filters
});


$FriendProfileCopyWith<$Res> get profile;$FriendsPreviewCopyWith<$Res> get friendsPreview;$GroupsPreviewCopyWith<$Res> get groupsPreview;$TopicsPreviewCopyWith<$Res> get topicsPreview;$FriendDetailsFiltersCopyWith<$Res> get filters;

}
/// @nodoc
class _$FriendDetailsDataCopyWithImpl<$Res>
    implements $FriendDetailsDataCopyWith<$Res> {
  _$FriendDetailsDataCopyWithImpl(this._self, this._then);

  final FriendDetailsData _self;
  final $Res Function(FriendDetailsData) _then;

/// Create a copy of FriendDetailsData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? profile = null,Object? friendsPreview = null,Object? groupsPreview = null,Object? topicsPreview = null,Object? filters = null,}) {
  return _then(_self.copyWith(
profile: null == profile ? _self.profile : profile // ignore: cast_nullable_to_non_nullable
as FriendProfile,friendsPreview: null == friendsPreview ? _self.friendsPreview : friendsPreview // ignore: cast_nullable_to_non_nullable
as FriendsPreview,groupsPreview: null == groupsPreview ? _self.groupsPreview : groupsPreview // ignore: cast_nullable_to_non_nullable
as GroupsPreview,topicsPreview: null == topicsPreview ? _self.topicsPreview : topicsPreview // ignore: cast_nullable_to_non_nullable
as TopicsPreview,filters: null == filters ? _self.filters : filters // ignore: cast_nullable_to_non_nullable
as FriendDetailsFilters,
  ));
}
/// Create a copy of FriendDetailsData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FriendProfileCopyWith<$Res> get profile {
  
  return $FriendProfileCopyWith<$Res>(_self.profile, (value) {
    return _then(_self.copyWith(profile: value));
  });
}/// Create a copy of FriendDetailsData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FriendsPreviewCopyWith<$Res> get friendsPreview {
  
  return $FriendsPreviewCopyWith<$Res>(_self.friendsPreview, (value) {
    return _then(_self.copyWith(friendsPreview: value));
  });
}/// Create a copy of FriendDetailsData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GroupsPreviewCopyWith<$Res> get groupsPreview {
  
  return $GroupsPreviewCopyWith<$Res>(_self.groupsPreview, (value) {
    return _then(_self.copyWith(groupsPreview: value));
  });
}/// Create a copy of FriendDetailsData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TopicsPreviewCopyWith<$Res> get topicsPreview {
  
  return $TopicsPreviewCopyWith<$Res>(_self.topicsPreview, (value) {
    return _then(_self.copyWith(topicsPreview: value));
  });
}/// Create a copy of FriendDetailsData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FriendDetailsFiltersCopyWith<$Res> get filters {
  
  return $FriendDetailsFiltersCopyWith<$Res>(_self.filters, (value) {
    return _then(_self.copyWith(filters: value));
  });
}
}


/// Adds pattern-matching-related methods to [FriendDetailsData].
extension FriendDetailsDataPatterns on FriendDetailsData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FriendDetailsData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FriendDetailsData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FriendDetailsData value)  $default,){
final _that = this;
switch (_that) {
case _FriendDetailsData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FriendDetailsData value)?  $default,){
final _that = this;
switch (_that) {
case _FriendDetailsData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( FriendProfile profile,  FriendsPreview friendsPreview,  GroupsPreview groupsPreview,  TopicsPreview topicsPreview,  FriendDetailsFilters filters)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FriendDetailsData() when $default != null:
return $default(_that.profile,_that.friendsPreview,_that.groupsPreview,_that.topicsPreview,_that.filters);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( FriendProfile profile,  FriendsPreview friendsPreview,  GroupsPreview groupsPreview,  TopicsPreview topicsPreview,  FriendDetailsFilters filters)  $default,) {final _that = this;
switch (_that) {
case _FriendDetailsData():
return $default(_that.profile,_that.friendsPreview,_that.groupsPreview,_that.topicsPreview,_that.filters);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( FriendProfile profile,  FriendsPreview friendsPreview,  GroupsPreview groupsPreview,  TopicsPreview topicsPreview,  FriendDetailsFilters filters)?  $default,) {final _that = this;
switch (_that) {
case _FriendDetailsData() when $default != null:
return $default(_that.profile,_that.friendsPreview,_that.groupsPreview,_that.topicsPreview,_that.filters);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FriendDetailsData implements FriendDetailsData {
  const _FriendDetailsData({required this.profile, required this.friendsPreview, required this.groupsPreview, required this.topicsPreview, required this.filters});
  factory _FriendDetailsData.fromJson(Map<String, dynamic> json) => _$FriendDetailsDataFromJson(json);

@override final  FriendProfile profile;
@override final  FriendsPreview friendsPreview;
@override final  GroupsPreview groupsPreview;
@override final  TopicsPreview topicsPreview;
@override final  FriendDetailsFilters filters;

/// Create a copy of FriendDetailsData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FriendDetailsDataCopyWith<_FriendDetailsData> get copyWith => __$FriendDetailsDataCopyWithImpl<_FriendDetailsData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FriendDetailsDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FriendDetailsData&&(identical(other.profile, profile) || other.profile == profile)&&(identical(other.friendsPreview, friendsPreview) || other.friendsPreview == friendsPreview)&&(identical(other.groupsPreview, groupsPreview) || other.groupsPreview == groupsPreview)&&(identical(other.topicsPreview, topicsPreview) || other.topicsPreview == topicsPreview)&&(identical(other.filters, filters) || other.filters == filters));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,profile,friendsPreview,groupsPreview,topicsPreview,filters);

@override
String toString() {
  return 'FriendDetailsData(profile: $profile, friendsPreview: $friendsPreview, groupsPreview: $groupsPreview, topicsPreview: $topicsPreview, filters: $filters)';
}


}

/// @nodoc
abstract mixin class _$FriendDetailsDataCopyWith<$Res> implements $FriendDetailsDataCopyWith<$Res> {
  factory _$FriendDetailsDataCopyWith(_FriendDetailsData value, $Res Function(_FriendDetailsData) _then) = __$FriendDetailsDataCopyWithImpl;
@override @useResult
$Res call({
 FriendProfile profile, FriendsPreview friendsPreview, GroupsPreview groupsPreview, TopicsPreview topicsPreview, FriendDetailsFilters filters
});


@override $FriendProfileCopyWith<$Res> get profile;@override $FriendsPreviewCopyWith<$Res> get friendsPreview;@override $GroupsPreviewCopyWith<$Res> get groupsPreview;@override $TopicsPreviewCopyWith<$Res> get topicsPreview;@override $FriendDetailsFiltersCopyWith<$Res> get filters;

}
/// @nodoc
class __$FriendDetailsDataCopyWithImpl<$Res>
    implements _$FriendDetailsDataCopyWith<$Res> {
  __$FriendDetailsDataCopyWithImpl(this._self, this._then);

  final _FriendDetailsData _self;
  final $Res Function(_FriendDetailsData) _then;

/// Create a copy of FriendDetailsData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? profile = null,Object? friendsPreview = null,Object? groupsPreview = null,Object? topicsPreview = null,Object? filters = null,}) {
  return _then(_FriendDetailsData(
profile: null == profile ? _self.profile : profile // ignore: cast_nullable_to_non_nullable
as FriendProfile,friendsPreview: null == friendsPreview ? _self.friendsPreview : friendsPreview // ignore: cast_nullable_to_non_nullable
as FriendsPreview,groupsPreview: null == groupsPreview ? _self.groupsPreview : groupsPreview // ignore: cast_nullable_to_non_nullable
as GroupsPreview,topicsPreview: null == topicsPreview ? _self.topicsPreview : topicsPreview // ignore: cast_nullable_to_non_nullable
as TopicsPreview,filters: null == filters ? _self.filters : filters // ignore: cast_nullable_to_non_nullable
as FriendDetailsFilters,
  ));
}

/// Create a copy of FriendDetailsData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FriendProfileCopyWith<$Res> get profile {
  
  return $FriendProfileCopyWith<$Res>(_self.profile, (value) {
    return _then(_self.copyWith(profile: value));
  });
}/// Create a copy of FriendDetailsData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FriendsPreviewCopyWith<$Res> get friendsPreview {
  
  return $FriendsPreviewCopyWith<$Res>(_self.friendsPreview, (value) {
    return _then(_self.copyWith(friendsPreview: value));
  });
}/// Create a copy of FriendDetailsData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GroupsPreviewCopyWith<$Res> get groupsPreview {
  
  return $GroupsPreviewCopyWith<$Res>(_self.groupsPreview, (value) {
    return _then(_self.copyWith(groupsPreview: value));
  });
}/// Create a copy of FriendDetailsData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TopicsPreviewCopyWith<$Res> get topicsPreview {
  
  return $TopicsPreviewCopyWith<$Res>(_self.topicsPreview, (value) {
    return _then(_self.copyWith(topicsPreview: value));
  });
}/// Create a copy of FriendDetailsData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FriendDetailsFiltersCopyWith<$Res> get filters {
  
  return $FriendDetailsFiltersCopyWith<$Res>(_self.filters, (value) {
    return _then(_self.copyWith(filters: value));
  });
}
}


/// @nodoc
mixin _$FriendProfile {

 String get userId; String? get firstName; String? get lastName; String? get displayName; String? get username; String? get avatarUrl; String? get phone; String? get pendingPhone; bool get phoneVerified; String? get email;@JsonKey(fromJson: _socialAccountsFromJson, toJson: _socialAccountsToJson) FriendSocialAccounts? get socialAccounts; List<String> get interests; String? get country; String? get preferredLanguage; int? get dailyReadingGoal; bool get isPrivate; bool get isFriend;
/// Create a copy of FriendProfile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FriendProfileCopyWith<FriendProfile> get copyWith => _$FriendProfileCopyWithImpl<FriendProfile>(this as FriendProfile, _$identity);

  /// Serializes this FriendProfile to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FriendProfile&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.username, username) || other.username == username)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.pendingPhone, pendingPhone) || other.pendingPhone == pendingPhone)&&(identical(other.phoneVerified, phoneVerified) || other.phoneVerified == phoneVerified)&&(identical(other.email, email) || other.email == email)&&(identical(other.socialAccounts, socialAccounts) || other.socialAccounts == socialAccounts)&&const DeepCollectionEquality().equals(other.interests, interests)&&(identical(other.country, country) || other.country == country)&&(identical(other.preferredLanguage, preferredLanguage) || other.preferredLanguage == preferredLanguage)&&(identical(other.dailyReadingGoal, dailyReadingGoal) || other.dailyReadingGoal == dailyReadingGoal)&&(identical(other.isPrivate, isPrivate) || other.isPrivate == isPrivate)&&(identical(other.isFriend, isFriend) || other.isFriend == isFriend));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,firstName,lastName,displayName,username,avatarUrl,phone,pendingPhone,phoneVerified,email,socialAccounts,const DeepCollectionEquality().hash(interests),country,preferredLanguage,dailyReadingGoal,isPrivate,isFriend);

@override
String toString() {
  return 'FriendProfile(userId: $userId, firstName: $firstName, lastName: $lastName, displayName: $displayName, username: $username, avatarUrl: $avatarUrl, phone: $phone, pendingPhone: $pendingPhone, phoneVerified: $phoneVerified, email: $email, socialAccounts: $socialAccounts, interests: $interests, country: $country, preferredLanguage: $preferredLanguage, dailyReadingGoal: $dailyReadingGoal, isPrivate: $isPrivate, isFriend: $isFriend)';
}


}

/// @nodoc
abstract mixin class $FriendProfileCopyWith<$Res>  {
  factory $FriendProfileCopyWith(FriendProfile value, $Res Function(FriendProfile) _then) = _$FriendProfileCopyWithImpl;
@useResult
$Res call({
 String userId, String? firstName, String? lastName, String? displayName, String? username, String? avatarUrl, String? phone, String? pendingPhone, bool phoneVerified, String? email,@JsonKey(fromJson: _socialAccountsFromJson, toJson: _socialAccountsToJson) FriendSocialAccounts? socialAccounts, List<String> interests, String? country, String? preferredLanguage, int? dailyReadingGoal, bool isPrivate, bool isFriend
});


$FriendSocialAccountsCopyWith<$Res>? get socialAccounts;

}
/// @nodoc
class _$FriendProfileCopyWithImpl<$Res>
    implements $FriendProfileCopyWith<$Res> {
  _$FriendProfileCopyWithImpl(this._self, this._then);

  final FriendProfile _self;
  final $Res Function(FriendProfile) _then;

/// Create a copy of FriendProfile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userId = null,Object? firstName = freezed,Object? lastName = freezed,Object? displayName = freezed,Object? username = freezed,Object? avatarUrl = freezed,Object? phone = freezed,Object? pendingPhone = freezed,Object? phoneVerified = null,Object? email = freezed,Object? socialAccounts = freezed,Object? interests = null,Object? country = freezed,Object? preferredLanguage = freezed,Object? dailyReadingGoal = freezed,Object? isPrivate = null,Object? isFriend = null,}) {
  return _then(_self.copyWith(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,firstName: freezed == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String?,lastName: freezed == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String?,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,username: freezed == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String?,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,pendingPhone: freezed == pendingPhone ? _self.pendingPhone : pendingPhone // ignore: cast_nullable_to_non_nullable
as String?,phoneVerified: null == phoneVerified ? _self.phoneVerified : phoneVerified // ignore: cast_nullable_to_non_nullable
as bool,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,socialAccounts: freezed == socialAccounts ? _self.socialAccounts : socialAccounts // ignore: cast_nullable_to_non_nullable
as FriendSocialAccounts?,interests: null == interests ? _self.interests : interests // ignore: cast_nullable_to_non_nullable
as List<String>,country: freezed == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String?,preferredLanguage: freezed == preferredLanguage ? _self.preferredLanguage : preferredLanguage // ignore: cast_nullable_to_non_nullable
as String?,dailyReadingGoal: freezed == dailyReadingGoal ? _self.dailyReadingGoal : dailyReadingGoal // ignore: cast_nullable_to_non_nullable
as int?,isPrivate: null == isPrivate ? _self.isPrivate : isPrivate // ignore: cast_nullable_to_non_nullable
as bool,isFriend: null == isFriend ? _self.isFriend : isFriend // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of FriendProfile
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FriendSocialAccountsCopyWith<$Res>? get socialAccounts {
    if (_self.socialAccounts == null) {
    return null;
  }

  return $FriendSocialAccountsCopyWith<$Res>(_self.socialAccounts!, (value) {
    return _then(_self.copyWith(socialAccounts: value));
  });
}
}


/// Adds pattern-matching-related methods to [FriendProfile].
extension FriendProfilePatterns on FriendProfile {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FriendProfile value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FriendProfile() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FriendProfile value)  $default,){
final _that = this;
switch (_that) {
case _FriendProfile():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FriendProfile value)?  $default,){
final _that = this;
switch (_that) {
case _FriendProfile() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String userId,  String? firstName,  String? lastName,  String? displayName,  String? username,  String? avatarUrl,  String? phone,  String? pendingPhone,  bool phoneVerified,  String? email, @JsonKey(fromJson: _socialAccountsFromJson, toJson: _socialAccountsToJson)  FriendSocialAccounts? socialAccounts,  List<String> interests,  String? country,  String? preferredLanguage,  int? dailyReadingGoal,  bool isPrivate,  bool isFriend)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FriendProfile() when $default != null:
return $default(_that.userId,_that.firstName,_that.lastName,_that.displayName,_that.username,_that.avatarUrl,_that.phone,_that.pendingPhone,_that.phoneVerified,_that.email,_that.socialAccounts,_that.interests,_that.country,_that.preferredLanguage,_that.dailyReadingGoal,_that.isPrivate,_that.isFriend);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String userId,  String? firstName,  String? lastName,  String? displayName,  String? username,  String? avatarUrl,  String? phone,  String? pendingPhone,  bool phoneVerified,  String? email, @JsonKey(fromJson: _socialAccountsFromJson, toJson: _socialAccountsToJson)  FriendSocialAccounts? socialAccounts,  List<String> interests,  String? country,  String? preferredLanguage,  int? dailyReadingGoal,  bool isPrivate,  bool isFriend)  $default,) {final _that = this;
switch (_that) {
case _FriendProfile():
return $default(_that.userId,_that.firstName,_that.lastName,_that.displayName,_that.username,_that.avatarUrl,_that.phone,_that.pendingPhone,_that.phoneVerified,_that.email,_that.socialAccounts,_that.interests,_that.country,_that.preferredLanguage,_that.dailyReadingGoal,_that.isPrivate,_that.isFriend);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String userId,  String? firstName,  String? lastName,  String? displayName,  String? username,  String? avatarUrl,  String? phone,  String? pendingPhone,  bool phoneVerified,  String? email, @JsonKey(fromJson: _socialAccountsFromJson, toJson: _socialAccountsToJson)  FriendSocialAccounts? socialAccounts,  List<String> interests,  String? country,  String? preferredLanguage,  int? dailyReadingGoal,  bool isPrivate,  bool isFriend)?  $default,) {final _that = this;
switch (_that) {
case _FriendProfile() when $default != null:
return $default(_that.userId,_that.firstName,_that.lastName,_that.displayName,_that.username,_that.avatarUrl,_that.phone,_that.pendingPhone,_that.phoneVerified,_that.email,_that.socialAccounts,_that.interests,_that.country,_that.preferredLanguage,_that.dailyReadingGoal,_that.isPrivate,_that.isFriend);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FriendProfile implements FriendProfile {
  const _FriendProfile({required this.userId, this.firstName, this.lastName, this.displayName, this.username, this.avatarUrl, this.phone, this.pendingPhone, this.phoneVerified = false, this.email, @JsonKey(fromJson: _socialAccountsFromJson, toJson: _socialAccountsToJson) this.socialAccounts, final  List<String> interests = const [], this.country, this.preferredLanguage, this.dailyReadingGoal, this.isPrivate = false, this.isFriend = false}): _interests = interests;
  factory _FriendProfile.fromJson(Map<String, dynamic> json) => _$FriendProfileFromJson(json);

@override final  String userId;
@override final  String? firstName;
@override final  String? lastName;
@override final  String? displayName;
@override final  String? username;
@override final  String? avatarUrl;
@override final  String? phone;
@override final  String? pendingPhone;
@override@JsonKey() final  bool phoneVerified;
@override final  String? email;
@override@JsonKey(fromJson: _socialAccountsFromJson, toJson: _socialAccountsToJson) final  FriendSocialAccounts? socialAccounts;
 final  List<String> _interests;
@override@JsonKey() List<String> get interests {
  if (_interests is EqualUnmodifiableListView) return _interests;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_interests);
}

@override final  String? country;
@override final  String? preferredLanguage;
@override final  int? dailyReadingGoal;
@override@JsonKey() final  bool isPrivate;
@override@JsonKey() final  bool isFriend;

/// Create a copy of FriendProfile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FriendProfileCopyWith<_FriendProfile> get copyWith => __$FriendProfileCopyWithImpl<_FriendProfile>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FriendProfileToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FriendProfile&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.username, username) || other.username == username)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.pendingPhone, pendingPhone) || other.pendingPhone == pendingPhone)&&(identical(other.phoneVerified, phoneVerified) || other.phoneVerified == phoneVerified)&&(identical(other.email, email) || other.email == email)&&(identical(other.socialAccounts, socialAccounts) || other.socialAccounts == socialAccounts)&&const DeepCollectionEquality().equals(other._interests, _interests)&&(identical(other.country, country) || other.country == country)&&(identical(other.preferredLanguage, preferredLanguage) || other.preferredLanguage == preferredLanguage)&&(identical(other.dailyReadingGoal, dailyReadingGoal) || other.dailyReadingGoal == dailyReadingGoal)&&(identical(other.isPrivate, isPrivate) || other.isPrivate == isPrivate)&&(identical(other.isFriend, isFriend) || other.isFriend == isFriend));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,firstName,lastName,displayName,username,avatarUrl,phone,pendingPhone,phoneVerified,email,socialAccounts,const DeepCollectionEquality().hash(_interests),country,preferredLanguage,dailyReadingGoal,isPrivate,isFriend);

@override
String toString() {
  return 'FriendProfile(userId: $userId, firstName: $firstName, lastName: $lastName, displayName: $displayName, username: $username, avatarUrl: $avatarUrl, phone: $phone, pendingPhone: $pendingPhone, phoneVerified: $phoneVerified, email: $email, socialAccounts: $socialAccounts, interests: $interests, country: $country, preferredLanguage: $preferredLanguage, dailyReadingGoal: $dailyReadingGoal, isPrivate: $isPrivate, isFriend: $isFriend)';
}


}

/// @nodoc
abstract mixin class _$FriendProfileCopyWith<$Res> implements $FriendProfileCopyWith<$Res> {
  factory _$FriendProfileCopyWith(_FriendProfile value, $Res Function(_FriendProfile) _then) = __$FriendProfileCopyWithImpl;
@override @useResult
$Res call({
 String userId, String? firstName, String? lastName, String? displayName, String? username, String? avatarUrl, String? phone, String? pendingPhone, bool phoneVerified, String? email,@JsonKey(fromJson: _socialAccountsFromJson, toJson: _socialAccountsToJson) FriendSocialAccounts? socialAccounts, List<String> interests, String? country, String? preferredLanguage, int? dailyReadingGoal, bool isPrivate, bool isFriend
});


@override $FriendSocialAccountsCopyWith<$Res>? get socialAccounts;

}
/// @nodoc
class __$FriendProfileCopyWithImpl<$Res>
    implements _$FriendProfileCopyWith<$Res> {
  __$FriendProfileCopyWithImpl(this._self, this._then);

  final _FriendProfile _self;
  final $Res Function(_FriendProfile) _then;

/// Create a copy of FriendProfile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userId = null,Object? firstName = freezed,Object? lastName = freezed,Object? displayName = freezed,Object? username = freezed,Object? avatarUrl = freezed,Object? phone = freezed,Object? pendingPhone = freezed,Object? phoneVerified = null,Object? email = freezed,Object? socialAccounts = freezed,Object? interests = null,Object? country = freezed,Object? preferredLanguage = freezed,Object? dailyReadingGoal = freezed,Object? isPrivate = null,Object? isFriend = null,}) {
  return _then(_FriendProfile(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,firstName: freezed == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String?,lastName: freezed == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String?,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,username: freezed == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String?,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,pendingPhone: freezed == pendingPhone ? _self.pendingPhone : pendingPhone // ignore: cast_nullable_to_non_nullable
as String?,phoneVerified: null == phoneVerified ? _self.phoneVerified : phoneVerified // ignore: cast_nullable_to_non_nullable
as bool,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,socialAccounts: freezed == socialAccounts ? _self.socialAccounts : socialAccounts // ignore: cast_nullable_to_non_nullable
as FriendSocialAccounts?,interests: null == interests ? _self._interests : interests // ignore: cast_nullable_to_non_nullable
as List<String>,country: freezed == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String?,preferredLanguage: freezed == preferredLanguage ? _self.preferredLanguage : preferredLanguage // ignore: cast_nullable_to_non_nullable
as String?,dailyReadingGoal: freezed == dailyReadingGoal ? _self.dailyReadingGoal : dailyReadingGoal // ignore: cast_nullable_to_non_nullable
as int?,isPrivate: null == isPrivate ? _self.isPrivate : isPrivate // ignore: cast_nullable_to_non_nullable
as bool,isFriend: null == isFriend ? _self.isFriend : isFriend // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of FriendProfile
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FriendSocialAccountsCopyWith<$Res>? get socialAccounts {
    if (_self.socialAccounts == null) {
    return null;
  }

  return $FriendSocialAccountsCopyWith<$Res>(_self.socialAccounts!, (value) {
    return _then(_self.copyWith(socialAccounts: value));
  });
}
}


/// @nodoc
mixin _$FriendSocialAccounts {

 String get x; String get google; String get instagram;
/// Create a copy of FriendSocialAccounts
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FriendSocialAccountsCopyWith<FriendSocialAccounts> get copyWith => _$FriendSocialAccountsCopyWithImpl<FriendSocialAccounts>(this as FriendSocialAccounts, _$identity);

  /// Serializes this FriendSocialAccounts to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FriendSocialAccounts&&(identical(other.x, x) || other.x == x)&&(identical(other.google, google) || other.google == google)&&(identical(other.instagram, instagram) || other.instagram == instagram));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,x,google,instagram);

@override
String toString() {
  return 'FriendSocialAccounts(x: $x, google: $google, instagram: $instagram)';
}


}

/// @nodoc
abstract mixin class $FriendSocialAccountsCopyWith<$Res>  {
  factory $FriendSocialAccountsCopyWith(FriendSocialAccounts value, $Res Function(FriendSocialAccounts) _then) = _$FriendSocialAccountsCopyWithImpl;
@useResult
$Res call({
 String x, String google, String instagram
});




}
/// @nodoc
class _$FriendSocialAccountsCopyWithImpl<$Res>
    implements $FriendSocialAccountsCopyWith<$Res> {
  _$FriendSocialAccountsCopyWithImpl(this._self, this._then);

  final FriendSocialAccounts _self;
  final $Res Function(FriendSocialAccounts) _then;

/// Create a copy of FriendSocialAccounts
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? x = null,Object? google = null,Object? instagram = null,}) {
  return _then(_self.copyWith(
x: null == x ? _self.x : x // ignore: cast_nullable_to_non_nullable
as String,google: null == google ? _self.google : google // ignore: cast_nullable_to_non_nullable
as String,instagram: null == instagram ? _self.instagram : instagram // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [FriendSocialAccounts].
extension FriendSocialAccountsPatterns on FriendSocialAccounts {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FriendSocialAccounts value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FriendSocialAccounts() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FriendSocialAccounts value)  $default,){
final _that = this;
switch (_that) {
case _FriendSocialAccounts():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FriendSocialAccounts value)?  $default,){
final _that = this;
switch (_that) {
case _FriendSocialAccounts() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String x,  String google,  String instagram)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FriendSocialAccounts() when $default != null:
return $default(_that.x,_that.google,_that.instagram);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String x,  String google,  String instagram)  $default,) {final _that = this;
switch (_that) {
case _FriendSocialAccounts():
return $default(_that.x,_that.google,_that.instagram);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String x,  String google,  String instagram)?  $default,) {final _that = this;
switch (_that) {
case _FriendSocialAccounts() when $default != null:
return $default(_that.x,_that.google,_that.instagram);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FriendSocialAccounts implements FriendSocialAccounts {
  const _FriendSocialAccounts({this.x = '', this.google = '', this.instagram = ''});
  factory _FriendSocialAccounts.fromJson(Map<String, dynamic> json) => _$FriendSocialAccountsFromJson(json);

@override@JsonKey() final  String x;
@override@JsonKey() final  String google;
@override@JsonKey() final  String instagram;

/// Create a copy of FriendSocialAccounts
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FriendSocialAccountsCopyWith<_FriendSocialAccounts> get copyWith => __$FriendSocialAccountsCopyWithImpl<_FriendSocialAccounts>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FriendSocialAccountsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FriendSocialAccounts&&(identical(other.x, x) || other.x == x)&&(identical(other.google, google) || other.google == google)&&(identical(other.instagram, instagram) || other.instagram == instagram));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,x,google,instagram);

@override
String toString() {
  return 'FriendSocialAccounts(x: $x, google: $google, instagram: $instagram)';
}


}

/// @nodoc
abstract mixin class _$FriendSocialAccountsCopyWith<$Res> implements $FriendSocialAccountsCopyWith<$Res> {
  factory _$FriendSocialAccountsCopyWith(_FriendSocialAccounts value, $Res Function(_FriendSocialAccounts) _then) = __$FriendSocialAccountsCopyWithImpl;
@override @useResult
$Res call({
 String x, String google, String instagram
});




}
/// @nodoc
class __$FriendSocialAccountsCopyWithImpl<$Res>
    implements _$FriendSocialAccountsCopyWith<$Res> {
  __$FriendSocialAccountsCopyWithImpl(this._self, this._then);

  final _FriendSocialAccounts _self;
  final $Res Function(_FriendSocialAccounts) _then;

/// Create a copy of FriendSocialAccounts
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? x = null,Object? google = null,Object? instagram = null,}) {
  return _then(_FriendSocialAccounts(
x: null == x ? _self.x : x // ignore: cast_nullable_to_non_nullable
as String,google: null == google ? _self.google : google // ignore: cast_nullable_to_non_nullable
as String,instagram: null == instagram ? _self.instagram : instagram // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$FriendsPreview {

 List<FriendPreviewItem> get items; int get totalCount;
/// Create a copy of FriendsPreview
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FriendsPreviewCopyWith<FriendsPreview> get copyWith => _$FriendsPreviewCopyWithImpl<FriendsPreview>(this as FriendsPreview, _$identity);

  /// Serializes this FriendsPreview to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FriendsPreview&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.totalCount, totalCount) || other.totalCount == totalCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(items),totalCount);

@override
String toString() {
  return 'FriendsPreview(items: $items, totalCount: $totalCount)';
}


}

/// @nodoc
abstract mixin class $FriendsPreviewCopyWith<$Res>  {
  factory $FriendsPreviewCopyWith(FriendsPreview value, $Res Function(FriendsPreview) _then) = _$FriendsPreviewCopyWithImpl;
@useResult
$Res call({
 List<FriendPreviewItem> items, int totalCount
});




}
/// @nodoc
class _$FriendsPreviewCopyWithImpl<$Res>
    implements $FriendsPreviewCopyWith<$Res> {
  _$FriendsPreviewCopyWithImpl(this._self, this._then);

  final FriendsPreview _self;
  final $Res Function(FriendsPreview) _then;

/// Create a copy of FriendsPreview
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = null,Object? totalCount = null,}) {
  return _then(_self.copyWith(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<FriendPreviewItem>,totalCount: null == totalCount ? _self.totalCount : totalCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [FriendsPreview].
extension FriendsPreviewPatterns on FriendsPreview {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FriendsPreview value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FriendsPreview() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FriendsPreview value)  $default,){
final _that = this;
switch (_that) {
case _FriendsPreview():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FriendsPreview value)?  $default,){
final _that = this;
switch (_that) {
case _FriendsPreview() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<FriendPreviewItem> items,  int totalCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FriendsPreview() when $default != null:
return $default(_that.items,_that.totalCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<FriendPreviewItem> items,  int totalCount)  $default,) {final _that = this;
switch (_that) {
case _FriendsPreview():
return $default(_that.items,_that.totalCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<FriendPreviewItem> items,  int totalCount)?  $default,) {final _that = this;
switch (_that) {
case _FriendsPreview() when $default != null:
return $default(_that.items,_that.totalCount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FriendsPreview implements FriendsPreview {
  const _FriendsPreview({final  List<FriendPreviewItem> items = const [], this.totalCount = 0}): _items = items;
  factory _FriendsPreview.fromJson(Map<String, dynamic> json) => _$FriendsPreviewFromJson(json);

 final  List<FriendPreviewItem> _items;
@override@JsonKey() List<FriendPreviewItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override@JsonKey() final  int totalCount;

/// Create a copy of FriendsPreview
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FriendsPreviewCopyWith<_FriendsPreview> get copyWith => __$FriendsPreviewCopyWithImpl<_FriendsPreview>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FriendsPreviewToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FriendsPreview&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.totalCount, totalCount) || other.totalCount == totalCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_items),totalCount);

@override
String toString() {
  return 'FriendsPreview(items: $items, totalCount: $totalCount)';
}


}

/// @nodoc
abstract mixin class _$FriendsPreviewCopyWith<$Res> implements $FriendsPreviewCopyWith<$Res> {
  factory _$FriendsPreviewCopyWith(_FriendsPreview value, $Res Function(_FriendsPreview) _then) = __$FriendsPreviewCopyWithImpl;
@override @useResult
$Res call({
 List<FriendPreviewItem> items, int totalCount
});




}
/// @nodoc
class __$FriendsPreviewCopyWithImpl<$Res>
    implements _$FriendsPreviewCopyWith<$Res> {
  __$FriendsPreviewCopyWithImpl(this._self, this._then);

  final _FriendsPreview _self;
  final $Res Function(_FriendsPreview) _then;

/// Create a copy of FriendsPreview
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = null,Object? totalCount = null,}) {
  return _then(_FriendsPreview(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<FriendPreviewItem>,totalCount: null == totalCount ? _self.totalCount : totalCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$FriendPreviewItem {

 String get id; String? get displayName; String? get username; String? get avatarUrl;
/// Create a copy of FriendPreviewItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FriendPreviewItemCopyWith<FriendPreviewItem> get copyWith => _$FriendPreviewItemCopyWithImpl<FriendPreviewItem>(this as FriendPreviewItem, _$identity);

  /// Serializes this FriendPreviewItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FriendPreviewItem&&(identical(other.id, id) || other.id == id)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.username, username) || other.username == username)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,displayName,username,avatarUrl);

@override
String toString() {
  return 'FriendPreviewItem(id: $id, displayName: $displayName, username: $username, avatarUrl: $avatarUrl)';
}


}

/// @nodoc
abstract mixin class $FriendPreviewItemCopyWith<$Res>  {
  factory $FriendPreviewItemCopyWith(FriendPreviewItem value, $Res Function(FriendPreviewItem) _then) = _$FriendPreviewItemCopyWithImpl;
@useResult
$Res call({
 String id, String? displayName, String? username, String? avatarUrl
});




}
/// @nodoc
class _$FriendPreviewItemCopyWithImpl<$Res>
    implements $FriendPreviewItemCopyWith<$Res> {
  _$FriendPreviewItemCopyWithImpl(this._self, this._then);

  final FriendPreviewItem _self;
  final $Res Function(FriendPreviewItem) _then;

/// Create a copy of FriendPreviewItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? displayName = freezed,Object? username = freezed,Object? avatarUrl = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,username: freezed == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String?,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [FriendPreviewItem].
extension FriendPreviewItemPatterns on FriendPreviewItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FriendPreviewItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FriendPreviewItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FriendPreviewItem value)  $default,){
final _that = this;
switch (_that) {
case _FriendPreviewItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FriendPreviewItem value)?  $default,){
final _that = this;
switch (_that) {
case _FriendPreviewItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? displayName,  String? username,  String? avatarUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FriendPreviewItem() when $default != null:
return $default(_that.id,_that.displayName,_that.username,_that.avatarUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? displayName,  String? username,  String? avatarUrl)  $default,) {final _that = this;
switch (_that) {
case _FriendPreviewItem():
return $default(_that.id,_that.displayName,_that.username,_that.avatarUrl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? displayName,  String? username,  String? avatarUrl)?  $default,) {final _that = this;
switch (_that) {
case _FriendPreviewItem() when $default != null:
return $default(_that.id,_that.displayName,_that.username,_that.avatarUrl);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FriendPreviewItem implements FriendPreviewItem {
  const _FriendPreviewItem({required this.id, this.displayName, this.username, this.avatarUrl});
  factory _FriendPreviewItem.fromJson(Map<String, dynamic> json) => _$FriendPreviewItemFromJson(json);

@override final  String id;
@override final  String? displayName;
@override final  String? username;
@override final  String? avatarUrl;

/// Create a copy of FriendPreviewItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FriendPreviewItemCopyWith<_FriendPreviewItem> get copyWith => __$FriendPreviewItemCopyWithImpl<_FriendPreviewItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FriendPreviewItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FriendPreviewItem&&(identical(other.id, id) || other.id == id)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.username, username) || other.username == username)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,displayName,username,avatarUrl);

@override
String toString() {
  return 'FriendPreviewItem(id: $id, displayName: $displayName, username: $username, avatarUrl: $avatarUrl)';
}


}

/// @nodoc
abstract mixin class _$FriendPreviewItemCopyWith<$Res> implements $FriendPreviewItemCopyWith<$Res> {
  factory _$FriendPreviewItemCopyWith(_FriendPreviewItem value, $Res Function(_FriendPreviewItem) _then) = __$FriendPreviewItemCopyWithImpl;
@override @useResult
$Res call({
 String id, String? displayName, String? username, String? avatarUrl
});




}
/// @nodoc
class __$FriendPreviewItemCopyWithImpl<$Res>
    implements _$FriendPreviewItemCopyWith<$Res> {
  __$FriendPreviewItemCopyWithImpl(this._self, this._then);

  final _FriendPreviewItem _self;
  final $Res Function(_FriendPreviewItem) _then;

/// Create a copy of FriendPreviewItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? displayName = freezed,Object? username = freezed,Object? avatarUrl = freezed,}) {
  return _then(_FriendPreviewItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,username: freezed == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String?,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$GroupsPreview {

 List<GroupPreviewItem> get items; int get totalCount;
/// Create a copy of GroupsPreview
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GroupsPreviewCopyWith<GroupsPreview> get copyWith => _$GroupsPreviewCopyWithImpl<GroupsPreview>(this as GroupsPreview, _$identity);

  /// Serializes this GroupsPreview to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GroupsPreview&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.totalCount, totalCount) || other.totalCount == totalCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(items),totalCount);

@override
String toString() {
  return 'GroupsPreview(items: $items, totalCount: $totalCount)';
}


}

/// @nodoc
abstract mixin class $GroupsPreviewCopyWith<$Res>  {
  factory $GroupsPreviewCopyWith(GroupsPreview value, $Res Function(GroupsPreview) _then) = _$GroupsPreviewCopyWithImpl;
@useResult
$Res call({
 List<GroupPreviewItem> items, int totalCount
});




}
/// @nodoc
class _$GroupsPreviewCopyWithImpl<$Res>
    implements $GroupsPreviewCopyWith<$Res> {
  _$GroupsPreviewCopyWithImpl(this._self, this._then);

  final GroupsPreview _self;
  final $Res Function(GroupsPreview) _then;

/// Create a copy of GroupsPreview
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = null,Object? totalCount = null,}) {
  return _then(_self.copyWith(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<GroupPreviewItem>,totalCount: null == totalCount ? _self.totalCount : totalCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [GroupsPreview].
extension GroupsPreviewPatterns on GroupsPreview {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GroupsPreview value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GroupsPreview() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GroupsPreview value)  $default,){
final _that = this;
switch (_that) {
case _GroupsPreview():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GroupsPreview value)?  $default,){
final _that = this;
switch (_that) {
case _GroupsPreview() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<GroupPreviewItem> items,  int totalCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GroupsPreview() when $default != null:
return $default(_that.items,_that.totalCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<GroupPreviewItem> items,  int totalCount)  $default,) {final _that = this;
switch (_that) {
case _GroupsPreview():
return $default(_that.items,_that.totalCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<GroupPreviewItem> items,  int totalCount)?  $default,) {final _that = this;
switch (_that) {
case _GroupsPreview() when $default != null:
return $default(_that.items,_that.totalCount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GroupsPreview implements GroupsPreview {
  const _GroupsPreview({final  List<GroupPreviewItem> items = const [], this.totalCount = 0}): _items = items;
  factory _GroupsPreview.fromJson(Map<String, dynamic> json) => _$GroupsPreviewFromJson(json);

 final  List<GroupPreviewItem> _items;
@override@JsonKey() List<GroupPreviewItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override@JsonKey() final  int totalCount;

/// Create a copy of GroupsPreview
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GroupsPreviewCopyWith<_GroupsPreview> get copyWith => __$GroupsPreviewCopyWithImpl<_GroupsPreview>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GroupsPreviewToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GroupsPreview&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.totalCount, totalCount) || other.totalCount == totalCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_items),totalCount);

@override
String toString() {
  return 'GroupsPreview(items: $items, totalCount: $totalCount)';
}


}

/// @nodoc
abstract mixin class _$GroupsPreviewCopyWith<$Res> implements $GroupsPreviewCopyWith<$Res> {
  factory _$GroupsPreviewCopyWith(_GroupsPreview value, $Res Function(_GroupsPreview) _then) = __$GroupsPreviewCopyWithImpl;
@override @useResult
$Res call({
 List<GroupPreviewItem> items, int totalCount
});




}
/// @nodoc
class __$GroupsPreviewCopyWithImpl<$Res>
    implements _$GroupsPreviewCopyWith<$Res> {
  __$GroupsPreviewCopyWithImpl(this._self, this._then);

  final _GroupsPreview _self;
  final $Res Function(_GroupsPreview) _then;

/// Create a copy of GroupsPreview
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = null,Object? totalCount = null,}) {
  return _then(_GroupsPreview(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<GroupPreviewItem>,totalCount: null == totalCount ? _self.totalCount : totalCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$GroupPreviewItem {

 String get id; String? get title; String? get thumbnailUrl; String? get type; int get memberCount;
/// Create a copy of GroupPreviewItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GroupPreviewItemCopyWith<GroupPreviewItem> get copyWith => _$GroupPreviewItemCopyWithImpl<GroupPreviewItem>(this as GroupPreviewItem, _$identity);

  /// Serializes this GroupPreviewItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GroupPreviewItem&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.thumbnailUrl, thumbnailUrl) || other.thumbnailUrl == thumbnailUrl)&&(identical(other.type, type) || other.type == type)&&(identical(other.memberCount, memberCount) || other.memberCount == memberCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,thumbnailUrl,type,memberCount);

@override
String toString() {
  return 'GroupPreviewItem(id: $id, title: $title, thumbnailUrl: $thumbnailUrl, type: $type, memberCount: $memberCount)';
}


}

/// @nodoc
abstract mixin class $GroupPreviewItemCopyWith<$Res>  {
  factory $GroupPreviewItemCopyWith(GroupPreviewItem value, $Res Function(GroupPreviewItem) _then) = _$GroupPreviewItemCopyWithImpl;
@useResult
$Res call({
 String id, String? title, String? thumbnailUrl, String? type, int memberCount
});




}
/// @nodoc
class _$GroupPreviewItemCopyWithImpl<$Res>
    implements $GroupPreviewItemCopyWith<$Res> {
  _$GroupPreviewItemCopyWithImpl(this._self, this._then);

  final GroupPreviewItem _self;
  final $Res Function(GroupPreviewItem) _then;

/// Create a copy of GroupPreviewItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = freezed,Object? thumbnailUrl = freezed,Object? type = freezed,Object? memberCount = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,thumbnailUrl: freezed == thumbnailUrl ? _self.thumbnailUrl : thumbnailUrl // ignore: cast_nullable_to_non_nullable
as String?,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String?,memberCount: null == memberCount ? _self.memberCount : memberCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [GroupPreviewItem].
extension GroupPreviewItemPatterns on GroupPreviewItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GroupPreviewItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GroupPreviewItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GroupPreviewItem value)  $default,){
final _that = this;
switch (_that) {
case _GroupPreviewItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GroupPreviewItem value)?  $default,){
final _that = this;
switch (_that) {
case _GroupPreviewItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? title,  String? thumbnailUrl,  String? type,  int memberCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GroupPreviewItem() when $default != null:
return $default(_that.id,_that.title,_that.thumbnailUrl,_that.type,_that.memberCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? title,  String? thumbnailUrl,  String? type,  int memberCount)  $default,) {final _that = this;
switch (_that) {
case _GroupPreviewItem():
return $default(_that.id,_that.title,_that.thumbnailUrl,_that.type,_that.memberCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? title,  String? thumbnailUrl,  String? type,  int memberCount)?  $default,) {final _that = this;
switch (_that) {
case _GroupPreviewItem() when $default != null:
return $default(_that.id,_that.title,_that.thumbnailUrl,_that.type,_that.memberCount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GroupPreviewItem implements GroupPreviewItem {
  const _GroupPreviewItem({required this.id, this.title, this.thumbnailUrl, this.type, this.memberCount = 0});
  factory _GroupPreviewItem.fromJson(Map<String, dynamic> json) => _$GroupPreviewItemFromJson(json);

@override final  String id;
@override final  String? title;
@override final  String? thumbnailUrl;
@override final  String? type;
@override@JsonKey() final  int memberCount;

/// Create a copy of GroupPreviewItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GroupPreviewItemCopyWith<_GroupPreviewItem> get copyWith => __$GroupPreviewItemCopyWithImpl<_GroupPreviewItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GroupPreviewItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GroupPreviewItem&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.thumbnailUrl, thumbnailUrl) || other.thumbnailUrl == thumbnailUrl)&&(identical(other.type, type) || other.type == type)&&(identical(other.memberCount, memberCount) || other.memberCount == memberCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,thumbnailUrl,type,memberCount);

@override
String toString() {
  return 'GroupPreviewItem(id: $id, title: $title, thumbnailUrl: $thumbnailUrl, type: $type, memberCount: $memberCount)';
}


}

/// @nodoc
abstract mixin class _$GroupPreviewItemCopyWith<$Res> implements $GroupPreviewItemCopyWith<$Res> {
  factory _$GroupPreviewItemCopyWith(_GroupPreviewItem value, $Res Function(_GroupPreviewItem) _then) = __$GroupPreviewItemCopyWithImpl;
@override @useResult
$Res call({
 String id, String? title, String? thumbnailUrl, String? type, int memberCount
});




}
/// @nodoc
class __$GroupPreviewItemCopyWithImpl<$Res>
    implements _$GroupPreviewItemCopyWith<$Res> {
  __$GroupPreviewItemCopyWithImpl(this._self, this._then);

  final _GroupPreviewItem _self;
  final $Res Function(_GroupPreviewItem) _then;

/// Create a copy of GroupPreviewItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = freezed,Object? thumbnailUrl = freezed,Object? type = freezed,Object? memberCount = null,}) {
  return _then(_GroupPreviewItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,thumbnailUrl: freezed == thumbnailUrl ? _self.thumbnailUrl : thumbnailUrl // ignore: cast_nullable_to_non_nullable
as String?,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String?,memberCount: null == memberCount ? _self.memberCount : memberCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$TopicsPreview {

 List<TopicPreviewItem> get items; int get totalCount;
/// Create a copy of TopicsPreview
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TopicsPreviewCopyWith<TopicsPreview> get copyWith => _$TopicsPreviewCopyWithImpl<TopicsPreview>(this as TopicsPreview, _$identity);

  /// Serializes this TopicsPreview to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TopicsPreview&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.totalCount, totalCount) || other.totalCount == totalCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(items),totalCount);

@override
String toString() {
  return 'TopicsPreview(items: $items, totalCount: $totalCount)';
}


}

/// @nodoc
abstract mixin class $TopicsPreviewCopyWith<$Res>  {
  factory $TopicsPreviewCopyWith(TopicsPreview value, $Res Function(TopicsPreview) _then) = _$TopicsPreviewCopyWithImpl;
@useResult
$Res call({
 List<TopicPreviewItem> items, int totalCount
});




}
/// @nodoc
class _$TopicsPreviewCopyWithImpl<$Res>
    implements $TopicsPreviewCopyWith<$Res> {
  _$TopicsPreviewCopyWithImpl(this._self, this._then);

  final TopicsPreview _self;
  final $Res Function(TopicsPreview) _then;

/// Create a copy of TopicsPreview
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = null,Object? totalCount = null,}) {
  return _then(_self.copyWith(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<TopicPreviewItem>,totalCount: null == totalCount ? _self.totalCount : totalCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [TopicsPreview].
extension TopicsPreviewPatterns on TopicsPreview {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TopicsPreview value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TopicsPreview() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TopicsPreview value)  $default,){
final _that = this;
switch (_that) {
case _TopicsPreview():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TopicsPreview value)?  $default,){
final _that = this;
switch (_that) {
case _TopicsPreview() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<TopicPreviewItem> items,  int totalCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TopicsPreview() when $default != null:
return $default(_that.items,_that.totalCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<TopicPreviewItem> items,  int totalCount)  $default,) {final _that = this;
switch (_that) {
case _TopicsPreview():
return $default(_that.items,_that.totalCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<TopicPreviewItem> items,  int totalCount)?  $default,) {final _that = this;
switch (_that) {
case _TopicsPreview() when $default != null:
return $default(_that.items,_that.totalCount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TopicsPreview implements TopicsPreview {
  const _TopicsPreview({final  List<TopicPreviewItem> items = const [], this.totalCount = 0}): _items = items;
  factory _TopicsPreview.fromJson(Map<String, dynamic> json) => _$TopicsPreviewFromJson(json);

 final  List<TopicPreviewItem> _items;
@override@JsonKey() List<TopicPreviewItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override@JsonKey() final  int totalCount;

/// Create a copy of TopicsPreview
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TopicsPreviewCopyWith<_TopicsPreview> get copyWith => __$TopicsPreviewCopyWithImpl<_TopicsPreview>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TopicsPreviewToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TopicsPreview&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.totalCount, totalCount) || other.totalCount == totalCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_items),totalCount);

@override
String toString() {
  return 'TopicsPreview(items: $items, totalCount: $totalCount)';
}


}

/// @nodoc
abstract mixin class _$TopicsPreviewCopyWith<$Res> implements $TopicsPreviewCopyWith<$Res> {
  factory _$TopicsPreviewCopyWith(_TopicsPreview value, $Res Function(_TopicsPreview) _then) = __$TopicsPreviewCopyWithImpl;
@override @useResult
$Res call({
 List<TopicPreviewItem> items, int totalCount
});




}
/// @nodoc
class __$TopicsPreviewCopyWithImpl<$Res>
    implements _$TopicsPreviewCopyWith<$Res> {
  __$TopicsPreviewCopyWithImpl(this._self, this._then);

  final _TopicsPreview _self;
  final $Res Function(_TopicsPreview) _then;

/// Create a copy of TopicsPreview
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = null,Object? totalCount = null,}) {
  return _then(_TopicsPreview(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<TopicPreviewItem>,totalCount: null == totalCount ? _self.totalCount : totalCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$TopicPreviewItem {

 String get id; String? get title; String? get topicImage; int get noOfReadings; String? get subtitle; String? get source; bool get isOwnTopic; bool get isSavedTopic;
/// Create a copy of TopicPreviewItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TopicPreviewItemCopyWith<TopicPreviewItem> get copyWith => _$TopicPreviewItemCopyWithImpl<TopicPreviewItem>(this as TopicPreviewItem, _$identity);

  /// Serializes this TopicPreviewItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TopicPreviewItem&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.topicImage, topicImage) || other.topicImage == topicImage)&&(identical(other.noOfReadings, noOfReadings) || other.noOfReadings == noOfReadings)&&(identical(other.subtitle, subtitle) || other.subtitle == subtitle)&&(identical(other.source, source) || other.source == source)&&(identical(other.isOwnTopic, isOwnTopic) || other.isOwnTopic == isOwnTopic)&&(identical(other.isSavedTopic, isSavedTopic) || other.isSavedTopic == isSavedTopic));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,topicImage,noOfReadings,subtitle,source,isOwnTopic,isSavedTopic);

@override
String toString() {
  return 'TopicPreviewItem(id: $id, title: $title, topicImage: $topicImage, noOfReadings: $noOfReadings, subtitle: $subtitle, source: $source, isOwnTopic: $isOwnTopic, isSavedTopic: $isSavedTopic)';
}


}

/// @nodoc
abstract mixin class $TopicPreviewItemCopyWith<$Res>  {
  factory $TopicPreviewItemCopyWith(TopicPreviewItem value, $Res Function(TopicPreviewItem) _then) = _$TopicPreviewItemCopyWithImpl;
@useResult
$Res call({
 String id, String? title, String? topicImage, int noOfReadings, String? subtitle, String? source, bool isOwnTopic, bool isSavedTopic
});




}
/// @nodoc
class _$TopicPreviewItemCopyWithImpl<$Res>
    implements $TopicPreviewItemCopyWith<$Res> {
  _$TopicPreviewItemCopyWithImpl(this._self, this._then);

  final TopicPreviewItem _self;
  final $Res Function(TopicPreviewItem) _then;

/// Create a copy of TopicPreviewItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = freezed,Object? topicImage = freezed,Object? noOfReadings = null,Object? subtitle = freezed,Object? source = freezed,Object? isOwnTopic = null,Object? isSavedTopic = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,topicImage: freezed == topicImage ? _self.topicImage : topicImage // ignore: cast_nullable_to_non_nullable
as String?,noOfReadings: null == noOfReadings ? _self.noOfReadings : noOfReadings // ignore: cast_nullable_to_non_nullable
as int,subtitle: freezed == subtitle ? _self.subtitle : subtitle // ignore: cast_nullable_to_non_nullable
as String?,source: freezed == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String?,isOwnTopic: null == isOwnTopic ? _self.isOwnTopic : isOwnTopic // ignore: cast_nullable_to_non_nullable
as bool,isSavedTopic: null == isSavedTopic ? _self.isSavedTopic : isSavedTopic // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [TopicPreviewItem].
extension TopicPreviewItemPatterns on TopicPreviewItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TopicPreviewItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TopicPreviewItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TopicPreviewItem value)  $default,){
final _that = this;
switch (_that) {
case _TopicPreviewItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TopicPreviewItem value)?  $default,){
final _that = this;
switch (_that) {
case _TopicPreviewItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? title,  String? topicImage,  int noOfReadings,  String? subtitle,  String? source,  bool isOwnTopic,  bool isSavedTopic)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TopicPreviewItem() when $default != null:
return $default(_that.id,_that.title,_that.topicImage,_that.noOfReadings,_that.subtitle,_that.source,_that.isOwnTopic,_that.isSavedTopic);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? title,  String? topicImage,  int noOfReadings,  String? subtitle,  String? source,  bool isOwnTopic,  bool isSavedTopic)  $default,) {final _that = this;
switch (_that) {
case _TopicPreviewItem():
return $default(_that.id,_that.title,_that.topicImage,_that.noOfReadings,_that.subtitle,_that.source,_that.isOwnTopic,_that.isSavedTopic);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? title,  String? topicImage,  int noOfReadings,  String? subtitle,  String? source,  bool isOwnTopic,  bool isSavedTopic)?  $default,) {final _that = this;
switch (_that) {
case _TopicPreviewItem() when $default != null:
return $default(_that.id,_that.title,_that.topicImage,_that.noOfReadings,_that.subtitle,_that.source,_that.isOwnTopic,_that.isSavedTopic);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TopicPreviewItem implements TopicPreviewItem {
  const _TopicPreviewItem({required this.id, this.title, this.topicImage, this.noOfReadings = 0, this.subtitle, this.source, this.isOwnTopic = false, this.isSavedTopic = false});
  factory _TopicPreviewItem.fromJson(Map<String, dynamic> json) => _$TopicPreviewItemFromJson(json);

@override final  String id;
@override final  String? title;
@override final  String? topicImage;
@override@JsonKey() final  int noOfReadings;
@override final  String? subtitle;
@override final  String? source;
@override@JsonKey() final  bool isOwnTopic;
@override@JsonKey() final  bool isSavedTopic;

/// Create a copy of TopicPreviewItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TopicPreviewItemCopyWith<_TopicPreviewItem> get copyWith => __$TopicPreviewItemCopyWithImpl<_TopicPreviewItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TopicPreviewItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TopicPreviewItem&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.topicImage, topicImage) || other.topicImage == topicImage)&&(identical(other.noOfReadings, noOfReadings) || other.noOfReadings == noOfReadings)&&(identical(other.subtitle, subtitle) || other.subtitle == subtitle)&&(identical(other.source, source) || other.source == source)&&(identical(other.isOwnTopic, isOwnTopic) || other.isOwnTopic == isOwnTopic)&&(identical(other.isSavedTopic, isSavedTopic) || other.isSavedTopic == isSavedTopic));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,topicImage,noOfReadings,subtitle,source,isOwnTopic,isSavedTopic);

@override
String toString() {
  return 'TopicPreviewItem(id: $id, title: $title, topicImage: $topicImage, noOfReadings: $noOfReadings, subtitle: $subtitle, source: $source, isOwnTopic: $isOwnTopic, isSavedTopic: $isSavedTopic)';
}


}

/// @nodoc
abstract mixin class _$TopicPreviewItemCopyWith<$Res> implements $TopicPreviewItemCopyWith<$Res> {
  factory _$TopicPreviewItemCopyWith(_TopicPreviewItem value, $Res Function(_TopicPreviewItem) _then) = __$TopicPreviewItemCopyWithImpl;
@override @useResult
$Res call({
 String id, String? title, String? topicImage, int noOfReadings, String? subtitle, String? source, bool isOwnTopic, bool isSavedTopic
});




}
/// @nodoc
class __$TopicPreviewItemCopyWithImpl<$Res>
    implements _$TopicPreviewItemCopyWith<$Res> {
  __$TopicPreviewItemCopyWithImpl(this._self, this._then);

  final _TopicPreviewItem _self;
  final $Res Function(_TopicPreviewItem) _then;

/// Create a copy of TopicPreviewItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = freezed,Object? topicImage = freezed,Object? noOfReadings = null,Object? subtitle = freezed,Object? source = freezed,Object? isOwnTopic = null,Object? isSavedTopic = null,}) {
  return _then(_TopicPreviewItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,topicImage: freezed == topicImage ? _self.topicImage : topicImage // ignore: cast_nullable_to_non_nullable
as String?,noOfReadings: null == noOfReadings ? _self.noOfReadings : noOfReadings // ignore: cast_nullable_to_non_nullable
as int,subtitle: freezed == subtitle ? _self.subtitle : subtitle // ignore: cast_nullable_to_non_nullable
as String?,source: freezed == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String?,isOwnTopic: null == isOwnTopic ? _self.isOwnTopic : isOwnTopic // ignore: cast_nullable_to_non_nullable
as bool,isSavedTopic: null == isSavedTopic ? _self.isSavedTopic : isSavedTopic // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$FriendDetailsFilters {

 String? get groupType;
/// Create a copy of FriendDetailsFilters
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FriendDetailsFiltersCopyWith<FriendDetailsFilters> get copyWith => _$FriendDetailsFiltersCopyWithImpl<FriendDetailsFilters>(this as FriendDetailsFilters, _$identity);

  /// Serializes this FriendDetailsFilters to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FriendDetailsFilters&&(identical(other.groupType, groupType) || other.groupType == groupType));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,groupType);

@override
String toString() {
  return 'FriendDetailsFilters(groupType: $groupType)';
}


}

/// @nodoc
abstract mixin class $FriendDetailsFiltersCopyWith<$Res>  {
  factory $FriendDetailsFiltersCopyWith(FriendDetailsFilters value, $Res Function(FriendDetailsFilters) _then) = _$FriendDetailsFiltersCopyWithImpl;
@useResult
$Res call({
 String? groupType
});




}
/// @nodoc
class _$FriendDetailsFiltersCopyWithImpl<$Res>
    implements $FriendDetailsFiltersCopyWith<$Res> {
  _$FriendDetailsFiltersCopyWithImpl(this._self, this._then);

  final FriendDetailsFilters _self;
  final $Res Function(FriendDetailsFilters) _then;

/// Create a copy of FriendDetailsFilters
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? groupType = freezed,}) {
  return _then(_self.copyWith(
groupType: freezed == groupType ? _self.groupType : groupType // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [FriendDetailsFilters].
extension FriendDetailsFiltersPatterns on FriendDetailsFilters {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FriendDetailsFilters value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FriendDetailsFilters() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FriendDetailsFilters value)  $default,){
final _that = this;
switch (_that) {
case _FriendDetailsFilters():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FriendDetailsFilters value)?  $default,){
final _that = this;
switch (_that) {
case _FriendDetailsFilters() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? groupType)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FriendDetailsFilters() when $default != null:
return $default(_that.groupType);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? groupType)  $default,) {final _that = this;
switch (_that) {
case _FriendDetailsFilters():
return $default(_that.groupType);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? groupType)?  $default,) {final _that = this;
switch (_that) {
case _FriendDetailsFilters() when $default != null:
return $default(_that.groupType);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FriendDetailsFilters implements FriendDetailsFilters {
  const _FriendDetailsFilters({this.groupType});
  factory _FriendDetailsFilters.fromJson(Map<String, dynamic> json) => _$FriendDetailsFiltersFromJson(json);

@override final  String? groupType;

/// Create a copy of FriendDetailsFilters
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FriendDetailsFiltersCopyWith<_FriendDetailsFilters> get copyWith => __$FriendDetailsFiltersCopyWithImpl<_FriendDetailsFilters>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FriendDetailsFiltersToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FriendDetailsFilters&&(identical(other.groupType, groupType) || other.groupType == groupType));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,groupType);

@override
String toString() {
  return 'FriendDetailsFilters(groupType: $groupType)';
}


}

/// @nodoc
abstract mixin class _$FriendDetailsFiltersCopyWith<$Res> implements $FriendDetailsFiltersCopyWith<$Res> {
  factory _$FriendDetailsFiltersCopyWith(_FriendDetailsFilters value, $Res Function(_FriendDetailsFilters) _then) = __$FriendDetailsFiltersCopyWithImpl;
@override @useResult
$Res call({
 String? groupType
});




}
/// @nodoc
class __$FriendDetailsFiltersCopyWithImpl<$Res>
    implements _$FriendDetailsFiltersCopyWith<$Res> {
  __$FriendDetailsFiltersCopyWithImpl(this._self, this._then);

  final _FriendDetailsFilters _self;
  final $Res Function(_FriendDetailsFilters) _then;

/// Create a copy of FriendDetailsFilters
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? groupType = freezed,}) {
  return _then(_FriendDetailsFilters(
groupType: freezed == groupType ? _self.groupType : groupType // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
