import 'package:flutter/material.dart';
import 'package:yildiz_kadro/app/theme/app_colors.dart';

class ContestantDetailBackButton extends StatelessWidget {
  const ContestantDetailBackButton({
    required this.onPressed,
    super.key,
  });

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Semantics(
        label: 'Yarışmacılara dön',
        button: true,
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.ink.withValues(alpha: .82),
            border: Border.all(
              color: AppColors.accent.withValues(alpha: .72),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .38),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: SizedBox.square(
            dimension: 44,
            child: IconButton(
              onPressed: onPressed,
              padding: EdgeInsets.zero,
              iconSize: 21,
              color: AppColors.paper,
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
            ),
          ),
        ),
      );
}
