import 'package:flutter/material.dart';
import 'package:redstreakapp/core/helper/log_helper.dart';
import 'package:redstreakapp/core/network/base_api_service.dart';
import 'package:redstreakapp/models/curiosity_reading/curiosity_reading_model.dart';
import 'package:redstreakapp/services/curiosity_reading/curiosity_reading_service.dart';

class CuriosityReadingProvider extends ChangeNotifier {
  CuriosityReadingProvider(this._service);

  static const int readThresholdMs = 10000;

  final CuriosityReadingService _service;

  bool isGettingCuriosityReading = false;
  bool isLoadingMoreReading = false;
  String? currentReadingError;
  CuriosityReadingModel? curiosityReading;

  int _currentIndex = 0;
  int get currentIndex => _currentIndex;

  bool _isReadingScreenActive = false;
  bool get isReadingScreenActive => _isReadingScreenActive;

  String? _sessionId;
  String? _activeReadingId;
  DateTime? _readingOpenedAt;
  int _scrollDepthPercent = 0;

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

    _sendInteraction(
      readingId: readingId,
      eventType: 'OPENED',
      readDurationMs: 0,
      scrollDepthPercent: 0,
    );
  }

  Future<void> onLeaveReadingScreen() async {
    await _finalizeActiveReading();
    _activeReadingId = null;
    _readingOpenedAt = null;
    _scrollDepthPercent = 0;
  }

  Future<void> setCurrentIndex(int value) async {
    if (value == _currentIndex) return;

    if (_activeReadingId != null) {
      await _finalizeActiveReading();
    }

    _currentIndex = value;
    if (_shouldLoadMoreReading()) {
      Logger.info('Loading more curiosity readings...');
      loadMoreReading();
    }
    notifyListeners();
  }

  Future<void> nextReading() async {
    await _finalizeActiveReading();

    final length = curiosityReading?.data.readings.length ?? 0;
    if (length == 0) return;

    if (_currentIndex < length - 1) {
      _currentIndex++;
      _activeReadingId = null;
      notifyListeners();
      if (_shouldLoadMoreReading()) {
        Logger.info('Loading more curiosity readings...');
        loadMoreReading();
      }
      return;
    }

    final hasMore = curiosityReading!.data.meta.pagination.hasMore;
    if (!hasMore) return;

    if (isLoadingMoreReading) {
      _currentIndex = length;
    } else {
      Logger.info('Loading more curiosity readings...');
      final previousLength = length;
      await loadMoreReading();
      final newLength = curiosityReading?.data.readings.length ?? 0;
      if (newLength > previousLength) {
        _currentIndex++;
      }
    }

    _activeReadingId = null;
    notifyListeners();
  }

  Future<void> previousReading() async {
    if (_currentIndex <= 0) return;

    await _finalizeActiveReading();
    _currentIndex--;
    _activeReadingId = null;
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
    currentReadingError = null;
    curiosityReading = null;
    _sessionId = null;
    _activeReadingId = null;
    _readingOpenedAt = null;
    _scrollDepthPercent = 0;
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

  Future<void> _finalizeActiveReading() async {
    final readingId = _activeReadingId;
    final openedAt = _readingOpenedAt;
    if (readingId == null || openedAt == null) return;

    final durationMs = DateTime.now().difference(openedAt).inMilliseconds;
    final isRead = durationMs >= readThresholdMs;

    _sendInteraction(
      readingId: readingId,
      eventType: isRead ? 'COMPLETED' : 'SKIPPED',
      readDurationMs: isRead ? durationMs : null,
      scrollDepthPercent: isRead ? _scrollDepthPercent : null,
    );

    _activeReadingId = null;
    _readingOpenedAt = null;
    _scrollDepthPercent = 0;
  }

  void _sendInteraction({
    required String readingId,
    required String eventType,
    int? readDurationMs,
    int? scrollDepthPercent,
  }) {
    _ensureSessionId();

    _service
        .recordReadingInteraction(
          readingId: readingId,
          eventType: eventType,
          sessionId: _sessionId!,
          readDurationMs: readDurationMs,
          scrollDepthPercent: scrollDepthPercent,
        )
        .then((result) {
          result.fold(
            (exception) => Logger.error(
              'Curiosity reading $eventType failed for $readingId: $exception',
            ),
            (_) => Logger.info(
              'Curiosity reading $eventType recorded for $readingId',
            ),
          );
        });
  }
}
