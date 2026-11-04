import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:scamshield/engine/grounding.dart';
import 'package:scamshield/engine/models.dart';

void main() {
  group('Grounding on scam_cbi script', () {
    test('rejects hallucinated quote and hallucinated phone', () {
      final file = File('assets/demo/scripts.json');
      final jsonMap =
          jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
      final rawScripts = (jsonMap['scripts'] as List<dynamic>)
          .cast<Map<String, dynamic>>();
      final cbiRaw = rawScripts.firstWhere((s) => s['id'] == 'scam_cbi');
      final script = DemoScript.fromJson(cbiRaw);

      final result = Grounding.filter(
        events: script.llm!.events,
        entities: script.llm!.entities,
        segments: script.segments,
      );

      // Hallucinated quote must be rejected
      final quotes = result.events.map((e) => e.quote).toList();
      expect(quotes, isNot(contains('apne bete ko phone mat karna')));

      // Hallucinated phone must be rejected
      expect(result.entities.phones, isNot(contains('9876543210')));
      expect(result.entities.phones, isEmpty);

      // Valid entities kept
      expect(result.entities.claimedAgency, 'CBI');
      expect(result.entities.claimedName, 'Inspector Sharma');

      // Valid quotes kept with re-derived atSec
      expect(result.events.length, 5);
      final authEvent = result.events.firstWhere(
        (e) => e.stage == Stage.authority,
      );
      expect(authEvent.atSec, 0.0);

      final fearEvent = result.events.firstWhere((e) => e.stage == Stage.fear);
      expect(fearEvent.atSec, 12.0);

      final urgEvent = result.events.firstWhere(
        (e) => e.stage == Stage.urgency,
      );
      expect(urgEvent.atSec, 18.0);

      final secEvent = result.events.firstWhere(
        (e) => e.stage == Stage.secrecy,
      );
      expect(secEvent.atSec, 24.0);

      final extEvent = result.events.firstWhere(
        (e) => e.stage == Stage.extraction,
      );
      expect(extEvent.atSec, 36.0);
    });

    test('punctuation and case differences still match', () {
      final segments = [
        const Segment(
          index: 0,
          startSec: 10,
          endSec: 15,
          text: 'Namaste! Main Mumbai Police Cyber-Cell se bol raha hoon.',
        ),
      ];

      final events = [
        const TacticEvent(
          stage: Stage.authority,
          quote: 'main mumbai police cyber cell',
          atSec: 999, // LLM hallucinated time
          confidence: 0.9,
          source: EventSource.llm,
        ),
      ];

      final result = Grounding.filter(
        events: events,
        entities: const Entities(claimedAgency: 'MUMBAI POLICE'),
        segments: segments,
      );

      expect(result.events.length, 1);
      expect(result.events.first.atSec, 10.0);
      expect(result.entities.claimedAgency, 'MUMBAI POLICE');
    });

    test('quotes spanning two segments match via sliding join', () {
      final segments = [
        const Segment(
          index: 0,
          startSec: 0,
          endSec: 5,
          text: 'Aapka parcel customs ne',
        ),
        const Segment(
          index: 1,
          startSec: 5,
          endSec: 10,
          text: 'rok liya hai Mumbai airport par.',
        ),
      ];

      final events = [
        const TacticEvent(
          stage: Stage.fear,
          quote: 'customs ne rok liya hai',
          atSec: 0,
          confidence: 0.85,
          source: EventSource.llm,
        ),
      ];

      final result = Grounding.filter(
        events: events,
        entities: const Entities(),
        segments: segments,
      );

      expect(result.events.length, 1);
      expect(result.events.first.atSec, 0.0);
    });

    test('rejects quotes with less than 3 words', () {
      final segments = [
        const Segment(
          index: 0,
          startSec: 0,
          endSec: 5,
          text: 'Namaste police officer',
        ),
      ];

      final events = [
        const TacticEvent(
          stage: Stage.authority,
          quote: 'police officer',
          atSec: 0,
          confidence: 0.9,
          source: EventSource.llm,
        ),
      ];

      final result = Grounding.filter(
        events: events,
        entities: const Entities(),
        segments: segments,
      );

      expect(result.events, isEmpty);
    });
  });
}
