import 'package:redstreakapp/core/enums/data_status.dart';
import 'package:redstreakapp/core/utils/app_imports.dart';
import 'package:redstreakapp/models/explore/explore_models.dart';
import 'package:redstreakapp/models/home/browse_topic_model.dart';
import 'package:redstreakapp/providers/curiosity_reading/curiosity_reading_provider.dart';
import 'package:redstreakapp/providers/explore/explore_provider.dart';
import 'package:redstreakapp/providers/home/home_provider.dart';
import 'package:redstreakapp/screens/dashboard.dart';
import 'package:redstreakapp/screens/explore/explore_constants.dart';
import 'package:redstreakapp/screens/explore/widgets/explore_widgets.dart';
import 'package:redstreakapp/screens/search/widgets/search_widgets.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _contentScrollController = ScrollController();

  ExploreMainTab _selectedTab = ExploreMainTab.series;
  final Set<String> _selectedInterestIds = {};

  @override
  void initState() {
    super.initState();
    tabIndex.addListener(_handleTabChange);
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  Future<void> _bootstrap() async {
    final provider = context.read<ExploreProvider>();
    await provider.ensureExploreReady();
    if (!mounted) return;
    await _loadCurrentTabContent();
  }

  @override
  void dispose() {
    tabIndex.removeListener(_handleTabChange);
    deBouncer.timer?.cancel();
    _searchController.dispose();
    _contentScrollController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (!mounted || tabIndex.value != 1) return;
    if (_searchController.text.isNotEmpty || _selectedInterestIds.isNotEmpty) {
      setState(() {
        _searchController.clear();
        _selectedInterestIds.clear();
      });
      _loadCurrentTabContent();
    }
  }

  bool get _isSearching => _searchController.text.trim().isNotEmpty;

  Future<void> _loadCurrentTabContent({bool refresh = false}) async {
    final provider = context.read<ExploreProvider>();
    final search = _searchController.text.trim();
    final filters = Set<String>.from(_selectedInterestIds);

    if (_selectedTab == ExploreMainTab.series) {
      await provider.loadSeriesContent(
        search: search,
        selectedInterestIds: filters,
        refresh: refresh,
      );
    } else {
      await provider.loadSparkContent(
        search: search,
        selectedInterestIds: filters,
        refresh: refresh,
      );
    }
  }

  void _clearInterestFilters() {
    setState(() => _selectedInterestIds.clear());
    _syncInterestSelection();
  }

  void _toggleInterestFilter(String interestId) {
    setState(() {
      if (_selectedInterestIds.contains(interestId)) {
        _selectedInterestIds.remove(interestId);
      } else {
        _selectedInterestIds.add(interestId);
      }
    });
    _syncInterestSelection();
  }

  void _syncInterestSelection() {
    final provider = context.read<ExploreProvider>();
    final filters = Set<String>.from(_selectedInterestIds);
    if (_selectedTab == ExploreMainTab.series) {
      provider.syncSeriesInterestSelection(filters);
    } else {
      provider.syncSparkInterestSelection(filters);
    }
  }

  void _onTabChanged(ExploreMainTab tab) {
    if (_selectedTab == tab) return;
    setState(() => _selectedTab = tab);
    final provider = context.read<ExploreProvider>();
    final needsLoad = tab == ExploreMainTab.series
        ? provider.seriesState.forYou == null
        : provider.sparkState.forYou == null;
    if (needsLoad) {
      _loadCurrentTabContent(refresh: true);
    }
  }

  Widget _buildInterestBlock() {
    return ExploreDiscoverByInterest(
      selectedInterestIds: _selectedInterestIds,
      onInterestToggled: _toggleInterestFilter,
    );
  }

  void _openTopicSeries(BrowseTopicModel topic) {
    final homeProvider = context.read<HomeProvider>();
    homeProvider.beginTopicStoryDetailsLoad(topicId: topic.id);
    homeProvider.getTopicStoryDetails(topicId: topic.id);
    context.pushNamed(
      AppRoutes.createdStorySummaryScreen.name,
      extra: topic.id,
    );
  }

  void _onSparkItemTap(
    ExploreSparkItem item,
    int index,
    ExplorePagedSection<ExploreSparkItem> section,
  ) {
    final curiosityProvider = context.read<CuriosityReadingProvider>();
    final exploreProvider = context.read<ExploreProvider>();

    curiosityProvider.beginExploreSession(
      items: section.items,
      startIndex: index,
      pagination: section.pagination,
      loadMoreItems: () =>
          exploreProvider.loadMoreSparkSectionPage(section.key),
    );

    if (curiosityProvider.currentReading == null) {
      AppToast.error(
        context,
        curiosityProvider.currentReadingError ??
            'Could not open this Spark. Please try again.',
      );
      return;
    }

    context.pushNamed(AppRoutes.curiosityReadingScreen.name);
    curiosityProvider.loadExploreSessionBody();
  }

  List<Widget> _buildSeriesScrollContent(ExploreProvider provider) {
    if (_isSearching) {
      final section = provider.seriesState.forYou;
      if (section == null || (section.state == DataState.loading && section.items.isEmpty)) {
        return const [ExploreContentShimmer()];
      }
      if (section.state == DataState.failed && section.items.isEmpty) {
        return [
          ExploreInlineError(
            message: section.error ?? 'Could not load search results.',
            onRetry: () => provider.retrySeriesSection(ExploreProvider.forYouKey),
          ),
        ];
      }
      if (section.items.isEmpty) {
        return [BrowseEmptyState(query: _searchController.text.trim())];
      }
      return [
        ExploreSeriesSectionView(
          section: section,
          onTopicTap: _openTopicSeries,
          onRetry: () => provider.retrySeriesSection(section.key),
          onLoadMore: () => provider.loadMoreSeriesSection(section.key),
        ),
      ];
    }

    final sections = provider.seriesState.visibleSeriesSections;
    if (sections.isEmpty) {
      if (provider.isLoadingSeriesContent) {
        return const [ExploreContentShimmer()];
      }
      return const [ExploreSectionEmpty(title: 'series')];
    }

    if (_selectedInterestIds.isNotEmpty &&
        sections.every((section) => section.items.isEmpty) &&
        sections.every((section) => section.state == DataState.success)) {
      return [
        ExploreFilteredEmptyState(
          interestLabels: provider.interestLabelsForIds(_selectedInterestIds),
          onClearFilter: _clearInterestFilters,
        ),
      ];
    }

    return [
      for (var i = 0; i < sections.length; i++) ...[
        if (i > 0) 28.w.verticalSpace,
        ExploreSeriesSectionView(
          section: sections[i],
          onTopicTap: _openTopicSeries,
          onRetry: () => provider.retrySeriesSection(sections[i].key),
          onLoadMore: () => provider.loadMoreSeriesSection(sections[i].key),
        ),
      ],
    ];
  }

  List<Widget> _buildSparkScrollContent(ExploreProvider provider) {
    if (_isSearching) {
      final section = provider.sparkState.forYou;
      if (section == null || (section.state == DataState.loading && section.items.isEmpty)) {
        return const [ExploreSparkContentShimmer()];
      }
      if (section.state == DataState.failed && section.items.isEmpty) {
        return [
          ExploreInlineError(
            message: section.error ?? 'Could not load search results.',
            onRetry: () => provider.retrySparkSection(ExploreProvider.forYouKey),
          ),
        ];
      }
      if (section.items.isEmpty) {
        return [BrowseEmptyState(query: _searchController.text.trim())];
      }
      return [
        ExploreSparkSectionView(
          section: section,
          onItemTap: (item, index) => _onSparkItemTap(item, index, section),
          onRetry: () => provider.retrySparkSection(section.key),
          onLoadMore: () => provider.loadMoreSparkSection(section.key),
        ),
      ];
    }

    final sections = provider.sparkState.visibleSparkSections;
    if (sections.isEmpty) {
      if (provider.isLoadingSparkContent) {
        return const [ExploreSparkContentShimmer()];
      }
      return const [ExploreSectionEmpty(title: 'spark')];
    }

    if (_selectedInterestIds.isNotEmpty &&
        sections.every((section) => section.items.isEmpty) &&
        sections.every((section) => section.state == DataState.success)) {
      return [
        ExploreFilteredEmptyState(
          interestLabels: provider.interestLabelsForIds(_selectedInterestIds),
          onClearFilter: _clearInterestFilters,
        ),
      ];
    }

    return [
      for (var i = 0; i < sections.length; i++) ...[
        if (i > 0) 28.w.verticalSpace,
        ExploreSparkSectionView(
          section: sections[i],
          onItemTap: (item, index) =>
              _onSparkItemTap(item, index, sections[i]),
          onRetry: () => provider.retrySparkSection(sections[i].key),
          onLoadMore: () => provider.loadMoreSparkSection(sections[i].key),
        ),
      ],
    ];
  }

  void _onSearchChanged(String value) {
    setState(() {});
    deBouncer.run(() {
      if (!mounted) return;
      _loadCurrentTabContent();
    });
  }

  @override
  Widget build(BuildContext context) {
    final exploreProvider = context.watch<ExploreProvider>();

    return AppLayout(
      body: ColoredBox(
        color: AppColors.white,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ExploreSearchField(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                    ),
                    20.w.verticalSpace,
                    ExploreTabBar(
                      selectedTab: _selectedTab,
                      onTabChanged: _onTabChanged,
                    ),
                    24.w.verticalSpace,
                    _buildInterestBlock(),
                  ],
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  color: AppColors.teal,
                  backgroundColor: AppColors.white,
                  onRefresh: () => exploreProvider.refreshCurrentTab(
                    tab: _selectedTab,
                    search: _searchController.text.trim(),
                    selectedInterestIds: _selectedInterestIds,
                  ),
                  child: ListView(
                    controller: _contentScrollController,
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 24.h),
                    children: _selectedTab == ExploreMainTab.series
                        ? _buildSeriesScrollContent(exploreProvider)
                        : _buildSparkScrollContent(exploreProvider),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
