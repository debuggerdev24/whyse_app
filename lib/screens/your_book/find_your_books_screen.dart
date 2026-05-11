import 'package:redstreakapp/core/extensions/color.extensions.dart';
import 'package:redstreakapp/core/utils/app_imports.dart';
import 'package:redstreakapp/core/widgets/app_network_image.dart';
import 'package:redstreakapp/screens/your_book/widget/search_books_field.dart';
import 'package:shimmer/shimmer.dart';

class FindYourBooksScreen extends StatefulWidget {
  const FindYourBooksScreen({super.key});

  @override
  State<FindYourBooksScreen> createState() => _FindYourBooksScreenState();
}

class _FindYourBooksScreenState extends State<FindYourBooksScreen> {
  late final TextEditingController _searchController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool get _hasSearchQuery => _searchQuery.trim().isNotEmpty;

  List<_SearchResultBook> get _filteredSearchBooks {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) return _searchResultBooks;
    return _searchResultBooks.where((book) {
      return book.title.toLowerCase().startsWith(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: AppText(
          text: 'Find Your Books',
          style: AppTextStyles.semiBold(fontSize: 20),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: SearchBooksField(
              controller: _searchController,
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
            ),
          ),
          16.h.verticalSpace,
          Container(
            height: 1,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.black.setOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
          Expanded(
            child: _hasSearchQuery
                ? _SearchResultSection(
                    query: _searchQuery.trim(),
                    items: _filteredSearchBooks,
                  )
                : SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.only(bottom: 20.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        30.h.verticalSpace,
                        _BookShelfRow(
                          title: 'Books read by your Friends',
                          items: [
                            _ShelfBook(
                              coverUrl:
                                  'https://picsum.photos/seed/wimpy-e1/320/480',
                              title: 'Diary of a Wimpy Kid',
                              author: 'Jeff Kinney',
                            ),
                            _ShelfBook(
                              coverUrl:
                                  'https://picsum.photos/seed/wimpy-e2/320/480',
                              title: 'Diary of a Wimpy Kid: Rodrick Rules',
                              author: 'Jeff Kinney',
                            ),
                            _ShelfBook(
                              coverUrl:
                                  'https://picsum.photos/seed/wimpy-e3/320/480',
                              title: 'Diary of a Wimpy Kid: The Last Straw',
                              author: 'Jeff Kinney',
                            ),
                            _ShelfBook(
                              coverUrl:
                                  'https://picsum.photos/seed/wimpy-e4/320/480',
                              title: 'Diary of a Wimpy Kid: Dog Days',
                              author: 'Jeff Kinney',
                            ),
                            _ShelfBook(
                              coverUrl:
                                  'https://picsum.photos/seed/wimpy-e5/320/480',
                              title: 'Diary of a Wimpy Kid: The Ugly Truth',
                              author: 'Jeff Kinney',
                            ),
                          ],
                        ),
                        28.h.verticalSpace,
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 24.w),
                          child: AppText(
                            text: 'Recommended for you',
                            style: AppTextStyles.bold(
                              fontSize: 22.sp,
                              color: AppColors.black,
                            ),
                          ),
                        ),
                        8.h.verticalSpace,
                        _RecommendedBooksList(items: _recommendedBooks),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

const List<_RecommendedBook> _recommendedBooks = [
  _RecommendedBook(
    coverUrl: 'https://picsum.photos/seed/reco-book-1/360/520',
    author: 'Barbara Park',
    title: 'Junie B. Jones #21: Cheater Pants',
    description:
        'Meet the World\'s Funniest First Grader - Junie B. Jones! Junie B. has all the answers when it comes to cheating. It\'s just plain wrong. But what about copying someone else\'s homework?',
  ),
  _RecommendedBook(
    coverUrl: 'https://picsum.photos/seed/reco-book-2/360/520',
    author: 'Matheus Rothe',
    title: 'The Lion Who Was Scared',
    description:
        'In the vast and colorful savanna, there lived a lion named Leo. With a golden and strong mane, he was the King of the Jungle, but he kept a secret: Leo was terrified of almost everything!',
  ),
  _RecommendedBook(
    coverUrl: 'https://picsum.photos/seed/reco-book-3/360/520',
    author: 'Eleanor Bright',
    title: 'Mila and the Moonlight Map',
    description:
        'When a glowing map appears under Mila\'s pillow, she follows it into hidden tunnels beneath her town and discovers that courage can be learned one tiny step at a time.',
  ),
  _RecommendedBook(
    coverUrl: 'https://picsum.photos/seed/reco-book-4/360/520',
    author: 'Noah Wren',
    title: 'The Clockwork Treehouse',
    description:
        'Arun and Nia climb into a mysterious treehouse where every room moves on gears. To get home, they must solve puzzles before sunrise.',
  ),
  _RecommendedBook(
    coverUrl: 'https://picsum.photos/seed/reco-book-5/360/520',
    author: 'Sofia Hill',
    title: 'Piper and the Paper Dragon',
    description:
        'A folded paper dragon springs to life and drags Piper into a festival world made of lanterns, music, and magical stories.',
  ),
  _RecommendedBook(
    coverUrl: 'https://picsum.photos/seed/reco-book-6/360/520',
    author: 'Kai Morrison',
    title: 'Detectives of Maple Street',
    description:
        'Three friends open a detective club and hunt for clues to solve the mystery of disappearing library books in their neighborhood.',
  ),
  _RecommendedBook(
    coverUrl: 'https://picsum.photos/seed/reco-book-7/360/520',
    author: 'Luna Grant',
    title: 'The Secret of Starfall Lake',
    description:
        'On summer vacation, Ava finds an old telescope that reveals constellations hidden beneath the lake and an adventure tied to her family history.',
  ),
  _RecommendedBook(
    coverUrl: 'https://picsum.photos/seed/reco-book-8/360/520',
    author: 'Theo Collins',
    title: 'Robo-Racers Academy',
    description:
        'At a school for inventors, Jay enters a robot race with a machine that is fast, funny, and full of surprising glitches.',
  ),
  _RecommendedBook(
    coverUrl: 'https://picsum.photos/seed/reco-book-9/360/520',
    author: 'Ivy Rhodes',
    title: 'The Whispering Library',
    description:
        'Books begin whispering after midnight, and two siblings must decode their messages to protect their town from an ancient storm.',
  ),
  _RecommendedBook(
    coverUrl: 'https://picsum.photos/seed/reco-book-10/360/520',
    author: 'Mason Gray',
    title: 'Journey to Cloud Castle',
    description:
        'Finn builds a kite big enough to fly and lands in a castle above the clouds where friendship is the key to unlocking every door.',
  ),
];

const List<_SearchResultBook> _searchResultBooks = [
  _SearchResultBook(
    coverUrl: 'https://picsum.photos/seed/wimpy-s1/300/450',
    author: 'Jeff Kinney',
    title: 'Diary of a Wimpy Kid (Book 1)',
    description:
        'For the adult readers of this book, it will make them feel nostalgic about their good old childhood days and help them recall how they struggled in the same way as Greg Heffley.',
  ),
  _SearchResultBook(
    coverUrl: 'https://picsum.photos/seed/wimpy-s2/300/450',
    author: 'Jeff Kinney',
    title: 'Diary of a Wimpy Kid 5 : The Ugly Truth',
    description:
        'For the adult readers of this book, it will make them feel nostalgic about their good old childhood days and help them recall how they struggled in the same way as Greg Heffley.',
  ),
  _SearchResultBook(
    coverUrl: 'https://picsum.photos/seed/wimpy-s3/300/450',
    author: 'Jeff Kinney',
    title: 'Diary of a Wimpy Kid #9 : The Long Haul',
    description:
        'For the adult readers of this book, it will make them feel nostalgic about their good old childhood days and help them recall how they struggled in the same way as Greg Heffley.',
  ),
  _SearchResultBook(
    coverUrl: 'https://picsum.photos/seed/wimpy-s4/300/450',
    author: 'Jeff Kinney',
    title: 'Diary of a Wimpy Kid 2 : Rodrick Rules',
    description:
        'Diary of a Wimpy Kid: Rodrick Rules is a sequel to the acclaimed hit, Diary of a Wimpy Kid and captures Greg\'s next big year in middle school.',
  ),
  _SearchResultBook(
    coverUrl: 'https://picsum.photos/seed/search-s5/300/450',
    author: 'Barbara Park',
    title: 'Junie B. Jones #21: Cheater Pants',
    description:
        'Meet the World\'s Funniest First Grader, Junie B. Jones. But what about copying someone else\'s homework?',
  ),
  _SearchResultBook(
    coverUrl: 'https://picsum.photos/seed/search-s6/300/450',
    author: 'Matheus Rothe',
    title: 'The Lion Who Was Scared',
    description:
        'A lion named Leo keeps a big secret: despite being king of the jungle, he is afraid of almost everything.',
  ),
  _SearchResultBook(
    coverUrl: 'https://picsum.photos/seed/search-s7/300/450',
    author: 'Eleanor Bright',
    title: 'Mila and the Moonlight Map',
    description:
        'A glowing map sends Mila into hidden tunnels beneath her town where she learns what courage really looks like.',
  ),
  _SearchResultBook(
    coverUrl: 'https://picsum.photos/seed/search-s8/300/450',
    author: 'Noah Wren',
    title: 'The Clockwork Treehouse',
    description:
        'A moving treehouse filled with gears, rooms, and riddles becomes the greatest puzzle two friends have ever faced.',
  ),
  _SearchResultBook(
    coverUrl: 'https://picsum.photos/seed/search-s9/300/450',
    author: 'Luna Grant',
    title: 'The Secret of Starfall Lake',
    description:
        'An old telescope reveals constellations hidden beneath a lake and opens a mystery tied to family history.',
  ),
  _SearchResultBook(
    coverUrl: 'https://picsum.photos/seed/search-s10/300/450',
    author: 'Ivy Rhodes',
    title: 'The Whispering Library',
    description:
        'At midnight, books whisper clues that two siblings must decode to save their town from an ancient storm.',
  ),
];

class _BookShelfRow extends StatelessWidget {
  const _BookShelfRow({required this.title, required this.items});

  final String title;
  final List<_ShelfBook> items;

  @override
  Widget build(BuildContext context) {
    final coverWidth = 95.h;
    final coverHeight = 100.h * 1.48;
    final listHeight = coverHeight + 8.h + 34.h + 4.h + 18.h;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: AppText(
            text: title,
            style: AppTextStyles.bold(fontSize: 20, color: AppColors.black),
          ),
        ),
        10.h.verticalSpace,
        SizedBox(
          height: listHeight,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.only(left: 24.w, right: 24.w),
            itemCount: items.length,
            separatorBuilder: (_, __) => 14.w.horizontalSpace,
            itemBuilder: (_, index) {
              return _ShelfBookTile(
                book: items[index],
                coverWidth: coverWidth,
                coverHeight: coverHeight,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ShelfBook {
  const _ShelfBook({
    required this.coverUrl,
    required this.title,
    required this.author,
  });

  final String coverUrl;
  final String title;
  final String author;
}

class _RecommendedBook {
  const _RecommendedBook({
    required this.coverUrl,
    required this.author,
    required this.title,
    required this.description,
  });

  final String coverUrl;
  final String author;
  final String title;
  final String description;
}

class _SearchResultBook {
  const _SearchResultBook({
    required this.coverUrl,
    required this.author,
    required this.title,
    required this.description,
  });

  final String coverUrl;
  final String author;
  final String title;
  final String description;
}

class _SearchResultSection extends StatelessWidget {
  const _SearchResultSection({required this.query, required this.items});

  final String query;
  final List<_SearchResultBook> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        12.h.verticalSpace,
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: AppText(
            text: '"$query"',
            style: AppTextStyles.semiBold(fontSize: 31, color: AppColors.black),
          ),
        ),
        12.h.verticalSpace,
        Expanded(
          child: items.isEmpty
              ? Center(
                  child: AppText(
                    text: 'No books found',
                    style: AppTextStyles.medium(
                      fontSize: 14,
                      color: AppColors.black.setOpacity(0.6),
                    ),
                  ),
                )
              : ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.only(
                    left: 24.w,
                    right: 24.w,
                    bottom: 20.h,
                  ),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => Divider(
                    height: 1,
                    thickness: 1,
                    color: AppColors.black.setOpacity(0.1),
                  ),
                  itemBuilder: (_, index) =>
                      _SearchResultBookTile(book: items[index]),
                ),
        ),
      ],
    );
  }
}

class _SearchResultBookTile extends StatelessWidget {
  const _SearchResultBookTile({required this.book});

  final _SearchResultBook book;

  @override
  Widget build(BuildContext context) {
    final imageWidth = 82.w;
    final imageHeight = 120.h;

    return InkWell(
      onTap: () => context.pushNamed(AppRoutes.bookDetailsScreen.name),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 18.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Container(
            width: imageWidth,
            height: imageHeight,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.r),
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withValues(alpha: 0.08),
                  blurRadius: 10,
                  offset: Offset(0, 4.h),
                ),
              ],
            ),
            child: AppNetworkImage(
              imageUrl: book.coverUrl,
              tag: 'FindYourBooks.searchResult',
              borderRadius: BorderRadius.circular(8.r),
              placeholder: (_) => _ShelfImageShimmer(
                borderRadius: BorderRadius.circular(8.r),
              ),
              errorBuilder: (_, __, ___) =>
                  _ShelfImageError(borderRadius: BorderRadius.circular(8.r)),
            ),
          ),
            12.w.horizontalSpace,
            Expanded(
              child: SizedBox(
                height: imageHeight,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  AppText(
                    text: book.author,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.medium(
                      fontSize: 11,
                      color: AppColors.black.setOpacity(0.82),
                    ),
                  ),
                  5.h.verticalSpace,
                  AppText(
                    text: book.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bold(
                      fontSize: 17,
                      color: AppColors.black,
                    ),
                  ),
                    7.h.verticalSpace,
                    Expanded(
                      child: AppText(
                        text: book.description,
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.medium(
                          fontSize: 12,
                          color: AppColors.black.setOpacity(0.62),
                        ),
                      ),
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

class _RecommendedBooksList extends StatelessWidget {
  const _RecommendedBooksList({required this.items});

  final List<_RecommendedBook> items;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: items.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      separatorBuilder: (_, __) => Divider(
        height: 1,
        thickness: 1,
        color: AppColors.black.setOpacity(0.08),
      ),
      itemBuilder: (_, index) => _RecommendedBookTile(book: items[index]),
    );
  }
}

class _RecommendedBookTile extends StatelessWidget {
  const _RecommendedBookTile({required this.book});

  final _RecommendedBook book;

  @override
  Widget build(BuildContext context) {
    final imageWidth = 94.h;
    final imageHeight = 136.h;

    return InkWell(
      onTap: () => context.pushNamed(AppRoutes.bookDetailsScreen.name),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Container(
            width: imageWidth,
            height: imageHeight,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.r),
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withValues(alpha: 0.08),
                  blurRadius: 16,
                  offset: Offset(0, 8.h),
                ),
              ],
            ),
            child: AppNetworkImage(
              imageUrl: book.coverUrl,
              tag: 'FindYourBooks.recommended',
              width: imageWidth,
              height: imageHeight,
              borderRadius: BorderRadius.circular(10.r),
              placeholder: (_) => _ShelfImageShimmer(
                borderRadius: BorderRadius.circular(10.r),
              ),
              errorBuilder: (_, __, ___) =>
                  _ShelfImageError(borderRadius: BorderRadius.circular(10.r)),
            ),
          ),
            16.w.horizontalSpace,
            Expanded(
              child: SizedBox(
                height: imageHeight,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  AppText(
                    text: book.author,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.semiBold(
                      fontSize: 12,
                      color: AppColors.black.setOpacity(0.88),
                    ),
                  ),
                  5.h.verticalSpace,
                  AppText(
                    text: book.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bold(
                      fontSize: 16,
                      color: AppColors.black,
                    ),
                  ),
                    5.h.verticalSpace,
                    Expanded(
                      child: AppText(
                        text: book.description,
                        maxLines: 6,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.medium(
                          fontSize: 12,
                          color: AppColors.black.setOpacity(0.8),
                        ),
                      ),
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

class _ShelfBookTile extends StatelessWidget {
  const _ShelfBookTile({
    required this.book,
    required this.coverWidth,
    required this.coverHeight,
  });

  final _ShelfBook book;
  final double coverWidth;
  final double coverHeight;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: coverWidth,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: coverWidth,
            height: coverHeight,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 10,
                  offset: Offset(0, 5.h),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: AppNetworkImage(
              imageUrl: book.coverUrl,
              tag: 'FindYourBooks.shelfCover',
              width: coverWidth,
              height: coverHeight,
              borderRadius: BorderRadius.circular(14.r),
              placeholder: (_) => _ShelfImageShimmer(
                borderRadius: BorderRadius.circular(14.r),
              ),
              errorBuilder: (_, __, ___) =>
                  _ShelfImageError(borderRadius: BorderRadius.circular(14.r)),
            ),
          ),
          8.h.verticalSpace,
          AppText(
            text: book.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bold(
              fontSize: 14.sp,
              color: AppColors.black,
              height: 1.2,
            ),
          ),
          4.h.verticalSpace,
          AppText(
            text: book.author,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.semiBold(
              fontSize: 12.sp,

              color: AppColors.black.setOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShelfImageShimmer extends StatelessWidget {
  const _ShelfImageShimmer({required this.borderRadius});

  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE7E9EC),
      highlightColor: const Color(0xFFF5F6F8),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFE7E9EC),
          borderRadius: borderRadius,
        ),
      ),
    );
  }
}

class _ShelfImageError extends StatelessWidget {
  const _ShelfImageError({required this.borderRadius});

  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFECEFF3),
        borderRadius: borderRadius,
      ),
      alignment: Alignment.center,
      child: Icon(
        Icons.menu_book_outlined,
        color: AppColors.black.withValues(alpha: 0.35),
        size: 32.w,
      ),
    );
  }
}
