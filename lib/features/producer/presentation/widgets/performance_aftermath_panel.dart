import 'package:flutter/material.dart';
import 'package:yildiz_kadro/app/theme/app_colors.dart';
import 'package:yildiz_kadro/app/theme/app_spacing.dart';
import 'package:yildiz_kadro/features/contestants/data/contestant_seed_data.dart';
import 'package:yildiz_kadro/features/contestants/presentation/widgets/contestant_portrait.dart';
import 'package:yildiz_kadro/features/game/application/game_scope.dart';
import 'package:yildiz_kadro/features/producer/domain/performance_aftermath.dart';

class PerformanceAftermathPanel extends StatelessWidget {
  const PerformanceAftermathPanel({
    required this.stageId,
    this.contestantIds,
    this.limit = 4,
    super.key,
  });

  final String stageId;
  final Iterable<int>? contestantIds;
  final int limit;

  @override
  Widget build(BuildContext context) {
    final aftermath = GameScope.of(context).performanceAftermath(stageId);
    if (aftermath == null) return const SizedBox.shrink();
    final filter = contestantIds?.toSet();
    final changes = aftermath.changes
        .where(
          (change) => filter == null || filter.contains(change.contestantId),
        )
        .take(limit)
        .toList();
    if (changes.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppSpacing.xl),
        Text('PERFORMANS SONRASI', style: _label(context)),
        const SizedBox(height: AppSpacing.sm),
        ...changes.map((change) => _ChangeCard(change: change)),
      ],
    );
  }

  TextStyle _label(BuildContext context) => Theme.of(context)
      .textTheme
      .labelLarge!
      .copyWith(color: AppColors.accentBright, letterSpacing: 1.1);
}

class _ChangeCard extends StatelessWidget {
  const _ChangeCard({required this.change});
  final PerformanceChange change;

  @override
  Widget build(BuildContext context) {
    final contestant = contestantSeedData.firstWhere(
      (value) => value.id == change.contestantId,
    );
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.inkSoft,
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipOval(
            child: SizedBox(
              width: 48,
              height: 48,
              child: ContestantPortrait(contestant: contestant),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contestant.displayName,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  'TAKİPÇİ ${_followers(change.before.followers)} → ${_followers(change.after.followers)} (${_signedFollowers(change.followerDelta)})',
                ),
                Text(
                  'POPÜLERLİK ${change.before.popularity} → ${change.after.popularity}  •  MOTİVASYON ${change.before.motivation} → ${change.after.motivation}',
                ),
                Text(
                  'XP ${change.before.experienceXp} → ${change.after.experienceXp} (${_signed(change.xpDelta)})${change.leveledUp ? '  •  SEVİYE ATLADI ${change.before.level} → ${change.after.level}' : ''}',
                  style: TextStyle(
                    color: change.leveledUp
                        ? AppColors.accentBright
                        : AppColors.paperMuted,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  change.reason,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _followers(int value) => value >= 1000000
      ? '${(value / 1000000).toStringAsFixed(1)}M'
      : '${(value / 1000).round()}K';
  String _signedFollowers(int value) =>
      '${value >= 0 ? '+' : ''}${_followers(value.abs())}';
  String _signed(int value) => '${value >= 0 ? '+' : ''}$value';
}
