/// Returned when leaving [CreatedStoryReadingScreen] so the ideas list can
/// update progress immediately without waiting for a server refetch.
class ReadingExitSnapshot {
  const ReadingExitSnapshot({
    required this.storyIdeaId,
    required this.lastPageIndex,
    required this.pageCount,
  });

  final String storyIdeaId;
  final int lastPageIndex;
  final int pageCount;

  bool get hasValidCounts =>
      pageCount > 0 &&
      lastPageIndex >= 0 &&
      lastPageIndex < pageCount;
}
