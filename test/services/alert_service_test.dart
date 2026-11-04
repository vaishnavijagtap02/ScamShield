import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:scamshield/engine/models.dart';
import 'package:scamshield/services/alert_service.dart';
import 'package:scamshield/services/guardian_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AlertTextBuilder', () {
    const verdict = Verdict(
      level: RiskLevel.high,
      score: 100,
      scamType: ScamType.digitalArrest,
      evidence: [
        TacticEvent(
          stage: Stage.fear,
          quote: 'parcel mein narcotics mila hai',
          atSec: 10,
          confidence: 0.95,
          source: EventSource.llm,
        ),
        TacticEvent(
          stage: Stage.authority,
          quote: 'hum CBI headquarters se bol rahe hain',
          atSec: 2,
          confidence: 0.99,
          source: EventSource.llm,
        ),
        TacticEvent(
          stage: Stage.urgency,
          quote: 'agli flight se police bhej rahe hain',
          atSec: 35,
          confidence: 0.85,
          source: EventSource.llm,
        ),
        TacticEvent(
          stage: Stage.secrecy,
          quote: 'kisi ko mat batana',
          atSec: 45,
          confidence: 0.70,
          source: EventSource.llm,
        ),
      ],
      entities: Entities(),
      summaryHi: 'CBI ke naam pe digital arrest ki dhamki di gayi.',
    );

    test('builds alert text with max 3 quotes, highest confidence first, <= 700 chars', () {
      const answers = Answers();
      final text = AlertTextBuilder.build(
        verdict: verdict,
        answers: answers,
        userName: 'Papa',
      );

      expect(text, contains('ScamShield: Papa ne ek call check ki — KHATRA'));
      expect(
        text,
        contains('CBI ke naam pe digital arrest ki dhamki di gayi.'),
      );
      expect(text, contains('Saboot:'));
      // Authority (0.99) should come before Fear (0.95)
      expect(
        text.indexOf('hum CBI headquarters se bol rahe hain'),
        lessThan(text.indexOf('parcel mein narcotics mila hai')),
      );
      // Secrecy (0.70) is 4th quote -> must not be included (max 3)
      expect(text, isNot(contains('kisi ko mat batana')));
      // paid is false
      expect(text, contains('Please abhi unhe call karein.'));
      expect(text.length, lessThanOrEqualTo(700));
    });

    test('paid is true shows 1930 reporting advice', () {
      const answers = Answers(paid: true);
      final text = AlertTextBuilder.build(verdict: verdict, answers: answers);

      expect(text, contains('Aapke parivaar ke sadasya'));
      expect(
        text,
        contains(
          'Paise bhej diye gaye hain — abhi call karein aur 1930 pe report karwayein.',
        ),
      );
      expect(text.length, lessThanOrEqualTo(700));
    });

    test('truncates quotes when text would otherwise exceed 700 chars', () {
      final longEvidence = [
        TacticEvent(
          stage: Stage.fear,
          quote: 'A' * 400,
          atSec: 10,
          confidence: 0.99,
          source: EventSource.llm,
        ),
        TacticEvent(
          stage: Stage.authority,
          quote: 'B' * 400,
          atSec: 20,
          confidence: 0.95,
          source: EventSource.llm,
        ),
      ];

      final longVerdict = Verdict(
        level: RiskLevel.high,
        score: 100,
        scamType: ScamType.digitalArrest,
        evidence: longEvidence,
        entities: const Entities(),
        summaryHi: 'Summary ' * 10,
      );

      final text = AlertTextBuilder.build(
        verdict: longVerdict,
        answers: const Answers(paid: true),
      );

      expect(text.length, lessThanOrEqualTo(700));
    });
  });

  group('TelegramAlertService', () {
    const token = '123456:ABC-DEF1234ghIkl-zyx57W2v1u123ew11';
    const botUsername = 'ScamShieldAlertBot';

    test(
      'pollForPairing saves guardian on matching code and ignores wrong code',
      () async {
        final updatesJson = jsonEncode({
          'ok': true,
          'result': [
            {
              'update_id': 1001,
              'message': {
                'message_id': 10,
                'from': {'id': 111, 'first_name': 'Unknown'},
                'chat': {'id': 111},
                'text': '/start WRONG_CODE',
              },
            },
            {
              'update_id': 1002,
              'message': {
                'message_id': 11,
                'from': {'id': 222, 'first_name': 'Ramesh Kumar'},
                'chat': {'id': 222},
                'text': '/start PAIR_CODE_1',
              },
            },
          ],
        });

        final mockClient = MockClient((request) async {
          expect(request.url.toString(), contains('getUpdates'));
          return http.Response(updatesJson, 200);
        });

        final service = TelegramAlertService(
          botToken: token,
          botUsername: botUsername,
          client: mockClient,
        );

        final guardian = await service.pollForPairing('PAIR_CODE_1');
        expect(guardian, isNotNull);
        expect(guardian!.name, equals('Ramesh Kumar'));
        expect(guardian.chatId, equals(222));
        expect(service.lastOffset, equals(1003));
      },
    );

    test('sendAlert sends plain text with no parse_mode and reports per-guardian results', () async {
      const guardians = [
        Guardian(name: 'Guardian 1', chatId: 101),
        Guardian(name: 'Guardian 2', chatId: 102),
      ];

      final requestsReceived = <http.BaseRequest>[];
      final mockClient = MockClient((request) async {
        requestsReceived.add(request);
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body.containsKey('parse_mode'), isFalse);
        expect(body['text'], isNotEmpty);

        if (body['chat_id'] == 101) {
          return http.Response(jsonEncode({'ok': true}), 200);
        } else {
          return http.Response(jsonEncode({'ok': false}), 400);
        }
      });

      final service = TelegramAlertService(
        botToken: token,
        botUsername: botUsername,
        client: mockClient,
      );

      final results = await service.sendAlert(
        text: 'ScamShield Alert: Test message',
        guardians: guardians,
      );

      expect(results[101], isTrue);
      expect(results[102], isFalse);
      expect(requestsReceived.length, equals(2));
    });
  });

  group('GuardianStore', () {
    test('persists guardians and settings in SharedPreferences', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final prefs = await SharedPreferences.getInstance();
      final store = GuardianStore(prefs);

      expect(store.getGuardians(), isEmpty);
      expect(store.getAutoAlert(), isTrue);

      const guardian = Guardian(name: 'Beta', chatId: 555);
      await store.saveGuardian(guardian);

      final loaded = store.getGuardians();
      expect(loaded.length, equals(1));
      expect(loaded.first.name, equals('Beta'));
      expect(loaded.first.chatId, equals(555));

      await store.setAutoAlert(enabled: false);
      expect(store.getAutoAlert(), isFalse);

      await store.setUserName('Mataji');
      expect(store.getUserName(), equals('Mataji'));

      await store.removeGuardian(555);
      expect(store.getGuardians(), isEmpty);
    });
  });
}
