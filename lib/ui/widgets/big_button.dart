import 'package:flutter/material.dart';
import 'package:scamshield/ui/theme/tokens.dart';

enum BigButtonVariant { primary, secondary, danger }

class BigButton extends StatefulWidget {
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
  State<BigButton> createState() => _BigButtonState();
}

class _BigButtonState extends State<BigButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isClickable = widget.enabled && widget.onPressed != null;

    final (
      bgColor,
      fgColor,
      border,
      shadows,
      gradient,
    ) = switch (widget.variant) {
      BigButtonVariant.primary => (
        AppColors.accent,
        const Color(0xFF0A0D14),
        BorderSide.none,
        isClickable ? AppShadows.card : const <BoxShadow>[],
        const LinearGradient(
          colors: [Color(0xFF00E676), Color(0xFF00C853)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      BigButtonVariant.secondary => (
        AppColors.elevatedSurface,
        AppColors.ink,
        const BorderSide(color: AppColors.line),
        const <BoxShadow>[],
        null,
      ),
      BigButtonVariant.danger => (
        AppColors.highStrong,
        AppColors.onHigh,
        BorderSide.none,
        isClickable
            ? [
                BoxShadow(
                  color: AppColors.highStrong.withValues(alpha: 0.35),
                  blurRadius: 18,
                  offset: const Offset(0, 4),
                ),
              ]
            : const <BoxShadow>[],
        const LinearGradient(
          colors: [Color(0xFFFF5252), Color(0xFFFF1744)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    };

    final content = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.icon != null) ...[
          Icon(
            widget.icon,
            size: 26,
            color: widget.variant == BigButtonVariant.secondary
                ? AppColors.accent
                : fgColor,
          ),
          const SizedBox(width: AppSpacing.s12),
        ],
        Flexible(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: widget.subtitle != null
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.center,
            children: [
              Text(
                widget.label,
                style: AppTypography.bodyStrong.copyWith(
                  color: fgColor,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (widget.subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  widget.subtitle!,
                  style: AppTypography.caption.copyWith(
                    color: widget.variant == BigButtonVariant.secondary
                        ? AppColors.inkMuted
                        : fgColor.withValues(alpha: 0.8),
                    fontSize: 14,
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
      label:
          widget.semanticsLabel ??
          (widget.subtitle != null
              ? '${widget.label}, ${widget.subtitle}'
              : widget.label),
      button: true,
      enabled: isClickable,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 150),
        opacity: isClickable ? 1.0 : 0.45,
        child: AnimatedScale(
          scale: _isPressed && isClickable ? 0.98 : 1.0,
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeInOut,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minWidth: double.infinity,
              minHeight: 64,
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: AppRadius.border16,
                boxShadow: shadows,
              ),
              child: Material(
                color: gradient == null ? bgColor : Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadius.border16,
                  side: border,
                ),
                clipBehavior: Clip.antiAlias,
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: gradient,
                    borderRadius: AppRadius.border16,
                  ),
                  child: InkWell(
                    onTap: isClickable ? widget.onPressed : null,
                    onHighlightChanged: (pressed) {
                      setState(() => _isPressed = pressed);
                    },
                    splashColor: fgColor.withValues(alpha: 0.12),
                    highlightColor: fgColor.withValues(alpha: 0.08),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.s20,
                        vertical: AppSpacing.s12,
                      ),
                      child: Center(child: content),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
