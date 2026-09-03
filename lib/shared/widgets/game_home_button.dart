import 'package:yildiz_kadro/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:yildiz_kadro/app/theme/app_colors.dart';

class GameHomeButton extends StatelessWidget {
  const GameHomeButton({required this.onPressed, super.key});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Semantics(
        label: isAppEnglish(context) ? 'Home Hub' : 'Ana Merkez',
        button: true,
        enabled: true,
        child: Material(
          color: AppColors.inkSoft.withValues(alpha: .94),
          shape: const CircleBorder(side: BorderSide(color: AppColors.accent)),
          child: IconButton(
            onPressed: onPressed,
            color: AppColors.paper,
            icon: const Icon(Icons.home_outlined),
          ),
        ),
      );
}
