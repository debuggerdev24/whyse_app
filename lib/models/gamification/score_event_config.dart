/// Fallback defaults mirroring the backend score-events configuration table.
/// Used only when an API response does not include awarded points.
class ScoreEventConfig {
  ScoreEventConfig._();

  static const String sparkCompleted = 'spark_completed';
  static const String seriesEpisodeCompleted = 'series_episode_completed';
  static const String episodeQuizCompleted = 'episode_quiz_completed';
  static const String seriesCompleted = 'series_completed';
  static const String firstInterestCompleted = 'first_interest_completed';

  static const Map<String, int> defaultPoints = {
    sparkCompleted: 10,
    seriesEpisodeCompleted: 20,
    episodeQuizCompleted: 10,
    seriesCompleted: 100,
    firstInterestCompleted: 25,
  };

  static int fallbackFor(String eventType) =>
      defaultPoints[eventType] ?? 0;
}
