// ================= ENUM =================

import 'package:redstreakapp/core/utils/network_image_url.dart';

enum GroupMemberRole { owner, admin, member }

extension GroupMemberRoleX on GroupMemberRole {
  static GroupMemberRole fromString(String value) {
    switch (value.toUpperCase()) {
      case 'OWNER':
        return GroupMemberRole.owner;
      case 'ADMIN':
        return GroupMemberRole.admin;
      case 'MEMBER':
        return GroupMemberRole.member;
      default:
        throw Exception('Unknown GroupMemberRole: $value');
    }
  }

  String toJson() => name.toUpperCase();
}

class GroupMemberStreak {
  const GroupMemberStreak({
    required this.current,
    required this.longest,
    this.lastActiveDate,
  });

  final int current;
  final int longest;
  final String? lastActiveDate;

  static const empty = GroupMemberStreak(current: 0, longest: 0);

  factory GroupMemberStreak.fromJson(Map<String, dynamic> json) {
    return GroupMemberStreak(
      current: _readInt(json['current'] ?? json['currentStreak']),
      longest: _readInt(json['longest'] ?? json['longestStreak']),
      lastActiveDate: json['lastActiveDate']?.toString(),
    );
  }
}

// ================= MODEL =================

class GroupMember {
  final String id;
  final String groupId;
  final String userId;
  final GroupMemberRole role;
  final DateTime joinedAt;

  final String displayName;
  final String email;
  final String firstName;
  final String lastName;
  final String? avatarUrl;
  final GroupMemberStreak? streak;

  const GroupMember({
    required this.id,
    required this.groupId,
    required this.userId,
    required this.role,
    required this.joinedAt,
    required this.displayName,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.avatarUrl,
    this.streak,
  });

  factory GroupMember.fromJson(Map<String, dynamic> json) {
    return GroupMember(
      id: json['id']?.toString() ?? '',
      groupId: json['groupId']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      role: GroupMemberRoleX.fromString(json['role']?.toString() ?? 'MEMBER'),
      joinedAt: DateTime.tryParse(json['joinedAt']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      displayName: json['displayName']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      avatarUrl: resolveNullableNetworkImageUrl(json['avatarUrl']?.toString()),
      streak: _parseStreak(json),
    );
  }

  static GroupMemberStreak? _parseStreak(Map<String, dynamic> json) {
    final streakRaw = json['streak'];
    if (streakRaw is Map) {
      return GroupMemberStreak.fromJson(Map<String, dynamic>.from(streakRaw));
    }
    if (json['currentStreak'] != null || json['longestStreak'] != null) {
      return GroupMemberStreak.fromJson(json);
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'groupId': groupId,
      'userId': userId,
      'role': role.toJson(),
      'joinedAt': joinedAt.toIso8601String(),
      'displayName': displayName,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'avatarUrl': avatarUrl,
      if (streak != null)
        'streak': {
          'current': streak!.current,
          'longest': streak!.longest,
          'lastActiveDate': streak!.lastActiveDate,
        },
    };
  }

  int get currentStreak => streak?.current ?? 0;

  String get fullName => '$firstName $lastName'.trim();

  bool get isOwner => role == GroupMemberRole.owner;
  bool get isAdmin => role == GroupMemberRole.admin;
}

extension GroupMemberStreakRanking on List<GroupMember> {
  List<GroupMember> sortedByStreakDesc() {
    final copy = List<GroupMember>.from(this);
    copy.sort((a, b) {
      final byStreak = b.currentStreak.compareTo(a.currentStreak);
      if (byStreak != 0) return byStreak;
      return a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase());
    });
    return copy;
  }
}

int _readInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}
