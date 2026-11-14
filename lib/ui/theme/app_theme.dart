import 'package:flutter/material.dart';
import 'package:scamshield/ui/theme/tokens.dart';

class AppTheme {
  const new _();

  static ThemeData get darkTheme {
    const colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.accent,
      onPrimary: Color(0xFF003D1F),
      secondary: AppColors.inkMuted,
      onSecondary: AppColors.ink,
      error: AppColors.highStrong,
      onError: AppColors.onHigh,
      surface: AppColors.surface,
      onSurface: AppColors.ink,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.paper,
      fontFamily: AppTypography.fontFamily,
      splashFactory: InkRipple.splashFactory,

      // ── AppBar ───────────────────────────────────────────────────────
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: AppTypography.h1,
        iconTheme: IconThemeData(color: AppColors.ink, size: 28),
      ),

      // ── Divider ──────────────────────────────────────────────────────
      dividerTheme: const DividerThemeData(
        color: AppColors.line,
        thickness: 1,
        space: 1,
      ),

      // ── Card ─────────────────────────────────────────────────────────
      cardTheme: CardThemeData(
        color: AppColors.cardSurface,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.border20),
        margin: EdgeInsets.zero,
      ),

      // ── InputDecoration ──────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.elevatedSurface,
        hintStyle: AppTypography.body.copyWith(color: AppColors.inkMuted),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s16,
          vertical: AppSpacing.s12,
        ),
        border: OutlineInputBorder(
          borderRadius: AppRadius.border16,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.border16,
          borderSide: const BorderSide(color: AppColors.line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.border16,
          borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.border16,
          borderSide: const BorderSide(color: AppColors.highStrong),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadius.border16,
          borderSide: const BorderSide(color: AppColors.highStrong, width: 1.5),
        ),
      ),

      // ── BottomSheet ──────────────────────────────────────────────────
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.elevatedSurface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: AppRadius.radius24),
        ),
        showDragHandle: true,
        dragHandleColor: AppColors.line,
      ),

      // ── Switch ───────────────────────────────────────────────────────
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.accent;
          }
          return AppColors.inkMuted;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.accentMuted;
          }
          return AppColors.line;
        }),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),

      // ── ElevatedButton ───────────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: const Color(0xFF003D1F),
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s24,
            vertical: AppSpacing.s12,
          ),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.border16),
          textStyle: AppTypography.label,
        ),
      ),

      // ── OutlinedButton ───────────────────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.ink,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s24,
            vertical: AppSpacing.s12,
          ),
          side: const BorderSide(color: AppColors.line),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.border16),
          textStyle: AppTypography.label,
        ),
      ),
    );
  }

  /// Backward-compatible alias — old call-sites use `AppTheme.lightTheme`.
  static ThemeData get lightTheme => darkTheme;
}
