import 'package:redstreakapp/models/gamification/activity_rewards.dart';
import 'package:redstreakapp/models/gamification/score_event_config.dart';

class ScoreEventAward {
  const ScoreEventAward({required this.eventType, required this.points});

  final String eventType;
  final int points;
}

/// Parsed gamification payload from activity APIs (mark-read, page-progress, quiz, spark interact).
class ScoreAwardResult {
  const ScoreAwardResult({
    required this.events,
    required this.totalPointsEarned,
    this.rewards,
  });

  final List<ScoreEventAward> events;
  final int totalPointsEarned;
  final ActivityRewards? rewards;

  bool hasEvent(String type) =>
      events.any((e) => e.eventType == type);

  int pointsFor(String type) => events
      .where((e) => e.eventType == type)
      .fold(0, (sum, e) => sum + e.points);

  bool get hasSeriesEpisodeCompleted =>
      hasEvent(ScoreEventConfig.seriesEpisodeCompleted) ||
      (rewards?.episodePoints ?? 0) > 0;

  bool get hasSeriesCompleted =>
      hasEvent(ScoreEventConfig.seriesCompleted) ||
      (rewards?.seriesPoints ?? 0) > 0;

  bool get hasFirstInterestCompleted =>
      hasEvent(ScoreEventConfig.firstInterestCompleted) ||
      (rewards?.interestPoints ?? 0) > 0;

  bool get hasSparkCompleted =>
      hasEvent(ScoreEventConfig.sparkCompleted) ||
      (rewards?.sparkPoints ?? 0) > 0;

  bool get hasEpisodeQuizCompleted =>
      hasEvent(ScoreEventConfig.episodeQuizCompleted);

  /// True when the API indicates the user finished every episode in this series.
  bool get isCurrentSeriesFullyComplete {
    final episode = rewards?.achievementProgress;
    if (episode == null || episode.type != 'episode') return false;
    if (!episode.completed) return false;
    if (episode.target <= 0) return episode.percentage >= 100;
    return episode.progress >= episode.target;
  }

  static ScoreAwardResult empty() =>
      const ScoreAwardResult(events: [], totalPointsEarned: 0, rewards: null);

  static ScoreAwardResult parse(dynamic raw) {
    if (raw == null) return empty();

    final root = raw is Map ? Map<String, dynamic>.from(raw) : <String, dynamic>{};
    final data = root['data'] is Map
        ? Map<String, dynamic>.from(root['data'] as Map)
        : root;

    final rewardsRaw = root['rewards'] ?? data['rewards'];
    final rewards = rewardsRaw is Map
        ? ActivityRewards.fromJson(rewardsRaw)
        : null;

    final gamification = data['gamification'] is Map
        ? Map<String, dynamic>.from(data['gamification'] as Map)
        : data['score'] is Map
        ? Map<String, dynamic>.from(data['score'] as Map)
        : null;

    final eventsRaw = gamification?['events'] ??
        gamification?['awards'] ??
        data['scoreEvents'] ??
        data['events'] ??
        data['awards'];

    final events = <ScoreEventAward>[];
    if (eventsRaw is List) {
      for (final item in eventsRaw) {
        if (item is! Map) continue;
        final map = Map<String, dynamic>.from(item);
        final type = (map['eventType'] ??
                map['type'] ??
                map['event'] ??
                map['name'])
            ?.toString();
        if (type == null || type.isEmpty) continue;

        final points = _readInt(
          map['points'] ??
              map['pointsAwarded'] ??
              map['awardedPoints'] ??
              map['value'],
          ScoreEventConfig.fallbackFor(type),
        );
        if (points <= 0) continue;
        events.add(ScoreEventAward(eventType: type, points: points));
      }
    } else if (rewards != null) {
      _addRewardEvent(
        events,
        type: ScoreEventConfig.sparkCompleted,
        points: rewards.sparkPoints,
      );
      _addRewardEvent(
        events,
        type: ScoreEventConfig.firstInterestCompleted,
        points: rewards.interestPoints,
      );
      _addRewardEvent(
        events,
        type: ScoreEventConfig.seriesEpisodeCompleted,
        points: rewards.episodePoints,
      );
      _addRewardEvent(
        events,
        type: ScoreEventConfig.seriesCompleted,
        points: rewards.seriesPoints,
      );
    }

    var total = _readInt(
      rewards?.pointsAwarded ??
          gamification?['totalPointsAwarded'] ??
          gamification?['totalPoints'] ??
          data['totalPointsAwarded'] ??
          data['totalPointsEarned'] ??
          data['pointsEarned'],
      -1,
    );
    if (total < 0) {
      total = events.fold(0, (sum, e) => sum + e.points);
    }

    return ScoreAwardResult(
      events: events,
      totalPointsEarned: total,
      rewards: rewards,
    );
  }

  static void _addRewardEvent(
    List<ScoreEventAward> events, {
    required String type,
    required int points,
  }) {
    if (points <= 0) return;
    events.add(ScoreEventAward(eventType: type, points: points));
  }

  static int _readInt(dynamic value, int fallback) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }
}
