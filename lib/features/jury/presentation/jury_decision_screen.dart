import 'dart:async';

import 'package:flutter/material.dart';
import 'package:yildiz_kadro/app/theme/app_colors.dart';
import 'package:yildiz_kadro/app/theme/app_spacing.dart';
import 'package:yildiz_kadro/features/contestants/data/contestant_seed_data.dart';
import 'package:yildiz_kadro/features/contestants/domain/contestant.dart';
import 'package:yildiz_kadro/features/contestants/presentation/widgets/contestant_portrait.dart';
import 'package:yildiz_kadro/features/evaluation/data/evaluation1_data.dart';
import 'package:yildiz_kadro/features/evaluation/domain/evaluation_result.dart';
import 'package:yildiz_kadro/features/game/application/game_scope.dart';
import 'package:yildiz_kadro/features/jury/data/jury_decision_data.dart';
import 'package:yildiz_kadro/features/last_chance/presentation/last_chance_performance_screen.dart';
import 'package:yildiz_kadro/shared/widgets/app_button.dart';
import 'package:yildiz_kadro/shared/widgets/max_width_container.dart';

enum _JuryPhase {
  intro,
  safe,
  risk,
  protect,
  producerReveal,
  juryReveal,
  summary,
}

class JuryDecisionScreen extends StatefulWidget {
  const JuryDecisionScreen({super.key});

  @override
  State<JuryDecisionScreen> createState() => _JuryDecisionScreenState();
}

class _JuryDecisionScreenState extends State<JuryDecisionScreen> {
  _JuryPhase _phase = _JuryPhase.intro;
  int? _selectedId;
  int _visibleRiskCount = 0;
  bool _juryRevealed = false;
  bool _submitting = false;
  final List<Timer> _timers = [];

  Map<int, EvaluationResult> get _results {
    final stored = GameScope.of(context).evaluation1Results;
    return stored.isEmpty ? evaluation1Results : stored;
  }

  List<int> get _riskIds {
    return juryRiskPriority
        .where(_results.containsKey)
        .take(5)
        .toList(growable: false);
  }

  Contestant _contestant(int id) =>
      contestantSeedData.firstWhere((contestant) => contestant.id == id);

  void _goTo(_JuryPhase phase) {
    setState(() => _phase = phase);
    if (phase == _JuryPhase.risk) {
      _visibleRiskCount = 0;
      for (var count = 1; count <= _riskIds.length; count++) {
        _timers.add(
          Timer(Duration(milliseconds: 300 * count), () {
            if (mounted && _phase == _JuryPhase.risk) {
              setState(() => _visibleRiskCount = count);
            }
          }),
        );
      }
    }
    if (phase == _JuryPhase.juryReveal) {
      _juryRevealed = false;
      _timers.add(
        Timer(const Duration(milliseconds: 1100), () {
          if (mounted && _phase == _JuryPhase.juryReveal) {
            setState(() => _juryRevealed = true);
          }
        }),
      );
    }
  }

  void _openProducerRight() {
    final state = GameScope.of(context);
    final canUseProducerRight = _phase == _JuryPhase.risk &&
        !state.juryDecision1Completed &&
        !_submitting &&
        _riskIds.length == 5;
    if (!canUseProducerRight) return;
    _goTo(_JuryPhase.protect);
  }

  Future<void> _askForConfirmation() async {
    final selectedId = _selectedId;
    if (selectedId == null || _submitting) return;
    final contestant = _contestant(selectedId);
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: AppColors.inkSoft,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.xl,
            AppSpacing.lg,
            AppSpacing.lg + MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${contestant.displayName}’Yİ KORUYORSUN',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                '${contestant.name} bu gece doğrudan güvende olacak.\nBu kararı daha sonra değiştiremezsin.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
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
                      child: const Text('EVET, KORU'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    if (confirmed == true && mounted) _commitDecision(selectedId);
  }

  void _commitDecision(int producerId) {
    if (_submitting || GameScope.of(context).juryDecision1Completed) return;
    _submitting = true;
    final remaining = _riskIds.where((id) => id != producerId).toList();
    remaining.sort((a, b) {
      final score = _results[b]!.overall.compareTo(_results[a]!.overall);
      if (score != 0) return score;
      return juryRiskPriority.indexOf(a).compareTo(juryRiskPriority.indexOf(b));
    });
    final juryId = remaining.first;
    final lastChance = _riskIds
        .where((id) => id != producerId && id != juryId)
        .toList(growable: false);
    GameScope.of(context).completeJuryDecision1(
      producerSaveContestantId: producerId,
      jurySaveContestantId: juryId,
      lastChanceContestantIds: lastChance,
    );
    _goTo(_JuryPhase.producerReveal);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (GameScope.of(context).juryDecision1Completed &&
        _phase == _JuryPhase.intro) {
      _phase = _JuryPhase.summary;
    }
  }

  @override
  void dispose() {
    for (final timer in _timers) {
      timer.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ink,
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 240),
          child: _buildPhase(context),
        ),
      ),
    );
  }

  Widget _buildPhase(BuildContext context) {
    switch (_phase) {
      case _JuryPhase.intro:
        return _Intro(onNext: () => _goTo(_JuryPhase.safe));
      case _JuryPhase.safe:
        final safeIds =
            _results.keys.where((id) => !_riskIds.contains(id)).toList()
              ..sort(
                (a, b) => _results[b]!.overall.compareTo(_results[a]!.overall),
              );
        return _SafeContestants(
          ids: safeIds,
          results: _results,
          contestant: _contestant,
          onNext: () => _goTo(_JuryPhase.risk),
        );
      case _JuryPhase.risk:
        final state = GameScope.of(context);
        final canUseProducerRight = !state.juryDecision1Completed &&
            !_submitting &&
            _riskIds.length == 5;
        return _RiskReveal(
          ids: _riskIds,
          visibleCount: _visibleRiskCount,
          results: _results,
          contestant: _contestant,
          onNext: canUseProducerRight ? _openProducerRight : null,
        );
      case _JuryPhase.protect:
        return _ProtectionSelection(
          ids: _riskIds,
          selectedId: _selectedId,
          results: _results,
          contestant: _contestant,
          onSelect: (id) => setState(() => _selectedId = id),
          onConfirm: _selectedId == null ? null : _askForConfirmation,
        );
      case _JuryPhase.producerReveal:
        return _ProducerReveal(
          contestant: _contestant(
            GameScope.of(context).producerSaveContestantId!,
          ),
          onNext: () => _goTo(_JuryPhase.juryReveal),
        );
      case _JuryPhase.juryReveal:
        return _JuryReveal(
          remainingIds: _riskIds
              .where(
                (id) => id != GameScope.of(context).producerSaveContestantId,
              )
              .toList(),
          jurySaveId: GameScope.of(context).jurySaveContestantId!,
          contestant: _contestant,
          revealed: _juryRevealed,
          onNext: _juryRevealed ? () => _goTo(_JuryPhase.summary) : null,
        );
      case _JuryPhase.summary:
        return _DecisionSummary(contestant: _contestant, results: _results);
    }
  }
}

class _Intro extends StatelessWidget {
  const _Intro({required this.onNext});
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) => _Page(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('1. GÜN', style: _pinkLabel(context)),
            const SizedBox(height: AppSpacing.sm),
            Text('JÜRİ KARARI',
                style: Theme.of(context).textTheme.displayLarge),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'Puanlar her şeyi söylemez.',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'İlk değerlendirme tamamlandı.\nŞimdi jüri masası konuşuyor.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: AppSpacing.xxl),
            Text(
              'En düşük 5 puanı alan yarışmacı risk bölgesinde.',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Ama bu gece bir karar sana ait.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.paperMuted,
                    fontStyle: FontStyle.italic,
                  ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            AppButton(label: 'RİSK BÖLGESİNİ GÖR', onPressed: onNext),
          ],
        ),
      );
}

class _SafeContestants extends StatelessWidget {
  const _SafeContestants({
    required this.ids,
    required this.results,
    required this.contestant,
    required this.onNext,
  });
  final List<int> ids;
  final Map<int, EvaluationResult> results;
  final Contestant Function(int) contestant;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    final tileHeight =
        150.0 + ((textScale - 1).clamp(0.0, 1.0) * 70).toDouble();
    return _Page(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('GÜVENDE', style: Theme.of(context).textTheme.displayLarge),
          const SizedBox(height: AppSpacing.md),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: ids.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisExtent: tileHeight,
              crossAxisSpacing: AppSpacing.sm,
              mainAxisSpacing: AppSpacing.sm,
            ),
            itemBuilder: (context, index) => _CompactCard(
              contestant: contestant(ids[index]),
              score: results[ids[index]]!.overall,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          AppButton(label: 'JÜRİNİN KARŞISINA ÇIK', onPressed: onNext),
        ],
      ),
    );
  }
}

class _RiskReveal extends StatelessWidget {
  const _RiskReveal({
    required this.ids,
    required this.visibleCount,
    required this.results,
    required this.contestant,
    required this.onNext,
  });
  final List<int> ids;
  final int visibleCount;
  final Map<int, EvaluationResult> results;
  final Contestant Function(int) contestant;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) => _Page(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('RİSK BÖLGESİ',
                style: Theme.of(context).textTheme.displayLarge),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Bu 5 yarışmacı ilk değerlendirmede gecenin en düşük puanlarını aldı.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: AppSpacing.lg),
            ...ids.asMap().entries.map(
                  (entry) => AnimatedOpacity(
                    opacity: entry.key < visibleCount ? 1 : 0,
                    duration: const Duration(milliseconds: 250),
                    child: _RiskCard(
                      contestant: contestant(entry.value),
                      result: results[entry.value]!,
                    ),
                  ),
                ),
            const SizedBox(height: AppSpacing.lg),
            AppButton(label: 'YAPIMCI HAKKINI KULLAN', onPressed: onNext),
          ],
        ),
      );
}

class _ProtectionSelection extends StatelessWidget {
  const _ProtectionSelection({
    required this.ids,
    required this.selectedId,
    required this.results,
    required this.contestant,
    required this.onSelect,
    required this.onConfirm,
  });
  final List<int> ids;
  final int? selectedId;
  final Map<int, EvaluationResult> results;
  final Contestant Function(int) contestant;
  final ValueChanged<int> onSelect;
  final VoidCallback? onConfirm;

  @override
  Widget build(BuildContext context) {
    final radar = GameScope.of(context).playerRadarContestantIds;
    return _Page(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('YAPIMCI HAKKI', style: _pinkLabel(context)),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Bir kişiyi koruyabilirsin.',
            style: Theme.of(context).textTheme.displayLarge,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Risk bölgesindeki 5 yarışmacıdan birini doğrudan güvene al.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Bu karar geri alınamaz.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.paperMuted,
                  fontStyle: FontStyle.italic,
                ),
          ),
          const SizedBox(height: AppSpacing.lg),
          ...ids.map(
            (id) => _ProtectionCard(
              contestant: contestant(id),
              result: results[id]!,
              selected: selectedId == id,
              onTap: () => onSelect(id),
              narrative: radar.contains(id)
                  ? '★ İlk seçiminin arkasında duruyorsun.'
                  : 'Yeni bir şans veriyorsun.',
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppButton(
            label: selectedId == null ? 'BİR KİŞİ SEÇ' : 'KARARIM BU',
            onPressed: onConfirm,
          ),
        ],
      ),
    );
  }
}

class _ProducerReveal extends StatelessWidget {
  const _ProducerReveal({required this.contestant, required this.onNext});
  final Contestant contestant;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) => _PortraitReveal(
        label: 'YAPIMCI KARARI',
        contestant: contestant,
        title: 'GÜVENDE',
        caption: '★ Yapımcı Koruması\nBu gece Son Şans’a çıkmayacak.',
        button: 'JÜRİ KARARINI AÇIKLASIN',
        onNext: onNext,
      );
}

class _JuryReveal extends StatelessWidget {
  const _JuryReveal({
    required this.remainingIds,
    required this.jurySaveId,
    required this.contestant,
    required this.revealed,
    required this.onNext,
  });
  final List<int> remainingIds;
  final int jurySaveId;
  final Contestant Function(int) contestant;
  final bool revealed;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) => _Page(
        child: Column(
          children: [
            Text(
              'JÜRİ BİR KİŞİYİ DAHA KURTARACAK',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: remainingIds
                  .map(
                    (id) => Expanded(
                      child: AnimatedOpacity(
                        opacity: !revealed || id == jurySaveId ? 1 : 0.2,
                        duration: const Duration(milliseconds: 350),
                        child: Padding(
                          padding: const EdgeInsets.all(3),
                          child: AspectRatio(
                            aspectRatio: 0.72,
                            child:
                                ContestantPortrait(contestant: contestant(id)),
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: AppSpacing.xl),
            AnimatedOpacity(
              opacity: revealed ? 1 : 0,
              duration: const Duration(milliseconds: 300),
              child: Column(
                children: [
                  Text('JÜRİ KARARI', style: _pinkLabel(context)),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    contestant(jurySaveId).displayName,
                    style: Theme.of(context).textTheme.displayLarge,
                  ),
                  Text(
                    'GÜVENDE',
                    style: Theme.of(context)
                        .textTheme
                        .headlineLarge
                        ?.copyWith(color: AppColors.accentBright),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    '“Bir performans daha görmek istiyoruz. Ama bunu Son Şans’ta yapmak zorunda değilsin.”',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            AppButton(label: 'SON ŞANS’I GÖR', onPressed: onNext),
          ],
        ),
      );
}

class _DecisionSummary extends StatelessWidget {
  const _DecisionSummary({required this.contestant, required this.results});
  final Contestant Function(int) contestant;
  final Map<int, EvaluationResult> results;

  @override
  Widget build(BuildContext context) {
    final state = GameScope.of(context);
    final lastChance = state.lastChanceContestantIds;
    final radarCount =
        lastChance.where(state.playerRadarContestantIds.contains).length;
    final feedback = radarCount == 0
        ? 'İlk favorilerin şimdilik güvende.'
        : radarCount == 1
            ? '★ Radarındaki bir isim tehlikede.'
            : '★ Radarındaki $radarCount yarışmacı tehlikede.';
    return _Page(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('SON ŞANS', style: _pinkLabel(context)),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Üç kişi kaldı.',
            style: Theme.of(context).textTheme.displayLarge,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Bir sonraki performans, yarışmadaki ilk vedayı belirleyecek.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: AppSpacing.lg),
          ...lastChance.map(
            (id) => _LastChanceCard(
              contestant: contestant(id),
              score: results[id]!.overall,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            feedback,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(color: AppColors.accentSoft),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text('BU GECE', style: _pinkLabel(context)),
          const SizedBox(height: AppSpacing.md),
          _DecisionLine(
            label: 'SEN KORUDUN',
            contestant: contestant(state.producerSaveContestantId!),
          ),
          _DecisionLine(
            label: 'JÜRİ KURTARDI',
            contestant: contestant(state.jurySaveContestantId!),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppButton(
            label: 'SON ŞANS SAHNESİNE GEÇ',
            onPressed: state.juryDecision1Completed &&
                    state.lastChanceContestantIds.length == 3 &&
                    state.producerSaveContestantId != null &&
                    state.jurySaveContestantId != null
                ? () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const LastChancePerformanceScreen(),
                      ),
                    )
                : null,
          ),
        ],
      ),
    );
  }
}

class _RiskCard extends StatelessWidget {
  const _RiskCard({required this.contestant, required this.result});
  final Contestant contestant;
  final EvaluationResult result;

  @override
  Widget build(BuildContext context) {
    final jury = juryComments[contestant.id]!;
    final onRadar =
        GameScope.of(context).playerRadarContestantIds.contains(contestant.id);
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.inkSoft,
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 112,
            height: 150,
            child: ContestantPortrait(contestant: contestant),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contestant.displayName,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                Text(
                  '${contestant.age} • ${contestant.archetype.toUpperCase()}',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                if (onRadar)
                  Text('★ SENİN RADARINDA', style: _pinkLabel(context)),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'VOKAL ${result.vocal}  •  DANS ${result.dance}\nSAHNE ${result.stage}  •  GENEL ${result.overall}',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '“${result.comment}”',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(fontStyle: FontStyle.italic),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(jury.label, style: _pinkLabel(context)),
                Text(
                  '“${jury.comment}”',
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProtectionCard extends StatelessWidget {
  const _ProtectionCard({
    required this.contestant,
    required this.result,
    required this.selected,
    required this.onTap,
    required this.narrative,
  });
  final Contestant contestant;
  final EvaluationResult result;
  final bool selected;
  final VoidCallback onTap;
  final String narrative;

  @override
  Widget build(BuildContext context) => GestureDetector(
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
                width: 92,
                height: 116,
                child: ContestantPortrait(contestant: contestant),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      contestant.displayName,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    Text(
                      'GENEL ${result.overall}',
                      style: Theme.of(context)
                          .textTheme
                          .labelLarge
                          ?.copyWith(color: AppColors.accentBright),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '“${juryComments[contestant.id]!.comment}”',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      selected ? '★ KORUMAYA ALINDI' : 'KORU',
                      style: _pinkLabel(context),
                    ),
                    if (selected)
                      Text(
                        narrative,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(fontStyle: FontStyle.italic),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}

class _LastChanceCard extends StatelessWidget {
  const _LastChanceCard({required this.contestant, required this.score});
  final Contestant contestant;
  final int score;

  @override
  Widget build(BuildContext context) {
    final onRadar =
        GameScope.of(context).playerRadarContestantIds.contains(contestant.id);
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.inkSoft,
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.65)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 104,
            height: 130,
            child: ContestantPortrait(contestant: contestant),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contestant.displayName,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                Text(
                  '${contestant.age} • GENEL $score',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                if (onRadar) Text('★ RADARINDA', style: _pinkLabel(context)),
                const SizedBox(height: AppSpacing.sm),
                Text('SON ŞANS', style: _pinkLabel(context)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CompactCard extends StatelessWidget {
  const _CompactCard({required this.contestant, required this.score});
  final Contestant contestant;
  final int score;

  @override
  Widget build(BuildContext context) {
    final onRadar =
        GameScope.of(context).playerRadarContestantIds.contains(contestant.id);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.inkSoft,
        border: Border.all(color: AppColors.line),
      ),
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Row(
          children: [
            SizedBox(
              width: 74,
              child: ContestantPortrait(contestant: contestant),
            ),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    contestant.displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  Text(
                    '$score',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(color: AppColors.accentBright),
                  ),
                  if (onRadar)
                    Text(
                      '★ RADARINDA',
                      maxLines: 1,
                      style: _pinkLabel(context),
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

class _PortraitReveal extends StatelessWidget {
  const _PortraitReveal({
    required this.label,
    required this.contestant,
    required this.title,
    required this.caption,
    required this.button,
    required this.onNext,
  });
  final String label;
  final Contestant contestant;
  final String title;
  final String caption;
  final String button;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) => _Page(
        child: Column(
          children: [
            Text(label, style: _pinkLabel(context)),
            const SizedBox(height: AppSpacing.lg),
            AspectRatio(
              aspectRatio: 0.86,
              child: ContestantPortrait(contestant: contestant),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              contestant.displayName,
              style: Theme.of(context).textTheme.displayLarge,
            ),
            Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .headlineLarge
                  ?.copyWith(color: AppColors.accentBright),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              caption,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: AppSpacing.xl),
            AppButton(label: button, onPressed: onNext),
          ],
        ),
      );
}

class _DecisionLine extends StatelessWidget {
  const _DecisionLine({required this.label, required this.contestant});
  final String label;
  final Contestant contestant;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: Row(
          children: [
            SizedBox(
              width: 58,
              height: 70,
              child: ContestantPortrait(contestant: contestant),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: _pinkLabel(context)),
                  Text(
                    contestant.displayName,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}

class _Page extends StatelessWidget {
  const _Page({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        key: const ValueKey('jury-page'),
        child: MaxWidthContainer(
          maxWidth: 760,
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

TextStyle? _pinkLabel(BuildContext context) => Theme.of(context)
    .textTheme
    .labelMedium
    ?.copyWith(color: AppColors.accentSoft, letterSpacing: 0.9);
