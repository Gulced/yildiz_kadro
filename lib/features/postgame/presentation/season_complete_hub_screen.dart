import 'package:flutter/material.dart';
import 'package:yildiz_kadro/app/theme/app_colors.dart';
import 'package:yildiz_kadro/app/theme/app_spacing.dart';
import 'package:yildiz_kadro/features/contestants/data/contestant_seed_data.dart';
import 'package:yildiz_kadro/features/contestants/domain/contestant.dart';
import 'package:yildiz_kadro/features/contestants/presentation/widgets/contestant_portrait.dart';
import 'package:yildiz_kadro/features/game/application/game_scope.dart';
import 'package:yildiz_kadro/features/game/application/game_state.dart';
import 'package:yildiz_kadro/features/group_task/data/group_task_profiles.dart';
import 'package:yildiz_kadro/features/group_task/domain/day4_position_result.dart';
import 'package:yildiz_kadro/features/group_task/domain/day6_final_result.dart';
import 'package:yildiz_kadro/features/group_task/domain/group_task_profile.dart';
import 'package:yildiz_kadro/features/home/presentation/home_screen.dart';
import 'package:yildiz_kadro/features/postgame/presentation/widgets/debut_lineup_poster.dart';
import 'package:yildiz_kadro/shared/widgets/app_button.dart';
import 'package:yildiz_kadro/shared/widgets/contestant_dialogue_bubble.dart';
import 'package:yildiz_kadro/shared/widgets/max_width_container.dart';

class SeasonCompleteHubScreen extends StatelessWidget {
  const SeasonCompleteHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = GameScope.of(context);
    _validateSeason(state);
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.ink,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: MaxWidthContainer(
              maxWidth: 900,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DebutLineupPoster(memberIds: state.playerFinalLineupIds),
                    const SizedBox(height: AppSpacing.lg),
                    Text('YILDIZ KADRO HAZIR',
                        style: Theme.of(context).textTheme.displayLarge),
                    const Text(
                        '15 kişiyle başladı. 5 kişiyle sahneye çıkıyor.'),
                    const SizedBox(height: AppSpacing.md),
                    Text(groupProfile(state.finalLineupBalance!),
                        style: _accent(context)),
                    const SizedBox(height: AppSpacing.xl),
                    Text('BU KADROYU SEN KURDUN', style: _accent(context)),
                    Text(
                        'Yarışma onları finale taşıdı. Son beşliyi sen seçtin.',
                        style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: AppSpacing.xl),
                    _HubButton(
                        label: 'KADROM',
                        subtitle: 'Grup profili ve roller',
                        onTap: () =>
                            _open(context, const _GroupProfileScreen())),
                    _HubButton(
                        label: 'SEZONUM',
                        subtitle: '6 günde verdiğin kararlar',
                        onTap: () =>
                            _open(context, const _SeasonRecapScreen())),
                    _HubButton(
                        label: 'YOLCULUK',
                        subtitle: '15 yarışmacının sezon arşivi',
                        onTap: () =>
                            _open(context, const _SeasonJourneyScreen())),
                    _HubButton(
                        label: 'YENİ SEZON',
                        subtitle: 'Bu kez kimi farklı göreceksin?',
                        onTap: () => _confirmReset(context)),
                  ]),
            ),
          ),
        ),
      ),
    );
  }

  static void _open(BuildContext context, Widget screen) =>
      Navigator.of(context)
          .push(MaterialPageRoute<void>(builder: (_) => screen));

  Future<void> _confirmReset(BuildContext context) async {
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
                      Text('YENİ SEZON BAŞLATILSIN MI?',
                          style: Theme.of(context).textTheme.headlineLarge),
                      const Text('Mevcut sezon sonuçların sıfırlanacak.'),
                      const SizedBox(height: AppSpacing.lg),
                      TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('VAZGEÇ')),
                      AppButton(
                          label: 'YENİ SEZON BAŞLAT',
                          onPressed: () => Navigator.pop(context, true)),
                    ]))));
    if (confirmed != true || !context.mounted) return;
    GameScope.of(context).resetSeason();
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(builder: (_) => const _NewSeasonTransition()),
        (_) => false);
  }
}

class _NewSeasonTransition extends StatefulWidget {
  const _NewSeasonTransition();
  @override
  State<_NewSeasonTransition> createState() => _NewSeasonTransitionState();
}

class _NewSeasonTransitionState extends State<_NewSeasonTransition> {
  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute<void>(builder: (_) => const HomeScreen()));
      }
    });
  }

  @override
  Widget build(BuildContext context) => const Scaffold(
      backgroundColor: AppColors.ink,
      body: SafeArea(
          child: Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text('YENİ SEZON'),
        SizedBox(height: AppSpacing.md),
        Text('Bu kez kimi farklı göreceksin?')
      ]))));
}

class _GroupProfileScreen extends StatelessWidget {
  const _GroupProfileScreen();
  @override
  Widget build(BuildContext context) {
    final state = GameScope.of(context), balance = state.finalLineupBalance!;
    final entries = {
      'VOKAL': balance.vocal,
      'DANS': balance.dance,
      'SAHNE': balance.stage,
      'KAMERA': balance.camera,
      'UYUM': balance.harmony
    };
    final strongest =
            entries.entries.reduce((a, b) => a.value >= b.value ? a : b),
        developing =
            entries.entries.reduce((a, b) => a.value <= b.value ? a : b);
    return _PostgameScaffold(title: 'GRUP PROFİLİ', children: [
      Text(groupProfile(balance),
          style: Theme.of(context).textTheme.displayLarge),
      DebutLineupPoster(memberIds: state.playerFinalLineupIds, height: 310),
      const SizedBox(height: AppSpacing.xl),
      ...entries.entries.map(
          (entry) => _EditorialMeter(label: entry.key, value: entry.value)),
      const SizedBox(height: AppSpacing.xl),
      _InfoBlock(
          label: 'GRUBUN İMZASI',
          value: strongest.key,
          body:
              '${strongest.key.toLowerCase()} gücü bu beşlinin en belirgin ortak imzası.'),
      _InfoBlock(
          label: 'GELİŞTİRİLECEK ALAN',
          value: developing.key,
          body:
              'Grubun diğer alanlarına göre daha fazla birlikte çalışma isteyecek.'),
      _InfoBlock(
          label: 'GRUP KİMYASI', value: chemistry(balance.harmony), body: ''),
      const SizedBox(height: AppSpacing.xl),
      Text('ÖNERİLEN ROLLER', style: _accent(context)),
      ...FinalGroupRole.values.map((role) {
        final id = state.suggestedFinalRoles[role]!;
        return ListTile(
            contentPadding: EdgeInsets.zero,
            leading: ClipOval(
                child: SizedBox(
                    width: 48,
                    height: 48,
                    child: ContestantPortrait(contestant: _contestant(id)))),
            title: Text(_contestant(id).displayName),
            subtitle: Text(finalRoleLabel(role)));
      }),
      const SizedBox(height: AppSpacing.xl),
      Text('İLK GRUP ANI', style: _accent(context)),
      ..._groupDialogue(state).asMap().entries.map((entry) => Padding(
          padding: const EdgeInsets.only(top: AppSpacing.sm),
          child: ContestantDialogueBubble(
              contestant: _contestant(entry.value.$1),
              text: entry.value.$2,
              alignRight: entry.key.isOdd))),
    ]);
  }
}

class _SeasonRecapScreen extends StatelessWidget {
  const _SeasonRecapScreen();
  @override
  Widget build(BuildContext context) {
    final state = GameScope.of(context),
        lineup = state.playerFinalLineupIds,
        radarCount =
            lineup.where(state.playerRadarContestantIds.contains).length,
        cards = <Widget>[];
    final impact = [
      state.day2DuelResultSnapshot?.playerChangedOutcome ?? false,
      state.day3FinalCutResultSnapshot?.playerChangedOutcome ?? false,
      state.day4ResultSnapshot?.playerChangedRoomElimination ?? false,
      state.day5ResultSnapshot?.playerChangedCut ?? false
    ].where((value) => value).length;
    if (impact > 0) {
      cards.add(_RecapCard(
          title: 'KARARLARIN',
          value: '$impact kritik sonucu gerçekten değiştirdi.'));
    }
    cards.add(_RecapCard(
        title: 'İLK RADARIN',
        value:
            'Final kadrona giren: $radarCount / 5\nSonradan keşfettiğin: ${5 - radarCount} üye',
        portraits: state.playerRadarContestantIds));
    final producer = state.producerSaveContestantId;
    if (producer != null && lineup.contains(producer)) {
      cards.add(_RecapCard(
          title: 'İLK GÜN KORUDUĞUN',
          value:
              '${_contestant(producer).displayName}, debut kadrosuna kadar geldi.',
          portraits: [producer]));
    }
    final coached = state.lastChanceCoachContestantId;
    if (coached != null && lineup.contains(coached)) {
      cards.add(_RecapCard(
          title: "SON ŞANS'TA DESTEKLEDİĞİN",
          value: '${_contestant(coached).displayName} şimdi Yıldız Kadro’da.',
          portraits: [coached]));
    }
    final captains = [state.day2CaptainAId, state.day2CaptainBId]
        .whereType<int>()
        .where(lineup.contains)
        .toList();
    if (captains.isNotEmpty) {
      cards.add(_RecapCard(
          title: 'KAPTAN SEÇİMİN',
          value: captains.length == 2
              ? 'Seçtiğin iki kaptan da Yıldız Kadro’da.'
              : '${_contestant(captains.first).displayName} final kadrona girdi.',
          portraits: captains));
    }
    final directed = state
        .day3IdentitySetupSnapshot!.creativeDirectionByContestantId.keys
        .where(lineup.contains)
        .toList();
    if (directed.isNotEmpty) {
      cards.add(_RecapCard(
          title: 'YARATICI SÜRECİNE DOKUNDUĞUN',
          value: '${directed.length} / 3 yarışmacı final grubunda.',
          portraits: directed));
    }
    final jury = lineup.where(state.recommendedFinalLineupIds.contains).length;
    cards.add(_RecapCard(
        title: 'JÜRİ ÖNERİSİYLE ORTAK',
        value:
            '$jury / 5\n${jury == 5 ? 'Jürinin önerdiği beşliyi aynen seçtin.' : jury >= 3 ? 'Bazı noktalarda jüriyle aynı düşündün.' : 'Final kadroda kendi yolunu seçtin.'}'));
    final discovered = lineup
        .where((id) => !state.playerRadarContestantIds.contains(id))
        .toList()
      ..sort((a, b) => state.day6ResultSnapshot!.results[b]!.growth
          .compareTo(state.day6ResultSnapshot!.results[a]!.growth));
    if (discovered.isNotEmpty) {
      cards.insert(
          minOf(cards.length, 3),
          _RecapCard(
              title: 'SENİ FİKRİNDEN DÖNDÜREN',
              value:
                  '${_contestant(discovered.first).displayName}\nİlk radarında değildi. Final kadrona girdi.',
              portraits: [discovered.first]));
    }
    return _PostgameScaffold(
        title: '6 GÜNDE NE DEĞİŞTİ?', children: cards.take(6).toList());
  }
}

class _SeasonJourneyScreen extends StatelessWidget {
  const _SeasonJourneyScreen();
  @override
  Widget build(BuildContext context) {
    final state = GameScope.of(context);
    return _PostgameScaffold(title: 'SEZON YOLCULUĞU', children: [
      _JourneySection(
          title: 'YILDIZ KADRO — 5',
          ids: state.playerFinalLineupIds,
          state: state,
          debut: true),
      _JourneySection(
          title: 'FİNALİST — 2',
          ids: state.finalistsOutsideDebutLineupIds,
          state: state,
          finalist: true),
      _JourneySection(
          title: 'VEDA EDENLER — 8',
          ids: state.eliminatedContestantIds,
          state: state),
    ]);
  }
}

class _JourneySection extends StatelessWidget {
  const _JourneySection(
      {required this.title,
      required this.ids,
      required this.state,
      this.debut = false,
      this.finalist = false});
  final String title;
  final List<int> ids;
  final GameState state;
  final bool debut;
  final bool finalist;
  @override
  Widget build(BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SizedBox(height: AppSpacing.xl),
        Text(title, style: _accent(context)),
        ...ids.map((id) => InkWell(
            onTap: () => _showHistory(context, id, state),
            child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                child: Row(children: [
                  ClipOval(
                      child: SizedBox(
                          width: 58,
                          height: 58,
                          child:
                              ContestantPortrait(contestant: _contestant(id)))),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Text(_contestant(id).displayName),
                        Text(
                            debut
                                ? finalRoleLabel(state
                                    .suggestedFinalRoles.entries
                                    .firstWhere((entry) => entry.value == id)
                                    .key)
                                : finalist
                                    ? 'FİNALİST • Debut kadrosuna giremedi.'
                                    : eliminationPoint(id, state),
                            style: Theme.of(context).textTheme.bodySmall)
                      ])),
                  const Icon(Icons.arrow_forward_ios_rounded, size: 14)
                ]))))
      ]);
}

class _PostgameScaffold extends StatelessWidget {
  const _PostgameScaffold({required this.title, required this.children});
  final String title;
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => Scaffold(
      backgroundColor: AppColors.ink,
      body: SafeArea(
          child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: MaxWidthContainer(
                  maxWidth: 850,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.arrow_back_rounded)),
                        Text(title, style: _accent(context)),
                        const SizedBox(height: AppSpacing.lg),
                        ...children
                      ])))));
}

class _HubButton extends StatelessWidget {
  const _HubButton(
      {required this.label, required this.subtitle, required this.onTap});
  final String label, subtitle;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkWell(
      onTap: onTap,
      child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          child: Row(children: [
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(label, style: Theme.of(context).textTheme.headlineSmall),
                  Text(subtitle, style: Theme.of(context).textTheme.bodySmall)
                ])),
            const Icon(Icons.arrow_forward_rounded)
          ])));
}

class _EditorialMeter extends StatelessWidget {
  const _EditorialMeter({required this.label, required this.value});
  final String label;
  final int value;
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(label, style: _accent(context))),
          Text('$value / ${balanceLabel(value)}')
        ]),
        const SizedBox(height: 7),
        ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
                value: value / 100,
                minHeight: 5,
                backgroundColor: AppColors.line,
                color: AppColors.accentBright))
      ]));
}

class _InfoBlock extends StatelessWidget {
  const _InfoBlock(
      {required this.label, required this.value, required this.body});
  final String label, value, body;
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: _accent(context)),
        Text(value, style: Theme.of(context).textTheme.headlineSmall),
        if (body.isNotEmpty) Text(body)
      ]));
}

class _RecapCard extends StatelessWidget {
  const _RecapCard(
      {required this.title, required this.value, this.portraits = const []});
  final String title, value;
  final List<int> portraits;
  @override
  Widget build(BuildContext context) => Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: const BoxDecoration(color: AppColors.inkSoft),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: _accent(context)),
        if (portraits.isNotEmpty)
          Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Wrap(
                  spacing: 5,
                  children: portraits
                      .map((id) => ClipOval(
                          child: SizedBox(
                              width: 45,
                              height: 45,
                              child: ContestantPortrait(
                                  contestant: _contestant(id)))))
                      .toList())),
        Text(value, style: Theme.of(context).textTheme.titleLarge)
      ]));
}

Contestant _contestant(int id) =>
    contestantSeedData.firstWhere((value) => value.id == id);
TextStyle _accent(BuildContext context) => Theme.of(context)
    .textTheme
    .labelLarge!
    .copyWith(color: AppColors.accentBright, letterSpacing: 1.1);
int minOf(int a, int b) => a < b ? a : b;
String balanceLabel(int score) => score >= 90
    ? 'ÇOK GÜÇLÜ'
    : score >= 84
        ? 'GÜÇLÜ'
        : score >= 78
            ? 'DENGELİ'
            : score >= 72
                ? 'RİSKLİ'
                : 'GELİŞİYOR';
String groupProfile(LineupBalance b) {
  final values = [b.vocal, b.dance, b.stage, b.camera];
  if (values.reduce((a, b) => a > b ? a : b) -
          values.reduce((a, b) => a < b ? a : b) <=
      5) {
    return 'DENGELİ BEŞLİ';
  }
  if (b.camera == values.reduce((a, b) => a > b ? a : b)) {
    return 'İKONİK POP';
  }
  if (b.dance == values.reduce((a, b) => a > b ? a : b)) {
    return 'PERFORMANS ODAKLI';
  }
  if (b.vocal == values.reduce((a, b) => a > b ? a : b)) {
    return 'VOKAL GÜCÜ';
  }
  return 'SAHNE GÜCÜ';
}

String chemistry(int harmony) => harmony >= 88
    ? 'Rolleri birbirini tamamlayan dengeli bir beşli.'
    : harmony >= 78
        ? 'Farklı karakterleri aynı sahnede buluşturan bir grup.'
        : 'Güçlü kişiliklerden oluşuyor. Uyum çalışıldıkça daha da büyüyebilir.';
List<(int, String)> _groupDialogue(GameState state) {
  final ids = state.playerFinalLineupIds.toList()
    ..sort((a, b) => a.compareTo(b));
  return ids.take(3).map((id) {
    final style = groupTaskProfiles[id]!.workStyle;
    final text = switch (style) {
      WorkStyle.playful => 'İlk prova ne zaman? Bugün değilse iyi.',
      WorkStyle.competitive => 'Final bitti diye çalışma bitmedi.',
      WorkStyle.calm => 'Önce bir nefes alalım.',
      WorkStyle.bold => 'İlk sahnemiz daha büyük olsun.',
      WorkStyle.social => 'Önce birlikte bir şey yiyelim.',
      WorkStyle.cameraSavvy => 'İlk grup çekimimizi istiyorum.',
      _ => 'Şimdi gerçekten aynı takımdayız.'
    };
    return (id, text);
  }).toList();
}

String eliminationPoint(int id, GameState state) {
  if (state.day2EliminatedContestantId == id) return '2. GÜN — DÜELLO';
  if (state.day3FinalCutResultSnapshot?.eliminatedContestantId == id) {
    return '3. GÜN — FINAL CUT';
  }
  if (state.day4ResultSnapshot?.eliminatedIds.contains(id) ?? false) {
    final room = state.day4ResultSnapshot!.results[id]!.room;
    return '4. GÜN — ${day4RoomLabel(room)}';
  }
  if (state.day5EliminatedContestantIds.contains(id)) {
    return '5. GÜN — STAR LIVE';
  }
  return '1. GÜN — SON ŞANS';
}

void _showHistory(BuildContext context, int id, GameState state) {
  final c = _contestant(id), evaluation = state.evaluation1Results[id];
  showModalBottomSheet<void>(
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
                    Row(children: [
                      ClipOval(
                          child: SizedBox(
                              width: 72,
                              height: 72,
                              child: ContestantPortrait(contestant: c))),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                          child: Text(c.displayName,
                              style: Theme.of(context).textTheme.headlineLarge))
                    ]),
                    const SizedBox(height: AppSpacing.lg),
                    Text('İLK DEĞERLENDİRME', style: _accent(context)),
                    Text(evaluation == null
                        ? 'Kayıt yok'
                        : 'VOKAL ${evaluation.vocal} • DANS ${evaluation.dance} • SAHNE ${evaluation.stage}'),
                    if (state.playerRadarContestantIds.contains(id))
                      const Text('★ İlk radarındaydı.'),
                    if (state.producerSaveContestantId == id)
                      const Text('★ Yapımcı tarafından korundu.'),
                    const SizedBox(height: AppSpacing.md),
                    Text(state.playerFinalLineupIds.contains(id)
                        ? 'YILDIZ KADRO ÜYESİ'
                        : state.day5FinalistIds.contains(id)
                            ? 'FİNALİST • Debut kadrosuna giremedi.'
                            : eliminationPoint(id, state))
                  ]))));
}

void _validateSeason(GameState state) {
  final debut = state.playerFinalLineupIds.toSet(),
      finalists = state.day5FinalistIds.toSet(),
      outside = state.finalistsOutsideDebutLineupIds.toSet(),
      eliminated = state.eliminatedContestantIds.toSet(),
      roles = state.suggestedFinalRoles.values.toSet();
  final valid = state.seasonCompleted &&
      debut.length == 5 &&
      finalists.length == 7 &&
      finalists.containsAll(debut) &&
      outside.length == 2 &&
      outside.intersection(debut).isEmpty &&
      eliminated.length == 8 &&
      {...debut, ...outside, ...eliminated}.length == 15 &&
      roles.length == 5 &&
      roles.containsAll(debut);
  if (!valid) throw StateError('Tamamlanmış sezon verisi geçersiz.');
}
