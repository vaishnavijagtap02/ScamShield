import 'package:flutter/material.dart';
import 'package:scamshield/ui/theme/tokens.dart';

enum BigButtonVariant { primary, secondary, danger }

class BigButton extends StatelessWidget {
  const new({
    required this.label,
    required this.onPressed,
    super.key,
    this.variant = BigButtonVariant.primary,
    this.subtitle,
    this.icon,
    this.enabled = true,
    this.semanticsLabel,
  });

  final String label;
  final VoidCallback? onPressed;
  final BigButtonVariant variant;
  final String? subtitle;
  final IconData? icon;
  final bool enabled;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final isClickable = enabled && onPressed != null;

    final bgColor = switch (variant) {
      BigButtonVariant.primary => AppColors.ink,
      BigButtonVariant.secondary => AppColors.surface,
      BigButtonVariant.danger => AppColors.highStrong,
    };

    final fgColor = switch (variant) {
      BigButtonVariant.primary => AppColors.surface,
      BigButtonVariant.secondary => AppColors.ink,
      BigButtonVariant.danger => AppColors.onHigh,
    };

    final border = switch (variant) {
      BigButtonVariant.secondary => const BorderSide(
        color: AppColors.ink,
        width: 1.5,
      ),
      _ => BorderSide.none,
    };

    final content = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 28, color: fgColor),
          const SizedBox(width: AppSpacing.s12),
        ],
        Flexible(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: subtitle != null
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.center,
            children: [
              Text(
                label,
                style: AppTypography.bodyStrong.copyWith(color: fgColor),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  style: AppTypography.caption.copyWith(
                    color: variant == BigButtonVariant.secondary
                        ? AppColors.inkMuted
                        : fgColor.withValues(alpha: 0.85),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ],
    );

    return Semantics(
      label: semanticsLabel ?? (subtitle != null ? '$label, $subtitle' : label),
      button: true,
      enabled: isClickable,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 150),
        opacity: isClickable ? 1.0 : 0.4,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minWidth: double.infinity,
            minHeight: 64,
          ),
          child: Material(
            color: bgColor,
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.border16,
              side: border,
            ),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: isClickable ? onPressed : null,
              splashColor: fgColor.withValues(alpha: 0.12),
              highlightColor: fgColor.withValues(alpha: 0.08),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.s16,
                  vertical: AppSpacing.s8,
                ),
                child: Center(child: content),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
