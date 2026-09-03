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
import 'package:yildiz_kadro/features/producer/presentation/producer_dashboard_screen.dart';
import 'package:yildiz_kadro/l10n/l10n.dart';
import 'package:yildiz_kadro/shared/widgets/app_button.dart';
import 'package:yildiz_kadro/shared/widgets/max_width_container.dart';

class PostEliminationRosterScreen extends StatelessWidget {
  const PostEliminationRosterScreen({super.key});

  Contestant _contestant(int id) =>
      contestantSeedData.firstWhere((contestant) => contestant.id == id);

  @override
  Widget build(BuildContext context) {
    final state = GameScope.of(context);
    if (!state.lastChance1Completed ||
        state.eliminatedContestantIds.isEmpty ||
        state.lastChanceCoachContestantId == null) {
      return _MissingRosterState(
        onExit: () {
          final navigator = Navigator.of(context);
          if (navigator.canPop()) {
            navigator.pop();
          } else {
            navigator.pushReplacement(ProducerDashboardScreen.route(day: 1));
          }
        },
      );
    }
    final eliminatedId = state.eliminatedContestantIds.last;
    final active = contestantSeedData
        .where((c) => !state.eliminatedContestantIds.contains(c.id))
        .toList();
    final eliminated = _contestant(eliminatedId);
    final eliminatedResult = lastChanceResults[eliminatedId];
    if (eliminatedResult == null) {
      return _MissingRosterState(
        onExit: () => Navigator.of(context).maybePop(),
      );
    }
    final isEn = isAppEnglish(context);
    final eliminatedScore = eliminatedResult.finalScore(
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
                  Text(context.l10n.day1Complete, style: _pinkLabel(context)),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    context.l10n.activeRemainingCount(
                      state.activeContestantCount,
                    ),
                    style: Theme.of(context).textTheme.displayLarge,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    isEn
                        ? 'Day 1 left one person behind.\nNow the real contest begins.'
                        : 'İlk gün bir kişiyi geride bıraktı.\nAma asıl yarış şimdi başlıyor.',
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
                  Text(
                    context.l10n.eliminatedMember,
                    style: _pinkLabel(context),
                  ),
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
                                Text(
                                  eliminated.displayName,
                                  style:
                                      Theme.of(context).textTheme.headlineSmall,
                                ),
                                Text(
                                  '${isEn ? "LAST CHANCE" : "SON ŞANS"} $eliminatedScore',
                                ),
                                Text(isEn ? 'ELIMINATED' : 'ELENDİ'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  Text(
                    isEn ? 'DAY 1 SUMMARY' : '1. GÜN ÖZETİ',
                    style: _pinkLabel(context),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _SummaryLine(
                    isEn
                        ? 'First evaluation leader'
                        : 'İlk değerlendirme lideri',
                    '${_contestant(4).displayName} — ${evaluation1Results[4]!.overall}',
                  ),
                  _SummaryLine(
                    isEn ? 'Protected by you' : 'Senin koruduğun',
                    _contestant(state.producerSaveContestantId!).displayName,
                  ),
                  _SummaryLine(
                    isEn ? 'Saved by jury' : 'Jürinin kurtardığı',
                    _contestant(state.jurySaveContestantId!).displayName,
                  ),
                  _SummaryLine(
                    isEn ? 'Coached by you' : 'Sahne notunu verdiğin',
                    _contestant(state.lastChanceCoachContestantId!).displayName,
                  ),
                  _SummaryLine(
                    isEn ? 'Eliminated' : 'Veda eden',
                    eliminated.displayName,
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  Text(isEn ? 'TOMORROW' : 'YARIN', style: _pinkLabel(context)),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    isEn
                        ? "Being good on your own won't be enough."
                        : 'Tek başına iyi olmak yetmeyecek.',
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    isEn
                        ? 'The first group task is coming.'
                        : 'İlk grup görevi geliyor.',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text(
                    isEn
                        ? '14 contestants must work together for the first time.'
                        : '14 yarışmacı ilk kez birlikte çalışmak zorunda.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  OutlinedButton(
                    onPressed: () => Navigator.of(context)
                        .push(ProducerDashboardScreen.route(day: 2)),
                    child: Text(context.l10n.producerDesk),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  AppButton(
                    label: context.l10n.advanceToDay2,
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

class _MissingRosterState extends StatelessWidget {
  const _MissingRosterState({required this.onExit});
  final VoidCallback onExit;

  @override
  Widget build(BuildContext context) {
    final isEn = isAppEnglish(context);
    return Scaffold(
      backgroundColor: AppColors.ink,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isEn ? 'ROSTER RESULT NOT READY' : 'KADRO SONUCU HAZIR DEĞİL',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  isEn
                      ? 'Roster will update once elimination is concluded.'
                      : 'Eleme sonucu tamamlandıktan sonra kadro güncellenecek.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.lg),
                AppButton(
                  label: isEn ? 'GO BACK' : 'GERİ DÖN',
                  onPressed: onExit,
                ),
              ],
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
              child: Text(
                label,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: AppColors.paperMuted),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                value,
                textAlign: TextAlign.right,
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
          ],
        ),
      );
}

TextStyle? _pinkLabel(BuildContext context) => Theme.of(context)
    .textTheme
    .labelMedium
    ?.copyWith(color: AppColors.accentSoft, letterSpacing: 0.9);
