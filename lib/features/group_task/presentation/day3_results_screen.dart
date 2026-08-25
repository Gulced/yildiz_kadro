import 'package:flutter/material.dart';
import 'package:yildiz_kadro/app/theme/app_colors.dart';
import 'package:yildiz_kadro/app/theme/app_spacing.dart';
import 'package:yildiz_kadro/features/contestants/data/contestant_seed_data.dart';
import 'package:yildiz_kadro/features/contestants/presentation/widgets/contestant_portrait.dart';
import 'package:yildiz_kadro/features/game/application/game_scope.dart';
import 'package:yildiz_kadro/features/group_task/presentation/day4_position_battle_screen.dart';
import 'package:yildiz_kadro/shared/widgets/app_button.dart';
import 'package:yildiz_kadro/shared/widgets/contestant_dialogue_bubble.dart';
import 'package:yildiz_kadro/shared/widgets/max_width_container.dart';

class Day3ResultsScreen extends StatelessWidget {
  const Day3ResultsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final state = GameScope.of(context);
    final active = contestantSeedData
        .where((c) => !state.eliminatedContestantIds.contains(c.id))
        .toList();
    final iconId = state.day3IconResultSnapshot!.rankingIds.first;
    final icon = contestantSeedData.firstWhere((c) => c.id == iconId);
    final winner = state.day3FinalCutResultSnapshot!.winnerContestantId;
    final eliminated = state.day3FinalCutResultSnapshot!.eliminatedContestantId;
    return Scaffold(
        backgroundColor: AppColors.ink,
        body: SafeArea(
            child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: MaxWidthContainer(
                    maxWidth: 900,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('3. GÜN TAMAMLANDI', style: _label(context)),
                          Text('12 KİŞİ KALDI',
                              style: Theme.of(context).textTheme.displayLarge),
                          const SizedBox(height: AppSpacing.xl),
                          Text('GECENİN ICON’U', style: _label(context)),
                          SizedBox(
                              width: 350,
                              child: AspectRatio(
                                  aspectRatio: .82,
                                  child: ContestantPortrait(contestant: icon))),
                          Text(icon.displayName,
                              style: Theme.of(context).textTheme.headlineLarge),
                          const SizedBox(height: AppSpacing.xl),
                          Text('SENİN YÖNETTİKLERİN', style: _label(context)),
                          _circles(state.day3IdentitySetupSnapshot!
                              .stylingSupportContestantIds),
                          const SizedBox(height: AppSpacing.lg),
                          Text('FINAL CUT’TAN ÇIKAN', style: _label(context)),
                          _circles([winner]),
                          Text('VEDA EDEN', style: _label(context)),
                          _circles([eliminated]),
                          if (state
                              .day3FinalCutResultSnapshot!.playerChangedOutcome)
                            Text('★ Final Cut kararın sonucu değiştirdi.',
                                style: _label(context)),
                          const SizedBox(height: AppSpacing.xl),
                          ContestantDialogueBubble(
                              contestant: active.first,
                              text: 'Yarın her şey sıfırlanıyor.'),
                          const SizedBox(height: AppSpacing.md),
                          ContestantDialogueBubble(
                              contestant: active[1],
                              text: 'Artık hata yapacak alan kalmadı.',
                              alignRight: true),
                          const SizedBox(height: AppSpacing.xl),
                          Text('12 AKTİF YARIŞMACI', style: _label(context)),
                          Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: active
                                  .map((c) => SizedBox(
                                      width: 72,
                                      child: Column(children: [
                                        ClipOval(
                                            child: SizedBox(
                                                width: 58,
                                                height: 58,
                                                child: ContestantPortrait(
                                                    contestant: c))),
                                        Text(c.displayName,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: Theme.of(context)
                                                .textTheme
                                                .labelSmall)
                                      ])))
                                  .toList()),
                          const SizedBox(height: AppSpacing.xl),
                          Text('YARIN', style: _label(context)),
                          Text('Herkes kendi alanına.',
                              style: Theme.of(context).textTheme.headlineLarge),
                          Text(
                              '12 yarışmacı kendi güçlü alanını seçmek zorunda.\nHer odadan biri veda edecek.',
                              style: Theme.of(context).textTheme.bodyLarge),
                          const SizedBox(height: AppSpacing.md),
                          ...[
                            'VOCAL ROOM',
                            'DANCE ROOM',
                            'STAR ROOM'
                          ].map((room) => Container(
                              margin:
                                  const EdgeInsets.only(bottom: AppSpacing.sm),
                              padding: const EdgeInsets.all(AppSpacing.lg),
                              decoration: BoxDecoration(
                                  color: AppColors.inkSoft,
                                  border: Border.all(color: AppColors.line)),
                              child: Text(room,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall))),
                          AppButton(
                              label: '4. GÜNE GEÇ  ★ →',
                              onPressed: () => Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                      builder: (_) =>
                                          const Day4PositionBattleScreen()))),
                        ])))));
  }

  Widget _circles(List<int> ids) => Row(
          children: ids.map((id) {
        final c = contestantSeedData.firstWhere((c) => c.id == id);
        return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.md),
            child: SizedBox(
                width: 82,
                child: Column(children: [
                  ClipOval(
                      child: SizedBox(
                          width: 64,
                          height: 64,
                          child: ContestantPortrait(contestant: c))),
                  Text(c.displayName, maxLines: 1)
                ])));
      }).toList());
}

TextStyle _label(BuildContext context) => Theme.of(context)
    .textTheme
    .labelLarge!
    .copyWith(color: AppColors.accentBright, letterSpacing: 1.2);
