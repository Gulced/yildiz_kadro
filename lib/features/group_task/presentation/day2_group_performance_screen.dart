import 'dart:async';

import 'package:flutter/material.dart';
import 'package:yildiz_kadro/app/theme/app_colors.dart';
import 'package:yildiz_kadro/app/theme/app_spacing.dart';
import 'package:yildiz_kadro/core/responsive/breakpoints.dart';
import 'package:yildiz_kadro/features/contestants/data/contestant_seed_data.dart';
import 'package:yildiz_kadro/features/contestants/domain/contestant.dart';
import 'package:yildiz_kadro/l10n/l10n.dart';
import 'package:yildiz_kadro/features/contestants/presentation/widgets/contestant_portrait.dart';
import 'package:yildiz_kadro/features/evaluation/data/evaluation1_data.dart';
import 'package:yildiz_kadro/features/game/application/game_scope.dart';
import 'package:yildiz_kadro/features/group_task/data/day2_group_performance_engine.dart';
import 'package:yildiz_kadro/features/group_task/domain/day2_group_performance.dart';
import 'package:yildiz_kadro/features/group_task/domain/day2_rehearsal.dart';
import 'package:yildiz_kadro/features/group_task/presentation/day2_jury_table_screen.dart';
import 'package:yildiz_kadro/shared/widgets/app_button.dart';
import 'package:yildiz_kadro/shared/widgets/max_width_container.dart';

enum _Phase {
  intro,
  preStage,
  teamA,
  starA,
  teamB,
  starB,
  comparison,
  winner,
  loser,
  top3,
  risk,
  immunity,
  immunityReveal,
  jury,
}

class Day2GroupPerformanceScreen extends StatefulWidget {
  const Day2GroupPerformanceScreen({super.key});

  @override
  State<Day2GroupPerformanceScreen> createState() =>
      _Day2GroupPerformanceScreenState();
}

class _Day2GroupPerformanceScreenState
    extends State<Day2GroupPerformanceScreen> {
  _Phase _phase = _Phase.intro;
  int _categoryRevealCount = 0;
  int? _selectedImmunityId;
  bool _submitting = false;
  final List<Timer> _timers = [];
  bool _initializationScheduled = false;

  Contestant _contestant(int id) =>
      contestantSeedData.firstWhere((contestant) => contestant.id == id);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final state = GameScope.of(context);
    if (state.day2GroupPerformanceSnapshot == null &&
        !_initializationScheduled) {
      _initializationScheduled = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final game = GameScope.of(context);
        if (game.day2GroupPerformanceSnapshot != null) return;
        final captainA = game.day2CaptainAId;
        final captainB = game.day2CaptainBId;
        final setup = game.day2RehearsalSetup;
        final outcome = game.day2RehearsalOutcome;
        if (captainA == null ||
            captainB == null ||
            setup == null ||
            outcome == null) {
          return;
        }
        game.initializeDay2GroupPerformance(
          calculateDay2GroupPerformance(
            teamAIds: game.day2TeamAIds,
            teamBIds: game.day2TeamBIds,
            captainAId: captainA,
            captainBId: captainB,
            evaluationResults: evaluation1Results,
            rehearsalSetup: setup,
            rehearsalOutcome: outcome,
          ),
        );
      });
    }
    if (state.day2GroupPerformanceCompleted) _phase = _Phase.jury;
  }

  void _go(_Phase phase) {
    setState(() {
      _phase = phase;
      _categoryRevealCount = 0;
    });
    if (phase == _Phase.teamA || phase == _Phase.teamB) {
      _startCategoryReveal();
    }
  }

  void _startCategoryReveal() {
    _cancelTimers();
    for (var step = 1; step <= 4; step++) {
      _timers.add(
        Timer(Duration(milliseconds: step * 380), () {
          if (mounted && (_phase == _Phase.teamA || _phase == _Phase.teamB)) {
            setState(() => _categoryRevealCount = step);
          }
        }),
      );
    }
  }

  void _showCategories() {
    _cancelTimers();
    setState(() => _categoryRevealCount = 4);
  }

  Future<void> _confirmImmunity() async {
    final id = _selectedImmunityId;
    if (id == null || _submitting) return;
    final contestant = _contestant(id);
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: AppColors.inkSoft,
      builder: (context) {
        final isEn = isAppEnglish(context);
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEn
                      ? 'GRANT IMMUNITY TO ${contestant.displayName}'
                      : '${contestant.displayName}’YA DOKUNULMAZLIK VERİYORSUN',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  isEn
                      ? '${contestant.name} will bypass the Jury Table tonight.\nThis decision cannot be undone.'
                      : '${contestant.name} bu gece Jüri Masası’na gitmeyecek.\nBu karar geri alınamaz.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: Text(isEn ? 'GO BACK' : 'GERİ DÖN'),
                      ),
                    ),
                    Expanded(
                      child: FilledButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: Text(isEn ? 'YES, PROTECT' : 'EVET, KORU'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
    if (confirmed == true && mounted) {
      _submitting = true;
      GameScope.of(context)
          .completeDay2GroupPerformance(immunityContestantId: id);
      _go(_Phase.immunityReveal);
    }
  }

  void _cancelTimers() {
    for (final timer in _timers) {
      timer.cancel();
    }
    _timers.clear();
  }

  @override
  void dispose() {
    _cancelTimers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.ink,
        body: SafeArea(
          child: GameScope.of(context).day2GroupPerformanceSnapshot == null
              ? const Center(child: CircularProgressIndicator())
              : AnimatedSwitcher(
                  duration: const Duration(milliseconds: 240),
                  child: _buildPhase(context),
                ),
        ),
      );

  Widget _buildPhase(BuildContext context) {
    final state = GameScope.of(context);
    final snapshot = state.day2GroupPerformanceSnapshot!;
    final winnerCaptainId = snapshot.winningTeamId == 'A'
        ? state.day2CaptainAId!
        : state.day2CaptainBId!;
    final loserCaptainId = snapshot.losingTeamId == 'A'
        ? state.day2CaptainAId!
        : state.day2CaptainBId!;
    final winnerIds =
        snapshot.winningTeamId == 'A' ? state.day2TeamAIds : state.day2TeamBIds;
    final loserIds =
        snapshot.losingTeamId == 'A' ? state.day2TeamAIds : state.day2TeamBIds;
    switch (_phase) {
      case _Phase.intro:
        return _Intro(
          contestant: _contestant,
          onNext: () => _go(_Phase.preStage),
        );
      case _Phase.preStage:
        return _PreStage(
          contestant: _contestant,
          onNext: () => _go(_Phase.teamA),
        );
      case _Phase.teamA:
        return _TeamPerformance(
          progress: 1,
          teamIds: state.day2TeamAIds,
          captain: _contestant(state.day2CaptainAId!),
          roles: state.day2RehearsalSetup!.teamARoles,
          result: snapshot.teamAResult,
          revealCount: _categoryRevealCount,
          contestant: _contestant,
          onSkip: _showCategories,
          onNext: _categoryRevealCount == 4 ? () => _go(_Phase.starA) : null,
        );
      case _Phase.starA:
        return _StarReveal(
          result: snapshot.teamAResult,
          individual: snapshot
              .individualResults[snapshot.teamAResult.starContestantId]!,
          roles: state.day2RehearsalSetup!.teamARoles,
          contestant: _contestant(snapshot.teamAResult.starContestantId),
          onNext: () => _go(_Phase.teamB),
        );
      case _Phase.teamB:
        return _TeamPerformance(
          progress: 2,
          teamIds: state.day2TeamBIds,
          captain: _contestant(state.day2CaptainBId!),
          roles: state.day2RehearsalSetup!.teamBRoles,
          result: snapshot.teamBResult,
          revealCount: _categoryRevealCount,
          contestant: _contestant,
          onSkip: _showCategories,
          onNext: _categoryRevealCount == 4 ? () => _go(_Phase.starB) : null,
        );
      case _Phase.starB:
        return _StarReveal(
          result: snapshot.teamBResult,
          individual: snapshot
              .individualResults[snapshot.teamBResult.starContestantId]!,
          roles: state.day2RehearsalSetup!.teamBRoles,
          contestant: _contestant(snapshot.teamBResult.starContestantId),
          onNext: () => _go(_Phase.comparison),
        );
      case _Phase.comparison:
        return _Comparison(
          contestant: _contestant,
          onNext: () => _go(_Phase.winner),
        );
      case _Phase.winner:
        return _Winner(
          captain: _contestant(winnerCaptainId),
          ids: winnerIds,
          result: snapshot.winningTeamId == 'A'
              ? snapshot.teamAResult
              : snapshot.teamBResult,
          contestant: _contestant,
          intervened: state.day2RehearsalOutcome!.playerInterventionTeamId ==
              snapshot.winningTeamId,
          onNext: () => _go(_Phase.loser),
        );
      case _Phase.loser:
        return _Loser(
          captain: _contestant(loserCaptainId),
          ids: loserIds,
          contestant: _contestant,
          onNext: () => _go(_Phase.top3),
        );
      case _Phase.top3:
        return _Top3(
          ids: snapshot.top3SafeIds,
          contestant: _contestant,
          results: snapshot.individualResults,
          onNext: () => _go(_Phase.risk),
        );
      case _Phase.risk:
        return _RiskFour(
          ids: snapshot.initialRiskIds,
          contestant: _contestant,
          results: snapshot.individualResults,
          onNext: () => _go(_Phase.immunity),
        );
      case _Phase.immunity:
        return _ImmunitySelection(
          ids: snapshot.initialRiskIds,
          selectedId: _selectedImmunityId,
          contestant: _contestant,
          results: snapshot.individualResults,
          onSelect: (id) => setState(() => _selectedImmunityId = id),
          onConfirm: _selectedImmunityId == null ? null : _confirmImmunity,
        );
      case _Phase.immunityReveal:
        final id = state.day2StarImmunityContestantId!;
        return _ImmunityReveal(
          contestant: _contestant(id),
          wasTeamStar: id ==
              (snapshot.losingTeamId == 'A'
                  ? snapshot.teamAResult.starContestantId
                  : snapshot.teamBResult.starContestantId),
          onNext: () => _go(_Phase.jury),
        );
      case _Phase.jury:
        return _JuryRisk(
          contestant: _contestant,
          onNext: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => const Day2JuryTableScreen(),
            ),
          ),
        );
    }
  }
}

class _Intro extends StatelessWidget {
  const _Intro({required this.contestant, required this.onNext});
  final Contestant Function(int) contestant;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final isEn = isAppEnglish(context);
    final state = GameScope.of(context);
    return _Page(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.l10n.dayLabel(2), style: _pinkLabel(context)),
          const SizedBox(height: AppSpacing.sm),
          Text(
            isEn ? 'GROUP STAGE' : 'GRUP SAHNESİ',
            style: Theme.of(context).textTheme.displayLarge,
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            isEn
                ? 'Now their true strength together will be revealed.'
                : 'Şimdi birlikte ne kadar güçlü oldukları belli olacak.',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            isEn
                ? '14 contestants.\n2 teams.\n1 winner.'
                : '14 yarışmacı.\n2 takım.\n1 kazanan.',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            isEn
                ? 'Tonight isn’t just about raw individual skill; team chemistry, rehearsal choices, and stage balance are scored.'
                : 'Bugün yalnızca bireysel yetenek değil; takım uyumu, prova kararları ve sahne dengesi de puanlanacak.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            isEn
                ? 'Your rehearsal decision is about to play out on stage.'
                : 'Provada verdiğin karar birazdan sahneye yansıyacak.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.paperMuted,
                  fontStyle: FontStyle.italic,
                ),
          ),
          const SizedBox(height: AppSpacing.xl),
          _TeamStrip(
            captain: contestant(state.day2CaptainAId!),
            ids: state.day2TeamAIds,
            contestant: contestant,
          ),
          const SizedBox(height: AppSpacing.md),
          _TeamStrip(
            captain: contestant(state.day2CaptainBId!),
            ids: state.day2TeamBIds,
            contestant: contestant,
          ),
          const SizedBox(height: AppSpacing.xl),
          AppButton(
            label: isEn ? 'OPEN THE STAGE' : 'SAHNEYİ AÇ',
            onPressed: onNext,
          ),
        ],
      ),
    );
  }
}

class _PreStage extends StatelessWidget {
  const _PreStage({required this.contestant, required this.onNext});
  final Contestant Function(int) contestant;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final isEn = isAppEnglish(context);
    final state = GameScope.of(context);
    final snapshot = state.day2GroupPerformanceSnapshot!;
    final cards = [
      _PreTeamCard(
        captain: contestant(state.day2CaptainAId!),
        ids: state.day2TeamAIds,
        roles: state.day2RehearsalSetup!.teamARoles,
        result: snapshot.teamAResult,
        rehearsal: state.day2RehearsalOutcome!.teamAFinalMetrics,
        intervened: state.day2RehearsalOutcome!.playerInterventionTeamId == 'A',
        contestant: contestant,
      ),
      _PreTeamCard(
        captain: contestant(state.day2CaptainBId!),
        ids: state.day2TeamBIds,
        roles: state.day2RehearsalSetup!.teamBRoles,
        result: snapshot.teamBResult,
        rehearsal: state.day2RehearsalOutcome!.teamBFinalMetrics,
        intervened: state.day2RehearsalOutcome!.playerInterventionTeamId == 'B',
        contestant: contestant,
      ),
    ];
    return _Page(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isEn ? 'PRE-STAGE' : 'SAHNE ÖNCESİ',
            style: Theme.of(context).textTheme.displayLarge,
          ),
          const SizedBox(height: AppSpacing.lg),
          LayoutBuilder(
            builder: (context, constraints) {
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
          const SizedBox(height: AppSpacing.xl),
          AppButton(
            label: isEn ? 'WATCH FIRST SQUAD' : 'İLK TAKIMI İZLE',
            onPressed: onNext,
          ),
        ],
      ),
    );
  }
}

class _TeamPerformance extends StatelessWidget {
  const _TeamPerformance({
    required this.progress,
    required this.teamIds,
    required this.captain,
    required this.roles,
    required this.result,
    required this.revealCount,
    required this.contestant,
    required this.onSkip,
    required this.onNext,
  });
  final int progress;
  final List<int> teamIds;
  final Contestant captain;
  final TeamRoleAssignments roles;
  final TeamGroupPerformanceResult result;
  final int revealCount;
  final Contestant Function(int) contestant;
  final VoidCallback onSkip;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    final isEn = isAppEnglish(context);
    return _Page(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isEn
                ? 'GROUP STAGE — $progress / 2'
                : 'GRUP SAHNESİ — $progress / 2',
            style: _pinkLabel(context),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '${isEn ? "TEAM" : "TAKIM"} ${captain.displayName}',
            style: Theme.of(context).textTheme.displayLarge,
          ),
          Text(arrangementLabel(result, context), style: _pinkLabel(context)),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: teamIds
                .map(
                  (id) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(2),
                      child: Column(
                        children: [
                          AspectRatio(
                            aspectRatio: .72,
                            child: ContestantPortrait(
                              contestant: contestant(id),
                            ),
                          ),
                          if (id == roles.centerId ||
                              id == roles.mainVocalId ||
                              id == roles.danceLeadId)
                            Text(
                              id == roles.centerId
                                  ? 'CENTER'
                                  : id == roles.mainVocalId
                                      ? (isEn ? 'VOCAL' : 'VOKAL')
                                      : (isEn ? 'DANCE' : 'DANS'),
                              maxLines: 1,
                              style: _pinkLabel(context),
                            ),
                        ],
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: AppSpacing.xl),
          _RevealScore(
            context.l10n.vocal.toUpperCase(),
            result.vocal,
            revealCount >= 1,
          ),
          _RevealScore(
            context.l10n.dance.toUpperCase(),
            result.dance,
            revealCount >= 2,
          ),
          _RevealScore(
            context.l10n.stage.toUpperCase(),
            result.stage,
            revealCount >= 3,
          ),
          _RevealScore(
            isEn ? 'CHEMISTRY' : 'UYUM',
            result.harmony,
            revealCount >= 4,
          ),
          if (revealCount >= 4) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              '“${teamPerformanceNarrative(result, context)}”',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          if (revealCount < 4)
            TextButton(
              onPressed: onSkip,
              child: Text(isEn ? 'SPEED UP' : 'HIZLANDIR'),
            ),
          AppButton(
            label: revealCount == 4
                ? (isEn ? 'VIEW STAR MOMENT' : 'YILDIZ ANINI GÖR')
                : (isEn ? 'PERFORMANCE IN PROGRESS' : 'PERFORMANS SÜRÜYOR'),
            onPressed: onNext,
          ),
        ],
      ),
    );
  }
}

class _StarReveal extends StatelessWidget {
  const _StarReveal({
    required this.result,
    required this.individual,
    required this.roles,
    required this.contestant,
    required this.onNext,
  });
  final TeamGroupPerformanceResult result;
  final IndividualGroupPerformanceResult individual;
  final TeamRoleAssignments roles;
  final Contestant contestant;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final isEn = isAppEnglish(context);
    final radar =
        GameScope.of(context).playerRadarContestantIds.contains(contestant.id);
    final microcopy = individual.assignedRole == 'CENTER'
        ? (isEn
            ? 'Truly owned the center spotlight.'
            : 'Center rolünü gerçekten sahiplendi.')
        : individual.assignedRole.contains('VOKAL') ||
                individual.assignedRole.contains('VOCAL')
            ? (isEn
                ? 'Stood out with raw vocal power at crucial climaxes.'
                : 'En kritik anlarda sesiyle öne çıktı.')
            : individual.assignedRole.contains('DANCER') ||
                    individual.assignedRole.contains('DANS')
                ? (isEn
                    ? 'Elevated the entire squad’s tempo and momentum.'
                    : 'Takımın temposunu yukarı taşıdı.')
                : (isEn
                    ? 'Had no designated spotlight role, yet commanded the room.'
                    : 'Spotlight rolü yoktu. Yine de gözler ona döndü.');
    return _Page(
      child: Column(
        children: [
          Text(isEn ? 'STAR MOMENT' : 'YILDIZ ANI', style: _pinkLabel(context)),
          const SizedBox(height: AppSpacing.lg),
          AspectRatio(
            aspectRatio: .85,
            child: ContestantPortrait(contestant: contestant),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            contestant.displayName,
            style: Theme.of(context).textTheme.displayLarge,
          ),
          Text(
            '${isEn ? "PERFORMANCE" : "PERFORMANS"} ${individual.overall}',
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(color: AppColors.accentBright),
          ),
          if (radar)
            Text(
              isEn ? '★ ON RADAR' : '★ RADARINDA',
              style: _pinkLabel(context),
            ),
          const SizedBox(height: AppSpacing.md),
          Text(
            isEn
                ? 'Tonight all eyes gravitated towards her.'
                : 'Bu performansta gözler en çok onun üzerindeydi.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          Text(
            '“$microcopy”',
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(fontStyle: FontStyle.italic),
          ),
          if (individual.receivedDecisionBonus) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              isEn
                  ? '★ Your rehearsal choice paved the way for this moment.'
                  : '★ Verdiğin prova kararı bu anın önünü açtı.',
              textAlign: TextAlign.center,
              style: _pinkLabel(context),
            ),
          ],
          const SizedBox(height: AppSpacing.xl),
          AppButton(
            label: result.teamId == 'A'
                ? (isEn ? 'SECOND SQUAD' : 'İKİNCİ TAKIM')
                : (isEn ? 'COMPARE SCORES' : 'PUANLARI KARŞILAŞTIR'),
            onPressed: onNext,
          ),
        ],
      ),
    );
  }
}

class _Comparison extends StatelessWidget {
  const _Comparison({required this.contestant, required this.onNext});
  final Contestant Function(int) contestant;
  final VoidCallback onNext;
  @override
  Widget build(BuildContext context) {
    final isEn = isAppEnglish(context);
    final state = GameScope.of(context);
    final result = state.day2GroupPerformanceSnapshot!;
    return _Page(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isEn ? 'GROUP STAGE CONCLUDED' : 'GRUP SAHNESİ TAMAMLANDI',
            style: Theme.of(context).textTheme.displayLarge,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            isEn
                ? 'Rehearsal, role division, and squad chemistry now convert into points.'
                : 'Prova, rol dağılımı ve takım uyumu şimdi puana dönüşüyor.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: AppSpacing.xl),
          _ScoreBoard(
            captain: contestant(state.day2CaptainAId!),
            result: result.teamAResult,
          ),
          const SizedBox(height: AppSpacing.md),
          _ScoreBoard(
            captain: contestant(state.day2CaptainBId!),
            result: result.teamBResult,
          ),
          const SizedBox(height: AppSpacing.xl),
          AppButton(
            label: isEn ? 'REVEAL SCORES' : 'PUANLARI AÇ',
            onPressed: onNext,
          ),
        ],
      ),
    );
  }
}

class _Winner extends StatelessWidget {
  const _Winner({
    required this.captain,
    required this.ids,
    required this.result,
    required this.contestant,
    required this.intervened,
    required this.onNext,
  });
  final Contestant captain;
  final List<int> ids;
  final TeamGroupPerformanceResult result;
  final Contestant Function(int) contestant;
  final bool intervened;
  final VoidCallback onNext;
  @override
  Widget build(BuildContext context) {
    final isEn = isAppEnglish(context);
    return _Page(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isEn ? 'NIGHT’S WINNER' : 'GECENİN KAZANANI',
            style: _pinkLabel(context),
          ),
          Text(
            '${isEn ? "TEAM" : "TAKIM"} ${captain.displayName}',
            style: Theme.of(context).textTheme.displayLarge,
          ),
          const SizedBox(height: AppSpacing.lg),
          _PortraitRow(ids: ids, contestant: contestant),
          const SizedBox(height: AppSpacing.lg),
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.accentInk,
              border: Border.all(color: AppColors.accent),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    isEn ? 'GROUP SCORE' : 'GRUP PUANI',
                    style: _pinkLabel(context),
                  ),
                ),
                Text(
                  '${result.groupScore}',
                  style: Theme.of(context)
                      .textTheme
                      .displayLarge
                      ?.copyWith(color: AppColors.accentBright),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            intervened
                ? (isEn
                    ? '★ Your rehearsal decision became an integral piece of the winning stage.'
                    : '★ Provada verdiğin karar kazanan performansın parçası oldu.')
                : (isEn
                    ? 'The captain’s rehearsal choices held the squad unified on stage.'
                    : 'Kaptanın prova kararı takımı sahnede bir arada tuttu.'),
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: AppSpacing.xl),
          AppButton(
            label:
                isEn ? 'VIEW OTHER SQUAD’S FATE' : 'DİĞER TAKIMIN SONUCUNU GÖR',
            onPressed: onNext,
          ),
        ],
      ),
    );
  }
}

class _Loser extends StatelessWidget {
  const _Loser({
    required this.captain,
    required this.ids,
    required this.contestant,
    required this.onNext,
  });
  final Contestant captain;
  final List<int> ids;
  final Contestant Function(int) contestant;
  final VoidCallback onNext;
  @override
  Widget build(BuildContext context) {
    final isEn = isAppEnglish(context);
    return _Page(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isEn ? 'SQUAD AT RISK' : 'RİSKTEKİ TAKIM',
            style: _pinkLabel(context),
          ),
          Text(
            '${isEn ? "TEAM" : "TAKIM"} ${captain.displayName}',
            style: Theme.of(context).textTheme.displayLarge,
          ),
          const SizedBox(height: AppSpacing.lg),
          _PortraitRow(ids: ids, contestant: contestant),
          const SizedBox(height: AppSpacing.lg),
          Text(
            isEn
                ? 'This is not elimination yet. Now individual performances will separate them.'
                : 'Bu henüz bir eleme değil. Şimdi bireysel performanslar ayrışacak.',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: AppSpacing.xl),
          AppButton(
            label: isEn ? 'REVEAL INDIVIDUAL SCORES' : 'BİREYSEL SONUÇLARI AÇ',
            onPressed: onNext,
          ),
        ],
      ),
    );
  }
}

class _Top3 extends StatelessWidget {
  const _Top3({
    required this.ids,
    required this.contestant,
    required this.results,
    required this.onNext,
  });
  final List<int> ids;
  final Contestant Function(int) contestant;
  final Map<int, IndividualGroupPerformanceResult> results;
  final VoidCallback onNext;
  @override
  Widget build(BuildContext context) {
    final isEn = isAppEnglish(context);
    return _Page(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isEn ? 'THE SQUAD’S TOP THREE' : 'TAKIMIN EN GÜÇLÜ ÜÇLÜSÜ',
            style: Theme.of(context).textTheme.displayLarge,
          ),
          Text(
            isEn
                ? 'Their individual performances secured their safety.'
                : 'Bireysel performansları onları güvende tuttu.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: AppSpacing.lg),
          ...ids.map(
            (id) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: _ResultCard(
                contestant: contestant(id),
                result: results[id]!,
                safe: true,
              ),
            ),
          ),
          AppButton(
            label: isEn ? 'ENTER RISK ZONE' : 'RİSK BÖLGESİNİ AÇ',
            onPressed: onNext,
          ),
        ],
      ),
    );
  }
}

class _RiskFour extends StatelessWidget {
  const _RiskFour({
    required this.ids,
    required this.contestant,
    required this.results,
    required this.onNext,
  });
  final List<int> ids;
  final Contestant Function(int) contestant;
  final Map<int, IndividualGroupPerformanceResult> results;
  final VoidCallback onNext;
  @override
  Widget build(BuildContext context) {
    final isEn = isAppEnglish(context);
    return _Page(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isEn ? 'PRIMARY RISK ZONE' : 'İLK RİSK BÖLGESİ',
            style: _pinkLabel(context),
          ),
          Text(
            isEn ? '4 Contestants' : '4 yarışmacı',
            style: Theme.of(context).textTheme.displayLarge,
          ),
          Text(
            isEn
                ? 'You will protect one member. The remaining three must face the Jury Table.'
                : 'Bir kişiyi sen koruyacaksın. Kalan üç kişi Jüri Masası’na gidecek.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: AppSpacing.lg),
          ...ids.map(
            (id) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: _ResultCard(
                contestant: contestant(id),
                result: results[id]!,
              ),
            ),
          ),
          AppButton(
            label: isEn ? 'GRANT IMMUNITY' : 'DOKUNULMAZLIK VER',
            onPressed: onNext,
          ),
        ],
      ),
    );
  }
}

class _ImmunitySelection extends StatelessWidget {
  const _ImmunitySelection({
    required this.ids,
    required this.selectedId,
    required this.contestant,
    required this.results,
    required this.onSelect,
    required this.onConfirm,
  });
  final List<int> ids;
  final int? selectedId;
  final Contestant Function(int) contestant;
  final Map<int, IndividualGroupPerformanceResult> results;
  final ValueChanged<int> onSelect;
  final VoidCallback? onConfirm;
  @override
  Widget build(BuildContext context) {
    final isEn = isAppEnglish(context);
    final radar = GameScope.of(context).playerRadarContestantIds;
    return _Page(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isEn ? 'PRODUCER IMMUNITY' : 'YAPIMCI DOKUNULMAZLIĞI',
            style: _pinkLabel(context),
          ),
          Text(
            isEn ? 'Protect one contestant.' : 'Bir kişiyi koru.',
            style: Theme.of(context).textTheme.displayLarge,
          ),
          Text(
            isEn
                ? 'Once confirmed, this decision cannot be undone.'
                : 'Kararın kesinleştiğinde geri alınamaz.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: AppSpacing.lg),
          ...ids.map(
            (id) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: InkWell(
                onTap: () => onSelect(id),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: selectedId == id
                          ? AppColors.accentBright
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      _ResultCard(
                        contestant: contestant(id),
                        result: results[id]!,
                      ),
                      if (radar.contains(id))
                        Padding(
                          padding: const EdgeInsets.all(AppSpacing.xs),
                          child: Text(
                            isEn ? '★ ON RADAR' : '★ RADARINDA',
                            style: _pinkLabel(context),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          AppButton(
            label: selectedId == null
                ? (isEn ? 'SELECT ONE CONTESTANT' : 'BİR KİŞİ SEÇ')
                : (isEn ? 'LOCK CHOICE  ★' : 'SEÇİMİ KİLİTLE  ★'),
            onPressed: onConfirm,
          ),
        ],
      ),
    );
  }
}

class _ImmunityReveal extends StatelessWidget {
  const _ImmunityReveal({
    required this.contestant,
    required this.wasTeamStar,
    required this.onNext,
  });
  final Contestant contestant;
  final bool wasTeamStar;
  final VoidCallback onNext;
  @override
  Widget build(BuildContext context) {
    final isEn = isAppEnglish(context);
    return _Page(
      child: Column(
        children: [
          Text(isEn ? 'IMMUNE' : 'DOKUNULMAZ', style: _pinkLabel(context)),
          const SizedBox(height: AppSpacing.lg),
          AspectRatio(
            aspectRatio: .86,
            child: ContestantPortrait(contestant: contestant),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            contestant.displayName,
            style: Theme.of(context).textTheme.displayLarge,
          ),
          Text(
            wasTeamStar
                ? (isEn
                    ? 'She was the squad’s star. Now safe by your command.'
                    : 'Takımın yıldızıydı. Şimdi senin kararınla güvende.')
                : (isEn
                    ? 'She will bypass the Jury Table tonight.'
                    : 'Bu gece Jüri Masası’na gitmeyecek.'),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: AppSpacing.xl),
          AppButton(
            label: isEn ? 'PROCEED TO JURY RISK' : 'JÜRİ RİSKİNİ AÇ',
            onPressed: onNext,
          ),
        ],
      ),
    );
  }
}

class _JuryRisk extends StatelessWidget {
  const _JuryRisk({required this.contestant, required this.onNext});
  final Contestant Function(int) contestant;
  final VoidCallback onNext;
  @override
  Widget build(BuildContext context) {
    final isEn = isAppEnglish(context);
    final state = GameScope.of(context);
    final ids = state.day2JuryRiskContestantIds;
    return _Page(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(isEn ? 'JURY TABLE' : 'JÜRİ MASASI', style: _pinkLabel(context)),
          Text(
            isEn ? 'Three remain.' : 'Üç kişi kaldı.',
            style: Theme.of(context).textTheme.displayLarge,
          ),
          Text(
            isEn
                ? 'Team battle has ended. Now each contestant stands alone.'
                : 'Takım sonucu bitti. Şimdi herkes tek başına.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: AppSpacing.xl),
          _PortraitRow(ids: ids, contestant: contestant),
          const SizedBox(height: AppSpacing.md),
          Text(
            isEn
                ? '${ids.where(state.playerRadarContestantIds.contains).length} contestants were on your radar.'
                : '${ids.where(state.playerRadarContestantIds.contains).length} kişi radarındaydı.',
            style: _pinkLabel(context),
          ),
          const SizedBox(height: AppSpacing.xl),
          AppButton(
            label: isEn ? 'ENTER JURY TABLE  →' : 'JÜRİ MASASINA GİT  →',
            onPressed: onNext,
          ),
        ],
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({
    required this.contestant,
    required this.result,
    this.safe = false,
  });
  final Contestant contestant;
  final IndividualGroupPerformanceResult result;
  final bool safe;
  @override
  Widget build(BuildContext context) {
    final isEn = isAppEnglish(context);
    return Container(
      decoration: BoxDecoration(
        color: AppColors.inkSoft,
        border: Border.all(color: safe ? AppColors.accentSoft : AppColors.line),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 88,
            height: 112,
            child: ContestantPortrait(contestant: contestant),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    contestant.displayName,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text(
                    _localizedAssignedRole(result.assignedRole, context),
                    style: _pinkLabel(context),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '${isEn ? "VOCAL" : "VOKAL"} ${result.vocal}  •  ${isEn ? "DANCE" : "DANS"} ${result.dance}  •  ${isEn ? "STAGE" : "SAHNE"} ${result.stage}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Text(
              '${result.overall}',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(color: AppColors.accentBright),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScoreBoard extends StatelessWidget {
  const _ScoreBoard({required this.captain, required this.result});
  final Contestant captain;
  final TeamGroupPerformanceResult result;
  @override
  Widget build(BuildContext context) {
    final isEn = isAppEnglish(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.inkSoft,
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${isEn ? "TEAM" : "TAKIM"} ${captain.displayName}',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '${isEn ? "VOCAL" : "VOKAL"} ${result.vocal}   ${isEn ? "DANCE" : "DANS"} ${result.dance}   ${isEn ? "STAGE" : "SAHNE"} ${result.stage}   ${isEn ? "CHEMISTRY" : "UYUM"} ${result.harmony}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const Divider(color: AppColors.line),
          Text(
            '${isEn ? "GROUP SCORE" : "GRUP PUANI"}  ${result.groupScore}',
            style: _pinkLabel(context),
          ),
        ],
      ),
    );
  }
}

class _TeamStrip extends StatelessWidget {
  const _TeamStrip({
    required this.captain,
    required this.ids,
    required this.contestant,
  });
  final Contestant captain;
  final List<int> ids;
  final Contestant Function(int) contestant;
  @override
  Widget build(BuildContext context) {
    final isEn = isAppEnglish(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${isEn ? "TEAM" : "TAKIM"} ${captain.displayName}',
          style: _pinkLabel(context),
        ),
        const SizedBox(height: AppSpacing.xs),
        _PortraitRow(ids: ids, contestant: contestant),
      ],
    );
  }
}

class _PortraitRow extends StatelessWidget {
  const _PortraitRow({required this.ids, required this.contestant});
  final List<int> ids;
  final Contestant Function(int) contestant;
  @override
  Widget build(BuildContext context) => Row(
        children: ids
            .map(
              (id) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 3),
                  child: AspectRatio(
                    aspectRatio: .72,
                    child: ContestantPortrait(contestant: contestant(id)),
                  ),
                ),
              ),
            )
            .toList(),
      );
}

class _PreTeamCard extends StatelessWidget {
  const _PreTeamCard({
    required this.captain,
    required this.ids,
    required this.roles,
    required this.result,
    required this.rehearsal,
    required this.intervened,
    required this.contestant,
  });
  final Contestant captain;
  final List<int> ids;
  final TeamRoleAssignments roles;
  final TeamGroupPerformanceResult result;
  final RehearsalMetrics rehearsal;
  final bool intervened;
  final Contestant Function(int) contestant;
  @override
  Widget build(BuildContext context) {
    final isEn = isAppEnglish(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.inkSoft,
        border: Border.all(
          color: intervened ? AppColors.accent : AppColors.line,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${isEn ? "TEAM" : "TAKIM"} ${captain.displayName}',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          Text(arrangementLabel(result, context), style: _pinkLabel(context)),
          const SizedBox(height: AppSpacing.sm),
          _PortraitRow(ids: ids, contestant: contestant),
          const SizedBox(height: AppSpacing.sm),
          Text(
            roles.roleSlots.isEmpty
                ? 'CENTER ${contestant(roles.centerId).displayName}  •  ${isEn ? "LEAD VOCAL" : "ANA VOKAL"} ${contestant(roles.mainVocalId).displayName}  •  ${isEn ? "DANCE" : "DANS"} ${contestant(roles.danceLeadId).displayName}'
                : roles.roleSlots
                    .map(
                      (entry) =>
                          '${day2TeamRoleLabel(entry.slot.type, context)} ${contestant(entry.contestantId).displayName}',
                    )
                    .join('  •  '),
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '${isEn ? "REHEARSAL" : "PROVA"} ${rehearsal.score}${intervened ? (isEn ? "  ★ YOUR CHOICE" : "  ★ SENİN KARARIN") : ""}',
            style: _pinkLabel(context),
          ),
        ],
      ),
    );
  }
}

class _RevealScore extends StatelessWidget {
  const _RevealScore(this.label, this.score, this.visible);
  final String label;
  final int score;
  final bool visible;
  @override
  Widget build(BuildContext context) => AnimatedOpacity(
        duration: const Duration(milliseconds: 220),
        opacity: visible ? 1 : .18,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
          child: Row(
            children: [
              Expanded(child: Text(label, style: _pinkLabel(context))),
              Text(
                visible ? '$score' : '—',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ],
          ),
        ),
      );
}

class _Page extends StatelessWidget {
  const _Page({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
        child: MaxWidthContainer(
          maxWidth: 820,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: child,
          ),
        ),
      );
}

TextStyle _pinkLabel(BuildContext context) => Theme.of(context)
    .textTheme
    .labelLarge!
    .copyWith(color: AppColors.accentBright, letterSpacing: 1.5);

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
