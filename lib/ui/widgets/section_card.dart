import 'package:flutter/material.dart';
import 'package:scamshield/ui/theme/tokens.dart';

class SectionCard extends StatelessWidget {
  const new({
    required this.child,
    super.key,
    this.padding = const EdgeInsets.all(AppSpacing.s16),
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cardContent = Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.border12,
        border: Border.all(color: AppColors.line, width: 1.5),
      ),
      child: child,
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.border12,
          splashColor: AppColors.ink.withValues(alpha: 0.06),
          child: cardContent,
        ),
      );
    }

    return cardContent;
  }
}
