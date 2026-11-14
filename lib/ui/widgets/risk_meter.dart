import 'package:flutter/material.dart';
import 'package:scamshield/engine/models.dart';
import 'package:scamshield/ui/strings.dart';
import 'package:scamshield/ui/theme/motion.dart';
import 'package:scamshield/ui/theme/tokens.dart';

class RiskMeter extends StatelessWidget {
  const new({required this.score, required this.level, super.key});

  final int score;
  final RiskLevel level;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final clampedScore = score.clamp(0, 100);
    final (levelColor, gradient, levelName) = switch (level) {
      RiskLevel.high => (
        AppColors.highStrong,
        const LinearGradient(
          colors: [Color(0xFFFF5252), Color(0xFFFF1744)],
        ),
        s.levelKhatra,
      ),
      RiskLevel.medium => (
        AppColors.medStrong,
        const LinearGradient(
          colors: [Color(0xFFFFD54F), Color(0xFFFFB300)],
        ),
        s.levelSavdhan,
      ),
      RiskLevel.low => (
        AppColors.accent,
        const LinearGradient(
          colors: [Color(0xFF69F0AE), Color(0xFF00E676)],
        ),
        s.levelTheek,
      ),
    };

    final duration = AppMotion.getDuration(
      context,
      AppMotion.riskMeterDuration,
    );

    return Semantics(
      label: 'Risk score $clampedScore, $levelName',
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.s16),
        decoration: BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: AppRadius.border16,
          border: Border.all(color: AppColors.line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.speed_rounded,
                      size: 18,
                      color: AppColors.inkMuted,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Risk Score',
                      style: AppTypography.caption.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                        fontSize: 14,
                        color: AppColors.ink,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: levelColor.withValues(alpha: 0.16),
                    borderRadius: AppRadius.border8,
                    border: Border.all(
                      color: levelColor.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Text(
                    '$clampedScore / 100',
                    style: AppTypography.caption.copyWith(
                      fontWeight: FontWeight.w800,
                      color: levelColor,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.s12),
            ClipRRect(
              borderRadius: AppRadius.border8,
              child: Container(
                height: 18,
                decoration: BoxDecoration(
                  color: AppColors.elevatedSurface,
                  borderRadius: AppRadius.border8,
                  border: Border.all(color: AppColors.line),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final fillWidth =
                        constraints.maxWidth * (clampedScore / 100.0);
                    return Stack(
                      children: [
                        // Zone dividers (30% and 70%)
                        Positioned(
                          left: constraints.maxWidth * 0.30,
                          top: 0,
                          bottom: 0,
                          child: Container(width: 1.5, color: AppColors.line),
                        ),
                        Positioned(
                          left: constraints.maxWidth * 0.70,
                          top: 0,
                          bottom: 0,
                          child: Container(width: 1.5, color: AppColors.line),
                        ),
                        // Animated Fill Bar
                        AnimatedContainer(
                          duration: duration,
                          curve: AppMotion.defaultCurve,
                          width: fillWidth,
                          height: 18,
                          decoration: BoxDecoration(
                            gradient: gradient,
                            borderRadius: AppRadius.border8,
                            boxShadow: [
                              BoxShadow(
                                color: levelColor.withValues(alpha: 0.4),
                                blurRadius: 10,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Theek',
                  style: AppTypography.caption.copyWith(
                    fontSize: 13,
                    fontWeight: level == RiskLevel.low
                        ? FontWeight.w700
                        : FontWeight.w400,
                    color: level == RiskLevel.low
                        ? AppColors.accent
                        : AppColors.inkMuted,
                  ),
                ),
                Text(
                  'Savdhan',
                  style: AppTypography.caption.copyWith(
                    fontSize: 13,
                    fontWeight: level == RiskLevel.medium
                        ? FontWeight.w700
                        : FontWeight.w400,
                    color: level == RiskLevel.medium
                        ? AppColors.medStrong
                        : AppColors.inkMuted,
                  ),
                ),
                Text(
                  'Khatra',
                  style: AppTypography.caption.copyWith(
                    fontSize: 13,
                    fontWeight: level == RiskLevel.high
                        ? FontWeight.w700
                        : FontWeight.w400,
                    color: level == RiskLevel.high
                        ? AppColors.highStrong
                        : AppColors.inkMuted,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
