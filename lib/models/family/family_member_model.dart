import 'package:redstreakapp/models/friend/friend_model.dart';

class FamilyMember {
  const FamilyMember({
    required this.id,
    required this.member,
    required this.relationship,
  });

  final String id;
  final FriendUser member;
  final String relationship;

  factory FamilyMember.fromJson(Map<String, dynamic> json) {
    return FamilyMember(
      id: json['id'] as String,
      relationship: json['relationship'] as String,
      member: FriendUser.fromJson(json['member'] as Map<String, dynamic>),
    );
  }
}
