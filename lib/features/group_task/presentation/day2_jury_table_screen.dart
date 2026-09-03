import 'package:flutter/material.dart';
import 'package:yildiz_kadro/app/theme/app_colors.dart';
import 'package:yildiz_kadro/app/theme/app_spacing.dart';
import 'package:yildiz_kadro/features/contestants/data/contestant_seed_data.dart';
import 'package:yildiz_kadro/features/contestants/domain/contestant.dart';
import 'package:yildiz_kadro/l10n/l10n.dart';
import 'package:yildiz_kadro/features/contestants/presentation/widgets/contestant_portrait.dart';
import 'package:yildiz_kadro/features/group_task/data/day2_jury_engine.dart';
import 'package:yildiz_kadro/features/group_task/data/group_task_profiles.dart';
import 'package:yildiz_kadro/features/group_task/domain/day2_jury_result.dart';
import 'package:yildiz_kadro/features/group_task/domain/group_task_profile.dart';
import 'package:yildiz_kadro/features/group_task/presentation/day2_duel_screen.dart';
import 'package:yildiz_kadro/features/game/application/game_scope.dart';
import 'package:yildiz_kadro/features/game/application/game_state.dart';
import 'package:yildiz_kadro/shared/widgets/app_button.dart';
import 'package:yildiz_kadro/shared/widgets/max_width_container.dart';

enum _JuryPhase { intro, contestant, decision, saved, duel }

class Day2JuryTableScreen extends StatefulWidget {
  const Day2JuryTableScreen({super.key});
  @override
  State<Day2JuryTableScreen> createState() => _Day2JuryTableScreenState();
}

class _Day2JuryTableScreenState extends State<Day2JuryTableScreen> {
  _JuryPhase _phase = _JuryPhase.intro;
  int _contestantIndex = 0;
  int _revealCount = 0;
  Day2JuryResultSnapshot? _preview;

  Contestant _contestant(int id) =>
      contestantSeedData.firstWhere((item) => item.id == id);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final state = GameScope.of(context);
    _preview ??= state.day2JuryResultSnapshot ??
        calculateDay2JuryResult(
          juryRiskIds: state.day2JuryRiskContestantIds,
          firstEvaluationResults: state.evaluation1Results,
          lastChanceResults: state.storedLastChanceResults,
          coachedContestantId: state.lastChanceCoachContestantId,
          groupPerformance: state.day2GroupPerformanceSnapshot!,
        );
    if (state.day2JuryTableCompleted) _phase = _JuryPhase.duel;
  }

  void _nextReveal() {
    if (_revealCount < 3) {
      setState(() => _revealCount++);
    } else if (_contestantIndex < 2) {
      setState(() {
        _contestantIndex++;
        _revealCount = 0;
      });
    } else {
      setState(() => _phase = _JuryPhase.decision);
    }
  }

  void _openDecision() {
    final state = GameScope.of(context);
    state.completeDay2JuryTable(_preview!);
    setState(() => _phase = _JuryPhase.saved);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.ink,
        body: SafeArea(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 240),
            child: switch (_phase) {
              _JuryPhase.intro => _intro(context),
              _JuryPhase.contestant => _evaluation(context),
              _JuryPhase.decision => _decision(context),
              _JuryPhase.saved => _saved(context),
              _JuryPhase.duel => _duel(context),
            },
          ),
        ),
      );

  Widget _intro(BuildContext context) {
    final isEn = isAppEnglish(context);
    final state = GameScope.of(context);
    final ids = state.day2JuryRiskContestantIds;
    return _Page(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.l10n.dayLabel(2), style: _label(context)),
          Text(
            isEn ? 'JURY TABLE' : 'JÜRİ MASASI',
            style: Theme.of(context).textTheme.displayLarge,
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            isEn
                ? 'Team is over. Now everyone stands alone.'
                : 'Takım bitti. Şimdi herkes tek başına.',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            isEn
                ? 'Three contestants remain.\nYet the jury will not judge tonight in isolation.'
                : 'Üç yarışmacı kaldı.\nAma jüri yalnızca bu geceye bakmayacak.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            isEn
                ? 'Just an off night? Or the first sign of cracking under pressure?'
                : 'Bir kötü gece mi? Yoksa yarışmanın ilk işareti mi?',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: AppColors.paperMuted,
                ),
          ),
          const SizedBox(height: AppSpacing.xl),
          _Portraits(
            ids: ids,
            contestant: _contestant,
            radarIds: state.playerRadarContestantIds,
          ),
          const SizedBox(height: AppSpacing.xl),
          AppButton(
            label: isEn ? 'HEAR THE JURY  →' : 'JÜRİYİ DİNLE  →',
            onPressed: () => setState(() => _phase = _JuryPhase.contestant),
          ),
        ],
      ),
    );
  }

  Widget _evaluation(BuildContext context) {
    final isEn = isAppEnglish(context);
    final state = GameScope.of(context);
    final id = state.day2JuryRiskContestantIds[_contestantIndex];
    final contestant = _contestant(id);
    final evaluation = _preview!.evaluations[id]!;
    final individual =
        state.day2GroupPerformanceSnapshot!.individualResults[id]!;
    final rows = [
      (isEn ? 'PERFORMANCE' : 'PERFORMANS', evaluation.performanceScore),
      (isEn ? 'GROWTH' : 'GELİŞİM', evaluation.developmentScore),
      (isEn ? 'POTENTIAL' : 'POTANSİYEL', evaluation.potentialScore),
    ];
    return _Page(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${_contestantIndex + 1} / 3', style: _label(context)),
          const SizedBox(height: AppSpacing.md),
          Center(
            child: SizedBox(
              width: 300,
              child: AspectRatio(
                aspectRatio: .82,
                child: ContestantPortrait(contestant: contestant),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            contestant.displayName,
            style: Theme.of(context).textTheme.displayLarge,
          ),
          Text(
            '${_localizedAssignedRole(individual.assignedRole, context)}  •  ${context.l10n.dayLabel(2)} ${individual.overall}',
            style: _label(context),
          ),
          if (state.playerRadarContestantIds.contains(id))
            Text(isEn ? '★ ON RADAR' : '★ RADARINDA', style: _label(context)),
          const SizedBox(height: AppSpacing.lg),
          ...List.generate(rows.length, (index) {
            final visible = _revealCount > index;
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: AppColors.line)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(rows[index].$1, style: _label(context)),
                        ),
                        Text(
                          visible ? '${rows[index].$2}' : '--',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ],
                    ),
                    if (visible)
                      Padding(
                        padding: const EdgeInsets.only(top: AppSpacing.xs),
                        child: Text(
                          '“${juryCategoryComment(rows[index].$1, rows[index].$2, context)}”',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(fontStyle: FontStyle.italic),
                        ),
                      ),
                  ],
                ),
              ),
            );
          }),
          if (_revealCount == 3)
            Text(
              _roleComment(groupTaskProfiles[id]!.primaryRole, context),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          const SizedBox(height: AppSpacing.lg),
          AppButton(
            label: _revealCount < 3
                ? (isEn
                    ? 'REVEAL ${rows[_revealCount].$1} SCORE'
                    : '${rows[_revealCount].$1} PUANINI AÇ')
                : _contestantIndex < 2
                    ? (isEn ? 'NEXT CONTESTANT' : 'SONRAKİ YARIŞMACI')
                    : (isEn ? 'PROCEED TO JURY DECISION' : 'JÜRİ KARARINA GEÇ'),
            onPressed: _nextReveal,
          ),
        ],
      ),
    );
  }

  Widget _decision(BuildContext context) {
    final isEn = isAppEnglish(context);
    final ids = GameScope.of(context).day2JuryRiskContestantIds;
    return _Page(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isEn ? 'THE JURY HAS DECIDED' : 'JÜRİ KARARINI VERDİ',
            style: Theme.of(context).textTheme.displayLarge,
          ),
          Text(
            isEn
                ? 'Three contestants.\nOne safe seat.'
                : 'Üç yarışmacı.\nBir güvenli koltuk.',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: AppSpacing.xl),
          _Portraits(ids: ids, contestant: _contestant),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: ids
                .map(
                  (_) => Expanded(
                    child: Text(
                      '--',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: AppSpacing.xl),
          AppButton(
            label: isEn ? 'REVEAL DECISION  →' : 'KARARI AÇ  →',
            onPressed: _openDecision,
          ),
        ],
      ),
    );
  }

  Widget _saved(BuildContext context) {
    final isEn = isAppEnglish(context);
    final state = GameScope.of(context);
    final id = _preview!.savedContestantId;
    final contestant = _contestant(id);
    final result = _preview!.evaluations[id]!;
    return _Page(
      child: Column(
        children: [
          Text(isEn ? 'JURY DECISION' : 'JÜRİ KARARI', style: _label(context)),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: 320,
            child: AspectRatio(
              aspectRatio: .82,
              child: ContestantPortrait(contestant: contestant),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            contestant.displayName,
            style: Theme.of(context).textTheme.displayLarge,
          ),
          Text(
            isEn ? 'SAFE' : 'GÜVENDE',
            style: Theme.of(context)
                .textTheme
                .headlineLarge
                ?.copyWith(color: AppColors.accentBright),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            isEn
                ? '“Tonight you earned the right to stay in this competition.”'
                : '“Bu gece yarışmaya devam etmeyi hak ettin.”',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          Text(
            '${isEn ? "PERFORMANCE" : "PERFORMANS"} ${result.performanceScore}  •  ${isEn ? "GROWTH" : "GELİŞİM"} ${result.developmentScore}  •  ${isEn ? "POTENTIAL" : "POTANSİYEL"} ${result.potentialScore}',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          Text(
            '${isEn ? "Jury Score:" : "Jüri Puanı:"} ${result.juryScore}',
            style: _label(context),
          ),
          if (state.playerRadarContestantIds.contains(id))
            Text(
              isEn
                  ? '★ Your radar favorite survived the danger zone.'
                  : '★ Radarındaki isim tehlikeyi atlattı.',
              style: _label(context),
            ),
          const SizedBox(height: AppSpacing.xl),
          AppButton(
            label: isEn ? 'SEE FINAL TWO' : 'SON İKİYİ GÖR',
            onPressed: () => setState(() => _phase = _JuryPhase.duel),
          ),
        ],
      ),
    );
  }

  Widget _duel(BuildContext context) {
    final isEn = isAppEnglish(context);
    final state = GameScope.of(context);
    final ids = _preview!.duelContestantIds;
    final radarCount =
        ids.where(state.playerRadarContestantIds.contains).length;
    final radarText = isEn
        ? (radarCount == 0
            ? 'Your initial favorites bypassed this duel entirely.'
            : radarCount == 1
                ? '★ A talent on your radar has fallen into the final two.'
                : '★ Two of your radar favorites face off head-to-head.')
        : (radarCount == 0
            ? 'İlk favorilerin bu düellonun dışında.'
            : radarCount == 1
                ? '★ Radarındaki bir isim son ikiye kaldı.'
                : '★ İki radar favorin karşı karşıya.');
    return _Page(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(isEn ? 'FINAL TWO' : 'SON İKİ', style: _label(context)),
          Text(
            isEn ? 'No team to hide behind this time.' : 'Bu kez takım yok.',
            style: Theme.of(context).textTheme.displayLarge,
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: _Duelist(
                  contestant: _contestant(ids.first),
                  result: _preview!.evaluations[ids.first]!,
                  history: _historyBadge(state, ids.first, context),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                child: Text('VS', style: _label(context)),
              ),
              Expanded(
                child: _Duelist(
                  contestant: _contestant(ids.last),
                  result: _preview!.evaluations[ids.last]!,
                  history: _historyBadge(state, ids.last, context),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(radarText, style: _label(context)),
          const SizedBox(height: AppSpacing.xl),
          Text(isEn ? 'DUEL' : 'DÜELLO', style: _label(context)),
          Text(
            isEn
                ? 'Two contestants will perform the same track with different interpretations.'
                : 'İki yarışmacı aynı parçayı farklı yaklaşımlarla yorumlayacak.',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          Text(
            isEn
                ? 'This time your producer decision directly reshapes the performance.'
                : 'Bu kez vereceğin karar doğrudan performansın şeklini değiştirecek.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: AppSpacing.xl),
          AppButton(
            label: isEn ? 'START DUEL  ★ →' : 'DÜELLOYU BAŞLAT  ★ →',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const Day2DuelScreen()),
            ),
          ),
        ],
      ),
    );
  }
}

class _Duelist extends StatelessWidget {
  const _Duelist({
    required this.contestant,
    required this.result,
    this.history,
  });
  final Contestant contestant;
  final Day2JuryEvaluationResult result;
  final String? history;
  @override
  Widget build(BuildContext context) => Column(
        children: [
          AspectRatio(
            aspectRatio: .72,
            child: ContestantPortrait(contestant: contestant),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            contestant.displayName,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          Text(
            'P ${result.performanceScore}  G ${result.developmentScore}  POT ${result.potentialScore}',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          Text(
            '${Localizations.localeOf(context).languageCode == "en" ? "JURY" : "JÜRİ"} ${result.juryScore}',
            style: _label(context),
          ),
          if (history != null)
            Text(
              history!,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AppColors.accentSoft),
            ),
        ],
      );
}

class _Portraits extends StatelessWidget {
  const _Portraits({
    required this.ids,
    required this.contestant,
    this.radarIds = const [],
  });
  final List<int> ids;
  final Contestant Function(int) contestant;
  final List<int> radarIds;
  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: ids
            .map(
              (id) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.xs),
                  child: Column(
                    children: [
                      AspectRatio(
                        aspectRatio: .72,
                        child: ContestantPortrait(contestant: contestant(id)),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        contestant(id).displayName,
                        maxLines: 1,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      if (radarIds.contains(id))
                        Text(
                          isAppEnglish(context) ? '★ ON RADAR' : '★ RADARINDA',
                          style: _label(context),
                        ),
                    ],
                  ),
                ),
              ),
            )
            .toList(),
      );
}

class _Page extends StatelessWidget {
  const _Page({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
        child: MaxWidthContainer(
          maxWidth: 760,
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
    .copyWith(color: AppColors.accentBright, letterSpacing: 1.3);

String _roleComment(GroupRole role, [BuildContext? context]) {
  final isEn = isAppEnglish(context);
  return switch (role) {
    GroupRole.vocal => isEn
        ? '“Your voice remains your biggest advantage.”'
        : '“Sesin hâlâ en büyük avantajın.”',
    GroupRole.dance => isEn
        ? '“Your technical skill can keep you in the game.”'
        : '“Teknik tarafın seni oyunda tutabilir.”',
    GroupRole.stage =>
      isEn ? '“The stage refuses to let you go.”' : '“Sahne seni bırakmıyor.”',
    GroupRole.allRounder => isEn
        ? '“You can do everything. Now you need to make one thing unforgettable.”'
        : '“Her şeyi yapabiliyorsun. Şimdi bir şeyi unutulmaz yapman gerekiyor.”',
  };
}

String? _historyBadge(GameState state, int id, [BuildContext? context]) {
  final isEn = isAppEnglish(context);
  if (id == state.day2CaptainAId || id == state.day2CaptainBId) {
    return isEn
        ? '★ You chose her as one of Day 2’s captains.'
        : '★ Onu 2. Gün kaptanlarından biri seçmiştin.';
  }
  if (state.playerRadarContestantIds.contains(id)) {
    return isEn
        ? '★ One of the original names on your radar.'
        : '★ İlk radarındaki isimlerden biriydi.';
  }
  final individual = state.day2GroupPerformanceSnapshot!.individualResults[id]!;
  if (individual.receivedDecisionBonus) {
    return isEn
        ? '★ Your rehearsal decision shaped her performance.'
        : '★ Prova kararın onun performansını etkiledi.';
  }
  return null;
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
