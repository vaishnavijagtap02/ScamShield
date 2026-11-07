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
    final levelColor = switch (level) {
      RiskLevel.high => AppColors.highStrong,
      RiskLevel.medium => AppColors.medStrong,
      RiskLevel.low => AppColors.lowStrong,
    };

    final levelName = switch (level) {
      RiskLevel.high => s.levelKhatra,
      RiskLevel.medium => s.levelSavdhan,
      RiskLevel.low => s.levelTheek,
    };

    final duration = AppMotion.getDuration(
      context,
      AppMotion.riskMeterDuration,
    );

    return Semantics(
      label: 'Risk score $clampedScore, $levelName',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Risk Score',
                style: AppTypography.caption.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '$clampedScore / 100',
                style: AppTypography.caption.copyWith(
                  fontWeight: FontWeight.w700,
                  color: levelColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s8),
          ClipRRect(
            borderRadius: AppRadius.border8,
            child: Container(
              height: 16,
              decoration: BoxDecoration(
                color: AppColors.line,
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
                        child: Container(width: 1.5, color: AppColors.paper),
                      ),
                      Positioned(
                        left: constraints.maxWidth * 0.70,
                        top: 0,
                        bottom: 0,
                        child: Container(width: 1.5, color: AppColors.paper),
                      ),
                      // Animated Fill Bar
                      AnimatedContainer(
                        duration: duration,
                        curve: AppMotion.defaultCurve,
                        width: fillWidth,
                        height: 16,
                        decoration: BoxDecoration(
                          color: levelColor,
                          borderRadius: AppRadius.border8,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Theek',
                style: AppTypography.caption.copyWith(fontSize: 14),
              ),
              Text(
                'Savdhan',
                style: AppTypography.caption.copyWith(fontSize: 14),
              ),
              Text(
                'Khatra',
                style: AppTypography.caption.copyWith(fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
