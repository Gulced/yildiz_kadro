import 'dart:async';

import 'package:flutter/material.dart';
import 'package:yildiz_kadro/app/theme/app_colors.dart';
import 'package:yildiz_kadro/app/theme/app_spacing.dart';
import 'package:yildiz_kadro/features/contestants/data/contestant_seed_data.dart';
import 'package:yildiz_kadro/features/contestants/domain/contestant.dart';
import 'package:yildiz_kadro/features/contestants/presentation/widgets/contestant_portrait.dart';
import 'package:yildiz_kadro/features/evaluation/data/evaluation1_data.dart';
import 'package:yildiz_kadro/features/game/application/game_scope.dart';
import 'package:yildiz_kadro/features/last_chance/data/last_chance_data.dart';
import 'package:yildiz_kadro/features/last_chance/domain/last_chance_result.dart';
import 'package:yildiz_kadro/features/roster/presentation/post_elimination_roster_screen.dart';
import 'package:yildiz_kadro/shared/widgets/app_button.dart';
import 'package:yildiz_kadro/shared/widgets/max_width_container.dart';

enum _Phase {
  intro,
  concept,
  coaching,
  reveal,
  comparison,
  firstSafe,
  finalTwo,
  farewell
}

class LastChancePerformanceScreen extends StatefulWidget {
  const LastChancePerformanceScreen({super.key});

  @override
  State<LastChancePerformanceScreen> createState() =>
      _LastChancePerformanceScreenState();
}

class _LastChancePerformanceScreenState
    extends State<LastChancePerformanceScreen> {
  _Phase _phase = _Phase.intro;
  int? _selectedCoachId;
  int _performanceIndex = 0;
  int _revealStep = 0;
  bool _busy = false;
  final List<Timer> _timers = [];

  Contestant _contestant(int id) =>
      contestantSeedData.firstWhere((contestant) => contestant.id == id);

  List<int> get _trio => GameScope.of(context).lastChanceContestantIds;
  int get _coachId => GameScope.of(context).lastChanceCoachContestantId!;
  List<int> get _revealIds =>
      lastChanceRevealPriority.where(_trio.contains).toList(growable: false);
  List<LastChanceResult> get _ranking => rankLastChanceResults(
        contestantIds: _trio,
        coachContestantId: _coachId,
      );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final state = GameScope.of(context);
    if (state.lastChance1Completed) {
      _phase = _Phase.farewell;
    } else if (state.lastChanceCoachContestantId != null &&
        _phase.index < _Phase.reveal.index) {
      _phase = _Phase.reveal;
      _startPerformanceReveal();
    }
  }

  void _go(_Phase phase) {
    setState(() => _phase = phase);
    if (phase == _Phase.reveal) _startPerformanceReveal();
  }

  Future<void> _confirmCoach() async {
    final id = _selectedCoachId;
    if (id == null || _busy) return;
    final contestant = _contestant(id);
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: AppColors.inkSoft,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${contestant.displayName}’YE SAHNE NOTU VERİYORSUN',
                  style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: AppSpacing.md),
              Text('Bu bölümde yalnızca bir yarışmacıya müdahale edebilirsin.',
                  style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('GERİ DÖN'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('NOTU VER'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    if (confirmed == true && mounted) {
      _busy = true;
      GameScope.of(context).lockLastChanceCoach(id);
      _go(_Phase.reveal);
    }
  }

  void _startPerformanceReveal() {
    _cancelTimers();
    _revealStep = 0;
    _timers.add(Timer(const Duration(milliseconds: 250), () {
      if (mounted && _phase == _Phase.reveal) _busy = false;
    }));
    final coached = _revealIds[_performanceIndex] == _coachId;
    final totalSteps = coached ? 5 : 4;
    for (var step = 1; step <= totalSteps; step++) {
      _timers.add(Timer(Duration(milliseconds: step * 360), () {
        if (mounted && _phase == _Phase.reveal) {
          setState(() => _revealStep = step);
        }
      }));
    }
  }

  void _nextPerformance() {
    final coached = _revealIds[_performanceIndex] == _coachId;
    if (_busy || _revealStep < (coached ? 5 : 4)) return;
    _busy = true;
    if (_performanceIndex == 2) {
      // The animation lock only belongs to the individual performance reveal.
      // Release it before the result phases so the elimination CTA can advance.
      _busy = false;
      _go(_Phase.comparison);
      return;
    }
    setState(() {
      _performanceIndex++;
      _revealStep = 0;
    });
    _startPerformanceReveal();
  }

  void _completeElimination() {
    if (_busy || GameScope.of(context).lastChance1Completed) return;
    _busy = true;
    final ranking = _ranking;
    final trioResults = {
      for (final id in _trio) id: lastChanceResults[id]!,
    };
    GameScope.of(context).completeLastChance1(
      results: trioResults,
      eliminatedContestantId: ranking.last.contestantId,
    );
    _go(_Phase.farewell);
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
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 240),
            child: _buildPhase(context),
          ),
        ),
      );

  Widget _buildPhase(BuildContext context) {
    switch (_phase) {
      case _Phase.intro:
        return _Intro(
          trio: _trio.map(_contestant).toList(),
          onNext: () => _go(_Phase.concept),
        );
      case _Phase.concept:
        return _Concept(onNext: () => _go(_Phase.coaching));
      case _Phase.coaching:
        return _Coaching(
          trio: _trio.map(_contestant).toList(),
          selectedId: _selectedCoachId,
          onSelect: (id) => setState(() => _selectedCoachId = id),
          onConfirm: _selectedCoachId == null ? null : _confirmCoach,
        );
      case _Phase.reveal:
        final id = _revealIds[_performanceIndex];
        return _PerformanceReveal(
          contestant: _contestant(id),
          result: lastChanceResults[id]!,
          coached: id == _coachId,
          progress: _performanceIndex + 1,
          revealStep: _revealStep,
          onNext:
              _revealStep >= (id == _coachId ? 5 : 4) ? _nextPerformance : null,
        );
      case _Phase.comparison:
        return _Comparison(
          trio: _trio.map(_contestant).toList(),
          onNext: () => _go(_Phase.firstSafe),
        );
      case _Phase.firstSafe:
        final first = _ranking.first;
        return _SafeReveal(
          label: 'İLK GÜVENDEKİ İSİM',
          contestant: _contestant(first.contestantId),
          score: first.finalScore(coached: first.contestantId == _coachId),
          onNext: () => _go(_Phase.finalTwo),
        );
      case _Phase.finalTwo:
        return _FinalTwo(
          safeContestant: _contestant(_ranking[1].contestantId),
          eliminatedContestant: _contestant(_ranking[2].contestantId),
          safeScore: _ranking[1].finalScore(
            coached: _ranking[1].contestantId == _coachId,
          ),
          onNext: _completeElimination,
        );
      case _Phase.farewell:
        final state = GameScope.of(context);
        final eliminatedId = state.eliminatedContestantIds.last;
        final result = lastChanceResults[eliminatedId]!;
        return _Farewell(
          contestant: _contestant(eliminatedId),
          score: result.finalScore(coached: eliminatedId == _coachId),
          coachId: _coachId,
          onNext: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => const PostEliminationRosterScreen(),
            ),
          ),
        );
    }
  }
}

class _Intro extends StatelessWidget {
  const _Intro({required this.trio, required this.onNext});
  final List<Contestant> trio;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final radar = GameScope.of(context).playerRadarContestantIds;
    final radarCount = trio.where((c) => radar.contains(c.id)).length;
    final feedback = radarCount == 0
        ? 'İlk favorilerin bu kez sahnenin dışında.'
        : radarCount == 1
            ? '★ Radarındaki bir isim tehlikede.'
            : '★ Radarındaki $radarCount isim tehlikede.';
    return _Page(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('1. GÜN', style: _pinkLabel(context)),
          const SizedBox(height: AppSpacing.sm),
          Text('SON ŞANS', style: Theme.of(context).textTheme.displayLarge),
          const SizedBox(height: AppSpacing.xl),
          Text('Bu kez yalnızca üç kişi sahnede.',
              style: Theme.of(context).textTheme.headlineLarge),
          const SizedBox(height: AppSpacing.md),
          Text('Aynı sahne.\nAynı baskı.\nTek bir veda.',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Bu performansın sonunda bir yarışmacı Yıldız Kadro’ya veda edecek.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.paperMuted,
                  fontStyle: FontStyle.italic,
                ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: trio
                .map((c) => Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(3),
                        child: AspectRatio(
                          aspectRatio: 0.75,
                          child: ContestantPortrait(contestant: c),
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(feedback,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.accentSoft,
                  )),
          const SizedBox(height: AppSpacing.xl),
          AppButton(label: 'SON ŞANSI BAŞLAT', onPressed: onNext),
        ],
      ),
    );
  }
}

class _Concept extends StatelessWidget {
  const _Concept({required this.onNext});
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) => _Page(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('SON ŞANS PERFORMANSI',
                style: Theme.of(context).textTheme.displayLarge),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Üç yarışmacı aynı kısa performans paketini hazırladı.\nJüri bu kez gelişime, baskı altında toparlanmaya ve sahne hakimiyetine bakacak.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: AppSpacing.xl),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [Text('VOKAL'), Text('DANS'), Text('SAHNE')],
            ),
            const SizedBox(height: AppSpacing.xxl),
            AppButton(label: 'SAHNE NOTUNU SEÇ', onPressed: onNext),
          ],
        ),
      );
}

class _Coaching extends StatelessWidget {
  const _Coaching({
    required this.trio,
    required this.selectedId,
    required this.onSelect,
    required this.onConfirm,
  });
  final List<Contestant> trio;
  final int? selectedId;
  final ValueChanged<int> onSelect;
  final VoidCallback? onConfirm;

  @override
  Widget build(BuildContext context) => _Page(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('SAHNE NOTU', style: _pinkLabel(context)),
            const SizedBox(height: AppSpacing.sm),
            Text('Bir kişiye son bir not bırakabilirsin.',
                style: Theme.of(context).textTheme.displayLarge),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Sahneye çıkmadan önce Son Şans’taki yarışmacılardan yalnızca birine koçluk yap.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text('Doğru dokunuş performansını değiştirebilir.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.paperMuted,
                      fontStyle: FontStyle.italic,
                    )),
            const SizedBox(height: AppSpacing.lg),
            ...trio.map((contestant) => _CoachCard(
                  contestant: contestant,
                  selected: selectedId == contestant.id,
                  onTap: () => onSelect(contestant.id),
                )),
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              label: selectedId == null ? 'BİR KİŞİ SEÇ' : 'NOTUMU VER',
              onPressed: onConfirm,
            ),
          ],
        ),
      );
}

class _CoachCard extends StatelessWidget {
  const _CoachCard({
    required this.contestant,
    required this.selected,
    required this.onTap,
  });
  final Contestant contestant;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radar = GameScope.of(context).playerRadarContestantIds;
    final evaluation = evaluation1Results[contestant.id]!;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.inkSoft,
          border: Border.all(
            color: selected ? AppColors.accentBright : AppColors.line,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 96,
              height: 120,
              child: ContestantPortrait(contestant: contestant),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(contestant.displayName,
                      style: Theme.of(context).textTheme.headlineSmall),
                  Text('İLK DEĞERLENDİRME ${evaluation.overall}',
                      style: _pinkLabel(context)),
                  if (radar.contains(contestant.id))
                    Text('★ RADARINDA', style: _pinkLabel(context)),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '“Kendini tutma. Bu sahne senin son şansın.”',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontStyle: FontStyle.italic,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(selected ? '★ SAHNE NOTU SEÇİLDİ' : 'SAHNE NOTU VER',
                      style: _pinkLabel(context)),
                  if (selected)
                    Text(
                      radar.contains(contestant.id)
                          ? '★ Favorinin arkasında duruyorsun.'
                          : 'Bu kez ona güvenmeyi seçtin.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PerformanceReveal extends StatelessWidget {
  const _PerformanceReveal({
    required this.contestant,
    required this.result,
    required this.coached,
    required this.progress,
    required this.revealStep,
    required this.onNext,
  });
  final Contestant contestant;
  final LastChanceResult result;
  final bool coached;
  final int progress;
  final int revealStep;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    final radar = GameScope.of(context).playerRadarContestantIds;
    final showFinal = revealStep >= (coached ? 5 : 4);
    return _Page(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('SON ŞANS — $progress / 3', style: _pinkLabel(context)),
          const SizedBox(height: AppSpacing.md),
          AspectRatio(
            aspectRatio: 1.05,
            child: ContestantPortrait(contestant: contestant),
          ),
          const SizedBox(height: AppSpacing.md),
          Text('${contestant.displayName} — ${contestant.age}',
              style: Theme.of(context).textTheme.headlineLarge),
          if (radar.contains(contestant.id))
            Text('★ RADARINDA', style: _pinkLabel(context)),
          if (coached) Text('★ SAHNE NOTUNU ALDI', style: _pinkLabel(context)),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              _Score('VOKAL', result.vocal, revealStep >= 1),
              _Score('DANS', result.dance, revealStep >= 2),
              _Score('SAHNE', result.stage, revealStep >= 3),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('GENEL ${revealStep >= 4 ? result.baseOverall : '--'}',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: AppColors.accentBright,
                  )),
          if (coached && revealStep >= 5) ...[
            Text('★ SAHNE NOTU +4', style: _pinkLabel(context)),
            Text('${result.finalScore(coached: true)}',
                style: Theme.of(context).textTheme.displayLarge),
          ],
          AnimatedOpacity(
            opacity: showFinal ? 1 : 0,
            duration: const Duration(milliseconds: 220),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.md),
                Text(result.tag, style: _pinkLabel(context)),
                Text('“${result.comment}”',
                    style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppButton(
            label: progress == 3 ? 'KARARI GÖR' : 'SONRAKİ PERFORMANS',
            onPressed: onNext,
          ),
        ],
      ),
    );
  }
}

class _Score extends StatelessWidget {
  const _Score(this.label, this.value, this.revealed);
  final String label;
  final int value;
  final bool revealed;

  @override
  Widget build(BuildContext context) => Expanded(
        child: Column(
          children: [
            Text(label, style: Theme.of(context).textTheme.labelMedium),
            Text(revealed ? '$value' : '--',
                style: Theme.of(context).textTheme.headlineLarge),
          ],
        ),
      );
}

class _Comparison extends StatelessWidget {
  const _Comparison({required this.trio, required this.onNext});
  final List<Contestant> trio;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) => _Page(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('SON ŞANS TAMAMLANDI',
                style: Theme.of(context).textTheme.displayLarge),
            const SizedBox(height: AppSpacing.md),
            Text('Üç performans bitti.\nŞimdi yalnızca skorlar konuşuyor.',
                style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: AppSpacing.lg),
            ...trio.map((c) => Container(
                  margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.inkSoft,
                    border: Border.all(color: AppColors.line),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 90,
                        height: 110,
                        child: ContestantPortrait(contestant: c),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(c.displayName,
                            style: Theme.of(context).textTheme.headlineSmall),
                      ),
                      Text('--',
                          style: Theme.of(context).textTheme.headlineLarge),
                    ],
                  ),
                )),
            const SizedBox(height: AppSpacing.lg),
            AppButton(label: 'SONUÇLARI AÇ', onPressed: onNext),
          ],
        ),
      );
}

class _SafeReveal extends StatelessWidget {
  const _SafeReveal({
    required this.label,
    required this.contestant,
    required this.score,
    required this.onNext,
  });
  final String label;
  final Contestant contestant;
  final int score;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) => _Page(
        child: Column(
          children: [
            Text(label, style: _pinkLabel(context)),
            const SizedBox(height: AppSpacing.lg),
            AspectRatio(
              aspectRatio: 0.85,
              child: ContestantPortrait(contestant: contestant),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(contestant.displayName,
                style: Theme.of(context).textTheme.displayLarge),
            Text('$score', style: Theme.of(context).textTheme.headlineLarge),
            Text('GÜVENDE',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: AppColors.accentBright,
                    )),
            const SizedBox(height: AppSpacing.xl),
            AppButton(label: 'SON İKİYİ GÖR', onPressed: onNext),
          ],
        ),
      );
}

class _FinalTwo extends StatelessWidget {
  const _FinalTwo({
    required this.safeContestant,
    required this.eliminatedContestant,
    required this.safeScore,
    required this.onNext,
  });
  final Contestant safeContestant;
  final Contestant eliminatedContestant;
  final int safeScore;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) => _Page(
        child: Column(
          children: [
            Text('SON İKİ', style: Theme.of(context).textTheme.displayLarge),
            const SizedBox(height: AppSpacing.md),
            Text('Biriniz kalacak.\nBiriniz bu gece veda edecek.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: AspectRatio(
                    aspectRatio: 0.75,
                    child: ContestantPortrait(contestant: safeContestant),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: AspectRatio(
                    aspectRatio: 0.75,
                    child: ContestantPortrait(contestant: eliminatedContestant),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            Text('GÜVENDE', style: _pinkLabel(context)),
            Text(safeContestant.displayName,
                style: Theme.of(context).textTheme.headlineLarge),
            Text('$safeScore • Yıldız Kadro’da kalıyor.',
                style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: AppSpacing.xl),
            AppButton(label: 'İLK VEDAYI AÇ', onPressed: onNext),
          ],
        ),
      );
}

class _Farewell extends StatelessWidget {
  const _Farewell({
    required this.contestant,
    required this.score,
    required this.coachId,
    required this.onNext,
  });
  final Contestant contestant;
  final int score;
  final int coachId;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final state = GameScope.of(context);
    final onRadar = state.playerRadarContestantIds.contains(contestant.id);
    final otherRadarSurvived = state.lastChanceContestantIds.any(
      (id) =>
          id != contestant.id && state.playerRadarContestantIds.contains(id),
    );
    final radarFeedback = onRadar
        ? '★ İlk favorilerinden biri yarışmaya veda etti.'
        : otherRadarSurvived
            ? '★ Radarındaki isim tehlikeyi atlattı.'
            : 'Radarındaki isimler bu geceyi atlattı.';
    final coachedEliminated = coachId == contestant.id;
    final coachedName = _findContestant(coachId).name;
    return _Page(
      child: Column(
        children: [
          Text('İLK VEDA', style: _pinkLabel(context)),
          const SizedBox(height: AppSpacing.lg),
          ColorFiltered(
            colorFilter:
                const ColorFilter.mode(Colors.grey, BlendMode.saturation),
            child: AspectRatio(
              aspectRatio: 0.85,
              child: ContestantPortrait(contestant: contestant),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(contestant.displayName,
              style: Theme.of(context).textTheme.displayLarge),
          Text('Yıldız Kadro’ya veda ediyor.',
              style: Theme.of(context).textTheme.titleLarge),
          Text('SON ŞANS $score', style: _pinkLabel(context)),
          const SizedBox(height: AppSpacing.md),
          Text('“${farewellMessages[contestant.id]}”',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: AppSpacing.md),
          Text(radarFeedback,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.accentSoft,
                  )),
          const SizedBox(height: AppSpacing.lg),
          Text(
            coachedEliminated
                ? 'SONUNA KADAR DESTEKLEDİN\n+4 puan bile ${contestant.name}’i bu gece kurtarmaya yetmedi.'
                : 'SAHNE NOTUN İŞE YARADI\n$coachedName yarışmada kaldı.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: AppSpacing.xl),
          AppButton(label: 'KADROYA DÖN', onPressed: onNext),
        ],
      ),
    );
  }
}

Contestant _findContestant(int id) =>
    contestantSeedData.firstWhere((contestant) => contestant.id == id);

class _Page extends StatelessWidget {
  const _Page({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        child: MaxWidthContainer(
          maxWidth: 720,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  tooltip: 'Geri',
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
                const SizedBox(height: AppSpacing.sm),
                child,
              ],
            ),
          ),
        ),
      );
}

TextStyle? _pinkLabel(BuildContext context) =>
    Theme.of(context).textTheme.labelMedium?.copyWith(
          color: AppColors.accentSoft,
          letterSpacing: 0.9,
        );
