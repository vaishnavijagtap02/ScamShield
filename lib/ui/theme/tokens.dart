import 'package:flutter/material.dart';

class AppColors {
  const new _();

  // ── Core surfaces ──────────────────────────────────────────────────
  static const Color paper = Color(0xFF0F0F0F);
  static const Color surface = Color(0xFF1A1A1A);
  static const Color cardSurface = Color(0xFF1A1A1A);
  static const Color elevatedSurface = Color(0xFF222222);

  // ── Text ───────────────────────────────────────────────────────────
  static const Color ink = Color(0xFFF0F0F0);
  static const Color inkMuted = Color(0xFF888888);

  // ── Lines & highlights ─────────────────────────────────────────────
  static const Color line = Color(0xFF2A2A2A);
  static const Color highlight = Color(0x2000E676);

  // ── Risk: low (safe / emerald) ─────────────────────────────────────
  static const Color lowStrong = Color(0xFF00E676);
  static const Color lowTint = Color(0x1A00E676);

  // ── Risk: medium (amber) ───────────────────────────────────────────
  static const Color medStrong = Color(0xFFFFB300);
  static const Color medTint = Color(0x1AFFB300);
  static const Color medInk = Color(0xFFFFD54F);

  // ── Risk: high (vivid red) ─────────────────────────────────────────
  static const Color highStrong = Color(0xFFFF3D3D);
  static const Color onHigh = Color(0xFFFFFFFF);

  // ── Accent & interaction ───────────────────────────────────────────
  static const Color focus = Color(0xFF00E676);
  static const Color accent = Color(0xFF00E676);
  static const Color accentMuted = Color(0x6600E676);
  static const Color shimmer = Color(0xFF2E2E2E);
}

class AppShadows {
  const new _();

  static const List<BoxShadow> subtle = [
    BoxShadow(color: Color(0x14000000), blurRadius: 8, offset: Offset(0, 2)),
  ];

  static const List<BoxShadow> card = [
    BoxShadow(color: Color(0x28000000), blurRadius: 16, offset: Offset(0, 4)),
    BoxShadow(color: Color(0x0A00E676), blurRadius: 24, offset: Offset(0, 2)),
  ];

  static const List<BoxShadow> elevated = [
    BoxShadow(color: Color(0x3C000000), blurRadius: 32, offset: Offset(0, 8)),
    BoxShadow(color: Color(0x1400E676), blurRadius: 40, offset: Offset(0, 4)),
  ];
}

class AppGradients {
  const new _();

  static const LinearGradient heroGlow = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0F0F0F), Color(0xFF0A1F14)],
  );

  static const LinearGradient accentFade = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0x3300E676), Color(0x00000000)],
  );

  static const LinearGradient dangerFade = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0x33FF3D3D), Color(0x00000000)],
  );
}

class AppSpacing {
  const new _();

  static const double s4 = 4;
  static const double s8 = 8;
  static const double s12 = 12;
  static const double s16 = 16;
  static const double s20 = 20;
  static const double s24 = 24;
  static const double s32 = 32;
  static const double s48 = 48;

  static const double screenPadding = 20;
  static const double buttonGap = 16;

  // ── Responsive breakpoints ─────────────────────────────────────────
  static const double mobile = 600;
  static const double tablet = 1024;
  static const double desktop = 1440;
}

class AppRadius {
  const new _();

  static const double r8 = 8;
  static const double r12 = 12;
  static const double r16 = 16;
  static const double r20 = 20;
  static const double r24 = 24;
  static const double r32 = 32;

  static const Radius radius8 = Radius.circular(r8);
  static const Radius radius12 = Radius.circular(r12);
  static const Radius radius16 = Radius.circular(r16);
  static const Radius radius20 = Radius.circular(r20);
  static const Radius radius24 = Radius.circular(r24);
  static const Radius radius32 = Radius.circular(r32);

  static final BorderRadius border8 = BorderRadius.circular(r8);
  static final BorderRadius border12 = BorderRadius.circular(r12);
  static final BorderRadius border16 = BorderRadius.circular(r16);
  static final BorderRadius border20 = BorderRadius.circular(r20);
  static final BorderRadius border24 = BorderRadius.circular(r24);
  static final BorderRadius border32 = BorderRadius.circular(r32);
}

class AppTypography {
  const new _();

  static const String fontFamily = 'Mukta';
  static const List<String> fontFallback = ['Roboto', 'sans-serif'];

  static const TextStyle display = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFallback,
    fontSize: 40,
    height: 1.15,
    fontWeight: FontWeight.w800,
    color: AppColors.ink,
  );

  static const TextStyle h1 = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFallback,
    fontSize: 30,
    height: 1.2,
    fontWeight: FontWeight.w700,
    color: AppColors.ink,
  );

  static const TextStyle h2 = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFallback,
    fontSize: 24,
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
