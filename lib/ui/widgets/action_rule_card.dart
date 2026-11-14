import 'package:flutter/material.dart';
import 'package:scamshield/engine/action_plan_service.dart';
import 'package:scamshield/ui/strings.dart';
import 'package:scamshield/ui/theme/tokens.dart';
import 'package:scamshield/ui/widgets/big_button.dart';

class ActionRuleCard extends StatelessWidget {
  const new({
    required this.rule,
    super.key,
    this.actionMap = const {},
    this.onActionPressed,
  });

  final ActionPlanRule rule;
  final Map<String, ActionPlanAction> actionMap;
  final void Function(ActionPlanAction action)? onActionPressed;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final title = s.isHindi ? rule.titleHindi : rule.titleHinglish;

    final border = rule.urgent
        ? Border.all(color: AppColors.highStrong, width: 1.5)
        : Border.all(color: AppColors.line);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: AppRadius.border20,
        border: border,
        boxShadow: rule.urgent
            ? [
                BoxShadow(
                  color: AppColors.highStrong.withValues(alpha: 0.18),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ]
            : AppShadows.subtle,
      ),
      padding: const EdgeInsets.all(AppSpacing.s20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (rule.urgent) ...[
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.highStrong.withValues(alpha: 0.15),
                    borderRadius: AppRadius.border8,
                  ),
                  child: const Icon(
                    Icons.warning_amber_rounded,
                    color: AppColors.highStrong,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppSpacing.s8),
              ],
              Expanded(
                child: Text(
                  title,
                  style: AppTypography.h2.copyWith(
                    color: rule.urgent ? AppColors.highStrong : AppColors.ink,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s16),
          for (var i = 0; i < rule.steps.length; i++) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.s12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: rule.urgent
                          ? AppColors.highStrong.withValues(alpha: 0.2)
                          : AppColors.elevatedSurface,
                      borderRadius: AppRadius.border8,
                      border: Border.all(
                        color: rule.urgent
                            ? AppColors.highStrong.withValues(alpha: 0.5)
                            : AppColors.line,
                      ),
                    ),
                    child: Text(
                      '${i + 1}',
                      style: AppTypography.label.copyWith(
                        fontSize: 14,
                        color: rule.urgent
                            ? AppColors.highStrong
                            : AppColors.accent,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s12),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        s.isHindi
                            ? rule.steps[i].hindi
                            : rule.steps[i].hinglish,
                        style: AppTypography.body.copyWith(
                          fontSize: 17,
                          height: 1.45,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (rule.actions.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.s12),
            for (final actionId in rule.actions) ...[
              if (actionMap.containsKey(actionId)) ...[
                Builder(
                  builder: (context) {
                    final act = actionMap[actionId]!;
                    final variant = switch (act.style) {
                      'danger' => BigButtonVariant.danger,
                      'secondary' => BigButtonVariant.secondary,
                      _ => BigButtonVariant.primary,
                    };
                    return Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.s8),
                      child: BigButton(
                        label: s.isHindi ? act.titleHindi : act.titleHinglish,
                        variant: variant,
                        subtitle: act.note,
                        onPressed: onActionPressed != null
                            ? () => onActionPressed!(act)
                            : null,
                      ),
                    );
                  },
                ),
              ],
            ],
          ],
        ],
      ),
    );
  }
}
