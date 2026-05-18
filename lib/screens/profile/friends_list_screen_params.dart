import 'package:redstreakapp/models/friend/friend_model.dart';

/// Params for [FriendsListScreen] when opened from another user's profile.
class FriendsListScreenParams {
  const FriendsListScreenParams({
    required this.friends,
    this.title,
    this.viewOnly = true,
  });

  final List<FriendUser> friends;
  final String? title;
  final bool viewOnly;
}
