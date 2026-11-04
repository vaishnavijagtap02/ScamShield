import 'dart:math';

import 'package:scamshield/engine/models.dart';

class RiskEngine {
  const new _();

  static const Map<Stage, int> weights = {
    Stage.authority: 15,
    Stage.fear: 20,
    Stage.urgency: 15,
    Stage.secrecy: 25,
    Stage.extraction: 25,
  };

  /// Evaluates grounded tactic events and returns [RiskResult].
  /// In live mode, pass [previousScore] to ensure monotonic score progression.
  static RiskResult evaluate(List<TacticEvent> events, {int? previousScore}) {
    // 1. Group events by stage and calculate max confidence per stage
    final maxConfidence = <Stage, double>{};
    for (final event in events) {
      final current = maxConfidence[event.stage] ?? 0.0;
      if (event.confidence > current) {
        maxConfidence[event.stage] = event.confidence;
      }
    }

    final stagesSeen = maxConfidence.keys.toSet();

    // 2. Base score: Σ weight[s] × c[s]
    var base = 0.0;
    for (final entry in maxConfidence.entries) {
      final w = weights[entry.key] ?? 0;
      base += w * entry.value;
    }

    // 3. Bonus calculation
    var bonus = 0;
    if (stagesSeen.length >= 3) {
      bonus += 15;
    }
    if (stagesSeen.contains(Stage.authority) &&
        stagesSeen.contains(Stage.extraction)) {
      bonus += 20;
    }

    // Initial formula score
    var score = min(100, (base + bonus).round());

    // 4. Hard rules in order
    // Rule 1: secrecy ∈ seen AND extraction ∈ seen → score = max(score, 60)
    if (stagesSeen.contains(Stage.secrecy) &&
        stagesSeen.contains(Stage.extraction)) {
      score = max(score, 60);
    }

    // Rule 2: stagesSeen == {authority} → score = min(score, 29)
    if (stagesSeen.length == 1 && stagesSeen.contains(Stage.authority)) {
      score = min(score, 29);
    }

    // Rule 3: Live mode only: score = max(score, previousScore) (monotonic)
    if (previousScore != null) {
      score = max(score, previousScore);
    }

    final level = levelOf(score);

    return RiskResult(score: score, level: level, stagesSeen: stagesSeen);
  }

  /// Determines [RiskLevel] for a given score (0-29 low, 30-59 medium, 60-100 high).
  static RiskLevel levelOf(int score) {
    if (score >= 60) return RiskLevel.high;
    if (score >= 30) return RiskLevel.medium;
    return RiskLevel.low;
  }

  /// Selects up to 6 evidence rows for the verdict:
  /// For each seen stage, picks highest confidence event (prefers LLM on tie),
  /// sorted by atSec ascending.
  static List<TacticEvent> selectEvidence(List<TacticEvent> events) {
    final bestByStage = <Stage, TacticEvent>{};
    for (final event in events) {
      final existing = bestByStage[event.stage];
      if (existing == null) {
        bestByStage[event.stage] = event;
      } else {
        if (event.confidence > existing.confidence) {
          bestByStage[event.stage] = event;
        } else if (event.confidence == existing.confidence) {
          if (event.source == EventSource.llm &&
              existing.source == EventSource.lexicon) {
            bestByStage[event.stage] = event;
          }
        }
      }
    }

    final sorted = bestByStage.values.toList()
      ..sort((a, b) => a.atSec.compareTo(b.atSec));

    return sorted.take(6).toList();
  }
}
