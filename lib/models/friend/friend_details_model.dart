import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:redstreakapp/models/profile/profile_data_model.dart';

part 'friend_details_model.freezed.dart';
part 'friend_details_model.g.dart';

ProfileOverview? _overviewFromJson(dynamic json) {
  if (json == null || json is! Map) return null;
  return ProfileOverview.fromJson(Map<String, dynamic>.from(json));
}

@freezed
abstract class FriendDetailsResponse with _$FriendDetailsResponse {
  const factory FriendDetailsResponse({
    required bool success,
    required String message,
    required FriendDetailsData data,
  }) = _FriendDetailsResponse;

  factory FriendDetailsResponse.fromJson(Map<String, dynamic> json) =>
      _$FriendDetailsResponseFromJson(json);
}

@freezed
abstract class FriendDetailsData with _$FriendDetailsData {
  const factory FriendDetailsData({
    required FriendProfile profile,
    @JsonKey(fromJson: _overviewFromJson, includeToJson: false)
    ProfileOverview? overview,
    required FriendsPreview friendsPreview,
    required GroupsPreview groupsPreview,
    required TopicsPreview topicsPreview,
    required FriendDetailsFilters filters,
  }) = _FriendDetailsData;

  factory FriendDetailsData.fromJson(Map<String, dynamic> json) =>
      _$FriendDetailsDataFromJson(json);
}

@freezed
abstract class FriendProfile with _$FriendProfile {
  const factory FriendProfile({
    required String userId,
    String? firstName,
    String? lastName,
    String? displayName,
    String? username,
    String? avatarUrl,
    String? phone,
    String? pendingPhone,
    @Default(false) bool phoneVerified,
    String? email,
    @JsonKey(fromJson: _socialAccountsFromJson, toJson: _socialAccountsToJson)
    FriendSocialAccounts? socialAccounts,
    @Default([]) List<String> interests,
    String? country,
    String? preferredLanguage,
    int? dailyReadingGoal,
    @Default(false) bool isPrivate,
    @Default(false) bool isFriend,
    @Default(false) bool friendRequestSent,
  }) = _FriendProfile;

  factory FriendProfile.fromJson(Map<String, dynamic> json) =>
      _$FriendProfileFromJson(json);
}

@freezed
abstract class FriendSocialAccounts with _$FriendSocialAccounts {
  const factory FriendSocialAccounts({
    @Default('') String x,
    @Default('') String google,
    @Default('') String instagram,
  }) = _FriendSocialAccounts;

  factory FriendSocialAccounts.fromJson(Map<String, dynamic> json) =>
      _$FriendSocialAccountsFromJson(json);
}

@freezed
abstract class FriendsPreview with _$FriendsPreview {
  const factory FriendsPreview({
    @Default([]) List<FriendPreviewItem> items,
    @Default(0) int totalCount,
  }) = _FriendsPreview;

  factory FriendsPreview.fromJson(Map<String, dynamic> json) =>
      _$FriendsPreviewFromJson(json);
}

@freezed
abstract class FriendPreviewItem with _$FriendPreviewItem {
  const factory FriendPreviewItem({
    required String id,
    String? displayName,
    String? username,
    String? avatarUrl,
  }) = _FriendPreviewItem;

  factory FriendPreviewItem.fromJson(Map<String, dynamic> json) =>
      _$FriendPreviewItemFromJson(json);
}

@freezed
abstract class GroupsPreview with _$GroupsPreview {
  const factory GroupsPreview({
    @Default([]) List<GroupPreviewItem> items,
    @Default(0) int totalCount,
  }) = _GroupsPreview;

  factory GroupsPreview.fromJson(Map<String, dynamic> json) =>
      _$GroupsPreviewFromJson(json);
}

@freezed
abstract class GroupPreviewItem with _$GroupPreviewItem {
  const factory GroupPreviewItem({
    required String id,
    String? title,
    String? thumbnailUrl,
    String? type,
    @Default(0) int memberCount,
  }) = _GroupPreviewItem;

  factory GroupPreviewItem.fromJson(Map<String, dynamic> json) =>
      _$GroupPreviewItemFromJson(json);
}

@freezed
abstract class TopicsPreview with _$TopicsPreview {
  const factory TopicsPreview({
    @Default([]) List<TopicPreviewItem> items,
    @Default(0) int totalCount,
  }) = _TopicsPreview;

  factory TopicsPreview.fromJson(Map<String, dynamic> json) =>
      _$TopicsPreviewFromJson(json);
}

@freezed
abstract class TopicPreviewItem with _$TopicPreviewItem {
  const factory TopicPreviewItem({
    required String id,
    String? title,
    String? topicImage,
    @Default(0) int noOfReadings,
    String? subtitle,
    String? source,
    @Default(false) bool isOwnTopic,
    @Default(false) bool isSavedTopic,
  }) = _TopicPreviewItem;

  factory TopicPreviewItem.fromJson(Map<String, dynamic> json) =>
      _$TopicPreviewItemFromJson(json);
}

@freezed
abstract class FriendProfileListResponse with _$FriendProfileListResponse {
  const factory FriendProfileListResponse({
    required bool success,
    required String message,
    required FriendProfileListData data,
  }) = _FriendProfileListResponse;

  factory FriendProfileListResponse.fromJson(Map<String, dynamic> json) =>
      _$FriendProfileListResponseFromJson(json);
}

@freezed
abstract class FriendProfileListData with _$FriendProfileListData {
  const factory FriendProfileListData({
    required String section,
    @Default([]) List<FriendProfileListItem> items,
    required FriendProfileListPagination pagination,
  }) = _FriendProfileListData;

  factory FriendProfileListData.fromJson(Map<String, dynamic> json) =>
      _$FriendProfileListDataFromJson(json);
}

@freezed
abstract class FriendProfileListItem with _$FriendProfileListItem {
  const factory FriendProfileListItem({
    required String id,
    String? displayName,
    String? username,
    String? avatarUrl,
    @Default(false) bool isFriend,
    @Default(false) bool friendRequestSent,
  }) = _FriendProfileListItem;

  factory FriendProfileListItem.fromJson(Map<String, dynamic> json) =>
      _$FriendProfileListItemFromJson(json);
}

@freezed
abstract class FriendProfileListPagination with _$FriendProfileListPagination {
  const factory FriendProfileListPagination({
    @Default(1) int page,
    @Default(20) int limit,
    @Default(0) int total,
    @Default(0) int totalPages,
  }) = _FriendProfileListPagination;

  factory FriendProfileListPagination.fromJson(Map<String, dynamic> json) =>
      _$FriendProfileListPaginationFromJson(json);
}

@freezed
abstract class UserProfileGroupsListResponse with _$UserProfileGroupsListResponse {
  const factory UserProfileGroupsListResponse({
    required bool success,
    required String message,
    required UserProfileGroupsListData data,
  }) = _UserProfileGroupsListResponse;

  factory UserProfileGroupsListResponse.fromJson(Map<String, dynamic> json) =>
      _$UserProfileGroupsListResponseFromJson(json);
}

@freezed
abstract class UserProfileGroupsListData with _$UserProfileGroupsListData {
  const factory UserProfileGroupsListData({
    required String section,
    @Default([]) List<GroupPreviewItem> items,
    required FriendProfileListPagination pagination,
    FriendDetailsFilters? filters,
  }) = _UserProfileGroupsListData;

  factory UserProfileGroupsListData.fromJson(Map<String, dynamic> json) =>
      _$UserProfileGroupsListDataFromJson(json);
}

@freezed
abstract class UserProfileTopicsListResponse with _$UserProfileTopicsListResponse {
  const factory UserProfileTopicsListResponse({
    required bool success,
    required String message,
    required UserProfileTopicsListData data,
  }) = _UserProfileTopicsListResponse;

  factory UserProfileTopicsListResponse.fromJson(Map<String, dynamic> json) =>
      _$UserProfileTopicsListResponseFromJson(json);
}

@freezed
abstract class UserProfileTopicsListData with _$UserProfileTopicsListData {
  const factory UserProfileTopicsListData({
    required String section,
    @Default([]) List<TopicPreviewItem> items,
    required FriendProfileListPagination pagination,
  }) = _UserProfileTopicsListData;

  factory UserProfileTopicsListData.fromJson(Map<String, dynamic> json) =>
      _$UserProfileTopicsListDataFromJson(json);
}

@freezed
abstract class FriendDetailsFilters with _$FriendDetailsFilters {
  const factory FriendDetailsFilters({
    String? groupType,
  }) = _FriendDetailsFilters;

  factory FriendDetailsFilters.fromJson(Map<String, dynamic> json) =>
      _$FriendDetailsFiltersFromJson(json);
}

FriendSocialAccounts? _socialAccountsFromJson(dynamic json) {
  if (json == null) return null;
  if (json is! Map<String, dynamic>) return null;
  return FriendSocialAccounts.fromJson(json);
}

Map<String, dynamic>? _socialAccountsToJson(FriendSocialAccounts? accounts) =>
    accounts?.toJson();

String _initialsFromName(String? displayName, String? username) {
  final name = (displayName ?? '').trim();
  if (name.isNotEmpty) {
    final parts = name.split(RegExp(r'\s+'));
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
  final user = (username ?? '').trim();
  if (user.isNotEmpty) return user[0].toUpperCase();
  return '?';
}

extension FriendProfileUi on FriendProfile {
  String get initials =>
      _initialsFromName(displayName, username);

  String get displayLabel => displayName ?? username ?? '';
}

extension FriendPreviewItemUi on FriendPreviewItem {
  String get initials =>
      _initialsFromName(displayName, username);

  String get displayLabel => displayName ?? username ?? '';
}

extension FriendProfileListItemUi on FriendProfileListItem {
  String get initials =>
      _initialsFromName(displayName, username);

  String get displayLabel => displayName ?? username ?? '';
}
