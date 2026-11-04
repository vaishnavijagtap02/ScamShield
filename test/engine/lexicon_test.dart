import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:scamshield/engine/lexicon.dart';
import 'package:scamshield/engine/models.dart';

void main() {
  group('Lexicon normalization', () {
    test('normalizes text with lowercase, whitespace collapse, and punctuation removal', () {
      expect(
        normalize('Namaste,  main CBI!! Inspector... '),
        'namaste main cbi inspector',
      );
    });
  });

  group('Lexicon stage matching - Latin (>= 2 positives each)', () {
    test('authority', () {
      const seg1 = Segment(
        index: 0,
        startSec: 0,
        endSec: 5,
        text: 'This is CBI officer calling',
      );
      const seg2 = Segment(
        index: 1,
        startSec: 0,
        endSec: 5,
        text: 'Mumbai police cyber cell investigation',
      );
      expect(Lexicon.scan(seg1).map((e) => e.stage), contains(Stage.authority));
      expect(Lexicon.scan(seg2).map((e) => e.stage), contains(Stage.authority));
    });

    test('fear', () {
      const seg1 = Segment(
        index: 0,
        startSec: 0,
        endSec: 5,
        text: 'Arrest warrant has been issued against you',
      );
      const seg2 = Segment(
        index: 1,
        startSec: 0,
        endSec: 5,
        text: 'Your Aadhaar is involved in illegal money laundering',
      );
      expect(Lexicon.scan(seg1).map((e) => e.stage), contains(Stage.fear));
      expect(Lexicon.scan(seg2).map((e) => e.stage), contains(Stage.fear));
    });

    test('urgency', () {
      const seg1 = Segment(
        index: 0,
        startSec: 0,
        endSec: 5,
        text: 'Turant action lijiye abhi',
      );
      const seg2 = Segment(
        index: 1,
        startSec: 0,
        endSec: 5,
        text: 'SIM will be blocked within 2 hours',
      );
      expect(Lexicon.scan(seg1).map((e) => e.stage), contains(Stage.urgency));
      expect(Lexicon.scan(seg2).map((e) => e.stage), contains(Stage.urgency));
    });

    test('secrecy', () {
      const seg1 = Segment(
        index: 0,
        startSec: 0,
        endSec: 5,
        text: 'Kisi ko mat batana confidential hai',
      );
      const seg2 = Segment(
        index: 1,
        startSec: 0,
        endSec: 5,
        text: 'Call mat kaatna camera on rakho',
      );
      expect(Lexicon.scan(seg1).map((e) => e.stage), contains(Stage.secrecy));
      expect(Lexicon.scan(seg2).map((e) => e.stage), contains(Stage.secrecy));
    });

    test('extraction', () {
      const seg1 = Segment(
        index: 0,
        startSec: 0,
        endSec: 5,
        text: 'Send money via upi immediately',
      );
      const seg2 = Segment(
        index: 1,
        startSec: 0,
        endSec: 5,
        text: 'Transfer to safe account with otp',
      );
      expect(
        Lexicon.scan(seg1).map((e) => e.stage),
        contains(Stage.extraction),
      );
      expect(
        Lexicon.scan(seg2).map((e) => e.stage),
        contains(Stage.extraction),
      );
    });
  });

  group('Lexicon stage matching - Devanagari (>= 2 positives each)', () {
    test('authority', () {
      const seg1 = Segment(
        index: 0,
        startSec: 0,
        endSec: 5,
        text: 'हम सीबीआई हेडक्वार्टर से बोल रहे हैं',
      );
      const seg2 = Segment(
        index: 1,
        startSec: 0,
        endSec: 5,
        text: 'पुलिस अधिकारी मामले की जांच कर रहे हैं',
      );
      expect(Lexicon.scan(seg1).map((e) => e.stage), contains(Stage.authority));
      expect(Lexicon.scan(seg2).map((e) => e.stage), contains(Stage.authority));
    });

    test('fear', () {
      const seg1 = Segment(
        index: 0,
        startSec: 0,
        endSec: 5,
        text: 'आपके खिलाफ केस दर्ज किया गया है',
      );
      const seg2 = Segment(
        index: 1,
        startSec: 0,
        endSec: 5,
        text: 'वारंट जारी हुआ है और जेल हो सकती है',
      );
      expect(Lexicon.scan(seg1).map((e) => e.stage), contains(Stage.fear));
      expect(Lexicon.scan(seg2).map((e) => e.stage), contains(Stage.fear));
    });

    test('urgency', () {
      const seg1 = Segment(
        index: 0,
        startSec: 0,
        endSec: 5,
        text: 'अभी तुरंत जवाब दीजिए',
      );
      const seg2 = Segment(
        index: 1,
        startSec: 0,
        endSec: 5,
        text: 'जल्दी करें दो घंटे में पहुंचें',
      );
      expect(Lexicon.scan(seg1).map((e) => e.stage), contains(Stage.urgency));
      expect(Lexicon.scan(seg2).map((e) => e.stage), contains(Stage.urgency));
    });

    test('secrecy', () {
      const seg1 = Segment(
        index: 0,
        startSec: 0,
        endSec: 5,
        text: 'किसी को मत बताना यह बात',
      );
      const seg2 = Segment(
        index: 1,
        startSec: 0,
        endSec: 5,
        text: 'कॉल मत काटना गोपनीय जांच है',
      );
      expect(Lexicon.scan(seg1).map((e) => e.stage), contains(Stage.secrecy));
      expect(Lexicon.scan(seg2).map((e) => e.stage), contains(Stage.secrecy));
    });

    test('extraction', () {
      const seg1 = Segment(
        index: 0,
        startSec: 0,
        endSec: 5,
        text: 'पैसे भेजें तुरंत खाते में',
      );
      const seg2 = Segment(
        index: 1,
        startSec: 0,
        endSec: 5,
        text: 'सरकारी खाते में ट्रांसफर करें',
      );
      expect(
        Lexicon.scan(seg1).map((e) => e.stage),
        contains(Stage.extraction),
      );
      expect(
        Lexicon.scan(seg2).map((e) => e.stage),
        contains(Stage.extraction),
      );
    });
  });

  group('Lexicon negation guard and negatives', () {
    test('bank kabhi OTP nahi maangta emits no extraction event', () {
      const seg = Segment(
        index: 0,
        startSec: 0,
        endSec: 5,
        text: 'bank kabhi OTP nahi maangta kisi ko OTP share mat kijiye',
      );
      final events = Lexicon.scan(seg);
      expect(events.where((e) => e.stage == Stage.extraction), isEmpty);
    });

    test('kal thane aa jaana emits nothing', () {
      const seg = Segment(
        index: 0,
        startSec: 0,
        endSec: 5,
        text: 'kal thane aa jaana original documents leke',
      );
      final events = Lexicon.scan(seg);
      expect(events, isEmpty);
    });
  });

  group('Demo scripts lexicon-only vectors match TESTING.md §3', () {
    test('all 6 demo scripts match expected lexicon stages', () {
      final file = File('assets/demo/scripts.json');
      final jsonMap =
          jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
      final rawScripts = jsonMap['scripts'] as List<dynamic>;

      final expectedStages = {
        'scam_cbi': {
          Stage.authority,
          Stage.fear,
          Stage.urgency,
          Stage.secrecy,
          Stage.extraction,
        },
        'scam_courier': {
          Stage.authority,
          Stage.fear,
          Stage.urgency,
          Stage.extraction,
        },
        'scam_trai': {Stage.authority, Stage.fear, Stage.urgency},
        'benign_bank': <Stage>{},
        'benign_passport': {Stage.authority},
        'ambiguous_family': {Stage.urgency, Stage.extraction},
      };

      for (final raw in rawScripts) {
        final script = DemoScript.fromJson(raw as Map<String, dynamic>);
        final stagesSeen = <Stage>{};
        for (final seg in script.segments) {
          final events = Lexicon.scan(seg);
          stagesSeen.addAll(events.map((e) => e.stage));
        }

        expect(
          stagesSeen,
          expectedStages[script.id],
          reason: 'Lexicon stages mismatch for script: ${script.id}',
        );
      }
    });
  });
}
