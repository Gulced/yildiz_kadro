import 'package:yildiz_kadro/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:yildiz_kadro/app/theme/app_colors.dart';
import 'package:yildiz_kadro/app/theme/app_spacing.dart';

class StatBar extends StatelessWidget {
  const StatBar({required this.label, required this.value, super.key});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    final isEn = isAppEnglish(context);
    return Semantics(
      label:
          isEn ? '$label, $value out of 100' : '$label, 100 üzerinden $value',
      excludeSemantics: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ),
              Text(
                '$value',
                style: Theme.of(context)
                    .textTheme
                    .labelLarge
                    ?.copyWith(color: AppColors.accentBright),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(2)),
            child: LinearProgressIndicator(
              value: value / 100,
              minHeight: 7,
              backgroundColor: AppColors.line,
              color: AppColors.accent,
            ),
          ),
        ],
      ),
    );
  }
}
