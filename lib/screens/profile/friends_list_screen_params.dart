import 'package:redstreakapp/models/friend/friend_details_model.dart';
import 'package:redstreakapp/models/friend/friend_model.dart';

/// Params for [FriendsListScreen].
class FriendsListScreenParams {
  /// Current user's friends list (fetched via [FriendProvider]).
  const FriendsListScreenParams({
    required List<FriendUser> friends,
    this.title,
    this.viewOnly = true,
  })  : friends = friends,
        friendPreviews = null,
        userId = null;

  /// Static preview list (legacy).
  const FriendsListScreenParams.fromPreviews({
    required List<FriendPreviewItem> friendPreviews,
    this.title,
    this.viewOnly = true,
  })  : friends = null,
        friendPreviews = friendPreviews,
        userId = null;

  /// Another user's friends — loaded from profile list API with pagination.
  const FriendsListScreenParams.forUserProfile({
    required this.userId,
    this.title,
    this.viewOnly = true,
  })  : friends = null,
        friendPreviews = null;

  final List<FriendUser>? friends;
  final List<FriendPreviewItem>? friendPreviews;
  final String? userId;
  final String? title;
  final bool viewOnly;

  bool get usesPreviews => friendPreviews != null;

  bool get isUserProfileFriendsList =>
      userId != null && userId!.isNotEmpty;
}
