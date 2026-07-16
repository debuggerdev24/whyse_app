import 'package:redstreakapp/models/gamification/achievement_progress_model.dart';
import 'package:redstreakapp/models/gamification/activity_rewards.dart';

class AchievementClaimResult {
  const AchievementClaimResult({
    required this.message,
    required this.pointsAwarded,
    this.achievement,
    this.totalScore,
    this.rewards,
  });

  final String message;
  final int pointsAwarded;
  final AchievementProgress? achievement;
  final int? totalScore;
  final ActivityRewards? rewards;

  factory AchievementClaimResult.fromJson(dynamic raw) {
    if (raw is! Map) {
      return const AchievementClaimResult(message: '', pointsAwarded: 0);
    }

    final root = Map<String, dynamic>.from(raw);
    final data = root['data'] is Map
        ? Map<String, dynamic>.from(root['data'] as Map)
        : root;

    AchievementProgress? achievement;
    for (final key in const [
      'achievement',
      'claimedAchievement',
      'achievementProgress',
    ]) {
      final value = data[key];
      if (value is Map) {
        achievement = AchievementProgress.fromJson(
          Map<String, dynamic>.from(value),
        );
        break;
      }
    }

    final rewardsRaw = data['rewards'];
    final rewards = rewardsRaw is Map
        ? ActivityRewards.fromJson(rewardsRaw)
        : null;

    final pointsAwarded = _readInt(
      data['pointsAwarded'] ??
          data['pointsEarned'] ??
          rewards?.pointsAwarded ??
          achievement?.rewardPoints,
    );

    final scores = data['scores'];
    final totalScore = _readNullableInt(
      data['totalScore'] ??
          (scores is Map ? scores['totalScore'] : null) ??
          rewards?.totalScore,
    );

    final message = root['message']?.toString() ??
        data['message']?.toString() ??
        '';

    return AchievementClaimResult(
      message: message,
      pointsAwarded: pointsAwarded,
      achievement: achievement,
      totalScore: totalScore,
      rewards: rewards,
    );
  }
}

int _readInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

int? _readNullableInt(dynamic value) {
  if (value == null) return null;
  return _readInt(value);
}
