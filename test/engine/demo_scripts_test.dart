import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:scamshield/engine/models.dart';

void main() {
  test('loads all 6 demo scripts and asserts ids and segment counts', () {
    final file = File('assets/demo/scripts.json');
    expect(file.existsSync(), isTrue);

    final jsonMap = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
    final rawScripts = jsonMap['scripts'] as List<dynamic>;

    final scripts = rawScripts
        .map((s) => DemoScript.fromJson(s as Map<String, dynamic>))
        .toList();

    expect(scripts.length, 6);

    final expectedCounts = {
      'scam_cbi': 7,
      'scam_courier': 5,
      'scam_trai': 3,
      'benign_bank': 3,
      'benign_passport': 3,
      'ambiguous_family': 3,
    };

    for (final script in scripts) {
      expect(
        expectedCounts.containsKey(script.id),
        isTrue,
        reason: 'Unexpected script id: ${script.id}',
      );
      expect(
        script.segments.length,
        expectedCounts[script.id],
        reason: 'Segment count mismatch for ${script.id}',
      );
    }
  });
}
