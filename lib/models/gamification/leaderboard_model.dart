class LeaderboardEntryModel {
  const LeaderboardEntryModel({
    required this.rank,
    required this.userId,
    required this.displayName,
    required this.totalScore,
    this.avatarUrl,
    this.isCurrentUser = false,
  });

  final int rank;
  final String userId;
  final String displayName;
  final int totalScore;
  final String? avatarUrl;
  final bool isCurrentUser;

  factory LeaderboardEntryModel.fromJson(Map<String, dynamic> json) =>
      LeaderboardEntryModel(
        rank: _int(json['rank']),
        userId: json['userId']?.toString() ?? json['id']?.toString() ?? '',
        displayName: json['displayName']?.toString() ??
            json['name']?.toString() ??
            json['username']?.toString() ??
            'User',
        totalScore: _int(json['totalScore'] ?? json['points'] ?? json['score']),
        avatarUrl: json['avatarUrl']?.toString() ?? json['avatar']?.toString(),
        isCurrentUser: json['isCurrentUser'] == true || json['isSelf'] == true,
      );
}

class LeaderboardYourRank {
  const LeaderboardYourRank({
    required this.rank,
    required this.totalScore,
  });

  final int rank;
  final int totalScore;

  factory LeaderboardYourRank.fromJson(Map<String, dynamic> json) =>
      LeaderboardYourRank(
        rank: _int(json['rank']),
        totalScore: _int(json['totalScore'] ?? json['points'] ?? json['score']),
      );
}

class LeaderboardModel {
  const LeaderboardModel({
    required this.entries,
    this.yourRank,
  });

  final List<LeaderboardEntryModel> entries;
  final LeaderboardYourRank? yourRank;

  factory LeaderboardModel.fromJson(dynamic raw) {
    final root = raw is Map ? Map<String, dynamic>.from(raw) : <String, dynamic>{};
    final data = root['data'] is Map
        ? Map<String, dynamic>.from(root['data'] as Map)
        : root;

    final entriesRaw = data['entries'] ?? data['items'] ?? data['leaderboard'];
    final entries = entriesRaw is List
        ? entriesRaw
            .whereType<Map>()
            .map((e) => LeaderboardEntryModel.fromJson(
                  Map<String, dynamic>.from(e),
                ))
            .toList()
        : <LeaderboardEntryModel>[];

    final yourRankRaw = data['yourRank'];
    final yourRank = yourRankRaw is Map
        ? LeaderboardYourRank.fromJson(
            Map<String, dynamic>.from(yourRankRaw),
          )
        : null;

    return LeaderboardModel(entries: entries, yourRank: yourRank);
  }
}

int _int(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}
