import 'package:flutter/material.dart';
import 'package:yildiz_kadro/app/theme/app_colors.dart';
import 'package:yildiz_kadro/app/theme/app_spacing.dart';
import 'package:yildiz_kadro/features/contestants/data/contestant_seed_data.dart';
import 'package:yildiz_kadro/features/contestants/domain/contestant.dart';
import 'package:yildiz_kadro/features/contestants/presentation/widgets/contestant_portrait.dart';
import 'package:yildiz_kadro/features/game/application/game_scope.dart';
import 'package:yildiz_kadro/features/group_task/data/day5_live_engine.dart';
import 'package:yildiz_kadro/features/group_task/data/group_task_profiles.dart';
import 'package:yildiz_kadro/features/group_task/domain/day5_live_result.dart';
import 'package:yildiz_kadro/features/group_task/domain/group_task_profile.dart';
import 'package:yildiz_kadro/features/group_task/presentation/day6_grand_final_screen.dart';
import 'package:yildiz_kadro/shared/widgets/app_button.dart';
import 'package:yildiz_kadro/shared/widgets/contestant_dialogue_bubble.dart';
import 'package:yildiz_kadro/shared/widgets/max_width_container.dart';

enum _P {
  intro,
  tests,
  direction,
  summary,
  segment,
  wall,
  top3,
  safe,
  bottom,
  farewell,
  finalists
}

class Day5LiveShowScreen extends StatefulWidget {
  const Day5LiveShowScreen({super.key});
  @override
  State<Day5LiveShowScreen> createState() => _S();
}

class _S extends State<Day5LiveShowScreen> {
  _P p = _P.intro;
  Day5BroadcastDirection? direction;
  Day5ResultSnapshot? result;
  int segment = 0;
  Contestant c(int id) => contestantSeedData.firstWhere((x) => x.id == id);
  void go(_P x) => setState(() => p = x);
  List<int> active() {
    final s = GameScope.of(context);
    return contestantSeedData
        .where((c) => !s.eliminatedContestantIds.contains(c.id))
        .map((c) => c.id)
        .toList();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final s = GameScope.of(context);
    if (s.day5Completed) {
      result = s.day5ResultSnapshot;
      p = _P.finalists;
    }
  }

  void start() {
    final s = GameScope.of(context), ids = active();
    final comeback = <int>{
      ...s.lastChanceContestantIds,
      ...s.day2DuelContestantIds,
      ...s.day3FinalCutContestantIds
    };
    final memorable = <int>{
      s.day2GroupPerformanceSnapshot!.teamAResult.starContestantId,
      s.day2GroupPerformanceSnapshot!.teamBResult.starContestantId,
      ...s.day4ResultSnapshot!.winnerByRoom.values
    };
    result = calculateDay5Results(
        activeIds: ids,
        direction: direction!,
        first: s.evaluation1Results,
        day2: s.day2GroupPerformanceSnapshot!,
        day3: s.day3IconResultSnapshot!,
        day4: s.day4ResultSnapshot!,
        comebackIds: comeback,
        memorableIds: memorable);
    s.completeDay5(result!);
    go(_P.segment);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      backgroundColor: AppColors.ink,
      body: SafeArea(
          child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              child: switch (p) {
                _P.intro => intro(),
                _P.tests => tests(),
                _P.direction => choose(),
                _P.summary => summary(),
                _P.segment => segmentView(),
                _P.wall => wall(),
                _P.top3 => top3(),
                _P.safe => safe(),
                _P.bottom => bottom(),
                _P.farewell => farewell(),
                _P.finalists => finalists()
              })));
  Widget intro() {
    final ids = active();
    return page([
      Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          color: AppColors.accent,
          child: const Text('ON AIR')),
      const SizedBox(height: AppSpacing.md),
      Text('5. GÜN • STAR LIVE', style: label()),
      Text('ARTIK HER ŞEY CANLI.',
          style: Theme.of(context).textTheme.displayLarge),
      Text('9 yarışmacı. Tek yayın. İkinci şans yok.',
          style: Theme.of(context).textTheme.headlineSmall),
      Text(
          'Sahne performansı kadar kamera önü kişiliği ve izleyiciyle kurdukları bağ da değerlendirilecek.'),
      const SizedBox(height: AppSpacing.xl),
      rundown(ids),
      AppButton(label: 'YAYINA GEÇ  ★ →', onPressed: () => go(_P.tests))
    ]);
  }

  Widget tests() => page([
        Text('CANLIDA ÜÇ ŞEY SAKLANAMAZ',
            style: Theme.of(context).textTheme.displayLarge),
        ...[
          'LIVE STAGE — Canlı performans.',
          'CAMERA TALK — Kamera açıldığında kişiliği.',
          'FAN CONNECT — İzleyiciyle bağ kurma gücü.'
        ].map((x) => Container(
            margin: const EdgeInsets.only(top: AppSpacing.md),
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
                color: AppColors.inkSoft,
                border: Border.all(color: AppColors.line)),
            child: Text(x, style: Theme.of(context).textTheme.titleLarge))),
        const SizedBox(height: AppSpacing.xl),
        Text("Bu üç alan birlikte LIVE SCORE'u oluşturacak."),
        AppButton(label: 'YAYINI PLANLA →', onPressed: () => go(_P.direction))
      ]);
  Widget choose() {
    final ids = active();
    return page([
      Text('BU GECEYİ NASIL ÇEKECEKSİN?',
          style: Theme.of(context).textTheme.displayLarge),
      const SizedBox(height: AppSpacing.xl),
      ...Day5BroadcastDirection.values.map((d) => InkWell(
          onTap: () => setState(() => direction = d),
          child: Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.md),
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                  color:
                      direction == d ? AppColors.accentInk : AppColors.inkSoft,
                  border: Border.all(
                      color: direction == d
                          ? AppColors.accentBright
                          : AppColors.line)),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(day5DirectionLabel(d),
                        style: Theme.of(context).textTheme.headlineSmall),
                    Text(dirDesc(d))
                  ])))),
      if (direction != null) ...[
        ContestantDialogueBubble(
            contestant: c(ids.first), text: talk(ids.first, 'preview')),
        const SizedBox(height: AppSpacing.sm),
        ContestantDialogueBubble(
            contestant: c(ids[1]),
            text: talk(ids[1], 'preview'),
            alignRight: true)
      ],
      AppButton(
          label: 'YAYIN DİLİNİ ONAYLA',
          onPressed: direction == null ? null : () => go(_P.summary))
    ]);
  }

  Widget summary() => page([
        Text('YAYIN DİLİN', style: label()),
        Text(day5DirectionLabel(direction!),
            style: Theme.of(context).textTheme.displayLarge),
        Text(
            'Bu yönetmenlik tercihi dokuz yarışmacının güçlü yanlarını farklı şekilde öne çıkaracak.'),
        const SizedBox(height: AppSpacing.xl),
        TextButton(
            onPressed: () => go(_P.direction), child: const Text('DEĞİŞTİR')),
        AppButton(label: 'YAYINI BAŞLAT', onPressed: start)
      ]);
  Widget segmentView() {
    final ids = result!.rankingIds.sublist(segment * 3, segment * 3 + 3);
    return page([
      Text('CANLI YAYIN — SEGMENT ${segment + 1}',
          style: Theme.of(context).textTheme.displayLarge),
      rundown(ids),
      const SizedBox(height: AppSpacing.lg),
      ...ids.map((id) {
        final r = result!.results[id]!;
        return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.lg),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('${c(id).displayName} • ${historyLabel(id)}',
                  style: label()),
              ContestantDialogueBubble(
                  contestant: c(id), text: talk(id, 'interview')),
              Text(
                  'CANLI TEPKİ: ${r.fanConnect >= 88 ? 'GÜÇLÜ TEPKİ' : r.fanConnect >= 82 ? 'BAĞ KURDU' : 'DİKKAT ÇEKTİ'}'),
              if (r.broadcastFitModifier >= 3)
                Text('★ Bu yayın dili ona uydu.', style: label())
            ]));
      }),
      AppButton(
          label: segment < 2 ? 'SONRAKİ SEGMENT' : 'YAYINI BİTİR',
          onPressed: () {
            if (segment < 2) {
              setState(() => segment++);
            } else {
              go(_P.wall);
            }
          })
    ]);
  }

  Widget wall() => page([
        Text('YAYIN BİTTİ', style: Theme.of(context).textTheme.displayLarge),
        Text('Şimdi yalnızca sonuçlar kaldı.'),
        const SizedBox(height: AppSpacing.xl),
        rundown(result!.rankingIds),
        Text('Bu gecenin sonunda 7 finalist kalacak.'),
        AppButton(label: 'SONUÇLARI AÇ  →', onPressed: () => go(_P.top3))
      ]);
  Widget top3() => page([
        Text('GECENİN ÖNE ÇIKANLARI',
            style: Theme.of(context).textTheme.displayLarge),
        Text('GECENİN CANLI YILDIZI', style: label()),
        portraits(result!.rankingIds.take(3).toList()),
        Text('Bu üç isim doğrudan FİNALİST.'),
        AppButton(label: 'FİNALE DEVAM EDENLER', onPressed: () => go(_P.safe))
      ]);
  Widget safe() => page([
        Text('FİNALE DEVAM EDENLER',
            style: Theme.of(context).textTheme.displayLarge),
        portraits(result!.rankingIds.skip(3).take(4).toList()),
        Text('Böylece 7 finalist tamamlandı.'),
        AppButton(label: 'SON İKİYİ GÖR', onPressed: () => go(_P.bottom))
      ]);
  Widget bottom() {
    final ids = result!.eliminatedIds;
    return page([
      Text('SON İKİ', style: Theme.of(context).textTheme.displayLarge),
      ContestantDialogueBubble(
          contestant: c(ids.first),
          text: 'Bunun burada bitmesini istemiyorum.'),
      const SizedBox(height: AppSpacing.lg),
      ContestantDialogueBubble(
          contestant: c(ids.last),
          text: 'Ne yaptıysam canlı yaptım.',
          alignRight: true),
      AppButton(
          label: 'CANLI YAYIN SONUCUNU AÇ', onPressed: () => go(_P.farewell))
    ]);
  }

  Widget farewell() {
    final ids = result!.eliminatedIds;
    return page([
      Text('CANLI YAYINA VEDA',
          style: Theme.of(context).textTheme.displayLarge),
      portraits(ids),
      ...ids.map((id) => ListTile(
          title: Text(c(id).displayName),
          subtitle: Text('“${talk(id, 'farewell')}”'),
          trailing:
              Text('LIVE ${result!.results[id]!.liveScore}', style: label()))),
      AppButton(label: '7 FİNALİSTİ AÇ', onPressed: () => go(_P.finalists))
    ]);
  }

  Widget finalists() {
    final s = GameScope.of(context), ids = result!.finalistIds;
    final radar = ids.where(s.playerRadarContestantIds.contains).length;
    return page([
      Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(border: Border.all(color: AppColors.line)),
          child: const Text('OFF AIR')),
      const SizedBox(height: AppSpacing.md),
      Text('5. GÜN TAMAMLANDI', style: label()),
      Text('7 FİNALİST', style: Theme.of(context).textTheme.displayLarge),
      Text('Yarışma bitti. Şimdi grup kurulacak.',
          style: Theme.of(context).textTheme.headlineSmall),
      const SizedBox(height: AppSpacing.xl),
      Text('FİNALE KALANLAR', style: label()),
      portraits(ids),
      Text('GECENİN CANLI YILDIZI: ${c(result!.rankingIds.first).displayName}'),
      Text('SENİN YAYIN TERCİHİN: ${day5DirectionLabel(result!.direction)}'),
      if (result!.playerChangedCut)
        Text('★ Yayın tercihin finalistlerden en az birini değiştirdi.',
            style: label()),
      Text(
          radar == 0
              ? 'İlk günkü radarın tamamen değişti.'
              : '★ İlk radarındaki 5 isimden $radar’ü finale kaldı.',
          style: label()),
      const SizedBox(height: AppSpacing.xl),
      Text('YARIN', style: label()),
      Text('ARTIK JÜRİ DEĞİL, SEN.',
          style: Theme.of(context).textTheme.headlineLarge),
      Text('7 finalist. 5 kişilik Yıldız Kadro.\nSon kadroyu sen kuracaksın.'),
      AppButton(
          label: 'BÜYÜK FİNALE GEÇ  ★ →',
          onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(
              builder: (_) => const Day6GrandFinalScreen())))
    ]);
  }

  Widget rundown(List<int> ids) => Wrap(
      spacing: 10,
      runSpacing: 10,
      children: ids
          .asMap()
          .entries
          .map((e) => SizedBox(
              width: 82,
              child: Column(children: [
                Text('${e.key + 1}'.padLeft(2, '0'), style: label()),
                ClipOval(
                    child: SizedBox(
                        width: 58,
                        height: 58,
                        child: ContestantPortrait(contestant: c(e.value)))),
                Text(c(e.value).displayName,
                    maxLines: 1, overflow: TextOverflow.ellipsis)
              ])))
          .toList());
  Widget portraits(List<int> ids) => Row(
      children: ids
          .map((id) => Expanded(
              child: Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: Column(children: [
                    ClipOval(
                        child: AspectRatio(
                            aspectRatio: 1,
                            child: ContestantPortrait(contestant: c(id)))),
                    Text(c(id).displayName, maxLines: 1)
                  ]))))
          .toList());
  Widget page(List<Widget> x) => SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: MaxWidthContainer(
          maxWidth: 850,
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, children: x)));
  TextStyle label() => Theme.of(context)
      .textTheme
      .labelLarge!
      .copyWith(color: AppColors.accentBright, letterSpacing: 1.1);
  String historyLabel(int id) {
    final s = GameScope.of(context);
    if (s.day4ResultSnapshot!.winnerByRoom.values.contains(id)) {
      return 'ROOM WINNER';
    }
    if (s.day3FinalCutResultSnapshot!.winnerContestantId == id) {
      return 'FINAL CUT SURVIVOR';
    }
    return day5DirectionLabel(direction!);
  }

  String dirDesc(Day5BroadcastDirection d) => switch (d) {
        Day5BroadcastDirection.bigStage =>
          'Geniş planlar, koreografi ve büyük performans anları.',
        Day5BroadcastDirection.closeCamera =>
          'Yüz, ifade ve küçük anlar ön planda.',
        Day5BroadcastDirection.storyNight =>
          'Yarışmacıların yolculuğu ve kişiliği öne çıkıyor.'
      };
  String talk(int id, String scene) {
    final style = groupTaskProfiles[id]!.workStyle;
    if (scene == 'farewell') {
      return id.isEven
          ? 'Finali görmek isterdim.'
          : 'Burada yaptıklarımı unutmayacağım.';
    }
    if (scene == 'preview') {
      return style == WorkStyle.cameraSavvy
          ? 'Kamera yaklaşsın.'
          : 'Bu yayın içinde yerimi bulacağım.';
    }
    return switch (style) {
      WorkStyle.bold => 'Çünkü burada küçülmedim.',
      WorkStyle.calm => 'Her gün ne yapabildiğimi biraz daha gösterdim.',
      WorkStyle.competitive => 'Hâlâ en iyi performansımı vermedim.',
      WorkStyle.sensitive => 'Burada gerçekten kendimi tanıdım.',
      WorkStyle.playful => 'Sahnede beni izlerken sıkılmıyorsunuz.',
      WorkStyle.cameraSavvy => 'Kamera açıldığında kim olduğumu biliyorum.',
      _ => 'Finale kalmak için hâlâ söyleyecek sözüm var.'
    };
  }
}
