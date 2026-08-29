import 'package:flutter/material.dart';
import 'package:yildiz_kadro/app/theme/app_colors.dart';
import 'package:yildiz_kadro/app/theme/app_spacing.dart';
import 'package:yildiz_kadro/features/evaluation/presentation/evaluation_reveal_screen.dart';
import 'package:yildiz_kadro/features/evaluation/presentation/evaluation_results_screen.dart';
import 'package:yildiz_kadro/features/game/application/game_scope.dart';
import 'package:yildiz_kadro/shared/widgets/app_button.dart';
import 'package:yildiz_kadro/shared/widgets/max_width_container.dart';
import 'package:yildiz_kadro/shared/widgets/mission_briefing.dart';

class FirstEvaluationScreen extends StatelessWidget {
  const FirstEvaluationScreen({super.key});

  void _openStage(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const EvaluationRevealScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (GameScope.of(context).evaluation1Completed) {
      return const EvaluationResultsScreen();
    }
    return MissionBriefing(
      stageId: 'first_evaluation',
      title: 'İLK DEĞERLENDİRME',
      what: '15 yarışmacının ilk sahne testini izle.',
      watch: 'Teknik puan kadar sahne güveni ve ilk radarın da önemli.',
      affects: 'İlk sıralama, jüri riski ve yarışmacı momentumu.',
      child: Scaffold(
        backgroundColor: AppColors.ink,
        body: SafeArea(
          child: SingleChildScrollView(
            child: MaxWidthContainer(
              maxWidth: 700,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      tooltip: 'Geri',
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Text(
                      '1. GÜN',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: AppColors.accentSoft,
                            letterSpacing: 1.4,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'İLK DEĞERLENDİRME',
                      style: Theme.of(context).textTheme.displayLarge,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Text(
                      'Işıklar yandı.\nİlk kez gerçekten sahnedeler.',
                      style:
                          Theme.of(context).textTheme.headlineLarge?.copyWith(
                                color: AppColors.paper,
                                height: 1.05,
                              ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      '15 yarışmacı kısa bir performans testine çıkacak.\nİlk izlenimlerin birazdan sınanacak.',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Radarındaki yıldızlar seni şaşırtabilir.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.paperMuted,
                            fontStyle: FontStyle.italic,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    AppButton(
                        label: 'SAHNEYİ AÇ',
                        onPressed: () => _openStage(context)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
