import 'package:redstreakapp/models/friend/friend_details_model.dart';
import 'package:redstreakapp/models/friend/friend_model.dart';

/// Params for [FriendsListScreen] when opened from another user's profile.
class FriendsListScreenParams {
  const FriendsListScreenParams({
    required List<FriendUser> friends,
    this.title,
    this.viewOnly = true,
  })  : friends = friends,
        friendPreviews = null;

  const FriendsListScreenParams.fromPreviews({
    required List<FriendPreviewItem> friendPreviews,
    this.title,
    this.viewOnly = true,
  })  : friends = null,
        friendPreviews = friendPreviews;

  final List<FriendUser>? friends;
  final List<FriendPreviewItem>? friendPreviews;
  final String? title;
  final bool viewOnly;

  bool get usesPreviews => friendPreviews != null;
}
