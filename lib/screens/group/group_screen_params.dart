/// Route / navigation params for group hub (details, updates, streaks).
class GroupDetailsScreenParams {
  GroupDetailsScreenParams({
    required this.id,
    required this.groupName,
    this.thumbnail,
    this.description,
    this.initialTab = 0,
    required this.inviteCode,
  });

  final String id;
  final String groupName;
  final String? thumbnail;
  final String? description;

  /// 0 = Details, 1 = Updates, 2 = Streaks Ranking
  final int initialTab;

  /// Shown as `#inviteCode` with copy; if null, a short code is derived from [id].
  final String? inviteCode;

  String get displayInviteCode {
    if (inviteCode != null && inviteCode!.isNotEmpty) {
      return inviteCode!.startsWith('#') ? inviteCode! : '#$inviteCode';
    }
    if (id.length >= 10) return '#${id.substring(0, 10)}';
    return '#$id';
  }
}
