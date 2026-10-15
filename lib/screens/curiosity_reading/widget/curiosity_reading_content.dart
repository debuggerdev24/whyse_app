import 'package:flutter_animate/flutter_animate.dart';
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
                color: const Color(0xFF3A3A3C),
              ).copyWith(height: 1.45),
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
        color: const Color(0xFFE5F4EF),
        borderRadius: BorderRadius.circular(18.r),
      ),
      padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 14.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(
              Icons.cloud_outlined,
              color: Color(0xFF1A9B86),
              size: 18,
            ),
          ),
          8.w.horizontalSpace,
          Expanded(
            child: AppText(
              text: quote,
              style: AppTextStyles.medium(
                fontSize: 15.sp,
                color: const Color(0xFF1A9B86),
              ).copyWith(height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
