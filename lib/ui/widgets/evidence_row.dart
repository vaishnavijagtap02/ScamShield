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
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.s12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.line, width: 1.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.paper,
                  borderRadius: AppRadius.border8,
                  border: Border.all(color: AppColors.line),
                ),
                child: Text(
                  _formatTimestamp(event.atSec),
                  style: AppTypography.caption.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.s8),
              Text(
                '· $stageStr',
                style: AppTypography.label.copyWith(color: AppColors.ink),
              ),
              const Spacer(),
              if (event.source == EventSource.lexicon)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.line.withValues(alpha: 0.5),
                    borderRadius: AppRadius.border8,
                  ),
                  child: Text(
                    'Lexicon',
                    style: AppTypography.caption.copyWith(fontSize: 12),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.s8),
          Container(
            padding: const EdgeInsets.all(AppSpacing.s8),
            decoration: BoxDecoration(
              color: AppColors.highlight,
              borderRadius: AppRadius.border8,
            ),
            child: Text(
              '"${event.quote}"',
              style: AppTypography.body.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.ink,
              ),
            ),
          ),
          if (event.explanationHi != null &&
              event.explanationHi!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.s4),
            Text(
              event.explanationHi!,
              style: AppTypography.caption.copyWith(color: AppColors.inkMuted),
            ),
          ],
        ],
      ),
    );
  }
}
