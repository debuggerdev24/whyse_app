import 'package:redstreakapp/models/friend/friend_model.dart';

class FamilyMember {
  const FamilyMember({
    required this.id,
    required this.role,
    required this.relationship,
    required this.member,
  });

  final String id;
  final String role;
  final String relationship;
  final FriendUser member;

  factory FamilyMember.fromJson(Map<String, dynamic> json) {
    return FamilyMember(
      id: json['familyMemberId'] as String,
      role: json['role'] as String,
      relationship: json['roleLabel'] as String,
      member: FriendUser.fromJson(json['member'] as Map<String, dynamic>),
    );
  }
}
