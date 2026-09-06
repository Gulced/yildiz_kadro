import 'package:flutter/material.dart';
import 'package:yildiz_kadro/app/theme/app_colors.dart';

abstract final class AppTypography {
  static const TextTheme textTheme = TextTheme(
    displayLarge: TextStyle(
      color: AppColors.paper,
      fontSize: 34,
      height: 1.08,
      fontWeight: FontWeight.w900,
      letterSpacing: -1.2,
    ),
    headlineMedium: TextStyle(
      color: AppColors.paper,
      fontSize: 26,
      height: 1.15,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.8,
    ),
    headlineSmall: TextStyle(
      color: AppColors.paper,
      fontSize: 22,
      height: 1.2,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.4,
    ),
    titleLarge: TextStyle(
      color: AppColors.paper,
      fontSize: 18,
      height: 1.3,
      fontWeight: FontWeight.w700,
    ),
    titleMedium: TextStyle(
      color: AppColors.paper,
      fontSize: 16,
      height: 1.35,
      fontWeight: FontWeight.w600,
    ),
    bodyLarge: TextStyle(
      color: AppColors.paperMuted,
      fontSize: 16,
      height: 1.45,
      fontWeight: FontWeight.w400,
    ),
    bodyMedium: TextStyle(
      color: AppColors.paperMuted,
      fontSize: 14,
      height: 1.4,
      fontWeight: FontWeight.w400,
    ),
    labelLarge: TextStyle(
      fontSize: 15,
      height: 1.2,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.3,
    ),
    labelMedium: TextStyle(
      color: AppColors.paperMuted,
      fontSize: 12,
      height: 1.3,
      fontWeight: FontWeight.w700,
      letterSpacing: 1.4,
    ),
    labelSmall: TextStyle(
      color: AppColors.paperMuted,
      fontSize: 11,
      height: 1.2,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.8,
    ),
  );

  static const TextStyle tvEyebrow = TextStyle(
    color: AppColors.accentBright,
    fontSize: 11,
    fontWeight: FontWeight.w800,
    letterSpacing: 1.6,
  );

  static const TextStyle tvHeadline = TextStyle(
    color: AppColors.paper,
    fontSize: 24,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.5,
    height: 1.15,
  );

  static const TextStyle tvSubhead = TextStyle(
    color: AppColors.paperMuted,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  static const TextStyle tvMetricPositive = TextStyle(
    color: Color(0xFF4EFA9A),
    fontSize: 13,
    fontWeight: FontWeight.w800,
    letterSpacing: 0.4,
  );

  static const TextStyle tvMetricNegative = TextStyle(
    color: Color(0xFFFF6666),
    fontSize: 13,
    fontWeight: FontWeight.w800,
    letterSpacing: 0.4,
  );
}
