import 'package:redstreakapp/core/utils/app_imports.dart';
import 'package:redstreakapp/core/utils/custom_loader.dart';
import 'package:redstreakapp/models/home/browse_topic_model.dart';
import 'package:redstreakapp/providers/home/story_provider.dart';
import 'package:redstreakapp/screens/dashboard.dart';
import 'package:redstreakapp/screens/explore/explore_dummy_data.dart';
import 'package:redstreakapp/screens/explore/explore_spark_dummy_data.dart';
import 'package:redstreakapp/screens/explore/explore_constants.dart';
import 'package:redstreakapp/screens/explore/widgets/explore_widgets.dart';
import 'package:redstreakapp/screens/search/widgets/search_widgets.dart';
import 'package:redstreakapp/services/home/home_api_service.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _contentScrollController = ScrollController();

  ExploreMainTab _selectedTab = ExploreMainTab.series;
  final Set<String> _selectedInterestFilters = {};
  bool _isLoadingProgress = false;

  @override
  void initState() {
    super.initState();
    tabIndex.addListener(_handleTabChange);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final storyProvider = context.read<StoryProvider>();
      if (storyProvider.interestsList.isEmpty) {
        storyProvider.getStoryInterest(onFailed: (_) {});
      }
    });
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
    if (_searchController.text.isNotEmpty || _selectedInterestFilters.isNotEmpty) {
      setState(() {
        _searchController.clear();
        _selectedInterestFilters.clear();
      });
    }
  }

  bool get _isSearching => _searchController.text.trim().isNotEmpty;

  void _clearInterestFilters() {
    setState(() => _selectedInterestFilters.clear());
  }

  void _toggleInterestFilter(String interest) {
    setState(() {
      if (_selectedInterestFilters.contains(interest)) {
        _selectedInterestFilters.remove(interest);
      } else {
        _selectedInterestFilters.add(interest);
      }
    });
  }

  Widget _buildInterestBlock() {
    return ExploreDiscoverByInterest(
      selectedInterests: _selectedInterestFilters,
      onInterestToggled: _toggleInterestFilter,
    );
  }

  List<Widget> _buildDummySeriesScrollContent() {
    if (_isSearching) {
      return [
        BrowseEmptyState(query: _searchController.text.trim()),
      ];
    }

    final sections =
        exploreDummySeriesSectionsForFilter(_selectedInterestFilters);

    if (_selectedInterestFilters.isNotEmpty && sections.isEmpty) {
      return [
        ExploreFilteredEmptyState(
          interestLabels: _selectedInterestFilters.toList(),
          onClearFilter: _clearInterestFilters,
        ),
      ];
    }

    return [
      for (var i = 0; i < sections.length; i++) ...[
        if (i > 0) 28.w.verticalSpace,
        ExploreHorizontalSection(
          title: sections[i].title,
          child: ExploreSeriesRow(
            topics: sections[i].topics,
            onTopicTap: _openTopicProgress,
          ),
        ),
      ],
    ];
  }

  Future<void> _openTopicProgress(BrowseTopicModel topic) async {
    if (_isLoadingProgress) return;
    setState(() => _isLoadingProgress = true);

    final response = await HomeApiService.instance.getTopicProgress(
      topicId: topic.id,
    );

    if (!mounted) return;
    setState(() => _isLoadingProgress = false);

    response.fold(
      (error) => AppToast.error(context, error.errorMsg),
      (result) {
        final data = result['data'] ?? result;
        final readings = data['readings'];
        final list = readings is List ? readings : <dynamic>[];
        if (list.isEmpty) {
          AppToast.info(context: context, message: 'No readings found');
          return;
        }
        context.pushNamed(
          AppRoutes.randomStorySeriesScreen.name,
          extra: {'progress': result, 'searchTopic': topic.toJson()},
        );
      },
    );
  }

  void _onSparkItemTap(ExploreSparkItem item) {
    AppToast.info(context: context, message: item.question);
  }

  List<Widget> _buildSparkScrollContent() {
    if (_isSearching) {
      return [BrowseEmptyState(query: _searchController.text.trim())];
    }

    final sections = exploreDummySparkSectionsForFilter(_selectedInterestFilters);

    if (_selectedInterestFilters.isNotEmpty && sections.isEmpty) {
      return [
        ExploreFilteredEmptyState(
          interestLabels: _selectedInterestFilters.toList(),
          onClearFilter: _clearInterestFilters,
        ),
      ];
    }

    return [
      for (var i = 0; i < sections.length; i++) ...[
        if (i > 0) 28.w.verticalSpace,
        ExploreHorizontalSection(
          title: sections[i].title,
          child: ExploreSparkItemsRow(
            items: sections[i].items,
            onItemTap: _onSparkItemTap,
          ),
        ),
      ],
    ];
  }

  void _onSearchChanged(String value) {
    setState(() {});
    deBouncer.run(() {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final storyProvider = context.watch<StoryProvider>();

    return Stack(
      children: [
        AppLayout(
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
                          onTabChanged: (tab) {
                            setState(() => _selectedTab = tab);
                          },
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
                      onRefresh: () async {
                        if (storyProvider.interestsList.isEmpty) {
                          await storyProvider.getStoryInterest(
                            onFailed: (_) {},
                          );
                        }
                        setState(() {});
                      },
                      child: ListView(
                        controller: _contentScrollController,
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 24.h),
                        children: _selectedTab == ExploreMainTab.series
                            ? _buildDummySeriesScrollContent()
                            : _buildSparkScrollContent(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (_isLoadingProgress) const FullPageIndicator(),
      ],
    );
  }
}
