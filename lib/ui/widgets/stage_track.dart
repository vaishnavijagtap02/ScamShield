import 'package:flutter/material.dart';
import 'package:scamshield/engine/models.dart';
import 'package:scamshield/ui/strings.dart';
import 'package:scamshield/ui/theme/tokens.dart';
import 'package:scamshield/ui/widgets/stage_stamp.dart';

class StageTrack extends StatelessWidget {
  const new({required this.seenStages, super.key, this.stageTimes = const {}});

  final Set<Stage> seenStages;
  final Map<Stage, double> stageTimes;

  @override
  Widget build(BuildContext context) {
    const canonicalStages = [
      Stage.authority,
      Stage.fear,
      Stage.urgency,
      Stage.secrecy,
      Stage.extraction,
    ];

    final s = S.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: AppRadius.border16,
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.analytics_outlined,
                size: 16,
                color: AppColors.accent,
              ),
              const SizedBox(width: 6),
              Text(
                'TACTIC TRACKER',
                style: AppTypography.caption.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                  fontSize: 11,
                  color: AppColors.inkMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Center(
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: AppSpacing.s8,
              runSpacing: AppSpacing.s12,
              children: canonicalStages.map((stage) {
                final seen = seenStages.contains(stage);
                final atSec = stageTimes[stage];
                return StageStamp(
                  stage: stage,
                  displayName: s.stageName(stage),
                  seen: seen,
                  atSec: atSec,
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
