import 'package:flutter/material.dart';
import 'package:yildiz_kadro/app/theme/app_colors.dart';
import 'package:yildiz_kadro/app/theme/app_spacing.dart';
import 'package:yildiz_kadro/features/contestants/data/contestant_seed_data.dart';
import 'package:yildiz_kadro/features/game/application/game_scope.dart';
import 'package:yildiz_kadro/features/group_task/data/day3_icon_engine.dart';
import 'package:yildiz_kadro/features/group_task/presentation/day3_final_cut_screen.dart';
import 'package:yildiz_kadro/features/producer/presentation/story_event_dialog.dart';
import 'package:yildiz_kadro/l10n/l10n.dart';
import 'package:yildiz_kadro/shared/widgets/app_button.dart';
import 'package:yildiz_kadro/shared/widgets/max_width_container.dart';

class Day3IconPerformanceScreen extends StatefulWidget {
  const Day3IconPerformanceScreen({super.key});

  @override
  State<Day3IconPerformanceScreen> createState() =>
      _Day3IconPerformanceScreenState();
}

class _Day3IconPerformanceScreenState extends State<Day3IconPerformanceScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) showStoryEventDialog(context, day: 3);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isEn = isAppEnglish(context);
    final state = GameScope.of(context);
    final active = contestantSeedData
        .where((c) => !state.eliminatedContestantIds.contains(c.id))
        .map((c) => c.id)
        .toList();
    return Scaffold(
      backgroundColor: AppColors.ink,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: MaxWidthContainer(
            maxWidth: 720,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${context.l10n.dayLabel(3).toUpperCase()} • ICON TEST',
                  style: Theme.of(context)
                      .textTheme
                      .labelLarge
                      ?.copyWith(color: AppColors.accentBright),
                ),
                Text(
                  isEn
                      ? 'The camera sees everything.'
                      : 'Kamera her şeyi görüyor.',
                  style: Theme.of(context).textTheme.displayLarge,
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  isEn
                      ? '13 contestants showcase their distinct star identity for the first time.'
                      : '13 yarışmacı kendi yıldız kimliğini ilk kez gösteriyor.',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                Text(
                  isEn
                      ? 'Identity. Styling. Camera. Performance.'
                      : 'Kimlik. Styling. Kamera. Performans.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: AppSpacing.xl),
                AppButton(
                  label: isEn
                      ? 'COMPLETE ICON TEST  ★ →'
                      : 'ICON TESTİ TAMAMLA  ★ →',
                  onPressed: () {
                    if (state.day3IconResultSnapshot == null) {
                      state.completeDay3IconTest(
                        calculateDay3IconResults(
                          activeIds: active,
                          firstResults: state.evaluation1Results,
                          day2Scores: {
                            for (final id in active)
                              id: state.day2GroupPerformanceSnapshot!
                                  .individualResults[id]!.rawOverall,
                          },
                          setup: state.day3IdentitySetupSnapshot!,
                        ),
                      );
                    }
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const Day3FinalCutScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
