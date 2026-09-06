import 'package:flutter/material.dart';
import 'package:yildiz_kadro/app/theme/app_colors.dart';
import 'package:yildiz_kadro/app/theme/app_spacing.dart';
import 'package:yildiz_kadro/features/contestants/data/contestant_seed_data.dart';
import 'package:yildiz_kadro/features/contestants/presentation/widgets/contestant_portrait.dart';
import 'package:yildiz_kadro/features/game/application/game_scope.dart';
import 'package:yildiz_kadro/features/producer/domain/performance_aftermath.dart';
import 'package:yildiz_kadro/l10n/l10n.dart';
import 'package:yildiz_kadro/shared/widgets/tv_components.dart';

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
    final isEn = isAppEnglish(context);
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

    final totalFollowers =
        changes.fold<int>(0, (sum, c) => sum + c.followerDelta);
    final totalXp = changes.fold<int>(0, (sum, c) => sum + c.xpDelta);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppSpacing.xl),
        TvSectionHeader(
          eyebrow: isEn ? 'STAGE RECAP' : 'PERFORMANS SONRASI',
          title: isEn ? 'PERFORMANCE AFTERMATH' : 'KULİS VE GELİŞİM RAPORU',
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          margin: const EdgeInsets.only(bottom: AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.inkSoft,
            border: Border.all(
                color: AppColors.accentBright.withValues(alpha: 0.5)),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            children: [
              const Icon(Icons.trending_up_rounded,
                  color: AppColors.accentBright, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isEn
                      ? 'Team Momentum ↑  ·  ${_signedFollowers(totalFollowers)} Followers · +$totalXp XP'
                      : 'Takım Momentumu ↑  ·  ${_signedFollowers(totalFollowers)} Takipçi · +$totalXp XP',
                  style: const TextStyle(
                    color: AppColors.paper,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
        ...changes.map((change) => _ChangeCard(change: change)),
      ],
    );
  }

  static String _followers(int value) => value >= 1000000
      ? '${(value / 1000000).toStringAsFixed(1)}M'
      : '${(value / 1000).round()}K';
  static String _signedFollowers(int value) =>
      '${value >= 0 ? '+' : ''}${_followers(value.abs())}';
}

class _ChangeCard extends StatelessWidget {
  const _ChangeCard({required this.change});
  final PerformanceChange change;

  @override
  Widget build(BuildContext context) {
    final isEn = isAppEnglish(context);
    final contestant = contestantSeedData.firstWhere(
      (value) => value.id == change.contestantId,
    );
    final popDelta = change.after.popularity - change.before.popularity;
    final motDelta = change.after.motivation - change.before.motivation;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.inkSoft,
        border: Border.all(color: AppColors.line),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipOval(
            child: SizedBox(
              width: 44,
              height: 44,
              child: ContestantPortrait(contestant: contestant),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        contestant.displayName,
                        style: const TextStyle(
                          color: AppColors.paper,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    if (change.leveledUp)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.accentInk,
                          border: Border.all(color: AppColors.accentBright),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Text(
                          isEn ? 'LVL UP' : 'SEVİYE ATLADI',
                          style: const TextStyle(
                            color: AppColors.accentBright,
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    TvMetricDeltaBadge(
                      label:
                          '${PerformanceAftermathPanel._signedFollowers(change.followerDelta)} ${isEn ? "FOLLOWERS" : "TAKİPÇİ"}',
                      secondary:
                          '${PerformanceAftermathPanel._followers(change.before.followers)} → ${PerformanceAftermathPanel._followers(change.after.followers)}',
                      isPositive: change.followerDelta >= 0,
                    ),
                    if (popDelta != 0)
                      TvMetricDeltaBadge(
                        label:
                            '${popDelta > 0 ? "+" : ""}$popDelta ${isEn ? "Popularity" : "Popülerlik"}',
                        isPositive: popDelta >= 0,
                      ),
                    if (motDelta != 0)
                      TvMetricDeltaBadge(
                        label:
                            '${motDelta > 0 ? "+" : ""}$motDelta ${isEn ? "Morale" : "Motivasyon"}',
                        isPositive: motDelta >= 0,
                      ),
                    TvMetricDeltaBadge(
                      label: '+${change.xpDelta} XP',
                      isPositive: true,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
