import 'package:redstreakapp/core/enums/data_status.dart';
import 'package:redstreakapp/core/utils/app_imports.dart';
import 'package:redstreakapp/core/widgets/app_network_image.dart';
import 'package:redstreakapp/models/explore/explore_models.dart';
import 'package:redstreakapp/models/home/browse_topic_model.dart';
import 'package:redstreakapp/providers/curiosity_reading/curiosity_reading_provider.dart';
import 'package:redstreakapp/providers/explore/explore_provider.dart';
import 'package:redstreakapp/providers/home/home_provider.dart';
import 'package:redstreakapp/screens/dashboard.dart';
import 'package:redstreakapp/screens/explore/explore_constants.dart';
import 'package:redstreakapp/screens/explore/widgets/explore_category_widgets.dart';
import 'package:redstreakapp/screens/explore/widgets/explore_widgets.dart';

enum _SeeAllKind { seriesForYou, seriesPopular, sparkForYou, sparkPopular }

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  ExploreDiscoverInterest? _openInterest;
  _SeeAllKind? _seeAll;
  bool _seriesSelected = true;

  @override
  void initState() {
    super.initState();
    tabIndex.addListener(_handleTabChange);
    WidgetsBinding.instance.addPostFrameCallback((_) {
    if (!mounted) return;
      context.read<ExploreProvider>().ensureExploreReady();
    });
  }

  @override
  void dispose() {
    tabIndex.removeListener(_handleTabChange);
    super.dispose();
  }

  void _handleTabChange() {
    if (!mounted || tabIndex.value == 1) return;
    if (_openInterest == null && _seeAll == null) return;
      setState(() {
      _openInterest = null;
      _seeAll = null;
    });
  }

  void _goBack() {
    setState(() {
      if (_seeAll != null) {
        _seeAll = null;
      } else {
        _openInterest = null;
      }
    });
  }

  void _openCategory(ExploreDiscoverInterest interest) {
    setState(() {
      _openInterest = interest;
      _seeAll = null;
      _seriesSelected = true;
    });
    final provider = context.read<ExploreProvider>();
    provider.syncSeriesInterestSelection({interest.id});
    provider.syncSparkInterestSelection({interest.id});
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

  bool _topicMatches(BrowseTopicModel topic, ExploreDiscoverInterest interest) {
    return topic.interests.any(
      (label) => matchesInterestLabel(label, interest.name),
    );
  }

  bool _sparkMatches(ExploreSparkItem item, ExploreDiscoverInterest interest) {
    return matchesInterestLabel(item.interestName, interest.name);
  }

  String _blurb(ExploreProvider provider, ExploreDiscoverInterest interest) {
    final description = interest.description.trim();
    if (description.isNotEmpty) return description;

    for (final topic in _seriesPool(provider)) {
      if (_topicMatches(topic, interest) &&
          topic.learningGoal.trim().isNotEmpty) {
        return topic.learningGoal.trim();
      }
    }
    return '';
  }

  String _cover(ExploreProvider provider, ExploreDiscoverInterest interest) {
    if (interest.imageUrl.trim().isNotEmpty) return interest.imageUrl.trim();

    for (final topic in _seriesPool(provider)) {
      if (_topicMatches(topic, interest) && topic.hasThumbnail) {
        return topic.thumbnailUrl;
      }
    }
    for (final item in _sparkPool(provider)) {
      if (_sparkMatches(item, interest) && item.imageUrl.trim().isNotEmpty) {
        return item.imageUrl;
      }
    }
    return '';
  }

  List<BrowseTopicModel> _seriesPool(ExploreProvider provider) {
      return [
      ...?provider.seriesState.forYou?.items,
      ...?provider.seriesState.popular?.items,
      for (final section in provider.seriesState.interestSections)
        ...section.items,
    ];
  }

  List<ExploreSparkItem> _sparkPool(ExploreProvider provider) {
    return [ 
      ...?provider.sparkState.forYou?.items,
      ...?provider.sparkState.popular?.items,
      for (final section in provider.sparkState.interestSections)
        ...section.items,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExploreProvider>();
    final atRoot = _openInterest == null;

    return PopScope(
      canPop: atRoot,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _goBack();
      },
      child: ColoredBox(
        color: explorePageColor,
        child: SafeArea(
          bottom: false,
          top: _openInterest == null || _seeAll != null,
          child: _seeAll != null && _openInterest != null
              ? _SeeAllView(
                  interest: _openInterest!,
                  kind: _seeAll!,
                  provider: provider,
                  topicMatches: _topicMatches,
                  sparkMatches: _sparkMatches,
                  onBack: _goBack,
                  onTopicTap: _openTopicSeries,
                  onSparkTap: _onSparkItemTap,
                )
              : _openInterest != null
              ? _CategoryDetailView(
                  interest: _openInterest!,
                  seriesSelected: _seriesSelected,
                  provider: provider,
                  blurb: _blurb(provider, _openInterest!),
                  coverUrl: _cover(provider, _openInterest!),
                  topicMatches: _topicMatches,
                  sparkMatches: _sparkMatches,
                  onBack: _goBack,
                  onModeChanged: (series) {
                    setState(() => _seriesSelected = series);
                  },
                  onSeeAll: (kind) => setState(() => _seeAll = kind),
                  onTopicTap: _openTopicSeries,
                  onSparkTap: _onSparkItemTap,
                )
              : _CategoryGrid(
                  provider: provider,
                  coverFor: _cover,
                  onOpen: _openCategory,
                  onSearch: () =>
                      context.pushNamed(AppRoutes.searchScreen.name),
                ),
        ),
      ),
    );
  }
}

class _CategoryGrid extends StatelessWidget {
  const _CategoryGrid({
    required this.provider,
    required this.coverFor,
    required this.onOpen,
    required this.onSearch,
  });

  final ExploreProvider provider;
  final String Function(ExploreProvider, ExploreDiscoverInterest) coverFor;
  final ValueChanged<ExploreDiscoverInterest> onOpen;
  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context) {
    final interests = provider.interests;
    final loading =
        provider.interestsState == DataState.loading && interests.isEmpty;
    final failed =
        provider.interestsState == DataState.failed && interests.isEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: AppText(
                  text: 'Explore',
                  style: AppTextStyles.bold(
                    fontSize: 34,
                    color: AppColors.black,
                  ),
                ),
              ),
              GlassIconButton(
                size: 44,
                onTap: onSearch,
                child: SvgIcon(
                  AppAssets.searchIcon,
                  size: 22,
                  color: AppColors.black,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 6.h, 16.w, 18.h),
          child: AppText(
            text: 'Choose an interest to discover amazing series and Sparks.',
            style: AppTextStyles.regular(
              fontSize: 15,
              color: AppColors.muted,
            ).copyWith(height: 1.35),
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            color: exploreTeal,
            backgroundColor: AppColors.surface,
            onRefresh: () => provider.loadDiscoverInterests(force: true),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: EdgeInsets.fromLTRB(
                16.w,
                0,
                16.w,
                24.h + MediaQuery.paddingOf(context).bottom,
              ),
              children: [
          if (loading)
            const _GridShimmer()
          else if (failed)
            ExploreInlineError(
              message:
                  provider.interestsError ??
                  'Could not load interests. Please try again.',
              onRetry: () => provider.loadDiscoverInterests(force: true),
            )
          else if (interests.isEmpty)
            AppText(
              text: 'No interests available',
              style: AppTextStyles.medium(
                fontSize: 15,
                color: AppColors.muted,
              ),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: interests.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12.h,
                crossAxisSpacing: 12.w,
                childAspectRatio: 0.86,
              ),
              itemBuilder: (context, index) {
                final interest = interests[index];
                return ExploreInterestCard(
                  title: interest.name,
                  imageUrl: coverFor(provider, interest),
                  fallbackColor: parseInterestColor(interest.color),
                  onTap: () => onOpen(interest),
                );
              },
            ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CategoryDetailView extends StatelessWidget {
  const _CategoryDetailView({
    required this.interest,
    required this.seriesSelected,
    required this.provider,
    required this.blurb,
    required this.coverUrl,
    required this.topicMatches,
    required this.sparkMatches,
    required this.onBack,
    required this.onModeChanged,
    required this.onSeeAll,
    required this.onTopicTap,
    required this.onSparkTap,
  });

  final ExploreDiscoverInterest interest;
  final bool seriesSelected;
  final ExploreProvider provider;
  final String blurb;
  final String coverUrl;
  final bool Function(BrowseTopicModel, ExploreDiscoverInterest) topicMatches;
  final bool Function(ExploreSparkItem, ExploreDiscoverInterest) sparkMatches;
  final VoidCallback onBack;
  final ValueChanged<bool> onModeChanged;
  final ValueChanged<_SeeAllKind> onSeeAll;
  final ValueChanged<BrowseTopicModel> onTopicTap;
  final void Function(
    ExploreSparkItem item,
    int index,
    ExplorePagedSection<ExploreSparkItem> section,
  )
  onSparkTap;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.only(
        bottom: 24.h + MediaQuery.paddingOf(context).bottom,
      ),
      children: [
        _Hero(
          title: interest.name,
          subtitle: blurb,
          imageUrl: coverUrl,
          fallbackColor: parseInterestColor(interest.color),
          onBack: onBack,
        ),
        16.h.verticalSpace,
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ExploreModeSwitch(
                seriesSelected: seriesSelected,
                onChanged: onModeChanged,
              ),
              22.h.verticalSpace,
              if (seriesSelected)
                _SeriesSections(
                  interest: interest,
                  provider: provider,
                  topicMatches: topicMatches,
                  onSeeAll: onSeeAll,
                  onTopicTap: onTopicTap,
                )
              else
                _SparkSections(
                  interest: interest,
                  provider: provider,
                  sparkMatches: sparkMatches,
                  onSeeAll: onSeeAll,
                  onSparkTap: onSparkTap,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.fallbackColor,
    required this.onBack,
  });

  final String title;
  final String subtitle;
  final String imageUrl;
  final Color fallbackColor;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;

    return ClipRRect(
      borderRadius: BorderRadius.vertical(bottom: Radius.circular(32.r)),
      child: SizedBox(
        height: topInset + 300.h,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (imageUrl.trim().isEmpty)
              ColoredBox(color: fallbackColor)
            else
              AppNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                errorCompact: true,
                placeholder: (_) => ColoredBox(color: fallbackColor),
              ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x14000000),
                    Color(0x00000000),
                    Color(0xE6000000),
                  ],
                  stops: [0, 0.42, 1],
                ),
              ),
            ),
              Padding(
              padding: EdgeInsets.fromLTRB(16.w, topInset + 8, 16.w, 22.h),
                child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  GlassIconButton(
                    onTap: onBack,
                    size: 44,
                    child: Icon(
                      Icons.chevron_left_rounded,
                      color: AppColors.black,
                      size: 28,
                    ),
                  ),
                  const Spacer(),
                  AppText(
                    text: title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bold(
                      fontSize: 32,
                      color: Colors.white,
                      height: 1.05,
                    ),
                  ),
                  if (subtitle.trim().isNotEmpty) ...[
                    8.h.verticalSpace,
                    AppText(
                      text: subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.medium(
                        fontSize: 15,
                        color: Colors.white,
                      ).copyWith(height: 1.35),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SeriesSections extends StatelessWidget {
  const _SeriesSections({
    required this.interest,
    required this.provider,
    required this.topicMatches,
    required this.onSeeAll,
    required this.onTopicTap,
  });

  final ExploreDiscoverInterest interest;
  final ExploreProvider provider;
  final bool Function(BrowseTopicModel, ExploreDiscoverInterest) topicMatches;
  final ValueChanged<_SeeAllKind> onSeeAll;
  final ValueChanged<BrowseTopicModel> onTopicTap;

  @override
  Widget build(BuildContext context) {
    final forYou = provider.seriesState.forYou;
    final popular = provider.seriesState.popular;
    final interestSection = _interestSection(
      provider.seriesState.interestSections,
      interest.id,
    );

    final forYouMatched = (forYou?.items ?? [])
        .where((topic) => topicMatches(topic, interest))
        .toList();
    final popularMatched = (popular?.items ?? [])
        .where((topic) => topicMatches(topic, interest))
        .toList();
    final useInterestList = forYouMatched.isEmpty;
    final forYouItems = useInterestList
        ? (interestSection?.items ?? const <BrowseTopicModel>[])
        : forYouMatched;
    final forYouLoading = useInterestList
        ? interestSection == null ||
              (interestSection.state == DataState.loading &&
                  forYouItems.isEmpty)
        : forYou?.state == DataState.loading && forYouItems.isEmpty;

    return Column(
      children: [
        _PreviewRow(
          title: 'For You',
          loading: forYouLoading,
          items: [
            for (final topic in forYouItems)
              ExploreMediaCard(
                title: topic.topic,
                imageUrl: topic.thumbnailUrl,
                fallbackColor: parseInterestColor(interest.color),
                onTap: () => onTopicTap(topic),
              ),
          ],
          onSeeAll: forYouItems.length > 2
              ? () => onSeeAll(_SeeAllKind.seriesForYou)
              : null,
        ),
        22.h.verticalSpace,
        _PreviewRow(
          title: 'Popular',
          loading:
              popular?.state == DataState.loading && popularMatched.isEmpty,
          items: [
            for (final topic in popularMatched)
              ExploreMediaCard(
                title: topic.topic,
                imageUrl: topic.thumbnailUrl,
                fallbackColor: parseInterestColor(interest.color),
                onTap: () => onTopicTap(topic),
              ),
          ],
          onSeeAll: popularMatched.length > 2
              ? () => onSeeAll(_SeeAllKind.seriesPopular)
              : null,
        ),
      ],
    );
  }
}

class _SparkSections extends StatelessWidget {
  const _SparkSections({
    required this.interest,
    required this.provider,
    required this.sparkMatches,
    required this.onSeeAll,
    required this.onSparkTap,
  });

  final ExploreDiscoverInterest interest;
  final ExploreProvider provider;
  final bool Function(ExploreSparkItem, ExploreDiscoverInterest) sparkMatches;
  final ValueChanged<_SeeAllKind> onSeeAll;
  final void Function(
    ExploreSparkItem item,
    int index,
    ExplorePagedSection<ExploreSparkItem> section,
  )
  onSparkTap;

  @override
  Widget build(BuildContext context) {
    final forYou = provider.sparkState.forYou;
    final popular = provider.sparkState.popular;
    final interestSection = _interestSection(
      provider.sparkState.interestSections,
      interest.id,
    );

    final forYouMatched = (forYou?.items ?? [])
        .where((item) => sparkMatches(item, interest))
        .toList();
    final popularMatched = (popular?.items ?? [])
        .where((item) => sparkMatches(item, interest))
        .toList();
    final useInterestList = forYouMatched.isEmpty;
    final source = useInterestList ? interestSection : forYou;
    final forYouItems = useInterestList
        ? (interestSection?.items ?? const <ExploreSparkItem>[])
        : forYouMatched;
    final forYouLoading = useInterestList
        ? interestSection == null ||
              (interestSection.state == DataState.loading &&
                  forYouItems.isEmpty)
        : forYou?.state == DataState.loading && forYouItems.isEmpty;

    return Column(
      children: [
        _PreviewRow(
          title: 'For You',
          loading: forYouLoading,
          items: [
            for (var i = 0; i < forYouItems.length; i++)
              ExploreMediaCard(
                title: forYouItems[i].question,
                imageUrl: forYouItems[i].imageUrl,
                fallbackColor: parseInterestColor(interest.color),
                onTap: () {
                  if (source == null) return;
                  onSparkTap(forYouItems[i], i, source);
                },
              ),
          ],
          onSeeAll: forYouItems.length > 2
              ? () => onSeeAll(_SeeAllKind.sparkForYou)
              : null,
        ),
        22.h.verticalSpace,
        _PreviewRow(
          title: 'Popular',
          loading:
              popular?.state == DataState.loading && popularMatched.isEmpty,
          items: [
            for (var i = 0; i < popularMatched.length; i++)
              ExploreMediaCard(
                title: popularMatched[i].question,
                imageUrl: popularMatched[i].imageUrl,
                fallbackColor: parseInterestColor(interest.color),
                onTap: () {
                  if (popular == null) return;
                  onSparkTap(popularMatched[i], i, popular);
                },
              ),
          ],
          onSeeAll: popularMatched.length > 2
              ? () => onSeeAll(_SeeAllKind.sparkPopular)
              : null,
        ),
      ],
    );
  }
}

ExplorePagedSection<T>? _interestSection<T>(
  List<ExplorePagedSection<T>> sections,
  String id,
) {
  for (final section in sections) {
    if (section.key == id) return section;
  }
  return null;
}

class _PreviewRow extends StatelessWidget {
  const _PreviewRow({
    required this.title,
    required this.loading,
    required this.items,
    required this.onSeeAll,
  });

  final String title;
  final bool loading;
  final List<Widget> items;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    final preview = items.take(2).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ExploreSectionHeader(title: title, onSeeAll: onSeeAll),
        12.h.verticalSpace,
        if (loading)
          const _PairShimmer()
        else if (preview.isEmpty)
          AppText(
            text: 'Nothing here yet',
            style: AppTextStyles.medium(
              fontSize: 14,
              color: AppColors.muted,
            ),
          )
        else
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: preview[0]),
              12.w.horizontalSpace,
              Expanded(
                child: preview.length > 1
                    ? preview[1]
                    : const SizedBox.shrink(),
              ),
            ],
          ),
      ],
    );
  }
}

class _SeeAllView extends StatelessWidget {
  const _SeeAllView({
    required this.interest,
    required this.kind,
    required this.provider,
    required this.topicMatches,
    required this.sparkMatches,
    required this.onBack,
    required this.onTopicTap,
    required this.onSparkTap,
  });

  final ExploreDiscoverInterest interest;
  final _SeeAllKind kind;
  final ExploreProvider provider;
  final bool Function(BrowseTopicModel, ExploreDiscoverInterest) topicMatches;
  final bool Function(ExploreSparkItem, ExploreDiscoverInterest) sparkMatches;
  final VoidCallback onBack;
  final ValueChanged<BrowseTopicModel> onTopicTap;
  final void Function(
    ExploreSparkItem item,
    int index,
    ExplorePagedSection<ExploreSparkItem> section,
  )
  onSparkTap;

  @override
  Widget build(BuildContext context) {
    final title = switch (kind) {
      _SeeAllKind.seriesForYou || _SeeAllKind.sparkForYou => 'For You',
      _SeeAllKind.seriesPopular || _SeeAllKind.sparkPopular => 'Popular',
    };

    final cards = _cards();

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(8.w, 8.h, 16.w, 8.h),
          child: Row(
            children: [
              IconButton(
                onPressed: onBack,
                icon: const Icon(Icons.chevron_left_rounded, size: 30),
                color: AppColors.black,
              ),
              AppText(
                text: title,
                style: AppTextStyles.bold(
                  fontSize: 22,
                  color: AppColors.black,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: cards.isEmpty
              ? Center(
                  child: AppText(
                    text: 'Nothing here yet',
                    style: AppTextStyles.medium(
                      fontSize: 15,
                      color: AppColors.muted,
                    ),
                  ),
                )
              : GridView.builder(
                  padding: EdgeInsets.fromLTRB(
                    16.w,
                    8.h,
                    16.w,
                    24.h + MediaQuery.paddingOf(context).bottom,
                  ),
                  physics: const BouncingScrollPhysics(),
                  itemCount: cards.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12.h,
                    crossAxisSpacing: 12.w,
                    childAspectRatio: 1,
                  ),
                  itemBuilder: (context, index) => cards[index],
                ),
        ),
      ],
    );
  }

  List<Widget> _cards() {
    switch (kind) {
      case _SeeAllKind.seriesForYou:
        final forYou = provider.seriesState.forYou;
        final interestSection = _interestSection(
          provider.seriesState.interestSections,
          interest.id,
        );
        final matched = (forYou?.items ?? [])
            .where((topic) => topicMatches(topic, interest))
            .toList();
        final topics = matched.isEmpty
            ? (interestSection?.items ?? const <BrowseTopicModel>[])
            : matched;
        return [
          for (final topic in topics)
            ExploreMediaCard(
              title: topic.topic,
              imageUrl: topic.thumbnailUrl,
              fallbackColor: parseInterestColor(interest.color),
              onTap: () => onTopicTap(topic),
            ),
        ];
      case _SeeAllKind.seriesPopular:
        final topics = (provider.seriesState.popular?.items ?? [])
            .where((topic) => topicMatches(topic, interest))
            .toList();
        return [
          for (final topic in topics)
            ExploreMediaCard(
              title: topic.topic,
              imageUrl: topic.thumbnailUrl,
              fallbackColor: parseInterestColor(interest.color),
              onTap: () => onTopicTap(topic),
            ),
        ];
      case _SeeAllKind.sparkForYou:
        final forYou = provider.sparkState.forYou;
        final interestSection = _interestSection(
          provider.sparkState.interestSections,
          interest.id,
        );
        final matched = (forYou?.items ?? [])
            .where((item) => sparkMatches(item, interest))
            .toList();
        final useInterest = matched.isEmpty;
        final source = useInterest ? interestSection : forYou;
        final items = useInterest
            ? (interestSection?.items ?? const <ExploreSparkItem>[])
            : matched;
        return [
          for (var i = 0; i < items.length; i++)
            ExploreMediaCard(
              title: items[i].question,
              imageUrl: items[i].imageUrl,
              fallbackColor: parseInterestColor(interest.color),
              onTap: () {
                if (source == null) return;
                onSparkTap(items[i], i, source);
              },
            ),
        ];
      case _SeeAllKind.sparkPopular:
        final popular = provider.sparkState.popular;
        final items = (popular?.items ?? [])
            .where((item) => sparkMatches(item, interest))
            .toList();
        return [
          for (var i = 0; i < items.length; i++)
            ExploreMediaCard(
              title: items[i].question,
              imageUrl: items[i].imageUrl,
              fallbackColor: parseInterestColor(interest.color),
              onTap: () {
                if (popular == null) return;
                onSparkTap(items[i], i, popular);
              },
            ),
        ];
    }
  }
}

class _GridShimmer extends StatelessWidget {
  const _GridShimmer();

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 6,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12.h,
        crossAxisSpacing: 12.w,
        childAspectRatio: 0.86,
      ),
      itemBuilder: (_, _) => DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFFE4E4E9),
          borderRadius: BorderRadius.circular(22.r),
        ),
      ),
    );
  }
}

class _PairShimmer extends StatelessWidget {
  const _PairShimmer();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _box()),
        12.w.horizontalSpace,
        Expanded(child: _box()),
      ],
    );
  }

  Widget _box() {
    return AspectRatio(
      aspectRatio: 1,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFFE4E4E9),
          borderRadius: BorderRadius.circular(18.r),
        ),
      ),
    );
  }
}
