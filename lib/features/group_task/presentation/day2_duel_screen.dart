import 'package:flutter/material.dart';
import 'package:yildiz_kadro/app/theme/app_colors.dart';
import 'package:yildiz_kadro/app/theme/app_spacing.dart';
import 'package:yildiz_kadro/features/contestants/data/contestant_seed_data.dart';
import 'package:yildiz_kadro/features/contestants/domain/contestant.dart';
import 'package:yildiz_kadro/features/contestants/presentation/widgets/contestant_portrait.dart';
import 'package:yildiz_kadro/features/game/application/game_scope.dart';
import 'package:yildiz_kadro/features/group_task/data/day2_duel_engine.dart';
import 'package:yildiz_kadro/features/group_task/data/group_task_profiles.dart';
import 'package:yildiz_kadro/features/group_task/domain/day2_duel_result.dart';
import 'package:yildiz_kadro/features/group_task/domain/group_task_profile.dart';
import 'package:yildiz_kadro/features/group_task/presentation/day2_results_screen.dart';
import 'package:yildiz_kadro/shared/widgets/app_button.dart';
import 'package:yildiz_kadro/shared/widgets/max_width_container.dart';

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
  farewell
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
    if (pair.length != 2 ||
        pair.toSet().length != 2 ||
        pair.any(state.eliminatedContestantIds.contains) ||
        pair.contains(state.day2JurySavedContestantId) ||
        pair.contains(state.day2StarImmunityContestantId)) {
      throw StateError('Düello katılımcıları geçersiz.');
    }
    if (state.day2DuelCompleted) {
      _preview = state.day2DuelResultSnapshot;
      _phase = _Phase.winner;
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
    );
    state.completeDay2Duel(_preview!);
    setState(() => _phase = _Phase.performance);
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
                      'DÜELLO NEYİ ÖLÇECEK?',
                      'Aynı parça. Farklı vurgu.',
                      Day2DuelConcept.values
                          .map((v) => (
                                duelConceptLabel(v),
                                _conceptDescription(v),
                                _concept == v,
                                () => setState(() => _concept = v)
                              ))
                          .toList(),
                      _concept == null ? null : () => _go(_Phase.approach)),
                  _Phase.approach => _choicePage(
                      'NASIL BİR DÜELLO İSTİYORSUN?',
                      'Performansın tavrını belirle.',
                      Day2DuelApproach.values
                          .map((v) => (
                                duelApproachLabel(v),
                                v == Day2DuelApproach.clean
                                    ? 'Daha kontrollü, daha güvenli, daha az hata.'
                                    : 'Daha riskli, daha iddialı, daha unutulmaz.',
                                _approach == v,
                                () => setState(() => _approach = v)
                              ))
                          .toList(),
                      _approach == null ? null : () => _go(_Phase.coaching)),
                  _Phase.coaching => _choicePage(
                      'SON NOTUN NE?',
                      'İki yarışmacı da aynı yapımcı notunu alacak.',
                      Day2DuelCoaching.values
                          .map((v) => (
                                duelCoachingLabel(v),
                                _coachingDescription(v),
                                _coaching == v,
                                () => setState(() => _coaching = v)
                              ))
                          .toList(),
                      _coaching == null ? null : () => _go(_Phase.summary)),
                  _Phase.summary => _summary(ids),
                  _Phase.performance => _performance(),
                  _Phase.finalReveal => _finalReveal(ids),
                  _Phase.winner => _winner(),
                  _Phase.farewell => _farewell(),
                })));
  }

  Widget _intro(List<int> ids) => _Page(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('2. GÜN', style: _label(context)),
        Text('DÜELLO', style: _label(context)),
        Text('Aynı sahne. İki farklı yıldız.',
            style: Theme.of(context).textTheme.displayLarge),
        const SizedBox(height: AppSpacing.xl),
        _versus(ids),
        const SizedBox(height: AppSpacing.xl),
        Text(
            'Jüri birini kurtardı.\nŞimdi bu iki isimden yalnızca biri yarışmaya devam edecek.',
            style: Theme.of(context).textTheme.bodyLarge),
        Text('Bu kez performansın yönünü sen belirleyeceksin.',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(fontStyle: FontStyle.italic)),
        const SizedBox(height: AppSpacing.xl),
        AppButton(
            label: 'DÜELLOYU KUR  ★ →', onPressed: () => _go(_Phase.profiles)),
      ]));

  Widget _profiles(List<int> ids) {
    final state = GameScope.of(context);
    return _Page(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('DÜELLO PROFİLLERİ',
          style: Theme.of(context).textTheme.displayLarge),
      const SizedBox(height: AppSpacing.lg),
      ...ids.map((id) {
        final c = _contestant(id);
        final profile = groupTaskProfiles[id]!;
        final day2 = state.day2GroupPerformanceSnapshot!.individualResults[id]!;
        final jury = state.day2JuryResultSnapshot!.evaluations[id]!;
        return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                    color: AppColors.inkSoft,
                    border: Border.all(color: AppColors.line)),
                child: Row(children: [
                  SizedBox(
                      width: 105,
                      height: 138,
                      child: ContestantPortrait(contestant: c)),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Text('${c.displayName} — ${c.age}',
                            style: Theme.of(context).textTheme.titleLarge),
                        Text(_powerLabel(profile.primaryRole),
                            style: _label(context)),
                        Text(
                            '${day2.assignedRole}  •  ${_styleLabel(profile.workStyle)}',
                            style: Theme.of(context).textTheme.bodySmall),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                            'İLK ${state.evaluation1Results[id]!.overall}  •  2. GÜN ${day2.overall}  •  JÜRİ ${jury.juryScore}',
                            style: Theme.of(context).textTheme.bodyMedium),
                        if (state.playerRadarContestantIds.contains(id))
                          Text('★ RADARINDA', style: _label(context))
                      ]))
                ])));
      }),
      AppButton(label: 'İLK KARARI VER', onPressed: () => _go(_Phase.concept)),
    ]));
  }

  Widget _choicePage(
          String title,
          String subtitle,
          List<(String, String, bool, VoidCallback)> choices,
          VoidCallback? next) =>
      _Page(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: Theme.of(context).textTheme.displayLarge),
        Text(subtitle, style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: AppSpacing.xl),
        ...choices.map((choice) => Padding(
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
                            color: choice.$3
                                ? AppColors.accentBright
                                : AppColors.line)),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(choice.$1,
                              style: Theme.of(context).textTheme.headlineSmall),
                          const SizedBox(height: AppSpacing.xs),
                          Text(choice.$2,
                              style: Theme.of(context).textTheme.bodyLarge)
                        ]))))),
        AppButton(label: 'DEVAM ET  →', onPressed: next),
      ]));

  Widget _summary(List<int> ids) => _Page(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('DÜELLO HAZIR', style: Theme.of(context).textTheme.displayLarge),
        const SizedBox(height: AppSpacing.lg),
        _summaryLine('KONSEPT', duelConceptLabel(_concept!)),
        _summaryLine('YAKLAŞIM', duelApproachLabel(_approach!)),
        _summaryLine('SON NOT', duelCoachingLabel(_coaching!)),
        const SizedBox(height: AppSpacing.xl),
        _versus(ids),
        const SizedBox(height: AppSpacing.md),
        Center(
            child: Text('Aynı kararlar. İki farklı sonuç.',
                style: Theme.of(context).textTheme.bodyLarge)),
        const SizedBox(height: AppSpacing.xl),
        TextButton(
            onPressed: () => _go(_Phase.concept),
            child: const Text('DEĞİŞTİR')),
        AppButton(label: 'SAHNEYİ BAŞLAT  ★ →', onPressed: _calculate),
      ]));

  Widget _performance() {
    final id = _preview!.performanceOrderIds[_performanceIndex];
    final c = _contestant(id);
    final result = _preview!.results[id]!;
    return _Page(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('DÜELLO — ${_performanceIndex + 1} / 2', style: _label(context)),
      const SizedBox(height: AppSpacing.md),
      Center(
          child: SizedBox(
              width: 330,
              child: AspectRatio(
                  aspectRatio: .82, child: ContestantPortrait(contestant: c)))),
      const SizedBox(height: AppSpacing.lg),
      Text(c.displayName, style: Theme.of(context).textTheme.displayLarge),
      Text('${duelConceptLabel(_preview!.concept)} DÜELLO',
          style: _label(context)),
      const SizedBox(height: AppSpacing.lg),
      ...[
        ('VOKAL', result.vocal),
        ('DANS', result.dance),
        ('SAHNE', result.stage)
      ].asMap().entries.map((entry) => ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(entry.value.$1, style: _label(context)),
          trailing: Text(_revealCount > entry.key ? '${entry.value.$2}' : '--',
              style: Theme.of(context).textTheme.headlineSmall))),
      if (_revealCount == 3) ...[
        Text('“${_performanceNarrative(result)}”',
            style: Theme.of(context).textTheme.bodyLarge),
        Text(
            result.totalModifier >= 5
                ? '★ Bu düello formatı ona uydu.'
                : 'Bu format onun için kolay değildi.',
            style: _label(context))
      ],
      const SizedBox(height: AppSpacing.lg),
      AppButton(
          label: _revealCount < 3
              ? 'KATEGORİYİ AÇ'
              : _performanceIndex == 0
                  ? 'İKİNCİ PERFORMANS'
                  : 'SONUCA GEÇ',
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
          }),
    ]));
  }

  Widget _finalReveal(List<int> ids) => _Page(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('DÜELLO TAMAMLANDI',
            style: Theme.of(context).textTheme.displayLarge),
        Text('Aynı sahne.\nAynı kararlar.\nFarklı sonuçlar.',
            style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: AppSpacing.xl),
        _versus(ids),
        const SizedBox(height: AppSpacing.lg),
        ...ids.map((id) {
          final r = _preview!.results[id]!;
          return ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(_contestant(id).displayName),
              subtitle: Text(
                  'VOKAL ${r.vocal}  •  DANS ${r.dance}  •  SAHNE ${r.stage}'),
              trailing: const Text('--'));
        }),
        const SizedBox(height: AppSpacing.xl),
        AppButton(label: 'SONUCU AÇ  →', onPressed: () => _go(_Phase.winner)),
      ]));

  Widget _winner() {
    final state = GameScope.of(context);
    final id = _preview!.winnerContestantId;
    final c = _contestant(id);
    final result = _preview!.results[id]!;
    return _Page(
        child: Column(children: [
      Text('DÜELLOYU KAZANDI', style: _label(context)),
      const SizedBox(height: AppSpacing.lg),
      SizedBox(
          width: 340,
          child: AspectRatio(
              aspectRatio: .82, child: ContestantPortrait(contestant: c))),
      const SizedBox(height: AppSpacing.lg),
      Text(c.displayName, style: Theme.of(context).textTheme.displayLarge),
      Text('GÜVENDE',
          style: Theme.of(context)
              .textTheme
              .headlineLarge
              ?.copyWith(color: AppColors.accentBright)),
      Text("Yıldız Kadro'da kalıyor.",
          style: Theme.of(context).textTheme.bodyLarge),
      Text('DÜELLO PUANI ${result.finalScore}', style: _label(context)),
      if (result.totalModifier >= 5)
        Text('★ Seçtiğin düello formatı onun güçlü yanlarını ortaya çıkardı.',
            textAlign: TextAlign.center, style: _label(context)),
      if (state.playerRadarContestantIds.contains(id))
        Text('★ Radarındaki isim düelloyu kazandı.', style: _label(context)),
      const SizedBox(height: AppSpacing.xl),
      AppButton(label: 'VEDAYI GÖR', onPressed: () => _go(_Phase.farewell)),
    ]));
  }

  Widget _farewell() {
    final state = GameScope.of(context);
    final id = _preview!.eliminatedContestantId;
    final c = _contestant(id);
    final result = _preview!.results[id]!;
    final wasStar = id ==
            state.day2GroupPerformanceSnapshot!.teamAResult.starContestantId ||
        id == state.day2GroupPerformanceSnapshot!.teamBResult.starContestantId;
    return _Page(
        child: Column(children: [
      Text('2. VEDA', style: _label(context)),
      const SizedBox(height: AppSpacing.lg),
      SizedBox(
          width: 340,
          child: AspectRatio(
              aspectRatio: .82, child: ContestantPortrait(contestant: c))),
      const SizedBox(height: AppSpacing.lg),
      Text(c.displayName, style: Theme.of(context).textTheme.displayLarge),
      Text("Yıldız Kadro'ya veda ediyor.",
          style: Theme.of(context).textTheme.headlineSmall),
      Text('DÜELLO PUANI ${result.finalScore}', style: _label(context)),
      const SizedBox(height: AppSpacing.md),
      Text(
          wasStar
              ? '“Bir takım performansında yıldız olmuştu. Düello gecesi aynı hikâyeyi yazamadı.”'
              : '“${_farewellText(groupTaskProfiles[id]!.primaryRole)}”',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge),
      if (state.playerRadarContestantIds.contains(id))
        Text('★ İlk radarından bir isim daha yarışmaya veda etti.',
            style: _label(context)),
      if (id == state.day2CaptainAId || id == state.day2CaptainBId)
        Text('Onu bu sabah kaptan seçmiştin.',
            style: Theme.of(context).textTheme.bodySmall),
      const SizedBox(height: AppSpacing.xl),
      AppButton(
          label: '2. GÜN SONUÇLARI',
          onPressed: () => Navigator.of(context).pushReplacement(
              MaterialPageRoute<void>(
                  builder: (_) => const Day2ResultsScreen()))),
    ]));
  }

  Widget _versus(List<int> ids) {
    final radar = GameScope.of(context).playerRadarContestantIds;
    return Row(children: [
      Expanded(
          child: _PortraitCard(
              c: _contestant(ids.first), radar: radar.contains(ids.first))),
      Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Text('VS', style: _label(context))),
      Expanded(
          child: _PortraitCard(
              c: _contestant(ids.last), radar: radar.contains(ids.last)))
    ]);
  }

  Widget _summaryLine(String title, String value) => Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(children: [
        Expanded(child: Text(title, style: _label(context))),
        Text(value, style: Theme.of(context).textTheme.titleLarge)
      ]));
}

class _PortraitCard extends StatelessWidget {
  const _PortraitCard({required this.c, required this.radar});
  final Contestant c;
  final bool radar;
  @override
  Widget build(BuildContext context) => Column(children: [
        AspectRatio(aspectRatio: .72, child: ContestantPortrait(contestant: c)),
        const SizedBox(height: AppSpacing.xs),
        Text(c.displayName, style: Theme.of(context).textTheme.titleLarge),
        if (radar) Text('★ RADARINDA', style: _label(context))
      ]);
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
              child: child)));
}

TextStyle _label(BuildContext context) => Theme.of(context)
    .textTheme
    .labelLarge!
    .copyWith(color: AppColors.accentBright, letterSpacing: 1.2);
String _conceptDescription(Day2DuelConcept v) => switch (v) {
      Day2DuelConcept.vocal => 'Ses kontrolü, ton ve yorum ön planda.',
      Day2DuelConcept.dance => 'Hareket, ritim ve koreografi ön planda.',
      Day2DuelConcept.stage =>
        'Kamera hakimiyeti, ifade ve yıldız etkisi ön planda.'
    };
String _coachingDescription(Day2DuelCoaching v) => switch (v) {
      Day2DuelCoaching.technique =>
        'Hata kovalamak yerine bildiğin şeyi kusursuz yap.',
      Day2DuelCoaching.showYourself =>
        'Sahneyi yalnızca tamamlamaya değil, sahiplenmeye çık.',
      Day2DuelCoaching.tellStory =>
        'Puan değil, iz bırakan bir performans düşün.'
    };
String _powerLabel(GroupRole role) => switch (role) {
      GroupRole.vocal => 'SES GÜCÜ',
      GroupRole.dance => 'HAREKET GÜCÜ',
      GroupRole.stage => 'SAHNE GÜCÜ',
      GroupRole.allRounder => 'DENGE'
    };
String _styleLabel(WorkStyle s) => switch (s) {
      WorkStyle.cameraSavvy => 'KAMERA SEZGİSİ',
      WorkStyle.controlled => 'KONTROLLÜ',
      WorkStyle.bold => 'CESUR',
      WorkStyle.calm => 'SAKİN',
      WorkStyle.experienced => 'DENEYİMLİ',
      WorkStyle.spontaneous => 'SPONTANE',
      WorkStyle.instinctive => 'İÇGÜDÜSEL',
      WorkStyle.competitive => 'REKABETÇİ',
      WorkStyle.observant => 'GÖZLEMCİ',
      WorkStyle.direct => 'DOĞRUDAN',
      WorkStyle.sensitive => 'HASSAS',
      WorkStyle.protective => 'KORUYUCU',
      WorkStyle.chaotic => 'ÖNGÖRÜLEMEZ',
      WorkStyle.social => 'SOSYAL',
      WorkStyle.playful => 'OYUNCU'
    };
String _performanceNarrative(DuelContestantResult r) =>
    r.vocal >= r.dance && r.vocal >= r.stage
        ? 'Sesini merkeze koydu.'
        : r.dance >= r.stage
            ? 'Hareket tarafında kontrolü bırakmadı.'
            : 'Kamera ondan ayrılmadı.';
String _farewellText(GroupRole role) => switch (role) {
      GroupRole.vocal =>
        'Sesi yarışmada iz bıraktı. Bu kez düello onu tutamadı.',
      GroupRole.dance => 'Tekniği güçlüydü. Yolculuğu ikinci günde sona erdi.',
      GroupRole.stage =>
        'Sahne onu seviyordu. Yarışma bu gece başka bir karar verdi.',
      GroupRole.allRounder => 'Her alanda savaştı. Bu kez denge yeterli olmadı.'
    };
