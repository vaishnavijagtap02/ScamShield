import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:scamshield/engine/grounding.dart';
import 'package:scamshield/engine/lexicon.dart';
import 'package:scamshield/engine/models.dart';
import 'package:scamshield/engine/risk_engine.dart';

void main() {
  group('RiskEngine - Lexicon + Grounded LLM Vectors (TESTING.md §3)', () {
    test('all 6 demo scripts match primary vector expectations', () {
      final file = File('assets/demo/scripts.json');
      final jsonMap =
          jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
      final rawScripts = (jsonMap['scripts'] as List<dynamic>)
          .cast<Map<String, dynamic>>();

      final expected = {
        'scam_cbi': {
          'stages': {
            Stage.authority,
            Stage.fear,
            Stage.urgency,
            Stage.secrecy,
            Stage.extraction,
          },
          'score': 100,
          'level': RiskLevel.high,
        },
        'scam_courier': {
          'stages': {
            Stage.authority,
            Stage.fear,
            Stage.urgency,
            Stage.extraction,
          },
          'score': 100,
          'level': RiskLevel.high,
        },
        'scam_trai': {
          'stages': {Stage.authority, Stage.fear, Stage.urgency},
          'score': 59,
          'level': RiskLevel.medium,
        },
        'benign_bank': {
          'stages': <Stage>{},
          'score': 0,
          'level': RiskLevel.low,
        },
        'benign_passport': {
          'stages': {Stage.authority},
          'score': 9,
          'level': RiskLevel.low,
        },
        'ambiguous_family': {
          'stages': {Stage.urgency, Stage.extraction},
          'score': 33,
          'level': RiskLevel.medium,
        },
      };

      for (final raw in rawScripts) {
        final script = DemoScript.fromJson(raw);

        // 1. Lexicon events
        final lexiconEvents = <TacticEvent>[];
        for (final seg in script.segments) {
          lexiconEvents.addAll(Lexicon.scan(seg));
        }

        // 2. Grounded LLM events
        final groundedEvents = script.llm != null
            ? Grounding.filter(
                events: script.llm!.events,
                entities: script.llm!.entities,
                segments: script.segments,
              ).events
            : const <TacticEvent>[];

        // 3. Merged events
        final allEvents = [...lexiconEvents, ...groundedEvents];

        final result = RiskEngine.evaluate(allEvents);
        final exp = expected[script.id]!;

        expect(
          result.stagesSeen,
          exp['stages'],
          reason: 'Stages mismatch for ${script.id}',
        );
        expect(
          result.score,
          exp['score'],
          reason: 'Score mismatch for ${script.id}',
        );
        expect(
          result.level,
          exp['level'],
          reason: 'Level mismatch for ${script.id}',
        );
      }
    });
  });

  group('RiskEngine - Lexicon Only Vectors (TESTING.md §3)', () {
    test('all 6 demo scripts match lexicon-only vector expectations', () {
      final file = File('assets/demo/scripts.json');
      final jsonMap =
          jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
      final rawScripts = (jsonMap['scripts'] as List<dynamic>)
          .cast<Map<String, dynamic>>();

      final expected = {
        'scam_cbi': {
          'stages': {
            Stage.authority,
            Stage.fear,
            Stage.urgency,
            Stage.secrecy,
            Stage.extraction,
          },
          'score': 85,
          'level': RiskLevel.high,
        },
        'scam_courier': {
          'stages': {
            Stage.authority,
            Stage.fear,
            Stage.urgency,
            Stage.extraction,
          },
          'score': 73,
          'level': RiskLevel.high,
        },
        'scam_trai': {
          'stages': {Stage.authority, Stage.fear, Stage.urgency},
          'score': 40,
          'level': RiskLevel.medium,
        },
        'benign_bank': {
          'stages': <Stage>{},
          'score': 0,
          'level': RiskLevel.low,
        },
        'benign_passport': {
          'stages': {Stage.authority},
          'score': 8,
          'level': RiskLevel.low,
        },
        'ambiguous_family': {
          'stages': {Stage.urgency, Stage.extraction},
          'score': 20,
          'level': RiskLevel.low,
        },
      };

      for (final raw in rawScripts) {
        final script = DemoScript.fromJson(raw);

        final lexiconEvents = <TacticEvent>[];
        for (final seg in script.segments) {
          lexiconEvents.addAll(Lexicon.scan(seg));
        }

        final result = RiskEngine.evaluate(lexiconEvents);
        final exp = expected[script.id]!;

        expect(
          result.stagesSeen,
          exp['stages'],
          reason: 'Lexicon-only stages mismatch for ${script.id}',
        );
        expect(
          result.score,
          exp['score'],
          reason: 'Lexicon-only score mismatch for ${script.id}',
        );
        expect(
          result.level,
          exp['level'],
          reason: 'Lexicon-only level mismatch for ${script.id}',
        );
      }
    });
  });

  group('RiskEngine Hard Rules & Monotonicity', () {
    test('Hard rule 1: secrecy + extraction clamps score to at least 60', () {
      // secrecy weight 25, extraction weight 25 with low confidence 0.3
      // base = 25*0.3 + 25*0.3 = 15. bonus = 0.
      // formula score = 15. Hard rule 1 should bump to 60.
      const events = [
        TacticEvent(
          stage: Stage.secrecy,
          quote: 'kisi ko mat batana',
          atSec: 5,
          confidence: 0.3,
          source: EventSource.llm,
        ),
        TacticEvent(
          stage: Stage.extraction,
          quote: 'paise bhej do',
          atSec: 10,
          confidence: 0.3,
          source: EventSource.llm,
        ),
      ];

      final result = RiskEngine.evaluate(events);
      expect(result.score, 60);
      expect(result.level, RiskLevel.high);
    });

    test('Hard rule 2: authority-only clamps score to at most 29', () {
      // Even if authority confidence is 1.0, 15*1.0 = 15 <= 29.
      // Suppose authority had confidence 1.0 and artificial weights gave > 29:
      // stagesSeen == {authority} => score <= 29 and level == low
      const events = [
        TacticEvent(
          stage: Stage.authority,
          quote: 'Main police officer',
          atSec: 0,
          confidence: 1,
          source: EventSource.llm,
        ),
      ];

      final result = RiskEngine.evaluate(events);
      expect(result.score, 15);
      expect(result.level, RiskLevel.low);
    });

    test('Hard rule 3: monotonic previousScore in live mode', () {
      const events = [
        TacticEvent(
          stage: Stage.urgency,
          quote: 'jaldi karo abhi',
          atSec: 0,
          confidence: 0.5,
          source: EventSource.lexicon,
        ),
      ];

      // urgency alone: 15 * 0.5 = 7.5 -> 8
      final result1 = RiskEngine.evaluate(events, previousScore: 50);
      expect(result1.score, 50);
      expect(result1.level, RiskLevel.medium);
    });
  });

  group('Evidence selection for Verdict', () {
    test('selects best event per stage, prefers LLM on ties, sorted by atSec, max 6', () {
      const events = [
        TacticEvent(
          stage: Stage.authority,
          quote: 'lexicon authority quote',
          atSec: 20,
          confidence: 0.5,
          source: EventSource.lexicon,
        ),
        TacticEvent(
          stage: Stage.authority,
          quote: 'llm authority quote',
          atSec: 5,
          confidence: 0.5, // tie with lexicon
          source: EventSource.llm,
        ),
        TacticEvent(
          stage: Stage.fear,
          quote: 'fear quote',
          atSec: 15,
          confidence: 0.9,
          source: EventSource.llm,
        ),
      ];

      final evidence = RiskEngine.selectEvidence(events);
      expect(evidence.length, 2);

      // On tie, LLM is preferred
      expect(evidence.first.stage, Stage.authority);
      expect(evidence.first.quote, 'llm authority quote');

      // Sorted by atSec: 5.0 before 15.0
      expect(evidence[0].atSec, 5.0);
      expect(evidence[1].atSec, 15.0);
    });
  });
}
