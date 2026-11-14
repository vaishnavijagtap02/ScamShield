import 'package:flutter/material.dart';
import 'package:scamshield/ui/theme/tokens.dart';

class StatusLine extends StatelessWidget {
  const new({
    required this.message,
    super.key,
    this.isError = false,
    this.isSuccess = false,
    this.onRetry,
    this.retryLabel = 'Dobara bhejein',
  });

  final String message;
  final bool isError;
  final bool isSuccess;
  final VoidCallback? onRetry;
  final String retryLabel;

  @override
  Widget build(BuildContext context) {
    final fgColor = isError
        ? AppColors.highStrong
        : isSuccess
        ? AppColors.accent
        : AppColors.ink;

    final bgColor = isError
        ? AppColors.highStrong.withValues(alpha: 0.12)
        : isSuccess
        ? AppColors.accent.withValues(alpha: 0.12)
        : AppColors.elevatedSurface;

    final borderColor = isError
        ? AppColors.highStrong.withValues(alpha: 0.35)
        : isSuccess
        ? AppColors.accent.withValues(alpha: 0.35)
        : AppColors.line;

    final icon = isError
        ? Icons.error_outline_rounded
        : isSuccess
        ? Icons.check_circle_outline_rounded
        : Icons.info_outline_rounded;

    return Semantics(
      label: message,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s16,
          vertical: AppSpacing.s12,
        ),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: AppRadius.border12,
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: fgColor),
            const SizedBox(width: AppSpacing.s12),
            Expanded(
              child: Text(
                message,
                style: AppTypography.caption.copyWith(
                  fontWeight: FontWeight.w600,
                  color: fgColor,
                  fontSize: 15,
                ),
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(width: AppSpacing.s8),
              InkWell(
                onTap: onRetry,
                borderRadius: AppRadius.border8,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  child: Text(
                    retryLabel,
                    style: AppTypography.caption.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.highStrong,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
