import 'package:flutter/material.dart';
import 'package:yildiz_kadro/app/theme/app_colors.dart';
import 'package:yildiz_kadro/app/theme/app_spacing.dart';
import 'package:yildiz_kadro/features/contestants/data/contestant_seed_data.dart';
import 'package:yildiz_kadro/features/contestants/domain/contestant.dart';
import 'package:yildiz_kadro/features/contestants/presentation/widgets/contestant_portrait.dart';
import 'package:yildiz_kadro/features/day2/presentation/day2_briefing_screen.dart';
import 'package:yildiz_kadro/features/evaluation/data/evaluation1_data.dart';
import 'package:yildiz_kadro/features/game/application/game_scope.dart';
import 'package:yildiz_kadro/features/last_chance/data/last_chance_data.dart';
import 'package:yildiz_kadro/shared/widgets/app_button.dart';
import 'package:yildiz_kadro/shared/widgets/max_width_container.dart';

class PostEliminationRosterScreen extends StatelessWidget {
  const PostEliminationRosterScreen({super.key});

  Contestant _contestant(int id) =>
      contestantSeedData.firstWhere((contestant) => contestant.id == id);

  @override
  Widget build(BuildContext context) {
    final state = GameScope.of(context);
    final eliminatedId = state.eliminatedContestantIds.last;
    final active = contestantSeedData
        .where((c) => !state.eliminatedContestantIds.contains(c.id))
        .toList();
    final eliminated = _contestant(eliminatedId);
    final eliminatedScore = lastChanceResults[eliminatedId]!.finalScore(
      coached: eliminatedId == state.lastChanceCoachContestantId,
    );
    return Scaffold(
      backgroundColor: AppColors.ink,
      body: SafeArea(
        child: SingleChildScrollView(
          child: MaxWidthContainer(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('1. GÜN TAMAMLANDI', style: _pinkLabel(context)),
                  const SizedBox(height: AppSpacing.sm),
                  Text('${state.activeContestantCount} KİŞİ KALDI',
                      style: Theme.of(context).textTheme.displayLarge),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'İlk gün bir kişiyi geride bıraktı.\nAma asıl yarış şimdi başlıyor.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: active.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisExtent: 170,
                      crossAxisSpacing: AppSpacing.sm,
                      mainAxisSpacing: AppSpacing.sm,
                    ),
                    itemBuilder: (context, index) => _ActiveCard(active[index]),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  Text('VEDA EDEN', style: _pinkLabel(context)),
                  const SizedBox(height: AppSpacing.sm),
                  ColorFiltered(
                    colorFilter: const ColorFilter.mode(
                      Colors.grey,
                      BlendMode.saturation,
                    ),
                    child: SizedBox(
                      height: 190,
                      child: Row(
                        children: [
                          SizedBox(
                            width: 130,
                            child: ContestantPortrait(contestant: eliminated),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(eliminated.displayName,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall),
                                Text('SON ŞANS $eliminatedScore'),
                                const Text('ELENDİ'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  Text('1. GÜN ÖZETİ', style: _pinkLabel(context)),
                  const SizedBox(height: AppSpacing.md),
                  _SummaryLine('İlk değerlendirme lideri',
                      '${_contestant(4).displayName} — ${evaluation1Results[4]!.overall}'),
                  _SummaryLine('Senin koruduğun',
                      _contestant(state.producerSaveContestantId!).displayName),
                  _SummaryLine('Jürinin kurtardığı',
                      _contestant(state.jurySaveContestantId!).displayName),
                  _SummaryLine(
                      'Sahne notunu verdiğin',
                      _contestant(state.lastChanceCoachContestantId!)
                          .displayName),
                  _SummaryLine('Veda eden', eliminated.displayName),
                  const SizedBox(height: AppSpacing.xxl),
                  Text('YARIN', style: _pinkLabel(context)),
                  const SizedBox(height: AppSpacing.sm),
                  Text('Tek başına iyi olmak yetmeyecek.',
                      style: Theme.of(context).textTheme.headlineLarge),
                  const SizedBox(height: AppSpacing.md),
                  Text('İlk grup görevi geliyor.',
                      style: Theme.of(context).textTheme.titleLarge),
                  Text('14 yarışmacı ilk kez birlikte çalışmak zorunda.',
                      style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(height: AppSpacing.xl),
                  AppButton(
                    label: '2. GÜNE GEÇ',
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const Day2BriefingScreen(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ActiveCard extends StatelessWidget {
  const _ActiveCard(this.contestant);
  final Contestant contestant;

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.inkSoft,
          border: Border.all(color: AppColors.line),
        ),
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: Row(
            children: [
              SizedBox(
                width: 82,
                child: ContestantPortrait(contestant: contestant),
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  contestant.displayName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
            ],
          ),
        ),
      );
}

class _SummaryLine extends StatelessWidget {
  const _SummaryLine(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.paperMuted,
                      )),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(value,
                  textAlign: TextAlign.right,
                  style: Theme.of(context).textTheme.labelLarge),
            ),
          ],
        ),
      );
}

TextStyle? _pinkLabel(BuildContext context) =>
    Theme.of(context).textTheme.labelMedium?.copyWith(
          color: AppColors.accentSoft,
          letterSpacing: 0.9,
        );
