import 'dart:convert';

import 'package:scamshield/engine/models.dart';

class PlanStep {
  const new({required this.hinglish, required this.hindi});

  final String hinglish;
  final String hindi;
}

class ActionPlanRule {
  const new({
    required this.id,
    required this.priority,
    required this.urgent,
    required this.titleHinglish,
    required this.titleHindi,
    required this.steps,
    required this.actions,
  });

  final String id;
  final int priority;
  final bool urgent;
  final String titleHinglish;
  final String titleHindi;
  final List<PlanStep> steps;
  final List<String> actions;
}

class ActionPlanAction {
  const new({
    required this.id,
    required this.titleHinglish,
    required this.titleHindi,
    required this.uri,
    required this.style,
    this.note,
  });

  final String id;
  final String titleHinglish;
  final String titleHindi;
  final String uri;
  final String style;
  final String? note;
}

class ActionPlan {
  const new({required this.rules, required this.actions});

  final List<ActionPlanRule> rules;
  final List<ActionPlanAction> actions;
}

class ActionPlanService {
  new(String jsonString) {
    _parsed = jsonDecode(jsonString) as Map<String, dynamic>;
  }

  late final Map<String, dynamic> _parsed;

  /// Generates the tailored action plan according to user [answers] and [level].
  ActionPlan planFor(Answers answers, RiskLevel level) {
    final rulesRaw = _parsed['rules'] as List<dynamic>? ?? [];
    final actionsMapRaw = _parsed['actions'] as Map<String, dynamic>? ?? {};

    final matchedRules = <ActionPlanRule>[];
    for (final raw in rulesRaw) {
      if (raw is! Map<String, dynamic>) continue;
      final when = raw['when'] as String? ?? '';
      var applies = false;

      if (when == 'paid') {
        applies = answers.paid;
      } else if (when == 'shared_credentials') {
        applies = answers.sharedCredentials;
      } else if (when == 'remote_app') {
        applies = answers.remoteApp;
      } else if (when == 'none') {
        final allNo =
            !answers.paid && !answers.sharedCredentials && !answers.remoteApp;
        applies =
            allNo && (level == RiskLevel.medium || level == RiskLevel.high);
      } else if (when == 'low_safe') {
        final allNo =
            !answers.paid && !answers.sharedCredentials && !answers.remoteApp;
        applies = allNo && level == RiskLevel.low;
      }

      if (applies) {
        final title = raw['title'] as Map<String, dynamic>? ?? {};
        final stepsRaw = raw['steps'] as List<dynamic>? ?? [];
        final steps = stepsRaw
            .whereType<Map<String, dynamic>>()
            .map(
              (s) => PlanStep(
                hinglish: s['hinglish'] as String? ?? '',
                hindi: s['hindi'] as String? ?? '',
              ),
            )
            .toList();

        final actions = (raw['actions'] as List<dynamic>? ?? [])
            .map((a) => a.toString())
            .toList();

        matchedRules.add(
          ActionPlanRule(
            id: raw['id'] as String? ?? '',
            priority: (raw['priority'] as num?)?.toInt() ?? 999,
            urgent: raw['urgent'] as bool? ?? false,
            titleHinglish: title['hinglish'] as String? ?? '',
            titleHindi: title['hindi'] as String? ?? '',
            steps: steps,
            actions: actions,
          ),
        );
      }
    }

    // Sort by priority (lower first)
    matchedRules.sort((a, b) => a.priority.compareTo(b.priority));

    // Resolve actions
    final actionIds = <String>{};
    for (final rule in matchedRules) {
      actionIds.addAll(rule.actions);
    }

    if (level == RiskLevel.high) {
      actionIds.add('alert_family');
    }

    final resolvedActions = <ActionPlanAction>[];
    for (final actionId in actionIds) {
      final actRaw = actionsMapRaw[actionId] as Map<String, dynamic>?;
      if (actRaw != null) {
        resolvedActions.add(
          ActionPlanAction(
            id: actionId,
            titleHinglish: actRaw['hinglish'] as String? ?? '',
            titleHindi: actRaw['hindi'] as String? ?? '',
            uri: actRaw['uri'] as String? ?? '',
            style: actRaw['style'] as String? ?? 'secondary',
            note: actRaw['note'] as String?,
          ),
        );
      }
    }

    return ActionPlan(rules: matchedRules, actions: resolvedActions);
  }
}
