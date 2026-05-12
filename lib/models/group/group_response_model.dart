import 'package:redstreakapp/core/utils/network_image_url.dart';
import 'package:redstreakapp/core/utils/user_facing_message.dart';

// ================= ENUMS =================

enum GroupType { private, public }

extension GroupTypeX on GroupType {
  static GroupType fromString(String value) {
    switch (value.toUpperCase()) {
      case 'PRIVATE':
        return GroupType.private;
      case 'PUBLIC':
        return GroupType.public;
      default:
        throw Exception('Unknown GroupType: $value');
    }
  }

  String toJson() {
    switch (this) {
      case GroupType.private:
        return 'PRIVATE';
      case GroupType.public:
        return 'PUBLIC';
    }
  }
}

enum UserRole { owner, member, admin }

extension UserRoleX on UserRole {
  static UserRole fromString(String value) {
    switch (value.toUpperCase()) {
      case 'OWNER':
        return UserRole.owner;
      case 'MEMBER':
        return UserRole.member;
      case 'ADMIN':
        return UserRole.admin;
      default:
        throw Exception('Unknown UserRole: $value');
    }
  }

  String toJson() {
    return name.toUpperCase();
  }
}

// ================= MAIN MODEL =================

class GroupResponse {
  final Group group;
  final UserRole myRole;
  final DateTime joinedAt;
  final int memberCount;

  const GroupResponse({
    required this.group,
    required this.myRole,
    required this.joinedAt,
    required this.memberCount,
  });

  factory GroupResponse.fromJson(Map<String, dynamic> json) {
    return GroupResponse(
      group: Group.fromJson(json['group']),
      myRole: UserRoleX.fromString(json['myRole']),
      joinedAt: DateTime.parse(json['joinedAt']),
      memberCount: json['memberCount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'group': group.toJson(),
      'myRole': myRole.toJson(),
      'joinedAt': joinedAt.toIso8601String(),
      'memberCount' : memberCount,
    };
  }
}

// ================= GROUP =================

class Group {
  final String id;
  final String title;
  final String? description;
  final String? thumbnailUrl;
  final GroupType type;
  final String createdBy;
  final String joinCode;

  final List<String> ageRanges;
  final List<String> grades;
  final List<String> languages;
  final List<String> levels;
  final List<String> countryCodes;

  final DateTime createdAt;
  final DateTime updatedAt;

  final Creator creator;

  const Group({
    required this.id,
    required this.title,
    required this.description,
    required this.thumbnailUrl,
    required this.type,
    required this.createdBy,
    required this.joinCode,
    required this.ageRanges,
    required this.grades,
    required this.languages,
    required this.levels,
    required this.countryCodes,
    required this.createdAt,
    required this.updatedAt,
    required this.creator,
  });

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      id: json['id'],
      title: json['title'],
      description: safeDescriptionForUi(json['description']?.toString()),
      thumbnailUrl: resolveNullableNetworkImageUrl(json['thumbnailUrl']?.toString()),
      type: GroupTypeX.fromString(json['type']),
      createdBy: json['createdBy'],
      joinCode: json['joinCode'],
      ageRanges: List<String>.from(json['ageRanges'] ?? []),
      grades: List<String>.from(json['grades'] ?? []),
      languages: List<String>.from(json['languages'] ?? []),
      levels: List<String>.from(json['levels'] ?? []),
      countryCodes: List<String>.from(json['countryCodes'] ?? []),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      creator: Creator.fromJson(json['creator']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'thumbnailUrl': thumbnailUrl,
      'type': type.toJson(),
      'createdBy': createdBy,
      'joinCode': joinCode,
      'ageRanges': ageRanges,
      'grades': grades,
      'languages': languages,
      'levels': levels,
      'countryCodes': countryCodes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'creator': creator.toJson(),
    };
  }
}

// ================= CREATOR =================

class Creator {
  final String userId;
  final String firstName;
  final String lastName;
  final String email;
  final String? username;
  final String? avatarUrl;
  final String displayName;

  const Creator({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.username,
    required this.avatarUrl,
    required this.displayName,
  });

  factory Creator.fromJson(Map<String, dynamic> json) {
    return Creator(
      userId: json['userId'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      username: json['username'],
      avatarUrl: resolveNullableNetworkImageUrl(json['avatarUrl']?.toString()),
      displayName: json['displayName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'username': username,
      'avatarUrl': avatarUrl,
      'displayName': displayName,
    };
  }
}