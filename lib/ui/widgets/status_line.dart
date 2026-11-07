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
        ? AppColors.lowStrong
        : AppColors.ink;

    final icon = isError
        ? Icons.error_outline_rounded
        : isSuccess
        ? Icons.check_circle_outline_rounded
        : Icons.info_outline_rounded;

    return Semantics(
      label: message,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s12,
          vertical: AppSpacing.s8,
        ),
        decoration: BoxDecoration(
          color: isError
              ? AppColors.highStrong.withValues(alpha: 0.08)
              : isSuccess
              ? AppColors.lowTint
              : AppColors.paper,
          borderRadius: AppRadius.border8,
          border: Border.all(
            color: isError
                ? AppColors.highStrong
                : isSuccess
                ? AppColors.lowStrong
                : AppColors.line,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: fgColor),
            const SizedBox(width: AppSpacing.s8),
            Expanded(
              child: Text(
                message,
                style: AppTypography.caption.copyWith(
                  fontWeight: FontWeight.w600,
                  color: fgColor,
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
                    horizontal: 8,
                    vertical: 4,
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
