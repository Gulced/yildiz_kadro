import 'package:yildiz_kadro/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:yildiz_kadro/app/theme/app_colors.dart';
import 'package:yildiz_kadro/app/theme/app_spacing.dart';
import 'package:yildiz_kadro/features/contestants/domain/contestant.dart';
import 'package:yildiz_kadro/features/contestants/domain/contestant_localization.dart';
import 'package:yildiz_kadro/features/contestants/presentation/widgets/contestant_portrait.dart';

class ContestantCard extends StatelessWidget {
  const ContestantCard({
    required this.contestant,
    required this.onTap,
    super.key,
  });

  final Contestant contestant;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final strongest = contestant.localizedStrongestStat(context);
    final isEn = isAppEnglish(context);
    return Semantics(
      button: true,
      label: isEn
          ? '${contestant.number}, ${contestant.name}, ${contestant.age} yrs, ${contestant.localizedArchetype(context)}'
          : '${contestant.number}, ${contestant.name}, ${contestant.age} yaş, ${contestant.archetype}',
      child: Material(
        color: AppColors.inkSoft,
        shape: const RoundedRectangleBorder(
          side: BorderSide(color: AppColors.line),
          borderRadius: BorderRadius.all(Radius.circular(5)),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(7),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: ContestantPortrait(contestant: contestant)),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Text(
                        contestant.displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      '${contestant.age}',
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  contestant.localizedArchetype(context).toUpperCase(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: AppColors.accentSoft,
                        letterSpacing: 0.7,
                      ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '★ ${strongest.label}  ${strongest.value}',
                  style: Theme.of(context)
                      .textTheme
                      .labelLarge
                      ?.copyWith(color: AppColors.accentBright),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  contestant.localizedOccupation(context),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: AppColors.paper,
                        fontSize: 10,
                        letterSpacing: 0.5,
                      ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  contestant.localizedShortBackground(context),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.paperMuted,
                        fontStyle: FontStyle.italic,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
