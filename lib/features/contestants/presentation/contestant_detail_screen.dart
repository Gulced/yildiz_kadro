import 'package:flutter/material.dart';
import 'package:yildiz_kadro/app/theme/app_colors.dart';
import 'package:yildiz_kadro/app/theme/app_spacing.dart';
import 'package:yildiz_kadro/features/contestants/domain/contestant.dart';
import 'package:yildiz_kadro/features/contestants/domain/contestant_localization.dart';
import 'package:yildiz_kadro/features/contestants/data/contestant_identity_profiles.dart';
import 'package:yildiz_kadro/features/contestants/presentation/widgets/contestant_portrait.dart';
import 'package:yildiz_kadro/features/contestants/presentation/widgets/contestant_detail_back_button.dart';
import 'package:yildiz_kadro/features/contestants/presentation/widgets/dossier_tag.dart';
import 'package:yildiz_kadro/features/contestants/presentation/widgets/stat_bar.dart';
import 'package:yildiz_kadro/features/contestants/presentation/contestant_dashboard_screen.dart';
import 'package:yildiz_kadro/l10n/l10n.dart';

class ContestantDetailScreen extends StatelessWidget {
  const ContestantDetailScreen({required this.contestant, super.key});

  final Contestant contestant;

  @override
  Widget build(BuildContext context) {
    final navigator = Navigator.of(context);
    final canPop = navigator.canPop();
    return PopScope(
      canPop: canPop,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _openContestantDashboard(context);
      },
      child: Scaffold(
        backgroundColor: AppColors.ink,
        body: Stack(
          children: [
            SafeArea(
              child: SingleChildScrollView(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 860),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.lg,
                        AppSpacing.sm,
                        AppSpacing.lg,
                        AppSpacing.section,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 44),
                          const SizedBox(height: AppSpacing.md),
                          _IdentityHeader(contestant: contestant),
                          const SizedBox(height: AppSpacing.xl),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 430),
                              child: AspectRatio(
                                aspectRatio: 0.82,
                                child: ContestantPortrait(
                                  contestant: contestant,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          _Quote(quote: contestant.localizedQuote(context)),
                          const SizedBox(height: AppSpacing.section),
                          _StorySection(contestant: contestant),
                          const SizedBox(height: AppSpacing.section),
                          _PersonalitySection(contestant: contestant),
                          const SizedBox(height: AppSpacing.xl),
                          _EditorialSection(
                            label: context.l10n.goal,
                            child: Text(localizedGoal(contestant, context)),
                          ),
                          const SizedBox(height: AppSpacing.xxl),
                          _FeatureSection(
                            label: context.l10n.specialTrait,
                            icon: Icons.bolt_rounded,
                            title: contestant.localizedSpecialTraitTitle(
                              context,
                            ),
                            description: contestant
                                .localizedSpecialTraitDescription(context),
                            accent: true,
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          _FeatureSection(
                            label: context.l10n.risk,
                            icon: Icons.warning_amber_rounded,
                            title: contestant.localizedRiskTitle(context),
                            description: contestant.localizedRiskDescription(
                              context,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.section),
                          _TalentReport(contestant: contestant),
                          const SizedBox(height: AppSpacing.section),
                          _RoleSection(contestant: contestant),
                          const SizedBox(height: AppSpacing.section),
                          _ProducerNote(
                            note: contestant.localizedProducerNote(context),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            PositionedDirectional(
              top: 0,
              start: 0,
              child: SafeArea(
                minimum: const EdgeInsets.only(
                  left: AppSpacing.lg,
                  top: AppSpacing.sm,
                ),
                child: ContestantDetailBackButton(
                  onPressed: () => _handleBack(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleBack(BuildContext context) {
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop();
      return;
    }
    _openContestantDashboard(context);
  }

  void _openContestantDashboard(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => const ContestantDashboardScreen(),
      ),
    );
  }
}

class _IdentityHeader extends StatelessWidget {
  const _IdentityHeader({required this.contestant});

  final Contestant contestant;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isEn = isAppEnglish(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isEn
              ? 'CONTESTANT ${contestant.number}'
              : 'YARIŞMACI ${contestant.number}',
          style: textTheme.labelMedium?.copyWith(color: AppColors.accentSoft),
        ),
        const SizedBox(height: AppSpacing.sm),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(contestant.displayName, style: textTheme.displayLarge),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          '${contestant.age} • ${contestant.city}',
          style: textTheme.headlineSmall?.copyWith(
            color: AppColors.accentBright,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          contestant.localizedOccupation(context),
          style: textTheme.bodyLarge?.copyWith(color: AppColors.paper),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          contestant.localizedArchetype(context).toUpperCase(),
          style: textTheme.labelMedium?.copyWith(
            color: AppColors.accentSoft,
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }
}

class _Quote extends StatelessWidget {
  const _Quote({required this.quote});

  final String quote;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: AppSpacing.lg),
      decoration: const BoxDecoration(
        border: Border(left: BorderSide(color: AppColors.accent, width: 3)),
      ),
      child: Text(
        '“$quote”',
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w500,
              height: 1.35,
            ),
      ),
    );
  }
}

class _StorySection extends StatelessWidget {
  const _StorySection({required this.contestant});

  final Contestant contestant;

  @override
  Widget build(BuildContext context) {
    return _EditorialSection(
      label: context.l10n.story,
      child: Text(
        contestant.localizedFullBackground(context),
        style: Theme.of(context)
            .textTheme
            .bodyLarge
            ?.copyWith(color: AppColors.paper, height: 1.65),
      ),
    );
  }
}

class _PersonalitySection extends StatelessWidget {
  const _PersonalitySection({required this.contestant});

  final Contestant contestant;

  @override
  Widget build(BuildContext context) {
    return _EditorialSection(
      label: context.l10n.personality,
      child: Wrap(
        spacing: AppSpacing.xs,
        runSpacing: AppSpacing.xs,
        children: [
          for (final trait in contestant.localizedPersonalityTraits(context))
            DossierTag(label: trait.toUpperCase()),
        ],
      ),
    );
  }
}

class _FeatureSection extends StatelessWidget {
  const _FeatureSection({
    required this.label,
    required this.icon,
    required this.title,
    required this.description,
    this.accent = false,
  });

  final String label;
  final IconData icon;
  final String title;
  final String description;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.line),
          bottom: BorderSide(color: AppColors.line),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Icon(
                icon,
                color: accent ? AppColors.accent : AppColors.accentSoft,
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  title.toUpperCase(),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color:
                            accent ? AppColors.accentBright : AppColors.paper,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(description, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }
}

class _TalentReport extends StatelessWidget {
  const _TalentReport({required this.contestant});

  final Contestant contestant;

  @override
  Widget build(BuildContext context) {
    return _EditorialSection(
      label: context.l10n.talentReport,
      child: Column(
        children: [
          StatBar(label: context.l10n.vocal, value: contestant.vocal),
          const SizedBox(height: AppSpacing.md),
          StatBar(label: context.l10n.dance, value: contestant.dance),
          const SizedBox(height: AppSpacing.md),
          StatBar(label: context.l10n.stage, value: contestant.stage),
          const SizedBox(height: AppSpacing.md),
          StatBar(label: context.l10n.popularity, value: contestant.popularity),
          const SizedBox(height: AppSpacing.md),
          StatBar(label: context.l10n.potential, value: contestant.potential),
        ],
      ),
    );
  }
}

class _RoleSection extends StatelessWidget {
  const _RoleSection({required this.contestant});

  final Contestant contestant;

  @override
  Widget build(BuildContext context) {
    return _EditorialSection(
      label: context.l10n.role,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            contestant.localizedPrimaryRole(context),
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(color: AppColors.accentBright),
          ),
          if (contestant.secondaryRoles.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              contestant.localizedSecondaryRoles(context).join(' • '),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ],
      ),
    );
  }
}

class _ProducerNote extends StatelessWidget {
  const _ProducerNote({required this.note});

  final String note;

  @override
  Widget build(BuildContext context) {
    return _EditorialSection(
      label: context.l10n.producerNoteLabel,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        color: AppColors.inkSoft,
        child: Text(
          '“$note”',
          style: Theme.of(context)
              .textTheme
              .bodyLarge
              ?.copyWith(color: AppColors.paper, fontStyle: FontStyle.italic),
        ),
      ),
    );
  }
}

class _EditorialSection extends StatelessWidget {
  const _EditorialSection({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(
                label,
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            const Expanded(child: Divider(height: 1)),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        child,
      ],
    );
  }
}
