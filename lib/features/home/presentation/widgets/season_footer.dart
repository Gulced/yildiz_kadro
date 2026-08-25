import 'package:flutter/material.dart';
import 'package:yildiz_kadro/app/theme/app_colors.dart';
import 'package:yildiz_kadro/app/theme/app_spacing.dart';

class SeasonFooter extends StatelessWidget {
  const SeasonFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final largeText = MediaQuery.textScalerOf(context).scale(1) >= 1.5;
    final labelStyle = Theme.of(context).textTheme.labelMedium?.copyWith(
          color: AppColors.paper,
          letterSpacing: 1.1,
        );
    final season = _FooterLabel(
      icon: Icons.star_outline_rounded,
      text: 'SEZON 01',
      style: labelStyle,
    );
    final producer = _FooterLabel(
      icon: Icons.tune_rounded,
      text: 'YAPIMCI MODU',
      style: labelStyle,
      iconAfter: true,
    );

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF120E11),
        border: Border.all(color: AppColors.line),
        borderRadius: const BorderRadius.all(Radius.circular(12)),
      ),
      child: largeText
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                season,
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  child: Icon(
                    Icons.auto_awesome,
                    color: AppColors.accent,
                    size: 24,
                  ),
                ),
                producer,
              ],
            )
          : Row(
              children: [
                Expanded(child: season),
                const Icon(
                  Icons.auto_awesome,
                  color: AppColors.accent,
                  size: 24,
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: producer,
                  ),
                ),
              ],
            ),
    );
  }
}

class _FooterLabel extends StatelessWidget {
  const _FooterLabel({
    required this.icon,
    required this.text,
    required this.style,
    this.iconAfter = false,
  });

  final IconData icon;
  final String text;
  final TextStyle? style;
  final bool iconAfter;

  @override
  Widget build(BuildContext context) {
    final iconWidget = Icon(icon, size: 17);
    final textWidget = Flexible(child: Text(text, style: style));
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: iconAfter
          ? [textWidget, const SizedBox(width: AppSpacing.xs), iconWidget]
          : [iconWidget, const SizedBox(width: AppSpacing.xs), textWidget],
    );
  }
}
