import 'package:flutter/material.dart';
import 'package:yildiz_kadro/app/theme/app_colors.dart';

abstract final class AppTypography {
  static const TextTheme textTheme = TextTheme(
    displayLarge: TextStyle(
      color: AppColors.paper,
      fontSize: 64,
      height: 0.98,
      fontWeight: FontWeight.w900,
      letterSpacing: -2.6,
    ),
    headlineSmall: TextStyle(
      color: AppColors.paper,
      fontSize: 24,
      height: 1.16,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.5,
    ),
    bodyLarge: TextStyle(
      color: AppColors.paperMuted,
      fontSize: 18,
      height: 1.5,
      fontWeight: FontWeight.w400,
    ),
    labelLarge: TextStyle(
      fontSize: 15,
      height: 1.2,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.2,
    ),
    labelMedium: TextStyle(
      color: AppColors.paperMuted,
      fontSize: 12,
      height: 1.4,
      fontWeight: FontWeight.w700,
      letterSpacing: 1.8,
    ),
  );
}
