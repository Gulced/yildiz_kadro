import 'package:yildiz_kadro/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:yildiz_kadro/app/theme/app_colors.dart';
import 'package:yildiz_kadro/app/theme/app_spacing.dart';

class SeasonMark extends StatelessWidget {
  const SeasonMark({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          isAppEnglish(context) ? 'SEASON 01' : 'SEZON 01',
          style: Theme.of(context)
              .textTheme
              .labelMedium
              ?.copyWith(color: AppColors.accentSoft),
        ),
        const SizedBox(width: AppSpacing.md),
        const Expanded(
          child: Divider(color: AppColors.accent, thickness: 1, height: 1),
        ),
      ],
    );
  }
}
