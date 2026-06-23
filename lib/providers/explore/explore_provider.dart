import 'dart:async';

import 'package:flutter/material.dart';
import 'package:redstreakapp/core/enums/data_status.dart';
import 'package:redstreakapp/core/helper/log_helper.dart';
import 'package:redstreakapp/core/network/base_api_service.dart';
import 'package:redstreakapp/models/explore/explore_models.dart';
import 'package:redstreakapp/models/home/browse_topic_model.dart';
import 'package:redstreakapp/screens/explore/explore_constants.dart';
import 'package:redstreakapp/services/explore/explore_api_service.dart';

class ExploreTabState {
  ExploreTabState({
    this.forYou,
    this.popular,
    this.interestSections = const [],
    this.isSearchMode = false,
  });

  ExplorePagedSection<BrowseTopicModel>? forYou;
  ExplorePagedSection<BrowseTopicModel>? popular;
  List<ExplorePagedSection<BrowseTopicModel>> interestSections;
  bool isSearchMode;

  List<ExplorePagedSection<BrowseTopicModel>> get visibleSeriesSections {
    if (isSearchMode) {
      return forYou == null ? [] : [forYou!];
    }
    return [
      ?forYou,
      ?popular,
      ...interestSections,
    ];
  }
}

class ExploreSparkTabState {
  ExploreSparkTabState({
    this.forYou,
    this.popular,
    this.interestSections = const [],
    this.isSearchMode = false,
  });

  ExplorePagedSection<ExploreSparkItem>? forYou;
  ExplorePagedSection<ExploreSparkItem>? popular;
  List<ExplorePagedSection<ExploreSparkItem>> interestSections;
  bool isSearchMode;

  List<ExplorePagedSection<ExploreSparkItem>> get visibleSparkSections {
    if (isSearchMode) {
      return forYou == null ? [] : [forYou!];
    }
    return [
      ?forYou,
      ?popular,
      ...interestSections,
    ];
  }
}

class ExploreProvider extends ChangeNotifier {
  static const int pageLimit = 10;
  static const String forYouKey = 'forYou';
  static const String popularKey = 'popular';

  final ExploreApiService _api;

  ExploreProvider({ExploreApiService? api})
      : _api = api ?? ExploreApiService.instance;

  DataState interestsState = DataState.loading;
  String? interestsError;
  List<ExploreDiscoverInterest> interests = [];

  ExploreTabState seriesState = ExploreTabState();
  ExploreSparkTabState sparkState = ExploreSparkTabState();

  final Map<String, ExplorePagedSection<BrowseTopicModel>> _seriesInterestCache =
      {};
  final Map<String, ExplorePagedSection<ExploreSparkItem>> _sparkInterestCache =
      {};

  bool isLoadingSeriesContent = false;
  bool isLoadingSparkContent = false;

  String _lastSeriesSearch = '';
  String _lastSparkSearch = '';

  Future<void>? _prefetchFuture;
  bool _hasPrefetchedBaseContent = false;
  bool _isPrefetching = false;

  bool get hasPrefetchedBaseContent => _hasPrefetchedBaseContent;
  bool get isPrefetching => _isPrefetching;

  /// Warms explore cache in the background (dashboard startup).
  /// Loads in phases: interests → series → spark. Interest rows stay on-demand.
  Future<void> prefetchExploreCache({bool force = false}) {
    if (!force && _hasPrefetchedBaseContent) {
      return Future.value();
    }
    if (!force && _prefetchFuture != null) {
      return _prefetchFuture!;
    }

    _prefetchFuture = _runPrefetch(force: force);
    return _prefetchFuture!;
  }

  Future<void> ensureExploreReady() => prefetchExploreCache();

  Future<void> _runPrefetch({required bool force}) async {
    _isPrefetching = true;

    seriesState.forYou ??= _emptySeriesSection(forYouKey, 'For You');
    seriesState.popular ??= _emptySeriesSection(popularKey, 'Popular');
    sparkState.forYou ??= _emptySparkSection(forYouKey, 'For You');
    sparkState.popular ??= _emptySparkSection(popularKey, 'Popular');

    try {
      await loadDiscoverInterests(force: force, silent: true);

      if (force || !_isSectionReady(seriesState.forYou)) {
        await _fetchSeriesForYou(replace: true, silent: true);
      }
      if (force || !_isSectionReady(seriesState.popular)) {
        await _fetchSeriesPopular(replace: true, silent: true);
      }

      if (force || !_isSectionReady(sparkState.forYou)) {
        await _fetchSparkForYou(replace: true, silent: true);
      }
      if (force || !_isSectionReady(sparkState.popular)) {
        await _fetchSparkPopular(replace: true, silent: true);
      }

      _hasPrefetchedBaseContent = true;
    } catch (error, stackTrace) {
      Logger.error('[EXPLORE]: prefetch failed: $error\n$stackTrace');
    } finally {
      _isPrefetching = false;
      notifyListeners();
    }
  }

  bool _isSectionReady<T>(ExplorePagedSection<T>? section) {
    return section?.state == DataState.success ||
        section?.state == DataState.failed;
  }

  Future<void> loadDiscoverInterests({
    bool force = false,
    bool silent = false,
  }) async {
    if (!force && interestsState == DataState.success && interests.isNotEmpty) {
      return;
    }

    if (!silent) {
      interestsState = DataState.loading;
      interestsError = null;
      if (force) interests = [];
      notifyListeners();
    }

    final result = await _api.getDiscoverInterests();
    result.fold(
      (error) {
        interestsState = DataState.failed;
        interestsError = error.errorMsg;
        Logger.error('[EXPLORE]: discover interests failed: ${error.errorMsg}');
      },
      (response) {
        final data = response['data'] as Map<String, dynamic>? ?? {};
        final list = data['interests'] as List? ?? [];
        interests = list
            .map(
              (item) => ExploreDiscoverInterest.fromJson(
                item as Map<String, dynamic>,
              ),
            )
            .toList();
        interestsState = DataState.success;
        interestsError = null;
      },
    );
    notifyListeners();
  }

  Future<void> loadSeriesContent({
    String search = '',
    Set<String> selectedInterestIds = const {},
    bool refresh = false,
  }) async {
    final trimmedSearch = search.trim();
    final previousSearch = _lastSeriesSearch;
    final searchChanged = trimmedSearch != previousSearch;
    final exitedSearch = previousSearch.isNotEmpty && trimmedSearch.isEmpty;
    _lastSeriesSearch = trimmedSearch;

    if (interests.isEmpty && interestsState != DataState.loading) {
      await loadDiscoverInterests();
    }

    final isSearchMode = trimmedSearch.isNotEmpty;
    seriesState.isSearchMode = isSearchMode;

    if (isSearchMode) {
      isLoadingSeriesContent = true;
      if (refresh || seriesState.forYou == null || searchChanged) {
        seriesState.forYou ??= _emptySeriesSection(forYouKey, 'For You');
        seriesState.popular = null;
        seriesState.interestSections = [];
        notifyListeners();
        await _fetchSeriesForYou(search: trimmedSearch, replace: true);
      }
      isLoadingSeriesContent = false;
      notifyListeners();
      return;
    }

    seriesState.forYou ??= _emptySeriesSection(forYouKey, 'For You');
    seriesState.popular ??= _emptySeriesSection(popularKey, 'Popular');

    final needsBaseInit =
        !_isSectionReady(seriesState.forYou) ||
        !_isSectionReady(seriesState.popular);

    if (refresh || needsBaseInit || exitedSearch) {
      isLoadingSeriesContent = true;
      notifyListeners();

      final fetches = <Future<void>>[];
      if (refresh || exitedSearch || !_isSectionReady(seriesState.forYou)) {
        fetches.add(_fetchSeriesForYou(replace: true));
      }
      if (refresh || exitedSearch || !_isSectionReady(seriesState.popular)) {
        fetches.add(_fetchSeriesPopular(replace: true));
      }
      if (fetches.isNotEmpty) {
        await Future.wait(fetches);
      }

      isLoadingSeriesContent = false;
      notifyListeners();
    }

    await syncSeriesInterestSelection(selectedInterestIds);
  }

  /// Adds/removes interest rows without refetching For You, Popular, or cached interests.
  Future<void> syncSeriesInterestSelection(Set<String> selectedInterestIds) async {
    if (seriesState.isSearchMode) return;

    final previousIds =
        seriesState.interestSections.map((section) => section.key).toSet();
    final added = selectedInterestIds.difference(previousIds);
    final removed = previousIds.difference(selectedInterestIds);

    for (final section in seriesState.interestSections) {
      if (removed.contains(section.key)) {
        _seriesInterestCache[section.key] = section;
      }
    }

    final nextSections = <ExplorePagedSection<BrowseTopicModel>>[];
    for (final id in selectedInterestIds) {
      if (previousIds.contains(id)) {
        nextSections.add(
          seriesState.interestSections.firstWhere((section) => section.key == id),
        );
        continue;
      }

      final cached = _seriesInterestCache[id];
      if (cached != null) {
        nextSections.add(cached);
        continue;
      }

      nextSections.add(
        _emptySeriesSection(id, _interestTitle(id), interestId: id),
      );
    }

    seriesState.interestSections = nextSections;
    notifyListeners();

    final idsToFetch = added.where((id) => !_seriesInterestCache.containsKey(id));
    if (idsToFetch.isEmpty) return;

    await Future.wait(
      idsToFetch.map(
        (id) => _fetchSingleSeriesInterestSection(interestId: id, replace: true),
      ),
    );
    notifyListeners();
  }

  Future<void> loadSparkContent({
    String search = '',
    Set<String> selectedInterestIds = const {},
    bool refresh = false,
  }) async {
    final trimmedSearch = search.trim();
    final previousSearch = _lastSparkSearch;
    final searchChanged = trimmedSearch != previousSearch;
    final exitedSearch = previousSearch.isNotEmpty && trimmedSearch.isEmpty;
    _lastSparkSearch = trimmedSearch;

    if (interests.isEmpty && interestsState != DataState.loading) {
      await loadDiscoverInterests();
    }

    final isSearchMode = trimmedSearch.isNotEmpty;
    sparkState.isSearchMode = isSearchMode;

    if (isSearchMode) {
      isLoadingSparkContent = true;
      if (refresh || sparkState.forYou == null || searchChanged) {
        sparkState.forYou ??= _emptySparkSection(forYouKey, 'For You');
        sparkState.popular = null;
        sparkState.interestSections = [];
        notifyListeners();
        await _fetchSparkForYou(search: trimmedSearch, replace: true);
      }
      isLoadingSparkContent = false;
      notifyListeners();
      return;
    }

    sparkState.forYou ??= _emptySparkSection(forYouKey, 'For You');
    sparkState.popular ??= _emptySparkSection(popularKey, 'Popular');

    final needsBaseInit =
        !_isSectionReady(sparkState.forYou) ||
        !_isSectionReady(sparkState.popular);

    if (refresh || needsBaseInit || exitedSearch) {
      isLoadingSparkContent = true;
      notifyListeners();

      final fetches = <Future<void>>[];
      if (refresh || exitedSearch || !_isSectionReady(sparkState.forYou)) {
        fetches.add(_fetchSparkForYou(replace: true));
      }
      if (refresh || exitedSearch || !_isSectionReady(sparkState.popular)) {
        fetches.add(_fetchSparkPopular(replace: true));
      }
      if (fetches.isNotEmpty) {
        await Future.wait(fetches);
      }

      isLoadingSparkContent = false;
      notifyListeners();
    }

    await syncSparkInterestSelection(selectedInterestIds);
  }

  Future<void> syncSparkInterestSelection(Set<String> selectedInterestIds) async {
    if (sparkState.isSearchMode) return;

    final previousIds =
        sparkState.interestSections.map((section) => section.key).toSet();
    final added = selectedInterestIds.difference(previousIds);
    final removed = previousIds.difference(selectedInterestIds);

    for (final section in sparkState.interestSections) {
      if (removed.contains(section.key)) {
        _sparkInterestCache[section.key] = section;
      }
    }

    final nextSections = <ExplorePagedSection<ExploreSparkItem>>[];
    for (final id in selectedInterestIds) {
      if (previousIds.contains(id)) {
        nextSections.add(
          sparkState.interestSections.firstWhere((section) => section.key == id),
        );
        continue;
      }

      final cached = _sparkInterestCache[id];
      if (cached != null) {
        nextSections.add(cached);
        continue;
      }

      nextSections.add(
        _emptySparkSection(id, _interestTitle(id), interestId: id),
      );
    }

    sparkState.interestSections = nextSections;
    notifyListeners();

    final idsToFetch = added.where((id) => !_sparkInterestCache.containsKey(id));
    if (idsToFetch.isEmpty) return;

    await Future.wait(
      idsToFetch.map(
        (id) => _fetchSingleSparkInterestSection(interestId: id, replace: true),
      ),
    );
    notifyListeners();
  }

  Future<void> refreshCurrentTab({
    required ExploreMainTab tab,
    String search = '',
    Set<String> selectedInterestIds = const {},
  }) async {
    _hasPrefetchedBaseContent = false;
    _prefetchFuture = null;
    await loadDiscoverInterests(force: true);
    if (tab == ExploreMainTab.series) {
      _seriesInterestCache.clear();
      await loadSeriesContent(
        search: search,
        selectedInterestIds: selectedInterestIds,
        refresh: true,
      );
    } else {
      _sparkInterestCache.clear();
      await loadSparkContent(
        search: search,
        selectedInterestIds: selectedInterestIds,
        refresh: true,
      );
    }
    _hasPrefetchedBaseContent = true;
  }

  Future<void> retrySeriesSection(String sectionKey) async {
    if (sectionKey == forYouKey) {
      await _fetchSeriesForYou(
        search: _lastSeriesSearch,
        replace: true,
      );
    } else if (sectionKey == popularKey) {
      await _fetchSeriesPopular(replace: true);
    } else {
      await _fetchSingleSeriesInterestSection(
        interestId: sectionKey,
        replace: true,
      );
    }
    notifyListeners();
  }

  Future<void> retrySparkSection(String sectionKey) async {
    if (sectionKey == forYouKey) {
      await _fetchSparkForYou(
        search: _lastSparkSearch,
        replace: true,
      );
    } else if (sectionKey == popularKey) {
      await _fetchSparkPopular(replace: true);
    } else {
      await _fetchSingleSparkInterestSection(
        interestId: sectionKey,
        replace: true,
      );
    }
    notifyListeners();
  }

  Future<void> loadMoreSeriesSection(String sectionKey) async {
    final section = _findSeriesSection(sectionKey);
    if (section == null || section.isLoadingMore || !section.hasMore) return;

    section.isLoadingMore = true;
    notifyListeners();

    if (sectionKey == forYouKey) {
      await _fetchSeriesForYou(
        search: _lastSeriesSearch,
        page: section.pagination.page + 1,
        replace: false,
      );
    } else if (sectionKey == popularKey) {
      await _fetchSeriesPopular(
        page: section.pagination.page + 1,
        replace: false,
      );
    } else {
      await _fetchSingleSeriesInterestSection(
        interestId: sectionKey,
        page: section.pagination.page + 1,
        replace: false,
      );
    }

    final updated = _findSeriesSection(sectionKey);
    if (updated != null) updated.isLoadingMore = false;
    notifyListeners();
  }

  Future<({List<ExploreSparkItem> items, ExplorePagination pagination})>
      loadMoreSparkSectionPage(String sectionKey) async {
    final section = _findSparkSection(sectionKey);
    if (section == null || !section.hasMore) {
      return (
        items: <ExploreSparkItem>[],
        pagination: section?.pagination ?? const ExplorePagination(),
      );
    }

    final beforeCount = section.items.length;
    await loadMoreSparkSection(sectionKey);
    final updated = _findSparkSection(sectionKey);
    if (updated == null) {
      return (items: <ExploreSparkItem>[], pagination: const ExplorePagination());
    }

    final newItems = updated.items.length > beforeCount
        ? updated.items.sublist(beforeCount)
        : <ExploreSparkItem>[];

    return (items: newItems, pagination: updated.pagination);
  }

  Future<void> loadMoreSparkSection(String sectionKey) async {
    final section = _findSparkSection(sectionKey);
    if (section == null || section.isLoadingMore || !section.hasMore) return;

    section.isLoadingMore = true;
    notifyListeners();

    if (sectionKey == forYouKey) {
      await _fetchSparkForYou(
        search: _lastSparkSearch,
        page: section.pagination.page + 1,
        replace: false,
      );
    } else if (sectionKey == popularKey) {
      await _fetchSparkPopular(
        page: section.pagination.page + 1,
        replace: false,
      );
    } else {
      await _fetchSingleSparkInterestSection(
        interestId: sectionKey,
        page: section.pagination.page + 1,
        replace: false,
      );
    }

    final updated = _findSparkSection(sectionKey);
    if (updated != null) updated.isLoadingMore = false;
    notifyListeners();
  }

  List<String> interestLabelsForIds(Set<String> ids) {
    return ids
        .map((id) => _interestTitle(id))
        .where((label) => label.isNotEmpty)
        .toList();
  }

  ExplorePagedSection<BrowseTopicModel>? _findSeriesSection(String key) {
    if (seriesState.forYou?.key == key) return seriesState.forYou;
    if (seriesState.popular?.key == key) return seriesState.popular;
    for (final section in seriesState.interestSections) {
      if (section.key == key) return section;
    }
    return null;
  }

  ExplorePagedSection<ExploreSparkItem>? _findSparkSection(String key) {
    if (sparkState.forYou?.key == key) return sparkState.forYou;
    if (sparkState.popular?.key == key) return sparkState.popular;
    for (final section in sparkState.interestSections) {
      if (section.key == key) return section;
    }
    return null;
  }

  String _interestTitle(String interestId) {
    for (final interest in interests) {
      if (interest.id == interestId) return interest.name;
    }
    return '';
  }

  void _cacheSeriesInterestSection(ExplorePagedSection<BrowseTopicModel> section) {
    if (section.interestId != null && section.interestId!.isNotEmpty) {
      _seriesInterestCache[section.interestId!] = section;
    }
  }

  void _cacheSparkInterestSection(ExplorePagedSection<ExploreSparkItem> section) {
    if (section.interestId != null && section.interestId!.isNotEmpty) {
      _sparkInterestCache[section.interestId!] = section;
    }
  }

  ExplorePagedSection<BrowseTopicModel> _emptySeriesSection(
    String key,
    String title, {
    String? interestId,
  }) {
    return ExplorePagedSection<BrowseTopicModel>(
      key: key,
      title: title,
      interestId: interestId,
    );
  }

  ExplorePagedSection<ExploreSparkItem> _emptySparkSection(
    String key,
    String title, {
    String? interestId,
  }) {
    return ExplorePagedSection<ExploreSparkItem>(
      key: key,
      title: title,
      interestId: interestId,
    );
  }

  Future<void> _fetchSeriesForYou({
    String search = '',
    int page = 1,
    bool replace = true,
    bool silent = false,
  }) async {
    final section = seriesState.forYou;
    if (section == null) return;

    if (replace && !silent) {
      section.state = DataState.loading;
      section.error = null;
      section.items = [];
      notifyListeners();
    }

    final result = await _api.getSeriesForYou(
      page: page,
      limit: pageLimit,
      search: search.isEmpty ? null : search,
    );

    result.fold(
      (error) => _applySeriesSectionFailure(section, error, replace: replace),
      (response) => _applySeriesSingleSectionSuccess(
        section,
        response,
        page: page,
        replace: replace,
      ),
    );
  }

  Future<void> _fetchSeriesPopular({
    int page = 1,
    bool replace = true,
    bool silent = false,
  }) async {
    final section = seriesState.popular;
    if (section == null) return;

    if (replace && !silent) {
      section.state = DataState.loading;
      section.error = null;
      section.items = [];
      notifyListeners();
    }

    final result = await _api.getSeriesPopular(page: page, limit: pageLimit);
    result.fold(
      (error) => _applySeriesSectionFailure(section, error, replace: replace),
      (response) => _applySeriesSingleSectionSuccess(
        section,
        response,
        page: page,
        replace: replace,
      ),
    );
  }

  Future<void> _fetchSingleSeriesInterestSection({
    required String interestId,
    int page = 1,
    bool replace = true,
  }) async {
    final section = _findSeriesSection(interestId);
    if (section == null) return;

    if (replace) {
      section.state = DataState.loading;
      section.error = null;
      section.items = [];
      notifyListeners();
    }

    final result = await _api.getSeriesInterest(
      page: page,
      limit: pageLimit,
      interestId: interestId,
    );

    result.fold(
      (error) => _applySeriesSectionFailure(section, error, replace: replace),
      (response) {
        final data = response['data'] as Map<String, dynamic>? ?? {};
        final sections = data['sections'] as List? ?? [];
        final raw = sections.isNotEmpty && sections.first is Map<String, dynamic>
            ? sections.first as Map<String, dynamic>
            : <String, dynamic>{};
        _applySeriesSectionPayload(section, raw, page: page, replace: replace);
        _cacheSeriesInterestSection(section);
      },
    );
  }

  void _applySeriesSingleSectionSuccess(
    ExplorePagedSection<BrowseTopicModel> section,
    Map<String, dynamic> response, {
    required int page,
    required bool replace,
  }) {
    final data = response['data'] as Map<String, dynamic>? ?? {};
    _applySeriesSectionPayload(section, data, page: page, replace: replace);
  }

  void _applySeriesSectionPayload(
    ExplorePagedSection<BrowseTopicModel> section,
    Map<String, dynamic> data, {
    required int page,
    required bool replace,
  }) {
    final title = data['title']?.toString();
    if (title != null && title.isNotEmpty) {
      section.title = title;
    }

    final items = (data['items'] as List? ?? [])
        .map((item) => browseTopicFromExplorerJson(item as Map<String, dynamic>))
        .toList();

    section
      ..state = DataState.success
      ..error = null
      ..items = replace ? items : [...section.items, ...items]
      ..pagination = ExplorePagination.fromJson(
        data['pagination'] as Map<String, dynamic>?,
      );
  }

  void _applySeriesSectionFailure(
    ExplorePagedSection<BrowseTopicModel> section,
    ApiException error, {
    required bool replace,
  }) {
    if (!replace && section.items.isNotEmpty) {
      Logger.error('[EXPLORE]: series section load-more failed: ${error.errorMsg}');
      return;
    }
    section
      ..state = DataState.failed
      ..error = error.errorMsg;
  }

  Future<void> _fetchSparkForYou({
    String search = '',
    int page = 1,
    bool replace = true,
    bool silent = false,
  }) async {
    final section = sparkState.forYou;
    if (section == null) return;

    if (replace && !silent) {
      section.state = DataState.loading;
      section.error = null;
      section.items = [];
      notifyListeners();
    }

    final result = await _api.getSparkForYou(
      page: page,
      limit: pageLimit,
      search: search.isEmpty ? null : search,
    );

    result.fold(
      (error) => _applySparkSectionFailure(section, error, replace: replace),
      (response) => _applySparkSingleSectionSuccess(
        section,
        response,
        page: page,
        replace: replace,
      ),
    );
  }

  Future<void> _fetchSparkPopular({
    int page = 1,
    bool replace = true,
    bool silent = false,
  }) async {
    final section = sparkState.popular;
    if (section == null) return;

    if (replace && !silent) {
      section.state = DataState.loading;
      section.error = null;
      section.items = [];
      notifyListeners();
    }

    final result = await _api.getSparkPopular(page: page, limit: pageLimit);
    result.fold(
      (error) => _applySparkSectionFailure(section, error, replace: replace),
      (response) => _applySparkSingleSectionSuccess(
        section,
        response,
        page: page,
        replace: replace,
      ),
    );
  }

  Future<void> _fetchSingleSparkInterestSection({
    required String interestId,
    int page = 1,
    bool replace = true,
  }) async {
    final section = _findSparkSection(interestId);
    if (section == null) return;

    if (replace) {
      section.state = DataState.loading;
      section.error = null;
      section.items = [];
      notifyListeners();
    }

    final result = await _api.getSparkInterest(
      page: page,
      limit: pageLimit,
      interestId: interestId,
    );

    result.fold(
      (error) => _applySparkSectionFailure(section, error, replace: replace),
      (response) {
        final data = response['data'] as Map<String, dynamic>? ?? {};
        final sections = data['sections'] as List? ?? [];
        final raw = sections.isNotEmpty && sections.first is Map<String, dynamic>
            ? sections.first as Map<String, dynamic>
            : <String, dynamic>{};
        _applySparkSectionPayload(section, raw, page: page, replace: replace);
        _cacheSparkInterestSection(section);
      },
    );
  }

  void _applySparkSingleSectionSuccess(
    ExplorePagedSection<ExploreSparkItem> section,
    Map<String, dynamic> response, {
    required int page,
    required bool replace,
  }) {
    final data = response['data'] as Map<String, dynamic>? ?? {};
    _applySparkSectionPayload(section, data, page: page, replace: replace);
  }

  void _applySparkSectionPayload(
    ExplorePagedSection<ExploreSparkItem> section,
    Map<String, dynamic> data, {
    required int page,
    required bool replace,
  }) {
    final title = data['title']?.toString();
    if (title != null && title.isNotEmpty) {
      section.title = title;
    }

    final items = (data['items'] as List? ?? [])
        .map((item) => ExploreSparkItem.fromJson(item as Map<String, dynamic>))
        .toList();

    section
      ..state = DataState.success
      ..error = null
      ..items = replace ? items : [...section.items, ...items]
      ..pagination = ExplorePagination.fromJson(
        data['pagination'] as Map<String, dynamic>?,
      );
  }

  void _applySparkSectionFailure(
    ExplorePagedSection<ExploreSparkItem> section,
    ApiException error, {
    required bool replace,
  }) {
    if (!replace && section.items.isNotEmpty) {
      Logger.error('[EXPLORE]: spark section load-more failed: ${error.errorMsg}');
      return;
    }
    section
      ..state = DataState.failed
      ..error = error.errorMsg;
  }

  void clearSessionData() {
    interestsState = DataState.loading;
    interestsError = null;
    interests = [];
    seriesState = ExploreTabState();
    sparkState = ExploreSparkTabState();
    _seriesInterestCache.clear();
    _sparkInterestCache.clear();
    isLoadingSeriesContent = false;
    isLoadingSparkContent = false;
    _lastSeriesSearch = '';
    _lastSparkSearch = '';
    _prefetchFuture = null;
    _hasPrefetchedBaseContent = false;
    _isPrefetching = false;
    notifyListeners();
  }
}
