import 'package:flutter/material.dart';
import 'package:yildiz_kadro/app/theme/app_colors.dart';
import 'package:yildiz_kadro/app/theme/app_spacing.dart';
import 'package:yildiz_kadro/core/responsive/breakpoints.dart';
import 'package:yildiz_kadro/features/contestants/data/contestant_seed_data.dart';
import 'package:yildiz_kadro/features/contestants/domain/contestant.dart';
import 'package:yildiz_kadro/features/contestants/presentation/widgets/contestant_portrait.dart';
import 'package:yildiz_kadro/features/evaluation/data/evaluation1_data.dart';
import 'package:yildiz_kadro/features/evaluation/domain/evaluation_result.dart';
import 'package:yildiz_kadro/features/game/application/game_scope.dart';
import 'package:yildiz_kadro/features/jury/presentation/jury_decision_screen.dart';
import 'package:yildiz_kadro/shared/widgets/app_button.dart';

class EvaluationResultsScreen extends StatelessWidget {
  const EvaluationResultsScreen({super.key});

  Contestant _contestant(int id) =>
      contestantSeedData.firstWhere((contestant) => contestant.id == id);

  @override
  Widget build(BuildContext context) {
    final gameState = GameScope.of(context);
    final results = gameState.evaluation1Results.isEmpty
        ? evaluation1Results
        : gameState.evaluation1Results;
    final radarIds = gameState.playerRadarContestantIds;
    final topFive = results.values.toList()
      ..sort((a, b) => b.overall.compareTo(a.overall));
    final outsideRadar = results.values
        .where((result) => !radarIds.contains(result.contestantId))
        .toList()
      ..sort((a, b) => b.overall.compareTo(a.overall));
    final radarResults = radarIds.map((id) => results[id]!).toList()
      ..sort((a, b) => a.overall.compareTo(b.overall));
    final radarAverage = radarResults.isEmpty
        ? 0.0
        : radarResults.fold<int>(0, (sum, result) => sum + result.overall) /
            radarResults.length;

    return Scaffold(
      backgroundColor: AppColors.ink,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: AppBreakpoints.maxContentWidth,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.md,
                      AppSpacing.lg,
                      AppSpacing.xl,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '1. GÜN • SAHNE TESTİ',
                          style:
                              Theme.of(context).textTheme.labelMedium?.copyWith(
                                    color: AppColors.accentSoft,
                                    letterSpacing: 1.2,
                                  ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'İLK DEĞERLENDİRME\nTAMAMLANDI',
                          style: Theme.of(context).textTheme.displayLarge,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          'İlk sahne bazı beklentileri doğruladı.\nBazılarını ise tamamen değiştirdi.',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(height: AppSpacing.xxl),
                        const _SectionLabel('GECENİN İLK 5’İ'),
                        const SizedBox(height: AppSpacing.md),
                        ...topFive.take(5).toList().asMap().entries.map(
                              (entry) => _LeaderboardRow(
                                rank: entry.key + 1,
                                contestant:
                                    _contestant(entry.value.contestantId),
                                score: entry.value.overall,
                              ),
                            ),
                        const SizedBox(height: AppSpacing.xxl),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final cards = [
                              _ResultSpotlight(
                                label: 'RADAR DIŞI SÜRPRİZ',
                                contestant: _contestant(
                                    outsideRadar.first.contestantId),
                                result: outsideRadar.first,
                                caption: 'İlk seçiminde onu pas geçmiştin.',
                              ),
                              _ResultSpotlight(
                                label: 'RADARDA SORU İŞARETİ',
                                contestant: _contestant(
                                    radarResults.first.contestantId),
                                result: radarResults.first,
                                caption:
                                    'İlk izlenimin güçlüydü. İlk performansı o kadar değil.',
                              ),
                            ];
                            if (constraints.maxWidth < AppBreakpoints.compact) {
                              return Column(
                                children: [
                                  cards.first,
                                  const SizedBox(height: AppSpacing.md),
                                  cards.last,
                                ],
                              );
                            }
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(child: cards.first),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(child: cards.last),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: AppSpacing.xxl),
                        const _SectionLabel('SENİN RADARIN'),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'Radar ortalaman: ${radarAverage.toStringAsFixed(1)}',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                color: AppColors.accentBright,
                              ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        SizedBox(
                          height: 178,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: radarIds.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(width: AppSpacing.sm),
                            itemBuilder: (context, index) {
                              final id = radarIds[index];
                              return _RadarSummaryCard(
                                contestant: _contestant(id),
                                score: results[id]!.overall,
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xxl),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 560),
                          child: AppButton(
                            label: 'JÜRİ MASASINA GEÇ',
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => const JuryDecisionScreen(),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xxl),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: AppColors.paperMuted,
            letterSpacing: 1.4,
          ),
    );
  }
}

class _LeaderboardRow extends StatelessWidget {
  const _LeaderboardRow(
      {required this.rank, required this.contestant, required this.score});
  final int rank;
  final Contestant contestant;
  final int score;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.xs),
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: rank <= 3
            ? AppColors.accent.withValues(alpha: 0.1)
            : AppColors.inkSoft,
        border:
            Border.all(color: rank <= 3 ? AppColors.accent : AppColors.line),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 34,
            child:
                Text('$rank', style: Theme.of(context).textTheme.headlineSmall),
          ),
          Expanded(
            child: Text(
              contestant.displayName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          Text(
            '$score',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.accentBright,
                ),
          ),
        ],
      ),
    );
  }
}

class _ResultSpotlight extends StatelessWidget {
  const _ResultSpotlight({
    required this.label,
    required this.contestant,
    required this.result,
    required this.caption,
  });
  final String label;
  final Contestant contestant;
  final EvaluationResult result;
  final String caption;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.inkSoft,
        border: Border.all(color: AppColors.line),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppColors.accentSoft,
                    letterSpacing: 1,
                  ),
            ),
            const SizedBox(height: AppSpacing.sm),
            AspectRatio(
              aspectRatio: 1.5,
              child: ContestantPortrait(contestant: contestant),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: Text(
                    contestant.displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Text(
                  '${result.overall}',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppColors.accentBright,
                      ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '“$caption”',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.paperMuted,
                    fontStyle: FontStyle.italic,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RadarSummaryCard extends StatelessWidget {
  const _RadarSummaryCard({required this.contestant, required this.score});
  final Contestant contestant;
  final int score;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 116,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.inkSoft,
          border: Border.all(color: AppColors.line),
        ),
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: ContestantPortrait(contestant: contestant)),
              const SizedBox(height: AppSpacing.xs),
              Text(
                contestant.displayName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelMedium,
              ),
              Text(
                '$score',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppColors.accentBright,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
