import 'package:flutter/material.dart';
import 'package:yildiz_kadro/app/theme/app_colors.dart';
import 'package:yildiz_kadro/app/theme/app_spacing.dart';
import 'package:yildiz_kadro/features/contestants/data/contestant_seed_data.dart';
import 'package:yildiz_kadro/features/contestants/domain/contestant.dart';
import 'package:yildiz_kadro/features/contestants/presentation/widgets/contestant_portrait.dart';
import 'package:yildiz_kadro/features/game/application/game_scope.dart';
import 'package:yildiz_kadro/features/group_task/data/day6_final_engine.dart';
import 'package:yildiz_kadro/features/group_task/data/group_task_profiles.dart';
import 'package:yildiz_kadro/features/group_task/domain/day6_final_result.dart';
import 'package:yildiz_kadro/features/group_task/domain/group_task_profile.dart';
import 'package:yildiz_kadro/features/postgame/presentation/season_complete_hub_screen.dart';
import 'package:yildiz_kadro/shared/widgets/app_button.dart';
import 'package:yildiz_kadro/shared/widgets/contestant_dialogue_bubble.dart';
import 'package:yildiz_kadro/shared/widgets/max_width_container.dart';

enum _FinalPhase {
  intro,
  backstage,
  direction,
  directionConfirm,
  showcase,
  evaluation,
  standout,
  recommendation,
  selection,
  review,
  transition,
  reveal,
  roles,
  recap,
  complete
}

class Day6GrandFinalScreen extends StatefulWidget {
  const Day6GrandFinalScreen({super.key});
  @override
  State<Day6GrandFinalScreen> createState() => _Day6GrandFinalScreenState();
}

class _Day6GrandFinalScreenState extends State<Day6GrandFinalScreen> {
  _FinalPhase phase = _FinalPhase.intro;
  Day6DebutDirection? direction;
  Day6ResultSnapshot? result;
  final selected = <int>[];
  int showcaseSegment = 0;
  int revealCount = 1;
  bool initialized = false;

  Contestant contestant(int id) =>
      contestantSeedData.firstWhere((value) => value.id == id);
  void go(_FinalPhase value) => setState(() => phase = value);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (initialized) return;
    initialized = true;
    final state = GameScope.of(context);
    if (state.seasonCompleted) {
      result = state.day6ResultSnapshot;
      selected
        ..clear()
        ..addAll(state.playerFinalLineupIds);
      direction = state.day6DebutDirection;
      phase = _FinalPhase.complete;
    } else if (state.day6ResultSnapshot != null && result == null) {
      result = state.day6ResultSnapshot;
      direction = result!.direction;
      phase = _FinalPhase.evaluation;
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
        canPop: !GameScope.of(context).day6FinalLineupConfirmed,
        child: Scaffold(
          backgroundColor: AppColors.ink,
          body: SafeArea(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 260),
              child: switch (phase) {
                _FinalPhase.intro => intro(),
                _FinalPhase.backstage => backstage(),
                _FinalPhase.direction => directionChoice(),
                _FinalPhase.directionConfirm => directionConfirm(),
                _FinalPhase.showcase => showcase(),
                _FinalPhase.evaluation => evaluation(),
                _FinalPhase.standout => standout(),
                _FinalPhase.recommendation => recommendation(),
                _FinalPhase.selection => selection(),
                _FinalPhase.review => review(),
                _FinalPhase.transition => transition(),
                _FinalPhase.reveal => reveal(),
                _FinalPhase.roles => roles(),
                _FinalPhase.recap => recap(),
                _FinalPhase.complete => complete(),
              },
            ),
          ),
        ),
      );

  Widget intro() => page([
        Text('6. GÜN', style: label()),
        Text('BÜYÜK FİNAL', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: AppSpacing.md),
        Text("Yıldız Kadro'yu kurma zamanı.",
            style: Theme.of(context).textTheme.displayLarge),
        Text('7 finalist.\n5 kişilik bir grup.\nSon karar senin.',
            style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: AppSpacing.sm),
        const Text(
            'Puanlar sana yol gösterecek.\nAma bu kez kimse senin yerine seçim yapmayacak.'),
        const SizedBox(height: AppSpacing.xl),
        lineup(GameScope.of(context).day5FinalistIds),
        const SizedBox(height: AppSpacing.xl),
        AppButton(
            label: 'FİNALİ BAŞLAT  ★ →',
            onPressed: () => go(_FinalPhase.backstage)),
      ]);

  Widget backstage() {
    final ids = GameScope.of(context).day5FinalistIds.take(4).toList();
    return page([
      Text('BACKSTAGE', style: label()),
      Text('Son bir sahne kaldı.',
          style: Theme.of(context).textTheme.displayLarge),
      ...ids.asMap().entries.map((entry) => Padding(
            padding: const EdgeInsets.only(top: AppSpacing.md),
            child: ContestantDialogueBubble(
                contestant: contestant(entry.value),
                text: backstageLine(entry.value),
                alignRight: entry.key.isOdd),
          )),
      const SizedBox(height: AppSpacing.xl),
      AppButton(
          label: 'DEBUT YÖNÜNÜ SEÇ',
          onPressed: () => go(_FinalPhase.direction)),
    ]);
  }

  Widget directionChoice() => page([
        Text('NASIL BİR GRUP ÇIKIŞ YAPSIN?',
            style: Theme.of(context).textTheme.displayLarge),
        const SizedBox(height: AppSpacing.lg),
        ...Day6DebutDirection.values.map((value) => InkWell(
              onTap: () => setState(() => direction = value),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                margin: const EdgeInsets.only(bottom: AppSpacing.md),
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: direction == value
                      ? AppColors.accentInk
                      : AppColors.inkSoft,
                  border: Border.all(
                      color: direction == value
                          ? AppColors.accentBright
                          : AppColors.line),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(day6DirectionLabel(value),
                          style: Theme.of(context).textTheme.headlineSmall),
                      Text(directionDescription(value)),
                    ]),
              ),
            )),
        if (direction != null) ...directionReactions(),
        const SizedBox(height: AppSpacing.lg),
        AppButton(
            label: 'DEBUT YÖNÜNÜ İNCELE',
            onPressed: direction == null
                ? null
                : () => go(_FinalPhase.directionConfirm)),
      ]);

  Widget directionConfirm() => page([
        Text('DEBUT YÖNÜ', style: label()),
        Text(day6DirectionLabel(direction!),
            style: Theme.of(context).textTheme.displayLarge),
        const Text('Final showcase bu yaratıcı doğrultuda hazırlanacak.'),
        const SizedBox(height: AppSpacing.sm),
        Text(
            'Bu seçim final performanslarını etkiler. Final kadroyu belirlemez.',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(fontStyle: FontStyle.italic)),
        const SizedBox(height: AppSpacing.xl),
        TextButton(
            onPressed: () => go(_FinalPhase.direction),
            child: const Text('DEĞİŞTİR')),
        AppButton(label: "SHOWCASE'İ BAŞLAT", onPressed: startShowcase),
      ]);

  void startShowcase() {
    final state = GameScope.of(context);
    result = calculateDay6Results(
      finalistIds: state.day5FinalistIds,
      direction: direction!,
      first: state.evaluation1Results,
      day2: state.day2GroupPerformanceSnapshot!,
      day3: state.day3IconResultSnapshot!,
      day4: state.day4ResultSnapshot!,
      day5: state.day5ResultSnapshot!,
    );
    state.lockDay6Evaluation(result!);
    go(_FinalPhase.showcase);
  }

  Widget showcase() {
    const titles = ['OPENING', 'SPOTLIGHT', 'FINAL FORMATION'];
    return page([
      Text('DEBUT SHOWCASE', style: label()),
      Text(titles[showcaseSegment],
          style: Theme.of(context).textTheme.displayLarge),
      const SizedBox(height: AppSpacing.xl),
      _stageFormation(showcaseSegment),
      const SizedBox(height: AppSpacing.lg),
      Text(
          switch (showcaseSegment) {
            0 => 'Yedi finalist ilk kez aynı sahnede.',
            1 => 'Kamera her birinin imza anını yakalıyor.',
            _ => 'Son formasyon. Son nota. Karar zamanı.'
          },
          style: Theme.of(context).textTheme.headlineSmall),
      AppButton(
          label: showcaseSegment < 2 ? 'SONRAKİ BÖLÜM' : 'SHOWCASE SONUÇLARI',
          onPressed: () {
            if (showcaseSegment < 2) {
              setState(() => showcaseSegment++);
            } else {
              go(_FinalPhase.evaluation);
            }
          }),
    ]);
  }

  Widget evaluation() => page([
        Text('FINAL SHOWCASE TAMAMLANDI',
            style: Theme.of(context).textTheme.displayLarge),
        const Text('LIVE • STAR • DEBUT FIT'),
        const SizedBox(height: AppSpacing.lg),
        Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: result!.rankingIds.map(scoreCard).toList()),
        const SizedBox(height: AppSpacing.xl),
        AppButton(
            label: 'GECENİN ÖNE ÇIKANLARI',
            onPressed: () => go(_FinalPhase.standout)),
      ]);

  Widget standout() => page([
        Text('SHOWCASE STANDOUT', style: label()),
        Text('Gecenin en güçlü 3’ü',
            style: Theme.of(context).textTheme.displayLarge),
        const Text('Bu gece en yüksek final değerlendirmesini alan isimler.'),
        const SizedBox(height: AppSpacing.xl),
        lineup(result!.rankingIds.take(3).toList()),
        const SizedBox(height: AppSpacing.xl),
        AppButton(
            label: 'JÜRİ ÖNERİSİNİ AÇ',
            onPressed: () => go(_FinalPhase.recommendation)),
      ]);

  Widget recommendation() => page([
        Text('JÜRİNİN ÖNERDİĞİ KADRO',
            style: Theme.of(context).textTheme.displayLarge),
        const Text(
            'Final performansı ve grup dengesi birlikte değerlendirildiğinde sistem bu beşliyi öne çıkarıyor.'),
        const SizedBox(height: AppSpacing.xl),
        lineup(result!.recommendedLineupIds),
        const SizedBox(height: AppSpacing.lg),
        Text('BU YALNIZCA ÖNERİ.', style: label()),
        Text('SON KARAR SENİN.',
            style: Theme.of(context).textTheme.headlineLarge),
        AppButton(
            label: 'KENDİ KADROMU KUR  ★ →',
            onPressed: () => go(_FinalPhase.selection)),
      ]);

  Widget selection() {
    final state = GameScope.of(context);
    final balance = calculateLineupBalance(
        lineupIds: selected,
        first: state.evaluation1Results,
        day3: state.day3IconResultSnapshot!,
        day5: state.day5ResultSnapshot!);
    final overlap =
        selected.where(result!.recommendedLineupIds.contains).length;
    return page([
      Text('YILDIZ KADRO', style: label()),
      Text('ŞİMDİ KADRONU KUR',
          style: Theme.of(context).textTheme.displayLarge),
      const Text('7 finalistten 5’ini seç. Bu kez son karar tamamen senin.'),
      const SizedBox(height: AppSpacing.lg),
      Text('${selected.length} / 5 ÜYE SEÇİLDİ',
          style: Theme.of(context).textTheme.headlineSmall),
      slots(),
      const SizedBox(height: AppSpacing.lg),
      Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: state.day5FinalistIds.map(finalistTile).toList()),
      const SizedBox(height: AppSpacing.xl),
      Text('KADRO DENGESİ', style: label()),
      balancePanel(balance),
      Text(identitySummary(balance),
          style: Theme.of(context).textTheme.titleLarge),
      Text('Jüri önerisinden $overlap / 5',
          style: Theme.of(context).textTheme.bodySmall),
      const SizedBox(height: AppSpacing.xl),
      AppButton(
          label: 'KADROMU İNCELE  ★ →',
          onPressed:
              selected.length == 5 ? () => go(_FinalPhase.review) : null),
    ]);
  }

  Widget review() {
    final state = GameScope.of(context);
    final balance = currentBalance(state);
    final assignments = currentRoles(state);
    final jury = selected.where(result!.recommendedLineupIds.contains).length;
    final radar =
        selected.where(state.playerRadarContestantIds.contains).length;
    return page([
      Text('BU SENİN YILDIZ KADRON',
          style: Theme.of(context).textTheme.displayLarge),
      lineup(selected),
      const SizedBox(height: AppSpacing.xl),
      Text('KADRO DENGESİ', style: label()),
      balancePanel(balance),
      Text('ÖNERİLEN ROLLER', style: label()),
      ...FinalGroupRole.values.map((role) => ListTile(
          dense: true,
          contentPadding: EdgeInsets.zero,
          title: Text(contestant(assignments[role]!).displayName),
          trailing: Text(finalRoleLabel(role), style: label()))),
      metric('JÜRİ ÖNERİSİYLE ORTAK', '$jury / 5'),
      metric('İLK RADARINDAN', '$radar / 5'),
      metric('SONRADAN KEŞFETTİĞİN', '${5 - radar} ÜYE'),
      ContestantDialogueBubble(
          contestant: contestant(selected.first),
          text: 'Bu beşli sahnede güçlü olabilir.'),
      const SizedBox(height: AppSpacing.lg),
      TextButton(
          onPressed: () => go(_FinalPhase.selection),
          child: const Text('KADROYU DEĞİŞTİR')),
      AppButton(
          label: 'YILDIZ KADROM BU  ★',
          onPressed: () => confirmSheet(balance, assignments)),
    ]);
  }

  Future<void> confirmSheet(
      LineupBalance balance, Map<FinalGroupRole, int> assignments) async {
    final accepted = await showModalBottomSheet<bool>(
        context: context,
        backgroundColor: AppColors.inkSoft,
        isScrollControlled: true,
        builder: (context) => SafeArea(
            child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('SON KARARIN',
                          style: Theme.of(context).textTheme.headlineLarge),
                      lineup(selected),
                      const SizedBox(height: AppSpacing.md),
                      const Text(
                          'Bu beş yarışmacı Yıldız Kadro’yu oluşturacak.\nBu seçim sezon finalini belirleyecek.'),
                      const SizedBox(height: AppSpacing.lg),
                      TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('GERİ DÖN')),
                      AppButton(
                          label: 'EVET, KADROM BU',
                          onPressed: () => Navigator.pop(context, true)),
                    ]))));
    if (accepted != true || !mounted) return;
    GameScope.of(context).confirmFinalLineup(
        contestantIds: selected, balance: balance, suggestedRoles: assignments);
    setState(() {
      revealCount = 1;
      phase = _FinalPhase.transition;
    });
    Future<void>.delayed(const Duration(milliseconds: 1400), () {
      if (mounted && phase == _FinalPhase.transition) go(_FinalPhase.reveal);
    });
  }

  Widget transition() => const Center(
        key: ValueKey('final-transition'),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('SEZON TAMAMLANDI'),
          SizedBox(height: AppSpacing.xl),
          Text('YILDIZ KADRO'),
          SizedBox(height: AppSpacing.sm),
          Text('DEBUT KADROSU HAZIR'),
        ]),
      );

  Widget reveal() {
    final visible = selected.take(revealCount).toList();
    return page([
      Text('YILDIZ KADRO', style: label()),
      Text(revealCount < 5 ? 'YILDIZ KADRO ÜYESİ' : 'KADRO TAMAMLANDI',
          style: Theme.of(context).textTheme.displayLarge),
      const SizedBox(height: AppSpacing.xl),
      lineup(visible),
      if (revealCount < 5) ...[
        Text(historyBadge(visible.last), style: label()),
        AppButton(
            label: 'SONRAKİ ÜYE',
            onPressed: () {
              setState(() => revealCount++);
              if (revealCount == 5) {
                GameScope.of(context).completeFinalReveal();
              }
            }),
      ] else ...[
        Text('YILDIZ KADRO', style: Theme.of(context).textTheme.headlineLarge),
        AppButton(
            label: 'GRUP ROLLERİNİ AÇ', onPressed: () => go(_FinalPhase.roles)),
      ],
    ]);
  }

  Widget roles() {
    final state = GameScope.of(context);
    return page([
      Text('GRUP İÇİNDEKİ ROLLER',
          style: Theme.of(context).textTheme.displayLarge),
      ...FinalGroupRole.values.map((role) => Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
              color: AppColors.inkSoft,
              border: Border.all(color: AppColors.line)),
          child: Row(children: [
            ClipOval(
                child: SizedBox(
                    width: 58,
                    height: 58,
                    child: ContestantPortrait(
                        contestant:
                            contestant(state.suggestedFinalRoles[role]!)))),
            const SizedBox(width: AppSpacing.md),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(finalRoleLabel(role), style: label()),
                  Text(
                      contestant(state.suggestedFinalRoles[role]!).displayName),
                  Text(roleDescription(role),
                      style: Theme.of(context).textTheme.bodySmall)
                ]))
          ]))),
      Text('GRUP PROFİLİ', style: label()),
      Text(groupProfile(state.finalLineupBalance!),
          style: Theme.of(context).textTheme.headlineLarge),
      Text(identitySummary(state.finalLineupBalance!)),
      AppButton(label: 'SEZON ÖZETİ', onPressed: () => go(_FinalPhase.recap)),
    ]);
  }

  Widget recap() {
    final state = GameScope.of(context);
    final radar =
        selected.where(state.playerRadarContestantIds.contains).length;
    final impact = [
      state.day2DuelResultSnapshot?.playerChangedOutcome ?? false,
      state.day3FinalCutResultSnapshot?.playerChangedOutcome ?? false,
      state.day4ResultSnapshot?.playerChangedRoomElimination ?? false,
      state.day5ResultSnapshot?.playerChangedCut ?? false
    ].where((value) => value).length;
    return page([
      Text('BU KADROYA NASIL GELDİN?',
          style: Theme.of(context).textTheme.displayLarge),
      metric('İLK RADARIN', 'Final kadrona giren: $radar / 5'),
      if (state.producerSaveContestantId != null &&
          selected.contains(state.producerSaveContestantId))
        metric('İLK GÜN KORUDUĞUN',
            '${contestant(state.producerSaveContestantId!).displayName} final kadrona kadar geldi.'),
      if (state.lastChanceCoachContestantId != null &&
          selected.contains(state.lastChanceCoachContestantId))
        metric('SAHNE NOTUN',
            '${contestant(state.lastChanceCoachContestantId!).displayName} şimdi Yıldız Kadro’da.'),
      if (impact > 0)
        metric('GERÇEK ETKİN',
            '$impact eleme sonucunu verdiğin kararlar değiştirdi.'),
      metric('JÜRİ ÖNERİSİYLE ORTAK',
          '${selected.where(result!.recommendedLineupIds.contains).length} / 5'),
      const SizedBox(height: AppSpacing.xl),
      Text('Puanlar onları finale taşıdı.',
          style: Theme.of(context).textTheme.headlineSmall),
      Text('Son beşliyi sen seçtin.',
          style: Theme.of(context).textTheme.headlineLarge),
      AppButton(
          label: 'FİNALİ TAMAMLA', onPressed: () => go(_FinalPhase.complete)),
    ]);
  }

  Widget complete() {
    final state = GameScope.of(context);
    final ids = state.playerFinalLineupIds;
    return page([
      Text('YILDIZ KADRO', style: Theme.of(context).textTheme.displayLarge),
      lineup(ids),
      const SizedBox(height: AppSpacing.xl),
      Text('SEZON TAMAMLANDI', style: label()),
      Text('5 kişilik grubun hazır.',
          style: Theme.of(context).textTheme.headlineSmall),
      const SizedBox(height: AppSpacing.xl),
      AppButton(
          label: 'KADROMU İNCELE', onPressed: () => go(_FinalPhase.roles)),
      TextButton(
          onPressed: () => go(_FinalPhase.recap),
          child: const Text('SEZONU GÖR')),
      TextButton(
          onPressed: () => Navigator.of(context).pushReplacement(
                MaterialPageRoute<void>(
                    builder: (_) => const SeasonCompleteHubScreen()),
              ),
          child: const Text('DEBUT HUB’A GEÇ')),
    ]);
  }

  Widget finalistTile(int id) {
    final state = GameScope.of(context),
        isSelected = selected.contains(id),
        score = result!.results[id]!;
    return InkWell(
        onTap: () => toggle(id),
        child: AnimatedScale(
            scale: isSelected ? 1.025 : 1,
            duration: const Duration(milliseconds: 150),
            child: Container(
                width: 156,
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                    color: AppColors.inkSoft,
                    border: Border.all(
                        width: isSelected ? 2 : 1,
                        color: isSelected
                            ? AppColors.accentBright
                            : AppColors.line),
                    borderRadius: BorderRadius.circular(8)),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AspectRatio(
                          aspectRatio: .82,
                          child:
                              ContestantPortrait(contestant: contestant(id))),
                      Text(contestant(id).displayName, maxLines: 1),
                      Text(groupRoleLabel(groupTaskProfiles[id]!.primaryRole),
                          style: label()),
                      Text('LIVE ${score.live}  STAR ${score.star}'),
                      Text('FIT ${score.debutFit}'),
                      if (state.playerRadarContestantIds.contains(id))
                        const Text('★ İLK RADAR'),
                      if (result!.recommendedLineupIds.contains(id))
                        const Text('JÜRİ ÖNERİSİ'),
                      if (isSelected) Text('★ KADRODA', style: label()),
                    ]))));
  }

  void toggle(int id) {
    if (selected.contains(id)) {
      setState(() => selected.remove(id));
      return;
    }
    if (selected.length == 5) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Kadron 5 kişilik. Önce birini çıkar.'),
          duration: Duration(milliseconds: 1300)));
      return;
    }
    setState(() => selected.add(id));
  }

  Widget slots() => SizedBox(
      height: 82,
      child: Row(
          children: List.generate(
              5,
              (index) => Expanded(
                  child: Container(
                      margin: const EdgeInsets.only(right: 5),
                      decoration: BoxDecoration(
                          color: AppColors.inkSoft,
                          border: Border.all(
                              color: index < selected.length
                                  ? AppColors.accentBright
                                  : AppColors.line)),
                      child: index < selected.length
                          ? ContestantPortrait(
                              contestant: contestant(selected[index]))
                          : const Center(
                              child: Icon(Icons.star_border_rounded,
                                  color: AppColors.line)))))));
  Widget scoreCard(int id) {
    final score = result!.results[id]!;
    return InkWell(
        onTap: () => scoreDetails(id),
        child: SizedBox(
            width: 150,
            child: Column(children: [
              AspectRatio(
                  aspectRatio: .82,
                  child: ContestantPortrait(contestant: contestant(id))),
              Text(contestant(id).displayName),
              Text('LIVE ${score.live}'),
              Text('STAR ${score.star}'),
              Text('FIT ${score.debutFit}', style: label())
            ])));
  }

  void scoreDetails(int id) {
    final score = result!.results[id]!;
    showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
            backgroundColor: AppColors.inkSoft,
            title: Text(contestant(id).displayName),
            content: Column(mainAxisSize: MainAxisSize.min, children: [
              metric('LIVE', '${score.live}'),
              metric('STAR', '${score.star}'),
              metric('GROWTH', '${score.growth}'),
              metric('CONSISTENCY', '${score.consistency}'),
              metric('DEBUT FIT', '${score.debutFit}')
            ])));
  }

  Widget balancePanel(LineupBalance value) =>
      Wrap(spacing: AppSpacing.sm, runSpacing: AppSpacing.sm, children: [
        balanceItem('VOKAL', value.vocal),
        balanceItem('DANS', value.dance),
        balanceItem('SAHNE', value.stage),
        balanceItem('KAMERA', value.camera),
        balanceItem('UYUM', value.harmony)
      ]);
  Widget balanceItem(String title, int score) => Container(
      width: 142,
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(border: Border.all(color: AppColors.line)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: label()),
        Text('$score — ${balanceLabel(score)}')
      ]));
  Widget metric(String title, String value) => Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
          color: AppColors.inkSoft, border: Border.all(color: AppColors.line)),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [Text(title, style: label()), Text(value)]));
  Widget lineup(List<int> ids) => Wrap(
      spacing: 8,
      runSpacing: 10,
      children: ids
          .map((id) => SizedBox(
              width: 104,
              child: Column(children: [
                AspectRatio(
                    aspectRatio: .72,
                    child: ContestantPortrait(contestant: contestant(id))),
                Text(contestant(id).displayName,
                    maxLines: 1, overflow: TextOverflow.ellipsis)
              ])))
          .toList());
  Widget _stageFormation(int segment) {
    final ids = result!.rankingIds;
    final ordered = segment == 1
        ? [...ids.skip(3), ...ids.take(3)]
        : segment == 2
            ? ids.reversed.toList()
            : ids;
    return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
        decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [AppColors.inkSoft, AppColors.accentInk]),
            border: Border.all(color: AppColors.line)),
        child: Center(
            child: Wrap(
                alignment: WrapAlignment.center,
                spacing: segment == 2 ? 4 : 12,
                runSpacing: 12,
                children: ordered
                    .map((id) => SizedBox(
                        width: segment == 1 &&
                                result!.rankingIds.take(3).contains(id)
                            ? 88
                            : 68,
                        child: Column(children: [
                          ClipOval(
                              child: AspectRatio(
                                  aspectRatio: 1,
                                  child: ContestantPortrait(
                                      contestant: contestant(id)))),
                          Text(contestant(id).displayName,
                              maxLines: 1,
                              style: Theme.of(context).textTheme.labelSmall)
                        ])))
                    .toList())));
  }

  Widget page(List<Widget> children) => SingleChildScrollView(
      key: ValueKey(phase),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: MaxWidthContainer(
          maxWidth: 850,
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children)));
  TextStyle label() => Theme.of(context)
      .textTheme
      .labelLarge!
      .copyWith(color: AppColors.accentBright, letterSpacing: 1.1);

  LineupBalance currentBalance(dynamic state) => calculateLineupBalance(
      lineupIds: selected,
      first: state.evaluation1Results,
      day3: state.day3IconResultSnapshot!,
      day5: state.day5ResultSnapshot!);
  Map<FinalGroupRole, int> currentRoles(dynamic state) => assignSuggestedRoles(
      lineupIds: selected,
      finalResult: result!,
      first: state.evaluation1Results,
      day3: state.day3IconResultSnapshot!,
      day4: state.day4ResultSnapshot!,
      day5: state.day5ResultSnapshot!);
  List<Widget> directionReactions() {
    final ids = GameScope.of(context).day5FinalistIds.take(2).toList();
    return ids
        .asMap()
        .entries
        .map((entry) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: ContestantDialogueBubble(
                contestant: contestant(entry.value),
                text: direction == Day6DebutDirection.performanceUnit
                    ? 'Tam benim finalim.'
                    : direction == Day6DebutDirection.iconGroup
                        ? 'Bunu nasıl oynayacağımı biliyorum.'
                        : 'Sesimi bu sahnede duyuracağım.',
                alignRight: entry.key.isOdd)))
        .toList();
  }

  String backstageLine(int id) => switch (groupTaskProfiles[id]!.workStyle) {
        WorkStyle.bold => 'Beşin içine girmek için buradayım.',
        WorkStyle.calm => 'Artık elimden geleni yaptım. Son bir sahne kaldı.',
        WorkStyle.competitive =>
          'Finale kadar geldim. Burada durmak istemiyorum.',
        WorkStyle.playful => 'Şimdi gerçekten grup kuruluyor.',
        WorkStyle.cameraSavvy => 'Son kez kamera açıldığında hazır olacağım.',
        _ => 'Bu sahne için bütün sezon çalıştım.'
      };
  String directionDescription(Day6DebutDirection value) => switch (value) {
        Day6DebutDirection.popPower =>
          'Büyük nakaratlar, güçlü vokal, dengeli performans.',
        Day6DebutDirection.performanceUnit =>
          'Koreografi, sahne gücü ve yüksek enerji.',
        Day6DebutDirection.iconGroup =>
          'Kamera, kimlik ve unutulmaz yıldız etkisi.'
      };
  String groupRoleLabel(GroupRole role) => switch (role) {
        GroupRole.vocal => 'VOCAL',
        GroupRole.dance => 'DANCE',
        GroupRole.stage => 'STAGE',
        GroupRole.allRounder => 'ALL-ROUNDER'
      };
  String balanceLabel(int score) => score >= 90
      ? 'ÇOK GÜÇLÜ'
      : score >= 84
          ? 'GÜÇLÜ'
          : score >= 78
              ? 'DENGELİ'
              : score >= 72
                  ? 'RİSKLİ'
                  : 'ZAYIF NOKTA';
  String identitySummary(LineupBalance b) {
    final values = {
      'vokal': b.vocal,
      'dans': b.dance,
      'sahne': b.stage,
      'kamera': b.camera
    };
    final best =
        values.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
    if (values.values.reduce((a, b) => a > b ? a : b) -
            values.values.reduce((a, b) => a < b ? a : b) <=
        5) {
      return 'Dengeli ve çok yönlü bir beşli.';
    }
    return switch (best) {
      'vokal' => 'Canlı performansta güçlü, vokal merkezli bir grup.',
      'dans' => 'Performans odaklı, hareket gücü yüksek bir kadro.',
      'kamera' => 'Görsel ve kamera kimliği çok güçlü bir kadro.',
      _ => 'Sahne gücü yüksek, etkili bir kadro.'
    };
  }

  String groupProfile(LineupBalance b) {
    if ((b.vocal - b.dance).abs() < 5 && (b.stage - b.camera).abs() < 5) {
      return 'DENGELİ BEŞLİ';
    }
    if (b.camera >= b.vocal && b.camera >= b.dance) return 'İKONİK POP';
    if (b.dance >= b.vocal) return 'PERFORMANS ODAKLI';
    return 'CANLI SAHNE GRUBU';
  }

  String roleDescription(FinalGroupRole role) => switch (role) {
        FinalGroupRole.mainVocal => 'Grubun canlı vokal omurgası.',
        FinalGroupRole.center => 'Formasyonun kamera ve sahne merkezi.',
        FinalGroupRole.performanceLead =>
          'Koreografi ve performans enerjisini taşır.',
        FinalGroupRole.allRounder => 'Farklı alanlar arasında denge kurar.',
        FinalGroupRole.starVisual => 'Grubun görsel ve kamera kimliğini taşır.'
      };
  String historyBadge(int id) {
    final state = GameScope.of(context);
    if (state.playerRadarContestantIds.contains(id)) return '★ İLK RADARINDA';
    if (state.day4ResultSnapshot!.winnerByRoom.values.contains(id)) {
      return '★ POZİSYON SAVAŞI GALİBİ';
    }
    if (state.day5ResultSnapshot!.rankingIds.first == id) {
      return '★ CANLI YAYIN YILDIZI';
    }
    return '★ BÜYÜK FİNALİST';
  }
}
