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
      builder: (context) {
        final isEn = isAppEnglish(context);
        return SafeArea(
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
                  isEn
                      ? 'PROTECTING ${contestant.displayName}'
                      : '${contestant.displayName}’Yİ KORUYORSUN',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  isEn
                      ? '${contestant.name} will be directly safe tonight.\nYou cannot change this decision later.'
                      : '${contestant.name} bu gece doğrudan güvende olacak.\nBu kararı daha sonra değiştiremezsin.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: Text(isEn ? 'CANCEL' : 'GERİ DÖN'),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
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
  Widget build(BuildContext context) {
    final isEn = isAppEnglish(context);
    return _Page(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.l10n.dayLabel(1), style: _pinkLabel(context)),
          const SizedBox(height: AppSpacing.sm),
          Text(
            context.l10n.juryDecisionTitle,
            style: Theme.of(context).textTheme.displayLarge,
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            context.l10n.scoresDontSayAll,
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            isEn
                ? 'First evaluation is complete.\nNow the jury panel speaks.'
                : 'İlk değerlendirme tamamlandı.\nŞimdi jüri masası konuşuyor.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: AppSpacing.xxl),
          Text(
            isEn
                ? 'The 5 contestants with the lowest scores are placed in the risk zone.'
                : 'En düşük 5 puanı alan yarışmacı risk bölgesinde.',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            isEn
                ? 'But tonight, one decision belongs to you.'
                : 'Ama bu gece bir karar sana ait.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.paperMuted,
                  fontStyle: FontStyle.italic,
                ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          AppButton(
            label: isEn ? 'VIEW RISK ZONE' : 'RİSK BÖLGESİNİ GÖR',
            onPressed: onNext,
          ),
        ],
      ),
    );
  }
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
    final isEn = isAppEnglish(context);
    return _Page(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isEn ? 'SAFE' : 'GÜVENDE',
            style: Theme.of(context).textTheme.displayLarge,
          ),
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
          AppButton(
            label: isEn ? 'FACE THE JURY' : 'JÜRİNİN KARŞISINA ÇIK',
            onPressed: onNext,
          ),
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
  Widget build(BuildContext context) {
    final isEn = isAppEnglish(context);
    return _Page(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.riskZone,
            style: Theme.of(context).textTheme.displayLarge,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            isEn
                ? 'These 5 contestants received the lowest scores of the night in the first evaluation.'
                : 'Bu 5 yarışmacı ilk değerlendirmede gecenin en düşük puanlarını aldı.',
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
          AppButton(
            label: isEn ? 'USE PRODUCER PRIVILEGE' : 'YAPIMCI HAKKINI KULLAN',
            onPressed: onNext,
          ),
        ],
      ),
    );
  }
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
    final isEn = isAppEnglish(context);
    return _Page(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isEn ? 'PRODUCER PRIVILEGE' : 'YAPIMCI HAKKI',
            style: _pinkLabel(context),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            isEn
                ? 'You can save one contestant.'
                : 'Bir kişiyi koruyabilirsin.',
            style: Theme.of(context).textTheme.displayLarge,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            isEn
                ? 'Directly save one of the 5 contestants in the risk zone.'
                : 'Risk bölgesindeki 5 yarışmacıdan birini doğrudan güvene al.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            isEn
                ? 'This decision cannot be undone.'
                : 'Bu karar geri alınamaz.',
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
                  ? (isEn
                      ? '★ Standing by your first impression.'
                      : '★ İlk seçiminin arkasında duruyorsun.')
                  : (isEn
                      ? 'Offering a second chance.'
                      : 'Yeni bir şans veriyorsun.'),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppButton(
            label: selectedId == null
                ? (isEn ? 'SELECT ONE PERSON' : 'BİR KİŞİ SEÇ')
                : (isEn ? 'CONFIRM DECISION' : 'KARARIM BU'),
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
  Widget build(BuildContext context) {
    final isEn = isAppEnglish(context);
    return _PortraitReveal(
      label: isEn ? 'PRODUCER DECISION' : 'YAPIMCI KARARI',
      contestant: contestant,
      title: isEn ? 'SAFE' : 'GÜVENDE',
      caption: isEn
          ? '★ Producer Protection\nWill not face Last Chance tonight.'
          : '★ Yapımcı Koruması\nBu gece Son Şans’a çıkmayacak.',
      button: isEn ? 'HEAR JURY DECISION' : 'JÜRİ KARARINI AÇIKLASIN',
      onNext: onNext,
    );
  }
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
  Widget build(BuildContext context) {
    final isEn = isAppEnglish(context);
    return _Page(
      child: Column(
        children: [
          Text(
            isEn
                ? 'THE JURY WILL SAVE ONE MORE'
                : 'JÜRİ BİR KİŞİYİ DAHA KURTARACAK',
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
                          child: ContestantPortrait(contestant: contestant(id)),
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
                Text(
                  isEn ? 'JURY DECISION' : 'JÜRİ KARARI',
                  style: _pinkLabel(context),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  contestant(jurySaveId).displayName,
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
                      ? '“We want to see one more performance. But you do not have to fight for it in Last Chance.”'
                      : '“Bir performans daha görmek istiyoruz. Ama bunu Son Şans’ta yapmak zorunda değilsin.”',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          AppButton(
            label: isEn ? 'VIEW LAST CHANCE' : 'SON ŞANS’I GÖR',
            onPressed: onNext,
          ),
        ],
      ),
    );
  }
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
    final isEn = isAppEnglish(context);
    final feedback = !isEn
        ? (radarCount == 0
            ? 'İlk favorilerin şimdilik güvende.'
            : radarCount == 1
                ? '★ Radarındaki bir isim tehlikede.'
                : '★ Radarındaki $radarCount yarışmacı tehlikede.')
        : (radarCount == 0
            ? 'Your initial favorites are safe for now.'
            : radarCount == 1
                ? '★ One name on your radar is in danger.'
                : '★ $radarCount names on your radar are in danger.');
    return _Page(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(isEn ? 'LAST CHANCE' : 'SON ŞANS', style: _pinkLabel(context)),
          const SizedBox(height: AppSpacing.sm),
          Text(
            isEn ? 'Three remain.' : 'Üç kişi kaldı.',
            style: Theme.of(context).textTheme.displayLarge,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            isEn
                ? 'The upcoming performance will decide the season\'s first farewell.'
                : 'Bir sonraki performans, yarışmadaki ilk vedayı belirleyecek.',
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
          Text(isEn ? 'TONIGHT' : 'BU GECE', style: _pinkLabel(context)),
          const SizedBox(height: AppSpacing.md),
          _DecisionLine(
            label: isEn ? 'YOU SAVED' : 'SEN KORUDUN',
            contestant: contestant(state.producerSaveContestantId!),
          ),
          _DecisionLine(
            label: isEn ? 'JURY SAVED' : 'JÜRİ KURTARDI',
            contestant: contestant(state.jurySaveContestantId!),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppButton(
            label: isEn ? 'ENTER LAST CHANCE STAGE' : 'SON ŞANS SAHNESİNE GEÇ',
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
    final isEn = isAppEnglish(context);
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
                  '${contestant.age} • ${contestant.localizedArchetype(context).toUpperCase()}',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                if (onRadar)
                  Text(
                    isEn ? '★ ON YOUR RADAR' : '★ SENİN RADARINDA',
                    style: _pinkLabel(context),
                  ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${context.l10n.vocal.toUpperCase()} ${result.vocal}  •  ${context.l10n.dance.toUpperCase()} ${result.dance}\n${context.l10n.stage.toUpperCase()} ${result.stage}  •  ${isEn ? "OVERALL" : "GENEL"} ${result.overall}',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '“${result.localizedComment(context)}”',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(fontStyle: FontStyle.italic),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  localizedJuryLabel(contestant.id, context),
                  style: _pinkLabel(context),
                ),
                Text(
                  '“${localizedJuryComment(contestant.id, context)}”',
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
                child: Builder(
                  builder: (context) {
                    final isEn = isAppEnglish(context);
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          contestant.displayName,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        Text(
                          '${isEn ? "OVERALL" : "GENEL"} ${result.overall}',
                          style: Theme.of(context)
                              .textTheme
                              .labelLarge
                              ?.copyWith(color: AppColors.accentBright),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          '“${localizedJuryComment(contestant.id, context)}”',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          selected
                              ? (isEn ? '★ PROTECTED' : '★ KORUMAYA ALINDI')
                              : (isEn ? 'PROTECT' : 'KORU'),
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
                    );
                  },
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
    final isEn = isAppEnglish(context);
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
                  '${contestant.age} • ${isEn ? "OVERALL" : "GENEL"} $score',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                if (onRadar)
                  Text(
                    isEn
                        ? '★ ON RADAR'
                        : isAppEnglish(context)
                            ? '★ ON RADAR'
                            : '★ RADARINDA',
                    style: _pinkLabel(context),
                  ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  isEn ? 'LAST CHANCE' : 'SON ŞANS',
                  style: _pinkLabel(context),
                ),
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
                      isAppEnglish(context) ? '★ ON RADAR' : '★ RADARINDA',
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
                  tooltip: context.l10n.back,
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
