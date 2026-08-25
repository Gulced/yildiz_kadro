import 'package:flutter/material.dart';
import 'package:yildiz_kadro/app/theme/app_colors.dart';
import 'package:yildiz_kadro/app/theme/app_spacing.dart';
import 'package:yildiz_kadro/features/contestants/data/contestant_seed_data.dart';
import 'package:yildiz_kadro/features/contestants/domain/contestant.dart';
import 'package:yildiz_kadro/features/contestants/presentation/widgets/contestant_portrait.dart';
import 'package:yildiz_kadro/features/game/application/game_scope.dart';
import 'package:yildiz_kadro/features/group_task/data/day3_identity_engine.dart';
import 'package:yildiz_kadro/features/group_task/data/group_task_profiles.dart';
import 'package:yildiz_kadro/features/group_task/domain/day3_identity_setup.dart';
import 'package:yildiz_kadro/features/group_task/domain/group_task_profile.dart';
import 'package:yildiz_kadro/features/group_task/presentation/day3_icon_performance_screen.dart';
import 'package:yildiz_kadro/shared/widgets/app_button.dart';
import 'package:yildiz_kadro/shared/widgets/max_width_container.dart';

enum _Phase { intro, task, reveal, worlds, director, select, plan, ready }

class Day3BriefingScreen extends StatefulWidget {
  const Day3BriefingScreen({super.key});
  @override
  State<Day3BriefingScreen> createState() => _Day3BriefingScreenState();
}

class _Day3BriefingScreenState extends State<Day3BriefingScreen> {
  _Phase _phase = _Phase.intro;
  int _revealIndex = 0;
  final Map<int, Day3CreativeDirection> _directions = {};
  Contestant _contestant(int id) =>
      contestantSeedData.firstWhere((c) => c.id == id);
  List<int> _activeIds(BuildContext context) {
    final eliminated = GameScope.of(context).eliminatedContestantIds;
    return contestantSeedData
        .where((c) => !eliminated.contains(c.id))
        .map((c) => c.id)
        .toList();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final state = GameScope.of(context);
    if (state.day3IdentityAllocation == null) {
      final ids = _activeIds(context);
      state.initializeDay3Identity(allocateDay3Concepts(
          activeContestantIds: ids,
          evaluationResults: state.evaluation1Results,
          day2Scores: {
            for (final id in ids)
              id: state.day2GroupPerformanceSnapshot!.individualResults[id]
                      ?.rawOverall ??
                  0
          }));
    }
    if (state.day3IdentitySetupCompleted) {
      _directions.addAll(
          state.day3IdentitySetupSnapshot!.creativeDirectionByContestantId);
      _phase = _Phase.ready;
    }
  }

  void _go(_Phase p) => setState(() => _phase = p);
  Future<void> _direct(int id) async {
    final selected = await showModalBottomSheet<Day3CreativeDirection>(
        context: context,
        backgroundColor: AppColors.inkSoft,
        builder: (context) => SafeArea(
            child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${_contestant(id).displayName} İÇİN YÖNÜN NE?',
                          style: Theme.of(context).textTheme.headlineSmall),
                      const SizedBox(height: AppSpacing.md),
                      ...Day3CreativeDirection.values.map((direction) =>
                          ListTile(
                              onTap: () => Navigator.pop(context, direction),
                              title: Text(day3DirectionLabel(direction)),
                              subtitle: Text(_directionDescription(direction))))
                    ]))));
    if (selected != null && mounted) {
      setState(() {
        if (_directions.length < 3 || _directions.containsKey(id)) {
          _directions[id] = selected;
        }
      });
    }
  }

  Future<void> _confirm() async {
    final ok = await showModalBottomSheet<bool>(
        context: context,
        backgroundColor: AppColors.inkSoft,
        builder: (context) => SafeArea(
            child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Text('YARATICI PLAN HAZIR',
                      style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: AppSpacing.md),
                  const Text(
                      'Bu üç yarışmacının kamera görevine doğrudan müdahale edeceksin.\nDiğer 10 yarışmacı kendi yaratıcı kararlarıyla ilerleyecek.'),
                  const SizedBox(height: AppSpacing.lg),
                  Row(children: [
                    Expanded(
                        child: TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('DEĞİŞTİR'))),
                    Expanded(
                        child: FilledButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('SETE GÖNDER')))
                  ])
                ]))));
    if (ok == true && mounted) {
      final state = GameScope.of(context);
      state.completeDay3IdentitySetup(createDay3IdentitySetup(
          allocation: state.day3IdentityAllocation!,
          directions: _directions,
          evaluationResults: state.evaluation1Results));
      _go(_Phase.ready);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ids = _activeIds(context);
    return Scaffold(
        backgroundColor: AppColors.ink,
        body: SafeArea(
            child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                child: switch (_phase) {
                  _Phase.intro => _intro(ids),
                  _Phase.task => _task(),
                  _Phase.reveal => _reveal(ids),
                  _Phase.worlds => _worlds(ids),
                  _Phase.director => _director(),
                  _Phase.select => _select(ids),
                  _Phase.plan => _plan(),
                  _Phase.ready => _ready(ids)
                })));
  }

  Widget _intro(List<int> ids) => _Page(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('3. GÜN', style: _label(context)),
        Text('YILDIZ KİMLİĞİ', style: Theme.of(context).textTheme.displayLarge),
        const SizedBox(height: AppSpacing.xl),
        Text('Bu kez takım yok.',
            style: Theme.of(context).textTheme.headlineLarge),
        Text(
            '13 yarışmacı.\n13 farklı yüz.\nAma hangisinin gerçekten bir yıldız kimliği var?',
            style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: AppSpacing.md),
        Text(
            'Bugün yarışmacılar kendi konseptlerini yaratacak. Stil, kamera ve sahne kişiliği ilk kez performans kadar önemli.',
            style: Theme.of(context).textTheme.bodyLarge),
        Text('İyi olmak yetmez. Hatırlanmak gerekir.',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(fontStyle: FontStyle.italic)),
        const SizedBox(height: AppSpacing.xl),
        _grid(ids, compact: true),
        const SizedBox(height: AppSpacing.xl),
        AppButton(label: 'GÖREVİ AÇ  ★ →', onPressed: () => _go(_Phase.task))
      ]));
  Widget _task() => _Page(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('KENDİ YILDIZINI YARAT',
            style: Theme.of(context).textTheme.displayLarge),
        Text('Her yarışmacı beş yaratıcı dünyadan birine yönelecek.',
            style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: AppSpacing.xl),
        ...Day3Concept.values.map((c) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(day3ConceptLabel(c), style: _label(context)),
              Text(_conceptDescription(c),
                  style: Theme.of(context).textTheme.headlineSmall),
              const Divider(color: AppColors.line)
            ]))),
        AppButton(label: 'KONSEPTLERİ AÇ', onPressed: () => _go(_Phase.reveal))
      ]));
  Widget _reveal(List<int> ids) {
    final id = ids[_revealIndex];
    final allocation = GameScope.of(context).day3IdentityAllocation!;
    final concept = allocation.conceptByContestantId[id]!;
    return _Page(
        child: Column(children: [
      Text('KONSEPTLER SEÇİLİYOR', style: _label(context)),
      Text('${_revealIndex + 1} / 13',
          style: Theme.of(context).textTheme.titleLarge),
      const SizedBox(height: AppSpacing.lg),
      SizedBox(
          width: 350,
          child: AspectRatio(
              aspectRatio: .82,
              child: ContestantPortrait(contestant: _contestant(id)))),
      const SizedBox(height: AppSpacing.lg),
      Text(_contestant(id).displayName,
          style: Theme.of(context).textTheme.displayLarge),
      Text(day3ConceptLabel(concept),
          style: Theme.of(context)
              .textTheme
              .headlineLarge
              ?.copyWith(color: AppColors.accentBright)),
      Text(day3FitLabel(allocation.conceptFitByContestantId[id]!),
          style: _label(context)),
      Text('“${_conceptReaction(concept)}”',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge),
      const SizedBox(height: AppSpacing.xl),
      AppButton(
          label:
              _revealIndex < 12 ? 'SONRAKİ KONSEPT' : 'YILDIZ DÜNYALARINI GÖR',
          onPressed: () {
            if (_revealIndex < 12) {
              setState(() => _revealIndex++);
            } else {
              _go(_Phase.worlds);
            }
          })
    ]));
  }

  Widget _worlds(List<int> ids) {
    final allocation = GameScope.of(context).day3IdentityAllocation!;
    return _Page(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('YILDIZ DÜNYALARI HAZIR',
          style: Theme.of(context).textTheme.displayLarge),
      const SizedBox(height: AppSpacing.xl),
      ...Day3Concept.values.map((concept) {
        final members = ids
            .where((id) => allocation.conceptByContestantId[id] == concept)
            .toList();
        return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.lg),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(day3ConceptLabel(concept), style: _label(context)),
              const SizedBox(height: AppSpacing.xs),
              Row(
                  children: members
                      .map((id) => Expanded(
                          child: Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: Column(children: [
                                AspectRatio(
                                    aspectRatio: .72,
                                    child: ContestantPortrait(
                                        contestant: _contestant(id))),
                                Text(_contestant(id).displayName, maxLines: 1)
                              ]))))
                      .toList())
            ]));
      }),
      AppButton(
          label: 'YARATICI YÖNETMEN MODU',
          onPressed: () => _go(_Phase.director))
    ]));
  }

  Widget _director() => _Page(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('YARATICI YÖNETMEN', style: _label(context)),
        Text('Her sete yetişemezsin.',
            style: Theme.of(context).textTheme.displayLarge),
        const SizedBox(height: AppSpacing.md),
        Text(
            'Bugün yalnızca 3 yarışmacının yaratıcı sürecine doğrudan müdahale edebilirsin.',
            style: Theme.of(context).textTheme.headlineSmall),
        Text('Kimi yönlendireceğin kadar, nasıl yönlendireceğin de önemli.',
            style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: AppSpacing.xl),
        AppButton(label: '3 İSMİ SEÇ', onPressed: () => _go(_Phase.select))
      ]));
  Widget _select(List<int> ids) {
    final allocation = GameScope.of(context).day3IdentityAllocation!;
    return _Page(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('${_directions.length} / 3 YARATICI MÜDAHALE',
            style: _label(context)),
        Text('Kimin dünyasına dokunacaksın?',
            style: Theme.of(context).textTheme.displayLarge),
        const SizedBox(height: AppSpacing.lg),
        ...ids.map((id) {
          final selected = _directions.containsKey(id);
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: InkWell(
              onTap: () => _direct(id),
              child: Container(
                decoration: BoxDecoration(
                    color: AppColors.inkSoft,
                    border: Border.all(
                        color: selected
                            ? AppColors.accentBright
                            : AppColors.line)),
                child: Row(children: [
                  SizedBox(
                      width: 82,
                      height: 105,
                      child: ContestantPortrait(contestant: _contestant(id))),
                  Expanded(
                      child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(_contestant(id).displayName,
                                    style:
                                        Theme.of(context).textTheme.titleLarge),
                                Text(
                                    '${day3ConceptLabel(allocation.conceptByContestantId[id]!)} • ${day3FitLabel(allocation.conceptFitByContestantId[id]!)}',
                                    style: _label(context)),
                                Text(_styleLabel(
                                    groupTaskProfiles[id]!.workStyle)),
                                if (selected)
                                  Text(
                                      '★ ${day3DirectionLabel(_directions[id]!)}',
                                      style: _label(context)),
                              ]))),
                ]),
              ),
            ),
          );
        }),
        AppButton(
            label: _directions.length == 3 ? 'YARATICI PLANIN' : '3 KİŞİ SEÇ',
            onPressed: _directions.length == 3 ? () => _go(_Phase.plan) : null),
      ]),
    );
  }

  Widget _plan() {
    final allocation = GameScope.of(context).day3IdentityAllocation!;
    return _Page(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('YARATICI PLANIN', style: Theme.of(context).textTheme.displayLarge),
      const SizedBox(height: AppSpacing.xl),
      ..._directions.entries.map((entry) => Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.lg),
          child: Row(children: [
            SizedBox(
                width: 90,
                height: 112,
                child: ContestantPortrait(contestant: _contestant(entry.key))),
            const SizedBox(width: AppSpacing.md),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(_contestant(entry.key).displayName,
                      style: Theme.of(context).textTheme.titleLarge),
                  Text(
                      day3ConceptLabel(
                          allocation.conceptByContestantId[entry.key]!),
                      style: _label(context)),
                  Text(day3DirectionLabel(entry.value))
                ]))
          ]))),
      TextButton(
          onPressed: () => _go(_Phase.select), child: const Text('DEĞİŞTİR')),
      AppButton(label: 'PLANI ONAYLA  ★ →', onPressed: _confirm)
    ]));
  }

  Widget _ready(List<int> ids) {
    final state = GameScope.of(context);
    final setup = state.day3IdentitySetupSnapshot!;
    final risk = ids
        .where((id) =>
            day3FitLabel(setup.allocation.conceptFitByContestantId[id]!) ==
            'RİSKLİ SEÇİM')
        .toList();
    final radar = ids.where(state.playerRadarContestantIds.contains).toList();
    return _Page(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('SET HAZIR', style: _label(context)),
      Text('13 farklı yıldız kimliği.',
          style: Theme.of(context).textTheme.displayLarge),
      Text('Şimdi kamera hangisinin gerçek olduğunu gösterecek.',
          style: Theme.of(context).textTheme.bodyLarge),
      const SizedBox(height: AppSpacing.xl),
      _grid(ids, directed: setup.stylingSupportContestantIds),
      if (risk.isNotEmpty) ...[
        const SizedBox(height: AppSpacing.xl),
        Text('RİSK ALANLAR', style: _label(context)),
        Text(risk.map((id) => _contestant(id).displayName).join(' • ')),
        Text('Bu konsept onların doğal alanı değil.',
            style: Theme.of(context).textTheme.bodySmall)
      ],
      if (radar.isNotEmpty) ...[
        const SizedBox(height: AppSpacing.xl),
        Text('AKTİF RADAR', style: _label(context)),
        ...radar.map((id) => Text(
            '★ ${_contestant(id).displayName} — ${day3ConceptLabel(setup.allocation.conceptByContestantId[id]!)}'))
      ],
      const SizedBox(height: AppSpacing.xl),
      AppButton(
          label: 'KAMERAYI AÇ  ★ →',
          onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(
              builder: (_) => const Day3IconPerformanceScreen())))
    ]));
  }

  Widget _grid(List<int> ids,
          {bool compact = false, List<int> directed = const []}) =>
      LayoutBuilder(builder: (context, constraints) {
        final count = constraints.maxWidth >= 650
            ? 5
            : constraints.maxWidth >= 420
                ? 4
                : 3;
        return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: ids.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: count,
                childAspectRatio: compact ? .68 : .58,
                crossAxisSpacing: 7,
                mainAxisSpacing: 7),
            itemBuilder: (_, i) => Column(children: [
                  Expanded(
                      child:
                          ContestantPortrait(contestant: _contestant(ids[i]))),
                  Text(_contestant(ids[i]).displayName, maxLines: 1),
                  if (directed.contains(ids[i]))
                    Text('★ SEN YÖNETTİN', maxLines: 1, style: _label(context))
                ]));
      });
}

class _Page extends StatelessWidget {
  const _Page({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
      child: MaxWidthContainer(
          maxWidth: 860,
          child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: child)));
}

TextStyle _label(BuildContext context) => Theme.of(context)
    .textTheme
    .labelLarge!
    .copyWith(color: AppColors.accentBright, letterSpacing: 1.1);
String _conceptDescription(Day3Concept c) => switch (c) {
      Day3Concept.popIcon => 'Parlak, güçlü, modern.',
      Day3Concept.highFashion => 'Keskin, editorial, mesafeli.',
      Day3Concept.romanticStar => 'Duygusal, zarif, vokal odaklı.',
      Day3Concept.rebelEdge => 'Cesur, asi, kontrolsüz enerji.',
      Day3Concept.dreamyCinema => 'Sinematik, gizemli, atmosferik.'
    };
String _conceptReaction(Day3Concept c) => switch (c) {
      Day3Concept.popIcon => 'Büyük görünmek istiyor.',
      Day3Concept.highFashion =>
        'Kamerada daha keskin bir tarafını gösterecek.',
      Day3Concept.romanticStar => 'Gücünü duygudan kuruyor.',
      Day3Concept.rebelEdge => 'Kontrollü görünmek gibi bir niyeti yok.',
      Day3Concept.dreamyCinema =>
        'Performanstan çok bir dünya yaratmak istiyor.'
    };
String _directionDescription(Day3CreativeDirection d) => switch (d) {
      Day3CreativeDirection.sharpenIdentity =>
        'Seçtiği konsepti daha net, tutarlı ve güçlü hale getir.',
      Day3CreativeDirection.surprise =>
        'Beklenmedik bir detay ekle; daha fazla risk ve özgünlük.',
      Day3CreativeDirection.ownCamera =>
        'Styling’i sadeleştir, odağı yüzüne ve kamera anlarına taşı.'
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
