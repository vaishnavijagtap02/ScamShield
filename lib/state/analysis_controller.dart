import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scamshield/core/result.dart';
import 'package:scamshield/engine/grounding.dart';
import 'package:scamshield/engine/lexicon.dart';
import 'package:scamshield/engine/models.dart';
import 'package:scamshield/engine/risk_engine.dart';
import 'package:scamshield/services/alert_service.dart';
import 'package:scamshield/services/guardian_store.dart';
import 'package:scamshield/services/llm_service.dart';
import 'package:scamshield/services/stt_service.dart';
import 'package:scamshield/services/tts_service.dart';
import 'package:scamshield/sources/demo_source.dart';
import 'package:scamshield/sources/mic_source.dart';
import 'package:scamshield/sources/upload_source.dart';
import 'package:scamshield/state/providers.dart';

enum AnalysisPhase { idle, running, done, error }

class AnalysisState {
  const new({
    this.phase = AnalysisPhase.idle,
    this.segments = const [],
    this.events = const [],
    this.risk = const RiskResult(
      score: 0,
      level: RiskLevel.low,
      stagesSeen: {},
    ),
    this.verdict,
    this.errorKey,
    this.piecesDone = 0,
    this.piecesTotal = 0,
    this.basicCheckOnly = false,
    this.partialAudio = false,
    this.isLive = false,
    this.alertSent,
  });

  final AnalysisPhase phase;
  final List<Segment> segments;
  final List<TacticEvent> events;
  final RiskResult risk;
  final Verdict? verdict;
  final String? errorKey;
  final int piecesDone;
  final int piecesTotal;
  final bool basicCheckOnly;
  final bool partialAudio;
  final bool isLive;
  final bool? alertSent;

  AnalysisState copyWith({
    AnalysisPhase? phase,
    List<Segment>? segments,
    List<TacticEvent>? events,
    RiskResult? risk,
    Verdict? verdict,
    String? errorKey,
    int? piecesDone,
    int? piecesTotal,
    bool? basicCheckOnly,
    bool? partialAudio,
    bool? isLive,
    bool? alertSent,
  }) {
    return AnalysisState(
      phase: phase ?? this.phase,
      segments: segments ?? this.segments,
      events: events ?? this.events,
      risk: risk ?? this.risk,
      verdict: verdict ?? this.verdict,
      errorKey: errorKey ?? this.errorKey,
      piecesDone: piecesDone ?? this.piecesDone,
      piecesTotal: piecesTotal ?? this.piecesTotal,
      basicCheckOnly: basicCheckOnly ?? this.basicCheckOnly,
      partialAudio: partialAudio ?? this.partialAudio,
      isLive: isLive ?? this.isLive,
      alertSent: alertSent ?? this.alertSent,
    );
  }
}

class AnalysisController extends Notifier<AnalysisState> {
  new({
    SttService? sttService,
    LlmService? llmService,
    AlertService? alertService,
    TtsService? ttsService,
    GuardianStore? guardianStore,
  }) : _injectedStt = sttService,
       _injectedLlm = llmService,
       _injectedAlert = alertService,
       _injectedTts = ttsService,
       _injectedStore = guardianStore;

  final SttService? _injectedStt;
  final LlmService? _injectedLlm;
  final AlertService? _injectedAlert;
  final TtsService? _injectedTts;
  final GuardianStore? _injectedStore;

  AnalysisState _standaloneState = const AnalysisState();

  @override
  AnalysisState get state {
    try {
      return super.state;
    } on Object {
      return _standaloneState;
    }
  }

  @override
  set state(AnalysisState value) {
    try {
      super.state = value;
    } on Object {
      _standaloneState = value;
    }
  }

  SttService get _stt {
    final stt = _injectedStt;
    if (stt != null) return stt;
    return ref.read(sttServiceProvider);
  }

  LlmService get _llm {
    final llm = _injectedLlm;
    if (llm != null) return llm;
    return ref.read(llmServiceProvider);
  }

  AlertService get _alert {
    final alert = _injectedAlert;
    if (alert != null) return alert;
    return ref.read(alertServiceProvider);
  }

  TtsService get _tts {
    final tts = _injectedTts;
    if (tts != null) return tts;
    return ref.read(ttsServiceProvider);
  }

  GuardianStore? get _store {
    if (_injectedStore != null) return _injectedStore;
    try {
      if (ref.exists(guardianStoreProvider)) {
        return ref.read(guardianStoreProvider);
      }
    } on Object {
      // Standalone mode or uninitialized
    }
    return null;
  }

  MicSource? _activeMicSource;
  StreamSubscription<AudioChunk>? _micSub;

  @override
  AnalysisState build() => const AnalysisState();

  /// Starts full audio analysis flow from uploaded bytes.
  Future<void> analyzeUpload({
    required Uint8List bytes,
    required String filename,
    double? durationSec,
  }) async {
    state = const AnalysisState(phase: AnalysisPhase.running);

    List<AudioChunk> chunks;
    try {
      chunks = UploadSource.process(
        bytes: bytes,
        filename: filename,
        durationSec: durationSec,
      );
    } on AudioFormatException catch (e) {
      state = state.copyWith(phase: AnalysisPhase.error, errorKey: e.message);
      return;
    }

    if (chunks.isEmpty) {
      state = state.copyWith(phase: AnalysisPhase.done);
      return;
    }

    state = state.copyWith(piecesTotal: chunks.length);

    var hasPartialAudio = false;
    final chunkResults = <int, List<Segment>>{};
    var failedChunksCount = 0;

    for (final chunk in chunks) {
      try {
        final segments = await _stt.transcribe(chunk);
        chunkResults[chunk.index] = segments;
      } on Exception {
        hasPartialAudio = true;
        failedChunksCount++;
      }
    }

    if (failedChunksCount == chunks.length) {
      state = state.copyWith(
        phase: AnalysisPhase.error,
        errorKey: 'errNoNetwork',
      );
      return;
    }

    final sortedChunkIndices = chunkResults.keys.toList()..sort();
    final allSegments = <Segment>[];
    final allLexiconEvents = <TacticEvent>[];
    var currentRisk = state.risk;

    for (final idx in sortedChunkIndices) {
      final segments = chunkResults[idx]!;
      for (final s in segments) {
        allSegments.add(s);
        final lexiconMatches = Lexicon.scan(s);
        allLexiconEvents.addAll(lexiconMatches);
        currentRisk = RiskEngine.evaluate(allLexiconEvents);
      }
      state = state.copyWith(
        segments: List.unmodifiable(allSegments),
        events: List.unmodifiable(allLexiconEvents),
        risk: currentRisk,
        piecesDone: state.piecesDone + 1,
        partialAudio: hasPartialAudio,
      );
    }

    Verdict verdict;
    try {
      final llmAnalysis = await _llm.analyze(allSegments);
      final grounded = Grounding.filter(
        events: llmAnalysis.events,
        entities: llmAnalysis.entities,
        segments: allSegments,
      );

      final combinedEvents = [...allLexiconEvents, ...grounded.events];
      final finalRisk = RiskEngine.evaluate(combinedEvents);
      final evidence = RiskEngine.selectEvidence(combinedEvents);

      verdict = Verdict(
        level: finalRisk.level,
        score: finalRisk.score,
        scamType: llmAnalysis.scamType,
        evidence: evidence,
        entities: grounded.entities,
        summaryHi: llmAnalysis.summaryHi,
        partialAudio: hasPartialAudio,
      );
    } on Exception {
      final finalRisk = RiskEngine.evaluate(allLexiconEvents);
      final evidence = RiskEngine.selectEvidence(allLexiconEvents);
      final stagesStr = finalRisk.stagesSeen
          .map((s) => s.name.toUpperCase())
          .join(', ');
      final summary =
          'Is call mein ${finalRisk.stagesSeen.length} khatre ke sanket mile: $stagesStr.';

      verdict = Verdict(
        level: finalRisk.level,
        score: finalRisk.score,
        scamType: ScamType.unknown,
        evidence: evidence,
        entities: const Entities(),
        summaryHi: summary,
        basicCheckOnly: true,
        partialAudio: hasPartialAudio,
      );
    }

    await _onVerdictProduced(verdict);
  }

  /// Runs the full pipeline against a DemoScript without STT or live LLM network.
  Future<void> analyzeDemo(
    DemoScript script, {
    Duration interval = const Duration(milliseconds: 1200),
  }) async {
    state = const AnalysisState(phase: AnalysisPhase.running);
    state = state.copyWith(piecesTotal: script.segments.length);

    final demoSource = DemoSource(script: script, interval: interval);
    final allSegments = <Segment>[];
    final allLexiconEvents = <TacticEvent>[];
    var currentRisk = state.risk;

    await for (final segment in demoSource.streamSegments()) {
      allSegments.add(segment);
      final lexiconMatches = Lexicon.scan(segment);
      allLexiconEvents.addAll(lexiconMatches);
      currentRisk = RiskEngine.evaluate(allLexiconEvents);

      state = state.copyWith(
        segments: List.unmodifiable(allSegments),
        events: List.unmodifiable(allLexiconEvents),
        risk: currentRisk,
        piecesDone: state.piecesDone + 1,
      );
    }

    final cannedLlm = demoSource.cannedLlm;
    Verdict verdict;
    if (cannedLlm != null) {
      final grounded = Grounding.filter(
        events: cannedLlm.events,
        entities: cannedLlm.entities,
        segments: allSegments,
      );
      final combinedEvents = [...allLexiconEvents, ...grounded.events];
      final finalRisk = RiskEngine.evaluate(combinedEvents);
      final evidence = RiskEngine.selectEvidence(combinedEvents);

      verdict = Verdict(
        level: finalRisk.level,
        score: finalRisk.score,
        scamType: cannedLlm.scamType,
        evidence: evidence,
        entities: grounded.entities,
        summaryHi: cannedLlm.summaryHi,
      );
    } else {
      final finalRisk = RiskEngine.evaluate(allLexiconEvents);
      final evidence = RiskEngine.selectEvidence(allLexiconEvents);
      verdict = Verdict(
        level: finalRisk.level,
        score: finalRisk.score,
        scamType: ScamType.unknown,
        evidence: evidence,
        entities: const Entities(),
        summaryHi: 'Demo check completed.',
        basicCheckOnly: true,
      );
    }

    await _onVerdictProduced(verdict);
  }

  /// Starts live streaming from microphone chunks.
  Future<void> startLive({MicSource? micSource}) async {
    state = const AnalysisState(phase: AnalysisPhase.running, isLive: true);

    _activeMicSource = micSource ?? MicSource();
    final stream = await _activeMicSource!.startStream();

    final allSegments = <Segment>[];
    final allEvents = <TacticEvent>[];
    var currentRisk = state.risk;
    var chunkCount = 0;

    _micSub = stream.listen((chunk) async {
      chunkCount++;
      try {
        final segments = await _stt.transcribe(chunk);
        for (final s in segments) {
          allSegments.add(s);
          final lex = Lexicon.scan(s);
          allEvents.addAll(lex);
          currentRisk = RiskEngine.evaluate(
            allEvents,
            previousScore: currentRisk.score,
          );
        }

        if (chunkCount.isEven) {
          try {
            final nowSec = chunk.startSec + chunk.durationSec;
            final windowStart = math.max(0, nowSec - 90);
            final windowSegments = allSegments
                .where((s) => s.startSec >= windowStart)
                .toList();

            final llmRes = await _llm.analyze(
              windowSegments,
              alreadyDetectedStages: currentRisk.stagesSeen,
            );
            final grounded = Grounding.filter(
              events: llmRes.events,
              entities: llmRes.entities,
              segments: windowSegments,
            );
            allEvents.addAll(grounded.events);
            currentRisk = RiskEngine.evaluate(
              allEvents,
              previousScore: currentRisk.score,
            );
          } on Exception {
            // Window LLM error is non-fatal in live mode
          }
        }

        state = state.copyWith(
          segments: List.unmodifiable(allSegments),
          events: List.unmodifiable(allEvents),
          risk: currentRisk,
          piecesDone: state.piecesDone + 1,
        );
      } on Exception {
        // STT failure on single chunk in live mode
      }
    });
  }

  /// Stops live streaming and produces final verdict.
  Future<void> stopLive() async {
    await _micSub?.cancel();
    _micSub = null;
    await _activeMicSource?.stop();
    _activeMicSource = null;

    final evidence = RiskEngine.selectEvidence(state.events);
    final verdict = Verdict(
      level: state.risk.level,
      score: state.risk.score,
      scamType: ScamType.unknown,
      evidence: evidence,
      entities: const Entities(),
      summaryHi: 'Live guard check completed.',
    );

    await _onVerdictProduced(verdict);
  }

  Future<void> _onVerdictProduced(Verdict verdict) async {
    bool? alertSent;
    if (verdict.level == RiskLevel.high) {
      try {
        await _tts.speakWarning('Savdhaan! Yeh call ek fraud lagti hai.');
      } on Object {
        // Safe fallback if TTS is not available on web/platform
      }

      final store = _store;
      if (store != null && store.getAutoAlert()) {
        final guardians = store.getGuardians();
        if (guardians.isNotEmpty) {
          final alertText = AlertTextBuilder.build(
            verdict: verdict,
            answers: const Answers(),
            userName: store.getUserName(),
          );
          try {
            final sendResults = await _alert.sendAlert(
              text: alertText,
              guardians: guardians,
            );
            alertSent = sendResults.values.any((s) => s);
          } on Object {
            // Non-fatal if alert network fails
          }
        }
      }
    }

    state = state.copyWith(
      phase: AnalysisPhase.done,
      verdict: verdict,
      alertSent: alertSent,
    );
  }

  void reset() {
    state = const AnalysisState();
  }
}
