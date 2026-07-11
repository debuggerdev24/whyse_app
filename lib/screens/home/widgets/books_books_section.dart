import 'package:redstreakapp/core/extensions/color.extensions.dart';
import 'package:redstreakapp/core/utils/app_imports.dart';
import 'package:redstreakapp/core/widgets/app_network_image.dart';

/// Must match title [TextStyle.height] and two lines in [_ShelfBookTile].
const _kShelfTitleLineHeight = 1.2;

/// Must match author [TextStyle.height] in [_ShelfBookTile].
const _kShelfAuthorLineHeight = 1.35;

/// Horizontal "Ebooks" and "Books" shelves matching the home design reference.
class BooksBooksHomeSections extends StatelessWidget {
  const BooksBooksHomeSections({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _BookShelfRow(
          title: 'Ebooks',
          onAddTap: () {},
          items: const [
            _ShelfBook(
              coverUrl: 'https://picsum.photos/seed/wimpy-e1/320/480',
              title: 'Diary of a Wimpy Kid',
              author: 'Jeff Kinney',
            ),
            _ShelfBook(
              coverUrl: 'https://picsum.photos/seed/wimpy-e2/320/480',
              title: 'Diary of a Wimpy Kid: Rodrick Rules',
              author: 'Jeff Kinney',
            ),
            _ShelfBook(
              coverUrl: 'https://picsum.photos/seed/wimpy-e3/320/480',
              title: 'Diary of a Wimpy Kid: The Last Straw',
              author: 'Jeff Kinney',
            ),
            _ShelfBook(
              coverUrl: 'https://picsum.photos/seed/wimpy-e4/320/480',
              title: 'Diary of a Wimpy Kid: Dog Days',
              author: 'Jeff Kinney',
            ),
            _ShelfBook(
              coverUrl: 'https://picsum.photos/seed/wimpy-e5/320/480',
              title: 'Diary of a Wimpy Kid: The Ugly Truth',
              author: 'Jeff Kinney',
            ),
          ],
        ),
        28.w.verticalSpace,
        _BookShelfRow(
          title: 'Books',
          onAddTap: () {},
          items: const [
            _ShelfBook(
              coverUrl: 'https://picsum.photos/seed/bunny-book/320/480',
              title: "It's Not Easy Being a Bunny",
              author: 'Marilyn Sadler',
            ),
            _ShelfBook(
              coverUrl: 'https://picsum.photos/seed/easter-story/320/480',
              title: 'The Story of Easter',
              author: 'Jean Miller',
            ),
            _ShelfBook(
              coverUrl: 'https://picsum.photos/seed/hybrid-prince/320/480',
              title: 'The Hybrid Prince',
              author: 'Tui T. Sutherland',
            ),
            _ShelfBook(
              coverUrl: 'https://picsum.photos/seed/lost-heir/320/480',
              title: 'The Lost Heir',
              author: 'Tui T. Sutherland',
            ),
          ],
        ),
      ],
    );
  }
}

class _BookShelfRow extends StatelessWidget {
  const _BookShelfRow({
    required this.title,
    required this.items,
    this.onAddTap,
  });

  final String title;
  final List<_ShelfBook> items;
  final VoidCallback? onAddTap;

  @override
  Widget build(BuildContext context) {
    final coverWidth = 95.h;
    final coverHeight = 100.h * 1.48;
    final textScaler = MediaQuery.textScalerOf(context);
    // Reserve vertical space from the same font metrics as [_ShelfBookTile] (not
    // mixed .h guesses): .sp vs .h scale differently and cause bottom overflow.
    final titleFontSize = 14.sp;
    final authorFontSize = 12.sp;
    final titleBlockHeight =
        textScaler.scale(titleFontSize * _kShelfTitleLineHeight * 2);
    final authorBlockHeight =
        textScaler.scale(authorFontSize * _kShelfAuthorLineHeight);
    final listHeight = coverHeight +
        8.h +
        titleBlockHeight +
        4.h +
        authorBlockHeight +
        12;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Row(
            children: [
              Expanded(
                child: AppText(
                  text: title,
                  style: AppTextStyles.bold(
                    fontSize: 20.sp,
                    color: AppColors.black,
                  ),
                ),
              ),
              GestureDetector(
                onTap: onAddTap,
                behavior: HitTestBehavior.opaque,
                child: AppText(
                  text: '+ Add',
                  style: AppTextStyles.semiBold(
                    fontSize: 15.sp,
                    color: AppColors.teal,
                  ),
                ),
              ),
            ],
          ),
        ),
        10.h.verticalSpace,
        SizedBox(
          height: listHeight,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.only(left: 20.w, right: 20.w),
            itemCount: items.length,
            separatorBuilder: (_, _) => 14.w.horizontalSpace,
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
              tag: 'BooksShelf.cover',
              width: coverWidth,
              height: coverHeight,
              borderRadius: BorderRadius.circular(14.r),
              placeholder: (_) => _ShelfImageShimmer(
                borderRadius: BorderRadius.circular(14.r),
              ),
              errorBuilder: (_, _, _) =>
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
              height: _kShelfTitleLineHeight,
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
            ).copyWith(height: _kShelfAuthorLineHeight),
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
    return AppSkeletonizer(
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.shimmerBaseColor,
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
