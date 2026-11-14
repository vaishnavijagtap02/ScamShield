import 'package:flutter/material.dart';
import 'package:scamshield/ui/theme/tokens.dart';

class SectionCard extends StatelessWidget {
  const new({
    required this.child,
    super.key,
    this.padding = const EdgeInsets.all(AppSpacing.s20),
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
        color: AppColors.cardSurface,
        borderRadius: AppRadius.border20,
        border: Border.all(color: AppColors.line),
        boxShadow: AppShadows.subtle,
      ),
      child: child,
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.border20,
          splashColor: AppColors.accent.withValues(alpha: 0.08),
          highlightColor: AppColors.line.withValues(alpha: 0.3),
          child: cardContent,
        ),
      );
    }

    return cardContent;
  }
}
