import 'package:flutter/material.dart';
import 'package:yildiz_kadro/app/theme/app_colors.dart';
import 'package:yildiz_kadro/app/theme/app_typography.dart';

abstract final class AppTheme {
  static ThemeData get dark {
    const colorScheme = ColorScheme.dark(
      primary: AppColors.accent,
      onPrimary: AppColors.accentInk,
      surface: AppColors.ink,
      onSurface: AppColors.paper,
      outline: AppColors.line,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.ink,
      textTheme: AppTypography.textTheme,
      dividerColor: AppColors.line,
      splashFactory: InkSparkle.splashFactory,
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: AppColors.accent,
        contentTextStyle: TextStyle(
          color: AppColors.accentInk,
          fontWeight: FontWeight.w700,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.paper,
          textStyle: AppTypography.textTheme.labelLarge,
        ),
      ),
    );
  }
}
