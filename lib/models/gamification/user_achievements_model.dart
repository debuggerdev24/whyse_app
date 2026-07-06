import 'package:redstreakapp/models/gamification/achievement_progress_model.dart';

class CompletedInterest {
  const CompletedInterest({required this.id, required this.name});

  final String id;
  final String name;

  factory CompletedInterest.fromJson(Map<String, dynamic> json) =>
      CompletedInterest(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
      );
}

class UserAchievements {
  const UserAchievements({
    required this.streak,
    required this.spark,
    required this.series,
    required this.interest,
  });

  final List<AchievementProgress> streak;
  final List<AchievementProgress> spark;
  final List<AchievementProgress> series;
  final List<AchievementProgress> interest;

  AchievementProgress? get activeStreakGoal {
    final flagged = streak.where((a) => a.isActiveGoal).toList();
    if (flagged.isNotEmpty) return flagged.first;
    final pending = streak.where((a) => !a.completed && !a.claimed).toList()
      ..sort((a, b) => a.target.compareTo(b.target));
    return pending.isEmpty ? null : pending.first;
  }

  List<AchievementProgress> get allGoals => [
        ...streak,
        ...spark,
        ...series,
        ...interest,
      ];

  factory UserAchievements.fromJson(dynamic raw) {
    if (raw is! Map) {
      return const UserAchievements(
        streak: [],
        spark: [],
        series: [],
        interest: [],
      );
    }
    final json = Map<String, dynamic>.from(raw);
    return UserAchievements(
      streak: _parseList(json['streak']),
      spark: _parseList(json['spark']),
      series: _parseList(json['series']),
      interest: _parseList(json['interest']),
    );
  }

  static List<AchievementProgress> _parseList(dynamic raw) {
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map((e) => AchievementProgress.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
}
