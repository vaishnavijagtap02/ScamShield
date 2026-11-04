import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:scamshield/engine/complaint_service.dart';
import 'package:scamshield/engine/grounding.dart';
import 'package:scamshield/engine/lexicon.dart';
import 'package:scamshield/engine/models.dart';
import 'package:scamshield/engine/risk_engine.dart';

void main() {
  group('ComplaintService', () {
    test(
      'build for scam_cbi matches template, has >=4 quotes, no rejected phone',
      () {
        final jsonFile = File('assets/demo/scripts.json');
        final jsonMap =
            jsonDecode(jsonFile.readAsStringSync()) as Map<String, dynamic>;
        final rawScripts = (jsonMap['scripts'] as List<dynamic>)
            .cast<Map<String, dynamic>>();
        final scriptMap = rawScripts.firstWhere((s) => s['id'] == 'scam_cbi');

        final script = DemoScript.fromJson(scriptMap);

        final lexiconEvents = <TacticEvent>[];
        for (final segment in script.segments) {
          lexiconEvents.addAll(Lexicon.scan(segment));
        }

        final llmResult = Grounding.filter(
          events: script.llm!.events,
          entities: script.llm!.entities,
          segments: script.segments,
        );

        final allEvents = [...lexiconEvents, ...llmResult.events];
        final riskResult = RiskEngine.evaluate(allEvents);
        final evidence = RiskEngine.selectEvidence(allEvents);

        final verdict = Verdict(
          level: riskResult.level,
          score: riskResult.score,
          scamType: ScamType.digitalArrest,
          evidence: evidence,
          entities: llmResult.entities,
          summaryHi: 'Aapko darakar paise lene ki koshish ki ja rahi hai.',
        );

        const answers = Answers();

        final testDate = DateTime(2026, 11, 4);
        final complaint = ComplaintService.build(verdict, answers, testDate);

        // Asserts
        expect(
          complaint,
          contains(
            'Subject: Suspected digital arrest fraud call on 04 Nov 2026',
          ),
        );
        expect(
          complaint,
          contains('I received a call from an unknown number on 04 Nov 2026.'),
        );
        expect(
          complaint,
          contains('The caller claimed to be Inspector Sharma from CBI.'),
        );
        // Ensure hallucinated phone 9876543210 is NOT in complaint
        expect(complaint, isNot(contains('9876543210')));

        // At least 4 timed quotes in evidence section
        final quoteLines = complaint
            .split('\n')
            .where((line) => line.trim().startsWith('- ['))
            .toList();
        expect(quoteLines.length, greaterThanOrEqualTo(4));

        // Contains blanks for unknown details
        expect(complaint, contains('______'));
        expect(complaint, contains('Money sent by me: No'));
        expect(complaint, contains('OTP/PIN/bank details shared: No'));
        expect(
          complaint,
          contains('Remote-access app installed / screen shared: No'),
        );
        expect(
          complaint,
          contains('I request action against the above numbers/accounts.'),
        );
        expect(
          complaint,
          contains('Name: ______   Phone: ______   City/District: ______'),
        );
      },
    );

    test('paid and accounts present populate correctly', () {
      final testDate = DateTime(2026, 11, 4);
      const verdict = Verdict(
        level: RiskLevel.high,
        score: 100,
        scamType: ScamType.kycBank,
        evidence: [],
        entities: Entities(
          phones: ['+919876543210'],
          claimedAgency: 'SBI Bank',
          accounts: ['1234567890'],
          amountAsked: '50000',
        ),
        summaryHi: 'Test summary',
      );

      const answers = Answers(
        paid: true,
        sharedCredentials: true,
        remoteApp: true,
      );

      final complaint = ComplaintService.build(verdict, answers, testDate);

      expect(complaint, contains('+919876543210'));
      expect(
        complaint,
        contains('Money/details requested: 50000 | Account: 1234567890'),
      );
      expect(
        complaint,
        contains('Money sent by me: Yes - UTR/Transaction ID: ______'),
      );
      expect(complaint, contains('OTP/PIN/bank details shared: Yes'));
      expect(
        complaint,
        contains('Remote-access app installed / screen shared: Yes'),
      );
    });
  });
}
