import 'package:flutter/material.dart';
import 'package:yildiz_kadro/app/theme/app_colors.dart';
import 'package:yildiz_kadro/app/theme/app_spacing.dart';
import 'package:yildiz_kadro/features/contestants/data/contestant_seed_data.dart';
import 'package:yildiz_kadro/features/contestants/domain/contestant.dart';
import 'package:yildiz_kadro/features/contestants/presentation/widgets/contestant_portrait.dart';
import 'package:yildiz_kadro/features/game/application/game_scope.dart';
import 'package:yildiz_kadro/features/group_task/data/day4_position_engine.dart';
import 'package:yildiz_kadro/features/group_task/domain/day4_position_result.dart';
import 'package:yildiz_kadro/features/group_task/presentation/day5_live_show_screen.dart';
import 'package:yildiz_kadro/shared/widgets/app_button.dart';
import 'package:yildiz_kadro/shared/widgets/contestant_dialogue_bubble.dart';
import 'package:yildiz_kadro/shared/widgets/max_width_container.dart';

enum _Phase { intro, reveal, rooms, mentor, choice, result, summary }

class Day4PositionBattleScreen extends StatefulWidget {
  const Day4PositionBattleScreen({super.key});
  @override
  State<Day4PositionBattleScreen> createState() => _State();
}

class _State extends State<Day4PositionBattleScreen> {
  _Phase phase = _Phase.intro;
  int roomIndex = 0;
  Day4Room? selected;
  Day4MentorChoice? choice;
  Day4ResultSnapshot? result;
  bool initializationScheduled = false;
  Contestant c(int id) => contestantSeedData.firstWhere((x) => x.id == id);
  void go(_Phase p) => setState(() => phase = p);
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final s = GameScope.of(context);
    if (s.day4RoomAllocation == null && !initializationScheduled) {
      initializationScheduled = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final game = GameScope.of(context);
        final day2 = game.day2GroupPerformanceSnapshot;
        final day3 = game.day3IconResultSnapshot;
        if (game.day4RoomAllocation != null || day2 == null || day3 == null) {
          return;
        }
        final ids = contestantSeedData
            .where((c) => !game.eliminatedContestantIds.contains(c.id))
            .map((c) => c.id)
            .toList();
        game.initializeDay4Rooms(allocateDay4Rooms(
          activeIds: ids,
          first: game.evaluation1Results,
          day2: day2,
          day3: day3,
        ));
      });
    }
    if (s.day4Completed) {
      result = s.day4ResultSnapshot;
      phase = _Phase.summary;
    }
  }

  void start() {
    final s = GameScope.of(context);
    s.lockDay4MentorRoom(selected!);
    result = calculateDay4Results(
        allocation: s.day4RoomAllocation!,
        mentorRoom: selected!,
        mentorChoice: choice!,
        first: s.evaluation1Results,
        day2: s.day2GroupPerformanceSnapshot!,
        day3: s.day3IconResultSnapshot!);
    s.completeDay4(result!);
    roomIndex = 0;
    go(_Phase.result);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      backgroundColor: AppColors.ink,
      body: SafeArea(
          child: GameScope.of(context).day4RoomAllocation == null
              ? const Center(child: CircularProgressIndicator())
              : AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  child: switch (phase) {
                    _Phase.intro => intro(),
                    _Phase.reveal => reveal(),
                    _Phase.rooms => rooms(),
                    _Phase.mentor => mentor(),
                    _Phase.choice => coaching(),
                    _Phase.result => roomResult(),
                    _Phase.summary => summary()
                  })));
  Widget intro() => page([
        Text('4. GÜN', style: label()),
        Text('POZİSYON SAVAŞI',
            style: Theme.of(context).textTheme.displayLarge),
        Text('Artık herkes kendi güçlü alanında yarışacak.',
            style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: AppSpacing.xl),
        ...Day4Room.values.map((r) => zone(r)),
        Text('12 yarışmacı. 3 oda. Her odadan bir veda.',
            style: Theme.of(context).textTheme.bodyLarge),
        Text('Bu kez rakibin, seninle aynı şeyi iyi yapan biri.',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(fontStyle: FontStyle.italic)),
        const SizedBox(height: AppSpacing.xl),
        AppButton(label: 'ODALARI AÇ  ★ →', onPressed: () => go(_Phase.reveal))
      ]);
  Widget zone(Day4Room r) => Container(
      height: 125,
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
          color: AppColors.inkSoft, border: Border.all(color: AppColors.line)),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(day4RoomLabel(r),
                style: Theme.of(context).textTheme.headlineSmall),
            Text(switch (r) {
              Day4Room.vocal => 'Ses. Kontrol. Yorum.',
              Day4Room.dance => 'Ritim. Teknik. Hareket.',
              Day4Room.star => 'Kamera. Karizma. Etki.'
            })
          ]));
  Widget reveal() {
    final s = GameScope.of(context);
    final room = Day4Room.values[roomIndex];
    final ids = s.day4RoomAllocation!.members(room);
    return page([
      Text(day4RoomLabel(room),
          style: Theme.of(context).textTheme.displayLarge),
      const SizedBox(height: AppSpacing.lg),
      portraits(ids),
      const SizedBox(height: AppSpacing.lg),
      ContestantDialogueBubble(
          contestant: c(ids.first), text: roomQuote(room, ids.first)),
      const SizedBox(height: AppSpacing.md),
      ContestantDialogueBubble(
          contestant: c(ids[1]),
          text: roomQuote(room, ids[1]),
          alignRight: true),
      const SizedBox(height: AppSpacing.xl),
      AppButton(
          label: roomIndex < 2 ? 'SONRAKİ ODA' : 'ODALARI GÖR',
          onPressed: () {
            if (roomIndex < 2) {
              setState(() => roomIndex++);
            } else {
              go(_Phase.rooms);
            }
          })
    ]);
  }

  Widget rooms() {
    final s = GameScope.of(context);
    return page([
      Text('ODALAR HAZIR', style: Theme.of(context).textTheme.displayLarge),
      ...Day4Room.values.map((r) => Padding(
          padding: const EdgeInsets.only(top: AppSpacing.lg),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(day4RoomLabel(r), style: label()),
            portraits(s.day4RoomAllocation!.members(r))
          ]))),
      const SizedBox(height: AppSpacing.xl),
      Text('Bu odaların üçünde de bir yarışmacı veda edecek.'),
      AppButton(label: 'MENTOR ODANI SEÇ →', onPressed: () => go(_Phase.mentor))
    ]);
  }

  Widget mentor() {
    final s = GameScope.of(context);
    return page([
      Text('HER ODAYA YETİŞEMEZSİN',
          style: Theme.of(context).textTheme.displayLarge),
      Text('Bugün yalnızca bir stüdyoya doğrudan müdahale edebilirsin.'),
      const SizedBox(height: AppSpacing.xl),
      ...Day4Room.values.map((r) => InkWell(
          onTap: () => setState(() => selected = r),
          child: Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.md),
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                  color:
                      selected == r ? AppColors.accentInk : AppColors.inkSoft,
                  border: Border.all(
                      color: selected == r
                          ? AppColors.accentBright
                          : AppColors.line)),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("${day4RoomLabel(r)}'A GİR",
                        style: Theme.of(context).textTheme.headlineSmall),
                    portraits(s.day4RoomAllocation!.members(r)),
                    Text(
                        '★ RADARINDAN ${s.day4RoomAllocation!.members(r).where(s.playerRadarContestantIds.contains).length} İSİM',
                        style: label())
                  ])))),
      AppButton(
          label: 'ODAYA GİR',
          onPressed: selected == null ? null : () => go(_Phase.choice))
    ]);
  }

  Widget coaching() {
    final room = selected!;
    final s = GameScope.of(context);
    return page([
      Text(
          switch (room) {
            Day4Room.vocal => 'SON PROVA NOTUN',
            Day4Room.dance => 'SON 8 COUNT NASIL OLSUN?',
            Day4Room.star => '30 SANİYEDE NE İSTİYORSUN?'
          },
          style: Theme.of(context).textTheme.displayLarge),
      const SizedBox(height: AppSpacing.xl),
      ...Day4MentorChoice.values.map((x) => InkWell(
          onTap: () => setState(() => choice = x),
          child: Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.md),
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                  color: choice == x ? AppColors.accentInk : AppColors.inkSoft,
                  border: Border.all(
                      color: choice == x
                          ? AppColors.accentBright
                          : AppColors.line)),
              child: Text(day4ChoiceLabel(room, x),
                  style: Theme.of(context).textTheme.headlineSmall)))),
      if (choice != null) ...[
        ContestantDialogueBubble(
            contestant: c(s.day4RoomAllocation!.members(room).first),
            text: 'Bu seçimi uygulayabilirim.'),
        const SizedBox(height: AppSpacing.md),
        ContestantDialogueBubble(
            contestant: c(s.day4RoomAllocation!.members(room)[1]),
            text: 'Tam tersini isterdim ama deneyeceğim.',
            alignRight: true)
      ],
      const SizedBox(height: AppSpacing.xl),
      AppButton(
          label: 'YARIŞMAYI BAŞLAT  ★ →',
          onPressed: choice == null ? null : start)
    ]);
  }

  Widget roomResult() {
    final room = Day4Room.values[roomIndex];
    final ids = result!.allocation.members(room)
      ..sort((a, b) =>
          result!.results[a]!.rank.compareTo(result!.results[b]!.rank));
    final loser = ids.last;
    return page([
      Text(day4RoomLabel(room),
          style: Theme.of(context).textTheme.displayLarge),
      Text(
          switch (room) {
            Day4Room.vocal => 'ONE TAKE',
            Day4Room.dance => '8 COUNT BATTLE',
            Day4Room.star => '30 SECOND STAR TEST'
          },
          style: label()),
      const SizedBox(height: AppSpacing.lg),
      ...ids.map((id) {
        final r = result!.results[id]!;
        return ListTile(
            contentPadding: EdgeInsets.zero,
            leading: ClipOval(
                child: SizedBox(
                    width: 52,
                    height: 52,
                    child: ContestantPortrait(contestant: c(id)))),
            title: Text('${r.rank}. ${c(id).displayName}'),
            subtitle:
                Text('${r.categoryA}  •  ${r.categoryB}  •  ${r.categoryC}'),
            trailing: Text(r.rank == 4 ? 'ELENDİ' : 'GÜVENDE', style: label()));
      }),
      const SizedBox(height: AppSpacing.lg),
      ContestantDialogueBubble(
          contestant: c(loser),
          text: 'Bu odada daha fazlasını göstermek isterdim.',
          badge: '${day4RoomLabel(room)}’A VEDA'),
      AppButton(
          label: roomIndex < 2 ? 'SONRAKİ ODA' : '4. GÜN SONUCU',
          onPressed: () {
            if (roomIndex < 2) {
              setState(() => roomIndex++);
            } else {
              go(_Phase.summary);
            }
          })
    ]);
  }

  Widget summary() {
    final r = result!;
    return page([
      Text('4. GÜN TAMAMLANDI', style: label()),
      Text('9 KİŞİ KALDI', style: Theme.of(context).textTheme.displayLarge),
      const SizedBox(height: AppSpacing.xl),
      ...Day4Room.values.map((room) {
        final survivors = r.allocation
            .members(room)
            .where((id) => id != r.eliminatedByRoom[room])
            .toList();
        return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.lg),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(day4RoomLabel(room), style: label()),
              portraits(survivors),
              Text('VEDA: ${c(r.eliminatedByRoom[room]!).displayName}')
            ]));
      }),
      Text('SENİN ODAN', style: label()),
      Text(
          '${day4RoomLabel(r.mentorRoom)} • ${day4ChoiceLabel(r.mentorRoom, r.mentorChoice)}'),
      if (r.playerChangedRoomElimination)
        Text('★ Kararın bu odanın kaderini değiştirdi.', style: label()),
      const SizedBox(height: AppSpacing.xl),
      Text('YARIN', style: label()),
      Text('ARTIK HER ŞEY CANLI.',
          style: Theme.of(context).textTheme.headlineLarge),
      Text(
          '9 yarışmacı ilk kez canlı yayın baskısıyla karşılaşacak.\nLIVE STAGE • CAMERA TALK • FAN CONNECT'),
      AppButton(
          label: '5. GÜNE GEÇ  ★ →',
          onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(
              builder: (_) => const Day5LiveShowScreen())))
    ]);
  }

  Widget portraits(List<int> ids) => Row(
      children: ids
          .map((id) => Expanded(
              child: Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Column(children: [
                    ClipOval(
                        child: AspectRatio(
                            aspectRatio: 1,
                            child: ContestantPortrait(contestant: c(id)))),
                    Text(c(id).displayName,
                        maxLines: 1, overflow: TextOverflow.ellipsis)
                  ]))))
          .toList());
  Widget page(List<Widget> children) => SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: MaxWidthContainer(
          maxWidth: 820,
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children)));
  TextStyle label() => Theme.of(context)
      .textTheme
      .labelLarge!
      .copyWith(color: AppColors.accentBright, letterSpacing: 1.1);
  String roomQuote(Day4Room r, int id) => switch (r) {
        Day4Room.vocal => 'Burada bahanem yok.',
        Day4Room.dance => 'Tekniği olan kazansın.',
        Day4Room.star => 'Kamera varsa ben hazırım.'
      };
}
