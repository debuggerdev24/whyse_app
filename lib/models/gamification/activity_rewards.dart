import 'package:redstreakapp/models/gamification/achievement_progress_model.dart';
import 'package:redstreakapp/models/gamification/user_achievements_model.dart';

/// Parsed `rewards` block from activity APIs (spark interact, mark-read, quiz, etc.).
class ActivityRewards {
  const ActivityRewards({
    required this.sparkPoints,
    required this.interestPoints,
    required this.episodePoints,
    required this.seriesPoints,
    required this.pointsAwarded,
    required this.totalScore,
    this.achievementProgress,
    this.interestAchievementProgress,
    this.seriesAchievementProgress,
    this.streakAchievementProgress,
    this.completedInterests = const [],
    this.currentStreak,
  });

  final int sparkPoints;
  final int interestPoints;
  final int episodePoints;
  final int seriesPoints;
  final int pointsAwarded;
  final int totalScore;
  final AchievementProgress? achievementProgress;
  final AchievementProgress? interestAchievementProgress;
  final AchievementProgress? seriesAchievementProgress;
  final AchievementProgress? streakAchievementProgress;
  final List<CompletedInterest> completedInterests;
  final int? currentStreak;

  factory ActivityRewards.fromJson(dynamic raw) {
    if (raw is! Map) {
      return const ActivityRewards(
        sparkPoints: 0,
        interestPoints: 0,
        episodePoints: 0,
        seriesPoints: 0,
        pointsAwarded: 0,
        totalScore: 0,
      );
    }
    final json = Map<String, dynamic>.from(raw);
    final streak = json['streak'] is Map
        ? Map<String, dynamic>.from(json['streak'] as Map)
        : null;

    return ActivityRewards(
      sparkPoints: _int(json['sparkPoints']),
      interestPoints: _int(json['interestPoints']),
      episodePoints: _int(json['episodePoints']),
      seriesPoints: _int(json['seriesPoints']),
      pointsAwarded: _int(json['pointsAwarded']),
      totalScore: _int(json['totalScore']),
      currentStreak: streak != null ? _int(streak['currentStreak']) : null,
      achievementProgress: _parseProgress(json['achievementProgress']),
      interestAchievementProgress:
          _parseProgress(json['interestAchievementProgress']),
      seriesAchievementProgress:
          _parseProgress(json['seriesAchievementProgress']),
      streakAchievementProgress:
          _parseProgress(json['streakAchievementProgress']),
      completedInterests: json['completedInterests'] is List
          ? (json['completedInterests'] as List)
              .whereType<Map>()
              .map((e) => CompletedInterest.fromJson(
                    Map<String, dynamic>.from(e),
                  ))
              .toList()
          : const [],
    );
  }

  static AchievementProgress? _parseProgress(dynamic raw) {
    if (raw is! Map) return null;
    return AchievementProgress.fromJson(Map<String, dynamic>.from(raw));
  }
}

int _int(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

/// Backward-compatible alias for spark interact responses.
typedef SparkInteractionRewards = ActivityRewards;
