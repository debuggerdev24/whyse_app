import 'dart:async';
import 'package:redstreakapp/core/extensions/color.extensions.dart';
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
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SavedSeriesProvider>().fetchAllSavedSeries();
    });
    _scrollController.addListener(_onScroll);
    _focusNode.addListener(() => setState(() {}));
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<SavedSeriesProvider>().fetchMoreSavedSeries();
    }
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        context.read<SavedSeriesProvider>().fetchAllSavedSeries(
          search: value.trim(),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.chevron_left_rounded),
        ),
        centerTitle: true,
        title: AppText(
          text: 'My Series List',
          style: AppTextStyles.semibold(fontSize: 20, color: AppColors.black),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 8.h),
            child: TextFormField(
              controller: _searchController,
              focusNode: _focusNode,
              onChanged: _onSearchChanged,
              cursorColor: AppColors.black,
              onTapOutside: (_) => FocusScope.of(context).unfocus(),
              style: AppTextStyles.medium(
                fontSize: 14.sp,
                color: AppColors.black,
              ),
              decoration: InputDecoration(
                hintText: 'Search series…',
                hintStyle: AppTextStyles.medium(
                  fontSize: 14.sp,
                  color: AppColors.black.setOpacity(0.4),
                ),
                filled: true,
                fillColor: AppColors.searchBackgroundColor,
                suffixIcon: _searchController.text.trim().isEmpty
                    ? Padding(
                        padding: EdgeInsets.only(
                          right: 15.w,
                          top: 10.w,
                          bottom: 10.w,
                        ),
                        child: SvgIcon(
                          AppAssets.searchIcon,
                          color: _focusNode.hasFocus
                              ? AppColors.black
                              : AppColors.black.setOpacity(0.4),
                          size: 24.sp,
                        ),
                      )
                    : GestureDetector(
                        onTap: () {
                          _searchController.clear();
                          _focusNode.unfocus();
                          context
                              .read<SavedSeriesProvider>()
                              .fetchAllSavedSeries(search: '');
                        },
                        child: Padding(
                          padding: EdgeInsets.only(
                            right: 15.w,
                            top: 10.w,
                            bottom: 10.w,
                          ),
                          child: SvgIcon(AppAssets.closeFilled, size: 20.sp),
                        ),
                      ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 20.w,
                  vertical: 10.h,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(999),
                  borderSide: BorderSide(
                    color: AppColors.searchBackgroundColor,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(999),
                  borderSide: BorderSide(color: AppColors.black, width: 1.4),
                ),
              ),
            ),
          ),
          Expanded(
            child: Consumer<SavedSeriesProvider>(
              builder: (context, ssp, _) {
                if (ssp.isAllSavedSeriesLoading) {
                  return _buildShimmer();
                }

                final list = ssp.allSavedSeriesList;

                if (list.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.bookmark_border_rounded,
                          size: 52.w,
                          color: AppColors.black.setOpacity(0.25),
                        ),
                        16.h.verticalSpace,
                        AppText(
                          text: _searchController.text.trim().isEmpty
                              ? "No saved series yet."
                              : "No results for \"${_searchController.text.trim()}\"",
                          textAlign: TextAlign.center,
                          style: AppTextStyles.medium(
                            fontSize: 16.sp,
                            color: AppColors.black.setOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return GridView.builder(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16.h,
                    crossAxisSpacing: 12.w,
                    childAspectRatio: 0.62,
                  ),
                  itemCount:
                      list.length + (ssp.isLoadingMoreSavedSeries ? 2 : 0),
                  itemBuilder: (context, index) {
                    if (index >= list.length) {
                      return _buildCardShimmer();
                    }
                    final item = list[index];
                    return _SavedSeriesCard(
                      item: item,
                      onTap: () {
                        final topicId = item.topic.id;
                        final homeProvider = context.read<HomeProvider>();
                        homeProvider.beginTopicStoryDetailsLoad(
                          topicId: topicId,
                        );
                        homeProvider.getTopicStoryDetails(topicId: topicId);
                        context.pushNamed(
                          AppRoutes.createdStorySummaryScreen.name,
                          extra: topicId,
                        );
                      },
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
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16.h,
        crossAxisSpacing: 12.w,
        childAspectRatio: 0.62,
      ),
      itemCount: 6,
      itemBuilder: (_, __) => _buildCardShimmer(),
    );
  }

  Widget _buildCardShimmer() {
    return AppSkeletonizer(child: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
              ),
            ),
          ),
          12.h.verticalSpace,
          Container(
            width: 32.w,
            height: 32.w,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}

class _SavedSeriesCard extends StatelessWidget {
  const _SavedSeriesCard({required this.item, this.onTap});

  final SavedSeriesItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final topic = item.topic;
    final subtitleColor = AppColors.black.setOpacity(0.45);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.setOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(16.r),
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: double.infinity,
                      child: AppNetworkImage(
                        imageUrl: topic.thumbnailUrl,
                        tag: 'MySavedSeries.thumbnail',
                        errorCompact: true,
                        errorIconOnly: true,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Builder(
                      builder: (context) {
                        final ssp = context.watch<SavedSeriesProvider>();
                        final isToggling = ssp.isTopicListToggling(topic.id);
                        return GestureDetector(
                          onTap: isToggling
                              ? null
                              : () async {
                                  final result = await ssp.toggleTopic(
                                    topicId: topic.id,
                                    onFailed: (err) {
                                      if (context.mounted) {
                                        AppToast.error(context, err);
                                      }
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
                            width: 32.h,
                            height: 32.h,
                            margin: EdgeInsets.only(top: 10.w, right: 10.w),
                            decoration: const BoxDecoration(
                              color: AppColors.white,
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: isToggling
                                ? SizedBox(
                                    width: 16.w,
                                    height: 16.w,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.teal,
                                    ),
                                  )
                                : Icon(
                                    Icons.bookmark_rounded,
                                    size: 20.sp,
                                    color: AppColors.teal,
                                  ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(14.w, 13.w, 14.w, 2.w),
              child: AppText(
                text: topic.title,
                style: AppTextStyles.bold(fontSize: 16.sp),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 14.w),
              child: AppText(
                text: '${topic.storiesCount} Readings',
                style: AppTextStyles.medium(
                  fontSize: 12.sp,
                  color: subtitleColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            AppButton(
              margin: EdgeInsets.fromLTRB(14.w, 12.w, 14.w, 16.w),
              onTap: () => onTap?.call(),
              text: "Start Reading",
            ),
          ],
        ),
      ),
    );
  }
}
