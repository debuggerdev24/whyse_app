import 'package:flutter/material.dart';
import 'package:redstreakapp/core/helper/log_helper.dart';
import 'package:redstreakapp/models/gamification/achievement_progress_model.dart';
import 'package:redstreakapp/models/gamification/activity_rewards.dart';
import 'package:redstreakapp/models/gamification/leaderboard_model.dart';
import 'package:redstreakapp/models/gamification/score_award_result.dart';
import 'package:redstreakapp/models/gamification/score_event_config.dart';
import 'package:redstreakapp/models/gamification/streak_score_model.dart';
import 'package:redstreakapp/services/gamification/gamification_api_service.dart';

class SparkSessionSummary {
  const SparkSessionSummary({
    required this.sparksCompleted,
    required this.pointsEarned,
    required this.events,
    this.achievementProgress,
    this.interestAchievementProgress,
  });

  final int sparksCompleted;
  final int pointsEarned;
  final List<ScoreEventAward> events;
  final AchievementProgress? achievementProgress;
  final AchievementProgress? interestAchievementProgress;

  bool get isEmpty => sparksCompleted <= 0 && pointsEarned <= 0;
}

class GamificationProvider extends ChangeNotifier {
  GamificationProvider(this._api);

  final GamificationApiService _api;

  StreakScoreModel? streakScore;
  LeaderboardModel? friendsLeaderboard;
  LeaderboardModel? globalLeaderboard;

  bool isLoadingStreakScore = false;
  bool isLoadingLeaderboard = false;
  bool isBuyingFreeze = false;
  String? claimingAchievementId;
  String? streakScoreError;
  String? leaderboardError;
  String? freezeBuyError;
  String? claimAchievementError;

  int _sessionSparkPoints = 0;
  int _sessionApiPointsAwarded = 0;
  int _sessionSparksCompleted = 0;
  final List<ScoreEventAward> _sessionSparkEvents = [];
  AchievementProgress? _sessionAchievementProgress;
  AchievementProgress? _sessionInterestAchievementProgress;
  ActivityRewards? _pendingEpisodeRewards;

  ActivityRewards? consumePendingEpisodeRewards() {
    final rewards = _pendingEpisodeRewards;
    _pendingEpisodeRewards = null;
    return rewards;
  }

  void stashPendingEpisodeRewards(ActivityRewards? rewards) {
    _pendingEpisodeRewards = rewards;
  }
  int get sessionSparksCompleted => _sessionSparksCompleted;

  AchievementProgress? get currentSparkAchievement {
    final fromSession = _sessionAchievementProgress;
    if (fromSession != null) return fromSession;
    final spark = streakScore?.achievements.spark;
    if (spark == null || spark.isEmpty) return null;
    return spark.firstWhere(
      (a) => !a.claimed,
      orElse: () => spark.first,
    );
  }

  AchievementProgress? get currentInterestAchievement {
    final fromSession = _sessionInterestAchievementProgress;
    if (fromSession != null) return fromSession;
    final interest = streakScore?.achievements.interest;
    if (interest == null || interest.isEmpty) return null;
    return interest.first;
  }

  AchievementProgress? get currentActiveStreakGoal =>
      streakScore?.achievements.activeStreakGoal;

  SparkSessionSummary? consumeSparkSessionSummary() {
    if (_sessionSparksCompleted <= 0 &&
        _sessionSparkPoints <= 0 &&
        _sessionApiPointsAwarded <= 0) {
      return null;
    }
    final points = _sessionApiPointsAwarded > 0
        ? _sessionApiPointsAwarded
        : _sessionSparkPoints;
    final summary = SparkSessionSummary(
      sparksCompleted: _sessionSparksCompleted,
      pointsEarned: points,
      events: List<ScoreEventAward>.from(_sessionSparkEvents),
      achievementProgress: _sessionAchievementProgress,
      interestAchievementProgress: _sessionInterestAchievementProgress,
    );
    _sessionSparkPoints = 0;
    _sessionApiPointsAwarded = 0;
    _sessionSparksCompleted = 0;
    _sessionSparkEvents.clear();
    _sessionAchievementProgress = null;
    _sessionInterestAchievementProgress = null;
    return summary;
  }

  void startSparkSession() {
    _sessionSparkPoints = 0;
    _sessionApiPointsAwarded = 0;
    _sessionSparksCompleted = 0;
    _sessionSparkEvents.clear();
    _sessionAchievementProgress = null;
    _sessionInterestAchievementProgress = null;
  }

  void recordSparkCompletion(ScoreAwardResult? awards) {
    _sessionSparksCompleted++;

    final parsed = awards ?? ScoreAwardResult.empty();
    if (parsed.rewards != null) {
      applySparkInteractionRewards(parsed);
      return;
    }

    var earned = parsed.pointsFor(ScoreEventConfig.sparkCompleted);
    if (earned <= 0) earned = parsed.totalPointsEarned;
    if (earned <= 0) {
      earned = ScoreEventConfig.fallbackFor(ScoreEventConfig.sparkCompleted);
    }
    _sessionSparkPoints += earned;

    if (parsed.events.isNotEmpty) {
      _sessionSparkEvents.addAll(parsed.events);
    } else {
      _sessionSparkEvents.add(
        ScoreEventAward(
          eventType: ScoreEventConfig.sparkCompleted,
          points: earned,
        ),
      );
    }
    notifyListeners();
  }

  void applySparkInteractionRewards(ScoreAwardResult awards) {
    final rewards = awards.rewards;
    if (rewards == null) return;

    if (rewards.pointsAwarded > 0) {
      _sessionApiPointsAwarded += rewards.pointsAwarded;
    }

    if (rewards.achievementProgress != null) {
      _sessionAchievementProgress = rewards.achievementProgress;
    }
    if (rewards.interestAchievementProgress != null) {
      _sessionInterestAchievementProgress = rewards.interestAchievementProgress;
    }

    for (final event in awards.events) {
      _sessionSparkEvents.removeWhere((e) => e.eventType == event.eventType);
      _sessionSparkEvents.add(event);
    }
    notifyListeners();
  }

  Future<void> fetchStreakScore({int? month, int? year, bool force = false}) async {
    if (isLoadingStreakScore && !force) return;
    isLoadingStreakScore = true;
    streakScoreError = null;
    notifyListeners();

    final result = await _api.getStreakScore(month: month, year: year);
    result.fold(
      (error) {
        streakScoreError = error.errorMsg;
        Logger.error('fetchStreakScore failed: ${error.errorMsg}');
      },
      (data) {
        if (month != null && year != null && streakScore != null) {
          streakScore = streakScore!.mergeCalendarDays(data.calendarDays);
        } else {
          streakScore = data;
        }
        streakScoreError = null;
      },
    );

    isLoadingStreakScore = false;
    notifyListeners();
  }

  Future<void> fetchLeaderboard({
    String scope = 'friends',
    int page = 1,
    int limit = 20,
  }) async {
    isLoadingLeaderboard = true;
    leaderboardError = null;
    notifyListeners();

    final result = await _api.getLeaderboard(
      scope: scope,
      page: page,
      limit: limit,
    );

    result.fold(
      (error) {
        leaderboardError = error.errorMsg;
        Logger.error('fetchLeaderboard failed: ${error.errorMsg}');
      },
      (data) {
        if (scope == 'friends') {
          friendsLeaderboard = data;
        } else {
          globalLeaderboard = data;
        }
        leaderboardError = null;
      },
    );

    isLoadingLeaderboard = false;
    notifyListeners();
  }

  Future<bool> buyStreakFreeze({int quantity = 1}) async {
    if (isBuyingFreeze) return false;
    isBuyingFreeze = true;
    freezeBuyError = null;
    notifyListeners();

    final result = await _api.buyStreakFreeze(quantity: quantity);
    var success = false;
    await result.fold(
      (error) async {
        freezeBuyError = error.errorMsg;
        Logger.error('buyStreakFreeze failed: ${error.errorMsg}');
      },
      (_) async {
        success = true;
        await fetchStreakScore(force: true);
      },
    );

    isBuyingFreeze = false;
    notifyListeners();
    return success;
  }

  Future<bool> claimAchievement(String achievementId) async {
    if (claimingAchievementId != null) return false;
    claimingAchievementId = achievementId;
    claimAchievementError = null;
    notifyListeners();

    final result = await _api.claimAchievement(achievementId: achievementId);
    var success = false;
    await result.fold(
      (error) async {
        claimAchievementError = error.errorMsg;
        Logger.error('claimAchievement failed: ${error.errorMsg}');
      },
      (_) async {
        success = true;
        await fetchStreakScore(force: true);
      },
    );

    claimingAchievementId = null;
    notifyListeners();
    return success;
  }

  Future<ScoreAwardResult?> completeEpisodeReading({
    required String storyIdeaId,
    required int lastPageIndex,
  }) async {
    return _saveReadingPageProgress(
      storyIdeaId: storyIdeaId,
      lastPageIndex: lastPageIndex,
    );
  }

  /// Saves reading progress when the user finishes the last page (quiz still required).
  Future<void> finishReadingSession({
    required String storyIdeaId,
    required int lastPageIndex,
  }) async {
    await _saveReadingPageProgress(
      storyIdeaId: storyIdeaId,
      lastPageIndex: lastPageIndex,
    );
  }

  /// Marks the episode as read after finishing reading and returns gamification rewards.
  Future<ScoreAwardResult?> completeEpisodeAfterReading({
    required String storyIdeaId,
  }) =>
      completeEpisodeAfterQuiz(storyIdeaId: storyIdeaId);

  /// Marks the episode as read (fires series_episode_completed) and returns rewards.
  Future<ScoreAwardResult?> completeEpisodeAfterQuiz({
    required String storyIdeaId,
  }) async {
    final result = await _api.markEpisodeAsRead(storyIdeaId: storyIdeaId);
    return result.fold(
      (error) {
        Logger.error('markAsRead failed: ${error.errorMsg}');
        return null;
      },
      (awards) async {
        stashPendingEpisodeRewards(awards.rewards);
        if (awards.totalPointsEarned > 0 || awards.rewards != null) {
          await fetchStreakScore(force: true);
        }
        return awards;
      },
    );
  }

  Future<ScoreAwardResult?> _saveReadingPageProgress({
    required String storyIdeaId,
    required int lastPageIndex,
  }) async {
    final progressResult = await _api.updatePageProgress(
      storyIdeaId: storyIdeaId,
      pageIndex: lastPageIndex,
    );

    return progressResult.fold(
      (error) {
        Logger.error('updatePageProgress failed: ${error.errorMsg}');
        return null;
      },
      (awards) => awards,
    );
  }

  int resolveQuizCompletionPoints(ScoreAwardResult? awards) {
    if (awards == null) {
      return ScoreEventConfig.fallbackFor(ScoreEventConfig.episodeQuizCompleted);
    }
    final quizPts = awards.pointsFor(ScoreEventConfig.episodeQuizCompleted);
    if (quizPts > 0) return quizPts;
    final apiPoints = awards.rewards?.pointsAwarded ?? 0;
    if (apiPoints > 0) return apiPoints;
    if (awards.totalPointsEarned > 0) return awards.totalPointsEarned;
    return 0;
  }

  int resolveEpisodeAndQuizPoints(ScoreAwardResult? awards) {
    final apiPoints = awards?.rewards?.pointsAwarded ?? 0;
    if (apiPoints > 0) return apiPoints;

    if (awards == null) {
      return ScoreEventConfig.fallbackFor(
            ScoreEventConfig.seriesEpisodeCompleted,
          ) +
          ScoreEventConfig.fallbackFor(ScoreEventConfig.episodeQuizCompleted);
    }
    final episodePts = awards.pointsFor(
      ScoreEventConfig.seriesEpisodeCompleted,
    );
    final quizPts = awards.pointsFor(ScoreEventConfig.episodeQuizCompleted);
    final combined = episodePts + quizPts;
    if (combined > 0) return combined;
    if (awards.totalPointsEarned > 0) return awards.totalPointsEarned;
    return 0;
  }

  Future<ScoreAwardResult?> handleActivityResponse(dynamic raw) async {
    final awards = ScoreAwardResult.parse(raw);
    if (awards.totalPointsEarned > 0 ||
        awards.events.isNotEmpty ||
        awards.rewards != null) {
      await fetchStreakScore(force: true);
    }
    return awards;
  }

  ScoreAwardResult mergeAwardResults(
    ScoreAwardResult? primary,
    ScoreAwardResult? secondary,
  ) {
    return _mergeAwards([
      primary ?? ScoreAwardResult.empty(),
      secondary ?? ScoreAwardResult.empty(),
    ]);
  }

  ScoreAwardResult mergeWithFallback(ScoreAwardResult awards) {
    if (awards.events.isNotEmpty) return awards;
    return awards;
  }

  int resolveEpisodePoints(ScoreAwardResult? awards) {
    final apiPoints = awards?.rewards?.pointsAwarded ?? 0;
    if (apiPoints > 0) return apiPoints;

    if (awards == null) {
      return ScoreEventConfig.fallbackFor(
        ScoreEventConfig.seriesEpisodeCompleted,
      );
    }
    final episodePts = awards.pointsFor(
      ScoreEventConfig.seriesEpisodeCompleted,
    );
    if (episodePts > 0) return episodePts;
    if (awards.totalPointsEarned > 0) return awards.totalPointsEarned;
    return 0;
  }

  int resolveQuizPoints(ScoreAwardResult? awards) {
    if (awards == null) {
      return ScoreEventConfig.fallbackFor(
        ScoreEventConfig.episodeQuizCompleted,
      );
    }
    final quizPts = awards.pointsFor(ScoreEventConfig.episodeQuizCompleted);
    if (quizPts > 0) return quizPts;
    return ScoreEventConfig.fallbackFor(ScoreEventConfig.episodeQuizCompleted);
  }

  ScoreAwardResult _mergeAwards(List<ScoreAwardResult> list) {
    final byType = <String, ScoreEventAward>{};
    ActivityRewards? rewards;
    for (final result in list.reversed) {
      rewards ??= result.rewards;
    }
    for (final result in list) {
      for (final event in result.events) {
        byType[event.eventType] = event;
      }
    }
    final events = byType.values.toList();
    var total = events.fold(0, (sum, e) => sum + e.points);
    final awarded = rewards?.pointsAwarded ?? 0;
    if (awarded > total) total = awarded;
    return ScoreAwardResult(
      events: events,
      totalPointsEarned: total,
      rewards: rewards,
    );
  }
}
