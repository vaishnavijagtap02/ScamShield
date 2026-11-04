import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:scamshield/engine/models.dart';
import 'package:scamshield/sources/demo_source.dart';

void main() {
  group('DemoSource', () {
    test(
      'emits all segments in order with zero interval and exposes canned LLM',
      () async {
        final jsonFile = File('assets/demo/scripts.json');
        final jsonMap =
            jsonDecode(jsonFile.readAsStringSync()) as Map<String, dynamic>;
        final rawScripts = (jsonMap['scripts'] as List<dynamic>)
            .cast<Map<String, dynamic>>();
        final cbiRaw = rawScripts.firstWhere((s) => s['id'] == 'scam_cbi');
        final script = DemoScript.fromJson(cbiRaw);

        final demoSource = DemoSource(script: script, interval: Duration.zero);

        final emitted = await demoSource.streamSegments().toList();
        expect(emitted.length, equals(script.segments.length));
        for (var i = 0; i < emitted.length; i++) {
          expect(emitted[i].text, equals(script.segments[i].text));
          expect(emitted[i].startSec, equals(script.segments[i].startSec));
        }

        expect(demoSource.cannedLlm, isNotNull);
        expect(demoSource.cannedLlm!.scamType, equals(ScamType.digitalArrest));
        expect(demoSource.cannedLlm!.events, isNotEmpty);
      },
    );
  });
}
