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
                        compact: (_) => _PhoneLanding(
                          onStart: () => _openCasting(context),
                        ),
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
    final usesLargeText = MediaQuery.textScalerOf(context).scale(1) >= 1.5;
    final contestantLabel = usesLargeText ? 'yarış\u00ADmacı.' : 'yarışmacı.';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SeasonMark(),
        const SizedBox(height: AppSpacing.lg),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(text: '15 $contestantLabel\n'),
              const TextSpan(
                text: '5 kişilik\nbir grup.',
                style: TextStyle(color: AppColors.accentBright),
              ),
            ],
          ),
          style: textTheme.displayLarge,
        ),
        const SizedBox(height: AppSpacing.lg),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Text(
            'Takımları kur, kararlarını ver ve final kadrosunu sen oluştur.',
            style: textTheme.bodyLarge,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        AppButton(label: 'SEZONA BAŞLA', onPressed: onStart),
        const SizedBox(height: AppSpacing.md),
        Align(
          alignment: Alignment.centerLeft,
          child: _HowToPlayButton(
            onPressed: () => _showHowToPlay(context),
          ),
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
            Text('NASIL OYNANIR?',
                style: Theme.of(context).textTheme.displayMedium),
            const SizedBox(height: AppSpacing.sm),
            const Text(
              'Sen bir yarışmacı değil, sezonun yapımcısısın. Kararların sahneyi ve ilişkileri değiştirir.',
            ),
            const SizedBox(height: AppSpacing.xl),
            const _HowToStep(
              number: '01',
              title: 'YARIŞMACILARI TANI',
              body:
                  '15 adayın yeteneklerini, hedeflerini ve karakterlerini keşfet.',
            ),
            const _HowToStep(
              number: '02',
              title: 'KARAR VER',
              body:
                  'Radarını kur, jüri kararlarına müdahale et ve riskleri yönet.',
            ),
            const _HowToStep(
              number: '03',
              title: 'TAKIMLARI KUR',
              body:
                  'Kaptan, rol ve konsept seçimleriyle sahne uyumunu şekillendir.',
            ),
            const _HowToStep(
              number: '04',
              title: 'SONUÇLARI YAŞA',
              body:
                  'Her tercih performansları, ilişkileri ve izleyici ilgisini etkiler.',
            ),
            const _HowToStep(
              number: '05',
              title: 'KADRONU ÇIKAR',
              body:
                  'Finalde beş üyeyi, pozisyonları, lideri ve grup adını sen belirle.',
            ),
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              label: 'ANLADIM',
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
            Text(number,
                style: Theme.of(context)
                    .textTheme
                    .labelLarge
                    ?.copyWith(color: AppColors.accentBright)),
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
      label: const Text('NASIL OYNANIR?'),
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
