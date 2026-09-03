import 'package:flutter/material.dart';
import 'package:yildiz_kadro/app/theme/app_colors.dart';
import 'package:yildiz_kadro/app/theme/app_spacing.dart';
import 'package:yildiz_kadro/features/contestants/data/contestant_seed_data.dart';
import 'package:yildiz_kadro/features/contestants/domain/contestant.dart';
import 'package:yildiz_kadro/l10n/l10n.dart';
import 'package:yildiz_kadro/features/contestants/presentation/widgets/contestant_portrait.dart';
import 'package:yildiz_kadro/features/game/application/game_scope.dart';
import 'package:yildiz_kadro/features/group_task/data/day4_position_engine.dart';
import 'package:yildiz_kadro/features/group_task/domain/day4_position_result.dart';
import 'package:yildiz_kadro/features/group_task/presentation/day5_live_show_screen.dart';
import 'package:yildiz_kadro/features/producer/presentation/story_event_dialog.dart';
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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) showStoryEventDialog(context, day: 4);
    });
  }

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
        game.initializeDay4Rooms(
          allocateDay4Rooms(
            activeIds: ids,
            first: game.evaluation1Results,
            day2: day2,
            day3: day3,
          ),
        );
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
      day3: s.day3IconResultSnapshot!,
    );
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
                    _Phase.summary => summary(),
                  },
                ),
        ),
      );
  Widget intro() {
    final isEn = isAppEnglish(context);
    return page([
      Text(context.l10n.dayLabel(4), style: label()),
      Text(
        isEn ? 'POSITION BATTLE' : 'POZİSYON SAVAŞI',
        style: Theme.of(context).textTheme.displayLarge,
      ),
      Text(
        isEn
            ? 'Now everyone competes in their core domain.'
            : 'Artık herkes kendi güçlü alanında yarışacak.',
        style: Theme.of(context).textTheme.headlineSmall,
      ),
      const SizedBox(height: AppSpacing.xl),
      ...Day4Room.values.map((r) => zone(r)),
      Text(
        isEn
            ? '12 contestants. 3 rooms. One farewell from each.'
            : '12 yarışmacı. 3 oda. Her odadan bir veda.',
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      Text(
        isEn
            ? 'This time your rival excels at the exact same craft as you.'
            : 'Bu kez rakibin, seninle aynı şeyi iyi yapan biri.',
        style: Theme.of(context)
            .textTheme
            .bodySmall
            ?.copyWith(fontStyle: FontStyle.italic),
      ),
      const SizedBox(height: AppSpacing.xl),
      AppButton(
        label: isEn ? 'OPEN ROOMS  ★ →' : 'ODALARI AÇ  ★ →',
        onPressed: () => go(_Phase.reveal),
      ),
    ]);
  }

  Widget zone(Day4Room r) => Container(
        height: 125,
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.inkSoft,
          border: Border.all(color: AppColors.line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              day4RoomLabel(r),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Text(switch (r) {
              Day4Room.vocal => isAppEnglish(context)
                  ? 'Vocals. Control. Expression.'
                  : 'Ses. Kontrol. Yorum.',
              Day4Room.dance => isAppEnglish(context)
                  ? 'Rhythm. Technique. Movement.'
                  : 'Ritim. Teknik. Hareket.',
              Day4Room.star => isAppEnglish(context)
                  ? 'Camera. Charisma. Impact.'
                  : 'Kamera. Karizma. Etki.',
            }),
          ],
        ),
      );
  Widget reveal() {
    final s = GameScope.of(context);
    final room = Day4Room.values[roomIndex];
    final ids = s.day4RoomAllocation!.members(room);
    return page([
      Text(
        day4RoomLabel(room),
        style: Theme.of(context).textTheme.displayLarge,
      ),
      const SizedBox(height: AppSpacing.lg),
      portraits(ids),
      const SizedBox(height: AppSpacing.lg),
      ContestantDialogueBubble(
        contestant: c(ids.first),
        text: roomQuote(room, ids.first, context),
      ),
      const SizedBox(height: AppSpacing.md),
      ContestantDialogueBubble(
        contestant: c(ids[1]),
        text: roomQuote(room, ids[1], context),
        alignRight: true,
      ),
      const SizedBox(height: AppSpacing.xl),
      AppButton(
        label: roomIndex < 2
            ? (isAppEnglish(context) ? 'NEXT ROOM' : 'SONRAKİ ODA')
            : (isAppEnglish(context) ? 'VIEW ALL ROOMS' : 'ODALARI GÖR'),
        onPressed: () {
          if (roomIndex < 2) {
            setState(() => roomIndex++);
          } else {
            go(_Phase.rooms);
          }
        },
      ),
    ]);
  }

  Widget rooms() {
    final isEn = isAppEnglish(context);
    final s = GameScope.of(context);
    return page([
      Text(
        isEn ? 'ROOMS ARE SET' : 'ODALAR HAZIR',
        style: Theme.of(context).textTheme.displayLarge,
      ),
      ...Day4Room.values.map(
        (r) => Padding(
          padding: const EdgeInsets.only(top: AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(day4RoomLabel(r), style: label()),
              portraits(s.day4RoomAllocation!.members(r)),
            ],
          ),
        ),
      ),
      const SizedBox(height: AppSpacing.xl),
      Text(
        isEn
            ? 'In each of these three rooms, one contestant will depart.'
            : 'Bu odaların üçünde de bir yarışmacı veda edecek.',
      ),
      AppButton(
        label: isEn ? 'SELECT MENTOR ROOM →' : 'MENTOR ODANI SEÇ →',
        onPressed: () => go(_Phase.mentor),
      ),
    ]);
  }

  Widget mentor() {
    final isEn = isAppEnglish(context);
    final s = GameScope.of(context);
    return page([
      Text(
        isEn ? 'YOU CANNOT BE IN EVERY ROOM' : 'HER ODAYA YETİŞEMEZSİN',
        style: Theme.of(context).textTheme.displayLarge,
      ),
      Text(
        isEn
            ? 'Today you can only directly mentor one single studio.'
            : 'Bugün yalnızca bir stüdyoya doğrudan müdahale edebilirsin.',
      ),
      const SizedBox(height: AppSpacing.xl),
      ...Day4Room.values.map(
        (r) => InkWell(
          onTap: () => setState(() => selected = r),
          child: Container(
            margin: const EdgeInsets.only(bottom: AppSpacing.md),
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: selected == r ? AppColors.accentInk : AppColors.inkSoft,
              border: Border.all(
                color: selected == r ? AppColors.accentBright : AppColors.line,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEn
                      ? 'ENTER ${day4RoomLabel(r)}'
                      : "${day4RoomLabel(r)}'A GİR",
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                portraits(s.day4RoomAllocation!.members(r)),
                Text(
                  isEn
                      ? '★ ${s.day4RoomAllocation!.members(r).where(s.playerRadarContestantIds.contains).length} TALENTS FROM RADAR'
                      : '★ RADARINDAN ${s.day4RoomAllocation!.members(r).where(s.playerRadarContestantIds.contains).length} İSİM',
                  style: label(),
                ),
              ],
            ),
          ),
        ),
      ),
      AppButton(
        label: isEn ? 'ENTER ROOM' : 'ODAYA GİR',
        onPressed: selected == null ? null : () => go(_Phase.choice),
      ),
    ]);
  }

  Widget coaching() {
    final room = selected!;
    final s = GameScope.of(context);
    final isEn = isAppEnglish(context);
    return page([
      Text(
          switch (room) {
            Day4Room.vocal => isEn ? 'FINAL REHEARSAL NOTE' : 'SON PROVA NOTUN',
            Day4Room.dance => isEn
                ? 'HOW SHOULD THE FINAL 8-COUNT BE?'
                : 'SON 8 COUNT NASIL OLSUN?',
            Day4Room.star => isEn
                ? 'WHAT DO YOU WANT IN 30 SECONDS?'
                : '30 SANİYEDE NE İSTİYORSUN?',
          },
          style: Theme.of(context).textTheme.displayLarge),
      const SizedBox(height: AppSpacing.xl),
      ...Day4MentorChoice.values.map(
        (x) => InkWell(
          onTap: () => setState(() => choice = x),
          child: Container(
            margin: const EdgeInsets.only(bottom: AppSpacing.md),
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: choice == x ? AppColors.accentInk : AppColors.inkSoft,
              border: Border.all(
                color: choice == x ? AppColors.accentBright : AppColors.line,
              ),
            ),
            child: Text(
              day4ChoiceLabel(room, x, context),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
        ),
      ),
      if (choice != null) ...[
        ContestantDialogueBubble(
          contestant: c(s.day4RoomAllocation!.members(room).first),
          text: isEn
              ? 'I can execute this choice.'
              : 'Bu seçimi uygulayabilirim.',
        ),
        const SizedBox(height: AppSpacing.md),
        ContestantDialogueBubble(
          contestant: c(s.day4RoomAllocation!.members(room)[1]),
          text: isEn
              ? 'I preferred the opposite, but I’ll make it work.'
              : 'Tam tersini isterdim ama deneyeceğim.',
          alignRight: true,
        ),
      ],
      const SizedBox(height: AppSpacing.xl),
      AppButton(
        label: isEn ? 'START BATTLE  ★ →' : 'YARIŞMAYI BAŞLAT  ★ →',
        onPressed: choice == null ? null : start,
      ),
    ]);
  }

  Widget roomResult() {
    final isEn = isAppEnglish(context);
    final room = Day4Room.values[roomIndex];
    final ids = result!.allocation.members(room)
      ..sort(
        (a, b) => result!.results[a]!.rank.compareTo(result!.results[b]!.rank),
      );
    final loser = ids.last;
    return page([
      Text(
        day4RoomLabel(room),
        style: Theme.of(context).textTheme.displayLarge,
      ),
      Text(
          switch (room) {
            Day4Room.vocal => 'ONE TAKE',
            Day4Room.dance => '8 COUNT BATTLE',
            Day4Room.star => '30 SECOND STAR TEST',
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
              child: ContestantPortrait(contestant: c(id)),
            ),
          ),
          title: Text('${r.rank}. ${c(id).displayName}'),
          subtitle: Text(
            '${r.categoryA}  •  ${r.categoryB}  •  ${r.categoryC}',
          ),
          trailing: Text(
            r.rank == 4
                ? (isEn ? 'ELIMINATED' : 'ELENDİ')
                : (isEn ? 'SAFE' : 'GÜVENDE'),
            style: label(),
          ),
        );
      }),
      const SizedBox(height: AppSpacing.lg),
      ContestantDialogueBubble(
        contestant: c(loser),
        text: isEn
            ? 'I wanted to show so much more in this room.'
            : 'Bu odada daha fazlasını göstermek isterdim.',
        badge: isEn
            ? 'FAREWELL TO ${day4RoomLabel(room)}'
            : '${day4RoomLabel(room)}’A VEDA',
      ),
      AppButton(
        label: roomIndex < 2
            ? (isEn ? 'NEXT ROOM' : 'SONRAKİ ODA')
            : (isEn ? 'DAY 4 RECAP' : '4. GÜN SONUCU'),
        onPressed: () {
          if (roomIndex < 2) {
            setState(() => roomIndex++);
          } else {
            go(_Phase.summary);
          }
        },
      ),
    ]);
  }

  Widget summary() {
    final isEn = isAppEnglish(context);
    final r = result!;
    return page([
      Text(
        '${context.l10n.dayLabel(4)} ${isEn ? "CONCLUDED" : "TAMAMLANDI"}',
        style: label(),
      ),
      Text(
        isEn ? '9 REMAIN' : '9 KİŞİ KALDI',
        style: Theme.of(context).textTheme.displayLarge,
      ),
      const SizedBox(height: AppSpacing.xl),
      ...Day4Room.values.map((room) {
        final survivors = r.allocation
            .members(room)
            .where((id) => id != r.eliminatedByRoom[room])
            .toList();
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(day4RoomLabel(room), style: label()),
              portraits(survivors),
              Text(
                '${isEn ? "DEPARTURE" : "VEDA"}: ${c(r.eliminatedByRoom[room]!).displayName}',
              ),
            ],
          ),
        );
      }),
      Text(isEn ? 'YOUR MENTORED ROOM' : 'SENİN ODAN', style: label()),
      Text(
        '${day4RoomLabel(r.mentorRoom)} • ${day4ChoiceLabel(r.mentorRoom, r.mentorChoice, context)}',
      ),
      if (r.playerChangedRoomElimination)
        Text(
          isEn
              ? '★ Your coaching altered the fate of this room.'
              : '★ Kararın bu odanın kaderini değiştirdi.',
          style: label(),
        ),
      const SizedBox(height: AppSpacing.xl),
      Text(isEn ? 'TOMORROW' : 'YARIN', style: label()),
      Text(
        isEn ? 'NOW EVERYTHING GOES LIVE.' : 'ARTIK HER ŞEY CANLI.',
        style: Theme.of(context).textTheme.headlineLarge,
      ),
      Text(
        isEn
            ? '9 contestants face live-broadcast pressure for the first time.\nLIVE STAGE • CAMERA TALK • FAN CONNECT'
            : '9 yarışmacı ilk kez canlı yayın baskısıyla karşılaşacak.\nLIVE STAGE • CAMERA TALK • FAN CONNECT',
      ),
      AppButton(
        label: isEn ? 'ADVANCE TO DAY 5  ★ →' : '5. GÜNE GEÇ  ★ →',
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const Day5LiveShowScreen()),
        ),
      ),
    ]);
  }

  Widget portraits(List<int> ids) => Row(
        children: ids
            .map(
              (id) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Column(
                    children: [
                      ClipOval(
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: ContestantPortrait(contestant: c(id)),
                        ),
                      ),
                      Text(
                        c(id).displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            )
            .toList(),
      );
  Widget page(List<Widget> children) => SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: MaxWidthContainer(
          maxWidth: 820,
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
  String roomQuote(Day4Room r, int id, [BuildContext? context]) {
    final isEn = isAppEnglish(context);
    return switch (r) {
      Day4Room.vocal =>
        isEn ? 'No excuses in this room.' : 'Burada bahanem yok.',
      Day4Room.dance =>
        isEn ? 'May the cleanest technique prevail.' : 'Tekniği olan kazansın.',
      Day4Room.star => isEn
          ? 'If the camera is rolling, I’m ready.'
          : 'Kamera varsa ben hazırım.',
    };
  }
}
