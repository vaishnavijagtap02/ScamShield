import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:scamshield/core/result.dart';
import 'package:scamshield/engine/models.dart';
import 'package:scamshield/engine/wav.dart';
import 'package:scamshield/services/alert_service.dart';
import 'package:scamshield/services/guardian_store.dart';
import 'package:scamshield/services/llm_service.dart';
import 'package:scamshield/services/stt_service.dart';
import 'package:scamshield/services/tts_service.dart';
import 'package:scamshield/state/analysis_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeSttService implements SttService {
  new({this.onTranscribe});

  final Future<List<Segment>> Function(AudioChunk chunk)? onTranscribe;

  @override
  Future<List<Segment>> transcribe(AudioChunk chunk) async {
    if (onTranscribe != null) {
      return await onTranscribe!(chunk);
    }
    return [
      Segment(
        index: chunk.index,
        text: 'Segment text for chunk ${chunk.index}',
        startSec: chunk.startSec,
        endSec: chunk.startSec + chunk.durationSec,
      ),
    ];
  }
}

class FakeLlmService implements LlmService {
  new({this.onAnalyze});

  final Future<LlmAnalysis> Function(List<Segment> segments)? onAnalyze;

  @override
  Future<LlmAnalysis> analyze(
    List<Segment> segments, {
    Set<Stage> alreadyDetectedStages = const {},
  }) async {
    if (onAnalyze != null) {
      return await onAnalyze!(segments);
    }
    return const LlmAnalysis(
      scamType: ScamType.none,
      events: [],
      entities: Entities(),
      summaryHi: 'Fake summary',
    );
  }
}

class FakeAlertService implements AlertService {
  int sendCount = 0;
  String? lastText;

  @override
  Future<Guardian?> pollForPairing(String code) async => null;

  @override
  Future<Map<int, bool>> sendAlert({
    required String text,
    required List<Guardian> guardians,
  }) async {
    sendCount++;
    lastText = text;
    return {for (final g in guardians) g.chatId: true};
  }

  @override
  String getPairingUrl(String code) => 'https://t.me/fakebot?start=$code';
}

class FakeTtsService implements TtsService {
  int speakCount = 0;
  String? lastSpoken;

  @override
  Future<void> speakWarning(String text) async {
    speakCount++;
    lastSpoken = text;
  }

  @override
  Future<void> stop() async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late DemoScript cbiScript;

  setUpAll(() {
    final jsonFile = File('assets/demo/scripts.json');
    final jsonMap =
        jsonDecode(jsonFile.readAsStringSync()) as Map<String, dynamic>;
    final rawScripts = (jsonMap['scripts'] as List<dynamic>)
        .cast<Map<String, dynamic>>();
    final cbiRaw = rawScripts.firstWhere((s) => s['id'] == 'scam_cbi');
    cbiScript = DemoScript.fromJson(cbiRaw);
  });

  group('AnalysisController (T12 acceptance criteria)', () {
    test('1) demo scam_cbi yields HIGH 100', () async {
      final controller = AnalysisController(
        sttService: FakeSttService(),
        llmService: FakeLlmService(),
        alertService: FakeAlertService(),
        ttsService: FakeTtsService(),
      );

      await controller.analyzeDemo(cbiScript, interval: Duration.zero);

      expect(controller.state.phase, equals(AnalysisPhase.done));
      expect(controller.state.verdict, isNotNull);
      expect(controller.state.verdict!.level, equals(RiskLevel.high));
      expect(controller.state.verdict!.score, equals(100));
      expect(
        controller.state.verdict!.scamType,
        equals(ScamType.digitalArrest),
      );
      expect(controller.state.verdict!.basicCheckOnly, isFalse);
    });

    test(
      '2) LLM throws yields basicCheckOnly true with lexicon-only score 85',
      () async {
        // Audio chunks that transcribe to the scam_cbi lines
        final fakeStt = FakeSttService(
          onTranscribe: (chunk) async => cbiScript.segments,
        );

        final fakeLlm = FakeLlmService(
          onAnalyze: (segments) async {
            throw const LlmException('LLM server down', statusCode: 503);
          },
        );

        final controller = AnalysisController(
          sttService: fakeStt,
          llmService: fakeLlm,
          alertService: FakeAlertService(),
          ttsService: FakeTtsService(),
        );

        // Single chunk WAV
        final wavBytes = wavFromPcm16(Uint8List(10 * 32000));
        await controller.analyzeUpload(
          bytes: wavBytes,
          filename: 'cbi_call.wav',
        );

        expect(controller.state.phase, equals(AnalysisPhase.done));
        expect(controller.state.verdict, isNotNull);
        expect(controller.state.verdict!.basicCheckOnly, isTrue);
        // scam_cbi lexicon-only score is 85 per TESTING.md §3
        expect(controller.state.verdict!.score, equals(85));
        expect(controller.state.verdict!.level, equals(RiskLevel.high));
      },
    );

    test('3) 1 of 3 STT pieces fails yields partialAudio true and segments stay ordered', () async {
      // 3-chunk WAV: 61 seconds
      final pcmBytes = Uint8List(61 * 32000);
      final wavBytes = wavFromPcm16(pcmBytes);

      final fakeStt = FakeSttService(
        onTranscribe: (chunk) async {
          if (chunk.index == 1) {
            throw const SttException('Piece 2 network error', statusCode: 500);
          }
          return [
            Segment(
              index: chunk.index,
              text: 'Segment from piece ${chunk.index}',
              startSec: chunk.startSec,
              endSec: chunk.startSec + chunk.durationSec,
            ),
          ];
        },
      );

      final controller = AnalysisController(
        sttService: fakeStt,
        llmService: FakeLlmService(
          onAnalyze: (segments) async => const LlmAnalysis(
            scamType: ScamType.none,
            events: [],
            entities: Entities(),
            summaryHi: 'Test',
          ),
        ),
        alertService: FakeAlertService(),
        ttsService: FakeTtsService(),
      );

      await controller.analyzeUpload(
        bytes: wavBytes,
        filename: 'three_chunks.wav',
      );

      expect(controller.state.phase, equals(AnalysisPhase.done));
      expect(controller.state.verdict, isNotNull);
      expect(controller.state.verdict!.partialAudio, isTrue);

      // Segments stay ordered by index/startSec
      expect(controller.state.segments.length, equals(2));
      expect(controller.state.segments[0].startSec, equals(0.0));
      expect(controller.state.segments[1].startSec, equals(50.0));
    });

    test('4) HIGH + autoAlert calls alertService.sendAlert once', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final prefs = await SharedPreferences.getInstance();
      final store = GuardianStore(prefs);
      await store.saveGuardian(const Guardian(name: 'Son', chatId: 999));
      await store.setAutoAlert(enabled: true);

      final fakeAlert = FakeAlertService();
      final fakeTts = FakeTtsService();

      final controller = AnalysisController(
        sttService: FakeSttService(),
        llmService: FakeLlmService(),
        alertService: fakeAlert,
        ttsService: fakeTts,
        guardianStore: store,
      );

      await controller.analyzeDemo(cbiScript, interval: Duration.zero);

      expect(controller.state.verdict!.level, equals(RiskLevel.high));
      expect(fakeAlert.sendCount, equals(1));
      expect(fakeTts.speakCount, equals(1));
    });
  });
}
