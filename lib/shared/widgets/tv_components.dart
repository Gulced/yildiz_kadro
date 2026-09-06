import 'package:flutter/material.dart';
import 'package:yildiz_kadro/app/theme/app_colors.dart';
import 'package:yildiz_kadro/app/theme/app_spacing.dart';
import 'package:yildiz_kadro/app/theme/app_typography.dart';
import 'package:yildiz_kadro/features/contestants/domain/contestant.dart';
import 'package:yildiz_kadro/features/contestants/presentation/widgets/contestant_portrait.dart';

/// Editorial TV category header with broadcast eyebrow, headline and subhead.
class TvSectionHeader extends StatelessWidget {
  const TvSectionHeader({
    required this.eyebrow,
    required this.title,
    this.subtitle,
    this.trailing,
    super.key,
  });

  final String eyebrow;
  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.accentInk,
                border:
                    Border.all(color: AppColors.accent.withValues(alpha: 0.6)),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                eyebrow.toUpperCase(),
                style: AppTypography.tvEyebrow,
              ),
            ),
            if (trailing != null) ...[
              const Spacer(),
              trailing!,
            ],
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          title,
          style: AppTypography.tvHeadline,
        ),
        if (subtitle != null && subtitle!.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            subtitle!,
            style: AppTypography.tvSubhead,
          ),
        ],
      ],
    );
  }
}

/// Compact editorial pill badge for roles, statuses, and tags.
class TvBadge extends StatelessWidget {
  const TvBadge({
    required this.label,
    this.color,
    this.borderColor,
    this.textColor,
    this.isAccent = false,
    this.icon,
    super.key,
  });

  final String label;
  final Color? color;
  final Color? borderColor;
  final Color? textColor;
  final bool isAccent;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final bg = color ?? (isAccent ? AppColors.accentInk : AppColors.inkSoft);
    final border =
        borderColor ?? (isAccent ? AppColors.accentBright : AppColors.line);
    final text =
        textColor ?? (isAccent ? AppColors.accentBright : AppColors.paper);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: border, width: isAccent ? 1.5 : 1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 11, color: text),
            const SizedBox(width: 4),
          ],
          Text(
            label.toUpperCase(),
            style: TextStyle(
              color: text,
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}

/// Gamified metric delta pill (+15K TAKİPÇİ, +5 POPÜLERLİK, -2 RİSK).
class TvMetricDeltaBadge extends StatelessWidget {
  const TvMetricDeltaBadge({
    required this.label,
    this.isPositive = true,
    this.secondary,
    super.key,
  });

  final String label;
  final bool isPositive;
  final String? secondary;

  @override
  Widget build(BuildContext context) {
    final color =
        isPositive ? const Color(0xFF4EFA9A) : const Color(0xFFFF6B6B);
    final bgColor = isPositive
        ? const Color(0xFF0D2818).withValues(alpha: 0.85)
        : const Color(0xFF2E0D14).withValues(alpha: 0.85);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: color.withValues(alpha: 0.6)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text.rich(
        TextSpan(
          text: label,
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.3,
          ),
          children: [
            if (secondary != null) ...[
              const TextSpan(text: ' '),
              TextSpan(
                text: secondary!,
                style: const TextStyle(
                  color: AppColors.paperMuted,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// TV Reality-Show Decision Card with short title, 1-line description, and impact preview badges.
class TvDecisionCard extends StatelessWidget {
  const TvDecisionCard({
    required this.title,
    required this.description,
    required this.isSelected,
    required this.onTap,
    this.estimatedEffects = const [],
    this.selectedBadgeText,
    super.key,
  });

  final String title;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;
  final List<({String label, bool isPositive})> estimatedEffects;
  final String? selectedBadgeText;

  @override
  Widget build(BuildContext context) {
    final isEnglish = Localizations.localeOf(context).languageCode == 'en';
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.accentInk.withValues(alpha: 0.6)
            : AppColors.inkSoft,
        border: Border.all(
          color: isSelected ? AppColors.accentBright : AppColors.line,
          width: isSelected ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          color: isSelected ? AppColors.paper : AppColors.paper,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                    if (isSelected)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Text(
                          selectedBadgeText ??
                              (isEnglish ? '✓ SELECTED' : '✓ SEÇİLDİ'),
                          style: const TextStyle(
                            color: AppColors.accentInk,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                  ],
                ),
                if (description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      color: AppColors.paperMuted,
                      fontSize: 13,
                      height: 1.35,
                    ),
                  ),
                ],
                if (estimatedEffects.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: estimatedEffects
                        .map(
                          (effect) => TvMetricDeltaBadge(
                            label: effect.label,
                            isPositive: effect.isPositive,
                          ),
                        )
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Compact Contestant Chip for Team grids and rankings.
class TvContestantChip extends StatelessWidget {
  const TvContestantChip({
    required this.contestant,
    this.roleLabel,
    this.isCaptain = false,
    this.onTap,
    this.isCompact = false,
    super.key,
  });

  final Contestant contestant;
  final String? roleLabel;
  final bool isCaptain;
  final VoidCallback? onTap;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: isCaptain ? AppColors.accentInk : AppColors.inkSoft,
          border: Border.all(
            color: isCaptain ? AppColors.accentBright : AppColors.line,
            width: isCaptain ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipOval(
              child: SizedBox(
                width: isCompact ? 26 : 32,
                height: isCompact ? 26 : 32,
                child: ContestantPortrait(contestant: contestant),
              ),
            ),
            const SizedBox(width: 6),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      contestant.displayName,
                      style: TextStyle(
                        color: AppColors.paper,
                        fontSize: isCompact ? 12 : 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (isCaptain) ...[
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: const Text(
                          'KAPTAN',
                          style: TextStyle(
                            color: AppColors.accentInk,
                            fontSize: 8,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (roleLabel != null)
                  Text(
                    roleLabel!,
                    style: const TextStyle(
                      color: AppColors.accentBright,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.4,
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

/// Compact TV score meter for Vokal, Dans, Sahne, Uyum.
class TvScoreMeter extends StatelessWidget {
  const TvScoreMeter({
    required this.label,
    required this.score,
    this.maxScore = 100,
    super.key,
  });

  final String label;
  final int score;
  final int maxScore;

  @override
  Widget build(BuildContext context) {
    final ratio = (score / maxScore).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label.toUpperCase(),
              style: const TextStyle(
                color: AppColors.paperMuted,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              ),
            ),
            Text(
              '$score',
              style: const TextStyle(
                color: AppColors.paper,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 3),
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: SizedBox(
            height: 4,
            child: LinearProgressIndicator(
              value: ratio,
              backgroundColor: AppColors.line,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.accentBright),
            ),
          ),
        ),
      ],
    );
  }
}
