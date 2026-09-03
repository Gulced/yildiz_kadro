import 'package:flutter/material.dart';
import 'package:yildiz_kadro/app/theme/app_colors.dart';
import 'package:yildiz_kadro/app/theme/app_spacing.dart';
import 'package:yildiz_kadro/features/contestants/data/contestant_seed_data.dart';
import 'package:yildiz_kadro/features/contestants/domain/contestant.dart';
import 'package:yildiz_kadro/l10n/l10n.dart';
import 'package:yildiz_kadro/features/contestants/presentation/widgets/contestant_portrait.dart';
import 'package:yildiz_kadro/features/game/application/game_scope.dart';
import 'package:yildiz_kadro/features/group_task/data/day2_duel_engine.dart';
import 'package:yildiz_kadro/features/group_task/data/group_task_profiles.dart';
import 'package:yildiz_kadro/features/group_task/domain/day2_duel_result.dart';
import 'package:yildiz_kadro/features/group_task/domain/group_task_profile.dart';
import 'package:yildiz_kadro/features/group_task/presentation/day2_results_screen.dart';
import 'package:yildiz_kadro/shared/widgets/app_button.dart';
import 'package:yildiz_kadro/shared/widgets/max_width_container.dart';
import 'package:yildiz_kadro/features/producer/presentation/widgets/performance_aftermath_panel.dart';

enum _Phase {
  intro,
  profiles,
  concept,
  approach,
  coaching,
  summary,
  performance,
  finalReveal,
  winner,
  farewell,
}

class Day2DuelScreen extends StatefulWidget {
  const Day2DuelScreen({super.key});
  @override
  State<Day2DuelScreen> createState() => _Day2DuelScreenState();
}

class _Day2DuelScreenState extends State<Day2DuelScreen> {
  _Phase _phase = _Phase.intro;
  Day2DuelConcept? _concept;
  Day2DuelApproach? _approach;
  Day2DuelCoaching? _coaching;
  Day2DuelResultSnapshot? _preview;
  int _performanceIndex = 0;
  int _revealCount = 0;

  Contestant _contestant(int id) =>
      contestantSeedData.firstWhere((c) => c.id == id);
  void _go(_Phase phase) => setState(() => _phase = phase);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final state = GameScope.of(context);
    final pair = state.day2DuelContestantIds;
    if (state.day2DuelCompleted) {
      final storedResult = state.day2DuelResultSnapshot;
      if (storedResult == null ||
          pair.length != 2 ||
          !storedResult.results.keys.toSet().containsAll(pair)) {
        throw StateError('Kaydedilmiş düello sonucu geçersiz.');
      }
      _preview = storedResult;
      _phase = _Phase.winner;
      return;
    }
    if (pair.length != 2 ||
        pair.toSet().length != 2 ||
        pair.any(state.eliminatedContestantIds.contains) ||
        pair.contains(state.day2JurySavedContestantId) ||
        pair.contains(state.day2StarImmunityContestantId)) {
      throw StateError('Düello katılımcıları geçersiz.');
    }
  }

  void _calculate() {
    final state = GameScope.of(context);
    _preview = calculateDay2DuelResult(
      contestantIds: state.day2DuelContestantIds,
      concept: _concept!,
      approach: _approach!,
      coaching: _coaching!,
      firstResults: state.evaluation1Results,
      groupPerformance: state.day2GroupPerformanceSnapshot!,
      jury: state.day2JuryResultSnapshot!,
      moraleByContestant: {
        for (final id in state.day2DuelContestantIds)
          id: state.socialStateFor(id).morale,
      },
      professionalismByContestant: {
        for (final id in state.day2DuelContestantIds)
          id: state.socialStateFor(id).professionalism,
      },
    );
    setState(() => _phase = _Phase.performance);
  }

  void _commitAndRevealWinner() {
    final state = GameScope.of(context);
    final result = _preview;
    if (result == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Düello sonucu hazırlanamadı.')),
      );
      return;
    }
    try {
      if (!state.day2DuelCompleted) state.completeDay2Duel(result);
    } on StateError catch (error) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.message.toString())));
      return;
    }
    if (!mounted) return;
    // Start the stored-result route with a fresh State object. Depending on a
    // local AnimatedSwitcher phase after GameScope notifies its listeners left
    // some devices on the reveal frame even though the duel had been saved.
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const Day2DuelScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = GameScope.of(context);
    final ids = state.day2DuelContestantIds;
    return Scaffold(
      backgroundColor: AppColors.ink,
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          child: switch (_phase) {
            _Phase.intro => _intro(ids),
            _Phase.profiles => _profiles(ids),
            _Phase.concept => _choicePage(
                isAppEnglish(context)
                    ? 'WHAT WILL THE DUEL MEASURE?'
                    : 'DÜELLO NEYİ ÖLÇECEK?',
                isAppEnglish(context)
                    ? 'Same track. Different focus.'
                    : 'Aynı parça. Farklı vurgu.',
                Day2DuelConcept.values
                    .map(
                      (v) => (
                        duelConceptLabel(v, context),
                        _conceptDescription(v, context),
                        _concept == v,
                        () => setState(() => _concept = v),
                      ),
                    )
                    .toList(),
                _concept == null ? null : () => _go(_Phase.approach),
              ),
            _Phase.approach => _choicePage(
                isAppEnglish(context)
                    ? 'WHAT KIND OF DUEL DO YOU WANT?'
                    : 'NASIL BİR DÜELLO İSTİYORSUN?',
                isAppEnglish(context)
                    ? 'Define performance attitude.'
                    : 'Performansın tavrını belirle.',
                Day2DuelApproach.values
                    .map(
                      (v) => (
                        duelApproachLabel(v, context),
                        v == Day2DuelApproach.clean
                            ? (isAppEnglish(context)
                                ? 'More controlled, safer, fewer errors.'
                                : 'Daha kontrollü, daha güvenli, daha az hata.')
                            : (isAppEnglish(context)
                                ? 'Riskier, bolder, unforgettable.'
                                : 'Daha riskli, daha iddialı, daha unutulmaz.'),
                        _approach == v,
                        () => setState(() => _approach = v),
                      ),
                    )
                    .toList(),
                _approach == null ? null : () => _go(_Phase.coaching),
              ),
            _Phase.coaching => _choicePage(
                isAppEnglish(context)
                    ? 'WHAT IS YOUR FINAL NOTE?'
                    : 'SON NOTUN NE?',
                isAppEnglish(context)
                    ? 'Both contestants will receive identical coaching.'
                    : 'İki yarışmacı da aynı yapımcı notunu alacak.',
                Day2DuelCoaching.values
                    .map(
                      (v) => (
                        duelCoachingLabel(v, context),
                        _coachingDescription(v, context),
                        _coaching == v,
                        () => setState(() => _coaching = v),
                      ),
                    )
                    .toList(),
                _coaching == null ? null : () => _go(_Phase.summary),
              ),
            _Phase.summary => _summary(ids),
            _Phase.performance => _performance(),
            _Phase.finalReveal => _finalReveal(ids),
            _Phase.winner => _winner(),
            _Phase.farewell => _farewell(),
          },
        ),
      ),
    );
  }

  Widget _intro(List<int> ids) {
    final isEn = isAppEnglish(context);
    return _Page(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.l10n.dayLabel(2), style: _label(context)),
          Text(isEn ? 'DUEL' : 'DÜELLO', style: _label(context)),
          Text(
            isEn
                ? 'Same stage. Two distinct stars.'
                : 'Aynı sahne. İki farklı yıldız.',
            style: Theme.of(context).textTheme.displayLarge,
          ),
          const SizedBox(height: AppSpacing.xl),
          _versus(ids),
          const SizedBox(height: AppSpacing.xl),
          Text(
            isEn
                ? 'The jury saved one.\nNow only one of these two talents will continue.'
                : 'Jüri birini kurtardı.\nŞimdi bu iki isimden yalnızca biri yarışmaya devam edecek.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          Text(
            isEn
                ? 'This time you determine the direction of the performance.'
                : 'Bu kez performansın yönünü sen belirleyeceksin.',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: AppSpacing.xl),
          AppButton(
            label: isEn ? 'CONFIGURE DUEL  ★ →' : 'DÜELLOYU KUR  ★ →',
            onPressed: () => _go(_Phase.profiles),
          ),
        ],
      ),
    );
  }

  Widget _profiles(List<int> ids) {
    final isEn = isAppEnglish(context);
    final state = GameScope.of(context);
    return _Page(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isEn ? 'DUEL PROFILES' : 'DÜELLO PROFİLLERİ',
            style: Theme.of(context).textTheme.displayLarge,
          ),
          const SizedBox(height: AppSpacing.lg),
          ...ids.map((id) {
            final c = _contestant(id);
            final profile = groupTaskProfiles[id]!;
            final day2 =
                state.day2GroupPerformanceSnapshot!.individualResults[id]!;
            final jury = state.day2JuryResultSnapshot!.evaluations[id]!;
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.inkSoft,
                  border: Border.all(color: AppColors.line),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 105,
                      height: 138,
                      child: ContestantPortrait(contestant: c),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${c.displayName} — ${c.age}',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          Text(
                            _powerLabel(profile.primaryRole, context),
                            style: _label(context),
                          ),
                          Text(
                            '${_localizedAssignedRole(day2.assignedRole, context)}  •  ${_styleLabel(profile.workStyle, context)}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            isEn
                                ? 'DAY 1 ${state.evaluation1Results[id]!.overall}  •  ${context.l10n.dayLabel(2).toUpperCase()} ${day2.overall}  •  JURY ${jury.juryScore}'
                                : 'İLK ${state.evaluation1Results[id]!.overall}  •  2. GÜN ${day2.overall}  •  JÜRİ ${jury.juryScore}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          if (state.playerRadarContestantIds.contains(id))
                            Text(
                              isEn ? '★ ON RADAR' : '★ RADARINDA',
                              style: _label(context),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          AppButton(
            label: isEn ? 'MAKE FIRST DECISION' : 'İLK KARARI VER',
            onPressed: () => _go(_Phase.concept),
          ),
        ],
      ),
    );
  }

  Widget _choicePage(
    String title,
    String subtitle,
    List<(String, String, bool, VoidCallback)> choices,
    VoidCallback? next,
  ) =>
      _Page(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.displayLarge),
            Text(subtitle, style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: AppSpacing.xl),
            ...choices.map(
              (choice) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: InkWell(
                  onTap: choice.$4,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color:
                          choice.$3 ? AppColors.accentInk : AppColors.inkSoft,
                      border: Border.all(
                        color:
                            choice.$3 ? AppColors.accentBright : AppColors.line,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          choice.$1,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          choice.$2,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            AppButton(
              label: isAppEnglish(context) ? 'CONTINUE  →' : 'DEVAM ET  →',
              onPressed: next,
            ),
          ],
        ),
      );

  Widget _summary(List<int> ids) {
    final isEn = isAppEnglish(context);
    return _Page(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isEn ? 'DUEL CONFIGURED' : 'DÜELLO HAZIR',
            style: Theme.of(context).textTheme.displayLarge,
          ),
          const SizedBox(height: AppSpacing.lg),
          _summaryLine(
            isEn ? 'CONCEPT' : 'KONSEPT',
            duelConceptLabel(_concept!, context),
          ),
          _summaryLine(
            isEn ? 'APPROACH' : 'YAKLAŞIM',
            duelApproachLabel(_approach!, context),
          ),
          _summaryLine(
            isEn ? 'COACHING' : 'SON NOT',
            duelCoachingLabel(_coaching!, context),
          ),
          const SizedBox(height: AppSpacing.xl),
          _versus(ids),
          const SizedBox(height: AppSpacing.md),
          Center(
            child: Text(
              isEn
                  ? 'Same choices. Two distinct outcomes.'
                  : 'Aynı kararlar. İki farklı sonuç.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          TextButton(
            onPressed: () => _go(_Phase.concept),
            child: Text(isEn ? 'CHANGE' : 'DEĞİŞTİR'),
          ),
          AppButton(
            label: isEn ? 'LAUNCH THE STAGE  ★ →' : 'SAHNEYİ BAŞLAT  ★ →',
            onPressed: _calculate,
          ),
        ],
      ),
    );
  }

  Widget _performance() {
    final isEn = isAppEnglish(context);
    final id = _preview!.performanceOrderIds[_performanceIndex];
    final c = _contestant(id);
    final result = _preview!.results[id]!;
    return _Page(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isEn
                ? 'DUEL — ${_performanceIndex + 1} / 2'
                : 'DÜELLO — ${_performanceIndex + 1} / 2',
            style: _label(context),
          ),
          const SizedBox(height: AppSpacing.md),
          Center(
            child: SizedBox(
              width: 330,
              child: AspectRatio(
                aspectRatio: .82,
                child: ContestantPortrait(contestant: c),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(c.displayName, style: Theme.of(context).textTheme.displayLarge),
          Text(
            isEn
                ? '${duelConceptLabel(_preview!.concept, context)} DUEL'
                : '${duelConceptLabel(_preview!.concept)} DÜELLO',
            style: _label(context),
          ),
          const SizedBox(height: AppSpacing.lg),
          ...[
            (context.l10n.vocal.toUpperCase(), result.vocal),
            (context.l10n.dance.toUpperCase(), result.dance),
            (context.l10n.stage.toUpperCase(), result.stage),
          ].asMap().entries.map(
                (entry) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(entry.value.$1, style: _label(context)),
                  trailing: Text(
                    _revealCount > entry.key ? '${entry.value.$2}' : '--',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
              ),
          if (_revealCount == 3) ...[
            Text(
              '“${_performanceNarrative(result, context)}”',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            Text(
              result.totalModifier >= 5
                  ? (isEn
                      ? '★ This duel format suited her strengths.'
                      : '★ Bu düello formatı ona uydu.')
                  : (isEn
                      ? 'This format was challenging for her.'
                      : 'Bu format onun için kolay değildi.'),
              style: _label(context),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          AppButton(
            label: _revealCount < 3
                ? (isEn ? 'REVEAL CATEGORY' : 'KATEGORİYİ AÇ')
                : _performanceIndex == 0
                    ? (isEn ? 'SECOND PERFORMANCE' : 'İKİNCİ PERFORMANS')
                    : (isEn ? 'VIEW OUTCOME' : 'SONUCA GEÇ'),
            onPressed: () {
              if (_revealCount < 3) {
                setState(() => _revealCount++);
              } else if (_performanceIndex == 0) {
                setState(() {
                  _performanceIndex = 1;
                  _revealCount = 0;
                });
              } else {
                _go(_Phase.finalReveal);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _finalReveal(List<int> ids) {
    final isEn = isAppEnglish(context);
    return _Page(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isEn ? 'DUEL CONCLUDED' : 'DÜELLO TAMAMLANDI',
            style: Theme.of(context).textTheme.displayLarge,
          ),
          Text(
            isEn
                ? 'Same stage.\nSame decisions.\nDifferent outcomes.'
                : 'Aynı sahne.\nAynı kararlar.\nFarklı sonuçlar.',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: AppSpacing.xl),
          _versus(ids),
          const SizedBox(height: AppSpacing.lg),
          ...ids.map((id) {
            final r = _preview!.results[id]!;
            return ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(_contestant(id).displayName),
              subtitle: Text(
                '${isEn ? "VOCAL" : "VOKAL"} ${r.vocal}  •  ${isEn ? "DANCE" : "DANS"} ${r.dance}  •  ${isEn ? "STAGE" : "SAHNE"} ${r.stage}'
                '${r.formModifier == 0 ? '' : (isEn ? '\nCURRENT FORM ' : '\nGÜNCEL FORM ') + (r.formModifier > 0 ? '+' : '') + r.formModifier.toString()}',
              ),
              trailing: const Text('--'),
            );
          }),
          const SizedBox(height: AppSpacing.xl),
          AppButton(
            label: isEn ? 'REVEAL WINNER  →' : 'SONUCU AÇ  →',
            onPressed: _commitAndRevealWinner,
          ),
        ],
      ),
    );
  }

  Widget _winner() {
    final isEn = isAppEnglish(context);
    final state = GameScope.of(context);
    final id = _preview!.winnerContestantId;
    final c = _contestant(id);
    final result = _preview!.results[id]!;
    return _Page(
      child: Column(
        children: [
          Text(
            isEn ? 'WON THE DUEL' : 'DÜELLOYU KAZANDI',
            style: _label(context),
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: 340,
            child: AspectRatio(
              aspectRatio: .82,
              child: ContestantPortrait(contestant: c),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(c.displayName, style: Theme.of(context).textTheme.displayLarge),
          Text(
            isEn ? 'SAFE' : 'GÜVENDE',
            style: Theme.of(context)
                .textTheme
                .headlineLarge
                ?.copyWith(color: AppColors.accentBright),
          ),
          Text(
            isEn ? 'Remains in Yıldız Kadro.' : "Yıldız Kadro'da kalıyor.",
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          Text(
            '${isEn ? "DUEL SCORE" : "DÜELLO PUANI"} ${result.finalScore}',
            style: _label(context),
          ),
          if (result.totalModifier >= 5)
            Text(
              isEn
                  ? '★ Your chosen duel format highlighted her distinct strengths.'
                  : '★ Seçtiğin düello formatı onun güçlü yanlarını ortaya çıkardı.',
              textAlign: TextAlign.center,
              style: _label(context),
            ),
          if (state.playerRadarContestantIds.contains(id))
            Text(
              isEn
                  ? '★ Your radar favorite won the duel.'
                  : '★ Radarındaki isim düelloyu kazandı.',
              style: _label(context),
            ),
          PerformanceAftermathPanel(
            stageId: 'day2_duel',
            contestantIds: [id],
            limit: 1,
          ),
          const SizedBox(height: AppSpacing.xl),
          AppButton(
            label: isEn ? 'SEE FAREWELL' : 'VEDAYI GÖR',
            onPressed: () => _go(_Phase.farewell),
          ),
        ],
      ),
    );
  }

  Widget _farewell() {
    final isEn = isAppEnglish(context);
    final state = GameScope.of(context);
    final id = _preview!.eliminatedContestantId;
    final c = _contestant(id);
    final result = _preview!.results[id]!;
    final wasStar = id ==
            state.day2GroupPerformanceSnapshot!.teamAResult.starContestantId ||
        id == state.day2GroupPerformanceSnapshot!.teamBResult.starContestantId;
    return _Page(
      child: Column(
        children: [
          Text(
            '${context.l10n.dayLabel(2)} ${isEn ? "FAREWELL" : "VEDA"}',
            style: _label(context),
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: 340,
            child: AspectRatio(
              aspectRatio: .82,
              child: ContestantPortrait(contestant: c),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(c.displayName, style: Theme.of(context).textTheme.displayLarge),
          Text(
            isEn
                ? 'Bids farewell to Yıldız Kadro.'
                : "Yıldız Kadro'ya veda ediyor.",
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          Text(
            '${isEn ? "DUEL SCORE" : "DÜELLO PUANI"} ${result.finalScore}',
            style: _label(context),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            wasStar
                ? (isEn
                    ? '“She was the shining star in a squad stage. Tonight’s duel could not replicate that story.”'
                    : '“Bir takım performansında yıldız olmuştu. Düello gecesi aynı hikâyeyi yazamadı.”')
                : '“${_farewellText(groupTaskProfiles[id]!.primaryRole, context)}”',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          if (state.playerRadarContestantIds.contains(id))
            Text(
              isEn
                  ? '★ Another talent from your initial radar has departed.'
                  : '★ İlk radarından bir isim daha yarışmaya veda etti.',
              style: _label(context),
            ),
          if (id == state.day2CaptainAId || id == state.day2CaptainBId)
            Text(
              isEn
                  ? 'You had chosen her as a captain this morning.'
                  : 'Onu bu sabah kaptan seçmiştin.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          PerformanceAftermathPanel(
            stageId: 'day2_duel',
            contestantIds: [id],
            limit: 1,
          ),
          const SizedBox(height: AppSpacing.xl),
          AppButton(
            label: isEn ? 'DAY 2 RESULTS' : '2. GÜN SONUÇLARI',
            onPressed: () => Navigator.of(context).pushReplacement(
              MaterialPageRoute<void>(
                builder: (_) => const Day2ResultsScreen(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _versus(List<int> ids) {
    final radar = GameScope.of(context).playerRadarContestantIds;
    return Row(
      children: [
        Expanded(
          child: _PortraitCard(
            c: _contestant(ids.first),
            radar: radar.contains(ids.first),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Text('VS', style: _label(context)),
        ),
        Expanded(
          child: _PortraitCard(
            c: _contestant(ids.last),
            radar: radar.contains(ids.last),
          ),
        ),
      ],
    );
  }

  Widget _summaryLine(String title, String value) => Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.md),
        child: Row(
          children: [
            Expanded(child: Text(title, style: _label(context))),
            Text(value, style: Theme.of(context).textTheme.titleLarge),
          ],
        ),
      );
}

class _PortraitCard extends StatelessWidget {
  const _PortraitCard({required this.c, required this.radar});
  final Contestant c;
  final bool radar;
  @override
  Widget build(BuildContext context) => Column(
        children: [
          AspectRatio(
              aspectRatio: .72, child: ContestantPortrait(contestant: c)),
          const SizedBox(height: AppSpacing.xs),
          Text(c.displayName, style: Theme.of(context).textTheme.titleLarge),
          if (radar)
            Text(
              isAppEnglish(context) ? '★ ON RADAR' : '★ RADARINDA',
              style: _label(context),
            ),
        ],
      );
}

class _Page extends StatelessWidget {
  const _Page({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
        child: MaxWidthContainer(
          maxWidth: 780,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: child,
          ),
        ),
      );
}

TextStyle _label(BuildContext context) => Theme.of(context)
    .textTheme
    .labelLarge!
    .copyWith(color: AppColors.accentBright, letterSpacing: 1.2);
String _conceptDescription(Day2DuelConcept v, [BuildContext? context]) {
  final isEn = isAppEnglish(context);
  return switch (v) {
    Day2DuelConcept.vocal => isEn
        ? 'Vocal control, timbre, and emotional interpretation take center stage.'
        : 'Ses kontrolü, ton ve yorum ön planda.',
    Day2DuelConcept.dance => isEn
        ? 'Movement, groove, and choreography sharpness take center stage.'
        : 'Hareket, ritim ve koreografi ön planda.',
    Day2DuelConcept.stage => isEn
        ? 'Camera dominance, facial expression, and star aura take center stage.'
        : 'Kamera hakimiyeti, ifade ve yıldız etkisi ön planda.',
  };
}

String _coachingDescription(Day2DuelCoaching v, [BuildContext? context]) {
  final isEn = isAppEnglish(context);
  return switch (v) {
    Day2DuelCoaching.technique => isEn
        ? 'Instead of overreaching, execute what you know flawlessly.'
        : 'Hata kovalamak yerine bildiğin şeyi kusursuz yap.',
    Day2DuelCoaching.showYourself => isEn
        ? 'Don’t just survive the stage—own it completely.'
        : 'Sahneyi yalnızca tamamlamaya değil, sahiplenmeye çık.',
    Day2DuelCoaching.tellStory => isEn
        ? 'Don’t think about points; deliver an unforgettable story.'
        : 'Puan değil, iz bırakan bir performans düşün.',
  };
}

String _powerLabel(GroupRole role, [BuildContext? context]) {
  final isEn = isAppEnglish(context);
  return switch (role) {
    GroupRole.vocal => isEn ? 'VOCAL POWER' : 'SES GÜCÜ',
    GroupRole.dance => isEn ? 'DANCE POWER' : 'HAREKET GÜCÜ',
    GroupRole.stage => isEn ? 'STAGE POWER' : 'SAHNE GÜCÜ',
    GroupRole.allRounder => isEn ? 'BALANCE' : 'DENGE',
  };
}

String _styleLabel(WorkStyle s, [BuildContext? context]) {
  final isEn = isAppEnglish(context);
  return switch (s) {
    WorkStyle.cameraSavvy => isEn ? 'CAMERA INTUITION' : 'KAMERA SEZGİSİ',
    WorkStyle.controlled => isEn ? 'CONTROLLED' : 'KONTROLLÜ',
    WorkStyle.bold => isEn ? 'BOLD' : 'CESUR',
    WorkStyle.calm => isEn ? 'CALM' : 'SAKİN',
    WorkStyle.experienced => isEn ? 'EXPERIENCED' : 'DENEYİMLİ',
    WorkStyle.spontaneous => isEn ? 'SPONTANEOUS' : 'SPONTANE',
    WorkStyle.instinctive => isEn ? 'INSTINCTIVE' : 'İÇGÜDÜSEL',
    WorkStyle.competitive => isEn ? 'COMPETITIVE' : 'REKABETÇİ',
    WorkStyle.observant => isEn ? 'OBSERVANT' : 'GÖZLEMCİ',
    WorkStyle.direct => isEn ? 'DIRECT' : 'DOĞRUDAN',
    WorkStyle.sensitive => isEn ? 'SENSITIVE' : 'HASSAS',
    WorkStyle.protective => isEn ? 'PROTECTIVE' : 'KORUYUCU',
    WorkStyle.chaotic => isEn ? 'UNPREDICTABLE' : 'ÖNGÖRÜLEMEZ',
    WorkStyle.social => isEn ? 'SOCIAL' : 'SOSYAL',
    WorkStyle.playful => isEn ? 'PLAYFUL' : 'OYUNCU',
  };
}

String _performanceNarrative(DuelContestantResult r, [BuildContext? context]) {
  final isEn = isAppEnglish(context);
  if (r.vocal >= r.dance && r.vocal >= r.stage) {
    return isEn
        ? 'Placed her raw voice at the center.'
        : 'Sesini merkeze koydu.';
  }
  if (r.dance >= r.stage) {
    return isEn
        ? 'Held tight control over physical movement.'
        : 'Hareket tarafında kontrolü bırakmadı.';
  }
  return isEn ? 'The camera never left her gaze.' : 'Kamera ondan ayrılmadı.';
}

String _farewellText(GroupRole role, [BuildContext? context]) {
  final isEn = isAppEnglish(context);
  return switch (role) {
    GroupRole.vocal => isEn
        ? 'Her voice left an imprint on the competition. This time the duel couldn’t hold her.'
        : 'Sesi yarışmada iz bıraktı. Bu kez düello onu tutamadı.',
    GroupRole.dance => isEn
        ? 'Her technique was formidable. Her journey ends on the second day.'
        : 'Tekniği güçlüydü. Yolculuğu ikinci günde sona erdi.',
    GroupRole.stage => isEn
        ? 'The stage adored her. The competition chose a different story tonight.'
        : 'Sahne onu seviyordu. Yarışma bu gece başka bir karar verdi.',
    GroupRole.allRounder => isEn
        ? 'Fought across every discipline. This time balance alone wasn’t enough.'
        : 'Her alanda savaştı. Bu kez denge yeterli olmadı.',
  };
}

String _localizedAssignedRole(String role, BuildContext context) {
  final isEn = isAppEnglish(context);
  if (!isEn) return role;
  return switch (role.toUpperCase()) {
    'CENTER' => 'CENTER',
    'LEAD VOKAL' => 'LEAD VOCAL',
    'SUB VOKAL' => 'SUB VOCAL',
    'ANA VOKAL' => 'LEAD VOCAL',
    'LEAD DANCER' => 'LEAD DANCER',
    'SUB DANCER' => 'SUB DANCER',
    'DANS LİDERİ' => 'LEAD DANCER',
    'GRUP ÜYESİ' => 'GROUP MEMBER',
    'ÜYE' => 'MEMBER',
    _ => role,
  };
}
