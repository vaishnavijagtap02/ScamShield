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
        ? const Border(
            left: BorderSide(color: AppColors.highStrong, width: 6),
            top: BorderSide(color: AppColors.line, width: 1.5),
            right: BorderSide(color: AppColors.line, width: 1.5),
            bottom: BorderSide(color: AppColors.line, width: 1.5),
          )
        : Border.all(color: AppColors.line, width: 1.5);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.border12,
        border: border,
      ),
      padding: const EdgeInsets.all(AppSpacing.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (rule.urgent) ...[
                const Icon(
                  Icons.warning_amber_rounded,
                  color: AppColors.highStrong,
                  size: 24,
                ),
                const SizedBox(width: AppSpacing.s8),
              ],
              Expanded(
                child: Text(
                  title,
                  style: AppTypography.h2.copyWith(
                    color: rule.urgent ? AppColors.highStrong : AppColors.ink,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s12),
          for (var i = 0; i < rule.steps.length; i++) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.s8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.paper,
                      borderRadius: AppRadius.border8,
                      border: Border.all(color: AppColors.line),
                    ),
                    child: Text(
                      '${i + 1}',
                      style: AppTypography.label.copyWith(fontSize: 16),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s12),
                  Expanded(
                    child: Text(
                      s.isHindi ? rule.steps[i].hindi : rule.steps[i].hinglish,
                      style: AppTypography.body,
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
