import 'package:flutter_animate/flutter_animate.dart';
import 'package:redstreakapp/core/extensions/color.extensions.dart';
import 'package:redstreakapp/core/utils/app_imports.dart';
import 'package:redstreakapp/models/curiosity_reading/curiosity_reading_model.dart';

class CuriosityReadingContent extends StatelessWidget {
  const CuriosityReadingContent({
    super.key,
    required this.reading,
  });

  final Reading reading;

  List<String> get _paragraphs => reading.body.article
      .split(RegExp(r'\n\s*\n'))
      .map((p) => p.trim())
      .where((p) => p.isNotEmpty)
      .toList();

  @override
  Widget build(BuildContext context) {
    final body = reading.body;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ..._paragraphs.asMap().entries.map(
          (entry) => Padding(
            padding: EdgeInsets.only(bottom: 16.h),
            child: AppText(
              text: entry.value,
              style: AppTextStyles.regular(
                fontSize: 16,
                color: AppColors.black.setOpacity(0.82),
              ).copyWith(height: 1.65, letterSpacing: 0.1),
            ).animate().fadeInRight(
              delay: Duration(milliseconds: 150 + (entry.key * 80)),
              curve: Curves.decelerate,
            ),
          ),
        ),
        if (body.quote.trim().isNotEmpty) ...[
          20.h.verticalSpace,
          _QuoteSection(quote: body.quote.trim())
              .animate()
              .fadeInRight(delay: 450.ms, curve: Curves.decelerate),
        ],
        32.h.verticalSpace,
      ],
    );
  }
}

class _QuoteSection extends StatelessWidget {
  const _QuoteSection({required this.quote});

  final String quote;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border(
          left: BorderSide(color: AppColors.teal, width: 4.w),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.teal.setOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(18.w, 16.h, 18.w, 18.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.format_quote_rounded,
            color: AppColors.teal.setOpacity(0.55),
            size: 28.r,
          ),
          6.h.verticalSpace,
          AppText(
            text: quote,
            style: AppTextStyles.semiBold(
              fontSize: 15,
              color: AppColors.black.setOpacity(0.75),
            ).copyWith(
              height: 1.5,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
