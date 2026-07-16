import 'package:dartz/dartz.dart';
import 'package:redstreakapp/core/network/base_api_service.dart';
import 'package:redstreakapp/core/network/end_points.dart';
import 'package:redstreakapp/models/gamification/achievement_claim_result.dart';
import 'package:redstreakapp/models/gamification/leaderboard_model.dart';
import 'package:redstreakapp/models/gamification/score_award_result.dart';
import 'package:redstreakapp/models/gamification/streak_score_model.dart';

class GamificationApiService {
  GamificationApiService._();

  static final GamificationApiService instance = GamificationApiService._();
  static final _api = BaseApiHelper(enableApiLogging: false);

  Future<Either<ApiException, StreakScoreModel>> getStreakScore({
    int? month,
    int? year,
  }) async {
    final path = month != null && year != null
        ? EndPoints.streakScoreForMonth(month: month, year: year)
        : EndPoints.streakScore;

    return _api.get<StreakScoreModel>(
      path,
      parser: (raw) {
        final map = raw is Map
            ? Map<String, dynamic>.from(raw)
            : <String, dynamic>{};
        final data = map['data'] is Map
            ? Map<String, dynamic>.from(map['data'] as Map)
            : map;
        return StreakScoreModel.fromJson(data);
      },
    );
  }

  Future<Either<ApiException, LeaderboardModel>> getLeaderboard({
    String scope = 'global',
    int page = 1,
    int limit = 20,
  }) async {
    return _api.get<LeaderboardModel>(
      EndPoints.leaderboard(scope: scope, page: page, limit: limit),
      parser: LeaderboardModel.fromJson,
    );
  }

  Future<Either<ApiException, ScoreAwardResult>> markEpisodeAsRead({
    required String storyIdeaId,
  }) async {
    return _api.post<ScoreAwardResult>(
      EndPoints.markAsRead(storyIdeaId: storyIdeaId),
      parser: ScoreAwardResult.parse,
    );
  }

  Future<Either<ApiException, ScoreAwardResult>> updatePageProgress({
    required String storyIdeaId,
    required int pageIndex,
  }) async {
    return _api.post<ScoreAwardResult>(
      EndPoints.pageProgress(storyIdeaId: storyIdeaId),
      data: {'pageIndex': pageIndex},
      parser: ScoreAwardResult.parse,
    );
  }

  Future<Either<ApiException, Map<String, dynamic>>> buyStreakFreeze({
    int quantity = 1,
  }) async {
    return _api.post<Map<String, dynamic>>(
      EndPoints.buyStreakFreeze,
      data: {'quantity': quantity},
      parser: (raw) => raw is Map
          ? Map<String, dynamic>.from(raw)
          : <String, dynamic>{},
    );
  }

  Future<Either<ApiException, AchievementClaimResult>> claimAchievement({
    required String achievementId,
  }) async {
    return _api.post<AchievementClaimResult>(
      EndPoints.claimAchievement(achievementId: achievementId),
      parser: AchievementClaimResult.fromJson,
    );
  }
}
