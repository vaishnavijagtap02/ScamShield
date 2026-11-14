import 'package:flutter/material.dart';
import 'package:scamshield/engine/models.dart';
import 'package:scamshield/ui/strings.dart';
import 'package:scamshield/ui/theme/tokens.dart';

class LevelBanner extends StatelessWidget {
  const new({required this.level, super.key, this.customSubtitle});

  final RiskLevel level;
  final String? customSubtitle;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    final (
      gradient,
      borderColor,
      glowColor,
      icon,
      title,
      defaultSub,
    ) = switch (level) {
      RiskLevel.high => (
        const LinearGradient(
          colors: [Color(0xFF4A0E0E), Color(0xFF1E0707)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        AppColors.highStrong,
        AppColors.highStrong.withValues(alpha: 0.3),
        Icons.warning_amber_rounded,
        s.levelKhatra,
        s.levelKhatraSub,
      ),
      RiskLevel.medium => (
        const LinearGradient(
          colors: [Color(0xFF422C05), Color(0xFF1C1302)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        AppColors.medStrong,
        AppColors.medStrong.withValues(alpha: 0.3),
        Icons.error_outline_rounded,
        s.levelSavdhan,
        s.levelSavdhanSub,
      ),
      RiskLevel.low => (
        const LinearGradient(
          colors: [Color(0xFF09331D), Color(0xFF03140B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        AppColors.accent,
        AppColors.accent.withValues(alpha: 0.3),
        Icons.check_circle_outline_rounded,
        s.levelTheek,
        s.levelTheekSub,
      ),
    };

    final subtitle = customSubtitle ?? defaultSub;

    return Semantics(
      label: 'Verdict banner: $title, $subtitle',
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s20,
          vertical: AppSpacing.s20,
        ),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: AppRadius.border20,
          border: Border.all(color: borderColor, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: glowColor,
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: borderColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(color: borderColor.withValues(alpha: 0.5)),
              ),
              child: Icon(icon, size: 36, color: borderColor),
            ),
            const SizedBox(width: AppSpacing.s16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.display.copyWith(
                      color: AppColors.ink,
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTypography.body.copyWith(
                      color: AppColors.ink.withValues(alpha: 0.85),
                      fontWeight: FontWeight.w600,
                      fontSize: 17,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
