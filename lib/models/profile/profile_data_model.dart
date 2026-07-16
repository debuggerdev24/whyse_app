import 'package:redstreakapp/core/constants/app_constants.dart';
import 'package:redstreakapp/core/utils/network_image_url.dart';

/// User profile from `GET /mobile/profile/me` (and merged PATCH `data`).
class ProfileDataModel {
  /// Common ISO 3166-1 alpha-2 codes from the API mapped to [AppConstants.countries] labels.
  static const Map<String, String> _isoCountryCodeToName = {
    'IN': 'India',
    'US': 'United States',
    'GB': 'United Kingdom',
    'AU': 'Australia',
    'CA': 'Canada',
    'DE': 'Germany',
    'FR': 'France',
    'AE': 'United Arab Emirates',
    'JP': 'Japan',
    'BR': 'Brazil',
  };

  /// Normalizes `country` from the API (often `IN`) to a dropdown-friendly name when possible.
  static String countryFromApi(dynamic raw) {
    final t = raw?.toString().trim() ?? '';
    if (t.isEmpty) return '';
    if (AppConstants.countries.contains(t)) return t;
    final mapped = _isoCountryCodeToName[t];
    if (mapped != null && AppConstants.countries.contains(mapped)) {
      return mapped;
    }
    return t;
  }

  static int? _readInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString());
  }

  final String userId;
  final String firstName;
  final String lastName;
  final String displayName;
  final String username;
  final String? avatarUrl;
  final String phone;
  final String? pendingPhone;
  final bool phoneVerified;
  final String email;
  final bool isPrivate;
  final SocialAccounts socialAccounts;
  final List<String> interests;
  final String country;
  final String preferredLanguage;
  final int dailyReadingGoal;
  final Counts counts;
  final ProfileOverview? overview;
  // final List<Group> groups;
  // final List<Friend> friends;
  // final List<Topic> topics;

  ProfileDataModel({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.displayName,
    required this.username,
    this.avatarUrl,
    required this.phone,
    this.pendingPhone,
    required this.phoneVerified,
    required this.email,
    required this.isPrivate,
    required this.socialAccounts,
    required this.interests,
    required this.country,
    required this.preferredLanguage,
    required this.dailyReadingGoal,
    required this.counts,
    this.overview,
    // required this.groups,
    // required this.friends,
    // required this.topics,
  });

  factory ProfileDataModel.fromJson(Map<String, dynamic> json) {
    final first = json['firstName']?.toString() ?? '';
    final last = json['lastName']?.toString() ?? '';
    final display = json['displayName']?.toString().trim();
    final resolvedDisplay = (display != null && display.isNotEmpty)
        ? display
        : '$first $last'.trim();
    return ProfileDataModel(
      userId: json['userId']?.toString() ?? '',
      firstName: first,
      lastName: last,
      displayName: resolvedDisplay.isNotEmpty ? resolvedDisplay : first,
      username: json['username']?.toString() ?? '',
      avatarUrl: resolveNullableNetworkImageUrl(json['avatarUrl'] as String?),
      phone: json['phone']?.toString() ?? '',
      pendingPhone: json['pendingPhone']?.toString(),
      phoneVerified: json['phoneVerified'] ?? false,
      email: json['email']?.toString() ?? '',
      isPrivate: json['isPrivate'] ?? false,
      socialAccounts: SocialAccounts.fromJson(json['socialAccounts'] ?? {}),
      interests: List<String>.from(json['interests'] ?? []),
      country: countryFromApi(json['country']),
      preferredLanguage: json['preferredLanguage']?.toString() ?? '',
      dailyReadingGoal: _readInt(json['dailyReadingGoal']) ?? 0,
      counts: Counts.fromJson(json['counts'] ?? {}),
      overview: json['overview'] is Map
          ? ProfileOverview.fromJson(
              Map<String, dynamic>.from(json['overview'] as Map),
            )
          : null,
      // groups: (json['groups'] as List? ?? [])
      //     .map((e) => Group.fromJson(e))
      //     .toList(),
      // friends: (json['friends'] as List? ?? [])
      //     .map((e) => Friend.fromJson(e))
      //     .toList(),
      // topics: (json['topics'] as List? ?? [])
      //     .map((e) => Topic.fromJson(e))
      //     .toList(),
    );
  }

  factory ProfileDataModel.mergeFromUpdate(
    Map<String, dynamic> data,
    ProfileDataModel base,
  ) {
    final first = data['firstName']?.toString() ?? base.firstName;
    final last = data['lastName']?.toString() ?? base.lastName;
    final displayFromApi = data['displayName']?.toString().trim();
    final composed = '$first $last'.trim();
    final displayName = (displayFromApi != null && displayFromApi.isNotEmpty)
        ? displayFromApi
        : (composed.isNotEmpty ? composed : base.displayName);
    return ProfileDataModel(
      userId: data['userId']?.toString() ?? base.userId,
      firstName: first,
      lastName: last,
      displayName: displayName,
      username: data['username']?.toString() ?? base.username,
      avatarUrl: data.containsKey('avatarUrl')
          ? resolveNullableNetworkImageUrl(data['avatarUrl'] as String?)
          : base.avatarUrl,
      phone: data['phone']?.toString() ?? base.phone,
      pendingPhone: data.containsKey('pendingPhone')
          ? data['pendingPhone'] as String?
          : base.pendingPhone,
      phoneVerified: data['phoneVerified'] as bool? ?? base.phoneVerified,
      email: data['email']?.toString() ?? base.email,
      isPrivate: data['isPrivate'] as bool? ?? base.isPrivate,
      socialAccounts: SocialAccounts.fromJson({
        ...base.socialAccounts.toJson(),
        ...(data['socialAccounts'] as Map<String, dynamic>? ?? {}),
      }),
      interests: data['interests'] != null
          ? List<String>.from(data['interests'] as List)
          : base.interests,
      country: data.containsKey('country')
          ? countryFromApi(data['country'])
          : base.country,
      preferredLanguage:
          data['preferredLanguage']?.toString() ?? base.preferredLanguage,
      dailyReadingGoal:
          _readInt(data['dailyReadingGoal']) ?? base.dailyReadingGoal,
      counts: data['counts'] is Map
          ? Counts.fromJson(Map<String, dynamic>.from(data['counts'] as Map))
          : base.counts,
      overview: data['overview'] is Map
          ? ProfileOverview.fromJson(
              Map<String, dynamic>.from(data['overview'] as Map),
            )
          : base.overview,
    );
  }
}

class SocialAccounts {
  final String? instagram;
  final String? x;
  final String? google;

  SocialAccounts({this.instagram, this.x, this.google});

  factory SocialAccounts.fromJson(Map<String, dynamic> json) {
    return SocialAccounts(
      instagram: _nonEmptyString(json['instagram']),
      x: _nonEmptyString(json['x']),
      google: _nonEmptyString(json['google']),
    );
  }

  static String? _nonEmptyString(dynamic v) {
    final s = v?.toString().trim();
    if (s == null || s.isEmpty) return null;
    return s;
  }

  Map<String, dynamic> toJson() => {
        'instagram': instagram?.trim() ?? '',
        'x': x?.trim() ?? '',
        'google': google?.trim() ?? '',
      };
}

class Counts {
  final int ownedGroupsCount;
  final int memberGroupsCount;
  final int friendCount;

  Counts({
    required this.ownedGroupsCount,
    required this.memberGroupsCount,
    required this.friendCount,
  });

  factory Counts.fromJson(Map<String, dynamic> json) {
    int n(dynamic k) => ProfileDataModel._readInt(json[k]) ?? 0;
    return Counts(
      ownedGroupsCount: n('ownedGroupsCount'),
      memberGroupsCount: n('memberGroupsCount'),
      friendCount: n('friendCount'),
    );
  }
}

class ProfileOverview {
  const ProfileOverview({
    required this.streak,
    required this.score,
    required this.reading,
    required this.achievementsUnlocked,
  });

  final ProfileOverviewStreak streak;
  final int score;
  final ProfileOverviewReading reading;
  final int achievementsUnlocked;

  static const empty = ProfileOverview(
    streak: ProfileOverviewStreak.empty,
    score: 0,
    reading: ProfileOverviewReading.empty,
    achievementsUnlocked: 0,
  );

  factory ProfileOverview.fromJson(Map<String, dynamic> json) {
    return ProfileOverview(
      streak: json['streak'] is Map
          ? ProfileOverviewStreak.fromJson(
              Map<String, dynamic>.from(json['streak'] as Map),
            )
          : ProfileOverviewStreak.empty,
      score: ProfileDataModel._readInt(json['score']) ?? 0,
      reading: json['reading'] is Map
          ? ProfileOverviewReading.fromJson(
              Map<String, dynamic>.from(json['reading'] as Map),
            )
          : ProfileOverviewReading.empty,
      achievementsUnlocked:
          ProfileDataModel._readInt(json['achievementsUnlocked']) ?? 0,
    );
  }
}

class ProfileOverviewStreak {
  const ProfileOverviewStreak({
    required this.current,
    required this.longest,
    this.lastActiveDate,
  });

  final int current;
  final int longest;
  final String? lastActiveDate;

  static const empty = ProfileOverviewStreak(
    current: 0,
    longest: 0,
  );

  factory ProfileOverviewStreak.fromJson(Map<String, dynamic> json) {
    return ProfileOverviewStreak(
      current: ProfileDataModel._readInt(json['current']) ?? 0,
      longest: ProfileDataModel._readInt(json['longest']) ?? 0,
      lastActiveDate: json['lastActiveDate']?.toString(),
    );
  }
}

class ProfileOverviewReading {
  const ProfileOverviewReading({
    required this.totalDuration,
    required this.completedCount,
  });

  final ProfileReadingDuration totalDuration;
  final int completedCount;

  static const empty = ProfileOverviewReading(
    totalDuration: ProfileReadingDuration.empty,
    completedCount: 0,
  );

  factory ProfileOverviewReading.fromJson(Map<String, dynamic> json) {
    return ProfileOverviewReading(
      totalDuration: json['totalDuration'] is Map
          ? ProfileReadingDuration.fromJson(
              Map<String, dynamic>.from(json['totalDuration'] as Map),
            )
          : ProfileReadingDuration.empty,
      completedCount: ProfileDataModel._readInt(json['completedCount']) ?? 0,
    );
  }
}

class ProfileReadingDuration {
  const ProfileReadingDuration({
    required this.value,
    required this.unit,
  });

  final int value;
  final String unit;

  static const empty = ProfileReadingDuration(value: 0, unit: 'minutes');

  factory ProfileReadingDuration.fromJson(Map<String, dynamic> json) {
    return ProfileReadingDuration(
      value: ProfileDataModel._readInt(json['value']) ?? 0,
      unit: json['unit']?.toString() ?? 'minutes',
    );
  }

  String get displayLabel {
    switch (unit.toLowerCase()) {
      case 'hour':
      case 'hours':
        return value == 1 ? 'Hour' : 'Hours';
      case 'minute':
      case 'minutes':
        return value == 1 ? 'Minute' : 'Minutes';
      default:
        return unit;
    }
  }
}

class Group {
  final Creator creator;
  final String id;
  final String title;
  final String type;
  final String? thumbnailUrl;
  final String myRole;
  final DateTime joinedAt;
  final String createdBy;

  Group({
    required this.creator,
    required this.id,
    required this.title,
    required this.type,
    this.thumbnailUrl,
    required this.myRole,
    required this.joinedAt,
    required this.createdBy,
  });

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      creator: Creator.fromJson(json['creator']),
      id: json['id'],
      title: json['title'],
      type: json['type'],
      thumbnailUrl: resolveNullableNetworkImageUrl(json['thumbnailUrl']?.toString()),
      myRole: json['myRole'],
      joinedAt: DateTime.parse(json['joinedAt']),
      createdBy: json['createdBy'],
    );
  }
}

class Creator {
  final String userId;
  final String displayName;
  final String username;
  final String? avatarUrl;

  Creator({
    required this.userId,
    required this.displayName,
    required this.username,
    this.avatarUrl,
  });

  factory Creator.fromJson(Map<String, dynamic> json) {
    return Creator(
      userId: json['userId'],
      displayName: json['displayName'],
      username: json['username'],
      avatarUrl: resolveNullableNetworkImageUrl(json['avatarUrl']?.toString()),
    );
  }
}

class Friend {
  final String userId;
  final String displayName;
  final String username;
  final String? avatarUrl;

  Friend({
    required this.userId,
    required this.displayName,
    required this.username,
    this.avatarUrl,
  });

  factory Friend.fromJson(Map<String, dynamic> json) {
    return Friend(
      userId: json['userId'],
      displayName: json['displayName'],
      username: json['username'],
      avatarUrl: resolveNullableNetworkImageUrl(json['avatarUrl']?.toString()),
    );
  }
}