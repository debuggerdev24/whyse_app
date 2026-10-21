import 'package:flutter/material.dart';
import 'package:redstreakapp/core/constants/app_color.dart';
import 'package:redstreakapp/core/constants/text_style.dart';
import 'package:redstreakapp/core/widgets/app_text.dart';

class PlanCard extends StatelessWidget {
  final bool isSelected;
  final VoidCallback onTap;

  final String title;
  final String price;
  final List<String> features;

  const PlanCard({
    super.key,
    required this.isSelected,
    required this.onTap,
    required this.title,
    required this.price,
    required this.features,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 16, 16, 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? AppColors.teal : Colors.transparent,
            width: 1.6,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    text: title,
                    style: AppTextStyles.bold(
                      fontSize: 16,
                      color: const Color(0xFF1C1C1E),
                    ),
                  ),
                  const SizedBox(height: 10),
                  for (final feature in features)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_rounded,
                            size: 16,
                            color: AppColors.teal,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: AppText(
                              text: feature,
                              style: AppTextStyles.medium(
                                fontSize: 14,
                                color: const Color(0xFF1C1C1E),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (isSelected)
                  Container(
                    width: 26,
                    height: 26,
                    margin: const EdgeInsets.only(bottom: 18),
                    decoration: BoxDecoration(
                      color: AppColors.teal,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  )
                else
                  const SizedBox(height: 44),
                AppText(
                  text: price,
                  style: AppTextStyles.bold(
                    fontSize: 16,
                    color: const Color(0xFF1C1C1E),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
