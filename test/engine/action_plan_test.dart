import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:scamshield/engine/action_plan_service.dart';
import 'package:scamshield/engine/models.dart';

void main() {
  late String actionPlanJson;
  late ActionPlanService service;

  setUpAll(() {
    actionPlanJson = File('assets/action_plan.json').readAsStringSync();
    service = ActionPlanService(actionPlanJson);
  });

  group('ActionPlanService', () {
    test('paid: true returns urgent 1930 rule first', () {
      const answers = Answers(paid: true);
      final plan = service.planFor(answers, RiskLevel.high);

      expect(plan.rules, isNotEmpty);
      expect(plan.rules.first.id, equals('paid'));
      expect(plan.rules.first.urgent, isTrue);
      expect(plan.rules.first.actions, contains('call_1930'));

      // High risk ensures alert_family is present in plan actions
      expect(plan.actions.any((a) => a.id == 'alert_family'), isTrue);
    });

    test('all no + MEDIUM returns none rule', () {
      const answers = Answers();
      final plan = service.planFor(answers, RiskLevel.medium);

      expect(plan.rules.length, equals(1));
      expect(plan.rules.first.id, equals('none'));
      expect(plan.rules.first.actions, contains('open_chakshu'));
    });

    test('all no + HIGH returns none rule with alert_family', () {
      const answers = Answers();
      final plan = service.planFor(answers, RiskLevel.high);

      expect(plan.rules.length, equals(1));
      expect(plan.rules.first.id, equals('none'));
      expect(plan.actions.any((a) => a.id == 'alert_family'), isTrue);
    });

    test('all no + LOW returns low_safe rule and no alert_family', () {
      const answers = Answers();
      final plan = service.planFor(answers, RiskLevel.low);

      expect(plan.rules.length, equals(1));
      expect(plan.rules.first.id, equals('low_safe'));
      expect(plan.actions.any((a) => a.id == 'alert_family'), isFalse);
    });

    test('shared_credentials and remote_app both true', () {
      const answers = Answers(sharedCredentials: true, remoteApp: true);
      final plan = service.planFor(answers, RiskLevel.high);

      final ruleIds = plan.rules.map((r) => r.id).toList();
      expect(
        ruleIds,
        containsAll(<String>['shared_credentials', 'remote_app']),
      );
      expect(plan.actions.any((a) => a.id == 'alert_family'), isTrue);
    });
  });
}
