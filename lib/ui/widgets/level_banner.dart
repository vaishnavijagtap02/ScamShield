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

    final (bgColor, fgColor, icon, title, defaultSub) = switch (level) {
      RiskLevel.high => (
        AppColors.highStrong,
        AppColors.onHigh,
        Icons.warning_amber_rounded,
        s.levelKhatra,
        s.levelKhatraSub,
      ),
      RiskLevel.medium => (
        AppColors.medTint,
        AppColors.medInk,
        Icons.error_outline_rounded,
        s.levelSavdhan,
        s.levelSavdhanSub,
      ),
      RiskLevel.low => (
        AppColors.lowTint,
        AppColors.lowStrong,
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
          horizontal: AppSpacing.screenPadding,
          vertical: AppSpacing.s24,
        ),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: AppRadius.border12,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 40, color: fgColor),
            const SizedBox(width: AppSpacing.s16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.display.copyWith(color: fgColor),
                  ),
                  const SizedBox(height: AppSpacing.s4),
                  Text(
                    subtitle,
                    style: AppTypography.body.copyWith(
                      color: fgColor.withValues(alpha: 0.95),
                      fontWeight: FontWeight.w600,
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
