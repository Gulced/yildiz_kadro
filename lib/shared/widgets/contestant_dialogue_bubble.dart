import 'package:flutter/material.dart';
import 'package:yildiz_kadro/app/theme/app_colors.dart';
import 'package:yildiz_kadro/app/theme/app_spacing.dart';
import 'package:yildiz_kadro/features/contestants/domain/contestant.dart';
import 'package:yildiz_kadro/features/contestants/presentation/widgets/contestant_portrait.dart';

enum DialogueAlignment { left, right, center }

class ContestantDialogueBubble extends StatelessWidget {
  const ContestantDialogueBubble(
      {required this.contestant,
      required this.text,
      this.alignRight = false,
      this.alignment,
      this.badge,
      this.showName = true,
      this.portraitSize,
      super.key});
  final Contestant contestant;
  final String text;
  final bool alignRight;
  final DialogueAlignment? alignment;
  final String? badge;
  final bool showName;
  final double? portraitSize;
  @override
  Widget build(BuildContext context) {
    final resolvedAlignment = alignment ??
        (alignRight ? DialogueAlignment.right : DialogueAlignment.left);
    final isRight = resolvedAlignment == DialogueAlignment.right;
    final size =
        portraitSize ?? (MediaQuery.sizeOf(context).width < 360 ? 48.0 : 56.0);
    return Align(
        alignment: switch (resolvedAlignment) {
          DialogueAlignment.left => Alignment.centerLeft,
          DialogueAlignment.right => Alignment.centerRight,
          DialogueAlignment.center => Alignment.center,
        },
        child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Row(
                textDirection: isRight ? TextDirection.rtl : TextDirection.ltr,
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipOval(
                      child: SizedBox(
                          width: size,
                          height: size,
                          child: ContestantPortrait(contestant: contestant))),
                  const SizedBox(width: AppSpacing.sm),
                  Flexible(
                      child: Column(
                          crossAxisAlignment: isRight
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                        if (showName)
                          Text(contestant.displayName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .labelMedium
                                  ?.copyWith(color: AppColors.accentBright)),
                        if (badge != null)
                          Text(badge!,
                              maxLines: 1,
                              style: Theme.of(context).textTheme.labelSmall),
                        Container(
                            margin: const EdgeInsets.only(top: 4),
                            padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.md,
                                vertical: AppSpacing.sm),
                            decoration: BoxDecoration(
                                color: AppColors.inkSoft,
                                border: Border.all(color: AppColors.accentSoft),
                                borderRadius: BorderRadius.circular(8)),
                            child: Text(text,
                                maxLines: 3, overflow: TextOverflow.ellipsis)),
                      ])),
                ])));
  }
}
