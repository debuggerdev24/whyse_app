import 'package:redstreakapp/core/enums/data_status.dart';
import 'package:redstreakapp/core/extensions/color.extensions.dart';
import 'package:redstreakapp/core/utils/app_imports.dart';
import 'package:redstreakapp/core/utils/network_image_url.dart';
import 'package:redstreakapp/core/utils/user_facing_message.dart';
import 'package:redstreakapp/core/widgets/app_network_image.dart';
import 'package:redstreakapp/models/friend/friend_details_model.dart';
import 'package:redstreakapp/screens/profile/user_profile_topics_list_screen_params.dart';
import 'package:redstreakapp/services/profile/friend_api_service.dart';
import 'package:shimmer/shimmer.dart';

class UserProfileTopicsListScreen extends StatefulWidget {
  const UserProfileTopicsListScreen({super.key, required this.params});

  final UserProfileTopicsListScreenParams params;

  @override
  State<UserProfileTopicsListScreen> createState() =>
      _UserProfileTopicsListScreenState();
}

class _UserProfileTopicsListScreenState extends State<UserProfileTopicsListScreen> {
  final ScrollController _scrollController = ScrollController();

  DataState _state = DataState.loading;
  String? _error;
  List<TopicPreviewItem> _topics = [];
  int _page = 1;
  int _totalPages = 1;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadTopics(page: 1);
  }

  void _onScroll() {
    if (_scrollController.position.pixels <
        _scrollController.position.maxScrollExtent - 200) {
      return;
    }
    if (_state != DataState.success || _isLoadingMore) return;
    if (_page >= _totalPages) return;
    _loadTopics(page: _page + 1);
  }

  Future<void> _loadTopics({required int page}) async {
    final isFirstPage = page == 1;

    if (isFirstPage) {
      setState(() {
        _state = DataState.loading;
        _error = null;
        _topics = [];
        _page = 1;
        _totalPages = 1;
      });
    } else {
      setState(() => _isLoadingMore = true);
    }

    final result = await FriendApiService.instance.getUserProfileTopicsList(
      userId: widget.params.userId,
      page: page,
    );

    if (!mounted) return;

    result.fold(
      (failure) {
        setState(() {
          if (isFirstPage) {
            _state = DataState.failed;
            _error = userFacingMessage(failure.errorMsg);
          }
          _isLoadingMore = false;
        });
      },
      (response) {
        final data = response.data;
        setState(() {
          if (isFirstPage) {
            _topics = List.of(data.items);
            _state = DataState.success;
            _error = null;
          } else {
            _topics = [..._topics, ...data.items];
          }
          _page = data.pagination.page;
          _totalPages = data.pagination.totalPages;
          _isLoadingMore = false;
        });
      },
    );
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        surfaceTintColor: Colors.transparent,
        title: AppText(text: widget.params.title ?? 'Series Followed'),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.chevron_left_rounded),
        ),
      ),
      body: Column(
        children: [
          Divider(color: AppColors.black.setOpacity(0.1), height: 1),
          Expanded(
            child: Padding(
              padding: EdgeInsets.fromLTRB(24.w, 14.w, 24.w, 0),
              child: _buildBody(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_state == DataState.loading) return const _LoadingList();
    if (_state == DataState.failed) {
      return _ErrorState(
        message: _error,
        onRetry: () => _loadTopics(page: 1),
      );
    }
    if (_topics.isEmpty) return const _EmptyState();

    final hasNextPage = _page < _totalPages;
    final itemCount = _topics.length + (hasNextPage ? 1 : 0);

    return RefreshIndicator(
      color: AppColors.teal,
      onRefresh: () => _loadTopics(page: 1),
      child: ListView.separated(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        itemCount: itemCount,
        separatorBuilder: (_, __) => SizedBox(height: 16.h),
        itemBuilder: (context, index) {
          if (index == _topics.length) {
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 12.h),
              child: Center(
                child: SizedBox(
                  width: 24.sp,
                  height: 24.sp,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: AppColors.teal,
                  ),
                ),
              ),
            );
          }
          return _TopicListTile(topic: _topics[index]);
        },
      ),
    );
  }
}

class _TopicListTile extends StatelessWidget {
  const _TopicListTile({required this.topic});

  final TopicPreviewItem topic;

  @override
  Widget build(BuildContext context) {
    final imageUrl = resolveNullableNetworkImageUrl(topic.topicImage);
    final subtitle = topic.subtitle?.trim();
    final subtitleText = subtitle != null && subtitle.isNotEmpty
        ? subtitle
        : '${topic.noOfReadings} Readings';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.black.setOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.setOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: 100.w,
              child: imageUrl != null
                  ? AppNetworkImage(
                      imageUrl: imageUrl,
                      tag: 'UserProfileTopicsList.cover',
                      width: 100.w,
                      height: 100.w,
                      fit: BoxFit.cover,
                      errorCompact: true,
                      errorIconOnly: true,
                    )
                  : ColoredBox(
                      color: AppColors.lightwhiteColor,
                      child: Icon(
                        Icons.auto_stories_outlined,
                        color: AppColors.black.setOpacity(0.25),
                      ),
                    ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 12.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AppText(
                      text: topic.title ?? 'Untitled',
                      style: AppTextStyles.semibold(
                        fontSize: 15.sp,
                        color: AppColors.black,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    8.h.verticalSpace,
                    AppText(
                      text: subtitleText,
                      style: AppTextStyles.medium(
                        fontSize: 13.sp,
                        color: AppColors.black.setOpacity(0.5),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingList extends StatelessWidget {
  const _LoadingList();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: 6,
      separatorBuilder: (_, __) => SizedBox(height: 16.h),
      itemBuilder: (_, __) => const _ShimmerTile(),
    );
  }
}

class _ShimmerTile extends StatelessWidget {
  const _ShimmerTile();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBaseColor,
      highlightColor: AppColors.shimmerHighlightColor,
      child: Container(
        height: 100.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({this.message, required this.onRetry});

  final String? message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 40.w,
            color: AppColors.orangeColor,
          ),
          12.verticalSpace,
          AppText(
            text: message ?? 'Something went wrong',
            textAlign: TextAlign.center,
            style: AppTextStyles.medium(fontSize: 14.sp),
          ),
          16.verticalSpace,
          GestureDetector(
            onTap: onRetry,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: AppColors.teal.setOpacity(0.4)),
              ),
              child: AppText(
                text: 'Retry',
                style: AppTextStyles.semibold(
                  fontSize: 14.sp,
                  color: AppColors.teal,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.auto_stories_outlined,
            size: 48.w,
            color: AppColors.black.setOpacity(0.3),
          ),
          12.verticalSpace,
          AppText(
            text: 'No series yet',
            style: AppTextStyles.medium(fontSize: 16.sp),
          ),
        ],
      ),
    );
  }
}
