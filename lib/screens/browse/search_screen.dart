import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:redstreakapp/core/constants/app_color.dart';
import 'package:redstreakapp/core/constants/text_style.dart';
import 'package:redstreakapp/core/utils/de_bouncing.dart';
import 'package:redstreakapp/core/widgets/app_layout.dart';
import 'package:redstreakapp/core/widgets/app_text.dart';
import 'package:redstreakapp/core/widgets/custom_toast.dart';
import 'package:redstreakapp/models/home/browse_topic_model.dart';
import 'package:redstreakapp/screens/dashboard.dart';
import 'package:redstreakapp/screens/browse/widgets/browse_widgets.dart';
import 'package:redstreakapp/services/home/home_api_service.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  static const String _allFilter = "All";
  static const int _pageSize = 20;

  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<BrowseTopicModel> _topics = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  String? _errorMessage;
  String _selectedInterest = _allFilter;
  final Set<String> _togglingTopicIds = <String>{};
  int _currentPage = 1;
  int _requestId = 0;

  List<String> get _interestFilters {
    final interests =
        _topics
            .expand((topic) => topic.interests)
            .where((interest) => interest.trim().isNotEmpty)
            .toSet()
            .toList()
          ..sort();

    return [_allFilter, ...interests];
  }

  List<BrowseTopicModel> get _visibleTopics {
    if (_selectedInterest == _allFilter) {
      return _topics;
    }
    return _topics
        .where((topic) => topic.interests.contains(_selectedInterest))
        .toList();
  }

  bool get _isSearching => _searchController.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    tabIndex.addListener(_handleTabChange);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchTopics(reset: true);
    });
  }

  @override
  void dispose() {
    deBouncer.timer?.cancel();
    tabIndex.removeListener(_handleTabChange);
    _searchController.dispose();
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (!mounted || tabIndex.value != 1) return;
    _clearSearchAndReload();
  }

  void _clearSearchAndReload() {
    deBouncer.timer?.cancel();
    FocusScope.of(context).unfocus();

    if (_searchController.text.isNotEmpty || _selectedInterest != _allFilter) {
      _searchController.clear();
      setState(() {
        _selectedInterest = _allFilter;
        _errorMessage = null;
      });
    }

    _fetchTopics(reset: true);
  }

  void _onScroll() {
    if (!_scrollController.hasClients ||
        _isLoading ||
        _isLoadingMore ||
        !_hasMore) {
      return;
    }

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;

    if (currentScroll >= (maxScroll - 300)) {
      _fetchTopics(loadMore: true);
    }
  }

  Future<void> _fetchTopics({
    bool showLoader = true,
    bool reset = false,
    bool loadMore = false,
  }) async {
    if (reset) {
      _currentPage = 1;
      _hasMore = true;
    }

    if (loadMore) {
      if (_isLoading || _isLoadingMore || !_hasMore) return;
      setState(() {
        _isLoadingMore = true;
      });
    } else if (showLoader) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    final int requestId = ++_requestId;
    final int pageToLoad = loadMore ? _currentPage + 1 : 1;
    final response = await HomeApiService.instance.browseAllTopics(
      search: _searchController.text.trim(),
      page: pageToLoad,
    );

    if (!mounted || requestId != _requestId) return;

    response.fold(
      (error) {
        setState(() {
          _isLoading = false;
          _isLoadingMore = false;
          if (!loadMore) {
            _topics = [];
            _errorMessage = error.errorMsg;
            _selectedInterest = _allFilter;
            _hasMore = false;
            _currentPage = 1;
          }
        });
        AppToast.error(context, error.errorMsg);
      },
      (result) {
        final data = result["data"];
        final parsedTopics = data is List
            ? data
                  .map(
                    (topic) => BrowseTopicModel.fromJson(
                      Map<String, dynamic>.from(topic as Map),
                    ),
                  )
                  .toList()
            : <BrowseTopicModel>[];

        final mergedTopics = loadMore
            ? [..._topics, ...parsedTopics]
            : parsedTopics;
        final uniqueTopics = <BrowseTopicModel>[];
        final uniqueIds = <String>{};
        for (final topic in mergedTopics) {
          if (uniqueIds.add(topic.id)) {
            uniqueTopics.add(topic);
          }
        }
        final nextFilters = uniqueTopics
            .expand((topic) => topic.interests)
            .where((interest) => interest.trim().isNotEmpty)
            .toSet();

        setState(() {
          _isLoading = false;
          _isLoadingMore = false;
          _errorMessage = null;
          _topics = uniqueTopics;
          _currentPage = pageToLoad;
          _hasMore = parsedTopics.length >= _pageSize;
          if (_selectedInterest != _allFilter &&
              !nextFilters.contains(_selectedInterest)) {
            _selectedInterest = _allFilter;
          }
        });
      },
    );
  }

  void _onSearchChanged(String value) {
    setState(() {
      if (_errorMessage != null) {
        _errorMessage = null;
      }
    });

    deBouncer.run(() {
      if (!mounted) return;
      _fetchTopics(reset: true);
    });
  }

  void _showTopicDetails(BrowseTopicModel topic) {
    showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BrowseTopicDetailsSheet(topic: topic),
    );
  }

  Future<void> _toggleTopicList(BrowseTopicModel topic) async {
    if (!topic.canManageMyList || _togglingTopicIds.contains(topic.id)) return;

    setState(() {
      _togglingTopicIds.add(topic.id);
    });

    final response = await HomeApiService.instance.toggleTopicList(
      topicId: topic.id,
    );

    if (!mounted) return;

    response.fold(
      (error) {
        setState(() {
          _togglingTopicIds.remove(topic.id);
        });
        AppToast.error(context, error.errorMsg);
      },
      (result) {
        final data = result["data"] is Map
            ? Map<String, dynamic>.from(result["data"] as Map)
            : <String, dynamic>{};
        final bool isInMyList = data["isInMyList"] == true;
        final String topicTitle =
            data["topicTitle"]?.toString().trim().isNotEmpty == true
            ? data["topicTitle"].toString()
            : topic.topic;

        setState(() {
          _togglingTopicIds.remove(topic.id);
          _topics = _topics.map((item) {
            if (item.id != topic.id) return item;
            return item.copyWith(isInMyList: isInMyList);
          }).toList();
        });

        if (isInMyList) {
          final String message =
              result["message"]?.toString().trim().isNotEmpty == true
              ? result["message"].toString()
              : '"$topicTitle" added to My List';
          AppToast.success(context, message);
        } else {
          AppToast.info(
            context: context,
            message: '"$topicTitle" removed from My List',
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final visibleTopics = _visibleTopics;

    return AppLayout(
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.teal,
          backgroundColor: AppColors.white,
          onRefresh: () => _fetchTopics(showLoader: false, reset: true),
          child: ListView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 20.h),
            children: [
              // Browse hero header hidden for now.
              // BrowseSearchHeroHeader(isSearching: _isSearching),
              // 20.h.verticalSpace,
              BrowseSearchField(
                controller: _searchController,
                onChanged: _onSearchChanged,
              ),
              18.h.verticalSpace,
              if (_isLoading)
                const BrowseSearchShimmer()
              else if (_errorMessage != null && _topics.isEmpty)
                BrowseErrorState(onRetry: _fetchTopics)
              else ...[
                // if (_interestFilters.length > 1) ...[
                //   AppText(
                //     text: "Browse by interest",
                //     style: AppTextStyles.sfProDisplaySemibold(fontSize: 16.sp),
                //   ),
                //   14.w.verticalSpace,
                // Wrap(
                //   spacing: 10.w,
                //   runSpacing: 10.h,
                //   children: _interestFilters.map((interest) {
                //     final bool isSelected = interest == _selectedInterest;
                //     return GestureDetector(
                //       onTap: () {
                //         setState(() {
                //           _selectedInterest = interest;
                //         });
                //       },
                //       child: AnimatedContainer(
                //         duration: const Duration(milliseconds: 180),
                //         padding: EdgeInsets.symmetric(
                //           horizontal: 16.w,
                //           vertical: 10.h,
                //         ),
                //         decoration: BoxDecoration(
                //           color: isSelected
                //               ? AppColors.teal
                //               : AppColors.white,
                //           borderRadius: BorderRadius.circular(999),
                //           border: Border.all(
                //             color: isSelected
                //                 ? AppColors.teal
                //                 : AppColors.black.withValues(alpha: 0.09),
                //           ),
                //         ),
                //         child: AppText(
                //           text: interest,
                //           style: AppTextStyles.sfProDisplaySemibold(
                //             fontSize: 13.sp,
                //             color: isSelected
                //                 ? AppColors.white
                //                 : AppColors.black.withValues(alpha: 0.75),
                //           ),
                //         ),
                //       ),
                //     );
                //   }).toList(),
                // ),
                // 22.h.verticalSpace,
                // ],
                if (visibleTopics.isEmpty)
                  BrowseEmptyState(query: _searchController.text.trim())
                else ...[
                  AppText(
                    text: _isSearching
                        ? 'Results for "${_searchController.text.trim()}"'
                        : "Featured right now",
                    style: AppTextStyles.sfProDisplayBold(fontSize: 22.sp),
                  ),
                  14.h.verticalSpace,
                  FeaturedTopicCard(
                    topic: visibleTopics.first,
                    onTap: () => _showTopicDetails(visibleTopics.first),
                    onToggleMyList: visibleTopics.first.canManageMyList
                        ? () => _toggleTopicList(visibleTopics.first)
                        : null,
                    isToggleLoading: _togglingTopicIds.contains(
                      visibleTopics.first.id,
                    ),
                  ),
                  if (visibleTopics.length > 1) ...[
                    24.h.verticalSpace,
                    AppText(
                      text: "More to explore",
                      style: AppTextStyles.sfProDisplaySemibold(
                        fontSize: 18.sp,
                      ),
                    ),
                    14.h.verticalSpace,
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 14.w,
                        mainAxisSpacing: 14.h,
                        childAspectRatio: 0.75,
                      ),
                      itemCount:
                          (visibleTopics.length - 1) +
                          (((visibleTopics.length - 1).isOdd && _hasMore)
                              ? 1
                              : 0),
                      itemBuilder: (context, index) {
                        if (index >= visibleTopics.length - 1) {
                          return const BrowsePosterShimmerTile();
                        }
                        final topic = visibleTopics[index + 1];
                        return PosterTopicCard(
                          topic: topic,
                          onTap: () => _showTopicDetails(topic),
                          onToggleMyList: topic.canManageMyList
                              ? () => _toggleTopicList(topic)
                              : null,
                          isToggleLoading: _togglingTopicIds.contains(topic.id),
                        );
                      },
                    ),
                  ],
                  if (_isLoadingMore) ...[
                    20.h.verticalSpace,
                    const BrowsePaginationShimmer(),
                  ],
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}
