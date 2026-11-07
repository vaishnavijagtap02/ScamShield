import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:scamshield/engine/action_plan_service.dart';
import 'package:scamshield/engine/models.dart';
import 'package:scamshield/state/providers.dart';
import 'package:scamshield/ui/strings.dart';
import 'package:scamshield/ui/theme/tokens.dart';
import 'package:scamshield/ui/widgets/action_rule_card.dart';
import 'package:scamshield/ui/widgets/big_button.dart';
import 'package:url_launcher/url_launcher.dart';

class ActionPlanScreen extends ConsumerStatefulWidget {
  const new({super.key, this.answers});

  final Answers? answers;

  @override
  ConsumerState<ActionPlanScreen> createState() => _ActionPlanScreenState();
}

class _ActionPlanScreenState extends ConsumerState<ActionPlanScreen> {
  ActionPlanService? _planService;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    unawaited(_loadService());
  }

  Future<void> _loadService() async {
    try {
      final jsonStr = await rootBundle.loadString('assets/action_plan.json');
      setState(() {
        _planService = ActionPlanService(jsonStr);
        _isLoading = false;
      });
    } on Object {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleAction(ActionPlanAction action) async {
    final uri = Uri.tryParse(action.uri);
    if (uri != null) {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsControllerProvider);
    final s = S(settings.language);

    final analysisState = ref.watch(analysisControllerProvider);
    final verdict = analysisState.verdict;
    final answers = widget.answers ?? const Answers();

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(s.planTitle)),
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.ink),
        ),
      );
    }

    final level = verdict?.level ?? RiskLevel.high;
    final plan = _planService?.planFor(answers, level);
    final matchedRules = plan?.rules ?? [];
    final actionMap = {
      for (final a in plan?.actions ?? <ActionPlanAction>[]) a.id: a,
    };

    return Scaffold(
      appBar: AppBar(title: Text(s.planTitle)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenPadding,
            vertical: AppSpacing.s16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: matchedRules.isEmpty
                    ? const Center(
                        child: Text(
                          'No action plan rules found.',
                          style: AppTypography.body,
                        ),
                      )
                    : ListView.separated(
                        itemCount: matchedRules.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: AppSpacing.s16),
                        itemBuilder: (context, index) {
                          final rule = matchedRules[index];
                          return ActionRuleCard(
                            rule: rule,
                            actionMap: actionMap,
                            onActionPressed: _handleAction,
                          );
                        },
                      ),
              ),
              const SizedBox(height: AppSpacing.s16),
              BigButton(
                label: s.draftComplaintBtn,
                onPressed: () async {
                  await context.push('/complaint', extra: answers);
                },
              ),
              const SizedBox(height: AppSpacing.s12),
            ],
          ),
        ),
      ),
    );
  }
}
