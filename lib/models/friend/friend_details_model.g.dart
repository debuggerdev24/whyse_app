// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'friend_details_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FriendDetailsResponse _$FriendDetailsResponseFromJson(
  Map<String, dynamic> json,
) => _FriendDetailsResponse(
  success: json['success'] as bool,
  message: json['message'] as String,
  data: FriendDetailsData.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$FriendDetailsResponseToJson(
  _FriendDetailsResponse instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'data': instance.data,
};

_FriendDetailsData _$FriendDetailsDataFromJson(Map<String, dynamic> json) =>
    _FriendDetailsData(
      profile: FriendProfile.fromJson(json['profile'] as Map<String, dynamic>),
      overview: _overviewFromJson(json['overview']),
      friendsPreview: FriendsPreview.fromJson(
        json['friendsPreview'] as Map<String, dynamic>,
      ),
      groupsPreview: GroupsPreview.fromJson(
        json['groupsPreview'] as Map<String, dynamic>,
      ),
      topicsPreview: TopicsPreview.fromJson(
        json['topicsPreview'] as Map<String, dynamic>,
      ),
      filters: FriendDetailsFilters.fromJson(
        json['filters'] as Map<String, dynamic>,
      ),
    );

Map<String, dynamic> _$FriendDetailsDataToJson(_FriendDetailsData instance) =>
    <String, dynamic>{
      'profile': instance.profile,
      'friendsPreview': instance.friendsPreview,
      'groupsPreview': instance.groupsPreview,
      'topicsPreview': instance.topicsPreview,
      'filters': instance.filters,
    };

_FriendProfile _$FriendProfileFromJson(Map<String, dynamic> json) =>
    _FriendProfile(
      userId: json['userId'] as String,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      displayName: json['displayName'] as String?,
      username: json['username'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      phone: json['phone'] as String?,
      pendingPhone: json['pendingPhone'] as String?,
      phoneVerified: json['phoneVerified'] as bool? ?? false,
      email: json['email'] as String?,
      socialAccounts: _socialAccountsFromJson(json['socialAccounts']),
      interests:
          (json['interests'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      country: json['country'] as String?,
      preferredLanguage: json['preferredLanguage'] as String?,
      dailyReadingGoal: (json['dailyReadingGoal'] as num?)?.toInt(),
      isPrivate: json['isPrivate'] as bool? ?? false,
      isFriend: json['isFriend'] as bool? ?? false,
      friendRequestSent: json['friendRequestSent'] as bool? ?? false,
    );

Map<String, dynamic> _$FriendProfileToJson(_FriendProfile instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'displayName': instance.displayName,
      'username': instance.username,
      'avatarUrl': instance.avatarUrl,
      'phone': instance.phone,
      'pendingPhone': instance.pendingPhone,
      'phoneVerified': instance.phoneVerified,
      'email': instance.email,
      'socialAccounts': _socialAccountsToJson(instance.socialAccounts),
      'interests': instance.interests,
      'country': instance.country,
      'preferredLanguage': instance.preferredLanguage,
      'dailyReadingGoal': instance.dailyReadingGoal,
      'isPrivate': instance.isPrivate,
      'isFriend': instance.isFriend,
      'friendRequestSent': instance.friendRequestSent,
    };

_FriendSocialAccounts _$FriendSocialAccountsFromJson(
  Map<String, dynamic> json,
) => _FriendSocialAccounts(
  x: json['x'] as String? ?? '',
  google: json['google'] as String? ?? '',
  instagram: json['instagram'] as String? ?? '',
);

Map<String, dynamic> _$FriendSocialAccountsToJson(
  _FriendSocialAccounts instance,
) => <String, dynamic>{
  'x': instance.x,
  'google': instance.google,
  'instagram': instance.instagram,
};

_FriendsPreview _$FriendsPreviewFromJson(Map<String, dynamic> json) =>
    _FriendsPreview(
      items:
          (json['items'] as List<dynamic>?)
              ?.map(
                (e) => FriendPreviewItem.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const [],
      totalCount: (json['totalCount'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$FriendsPreviewToJson(_FriendsPreview instance) =>
    <String, dynamic>{
      'items': instance.items,
      'totalCount': instance.totalCount,
    };

_FriendPreviewItem _$FriendPreviewItemFromJson(Map<String, dynamic> json) =>
    _FriendPreviewItem(
      id: json['id'] as String,
      displayName: json['displayName'] as String?,
      username: json['username'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
    );

Map<String, dynamic> _$FriendPreviewItemToJson(_FriendPreviewItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'displayName': instance.displayName,
      'username': instance.username,
      'avatarUrl': instance.avatarUrl,
    };

_GroupsPreview _$GroupsPreviewFromJson(Map<String, dynamic> json) =>
    _GroupsPreview(
      items:
          (json['items'] as List<dynamic>?)
              ?.map((e) => GroupPreviewItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      totalCount: (json['totalCount'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$GroupsPreviewToJson(_GroupsPreview instance) =>
    <String, dynamic>{
      'items': instance.items,
      'totalCount': instance.totalCount,
    };

_GroupPreviewItem _$GroupPreviewItemFromJson(Map<String, dynamic> json) =>
    _GroupPreviewItem(
      id: json['id'] as String,
      title: json['title'] as String?,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      type: json['type'] as String?,
      memberCount: (json['memberCount'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$GroupPreviewItemToJson(_GroupPreviewItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'thumbnailUrl': instance.thumbnailUrl,
      'type': instance.type,
      'memberCount': instance.memberCount,
    };

_TopicsPreview _$TopicsPreviewFromJson(Map<String, dynamic> json) =>
    _TopicsPreview(
      items:
          (json['items'] as List<dynamic>?)
              ?.map((e) => TopicPreviewItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      totalCount: (json['totalCount'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$TopicsPreviewToJson(_TopicsPreview instance) =>
    <String, dynamic>{
      'items': instance.items,
      'totalCount': instance.totalCount,
    };

_TopicPreviewItem _$TopicPreviewItemFromJson(Map<String, dynamic> json) =>
    _TopicPreviewItem(
      id: json['id'] as String,
      title: json['title'] as String?,
      topicImage: json['topicImage'] as String?,
      noOfReadings: (json['noOfReadings'] as num?)?.toInt() ?? 0,
      subtitle: json['subtitle'] as String?,
      source: json['source'] as String?,
      isOwnTopic: json['isOwnTopic'] as bool? ?? false,
      isSavedTopic: json['isSavedTopic'] as bool? ?? false,
    );

Map<String, dynamic> _$TopicPreviewItemToJson(_TopicPreviewItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'topicImage': instance.topicImage,
      'noOfReadings': instance.noOfReadings,
      'subtitle': instance.subtitle,
      'source': instance.source,
      'isOwnTopic': instance.isOwnTopic,
      'isSavedTopic': instance.isSavedTopic,
    };

_FriendProfileListResponse _$FriendProfileListResponseFromJson(
  Map<String, dynamic> json,
) => _FriendProfileListResponse(
  success: json['success'] as bool,
  message: json['message'] as String,
  data: FriendProfileListData.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$FriendProfileListResponseToJson(
  _FriendProfileListResponse instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'data': instance.data,
};

_FriendProfileListData _$FriendProfileListDataFromJson(
  Map<String, dynamic> json,
) => _FriendProfileListData(
  section: json['section'] as String,
  items:
      (json['items'] as List<dynamic>?)
          ?.map(
            (e) => FriendProfileListItem.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      const [],
  pagination: FriendProfileListPagination.fromJson(
    json['pagination'] as Map<String, dynamic>,
  ),
);

Map<String, dynamic> _$FriendProfileListDataToJson(
  _FriendProfileListData instance,
) => <String, dynamic>{
  'section': instance.section,
  'items': instance.items,
  'pagination': instance.pagination,
};

_FriendProfileListItem _$FriendProfileListItemFromJson(
  Map<String, dynamic> json,
) => _FriendProfileListItem(
  id: json['id'] as String,
  displayName: json['displayName'] as String?,
  username: json['username'] as String?,
  avatarUrl: json['avatarUrl'] as String?,
  isFriend: json['isFriend'] as bool? ?? false,
  friendRequestSent: json['friendRequestSent'] as bool? ?? false,
);

Map<String, dynamic> _$FriendProfileListItemToJson(
  _FriendProfileListItem instance,
) => <String, dynamic>{
  'id': instance.id,
  'displayName': instance.displayName,
  'username': instance.username,
  'avatarUrl': instance.avatarUrl,
  'isFriend': instance.isFriend,
  'friendRequestSent': instance.friendRequestSent,
};

_FriendProfileListPagination _$FriendProfileListPaginationFromJson(
  Map<String, dynamic> json,
) => _FriendProfileListPagination(
  page: (json['page'] as num?)?.toInt() ?? 1,
  limit: (json['limit'] as num?)?.toInt() ?? 20,
  total: (json['total'] as num?)?.toInt() ?? 0,
  totalPages: (json['totalPages'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$FriendProfileListPaginationToJson(
  _FriendProfileListPagination instance,
) => <String, dynamic>{
  'page': instance.page,
  'limit': instance.limit,
  'total': instance.total,
  'totalPages': instance.totalPages,
};

_UserProfileGroupsListResponse _$UserProfileGroupsListResponseFromJson(
  Map<String, dynamic> json,
) => _UserProfileGroupsListResponse(
  success: json['success'] as bool,
  message: json['message'] as String,
  data: UserProfileGroupsListData.fromJson(
    json['data'] as Map<String, dynamic>,
  ),
);

Map<String, dynamic> _$UserProfileGroupsListResponseToJson(
  _UserProfileGroupsListResponse instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'data': instance.data,
};

_UserProfileGroupsListData _$UserProfileGroupsListDataFromJson(
  Map<String, dynamic> json,
) => _UserProfileGroupsListData(
  section: json['section'] as String,
  items:
      (json['items'] as List<dynamic>?)
          ?.map((e) => GroupPreviewItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  pagination: FriendProfileListPagination.fromJson(
    json['pagination'] as Map<String, dynamic>,
  ),
  filters: json['filters'] == null
      ? null
      : FriendDetailsFilters.fromJson(json['filters'] as Map<String, dynamic>),
);

Map<String, dynamic> _$UserProfileGroupsListDataToJson(
  _UserProfileGroupsListData instance,
) => <String, dynamic>{
  'section': instance.section,
  'items': instance.items,
  'pagination': instance.pagination,
  'filters': instance.filters,
};

_UserProfileTopicsListResponse _$UserProfileTopicsListResponseFromJson(
  Map<String, dynamic> json,
) => _UserProfileTopicsListResponse(
  success: json['success'] as bool,
  message: json['message'] as String,
  data: UserProfileTopicsListData.fromJson(
    json['data'] as Map<String, dynamic>,
  ),
);

Map<String, dynamic> _$UserProfileTopicsListResponseToJson(
  _UserProfileTopicsListResponse instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'data': instance.data,
};

_UserProfileTopicsListData _$UserProfileTopicsListDataFromJson(
  Map<String, dynamic> json,
) => _UserProfileTopicsListData(
  section: json['section'] as String,
  items:
      (json['items'] as List<dynamic>?)
          ?.map((e) => TopicPreviewItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  pagination: FriendProfileListPagination.fromJson(
    json['pagination'] as Map<String, dynamic>,
  ),
);

Map<String, dynamic> _$UserProfileTopicsListDataToJson(
  _UserProfileTopicsListData instance,
) => <String, dynamic>{
  'section': instance.section,
  'items': instance.items,
  'pagination': instance.pagination,
};

_FriendDetailsFilters _$FriendDetailsFiltersFromJson(
  Map<String, dynamic> json,
) => _FriendDetailsFilters(groupType: json['groupType'] as String?);

Map<String, dynamic> _$FriendDetailsFiltersToJson(
  _FriendDetailsFilters instance,
) => <String, dynamic>{'groupType': instance.groupType};
