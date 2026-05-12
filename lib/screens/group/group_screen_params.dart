import 'package:redstreakapp/models/group/group_response_model.dart';

/// Route / navigation params for group hub (details, updates, streaks).
class GroupDetailsScreenParams {
  GroupDetailsScreenParams({
    required this.id,
    required this.groupName,
    this.thumbnail,
    this.description,
    this.initialTab = 0,
    required this.inviteCode,
    this.myRole,
  });

  final String id;
  final String groupName;
  final String? thumbnail;
  final String? description;

  /// 0 = Details, 1 = Updates, 2 = Streaks Ranking
  final int initialTab;

  /// Shown as `#inviteCode` with copy; if null, a short code is derived from [id].
  final String? inviteCode;

  /// Current user's role in this group (from list APIs). Used when member list
  /// is truncated or not loaded yet.
  final UserRole? myRole;

  String get displayInviteCode {
    if (inviteCode != null && inviteCode!.isNotEmpty) {
      return inviteCode!.startsWith('#') ? inviteCode! : '#$inviteCode';
    }
    if (id.length >= 10) return '#${id.substring(0, 10)}';
    return '#$id';
  }
}
