class AchievementProgress {
  const AchievementProgress({
    required this.id,
    required this.type,
    required this.label,
    required this.progress,
    required this.target,
    required this.progressText,
    required this.percentage,
    required this.completed,
    required this.claimable,
    required this.claimed,
    this.rewardPoints,
    this.claimedAt,
    this.isActiveGoal = false,
  });

  final String id;
  final String type;
  final String label;
  final int progress;
  final int target;
  final String progressText;
  final int percentage;
  final bool completed;
  final bool claimable;
  final bool claimed;
  final int? rewardPoints;
  final String? claimedAt;
  final bool isActiveGoal;

  double get progressValue =>
      target > 0 ? (progress / target).clamp(0.0, 1.0) : 0.0;

  factory AchievementProgress.fromJson(Map<String, dynamic> json) {
    final type = json['type']?.toString() ?? '';
    var progress = _int(json['progress']);
    var target = _int(json['target']);

    if (type == 'episode') {
      if (progress <= 0) {
        progress = _int(json['completedEpisodes']);
      }
      if (target <= 0) {
        target = _int(json['totalEpisodes']);
      }
    }

    final parsedPercentage = _int(json['percentage'], fallback: -1);
    final percentage = parsedPercentage >= 0
        ? parsedPercentage
        : (target > 0 ? ((progress / target) * 100).round() : 0);

    final label = json['label']?.toString() ??
        (type == 'episode' ? 'Series Progress' : '');

    return AchievementProgress(
      id: json['id']?.toString() ?? json['seriesId']?.toString() ?? '',
      type: type,
      label: label,
      progress: progress,
      target: target,
      progressText: json['progressText']?.toString() ?? '',
      percentage: percentage,
      completed: json['completed'] == true,
      claimable: json['claimable'] == true,
      claimed: json['claimed'] == true,
      rewardPoints: json['rewardPoints'] != null
          ? _int(json['rewardPoints'])
          : null,
      claimedAt: json['claimedAt']?.toString(),
      isActiveGoal: json['isActiveGoal'] == true,
    );
  }
}

int _int(dynamic value, {int fallback = 0}) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? fallback;
}
