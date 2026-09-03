import 'dart:async';

import 'package:flutter/material.dart';
import 'package:yildiz_kadro/app/theme/app_colors.dart';
import 'package:yildiz_kadro/app/theme/app_spacing.dart';
import 'package:yildiz_kadro/features/contestants/data/contestant_seed_data.dart';
import 'package:yildiz_kadro/features/contestants/domain/contestant.dart';
import 'package:yildiz_kadro/features/contestants/domain/contestant_localization.dart';
import 'package:yildiz_kadro/l10n/l10n.dart';
import 'package:yildiz_kadro/features/contestants/presentation/widgets/contestant_portrait.dart';
import 'package:yildiz_kadro/features/evaluation/data/evaluation1_data.dart';
import 'package:yildiz_kadro/features/evaluation/domain/evaluation_result.dart';
import 'package:yildiz_kadro/features/evaluation/presentation/evaluation_results_screen.dart';
import 'package:yildiz_kadro/features/game/application/game_scope.dart';
import 'package:yildiz_kadro/shared/widgets/app_button.dart';
import 'package:yildiz_kadro/shared/widgets/max_width_container.dart';

class EvaluationRevealScreen extends StatefulWidget {
  const EvaluationRevealScreen({super.key});

  @override
  State<EvaluationRevealScreen> createState() => _EvaluationRevealScreenState();
}

class _EvaluationRevealScreenState extends State<EvaluationRevealScreen> {
  int _contestantIndex = 0;
  int _revealedScoreCount = 0;
  bool _isAdvancing = false;
  final List<Timer> _timers = [];

  Contestant get _contestant => contestantSeedData.firstWhere(
        (contestant) =>
            contestant.id == evaluation1RevealOrder[_contestantIndex],
      );
  EvaluationResult get _result => evaluation1Results[_contestant.id]!;

  @override
  void initState() {
    super.initState();
    _startReveal();
  }

  void _startReveal() {
    _cancelTimers();
    _revealedScoreCount = 0;
    for (var step = 1; step <= 4; step++) {
      _timers.add(
        Timer(Duration(milliseconds: 380 * step), () {
          if (!mounted) return;
          setState(() => _revealedScoreCount = step);
        }),
      );
    }
  }

  void _cancelTimers() {
    for (final timer in _timers) {
      timer.cancel();
    }
    _timers.clear();
  }

  void _next() {
    if (_revealedScoreCount < 4 || _isAdvancing) return;
    _isAdvancing = true;
    if (_contestantIndex == evaluation1RevealOrder.length - 1) {
      GameScope.of(context).completeEvaluation1(evaluation1Results);
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => const EvaluationResultsScreen(),
        ),
      );
      return;
    }
    setState(() {
      _contestantIndex++;
      _isAdvancing = false;
      _revealedScoreCount = 0;
    });
    _startReveal();
  }

  @override
  void dispose() {
    _cancelTimers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gameState = GameScope.of(context);
    final isOnRadar = gameState.playerRadarContestantIds.contains(
      _contestant.id,
    );
    final isComplete = _revealedScoreCount == 4;
    return Scaffold(
      backgroundColor: AppColors.ink,
      body: SafeArea(
        child: MaxWidthContainer(
          maxWidth: 760,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      tooltip: context.l10n.back,
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
                    const Spacer(),
                    Text(
                      '${_contestantIndex + 1} / 15',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: AppColors.paperMuted,
                            letterSpacing: 1.2,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Expanded(
                  child: SingleChildScrollView(
                    child: _RevealCard(
                      contestant: _contestant,
                      result: _result,
                      isOnRadar: isOnRadar,
                      revealedScoreCount: _revealedScoreCount,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                AppButton(
                  label: _contestantIndex == 14
                      ? context.l10n.seeResults
                      : context.l10n.nextContestant,
                  onPressed: isComplete ? _next : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RevealCard extends StatelessWidget {
  const _RevealCard({
    required this.contestant,
    required this.result,
    required this.isOnRadar,
    required this.revealedScoreCount,
  });

  final Contestant contestant;
  final EvaluationResult result;
  final bool isOnRadar;
  final int revealedScoreCount;

  String? _radarReaction(BuildContext context) {
    if (isOnRadar && result.overall >= 88) {
      return context.l10n.radarPaidOff;
    }
    if (isOnRadar && result.overall <= 84) {
      return context.l10n.radarDebatable;
    }
    if (!isOnRadar && result.overall >= 89) {
      return context.l10n.notOnRadarThinkAgain;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final reaction = _radarReaction(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.inkSoft,
        border: Border.all(color: AppColors.line),
        borderRadius: const BorderRadius.all(Radius.circular(7)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1.25,
              child: ContestantPortrait(contestant: contestant),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${contestant.number} • ${contestant.displayName} — ${contestant.age}',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        contestant.localizedArchetype(context).toUpperCase(),
                        style:
                            Theme.of(context).textTheme.labelMedium?.copyWith(
                                  color: AppColors.accentSoft,
                                  letterSpacing: 0.8,
                                ),
                      ),
                    ],
                  ),
                ),
                if (isOnRadar)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 6,
                    ),
                    color: AppColors.accent,
                    child: Text(
                      isAppEnglish(context) ? '★ ON RADAR' : '★ RADARINDA',
                      style: Theme.of(context)
                          .textTheme
                          .labelMedium
                          ?.copyWith(color: AppColors.accentInk),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                _Score(
                  label: context.l10n.vocal,
                  value: result.vocal,
                  revealed: revealedScoreCount >= 1,
                ),
                _Score(
                  label: context.l10n.dance,
                  value: result.dance,
                  revealed: revealedScoreCount >= 2,
                ),
                _Score(
                  label: context.l10n.stage,
                  value: result.stage,
                  revealed: revealedScoreCount >= 3,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            AnimatedOpacity(
              opacity: revealedScoreCount >= 4 ? 1 : 0,
              duration: const Duration(milliseconds: 220),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${isAppEnglish(context) ? 'OVERALL' : 'GENEL'} ${revealedScoreCount >= 4 ? result.overall : '--'}',
                    style: Theme.of(context)
                        .textTheme
                        .displayLarge
                        ?.copyWith(color: AppColors.accentBright, fontSize: 44),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    result.localizedTag(context),
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: AppColors.accentSoft,
                          letterSpacing: 1,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '“${result.localizedComment(context)}”',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(color: AppColors.paper),
                  ),
                  if (reaction != null) ...[
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      reaction,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.paperMuted,
                            fontStyle: FontStyle.italic,
                          ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Score extends StatelessWidget {
  const _Score({
    required this.label,
    required this.value,
    required this.revealed,
  });

  final String label;
  final int value;
  final bool revealed;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(label, style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: AppSpacing.xs),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: Text(
              revealed ? '$value' : '--',
              key: ValueKey(revealed),
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: revealed ? AppColors.paper : AppColors.paperMuted,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
