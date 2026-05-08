/// Returned when leaving the quiz flow so callers can update local UI
/// immediately (e.g. mark quizProgress completed).
class QuizExitSnapshot {
  const QuizExitSnapshot({
    required this.storyIdeaId,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.isCompleted,
    this.completedAt,
  });

  final String storyIdeaId;
  final int totalQuestions;
  final int correctAnswers;
  final bool isCompleted;
  final String? completedAt;
}

