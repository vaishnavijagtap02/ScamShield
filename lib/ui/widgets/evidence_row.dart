import 'package:flutter/material.dart';
import 'package:scamshield/engine/models.dart';
import 'package:scamshield/ui/strings.dart';
import 'package:scamshield/ui/theme/tokens.dart';

class EvidenceRow extends StatelessWidget {
  const new({required this.event, super.key});

  final TacticEvent event;

  static String _formatTimestamp(double sec) {
    final totalSec = sec.floor();
    final m = (totalSec ~/ 60).toString().padLeft(2, '0');
    final s = (totalSec % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final stageStr = s.stageName(event.stage);

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.s12),
      padding: const EdgeInsets.all(AppSpacing.s16),
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.elevatedSurface,
                  borderRadius: AppRadius.border8,
                  border: Border.all(color: AppColors.line),
                ),
                child: Text(
                  _formatTimestamp(event.atSec),
                  style: AppTypography.caption.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.accent,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.s8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.highStrong.withValues(alpha: 0.15),
                  borderRadius: AppRadius.border8,
                ),
                child: Text(
                  '· $stageStr',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.highStrong,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
              const Spacer(),
              if (event.source == EventSource.lexicon)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.elevatedSurface,
                    borderRadius: AppRadius.border8,
                    border: Border.all(color: AppColors.line),
                  ),
                  child: Text(
                    'Lexicon Pattern',
                    style: AppTypography.caption.copyWith(
                      fontSize: 11,
                      color: AppColors.inkMuted,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.s12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.s12),
            decoration: BoxDecoration(
              color: AppColors.elevatedSurface,
              borderRadius: AppRadius.border8,
              border: const Border(
                left: BorderSide(color: AppColors.accent, width: 3),
              ),
            ),
            child: Text(
              '"${event.quote}"',
              style: AppTypography.body.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.ink,
                fontStyle: FontStyle.italic,
                fontSize: 18,
              ),
            ),
          ),
          if (event.explanationHi != null &&
              event.explanationHi!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.s8),
            Text(
              event.explanationHi!,
              style: AppTypography.caption.copyWith(
                color: AppColors.inkMuted,
                fontSize: 14,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
