import 'package:flutter/material.dart';
import 'package:yildiz_kadro/app/theme/app_colors.dart';
import 'package:yildiz_kadro/app/theme/app_spacing.dart';
import 'package:yildiz_kadro/core/responsive/breakpoints.dart';
import 'package:yildiz_kadro/features/contestants/data/contestant_seed_data.dart';
import 'package:yildiz_kadro/features/contestants/presentation/contestant_detail_screen.dart';
import 'package:yildiz_kadro/features/contestants/presentation/widgets/contestant_card.dart';
import 'package:yildiz_kadro/features/first_impression/presentation/first_impression_screen.dart';
import 'package:yildiz_kadro/shared/widgets/app_button.dart';

class ContestantDashboardScreen extends StatelessWidget {
  const ContestantDashboardScreen({super.key});

  void _openContestant(BuildContext context, int index) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            ContestantDetailScreen(contestant: contestantSeedData[index]),
      ),
    );
  }

  void _showNextStep(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const FirstImpressionScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    final tileHeight =
        330.0 + ((textScale - 1).clamp(0.0, 1.0) * 140).toDouble();

    return Scaffold(
      backgroundColor: AppColors.ink,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: AppBreakpoints.maxContentWidth,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md,
                      AppSpacing.sm,
                      AppSpacing.md,
                      AppSpacing.lg,
                    ),
                    child: _DashboardHeader(
                      onBack: () => Navigator.of(context).pop(),
                    ),
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              sliver: SliverLayoutBuilder(
                builder: (context, constraints) {
                  final sideSpace = (constraints.crossAxisExtent -
                              AppBreakpoints.maxContentWidth)
                          .clamp(0.0, double.infinity) /
                      2;
                  return SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: sideSpace),
                    sliver: SliverGrid(
                      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 220,
                        mainAxisExtent: tileHeight,
                        crossAxisSpacing: AppSpacing.sm,
                        mainAxisSpacing: AppSpacing.sm,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => ContestantCard(
                          contestant: contestantSeedData[index],
                          onTap: () => _openContestant(context, index),
                        ),
                        childCount: contestantSeedData.length,
                      ),
                    ),
                  );
                },
              ),
            ),
            SliverToBoxAdapter(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.xl,
                      AppSpacing.lg,
                      AppSpacing.xxl,
                    ),
                    child: AppButton(
                      label: '15 YARIŞMACIYI GÖRDÜM',
                      onPressed: () => _showNextStep(context),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IconButton(
          onPressed: onBack,
          tooltip: 'Geri',
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'CASTING • SEZON 01',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: AppColors.accentSoft,
              ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'YARIŞMACILAR',
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                fontSize: 48,
              ),
        ),
        const SizedBox(height: AppSpacing.md),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: Text(
            '15 yarışmacıyı tanı. Final kadronu şimdiden düşünmeye başla.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      ],
    );
  }
}
