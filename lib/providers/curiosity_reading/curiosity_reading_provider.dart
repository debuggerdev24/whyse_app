import 'dart:async';

import 'package:flutter/material.dart';
import 'package:redstreakapp/core/helper/log_helper.dart';
import 'package:redstreakapp/core/network/base_api_service.dart';
import 'package:redstreakapp/models/curiosity_reading/curiosity_reading_model.dart';
import 'package:redstreakapp/models/explore/explore_models.dart';
import 'package:redstreakapp/models/explore/spark_reading_mapper.dart';
import 'package:redstreakapp/models/gamification/score_award_result.dart';
import 'package:redstreakapp/services/curiosity_reading/curiosity_reading_service.dart';

typedef ExploreSparkLoadMore =
    Future<({List<ExploreSparkItem> items, ExplorePagination pagination})>
    Function();

class _ExploreSparkSession {
  _ExploreSparkSession({
    required this.loadMoreItems,
    required this.pagination,
  });

  final ExploreSparkLoadMore loadMoreItems;
  ExplorePagination pagination;
}

class CuriosityReadingProvider extends ChangeNotifier {
  CuriosityReadingProvider(this._service);

  static const int readThresholdMs = 10000;

  final CuriosityReadingService _service;

  bool isGettingCuriosityReading = false;
  bool isLoadingMoreReading = false;
  bool isLoadingReadingBody = false;
  String? currentReadingError;
  CuriosityReadingModel? curiosityReading;

  bool _openedFromExplore = false;
  bool get openedFromExplore => _openedFromExplore;

  _ExploreSparkSession? _exploreSession;

  int _currentIndex = 0;
  int get currentIndex => _currentIndex;

  bool _isReadingScreenActive = false;
  bool get isReadingScreenActive => _isReadingScreenActive;

  String? _sessionId;
  String? _activeReadingId;
  DateTime? _readingOpenedAt;
  int _scrollDepthPercent = 0;

  /// Called when a spark is marked COMPLETED (swipe away or exit).
  void Function(ScoreAwardResult award)? onSparkAwarded;

  /// Called when the interact API returns rewards for a completed spark.
  void Function(ScoreAwardResult award)? onSparkRewardsFromApi;

  final List<Future<ScoreAwardResult?>> _pendingInteractions = [];

  Reading? get currentReading {
    final readings = curiosityReading?.data.readings;
    if (readings == null || readings.isEmpty) return null;
    if (_currentIndex < 0 || _currentIndex >= readings.length) return null;
    return readings[_currentIndex];
  }

  void markReadingScreenActive() {
    _isReadingScreenActive = true;
  }

  void markReadingScreenInactive() {
    _isReadingScreenActive = false;
  }

  void updateScrollDepth(int percent) {
    _scrollDepthPercent = percent.clamp(0, 100);
  }

  void onReadingDisplayed(String readingId) {
    if (_activeReadingId == readingId) return;

    _ensureSessionId();
    _activeReadingId = readingId;
    _readingOpenedAt = DateTime.now();
    _scrollDepthPercent = 0;

    unawaited(
      _sendInteraction(
        readingId: readingId,
        eventType: 'OPENED',
        readDurationMs: 0,
        scrollDepthPercent: 0,
      ),
    );
  }

  void onLeaveReadingScreen() {
    _finalizeActiveReadingLocally();
  }

  Future<void> awaitPendingInteractions({
    Duration timeout = const Duration(milliseconds: 800),
  }) async {
    if (_pendingInteractions.isEmpty) return;
    final pending = List<Future<ScoreAwardResult?>>.from(_pendingInteractions);
    try {
      await Future.wait(pending).timeout(timeout);
    } catch (_) {
      // Show summary with whatever rewards arrived before timeout.
    }
  }

  void setCurrentIndex(int value) {
    if (value == _currentIndex) return;

    if (_activeReadingId != null) {
      _finalizeActiveReadingLocally();
    }

    _currentIndex = value;
    if (_shouldLoadMoreReading()) {
      Logger.info('Loading more curiosity readings...');
      unawaited(loadMoreReading());
    }
    notifyListeners();
  }

  void nextReading() {
    _finalizeActiveReadingLocally();

    final length = curiosityReading?.data.readings.length ?? 0;
    if (length == 0) return;

    if (_currentIndex < length - 1) {
      _currentIndex++;
      notifyListeners();
      unawaited(_ensureCurrentReadingBody());
      if (_shouldLoadMoreReading()) {
        Logger.info('Loading more curiosity readings...');
        unawaited(loadMoreReading());
      }
      return;
    }

    final hasMore = curiosityReading!.data.meta.pagination.hasMore;
    if (!hasMore) return;

    if (isLoadingMoreReading) {
      _currentIndex = length;
      notifyListeners();
      return;
    }

    Logger.info('Loading more curiosity readings...');
    final previousLength = length;
    _currentIndex = length;
    notifyListeners();

    unawaited(() async {
      await loadMoreReading();
      final newLength = curiosityReading?.data.readings.length ?? 0;
      if (newLength > previousLength && _currentIndex == previousLength) {
        _currentIndex++;
        notifyListeners();
        unawaited(_ensureCurrentReadingBody());
      } else {
        _clampIndexToLoadedReadings();
        notifyListeners();
      }
    }());
  }

  void previousReading() {
    if (_currentIndex <= 0) return;

    _finalizeActiveReadingLocally();
    _currentIndex--;
    notifyListeners();
    unawaited(_ensureCurrentReadingBody());
  }

  void beginExploreSession({
    required List<ExploreSparkItem> items,
    required int startIndex,
    required ExplorePagination pagination,
    required ExploreSparkLoadMore loadMoreItems,
  }) {
    if (items.isEmpty) return;

    _openedFromExplore = true;
    _exploreSession = _ExploreSparkSession(
      loadMoreItems: loadMoreItems,
      pagination: pagination,
    );

    currentReadingError = null;
    isGettingCuriosityReading = false;

    final readings =
        items.map((item) => readingFromSparkJson(item.rawJson)).toList();
    curiosityReading = CuriosityReadingModel(
      success: true,
      data: CuriosityReadingData(
        readings: readings,
        meta: readingMetaFromExplorePagination(pagination),
      ),
    );
    _currentIndex = startIndex.clamp(0, readings.length - 1);
    _sessionId = 'explore-spark-${DateTime.now().millisecondsSinceEpoch}';

    final reading = currentReading;
    final needsBody =
        reading != null &&
        (!reading.hasBody || reading.body.article.trim().isEmpty);
    isLoadingReadingBody = needsBody;
    notifyListeners();
  }

  Future<void> loadExploreSessionBody() async {
    if (!_openedFromExplore || !isLoadingReadingBody) return;
    await _ensureCurrentReadingBody();
  }

  Future<void> _ensureCurrentReadingBody() async {
    final reading = currentReading;
    if (reading == null) return;
    if (reading.hasBody && reading.body.article.trim().isNotEmpty) return;

    isLoadingReadingBody = true;
    notifyListeners();

    final enriched = await _loadReadingBody(reading);
    _replaceReadingAt(_currentIndex, enriched);

    isLoadingReadingBody = false;
    notifyListeners();
  }

  Future<Reading> _loadReadingBody(Reading reading) async {
    final result = await _service.getReadingById(readingId: reading.id);
    return result.fold(
      (error) {
        Logger.error('Failed to load spark body for ${reading.id}: ${error.errorMsg}');
        if (reading.body.article.trim().isNotEmpty) return reading;
        return reading.copyWith(
          body: ReadingBody(
            article: reading.question,
            keyFacts: const [],
            quote: '',
            readingLevel: '',
          ),
          hasBody: true,
        );
      },
      (enriched) => enriched,
    );
  }

  void _replaceReadingAt(int index, Reading reading) {
    final current = curiosityReading;
    if (current == null) return;

    final readings = [...current.data.readings];
    if (index < 0 || index >= readings.length) return;
    readings[index] = reading;
    curiosityReading = current.copyWith(
      data: current.data.copyWith(readings: readings),
    );
  }

  void completeExploreSession() {
    _openedFromExplore = false;
    _exploreSession = null;
    _currentIndex = 0;
    _activeReadingId = null;
    _readingOpenedAt = null;
    _scrollDepthPercent = 0;
    isLoadingReadingBody = false;
    isLoadingMoreReading = false;
  }

  Future<void> exitExploreSessionAndRestoreHome() async {
    completeExploreSession();
    isGettingCuriosityReading = true;
    notifyListeners();
    await _fetchCuriosityReading();
    isGettingCuriosityReading = false;
    notifyListeners();
  }

  Future<void> retryLoadCuriosityReading() async {
    currentReadingError = null;
    await getCuriosityReading();
  }

  Future<void> getCuriosityReading({int page = 1, int limit = 10}) async {
    isGettingCuriosityReading = true;
    notifyListeners();

    await _fetchCuriosityReading(page: page, limit: limit);

    isGettingCuriosityReading = false;
    notifyListeners();
  }

  Future<void> _fetchCuriosityReading({int page = 1, int limit = 10}) async {
    final result = await _service.getCuriosityReading(page: page, limit: limit);

    result.fold(
      (exception) {
        Logger.error('Failed to fetch curiosity readings: $exception');
        currentReadingError = _friendlyErrorMessage(exception);
      },
      (readings) {
        currentReadingError = null;
        curiosityReading = readings;
      },
    );
  }

  String _friendlyErrorMessage(ApiException exception) {
    final message = exception.errorMsg.trim();
    if (message.isNotEmpty) return message;
    return 'We couldn\'t load curiosity readings right now. Please try again.';
  }

  void _resetReadingState() {
    _currentIndex = 0;
    isLoadingMoreReading = false;
    isLoadingReadingBody = false;
    currentReadingError = null;
    curiosityReading = null;
    _sessionId = null;
    _activeReadingId = null;
    _readingOpenedAt = null;
    _scrollDepthPercent = 0;
    _exploreSession = null;
    _openedFromExplore = false;
  }

  void resetForNewSession() {
    _resetReadingState();
    _isReadingScreenActive = false;
    isGettingCuriosityReading = false;
    notifyListeners();
  }

  Future<void> refreshFromHome() async {
    if (_isReadingScreenActive) return;

    _resetReadingState();
    isGettingCuriosityReading = true;
    notifyListeners();

    await _fetchCuriosityReading();

    isGettingCuriosityReading = false;
    notifyListeners();
  }

  Future<void> loadMoreReading() async {
    if (_exploreSession != null) {
      await _loadMoreExploreReading();
      return;
    }

    isLoadingMoreReading = true;
    notifyListeners();

    final result = await _service.getCuriosityReading(
      page: (curiosityReading!.data.meta.pagination.page + 1),
      limit: 15,
    );
    result.fold(
      (exception) {
        Logger.error('Failed to load more curiosity readings: $exception');
        _clampIndexToLoadedReadings();
      },
      (readings) {
        final current = curiosityReading!;
        curiosityReading = current.copyWith(
          data: current.data.copyWith(
            readings: [...current.data.readings, ...readings.data.readings],
            meta: current.data.meta.copyWith(
              pagination: readings.data.meta.pagination,
            ),
          ),
        );
      },
    );
    isLoadingMoreReading = false;
    notifyListeners();
  }

  Future<void> _loadMoreExploreReading() async {
    final session = _exploreSession;
    if (session == null || !session.pagination.hasMore) return;

    isLoadingMoreReading = true;
    notifyListeners();

    try {
      final result = await session.loadMoreItems();
      if (result.items.isEmpty) {
        session.pagination = result.pagination;
        _syncExplorePagination(result.pagination);
        return;
      }

      final newReadings = result.items
          .map((item) => readingFromSparkJson(item.rawJson))
          .toList();
      final current = curiosityReading!;
      curiosityReading = current.copyWith(
        data: current.data.copyWith(
          readings: [...current.data.readings, ...newReadings],
        ),
      );

      session.pagination = result.pagination;
      _syncExplorePagination(result.pagination);
    } catch (error, stackTrace) {
      Logger.error('Failed to load more explore sparks: $error\n$stackTrace');
      _clampIndexToLoadedReadings();
    } finally {
      isLoadingMoreReading = false;
      notifyListeners();
    }
  }

  void _syncExplorePagination(ExplorePagination pagination) {
    final current = curiosityReading;
    if (current == null) return;
    curiosityReading = current.copyWith(
      data: current.data.copyWith(
        meta: readingMetaFromExplorePagination(pagination),
      ),
    );
  }

  void _clampIndexToLoadedReadings() {
    final length = curiosityReading?.data.readings.length ?? 0;
    if (length == 0) {
      _currentIndex = 0;
      return;
    }
    if (_currentIndex >= length) {
      _currentIndex = length - 1;
    }
  }

  bool _shouldLoadMoreReading() {
    if (curiosityReading == null) return false;
    if (curiosityReading!.data.meta.pagination.hasMore == false) return false;

    return (curiosityReading!.data.readings.length - _currentIndex) <= 5;
  }

  void _ensureSessionId() {
    _sessionId ??= 'curiosity-${DateTime.now().millisecondsSinceEpoch}';
  }

  void _finalizeActiveReadingLocally() {
    final readingId = _activeReadingId;
    final openedAt = _readingOpenedAt;
    if (readingId == null || openedAt == null) return;

    final durationMs = DateTime.now().difference(openedAt).inMilliseconds;
    final isRead = durationMs >= readThresholdMs;
    final depth = _scrollDepthPercent;

    _activeReadingId = null;
    _readingOpenedAt = null;
    _scrollDepthPercent = 0;

    if (isRead) {
      onSparkAwarded?.call(ScoreAwardResult.empty());
    }

    unawaited(
      _sendInteraction(
        readingId: readingId,
        eventType: isRead ? 'COMPLETED' : 'SKIPPED',
        readDurationMs: isRead ? durationMs : null,
        scrollDepthPercent: isRead ? depth : null,
      ).then((award) {
        if (award != null && isRead) {
          onSparkRewardsFromApi?.call(award);
          if (award.totalPointsEarned > 0) {
            Logger.info(
              'Spark $readingId API awarded ${award.totalPointsEarned} pts',
            );
          }
        }
      }),
    );
  }

  Future<ScoreAwardResult?> _sendInteraction({
    required String readingId,
    required String eventType,
    int? readDurationMs,
    int? scrollDepthPercent,
  }) async {
    _ensureSessionId();

    final future = _service
        .recordReadingInteraction(
          readingId: readingId,
          eventType: eventType,
          sessionId: _sessionId!,
          readDurationMs: readDurationMs,
          scrollDepthPercent: scrollDepthPercent,
        )
        .then(
          (result) => result.fold(
            (exception) {
              Logger.error(
                'Curiosity reading $eventType failed for $readingId: $exception',
              );
              return null;
            },
            (raw) {
              Logger.info('Curiosity reading $eventType recorded for $readingId');
              return ScoreAwardResult.parse(raw);
            },
          ),
        );

    _pendingInteractions.add(future);
    future.whenComplete(() => _pendingInteractions.remove(future));
    return future;
  }
}
