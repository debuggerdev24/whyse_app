import 'package:redstreakapp/core/utils/app_imports.dart';
import 'package:redstreakapp/core/widgets/app_network_image.dart';
import 'package:redstreakapp/models/home/saved_series_model.dart';
import 'package:redstreakapp/providers/home/home_provider.dart';
import 'package:redstreakapp/providers/home/saved_series_provider.dart';

class MySavedSeriesScreen extends StatefulWidget {
  const MySavedSeriesScreen({super.key});

  @override
  State<MySavedSeriesScreen> createState() => _MySavedSeriesScreenState();
}

class _MySavedSeriesScreenState extends State<MySavedSeriesScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SavedSeriesProvider>().fetchAllSavedSeries();
    });
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<SavedSeriesProvider>().fetchMoreSavedSeries();
    }
  }

  void _openSeries(SavedSeriesItem item) {
    final topicId = item.topic.id;
    final homeProvider = context.read<HomeProvider>();
    homeProvider.beginTopicStoryDetailsLoad(topicId: topicId);
    homeProvider.getTopicStoryDetails(topicId: topicId);
    context.pushNamed(AppRoutes.createdStorySummaryScreen.name, extra: topicId);
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16, top + 6, 16, 8),
            child: SizedBox(
              height: 44,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GlassIconButton(
                      size: 44,
                      onTap: () => context.pop(),
                      child: Icon(
                        Icons.chevron_left_rounded,
                        size: 28,
                        color: AppColors.black,
                      ),
                    ),
                  ),
                  AppText(
                    text: 'My Series',
                    style: AppTextStyles.bold(
                      fontSize: 18,
                      color: AppColors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Consumer<SavedSeriesProvider>(
              builder: (context, ssp, _) {
                if (ssp.isAllSavedSeriesLoading &&
                    ssp.allSavedSeriesList.isEmpty) {
                  return _buildShimmer();
                }

                final list = ssp.allSavedSeriesList;
                if (list.isEmpty) {
                  return Center(
                    child: AppText(
                      text: 'No saved series yet.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.medium(
                        fontSize: 16,
                        color: AppColors.muted,
                      ),
                    ),
                  );
                }

                return GridView.builder(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(
                    16,
                    8,
                    16,
                    MediaQuery.paddingOf(context).bottom + 16,
                  ),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.78,
                  ),
                  itemCount: list.length + (ssp.isLoadingMoreSavedSeries ? 2 : 0),
                  itemBuilder: (context, index) {
                    if (index >= list.length) return const _SeriesCardShimmer();
                    final item = list[index];
                    return _SeriesCard(
                      item: item,
                      onOpen: () => _openSeries(item),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmer() {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 12,
        childAspectRatio: 0.78,
      ),
      itemCount: 6,
      itemBuilder: (_, _) => const _SeriesCardShimmer(),
    );
  }
}

class _SeriesCardShimmer extends StatelessWidget {
  const _SeriesCardShimmer();

  @override
  Widget build(BuildContext context) {
    return AppSkeletonizer(
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(22),
        ),
      ),
    );
  }
}

class _SeriesCard extends StatelessWidget {
  const _SeriesCard({required this.item, required this.onOpen});

  final SavedSeriesItem item;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final topic = item.topic;

    return GestureDetector(
      onTap: onOpen,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          fit: StackFit.expand,
          children: [
            ColoredBox(
              color: AppColors.black,
              child: AppNetworkImage(
                imageUrl: topic.thumbnailUrl,
                tag: 'MySavedSeries.thumbnail',
                errorCompact: true,
                errorIconOnly: true,
              ),
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x00000000), Color(0xCC000000)],
                  stops: [0.4, 1],
                ),
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: _BookmarkButton(topicId: topic.id),
            ),
            Positioned(
              left: 10,
              right: 10,
              bottom: 10,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    text: topic.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bold(fontSize: 16, color: Colors.white),
                  ),
                  const SizedBox(height: 2),
                  AppText(
                    text: topic.storiesCount == 1
                        ? '1 reading'
                        : '${topic.storiesCount} readings',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.regular(
                      fontSize: 12,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BookmarkButton extends StatelessWidget {
  const _BookmarkButton({required this.topicId});

  final String topicId;

  @override
  Widget build(BuildContext context) {
    final ssp = context.watch<SavedSeriesProvider>();
    final isToggling = ssp.isTopicListToggling(topicId);

    return GestureDetector(
      onTap: isToggling
          ? null
          : () async {
              final result = await ssp.toggleTopic(
                topicId: topicId,
                onFailed: (err) {
                  if (context.mounted) AppToast.error(context, err);
                },
              );
              if (result != null && context.mounted) {
                AppToast.success(
                  context,
                  result.isInMyList
                      ? 'Added to your list'
                      : 'Removed from your list',
                );
              }
            },
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.35),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: isToggling
            ? const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(
                Icons.bookmark_rounded,
                size: 16,
                color: Colors.white,
              ),
      ),
    );
  }
}
