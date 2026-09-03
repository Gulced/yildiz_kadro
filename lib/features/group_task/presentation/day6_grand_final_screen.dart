import 'package:flutter/material.dart';
import 'package:yildiz_kadro/app/theme/app_colors.dart';
import 'package:yildiz_kadro/app/theme/app_spacing.dart';
import 'package:yildiz_kadro/features/contestants/data/contestant_seed_data.dart';
import 'package:yildiz_kadro/features/contestants/domain/contestant.dart';
import 'package:yildiz_kadro/l10n/l10n.dart';
import 'package:yildiz_kadro/features/contestants/presentation/widgets/contestant_portrait.dart';
import 'package:yildiz_kadro/features/game/application/game_scope.dart';
import 'package:yildiz_kadro/features/group_task/data/day6_final_engine.dart';
import 'package:yildiz_kadro/features/group_task/data/group_task_profiles.dart';
import 'package:yildiz_kadro/features/group_task/domain/day6_final_result.dart';
import 'package:yildiz_kadro/features/group_task/domain/group_task_profile.dart';
import 'package:yildiz_kadro/features/postgame/presentation/season_complete_hub_screen.dart';
import 'package:yildiz_kadro/features/postgame/presentation/final_group_customization_screen.dart';
import 'package:yildiz_kadro/features/postgame/presentation/group_naming_screen.dart';
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
  complete,
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

  Widget intro() {
    final isEn = isAppEnglish(context);
    return page([
      Text(context.l10n.dayLabel(6), style: label()),
      Text(
        isEn ? 'GRAND FINAL' : 'BÜYÜK FİNAL',
        style: Theme.of(context).textTheme.titleLarge,
      ),
      const SizedBox(height: AppSpacing.md),
      Text(
        isEn
            ? 'Time to form the Star Lineup.'
            : "Yıldız Kadro'yu kurma zamanı.",
        style: Theme.of(context).textTheme.displayLarge,
      ),
      Text(
        isEn
            ? '7 finalists.\nA 5-member group.\nThe final choice is yours.'
            : '7 finalist.\n5 kişilik bir grup.\nSon karar senin.',
        style: Theme.of(context).textTheme.headlineSmall,
      ),
      const SizedBox(height: AppSpacing.sm),
      Text(
        isEn
            ? 'Scores will guide you.\nBut this time nobody will make the choice for you.'
            : 'Puanlar sana yol gösterecek.\nAma bu kez kimse senin yerine seçim yapmayacak.',
      ),
      const SizedBox(height: AppSpacing.xl),
      lineup(GameScope.of(context).day5FinalistIds),
      const SizedBox(height: AppSpacing.xl),
      AppButton(
        label: isEn ? 'START THE FINAL  ★ →' : 'FİNALİ BAŞLAT  ★ →',
        onPressed: () => go(_FinalPhase.backstage),
      ),
    ]);
  }

  Widget backstage() {
    final isEn = isAppEnglish(context);
    final ids = GameScope.of(context).day5FinalistIds.take(4).toList();
    return page([
      Text(isEn ? 'BACKSTAGE' : 'BACKSTAGE', style: label()),
      Text(
        isEn ? 'One last stage remains.' : 'Son bir sahne kaldı.',
        style: Theme.of(context).textTheme.displayLarge,
      ),
      ...ids.asMap().entries.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(top: AppSpacing.md),
              child: ContestantDialogueBubble(
                contestant: contestant(entry.value),
                text: backstageLine(entry.value, context),
                alignRight: entry.key.isOdd,
              ),
            ),
          ),
      const SizedBox(height: AppSpacing.xl),
      AppButton(
        label: isEn ? 'CHOOSE DEBUT DIRECTION' : 'DEBUT YÖNÜNÜ SEÇ',
        onPressed: () => go(_FinalPhase.direction),
      ),
    ]);
  }

  Widget directionChoice() {
    final isEn = isAppEnglish(context);
    return page([
      Text(
        isEn
            ? 'WHAT KIND OF GROUP SHOULD DEBUT?'
            : 'NASIL BİR GRUP ÇIKIŞ YAPSIN?',
        style: Theme.of(context).textTheme.displayLarge,
      ),
      const SizedBox(height: AppSpacing.lg),
      ...Day6DebutDirection.values.map(
        (value) => InkWell(
          onTap: () => setState(() => direction = value),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            margin: const EdgeInsets.only(bottom: AppSpacing.md),
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color:
                  direction == value ? AppColors.accentInk : AppColors.inkSoft,
              border: Border.all(
                color: direction == value
                    ? AppColors.accentBright
                    : AppColors.line,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  day6DirectionLabel(value),
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                Text(directionDescription(value, context)),
              ],
            ),
          ),
        ),
      ),
      if (direction != null) ...directionReactions(context),
      const SizedBox(height: AppSpacing.lg),
      AppButton(
        label: isEn ? 'REVIEW DEBUT DIRECTION' : 'DEBUT YÖNÜNÜ İNCELE',
        onPressed:
            direction == null ? null : () => go(_FinalPhase.directionConfirm),
      ),
    ]);
  }

  Widget directionConfirm() {
    final isEn = isAppEnglish(context);
    return page([
      Text(isEn ? 'DEBUT DIRECTION' : 'DEBUT YÖNÜ', style: label()),
      Text(
        day6DirectionLabel(direction!),
        style: Theme.of(context).textTheme.displayLarge,
      ),
      Text(
        isEn
            ? 'The final showcase will be staged with this creative vision.'
            : 'Final showcase bu yaratıcı doğrultuda hazırlanacak.',
      ),
      const SizedBox(height: AppSpacing.sm),
      Text(
        isEn
            ? 'This choice impacts showcase performance scores. It does not decide the final lineup.'
            : 'Bu seçim final performanslarını etkiler. Final kadroyu belirlemez.',
        style: Theme.of(context)
            .textTheme
            .bodySmall
            ?.copyWith(fontStyle: FontStyle.italic),
      ),
      const SizedBox(height: AppSpacing.xl),
      TextButton(
        onPressed: () => go(_FinalPhase.direction),
        child: Text(isEn ? 'CHANGE' : 'DEĞİŞTİR'),
      ),
      AppButton(
        label: isEn ? 'START SHOWCASE' : "SHOWCASE'İ BAŞLAT",
        onPressed: startShowcase,
      ),
    ]);
  }

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
    final isEn = isAppEnglish(context);
    const titles = ['OPENING', 'SPOTLIGHT', 'FINAL FORMATION'];
    return page([
      Text(isEn ? 'DEBUT SHOWCASE' : 'DEBUT SHOWCASE', style: label()),
      Text(
        titles[showcaseSegment],
        style: Theme.of(context).textTheme.displayLarge,
      ),
      const SizedBox(height: AppSpacing.xl),
      _stageFormation(showcaseSegment),
      const SizedBox(height: AppSpacing.lg),
      Text(
          switch (showcaseSegment) {
            0 => isEn
                ? 'Seven finalists on the same stage for the first time.'
                : 'Yedi finalist ilk kez aynı sahnede.',
            1 => isEn
                ? 'The lens captures every talent’s signature spotlight.'
                : 'Kamera her birinin imza anını yakalıyor.',
            _ => isEn
                ? 'Final formation. Final chord. Decision time.'
                : 'Son formasyon. Son nota. Karar zamanı.',
          },
          style: Theme.of(context).textTheme.headlineSmall),
      AppButton(
        label: showcaseSegment < 2
            ? (isEn ? 'NEXT SEGMENT' : 'SONRAKİ BÖLÜM')
            : (isEn ? 'SHOWCASE RESULTS' : 'SHOWCASE SONUÇLARI'),
        onPressed: () {
          if (showcaseSegment < 2) {
            setState(() => showcaseSegment++);
          } else {
            go(_FinalPhase.evaluation);
          }
        },
      ),
    ]);
  }

  Widget evaluation() {
    final isEn = isAppEnglish(context);
    return page([
      Text(
        isEn ? 'FINAL SHOWCASE CONCLUDED' : 'FINAL SHOWCASE TAMAMLANDI',
        style: Theme.of(context).textTheme.displayLarge,
      ),
      const Text('LIVE • STAR • DEBUT FIT'),
      const SizedBox(height: AppSpacing.lg),
      Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: result!.rankingIds.map(scoreCard).toList(),
      ),
      const SizedBox(height: AppSpacing.xl),
      AppButton(
        label: isEn ? 'NIGHT’S STANDOUTS' : 'GECENİN ÖNE ÇIKANLARI',
        onPressed: () => go(_FinalPhase.standout),
      ),
    ]);
  }

  Widget standout() {
    final isEn = isAppEnglish(context);
    return page([
      Text(isEn ? 'SHOWCASE STANDOUT' : 'SHOWCASE STANDOUT', style: label()),
      Text(
        isEn ? 'Night’s Top 3 Performers' : 'Gecenin en güçlü 3’ü',
        style: Theme.of(context).textTheme.displayLarge,
      ),
      Text(
        isEn
            ? 'Contestants with the highest final showcase evaluation.'
            : 'Bu gece en yüksek final değerlendirmesini alan isimler.',
      ),
      const SizedBox(height: AppSpacing.xl),
      lineup(result!.rankingIds.take(3).toList()),
      const SizedBox(height: AppSpacing.xl),
      AppButton(
        label: isEn ? 'REVEAL JURY RECOMMENDATION' : 'JÜRİ ÖNERİSİNİ AÇ',
        onPressed: () => go(_FinalPhase.recommendation),
      ),
    ]);
  }

  Widget recommendation() {
    final isEn = isAppEnglish(context);
    return page([
      Text(
        isEn ? 'JURY’S RECOMMENDED LINEUP' : 'JÜRİNİN ÖNERDİĞİ KADRO',
        style: Theme.of(context).textTheme.displayLarge,
      ),
      Text(
        isEn
            ? 'Factoring in both final showcase marks and ensemble synergy, the jury highlights this five.'
            : 'Final performansı ve grup dengesi birlikte değerlendirildiğinde sistem bu beşliyi öne çıkarıyor.',
      ),
      const SizedBox(height: AppSpacing.xl),
      lineup(result!.recommendedLineupIds),
      const SizedBox(height: AppSpacing.lg),
      Text(
        isEn ? 'THIS IS MERELY A RECOMMENDATION.' : 'BU YALNIZCA ÖNERİ.',
        style: label(),
      ),
      Text(
        isEn ? 'THE FINAL CALL IS YOURS.' : 'SON KARAR SENİN.',
        style: Theme.of(context).textTheme.headlineLarge,
      ),
      AppButton(
        label: isEn ? 'BUILD MY OWN LINEUP  ★ →' : 'KENDİ KADROMU KUR  ★ →',
        onPressed: () => go(_FinalPhase.selection),
      ),
    ]);
  }

  Widget selection() {
    final isEn = isAppEnglish(context);
    final state = GameScope.of(context);
    final balance = calculateLineupBalance(
      lineupIds: selected,
      first: state.evaluation1Results,
      day3: state.day3IconResultSnapshot!,
      day5: state.day5ResultSnapshot!,
    );
    final overlap =
        selected.where(result!.recommendedLineupIds.contains).length;
    return page([
      Text(isEn ? 'STAR LINEUP' : 'YILDIZ KADRO', style: label()),
      Text(
        isEn ? 'NOW BUILD YOUR LINEUP' : 'ŞİMDİ KADRONU KUR',
        style: Theme.of(context).textTheme.displayLarge,
      ),
      Text(
        isEn
            ? 'Choose 5 of the 7 finalists. The final roster is entirely up to you.'
            : '7 finalistten 5’ini seç. Bu kez son karar tamamen senin.',
      ),
      const SizedBox(height: AppSpacing.lg),
      Text(
        isEn
            ? '${selected.length} / 5 MEMBERS SELECTED'
            : '${selected.length} / 5 ÜYE SEÇİLDİ',
        style: Theme.of(context).textTheme.headlineSmall,
      ),
      slots(),
      const SizedBox(height: AppSpacing.lg),
      Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: state.day5FinalistIds.map(finalistTile).toList(),
      ),
      const SizedBox(height: AppSpacing.xl),
      Text(isEn ? 'LINEUP BALANCE' : 'KADRO DENGESİ', style: label()),
      balancePanel(balance),
      Text(
        identitySummary(balance, context),
        style: Theme.of(context).textTheme.titleLarge,
      ),
      Text(
        isEn
            ? '$overlap / 5 from jury recommendation'
            : 'Jüri önerisinden $overlap / 5',
        style: Theme.of(context).textTheme.bodySmall,
      ),
      const SizedBox(height: AppSpacing.xl),
      AppButton(
        label: isEn ? 'REVIEW MY LINEUP  ★ →' : 'KADROMU İNCELE  ★ →',
        onPressed: selected.length == 5 ? () => go(_FinalPhase.review) : null,
      ),
    ]);
  }

  Widget review() {
    final isEn = isAppEnglish(context);
    final state = GameScope.of(context);
    final balance = currentBalance(state);
    final assignments = currentRoles(state);
    final jury = selected.where(result!.recommendedLineupIds.contains).length;
    final radar =
        selected.where(state.playerRadarContestantIds.contains).length;
    return page([
      Text(
        isEn ? 'THIS IS YOUR STAR LINEUP' : 'BU SENİN YILDIZ KADRON',
        style: Theme.of(context).textTheme.displayLarge,
      ),
      lineup(selected),
      const SizedBox(height: AppSpacing.xl),
      Text(isEn ? 'LINEUP BALANCE' : 'KADRO DENGESİ', style: label()),
      balancePanel(balance),
      Text(isEn ? 'SUGGESTED ROLES' : 'ÖNERİLEN ROLLER', style: label()),
      ...FinalGroupRole.values.map(
        (role) => ListTile(
          dense: true,
          contentPadding: EdgeInsets.zero,
          title: Text(contestant(assignments[role]!).displayName),
          trailing: Text(finalRoleLabel(role), style: label()),
        ),
      ),
      metric(
        isEn ? 'MATCHING JURY PICK' : 'JÜRİ ÖNERİSİYLE ORTAK',
        '$jury / 5',
      ),
      metric(isEn ? 'FROM INITIAL RADAR' : 'İLK RADARINDAN', '$radar / 5'),
      metric(
        isEn ? 'LATER DISCOVERIES' : 'SONRADAN KEŞFETTİĞİN',
        isEn ? '${5 - radar} MEMBERS' : '${5 - radar} ÜYE',
      ),
      ContestantDialogueBubble(
        contestant: contestant(selected.first),
        text: isEn
            ? 'This five could be formidable on stage.'
            : 'Bu beşli sahnede güçlü olabilir.',
      ),
      const SizedBox(height: AppSpacing.lg),
      TextButton(
        onPressed: () => go(_FinalPhase.selection),
        child: Text(isEn ? 'CHANGE LINEUP' : 'KADROYU DEĞİŞTİR'),
      ),
      AppButton(
        label: isEn ? 'THIS IS MY LINEUP  ★' : 'YILDIZ KADROM BU  ★',
        onPressed: () => confirmSheet(balance, assignments),
      ),
    ]);
  }

  Future<void> confirmSheet(
    LineupBalance balance,
    Map<FinalGroupRole, int> assignments,
  ) async {
    final isEn = isAppEnglish(context);
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
              Text(
                isEn ? 'YOUR FINAL DECISION' : 'SON KARARIN',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              lineup(selected),
              const SizedBox(height: AppSpacing.md),
              Text(
                isEn
                    ? 'These five contestants will form the Star Lineup.\nThis choice concludes the season finale.'
                    : 'Bu beş yarışmacı Yıldız Kadro’yu oluşturacak.\nBu seçim sezon finalini belirleyecek.',
              ),
              const SizedBox(height: AppSpacing.lg),
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(isEn ? 'GO BACK' : 'GERİ DÖN'),
              ),
              AppButton(
                label: isEn ? 'YES, THIS IS MY LINEUP' : 'EVET, KADROM BU',
                onPressed: () => Navigator.pop(context, true),
              ),
            ],
          ),
        ),
      ),
    );
    if (accepted != true || !mounted) return;
    GameScope.of(context).confirmFinalLineup(
      contestantIds: selected,
      balance: balance,
      suggestedRoles: assignments,
    );
    final customized = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => const FinalGroupCustomizationScreen(),
      ),
    );
    if (customized != true || !mounted) return;
    final named = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(builder: (_) => const GroupNamingScreen()),
    );
    if (named != true || !mounted) return;
    setState(() {
      revealCount = 1;
      phase = _FinalPhase.transition;
    });
    Future<void>.delayed(const Duration(milliseconds: 1400), () {
      if (mounted && phase == _FinalPhase.transition) go(_FinalPhase.reveal);
    });
  }

  Widget transition() {
    final isEn = isAppEnglish(context);
    return Center(
      key: const ValueKey('final-transition'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(isEn ? 'SEASON COMPLETED' : 'SEZON TAMAMLANDI'),
          const SizedBox(height: AppSpacing.xl),
          Text(isEn ? 'STAR LINEUP' : 'YILDIZ KADRO'),
          const SizedBox(height: AppSpacing.sm),
          Text(isEn ? 'DEBUT LINEUP READY' : 'DEBUT KADROSU HAZIR'),
        ],
      ),
    );
  }

  Widget reveal() {
    final isEn = isAppEnglish(context);
    final visible = selected.take(revealCount).toList();
    return page([
      Text(isEn ? 'STAR LINEUP' : 'YILDIZ KADRO', style: label()),
      Text(
        revealCount < 5
            ? (isEn ? 'STAR LINEUP MEMBER' : 'YILDIZ KADRO ÜYESİ')
            : (isEn ? 'LINEUP COMPLETE' : 'KADRO TAMAMLANDI'),
        style: Theme.of(context).textTheme.displayLarge,
      ),
      const SizedBox(height: AppSpacing.xl),
      lineup(visible),
      if (revealCount < 5) ...[
        Text(historyBadge(visible.last, context), style: label()),
        AppButton(
          label: isEn ? 'NEXT MEMBER' : 'SONRAKİ ÜYE',
          onPressed: () {
            setState(() => revealCount++);
            if (revealCount == 5) {
              GameScope.of(context).completeFinalReveal();
            }
          },
        ),
      ] else ...[
        Text(
          isEn ? 'STAR LINEUP' : 'YILDIZ KADRO',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        AppButton(
          label: isEn ? 'REVEAL GROUP ROLES' : 'GRUP ROLLERİNİ AÇ',
          onPressed: () => go(_FinalPhase.roles),
        ),
      ],
    ]);
  }

  Widget roles() {
    final isEn = isAppEnglish(context);
    final state = GameScope.of(context);
    return page([
      Text(
        isEn ? 'ROLES WITHIN THE GROUP' : 'GRUP İÇİNDEKİ ROLLER',
        style: Theme.of(context).textTheme.displayLarge,
      ),
      ...FinalGroupRole.values.map(
        (role) => Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.inkSoft,
            border: Border.all(color: AppColors.line),
          ),
          child: Row(
            children: [
              ClipOval(
                child: SizedBox(
                  width: 58,
                  height: 58,
                  child: ContestantPortrait(
                    contestant: contestant(state.suggestedFinalRoles[role]!),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(finalRoleLabel(role), style: label()),
                    Text(
                      contestant(state.suggestedFinalRoles[role]!).displayName,
                    ),
                    Text(
                      roleDescription(role, context),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      Text(isEn ? 'GROUP PROFILE' : 'GRUP PROFİLİ', style: label()),
      Text(
        groupProfile(state.finalLineupBalance!, context),
        style: Theme.of(context).textTheme.headlineLarge,
      ),
      Text(identitySummary(state.finalLineupBalance!, context)),
      AppButton(
        label: isEn ? 'SEASON RECAP' : 'SEZON ÖZETİ',
        onPressed: () => go(_FinalPhase.recap),
      ),
    ]);
  }

  Widget recap() {
    final isEn = isAppEnglish(context);
    final state = GameScope.of(context);
    final radar =
        selected.where(state.playerRadarContestantIds.contains).length;
    final impact = [
      state.day2DuelResultSnapshot?.playerChangedOutcome ?? false,
      state.day3FinalCutResultSnapshot?.playerChangedOutcome ?? false,
      state.day4ResultSnapshot?.playerChangedRoomElimination ?? false,
      state.day5ResultSnapshot?.playerChangedCut ?? false,
    ].where((value) => value).length;
    return page([
      Text(
        isEn
            ? 'HOW DID YOU ARRIVE AT THIS LINEUP?'
            : 'BU KADROYA NASIL GELDİN?',
        style: Theme.of(context).textTheme.displayLarge,
      ),
      metric(
        isEn ? 'INITIAL RADAR' : 'İLK RADARIN',
        isEn
            ? 'Reached final lineup: $radar / 5'
            : 'Final kadrona giren: $radar / 5',
      ),
      if (state.producerSaveContestantId != null &&
          selected.contains(state.producerSaveContestantId))
        metric(
          isEn ? 'SAVED ON DAY 1' : 'İLK GÜN KORUDUĞUN',
          isEn
              ? '${contestant(state.producerSaveContestantId!).displayName} made it all the way to your final lineup.'
              : '${contestant(state.producerSaveContestantId!).displayName} final kadrona kadar geldi.',
        ),
      if (state.lastChanceCoachContestantId != null &&
          selected.contains(state.lastChanceCoachContestantId))
        metric(
          isEn ? 'COACHING IMPACT' : 'SAHNE NOTUN',
          isEn
              ? '${contestant(state.lastChanceCoachContestantId!).displayName} is now in the Star Lineup.'
              : '${contestant(state.lastChanceCoachContestantId!).displayName} şimdi Yıldız Kadro’da.',
        ),
      if (impact > 0)
        metric(
          isEn ? 'GENUINE IMPACT' : 'GERÇEK ETKİN',
          isEn
              ? 'Your decisions changed $impact elimination outcomes.'
              : '$impact eleme sonucunu verdiğin kararlar değiştirdi.',
        ),
      metric(
        isEn ? 'MATCHING JURY PICK' : 'JÜRİ ÖNERİSİYLE ORTAK',
        '${selected.where(result!.recommendedLineupIds.contains).length} / 5',
      ),
      const SizedBox(height: AppSpacing.xl),
      Text(
        isEn
            ? 'Scores carried them to the finale.'
            : 'Puanlar onları finale taşıdı.',
        style: Theme.of(context).textTheme.headlineSmall,
      ),
      Text(
        isEn ? 'You chose the final five.' : 'Son beşliyi sen seçtin.',
        style: Theme.of(context).textTheme.headlineLarge,
      ),
      AppButton(
        label: isEn ? 'COMPLETE FINALE' : 'FİNALİ TAMAMLA',
        onPressed: () => go(_FinalPhase.complete),
      ),
    ]);
  }

  Widget complete() {
    final isEn = isAppEnglish(context);
    final state = GameScope.of(context);
    final ids = state.playerFinalLineupIds;
    return page([
      Text(
        isEn ? 'STAR LINEUP' : 'YILDIZ KADRO',
        style: Theme.of(context).textTheme.displayLarge,
      ),
      lineup(ids),
      const SizedBox(height: AppSpacing.xl),
      Text(isEn ? 'SEASON COMPLETED' : 'SEZON TAMAMLANDI', style: label()),
      Text(
        isEn ? 'Your 5-member group is ready.' : '5 kişilik grubun hazır.',
        style: Theme.of(context).textTheme.headlineSmall,
      ),
      const SizedBox(height: AppSpacing.xl),
      AppButton(
        label: isEn ? 'REVIEW MY LINEUP' : 'KADROMU İNCELE',
        onPressed: () => go(_FinalPhase.roles),
      ),
      TextButton(
        onPressed: () => go(_FinalPhase.recap),
        child: Text(isEn ? 'VIEW SEASON' : 'SEZONU GÖR'),
      ),
      TextButton(
        onPressed: () => Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(
            builder: (_) => const SeasonCompleteHubScreen(),
          ),
        ),
        child: Text(isEn ? 'ADVANCE TO DEBUT HUB' : 'DEBUT HUB’A GEÇ'),
      ),
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
              color: isSelected ? AppColors.accentBright : AppColors.line,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: .82,
                child: ContestantPortrait(contestant: contestant(id)),
              ),
              Text(contestant(id).displayName, maxLines: 1),
              Text(
                groupRoleLabel(groupTaskProfiles[id]!.primaryRole),
                style: label(),
              ),
              Text('LIVE ${score.live}  STAR ${score.star}'),
              Text('FIT ${score.debutFit}'),
              if (state.playerRadarContestantIds.contains(id))
                Text(isAppEnglish(context) ? '★ INITIAL RADAR' : '★ İLK RADAR'),
              if (result!.recommendedLineupIds.contains(id))
                Text(isAppEnglish(context) ? 'JURY PICK' : 'JÜRİ ÖNERİSİ'),
              if (isSelected)
                Text(
                  isAppEnglish(context) ? '★ IN LINEUP' : '★ KADRODA',
                  style: label(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void toggle(int id) {
    if (selected.contains(id)) {
      setState(() => selected.remove(id));
      return;
    }
    if (selected.length == 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isAppEnglish(context)
                ? 'Your lineup has 5 members. Remove one first.'
                : 'Kadron 5 kişilik. Önce birini çıkar.',
          ),
          duration: const Duration(milliseconds: 1300),
        ),
      );
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
                        : AppColors.line,
                  ),
                ),
                child: index < selected.length
                    ? ContestantPortrait(
                        contestant: contestant(selected[index]))
                    : const Center(
                        child: Icon(
                          Icons.star_border_rounded,
                          color: AppColors.line,
                        ),
                      ),
              ),
            ),
          ),
        ),
      );
  Widget scoreCard(int id) {
    final score = result!.results[id]!;
    return InkWell(
      onTap: () => scoreDetails(id),
      child: SizedBox(
        width: 150,
        child: Column(
          children: [
            AspectRatio(
              aspectRatio: .82,
              child: ContestantPortrait(contestant: contestant(id)),
            ),
            Text(contestant(id).displayName),
            Text('LIVE ${score.live}'),
            Text('STAR ${score.star}'),
            Text('FIT ${score.debutFit}', style: label()),
          ],
        ),
      ),
    );
  }

  void scoreDetails(int id) {
    final score = result!.results[id]!;
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.inkSoft,
        title: Text(contestant(id).displayName),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            metric('LIVE', '${score.live}'),
            metric('STAR', '${score.star}'),
            metric('GROWTH', '${score.growth}'),
            metric('CONSISTENCY', '${score.consistency}'),
            metric('DEBUT FIT', '${score.debutFit}'),
          ],
        ),
      ),
    );
  }

  Widget balancePanel(LineupBalance value) {
    final isEn = isAppEnglish(context);
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        balanceItem(isEn ? 'VOCALS' : 'VOKAL', value.vocal),
        balanceItem(isEn ? 'DANCE' : 'DANS', value.dance),
        balanceItem(isEn ? 'STAGE' : 'SAHNE', value.stage),
        balanceItem(isEn ? 'CAMERA' : 'KAMERA', value.camera),
        balanceItem(isEn ? 'HARMONY' : 'UYUM', value.harmony),
      ],
    );
  }

  Widget balanceItem(String title, int score) => Container(
        width: 142,
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(border: Border.all(color: AppColors.line)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: label()),
            Text('$score — ${balanceLabel(score, context)}'),
          ],
        ),
      );
  Widget metric(String title, String value) => Container(
        width: double.infinity,
        margin: const EdgeInsets.only(top: AppSpacing.sm),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.inkSoft,
          border: Border.all(color: AppColors.line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: label()),
            Text(value),
          ],
        ),
      );
  Widget lineup(List<int> ids) => Wrap(
        spacing: 8,
        runSpacing: 10,
        children: ids
            .map(
              (id) => SizedBox(
                width: 104,
                child: Column(
                  children: [
                    AspectRatio(
                      aspectRatio: .72,
                      child: ContestantPortrait(contestant: contestant(id)),
                    ),
                    Text(
                      contestant(id).displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      );
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
          colors: [AppColors.inkSoft, AppColors.accentInk],
        ),
        border: Border.all(color: AppColors.line),
      ),
      child: Center(
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: segment == 2 ? 4 : 12,
          runSpacing: 12,
          children: ordered
              .map(
                (id) => SizedBox(
                  width: segment == 1 && result!.rankingIds.take(3).contains(id)
                      ? 88
                      : 68,
                  child: Column(
                    children: [
                      ClipOval(
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: ContestantPortrait(contestant: contestant(id)),
                        ),
                      ),
                      Text(
                        contestant(id).displayName,
                        maxLines: 1,
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  Widget page(List<Widget> children) => SingleChildScrollView(
        key: ValueKey(phase),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: MaxWidthContainer(
          maxWidth: 850,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      );
  TextStyle label() => Theme.of(context)
      .textTheme
      .labelLarge!
      .copyWith(color: AppColors.accentBright, letterSpacing: 1.1);

  LineupBalance currentBalance(dynamic state) => calculateLineupBalance(
        lineupIds: selected,
        first: state.evaluation1Results,
        day3: state.day3IconResultSnapshot!,
        day5: state.day5ResultSnapshot!,
      );
  Map<FinalGroupRole, int> currentRoles(dynamic state) => assignSuggestedRoles(
        lineupIds: selected,
        finalResult: result!,
        first: state.evaluation1Results,
        day3: state.day3IconResultSnapshot!,
        day4: state.day4ResultSnapshot!,
        day5: state.day5ResultSnapshot!,
      );
  List<Widget> directionReactions([BuildContext? ctx]) {
    final isEn = isAppEnglish(ctx);
    final ids = GameScope.of(context).day5FinalistIds.take(2).toList();
    return ids
        .asMap()
        .entries
        .map(
          (entry) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: ContestantDialogueBubble(
              contestant: contestant(entry.value),
              text: direction == Day6DebutDirection.performanceUnit
                  ? (isEn
                      ? 'This is tailor-made for my final.'
                      : 'Tam benim finalim.')
                  : direction == Day6DebutDirection.iconGroup
                      ? (isEn
                          ? 'I know exactly how to play this.'
                          : 'Bunu nasıl oynayacağımı biliyorum.')
                      : (isEn
                          ? 'I will make my voice heard across this stage.'
                          : 'Sesimi bu sahnede duyuracağım.'),
              alignRight: entry.key.isOdd,
            ),
          ),
        )
        .toList();
  }

  String backstageLine(int id, [BuildContext? ctx]) {
    final isEn = isAppEnglish(ctx);
    return switch (groupTaskProfiles[id]!.workStyle) {
      WorkStyle.bold => isEn
          ? 'I am here to claim a spot in the final five.'
          : 'Beşin içine girmek için buradayım.',
      WorkStyle.calm => isEn
          ? 'I did all I could. Just one final stage left.'
          : 'Artık elimden geleni yaptım. Son bir sahne kaldı.',
      WorkStyle.competitive => isEn
          ? 'I made it to the finale. I refuse to stop here.'
          : 'Finale kadar geldim. Burada durmak istemiyorum.',
      WorkStyle.playful => isEn
          ? 'Now the real debut group comes together.'
          : 'Şimdi gerçekten grup kuruluyor.',
      WorkStyle.cameraSavvy => isEn
          ? 'When that red light hits one last time, I’ll be ready.'
          : 'Son kez kamera açıldığında hazır olacağım.',
      _ => isEn
          ? 'I worked the entire season for this very stage.'
          : 'Bu sahne için bütün sezon çalıştım.',
    };
  }

  String directionDescription(Day6DebutDirection value, [BuildContext? ctx]) {
    final isEn = isAppEnglish(ctx);
    return switch (value) {
      Day6DebutDirection.popPower => isEn
          ? 'Anthemic hooks, powerhouse vocals, and balanced stage presence.'
          : 'Büyük nakaratlar, güçlü vokal, dengeli performans.',
      Day6DebutDirection.performanceUnit => isEn
          ? 'Precision choreography, stage authority, and explosive energy.'
          : 'Koreografi, sahne gücü ve yüksek enerji.',
      Day6DebutDirection.iconGroup => isEn
          ? 'Camera magnetism, distinct identity, and unforgettable star quality.'
          : 'Kamera, kimlik ve unutulmaz yıldız etkisi.',
    };
  }

  String groupRoleLabel(GroupRole role) => switch (role) {
        GroupRole.vocal => 'VOCAL',
        GroupRole.dance => 'DANCE',
        GroupRole.stage => 'STAGE',
        GroupRole.allRounder => 'ALL-ROUNDER',
      };
  String balanceLabel(int score, [BuildContext? ctx]) {
    final isEn = isAppEnglish(ctx);
    return score >= 90
        ? (isEn ? 'EXCELLENT' : 'ÇOK GÜÇLÜ')
        : score >= 84
            ? (isEn ? 'STRONG' : 'GÜÇLÜ')
            : score >= 78
                ? (isEn ? 'BALANCED' : 'DENGELİ')
                : score >= 72
                    ? (isEn ? 'VULNERABLE' : 'RİSKLİ')
                    : (isEn ? 'WEAK SPOT' : 'ZAYIF NOKTA');
  }

  String identitySummary(LineupBalance b, [BuildContext? ctx]) {
    final isEn = isAppEnglish(ctx);
    final values = {
      'vokal': b.vocal,
      'dans': b.dance,
      'sahne': b.stage,
      'kamera': b.camera,
    };
    final best =
        values.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
    if (values.values.reduce((a, b) => a > b ? a : b) -
            values.values.reduce((a, b) => a < b ? a : b) <=
        5) {
      return isEn
          ? 'A balanced and versatile quintet.'
          : 'Dengeli ve çok yönlü bir beşli.';
    }
    return switch (best) {
      'vokal' => isEn
          ? 'Vocal-centered group with immense live command.'
          : 'Canlı performansta güçlü, vokal merkezli bir grup.',
      'dans' => isEn
          ? 'Performance-driven group with outstanding movement power.'
          : 'Performans odaklı, hareket gücü yüksek bir kadro.',
      'kamera' => isEn
          ? 'Visual and camera-commanding powerhouse lineup.'
          : 'Görsel ve kamera kimliği çok güçlü bir kadro.',
      _ => isEn
          ? 'Electrifying stage presence with massive crowd command.'
          : 'Sahne gücü yüksek, etkili bir kadro.',
    };
  }

  String groupProfile(LineupBalance b, [BuildContext? ctx]) {
    final isEn = isAppEnglish(ctx);
    if ((b.vocal - b.dance).abs() < 5 && (b.stage - b.camera).abs() < 5) {
      return isEn ? 'BALANCED QUINTET' : 'DENGELİ BEŞLİ';
    }
    if (b.camera >= b.vocal && b.camera >= b.dance) {
      return isEn ? 'ICONIC POP' : 'İKONİK POP';
    }
    if (b.dance >= b.vocal) {
      return isEn ? 'PERFORMANCE UNIT' : 'PERFORMANS ODAKLI';
    }
    return isEn ? 'LIVE STAGE GROUP' : 'CANLI SAHNE GRUBU';
  }

  String roleDescription(FinalGroupRole role, [BuildContext? ctx]) {
    final isEn = isAppEnglish(ctx);
    return switch (role) {
      FinalGroupRole.mainVocal => isEn
          ? 'Live vocal backbone of the ensemble.'
          : 'Grubun canlı vokal omurgası.',
      FinalGroupRole.center => isEn
          ? 'Camera and stage nucleus of the formation.'
          : 'Formasyonun kamera ve sahne merkezi.',
      FinalGroupRole.performanceLead => isEn
          ? 'Carries choreography and athletic stage voltage.'
          : 'Koreografi ve performans enerjisini taşır.',
      FinalGroupRole.allRounder => isEn
          ? 'Balances harmony across all distinct disciplines.'
          : 'Farklı alanlar arasında denge kurar.',
      FinalGroupRole.starVisual => isEn
          ? 'Anchors the visual identity and camera charisma.'
          : 'Grubun görsel ve kamera kimliğini taşır.',
    };
  }

  String historyBadge(int id, [BuildContext? ctx]) {
    final isEn = isAppEnglish(ctx);
    final state = GameScope.of(context);
    if (state.playerRadarContestantIds.contains(id)) {
      return isEn ? '★ INITIAL RADAR' : '★ İLK RADARINDA';
    }
    if (state.day4ResultSnapshot!.winnerByRoom.values.contains(id)) {
      return isEn ? '★ POSITION BATTLE WINNER' : '★ POZİSYON SAVAŞI GALİBİ';
    }
    if (state.day5ResultSnapshot!.rankingIds.first == id) {
      return isEn ? '★ LIVE BROADCAST STAR' : '★ CANLI YAYIN YILDIZI';
    }
    return isEn ? '★ GRAND FINALIST' : '★ BÜYÜK FİNALİST';
  }
}
