import 'package:flutter/material.dart';
import 'package:yildiz_kadro/app/theme/app_colors.dart';
import 'package:yildiz_kadro/app/theme/app_spacing.dart';
import 'package:yildiz_kadro/core/responsive/breakpoints.dart';
import 'package:yildiz_kadro/core/responsive/responsive_layout.dart';
import 'package:yildiz_kadro/features/contestants/presentation/contestant_dashboard_screen.dart';
import 'package:yildiz_kadro/features/home/presentation/widgets/casting_wall.dart';
import 'package:yildiz_kadro/features/home/presentation/widgets/season_footer.dart';
import 'package:yildiz_kadro/features/home/presentation/widgets/season_mark.dart';
import 'package:yildiz_kadro/features/home/presentation/widgets/show_background.dart';
import 'package:yildiz_kadro/features/home/presentation/widgets/show_wordmark.dart';
import 'package:yildiz_kadro/shared/widgets/app_button.dart';
import 'package:yildiz_kadro/shared/widgets/max_width_container.dart';
import 'package:yildiz_kadro/l10n/l10n.dart';
import 'package:yildiz_kadro/shared/widgets/language_selector.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _openCasting(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const ContestantDashboardScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ShowBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, viewport) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: viewport.maxHeight),
                  child: MaxWidthContainer(
                    maxWidth: AppBreakpoints.maxContentWidth,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.xl,
                      ),
                      child: ResponsiveLayout(
                        compact: (_) =>
                            _PhoneLanding(onStart: () => _openCasting(context)),
                        medium: (_) => _PhoneLanding(
                          onStart: () => _openCasting(context),
                          spacious: true,
                        ),
                        expanded: (_) => _TabletLanding(
                          onStart: () => _openCasting(context),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _PhoneLanding extends StatelessWidget {
  const _PhoneLanding({required this.onStart, this.spacious = false});

  final VoidCallback onStart;
  final bool spacious;

  @override
  Widget build(BuildContext context) {
    final sectionGap = spacious ? AppSpacing.xxl : AppSpacing.xl;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Align(
          alignment: Alignment.centerRight,
          child: LanguageSelector(),
        ),
        const SizedBox(height: AppSpacing.md),
        const ShowWordmark(),
        SizedBox(height: sectionGap),
        _HeroContent(onStart: onStart),
        SizedBox(height: sectionGap),
        const CastingWall(),
        SizedBox(height: sectionGap),
        const SeasonFooter(),
      ],
    );
  }
}

class _TabletLanding extends StatelessWidget {
  const _TabletLanding({required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final usesLargeText = MediaQuery.textScalerOf(context).scale(1) >= 1.5;
    if (usesLargeText) {
      return _PhoneLanding(onStart: onStart, spacious: true);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Align(
          alignment: Alignment.centerRight,
          child: LanguageSelector(),
        ),
        const SizedBox(height: AppSpacing.md),
        const ShowWordmark(),
        const SizedBox(height: AppSpacing.xxl),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(flex: 9, child: _HeroContent(onStart: onStart)),
            const SizedBox(width: AppSpacing.section),
            const Expanded(flex: 10, child: CastingWall()),
          ],
        ),
        const SizedBox(height: AppSpacing.xxl),
        const SeasonFooter(),
      ],
    );
  }
}

class _HeroContent extends StatelessWidget {
  const _HeroContent({required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SeasonMark(),
        const SizedBox(height: AppSpacing.lg),
        Text(context.l10n.contestantsAndGroup, style: textTheme.displayLarge),
        const SizedBox(height: AppSpacing.lg),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Text(context.l10n.landingSupport, style: textTheme.bodyLarge),
        ),
        const SizedBox(height: AppSpacing.xl),
        AppButton(
          label: context.l10n.startSeason.toUpperCase(),
          onPressed: onStart,
        ),
        const SizedBox(height: AppSpacing.md),
        Align(
          alignment: Alignment.centerLeft,
          child: _HowToPlayButton(onPressed: () => _showHowToPlay(context)),
        ),
      ],
    );
  }

  void _showHowToPlay(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.inkSoft,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: .82,
        maxChildSize: .94,
        builder: (context, controller) => ListView(
          controller: controller,
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            Text(
              context.l10n.howToPlay.toUpperCase(),
              style: Theme.of(context).textTheme.displayMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(context.l10n.howToIntro),
            const SizedBox(height: AppSpacing.xl),
            _HowToStep(
              number: '01',
              title: context.l10n.meetContestants,
              body: context.l10n.meetContestantsBody,
            ),
            _HowToStep(
              number: '02',
              title: context.l10n.makeDecisions,
              body: context.l10n.makeDecisionsBody,
            ),
            _HowToStep(
              number: '03',
              title: context.l10n.buildTeams,
              body: context.l10n.buildTeamsBody,
            ),
            _HowToStep(
              number: '04',
              title: context.l10n.liveResults,
              body: context.l10n.liveResultsBody,
            ),
            _HowToStep(
              number: '05',
              title: context.l10n.formLineup,
              body: context.l10n.formLineupBody,
            ),
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              label: context.l10n.understood,
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _HowToStep extends StatelessWidget {
  const _HowToStep({
    required this.number,
    required this.title,
    required this.body,
  });

  final String number;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: AppSpacing.sm),
    padding: const EdgeInsets.all(AppSpacing.md),
    decoration: BoxDecoration(
      border: Border.all(color: AppColors.line),
      color: AppColors.ink,
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          number,
          style: Theme.of(context).textTheme.labelLarge
              ?.copyWith(color: AppColors.accentBright),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: AppSpacing.xs),
              Text(body),
            ],
          ),
        ),
      ],
    ),
  );
}

class _HowToPlayButton extends StatelessWidget {
  const _HowToPlayButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.menu_book_outlined, size: 19),
      label: Text(context.l10n.howToPlay.toUpperCase()),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.paper,
        minimumSize: const Size(0, 50),
        side: const BorderSide(color: AppColors.accent, width: 1.2),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(7)),
        ),
      ),
    );
  }
}
