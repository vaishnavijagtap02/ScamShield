import 'package:flutter/material.dart';
import 'package:scamshield/engine/models.dart';
import 'package:scamshield/ui/theme/tokens.dart';

class StageStamp extends StatelessWidget {
  const new({
    required this.stage,
    required this.displayName,
    super.key,
    this.seen = false,
    this.atSec,
  });

  final Stage stage;
  final String displayName;
  final bool seen;
  final double? atSec;

  static String _formatTimestamp(double sec) {
    final totalSec = sec.floor();
    final m = (totalSec ~/ 60).toString().padLeft(2, '0');
    final s = (totalSec % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final stampBox = Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s12,
        vertical: AppSpacing.s8,
      ),
      decoration: BoxDecoration(
        color: seen ? AppColors.surface : Colors.transparent,
        borderRadius: AppRadius.border8,
        border: seen
            ? Border.all(color: AppColors.ink, width: 2)
            : Border.all(color: AppColors.line, width: 1.5),
      ),
      child: Text(
        displayName,
        style: AppTypography.label.copyWith(
          color: seen ? AppColors.ink : AppColors.inkMuted,
          fontWeight: seen ? FontWeight.w700 : FontWeight.w600,
        ),
      ),
    );

    final styledStamp = seen
        ? Transform.rotate(
            angle: -0.035, // -2 degrees
            child: stampBox,
          )
        : stampBox;

    return Semantics(
      label: '$displayName: ${seen ? "detected" : "not detected"}',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          styledStamp,
          const SizedBox(height: 4),
          Text(
            seen && atSec != null ? _formatTimestamp(atSec!) : '--:--',
            style: AppTypography.caption.copyWith(
              color: seen
                  ? AppColors.ink
                  : AppColors.inkMuted.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}
