import 'package:flutter/material.dart';
import 'package:redstreakapp/core/helper/log_helper.dart';
import 'package:redstreakapp/models/home/saved_series_model.dart';
import 'package:redstreakapp/services/home/saved_series_service.dart';

class ToggleTopicListResult {
  final bool isInMyList;
  final String topicTitle;
  final String? message;

  const ToggleTopicListResult({
    required this.isInMyList,
    required this.topicTitle,
    this.message,
  });
}

class SavedSeriesProvider extends ChangeNotifier {
  // ─── Toggle cache (shared across all screens) ─────────────────────
  final Set<String> _togglingTopicIds = {};
  final Map<String, bool> _topicIsInMyListOverrides = {};

  bool isTopicListToggling(String topicId) =>
      _togglingTopicIds.contains(topicId);

  /// Checks the in-memory toggle cache first, then the profile preview list.
  bool? topicIsInMyListOverride(String topicId) {
    if (_topicIsInMyListOverrides.containsKey(topicId)) {
      return _topicIsInMyListOverrides[topicId];
    }
    if (savedSeriesList != null) {
      return savedSeriesList!.any((item) => item.topic.id == topicId);
    }
    return null;
  }

  // ─── Profile preview (top 5) ──────────────────────────────────────
  List<SavedSeriesItem>? savedSeriesList;
  bool isSavedSeriesLoading = false;

  Future<void> getMySeriesList() async {
    if (isSavedSeriesLoading) return;
    isSavedSeriesLoading = true;
    notifyListeners();

    final response = await SavedSeriesService.instance.getMyList(limit: 5);

    isSavedSeriesLoading = false;
    response.fold(
      (l) {
        Logger.error(l.errorMsg);
        savedSeriesList ??= [];
      },
      (r) {
        try {
          final data = r["data"];
          if (data is Map && data.containsKey("items")) {
            savedSeriesList = (data["items"] as List)
                .map((e) => SavedSeriesItem.fromJson(e))
                .toList();
          } else {
            savedSeriesList = [];
          }
        } catch (e, stack) {
          Logger.error("Error parsing my-list: $e\n$stack");
          savedSeriesList = [];
        }
      },
    );
    notifyListeners();
  }

  // ─── View All (paginated + search) ────────────────────────────────
  List<SavedSeriesItem> allSavedSeriesList = [];
  bool isAllSavedSeriesLoading = false;
  bool isLoadingMoreSavedSeries = false;
  bool hasMoreSavedSeries = true;
  int _allSavedSeriesPage = 1;
  String _allSavedSeriesSearch = '';

  Future<void> fetchAllSavedSeries({String search = ''}) async {
    if (isAllSavedSeriesLoading) return;
    _allSavedSeriesPage = 1;
    _allSavedSeriesSearch = search;
    isAllSavedSeriesLoading = true;
    allSavedSeriesList = [];
    hasMoreSavedSeries = true;
    notifyListeners();

    try {
      final response = await SavedSeriesService.instance.getMyList(
        page: 1,
        limit: 10,
        search: search,
      );
      response.fold(
        (l) => Logger.error(l.errorMsg),
        (r) {
          final data = r["data"];
          if (data is Map) {
            allSavedSeriesList = ((data["items"] as List?) ?? [])
                .map((e) => SavedSeriesItem.fromJson(e))
                .toList();
            final pagination = data["pagination"] as Map?;
            hasMoreSavedSeries = pagination?["hasMore"] == true;
          }
        },
      );
    } catch (e) {
      Logger.error("fetchAllSavedSeries error: $e");
    } finally {
      isAllSavedSeriesLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchMoreSavedSeries() async {
    if (isLoadingMoreSavedSeries || !hasMoreSavedSeries) return;
    _allSavedSeriesPage++;
    isLoadingMoreSavedSeries = true;
    notifyListeners();

    try {
      final response = await SavedSeriesService.instance.getMyList(
        page: _allSavedSeriesPage,
        limit: 10,
        search: _allSavedSeriesSearch,
      );
      response.fold(
        (l) {
          _allSavedSeriesPage--;
          Logger.error(l.errorMsg);
        },
        (r) {
          final data = r["data"];
          if (data is Map) {
            final newItems = ((data["items"] as List?) ?? [])
                .map((e) => SavedSeriesItem.fromJson(e))
                .toList();
            allSavedSeriesList.addAll(newItems);
            final pagination = data["pagination"] as Map?;
            hasMoreSavedSeries = pagination?["hasMore"] == true;
          }
        },
      );
    } catch (e) {
      _allSavedSeriesPage--;
      Logger.error("fetchMoreSavedSeries error: $e");
    } finally {
      isLoadingMoreSavedSeries = false;
      notifyListeners();
    }
  }

  // ─── Toggle ────────────────────────────────────────────────────────
  /// Toggle a topic in/out of the saved list.
  ///
  /// [postToggleCallback] is called after a successful toggle (e.g. to refresh
  /// the browse-topics list from HomeProvider).
  Future<ToggleTopicListResult?> toggleTopic({
    required String topicId,
    String? fallbackTitle,
    required Function(String error) onFailed,
    Future<void> Function()? postToggleCallback,
  }) async {
    if (_togglingTopicIds.contains(topicId)) return null;

    _togglingTopicIds.add(topicId);
    notifyListeners();

    final response = await SavedSeriesService.instance.toggleTopicList(
      topicId: topicId,
    );

    return response.fold(
      (error) {
        _togglingTopicIds.remove(topicId);
        notifyListeners();
        onFailed(error.errorMsg);
        return null;
      },
      (result) async {
        final data = result["data"] is Map
            ? Map<String, dynamic>.from(result["data"] as Map)
            : <String, dynamic>{};
        final bool isInMyList = data["isInMyList"] == true;
        final String topicTitle =
            data["topicTitle"]?.toString().trim().isNotEmpty == true
                ? data["topicTitle"].toString()
                : (fallbackTitle ?? '');

        _togglingTopicIds.remove(topicId);
        _topicIsInMyListOverrides[topicId] = isInMyList;
        if (!isInMyList) {
          allSavedSeriesList.removeWhere((item) => item.topic.id == topicId);
        }
        notifyListeners();

        // Refresh the profile preview, then run any caller-provided callback.
        await getMySeriesList();
        await postToggleCallback?.call();

        return ToggleTopicListResult(
          isInMyList: isInMyList,
          topicTitle: topicTitle,
          message: result["message"]?.toString(),
        );
      },
    );
  }

  // ─── Session reset ─────────────────────────────────────────────────
  void clearSessionData() {
    _togglingTopicIds.clear();
    _topicIsInMyListOverrides.clear();
    savedSeriesList = null;
    isSavedSeriesLoading = false;
    allSavedSeriesList = [];
    isAllSavedSeriesLoading = false;
    isLoadingMoreSavedSeries = false;
    hasMoreSavedSeries = true;
    _allSavedSeriesPage = 1;
    _allSavedSeriesSearch = '';
    notifyListeners();
  }
}
