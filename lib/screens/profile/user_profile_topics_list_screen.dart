import 'package:redstreakapp/core/enums/data_status.dart';
import 'package:redstreakapp/core/utils/app_imports.dart';
import 'package:redstreakapp/core/utils/network_image_url.dart';
import 'package:redstreakapp/core/utils/user_facing_message.dart';
import 'package:redstreakapp/core/widgets/app_network_image.dart';
import 'package:redstreakapp/models/friend/friend_details_model.dart';
import 'package:redstreakapp/screens/profile/user_profile_topics_list_screen_params.dart';
import 'package:redstreakapp/screens/settings/widget/settings_chrome.dart';
import 'package:redstreakapp/services/profile/friend_api_service.dart';

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
    return SettingsScaffold(
      title: widget.params.title ?? 'Series Followed',
      body: _buildBody(),
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
      child: GridView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
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
        itemCount: itemCount,
        itemBuilder: (context, index) {
          if (index == _topics.length) {
            return Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: AppColors.teal,
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

    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ColoredBox(
            color: AppColors.black,
            child: imageUrl == null
                ? const Icon(Icons.auto_stories_outlined, color: Colors.white54)
                : AppNetworkImage(
                    imageUrl: imageUrl,
                    tag: 'UserProfileTopicsList.cover',
                    fit: BoxFit.cover,
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
                stops: [0.45, 1],
              ),
            ),
          ),
          Positioned(
            left: 10,
            right: 10,
            bottom: 12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  text: topic.title ?? 'Untitled',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bold(fontSize: 16, color: Colors.white),
                ),
                const SizedBox(height: 2),
                AppText(
                  text: subtitleText,
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
    );
  }
}

class _LoadingList extends StatelessWidget {
  const _LoadingList();

  @override
  Widget build(BuildContext context) {
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
      itemBuilder: (_, _) => const _ShimmerTile(),
    );
  }
}

class _ShimmerTile extends StatelessWidget {
  const _ShimmerTile();

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
          AppText(
            text: message ?? 'Something went wrong',
            textAlign: TextAlign.center,
            style: AppTextStyles.regular(fontSize: 14, color: settingsMuted),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: onRetry,
            child: Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.buttonBackground,
                borderRadius: BorderRadius.circular(22),
              ),
              child: AppText(
                text: 'Retry',
                style: AppTextStyles.semibold(fontSize: 15, color: AppColors.onFill),
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
          AppText(
            text: 'No series yet',
            style: AppTextStyles.regular(fontSize: 14, color: settingsMuted),
          ),
        ],
      ),
    );
  }
}
