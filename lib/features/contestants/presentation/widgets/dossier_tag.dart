import 'package:flutter/material.dart';
import 'package:yildiz_kadro/app/theme/app_colors.dart';
import 'package:yildiz_kadro/app/theme/app_spacing.dart';

class DossierTag extends StatelessWidget {
  const DossierTag({required this.label, this.accent = false, super.key});

  final String label;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 32),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: accent ? AppColors.accent.withValues(alpha: 0.12) : null,
        border: Border.all(color: accent ? AppColors.accent : AppColors.line),
        borderRadius: const BorderRadius.all(Radius.circular(3)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: accent ? AppColors.accentSoft : AppColors.paper,
              letterSpacing: 0.7,
            ),
      ),
    );
  }
}
