import 'package:flutter/material.dart';
import 'package:yildiz_kadro/app/theme/app_colors.dart';
import 'package:yildiz_kadro/app/theme/app_spacing.dart';
import 'package:yildiz_kadro/features/contestants/data/contestant_seed_data.dart';
import 'package:yildiz_kadro/l10n/l10n.dart';
import 'package:yildiz_kadro/features/contestants/presentation/widgets/contestant_portrait.dart';
import 'package:yildiz_kadro/features/game/application/game_scope.dart';
import 'package:yildiz_kadro/features/group_task/data/day2_duel_engine.dart';
import 'package:yildiz_kadro/features/group_task/presentation/day3_briefing_screen.dart';
import 'package:yildiz_kadro/shared/widgets/app_button.dart';
import 'package:yildiz_kadro/shared/widgets/max_width_container.dart';

class Day2ResultsScreen extends StatelessWidget {
  const Day2ResultsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final isEn = isAppEnglish(context);
    final state = GameScope.of(context);
    final active = contestantSeedData
        .where((c) => !state.eliminatedContestantIds.contains(c.id))
        .toList();
    String name(int? id) =>
        contestantSeedData.firstWhere((c) => c.id == id).displayName;
    final group = state.day2GroupPerformanceSnapshot!;
    final winnerCaptain = group.winningTeamId == 'A'
        ? state.day2CaptainAId
        : state.day2CaptainBId;
    return Scaffold(
      backgroundColor: AppColors.ink,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
          child: MaxWidthContainer(
            maxWidth: 900,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${context.l10n.dayLabel(2)} ${isEn ? "CONCLUDED" : "TAMAMLANDI"}',
                    style: _label(context),
                  ),
                  Text(
                    isEn ? '13 REMAIN' : '13 KİŞİ KALDI',
                    style: Theme.of(context).textTheme.displayLarge,
                  ),
                  Text(
                    isEn
                        ? 'The first group task restructured the roster.\nTeams disband. The competition drives forward.'
                        : 'İlk grup görevi kadroyu değiştirdi.\nTakımlar dağılıyor. Yarışma devam ediyor.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final count = constraints.maxWidth >= 700
                          ? 5
                          : constraints.maxWidth >= 430
                              ? 4
                              : 3;
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: active.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: count,
                          childAspectRatio: .64,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                        itemBuilder: (_, i) => Column(
                          children: [
                            Expanded(
                              child: ContestantPortrait(contestant: active[i]),
                            ),
                            Text(active[i].displayName, maxLines: 1),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    isEn ? 'DAY 2 RECAP' : '2. GÜN ÖZETİ',
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  _line(
                    context,
                    isEn ? 'WINNING TEAM' : 'KAZANAN TAKIM',
                    '${isEn ? "TEAM" : "TAKIM"} ${name(winnerCaptain)}',
                  ),
                  _line(
                    context,
                    isEn ? 'STAGE STARS' : 'TAKIMIN YILDIZLARI',
                    '${name(group.teamAResult.starContestantId)} • ${name(group.teamBResult.starContestantId)}',
                  ),
                  _line(
                    context,
                    isEn ? 'GRANTED IMMUNITY' : 'SENİN DOKUNULMAZ YAPTIĞIN',
                    name(state.day2StarImmunityContestantId),
                  ),
                  _line(
                    context,
                    isEn ? 'SAVED BY JURY' : 'JÜRİNİN KURTARDIĞI',
                    name(state.day2JurySavedContestantId),
                  ),
                  _line(
                    context,
                    isEn ? 'DUEL WINNER' : 'DÜELLOYU KAZANAN',
                    name(state.day2DuelWinnerContestantId),
                  ),
                  _line(
                    context,
                    isEn ? 'ELIMINATED' : 'VEDA EDEN',
                    name(state.day2EliminatedContestantId),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: AppColors.accentInk,
                      border: Border.all(color: AppColors.accent),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isEn ? 'YOUR PRODUCER CHOICES' : 'SENİN KARARLARIN',
                          style: _label(context),
                        ),
                        Text(
                          isEn
                              ? 'You chose the captains.\nYou intervened in Team ${state.day2PlayerInterventionTeamId}’s rehearsal.\nYou granted immunity to ${name(state.day2StarImmunityContestantId)}.\nYou directed the duel as ${duelConceptLabel(state.day2DuelResultSnapshot!.concept, context)}.'
                              : 'Kaptanları sen seçtin.\nTakım ${state.day2PlayerInterventionTeamId} provasına müdahale ettin.\n${name(state.day2StarImmunityContestantId)}’e dokunulmazlık verdin.\nDüelloyu ${duelConceptLabel(state.day2DuelResultSnapshot!.concept)} yaptın.',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        if (state.day2DuelResultSnapshot!.playerChangedOutcome)
                          Text(
                            isEn
                                ? '★ Your duel decisions altered the final outcome.'
                                : '★ Düellodaki kararların sonucu değiştirdi.',
                            style: _label(context),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    isEn ? 'DEPARTED CONTESTANTS' : 'VEDA EDENLER',
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  Row(
                    children: state.eliminatedContestantIds.asMap().entries.map(
                      (entry) {
                        final c = contestantSeedData.firstWhere(
                          (c) => c.id == entry.value,
                        );
                        return Expanded(
                          child: Opacity(
                            opacity: .55,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                right: AppSpacing.md,
                              ),
                              child: Column(
                                children: [
                                  AspectRatio(
                                    aspectRatio: .82,
                                    child: ContestantPortrait(contestant: c),
                                  ),
                                  Text(
                                    context.l10n.dayLabel(entry.key + 1),
                                    style: _label(context),
                                  ),
                                  Text(c.displayName),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ).toList(),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text(isEn ? 'TOMORROW' : 'YARIN', style: _label(context)),
                  Text(
                    isEn
                        ? 'Teams dissolve. Now each must prove who they truly are.'
                        : 'Takımlar dağılıyor. Sıra kim olduklarını göstermekte.',
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  Text(
                    isEn
                        ? '13 contestants will construct their distinct identity for the first time.\nConcept. Style. Camera.'
                        : '13 yarışmacı ilk kez kendi imajını yaratacak.\nKonsept. Stil. Kamera.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  AppButton(
                    label: isEn ? 'ADVANCE TO DAY 3  ★ →' : '3. GÜNE GEÇ  ★ →',
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const Day3BriefingScreen(),
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

  Widget _line(BuildContext context, String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: _label(context)),
            Text(value, style: Theme.of(context).textTheme.titleLarge),
            const Divider(color: AppColors.line),
          ],
        ),
      );
}

TextStyle _label(BuildContext context) => Theme.of(context)
    .textTheme
    .labelLarge!
    .copyWith(color: AppColors.accentBright, letterSpacing: 1.2);
