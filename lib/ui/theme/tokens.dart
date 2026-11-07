import 'package:flutter/material.dart';

class AppColors {
  const new _();

  static const Color paper = Color(0xFFF7F3EC);
  static const Color surface = Color(0xFFFFFDF8);
  static const Color ink = Color(0xFF1D1B18);
  static const Color inkMuted = Color(0xFF55504A);
  static const Color line = Color(0xFFDDD5C7);
  static const Color highlight = Color(0xFFFFE8A3);

  static const Color lowStrong = Color(0xFF175234);
  static const Color lowTint = Color(0xFFE3F0E7);

  static const Color medStrong = Color(0xFF9A6400);
  static const Color medTint = Color(0xFFFBEFD5);
  static const Color medInk = Color(0xFF4A3000);

  static const Color highStrong = Color(0xFFA21C15);
  static const Color onHigh = Color(0xFFFFFFFF);

  static const Color focus = Color(0xFF1D1B18);
}

class AppSpacing {
  const new _();

  static const double s4 = 4;
  static const double s8 = 8;
  static const double s12 = 12;
  static const double s16 = 16;
  static const double s24 = 24;
  static const double s32 = 32;
  static const double s48 = 48;

  static const double screenPadding = 24;
  static const double buttonGap = 16;
}

class AppRadius {
  const new _();

  static const double r8 = 8;
  static const double r12 = 12;
  static const double r16 = 16;

  static const Radius radius8 = Radius.circular(r8);
  static const Radius radius12 = Radius.circular(r12);
  static const Radius radius16 = Radius.circular(r16);

  static final BorderRadius border8 = BorderRadius.circular(r8);
  static final BorderRadius border12 = BorderRadius.circular(r12);
  static final BorderRadius border16 = BorderRadius.circular(r16);
}

class AppTypography {
  const new _();

  static const String fontFamily = 'Mukta';
  static const List<String> fontFallback = ['Roboto', 'sans-serif'];

  static const TextStyle display = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFallback,
    fontSize: 36,
    height: 1.15,
    fontWeight: FontWeight.w800,
    color: AppColors.ink,
  );

  static const TextStyle h1 = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFallback,
    fontSize: 28,
    height: 1.2,
    fontWeight: FontWeight.w700,
    color: AppColors.ink,
  );

  static const TextStyle h2 = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFallback,
    fontSize: 22,
    height: 1.3,
    fontWeight: FontWeight.w700,
    color: AppColors.ink,
  );

  static const TextStyle body = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFallback,
    fontSize: 20,
    height: 1.5,
    fontWeight: FontWeight.w400,
    color: AppColors.ink,
  );

  static const TextStyle bodyStrong = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFallback,
    fontSize: 20,
    height: 1.5,
    fontWeight: FontWeight.w600,
    color: AppColors.ink,
  );

  static const TextStyle label = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFallback,
    fontSize: 18,
    height: 1.3,
    fontWeight: FontWeight.w600,
    color: AppColors.ink,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFallback,
    fontSize: 16,
    height: 1.4,
    fontWeight: FontWeight.w400,
    color: AppColors.inkMuted,
    fontFeatures: [FontFeature.tabularFigures()],
  );
}
