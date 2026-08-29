import 'package:flutter/material.dart';
import 'package:yildiz_kadro/app/theme/app_colors.dart';
import 'package:yildiz_kadro/app/theme/app_spacing.dart';
import 'package:yildiz_kadro/core/responsive/breakpoints.dart';
import 'package:yildiz_kadro/features/contestants/data/contestant_seed_data.dart';
import 'package:yildiz_kadro/features/contestants/data/contestant_identity_profiles.dart';
import 'package:yildiz_kadro/features/contestants/domain/contestant.dart';
import 'package:yildiz_kadro/features/contestants/presentation/widgets/contestant_portrait.dart';
import 'package:yildiz_kadro/features/first_impression/presentation/first_impression_transition_screen.dart';
import 'package:yildiz_kadro/features/first_impression/presentation/widgets/radar_contestant_card.dart';
import 'package:yildiz_kadro/features/game/application/game_scope.dart';
import 'package:yildiz_kadro/shared/widgets/app_button.dart';

class FirstImpressionScreen extends StatefulWidget {
  const FirstImpressionScreen({super.key});

  @override
  State<FirstImpressionScreen> createState() => _FirstImpressionScreenState();
}

class _FirstImpressionScreenState extends State<FirstImpressionScreen> {
  static const _maximumSelection = 5;
  final Set<int> _selectedIds = {};

  void _toggleContestant(int id, String name) {
    if (_selectedIds.contains(id)) {
      setState(() => _selectedIds.remove(id));
      return;
    }
    if (_selectedIds.length == _maximumSelection) {
      _showFeedback('Radarında sadece 5 kişi olabilir.');
      return;
    }
    setState(() => _selectedIds.add(id));
    _showFeedback('$name radarına girdi ★');
  }

  void _showFeedback(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(milliseconds: 1200),
        ),
      );
  }

  void _confirmRadar() {
    GameScope.of(context).savePlayerRadar(_selectedIds);
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const FirstImpressionTransitionScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    final cardHeight =
        270.0 + ((textScale - 1).clamp(0.0, 1.0) * 100).toDouble();
    final selectionComplete = _selectedIds.length == _maximumSelection;

    return Scaffold(
      backgroundColor: AppColors.ink,
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.ink,
            border: Border(top: BorderSide(color: AppColors.line)),
          ),
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.sm,
            AppSpacing.lg,
            AppSpacing.md,
          ),
          child: Center(
            heightFactor: 1,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: AppButton(
                label: selectionComplete ? 'RADARIM HAZIR' : '5 KİŞİ SEÇ',
                onPressed: selectionComplete ? _confirmRadar : null,
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        bottom: false,
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
                    child: _FirstImpressionHeader(
                      selectedCount: _selectedIds.length,
                      onBack: () => Navigator.of(context).pop(),
                    ),
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                0,
                AppSpacing.md,
                AppSpacing.xl,
              ),
              sliver: SliverLayoutBuilder(
                builder: (context, constraints) {
                  final sideSpace = (constraints.crossAxisExtent - 760)
                          .clamp(0.0, double.infinity) /
                      2;
                  return SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: sideSpace),
                    sliver: SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisExtent: cardHeight,
                        crossAxisSpacing: AppSpacing.sm,
                        mainAxisSpacing: AppSpacing.sm,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final contestant = contestantSeedData[index];
                          return RadarContestantCard(
                            contestant: contestant,
                            isSelected: _selectedIds.contains(contestant.id),
                            onTap: () => _toggleContestant(
                              contestant.id,
                              contestant.displayName,
                            ),
                            onInfo: () => _showPreview(contestant),
                          );
                        },
                        childCount: contestantSeedData.length,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPreview(Contestant contestant) {
    final state = GameScope.of(context);
    final identity = identityFor(contestant);
    final social = state.socialStateFor(contestant.id);
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.inkSoft,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: SizedBox(
                  width: 112,
                  height: 148,
                  child: ContestantPortrait(contestant: contestant),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(contestant.displayName,
                        style: Theme.of(context).textTheme.headlineLarge),
                    Text(contestant.personalityTraits.join(' · ')),
                    const SizedBox(height: AppSpacing.sm),
                    Text(identity.hook,
                        style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
            ]),
            const SizedBox(height: AppSpacing.lg),
            Text('İLK İZLENİM RADARI', style: _previewLabel(context)),
            _PreviewMeter(label: 'VOKAL', value: contestant.vocal),
            _PreviewMeter(label: 'DANS', value: contestant.dance),
            _PreviewMeter(label: 'SAHNE', value: contestant.stage),
            _PreviewMeter(label: 'MOTİVASYON', value: social.motivation),
            _PreviewMeter(label: 'POPÜLERLİK', value: social.popularity),
            const SizedBox(height: AppSpacing.lg),
            Text('HEDEF', style: _previewLabel(context)),
            Text(identity.goal),
            const SizedBox(height: AppSpacing.md),
            Text('GÜÇLÜ TARAF', style: _previewLabel(context)),
            Text(identity.characterStrength),
            const SizedBox(height: AppSpacing.md),
            Text('DİKKAT', style: _previewLabel(context)),
            Text(identity.sensitivity),
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              label: _selectedIds.contains(contestant.id)
                  ? 'RADARDAN ÇIKAR'
                  : 'RADARA AL  ★',
              onPressed: () {
                Navigator.pop(context);
                _toggleContestant(contestant.id, contestant.displayName);
              },
            ),
          ],
        ),
      ),
    );
  }

  TextStyle _previewLabel(BuildContext context) =>
      Theme.of(context).textTheme.labelLarge!.copyWith(
            color: AppColors.accentBright,
            letterSpacing: 1.1,
          );
}

class _PreviewMeter extends StatelessWidget {
  const _PreviewMeter({required this.label, required this.value});
  final String label;
  final int value;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: AppSpacing.sm),
        child: Row(children: [
          SizedBox(width: 100, child: Text(label)),
          Expanded(
            child: LinearProgressIndicator(
              value: value / 100,
              minHeight: 5,
              color: AppColors.accentBright,
              backgroundColor: AppColors.line,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          SizedBox(width: 28, child: Text('$value')),
        ]),
      );
}

class _FirstImpressionHeader extends StatelessWidget {
  const _FirstImpressionHeader({
    required this.selectedCount,
    required this.onBack,
  });

  final int selectedCount;
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
          '1. GÜN',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: AppColors.accentSoft,
                letterSpacing: 1.4,
              ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'İlk izlenimin kimden yana?',
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                fontSize: 43,
                height: 0.98,
              ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          '15 yarışmacıyla tanıştın.\nŞimdilik sadece dikkatini çeken 5 kişiyi seç.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Bu bir eleme değil. Fikrini daha sonra değiştirebilirsin.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.paperMuted,
                fontStyle: FontStyle.italic,
              ),
        ),
        const SizedBox(height: AppSpacing.lg),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 160),
          child: Text(
            '$selectedCount / 5 RADARDA',
            key: ValueKey(selectedCount),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: selectedCount == 5
                      ? AppColors.accentBright
                      : AppColors.paper,
                  letterSpacing: 1,
                ),
          ),
        ),
      ],
    );
  }
}
