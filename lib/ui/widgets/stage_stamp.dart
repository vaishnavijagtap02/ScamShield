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
        color: seen
            ? AppColors.highStrong.withValues(alpha: 0.16)
            : AppColors.elevatedSurface.withValues(alpha: 0.5),
        borderRadius: AppRadius.border12,
        border: seen
            ? Border.all(color: AppColors.highStrong, width: 1.5)
            : Border.all(color: AppColors.line),
        boxShadow: seen
            ? [
                BoxShadow(
                  color: AppColors.highStrong.withValues(alpha: 0.25),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (seen) ...[
            const Icon(
              Icons.warning_amber_rounded,
              size: 14,
              color: AppColors.highStrong,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            displayName,
            style: AppTypography.label.copyWith(
              color: seen ? AppColors.highStrong : AppColors.inkMuted,
              fontWeight: seen ? FontWeight.w800 : FontWeight.w600,
              fontSize: 15,
            ),
          ),
        ],
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
          const SizedBox(height: 6),
          Text(
            seen && atSec != null ? _formatTimestamp(atSec!) : '--:--',
            style: AppTypography.caption.copyWith(
              color: seen
                  ? AppColors.ink
                  : AppColors.inkMuted.withValues(alpha: 0.5),
              fontWeight: seen ? FontWeight.w700 : FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
