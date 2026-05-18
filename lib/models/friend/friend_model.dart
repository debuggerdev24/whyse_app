import 'package:redstreakapp/core/enums/user_gender.dart';

class FriendResponse {
  final String friendshipId;
  final String status;
  final FriendUser friend;

  const FriendResponse({
    required this.friendshipId,
    required this.status,
    required this.friend,
  });

  factory FriendResponse.fromJson(Map<String, dynamic> json) {
    return FriendResponse(
      friendshipId: json['friendshipId'] as String,
      status: json['status'] as String,
      friend: FriendUser.fromJson(json['friend'] as Map<String, dynamic>),
    );
  }
}

class FriendUser {
  final String id;
  final String? displayName;
  final String? email;
  final String? username;
  final String? phone;
  final UserGender? gender;

  const FriendUser({
    required this.id,
    this.displayName,
    this.email,
    this.username,
    this.phone,
    this.gender,
  });

  factory FriendUser.fromJson(Map<String, dynamic> json) {
    return FriendUser(
      id: json['id'] as String,
      displayName: json['displayName'] as String?,
      email: json['email'] as String?,
      username: json['username'] as String?,
      phone: json['phone'] as String?,
      gender: UserGender.fromApi(json['gender']),
    );
  }

  String get initials {
    final name = displayName ?? '';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}

class FriendRequestResponse {
  final String friendshipId;
  final String status;
  final FriendUser requester;

  const FriendRequestResponse({
    required this.friendshipId,
    required this.status,
    required this.requester,
  });

  factory FriendRequestResponse.fromJson(Map<String, dynamic> json) {
    return FriendRequestResponse(
      friendshipId: json['friendshipId'] as String,
      status: json['status'] as String,
      requester: FriendUser.fromJson(json['requester'] as Map<String, dynamic>),
    );
  }
}
