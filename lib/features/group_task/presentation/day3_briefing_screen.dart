import 'package:flutter/material.dart';
import 'package:yildiz_kadro/app/theme/app_colors.dart';
import 'package:yildiz_kadro/app/theme/app_spacing.dart';
import 'package:yildiz_kadro/features/contestants/data/contestant_seed_data.dart';
import 'package:yildiz_kadro/features/contestants/domain/contestant.dart';
import 'package:yildiz_kadro/l10n/l10n.dart';
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
  bool _initializationScheduled = false;
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
    if (state.day3IdentityAllocation == null && !_initializationScheduled) {
      _initializationScheduled = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final game = GameScope.of(context);
        final day2 = game.day2GroupPerformanceSnapshot;
        if (game.day3IdentityAllocation != null || day2 == null) return;
        final ids = _activeIds(context);
        game.initializeDay3Identity(
          allocateDay3Concepts(
            activeContestantIds: ids,
            evaluationResults: game.evaluation1Results,
            day2Scores: {
              for (final id in ids)
                id: day2.individualResults[id]?.rawOverall ?? 0,
            },
          ),
        );
      });
    }
    if (state.day3IdentitySetupCompleted) {
      _directions.addAll(
        state.day3IdentitySetupSnapshot!.creativeDirectionByContestantId,
      );
      _phase = _Phase.ready;
    }
  }

  void _go(_Phase p) => setState(() => _phase = p);
  Future<void> _direct(int id) async {
    final selected = await showModalBottomSheet<Day3CreativeDirection>(
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
                      ? 'WHAT IS YOUR DIRECTION FOR ${_contestant(id).displayName}?'
                      : '${_contestant(id).displayName} İÇİN YÖNÜN NE?',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: AppSpacing.md),
                ...Day3CreativeDirection.values.map(
                  (direction) => ListTile(
                    onTap: () => Navigator.pop(context, direction),
                    title: Text(day3DirectionLabel(direction, context)),
                    subtitle: Text(_directionDescription(direction, context)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
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
      builder: (context) {
        final isEn = isAppEnglish(context);
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isEn ? 'CREATIVE PLAN READY' : 'YARATICI PLAN HAZIR',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  isEn
                      ? 'You will directly guide the camera mission of these 3 contestants.\nThe other 10 contestants will proceed with their own creative instinct.'
                      : 'Bu üç yarışmacının kamera görevine doğrudan müdahale edeceksin.\nDiğer 10 yarışmacı kendi yaratıcı kararlarıyla ilerleyecek.',
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: Text(isEn ? 'CHANGE' : 'DEĞİŞTİR'),
                      ),
                    ),
                    Expanded(
                      child: FilledButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: Text(isEn ? 'SEND TO SET' : 'SETE GÖNDER'),
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
    if (ok == true && mounted) {
      final state = GameScope.of(context);
      state.completeDay3IdentitySetup(
        createDay3IdentitySetup(
          allocation: state.day3IdentityAllocation!,
          directions: _directions,
          evaluationResults: state.evaluation1Results,
        ),
      );
      _go(_Phase.ready);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ids = _activeIds(context);
    return Scaffold(
      backgroundColor: AppColors.ink,
      body: SafeArea(
        child: GameScope.of(context).day3IdentityAllocation == null
            ? const Center(child: CircularProgressIndicator())
            : AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                child: switch (_phase) {
                  _Phase.intro => _intro(ids),
                  _Phase.task => _task(),
                  _Phase.reveal => _reveal(ids),
                  _Phase.worlds => _worlds(ids),
                  _Phase.director => _director(),
                  _Phase.select => _select(ids),
                  _Phase.plan => _plan(),
                  _Phase.ready => _ready(ids),
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
          Text(context.l10n.dayLabel(3), style: _label(context)),
          Text(
            isEn ? 'STAR IDENTITY' : 'YILDIZ KİMLİĞİ',
            style: Theme.of(context).textTheme.displayLarge,
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            isEn ? 'No squads this time.' : 'Bu kez takım yok.',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          Text(
            isEn
                ? '13 contestants.\n13 distinct faces.\nYet which one holds an authentic star identity?'
                : '13 yarışmacı.\n13 farklı yüz.\nAma hangisinin gerçekten bir yıldız kimliği var?',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            isEn
                ? 'Today contestants construct their own concepts. Style, camera aura, and persona are now as vital as raw performance.'
                : 'Bugün yarışmacılar kendi konseptlerini yaratacak. Stil, kamera ve sahne kişiliği ilk kez performans kadar önemli.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          Text(
            isEn
                ? 'Being good is not enough. You must be unforgettable.'
                : 'İyi olmak yetmez. Hatırlanmak gerekir.',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: AppSpacing.xl),
          _grid(ids, compact: true),
          const SizedBox(height: AppSpacing.xl),
          AppButton(
            label: isEn ? 'REVEAL MISSION  ★ →' : 'GÖREVİ AÇ  ★ →',
            onPressed: () => _go(_Phase.task),
          ),
        ],
      ),
    );
  }

  Widget _task() {
    final isEn = isAppEnglish(context);
    return _Page(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isEn ? 'CREATE YOUR STAR' : 'KENDİ YILDIZINI YARAT',
            style: Theme.of(context).textTheme.displayLarge,
          ),
          Text(
            isEn
                ? 'Each contestant gravitates toward one of five creative worlds.'
                : 'Her yarışmacı beş yaratıcı dünyadan birine yönelecek.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: AppSpacing.xl),
          ...Day3Concept.values.map(
            (c) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(day3ConceptLabel(c), style: _label(context)),
                  Text(
                    _conceptDescription(c, context),
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const Divider(color: AppColors.line),
                ],
              ),
            ),
          ),
          AppButton(
            label: isEn ? 'REVEAL CONCEPTS' : 'KONSEPTLERİ AÇ',
            onPressed: () => _go(_Phase.reveal),
          ),
        ],
      ),
    );
  }

  Widget _reveal(List<int> ids) {
    final isEn = isAppEnglish(context);
    final id = ids[_revealIndex];
    final allocation = GameScope.of(context).day3IdentityAllocation!;
    final concept = allocation.conceptByContestantId[id]!;
    return _Page(
      child: Column(
        children: [
          Text(
            isEn ? 'SELECTING CONCEPTS' : 'KONSEPTLER SEÇİLİYOR',
            style: _label(context),
          ),
          Text(
            '${_revealIndex + 1} / 13',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: 350,
            child: AspectRatio(
              aspectRatio: .82,
              child: ContestantPortrait(contestant: _contestant(id)),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            _contestant(id).displayName,
            style: Theme.of(context).textTheme.displayLarge,
          ),
          Text(
            day3ConceptLabel(concept),
            style: Theme.of(context)
                .textTheme
                .headlineLarge
                ?.copyWith(color: AppColors.accentBright),
          ),
          Text(
            day3FitLabel(allocation.conceptFitByContestantId[id]!, context),
            style: _label(context),
          ),
          Text(
            '“${_conceptReaction(concept, context)}”',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: AppSpacing.xl),
          AppButton(
            label: _revealIndex < 12
                ? (isEn ? 'NEXT CONCEPT' : 'SONRAKİ KONSEPT')
                : (isEn ? 'EXPLORE STAR WORLDS' : 'YILDIZ DÜNYALARINI GÖR'),
            onPressed: () {
              if (_revealIndex < 12) {
                setState(() => _revealIndex++);
              } else {
                _go(_Phase.worlds);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _worlds(List<int> ids) {
    final isEn = isAppEnglish(context);
    final allocation = GameScope.of(context).day3IdentityAllocation!;
    return _Page(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isEn ? 'STAR WORLDS CONFIGURED' : 'YILDIZ DÜNYALARI HAZIR',
            style: Theme.of(context).textTheme.displayLarge,
          ),
          const SizedBox(height: AppSpacing.xl),
          ...Day3Concept.values.map((concept) {
            final members = ids
                .where((id) => allocation.conceptByContestantId[id] == concept)
                .toList();
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(day3ConceptLabel(concept), style: _label(context)),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: members
                        .map(
                          (id) => Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: Column(
                                children: [
                                  AspectRatio(
                                    aspectRatio: .72,
                                    child: ContestantPortrait(
                                      contestant: _contestant(id),
                                    ),
                                  ),
                                  Text(
                                    _contestant(id).displayName,
                                    maxLines: 1,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            );
          }),
          AppButton(
            label: isEn ? 'CREATIVE DIRECTOR MODE' : 'YARATICI YÖNETMEN MODU',
            onPressed: () => _go(_Phase.director),
          ),
        ],
      ),
    );
  }

  Widget _director() {
    final isEn = isAppEnglish(context);
    return _Page(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isEn ? 'CREATIVE DIRECTOR' : 'YARATICI YÖNETMEN',
            style: _label(context),
          ),
          Text(
            isEn
                ? 'You cannot be on every set at once.'
                : 'Her sete yetişemezsin.',
            style: Theme.of(context).textTheme.displayLarge,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            isEn
                ? 'Today you can only directly guide the creative process of 3 contestants.'
                : 'Bugün yalnızca 3 yarışmacının yaratıcı sürecine doğrudan müdahale edebilirsin.',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          Text(
            isEn
                ? 'How you direct them matters just as much as who you direct.'
                : 'Kimi yönlendireceğin kadar, nasıl yönlendireceğin de önemli.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.xl),
          AppButton(
            label: isEn ? 'SELECT 3 TALENTS' : '3 İSMİ SEÇ',
            onPressed: () => _go(_Phase.select),
          ),
        ],
      ),
    );
  }

  Widget _select(List<int> ids) {
    final isEn = isAppEnglish(context);
    final allocation = GameScope.of(context).day3IdentityAllocation!;
    return _Page(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isEn
                ? '${_directions.length} / 3 CREATIVE INTERVENTIONS'
                : '${_directions.length} / 3 YARATICI MÜDAHALE',
            style: _label(context),
          ),
          Text(
            isEn
                ? 'Whose world will you shape?'
                : 'Kimin dünyasına dokunacaksın?',
            style: Theme.of(context).textTheme.displayLarge,
          ),
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
                      color: selected ? AppColors.accentBright : AppColors.line,
                    ),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 82,
                        height: 105,
                        child: ContestantPortrait(contestant: _contestant(id)),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _contestant(id).displayName,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              Text(
                                '${day3ConceptLabel(allocation.conceptByContestantId[id]!)} • ${day3FitLabel(allocation.conceptFitByContestantId[id]!, context)}',
                                style: _label(context),
                              ),
                              Text(
                                _styleLabel(
                                  groupTaskProfiles[id]!.workStyle,
                                  context,
                                ),
                              ),
                              if (selected)
                                Text(
                                  '★ ${day3DirectionLabel(_directions[id]!, context)}',
                                  style: _label(context),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
          AppButton(
            label: _directions.length == 3
                ? (isEn ? 'VIEW CREATIVE PLAN' : 'YARATICI PLANIN')
                : (isEn ? 'SELECT 3 TALENTS' : '3 KİŞİ SEÇ'),
            onPressed: _directions.length == 3 ? () => _go(_Phase.plan) : null,
          ),
        ],
      ),
    );
  }

  Widget _plan() {
    final isEn = isAppEnglish(context);
    final allocation = GameScope.of(context).day3IdentityAllocation!;
    return _Page(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isEn ? 'YOUR CREATIVE PLAN' : 'YARATICI PLANIN',
            style: Theme.of(context).textTheme.displayLarge,
          ),
          const SizedBox(height: AppSpacing.xl),
          ..._directions.entries.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.lg),
              child: Row(
                children: [
                  SizedBox(
                    width: 90,
                    height: 112,
                    child: ContestantPortrait(
                      contestant: _contestant(entry.key),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _contestant(entry.key).displayName,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Text(
                          day3ConceptLabel(
                            allocation.conceptByContestantId[entry.key]!,
                          ),
                          style: _label(context),
                        ),
                        Text(day3DirectionLabel(entry.value, context)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          TextButton(
            onPressed: () => _go(_Phase.select),
            child: Text(isEn ? 'CHANGE' : 'DEĞİŞTİR'),
          ),
          AppButton(
            label: isEn ? 'CONFIRM PLAN  ★ →' : 'PLANI ONAYLA  ★ →',
            onPressed: _confirm,
          ),
        ],
      ),
    );
  }

  Widget _ready(List<int> ids) {
    final isEn = isAppEnglish(context);
    final state = GameScope.of(context);
    final setup = state.day3IdentitySetupSnapshot!;
    final risk = ids
        .where(
          (id) => (setup.allocation.conceptFitByContestantId[id] ?? 80) < 77,
        )
        .toList();
    final radar = ids.where(state.playerRadarContestantIds.contains).toList();
    return _Page(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(isEn ? 'SET IS READY' : 'SET HAZIR', style: _label(context)),
          Text(
            isEn ? '13 distinct star identities.' : '13 farklı yıldız kimliği.',
            style: Theme.of(context).textTheme.displayLarge,
          ),
          Text(
            isEn
                ? 'Now the camera will reveal which ones are genuine.'
                : 'Şimdi kamera hangisinin gerçek olduğunu gösterecek.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: AppSpacing.xl),
          _grid(ids, directed: setup.stylingSupportContestantIds),
          if (risk.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xl),
            Text(isEn ? 'RISK TAKERS' : 'RİSK ALANLAR', style: _label(context)),
            Text(risk.map((id) => _contestant(id).displayName).join(' • ')),
            Text(
              isEn
                  ? 'This concept lies outside their natural wheelhouse.'
                  : 'Bu konsept onların doğal alanı değil.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
          if (radar.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xl),
            Text(isEn ? 'ACTIVE RADAR' : 'AKTİF RADAR', style: _label(context)),
            ...radar.map(
              (id) => Text(
                '★ ${_contestant(id).displayName} — ${day3ConceptLabel(setup.allocation.conceptByContestantId[id]!)}',
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.xl),
          AppButton(
            label: isEn ? 'ROLL CAMERA  ★ →' : 'KAMERAYI AÇ  ★ →',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const Day3IconPerformanceScreen(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _grid(
    List<int> ids, {
    bool compact = false,
    List<int> directed = const [],
  }) =>
      LayoutBuilder(
        builder: (context, constraints) {
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
              mainAxisSpacing: 7,
            ),
            itemBuilder: (_, i) => Column(
              children: [
                Expanded(
                  child: ContestantPortrait(contestant: _contestant(ids[i])),
                ),
                Text(_contestant(ids[i]).displayName, maxLines: 1),
                if (directed.contains(ids[i]))
                  Text(
                    isAppEnglish(context)
                        ? '★ DIRECTED BY YOU'
                        : '★ SEN YÖNETTİN',
                    maxLines: 1,
                    style: _label(context),
                  ),
              ],
            ),
          );
        },
      );
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
            child: child,
          ),
        ),
      );
}

TextStyle _label(BuildContext context) => Theme.of(context)
    .textTheme
    .labelLarge!
    .copyWith(color: AppColors.accentBright, letterSpacing: 1.1);
String _conceptDescription(Day3Concept c, [BuildContext? context]) {
  final isEn = isAppEnglish(context);
  return switch (c) {
    Day3Concept.popIcon =>
      isEn ? 'Bright, powerful, contemporary.' : 'Parlak, güçlü, modern.',
    Day3Concept.highFashion =>
      isEn ? 'Sharp, editorial, distant.' : 'Keskin, editorial, mesafeli.',
    Day3Concept.romanticStar => isEn
        ? 'Emotional, graceful, vocal-driven.'
        : 'Duygusal, zarif, vokal odaklı.',
    Day3Concept.rebelEdge => isEn
        ? 'Bold, defiant, unchecked energy.'
        : 'Cesur, asi, kontrolsüz enerji.',
    Day3Concept.dreamyCinema => isEn
        ? 'Cinematic, enigmatic, atmospheric.'
        : 'Sinematik, gizemli, atmosferik.',
  };
}

String _conceptReaction(Day3Concept c, [BuildContext? context]) {
  final isEn = isAppEnglish(context);
  return switch (c) {
    Day3Concept.popIcon =>
      isEn ? 'Aims for massive stage presence.' : 'Büyük görünmek istiyor.',
    Day3Concept.highFashion => isEn
        ? 'Will showcase an edgy, razor-sharp aura on camera.'
        : 'Kamerada daha keskin bir tarafını gösterecek.',
    Day3Concept.romanticStar => isEn
        ? 'Builds her gravity from pure emotion.'
        : 'Gücünü duygudan kuruyor.',
    Day3Concept.rebelEdge => isEn
        ? 'Has zero intention of playing it safe.'
        : 'Kontrollü görünmek gibi bir niyeti yok.',
    Day3Concept.dreamyCinema => isEn
        ? 'Seeks to build an immersive universe beyond mere performance.'
        : 'Performanstan çok bir dünya yaratmak istiyor.',
  };
}

String _directionDescription(Day3CreativeDirection d, [BuildContext? context]) {
  final isEn = isAppEnglish(context);
  return switch (d) {
    Day3CreativeDirection.sharpenIdentity => isEn
        ? 'Make her chosen concept sharper, coherent, and punchy.'
        : 'Seçtiği konsepti daha net, tutarlı ve güçlü hale getir.',
    Day3CreativeDirection.surprise => isEn
        ? 'Add an unexpected twist; higher risk and unmatched originality.'
        : 'Beklenmedik bir detay ekle; daha fazla risk ve özgünlük.',
    Day3CreativeDirection.ownCamera => isEn
        ? 'Streamline styling, shift laser focus to facial expressions and camera hits.'
        : 'Styling’i sadeleştir, odağı yüzüne ve kamera anlarına taşı.',
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
