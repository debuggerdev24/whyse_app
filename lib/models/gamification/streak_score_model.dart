import 'package:redstreakapp/models/gamification/achievement_progress_model.dart';
import 'package:redstreakapp/models/gamification/user_achievements_model.dart';

class StreakInfo {
  const StreakInfo({
    required this.currentStreak,
    required this.longestStreak,
    this.lastActiveDate,
    this.streakStatus,
    this.freezesAvailable = 0,
  });

  final int currentStreak;
  final int longestStreak;
  final String? lastActiveDate;
  final String? streakStatus;
  final int freezesAvailable;

  factory StreakInfo.fromJson(Map<String, dynamic> json) => StreakInfo(
        currentStreak: _int(json['currentStreak']),
        longestStreak: _int(json['longestStreak']),
        lastActiveDate: json['lastActiveDate']?.toString(),
        streakStatus: json['streakStatus']?.toString(),
        freezesAvailable: _int(json['freezesAvailable']),
      );
}

class ScoreBreakdownItem {
  const ScoreBreakdownItem({
    required this.eventType,
    required this.totalPoints,
    required this.count,
  });

  final String eventType;
  final int totalPoints;
  final int count;

  factory ScoreBreakdownItem.fromJson(Map<String, dynamic> json) =>
      ScoreBreakdownItem(
        eventType: json['eventType']?.toString() ?? '',
        totalPoints: _int(json['totalPoints']),
        count: _int(json['count']),
      );
}

class ScoresInfo {
  const ScoresInfo({
    required this.totalScore,
    required this.breakdown,
  });

  final int totalScore;
  final List<ScoreBreakdownItem> breakdown;

  factory ScoresInfo.fromJson(Map<String, dynamic> json) => ScoresInfo(
        totalScore: _int(json['totalScore']),
        breakdown: json['breakdown'] is List
            ? (json['breakdown'] as List)
                .whereType<Map>()
                .map((e) => ScoreBreakdownItem.fromJson(
                      Map<String, dynamic>.from(e),
                    ))
                .toList()
            : const [],
      );
}

class StreakMilestone {
  const StreakMilestone({
    required this.days,
    required this.label,
    required this.achieved,
    this.isActiveGoal = false,
  });

  final int days;
  final String label;
  final bool achieved;
  final bool isActiveGoal;

  factory StreakMilestone.fromJson(Map<String, dynamic> json) =>
      StreakMilestone(
        days: _int(json['days']),
        label: json['label']?.toString() ?? '',
        achieved: json['achieved'] == true,
        isActiveGoal: json['isActiveGoal'] == true,
      );

  factory StreakMilestone.fromAchievement(AchievementProgress achievement) =>
      StreakMilestone(
        days: achievement.target,
        label: achievement.label,
        achieved: achievement.completed || achievement.claimed,
        isActiveGoal: achievement.isActiveGoal,
      );
}

class StreakCalendarDay {
  const StreakCalendarDay({
    required this.date,
    required this.qualified,
    this.status = 'none',
  });

  final String date;
  final bool qualified;
  final String status;

  bool get isCompleted => status == 'completed' || qualified;

  bool get isFrozen => status == 'frozen';

  factory StreakCalendarDay.fromJson(Map<String, dynamic> json) =>
      StreakCalendarDay(
        date: json['date']?.toString() ?? '',
        qualified: json['qualified'] == true,
        status: json['status']?.toString() ?? 'none',
      );
}

class StreakFreezeInfo {
  const StreakFreezeInfo({
    required this.freezesAvailable,
    required this.freezeCostPoints,
  });

  final int freezesAvailable;
  final int freezeCostPoints;

  factory StreakFreezeInfo.fromJson(Map<String, dynamic> json) =>
      StreakFreezeInfo(
        freezesAvailable: _int(json['freezesAvailable']),
        freezeCostPoints: _int(json['freezeCostPoints'], fallback: 100),
      );
}

class StreakScoreModel {
  const StreakScoreModel({
    required this.streak,
    required this.scores,
    required this.milestones,
    required this.calendarDays,
    required this.achievements,
    required this.completedInterests,
    this.freeze,
    this.dailySparkGoal = 5,
    this.dailySparksCompleted = 0,
  });

  final StreakInfo streak;
  final ScoresInfo scores;
  final List<StreakMilestone> milestones;
  final List<StreakCalendarDay> calendarDays;
  final UserAchievements achievements;
  final List<CompletedInterest> completedInterests;
  final StreakFreezeInfo? freeze;
  final int dailySparkGoal;
  final int dailySparksCompleted;

  AchievementProgress? get activeStreakGoal => achievements.activeStreakGoal;

  int get freezesAvailable =>
      freeze?.freezesAvailable ?? streak.freezesAvailable;

  int get freezeCostPoints => freeze?.freezeCostPoints ?? 100;

  StreakMilestone? get activeGoal {
    final streakGoal = activeStreakGoal;
    if (streakGoal != null) {
      return StreakMilestone.fromAchievement(streakGoal);
    }
    final flagged = milestones.where((m) => m.isActiveGoal).toList();
    if (flagged.isNotEmpty) return flagged.first;
    final pending = milestones.where((m) => !m.achieved).toList()
      ..sort((a, b) => a.days.compareTo(b.days));
    return pending.isEmpty ? null : pending.first;
  }

  Set<int> streakDayNumbersForMonth(int year, int month) {
    final days = <int>{};
    for (final day in calendarDays) {
      if (!day.isCompleted) continue;
      final parsed = DateTime.tryParse(day.date);
      if (parsed == null) continue;
      if (parsed.year == year && parsed.month == month) {
        days.add(parsed.day);
      }
    }
    return days;
  }

  bool isDateCompleted(DateTime date) {
    final key =
        '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    return calendarDays.any((d) => d.date == key && d.isCompleted);
  }

  StreakScoreModel copyWith({
    StreakInfo? streak,
    ScoresInfo? scores,
    List<StreakMilestone>? milestones,
    List<StreakCalendarDay>? calendarDays,
    UserAchievements? achievements,
    List<CompletedInterest>? completedInterests,
    StreakFreezeInfo? freeze,
    int? dailySparkGoal,
    int? dailySparksCompleted,
  }) {
    return StreakScoreModel(
      streak: streak ?? this.streak,
      scores: scores ?? this.scores,
      milestones: milestones ?? this.milestones,
      calendarDays: calendarDays ?? this.calendarDays,
      achievements: achievements ?? this.achievements,
      completedInterests: completedInterests ?? this.completedInterests,
      freeze: freeze ?? this.freeze,
      dailySparkGoal: dailySparkGoal ?? this.dailySparkGoal,
      dailySparksCompleted: dailySparksCompleted ?? this.dailySparksCompleted,
    );
  }

  StreakScoreModel mergeCalendarDays(List<StreakCalendarDay> incoming) {
    if (incoming.isEmpty) return this;
    final incomingMonths = incoming.map((d) {
      final parsed = DateTime.tryParse(d.date);
      return parsed == null ? null : (parsed.year, parsed.month);
    }).whereType<(int, int)>().toSet();

    final kept = calendarDays.where((d) {
      final parsed = DateTime.tryParse(d.date);
      if (parsed == null) return true;
      return !incomingMonths.contains((parsed.year, parsed.month));
    }).toList();

    return copyWith(calendarDays: [...kept, ...incoming]);
  }

  factory StreakScoreModel.fromJson(Map<String, dynamic> json) {
    final streakMap = json['streak'] is Map
        ? Map<String, dynamic>.from(json['streak'] as Map)
        : <String, dynamic>{};
    final scoresMap = json['scores'] is Map
        ? Map<String, dynamic>.from(json['scores'] as Map)
        : <String, dynamic>{};

    final achievements = UserAchievements.fromJson(json['achievements']);

    final legacyMilestones = json['milestones'] is List
        ? (json['milestones'] as List)
            .whereType<Map>()
            .map((e) => StreakMilestone.fromJson(
                  Map<String, dynamic>.from(e),
                ))
            .toList()
        : <StreakMilestone>[];

    final milestones = legacyMilestones.isNotEmpty
        ? legacyMilestones
        : achievements.streak
            .map(StreakMilestone.fromAchievement)
            .toList();

    final freezeFromRoot = json['freeze'] is Map
        ? StreakFreezeInfo.fromJson(
            Map<String, dynamic>.from(json['freeze'] as Map),
          )
        : null;
    final freezeFromStreak = streakMap['freezesAvailable'] != null
        ? StreakFreezeInfo(
            freezesAvailable: _int(streakMap['freezesAvailable']),
            freezeCostPoints: 100,
          )
        : null;

    return StreakScoreModel(
      streak: StreakInfo.fromJson(streakMap),
      scores: ScoresInfo.fromJson(scoresMap),
      milestones: milestones,
      calendarDays: json['calendarDays'] is List
          ? (json['calendarDays'] as List)
              .whereType<Map>()
              .map((e) => StreakCalendarDay.fromJson(
                    Map<String, dynamic>.from(e),
                  ))
              .toList()
          : const [],
      achievements: achievements,
      completedInterests: json['completedInterests'] is List
          ? (json['completedInterests'] as List)
              .whereType<Map>()
              .map((e) => CompletedInterest.fromJson(
                    Map<String, dynamic>.from(e),
                  ))
              .toList()
          : const [],
      freeze: freezeFromRoot ?? freezeFromStreak,
      dailySparkGoal: _int(json['dailySparkGoal'], fallback: 5),
      dailySparksCompleted: _int(json['dailySparksCompleted']),
    );
  }
}

int _int(dynamic value, {int fallback = 0}) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? fallback;
}
