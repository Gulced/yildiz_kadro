import 'package:flutter/material.dart';
import 'package:yildiz_kadro/app/theme/app_colors.dart';
import 'package:yildiz_kadro/app/theme/app_spacing.dart';
import 'package:yildiz_kadro/features/contestants/domain/contestant.dart';
import 'package:yildiz_kadro/features/contestants/presentation/widgets/contestant_portrait.dart';

class RadarContestantCard extends StatelessWidget {
  const RadarContestantCard({
    required this.contestant,
    required this.isSelected,
    required this.onTap,
    required this.onInfo,
    super.key,
  });

  final Contestant contestant;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onInfo;

  @override
  Widget build(BuildContext context) {
    final strongest = contestant.strongestStat;
    return Semantics(
      button: true,
      selected: isSelected,
      label: '${contestant.name}, ${isSelected ? 'radarda' : 'radarda değil'}',
      child: AnimatedScale(
        scale: isSelected ? 1.012 : 1,
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            color: AppColors.inkSoft,
            borderRadius: const BorderRadius.all(Radius.circular(6)),
            border: Border.all(
              color: isSelected ? AppColors.accentBright : AppColors.line,
              width: isSelected ? 1.5 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.accent.withValues(alpha: 0.18),
                      blurRadius: 18,
                    ),
                  ]
                : null,
          ),
          clipBehavior: Clip.antiAlias,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.all(7),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          ContestantPortrait(contestant: contestant),
                          Align(
                            alignment: Alignment.topLeft,
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Material(
                                color: AppColors.ink.withValues(alpha: .78),
                                shape: const CircleBorder(),
                                child: IconButton(
                                  tooltip: 'Profili incele',
                                  onPressed: onInfo,
                                  icon: const Icon(Icons.visibility_outlined),
                                  iconSize: 19,
                                ),
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.topRight,
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 160),
                                width: 36,
                                height: 36,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.accent
                                      : AppColors.ink.withValues(alpha: 0.78),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.accentBright
                                        : AppColors.paperMuted,
                                  ),
                                ),
                                child: Text(
                                  isSelected ? '★' : '☆',
                                  style: TextStyle(
                                    color: isSelected
                                        ? AppColors.paper
                                        : AppColors.paperMuted,
                                    fontSize: 20,
                                    height: 1,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      '${contestant.displayName} — ${contestant.age}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      contestant.archetype.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: AppColors.accentSoft,
                            letterSpacing: 0.8,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '★ ${strongest.label}  ${strongest.value}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: AppColors.accentBright,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
