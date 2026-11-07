import 'package:flutter/material.dart';
import 'package:scamshield/ui/theme/tokens.dart';

class AppTheme {
  const new _();

  static ThemeData get lightTheme {
    const colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.ink,
      onPrimary: AppColors.surface,
      secondary: AppColors.inkMuted,
      onSecondary: AppColors.surface,
      error: AppColors.highStrong,
      onError: AppColors.onHigh,
      surface: AppColors.surface,
      onSurface: AppColors.ink,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.paper,
      fontFamily: AppTypography.fontFamily,
      splashFactory: InkRipple.splashFactory,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.paper,
        foregroundColor: AppColors.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: AppTypography.h1,
        iconTheme: IconThemeData(color: AppColors.ink, size: 28),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.line,
        thickness: 1.5,
        space: 1.5,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.border12,
          side: const BorderSide(color: AppColors.line, width: 1.5),
        ),
        margin: EdgeInsets.zero,
      ),
    );
  }
}
