// ================= ENUM =================

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
  });

  factory GroupMember.fromJson(Map<String, dynamic> json) {
    return GroupMember(
      id: json['id'] as String,
      groupId: json['groupId'] as String,
      userId: json['userId'] as String,
      role: GroupMemberRoleX.fromString(json['role']),
      joinedAt: DateTime.parse(json['joinedAt'] as String),
      displayName: json['displayName'] as String,
      email: json['email'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
    );
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
    };
  }

  // ================= HELPERS =================

  String get fullName => '$firstName $lastName';

  bool get isOwner => role == GroupMemberRole.owner;
  bool get isAdmin => role == GroupMemberRole.admin;
}