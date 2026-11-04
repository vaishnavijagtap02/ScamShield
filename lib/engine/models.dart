import 'dart:typed_data';

enum Stage {
  authority,
  fear,
  urgency,
  secrecy,
  extraction;

  static Stage? fromString(String value) {
    final lower = value.toLowerCase().trim();
    for (final s in Stage.values) {
      if (s.name == lower) return s;
    }
    return null;
  }
}

enum RiskLevel {
  low,
  medium,
  high;

  static RiskLevel fromString(String value) {
    final lower = value.toLowerCase().trim();
    for (final r in RiskLevel.values) {
      if (r.name == lower) return r;
    }
    return RiskLevel.low;
  }
}

enum ScamType {
  digitalArrest,
  kycBank,
  courierParcel,
  traiSim,
  investment,
  loanApp,
  sextortion,
  familyEmergency,
  none,
  unknown;

  static ScamType fromJson(String? value) {
    if (value == null) return ScamType.unknown;
    return switch (value.toLowerCase().trim()) {
      'digital_arrest' => ScamType.digitalArrest,
      'kyc_bank' => ScamType.kycBank,
      'courier_parcel' => ScamType.courierParcel,
      'trai_sim' => ScamType.traiSim,
      'investment' => ScamType.investment,
      'loan_app' => ScamType.loanApp,
      'sextortion' => ScamType.sextortion,
      'family_emergency' => ScamType.familyEmergency,
      'none' => ScamType.none,
      _ => ScamType.unknown,
    };
  }

  String toJson() => switch (this) {
    ScamType.digitalArrest => 'digital_arrest',
    ScamType.kycBank => 'kyc_bank',
    ScamType.courierParcel => 'courier_parcel',
    ScamType.traiSim => 'trai_sim',
    ScamType.investment => 'investment',
    ScamType.loanApp => 'loan_app',
    ScamType.sextortion => 'sextortion',
    ScamType.familyEmergency => 'family_emergency',
    ScamType.none => 'none',
    ScamType.unknown => 'unknown',
  };
}

enum EventSource { lexicon, llm }

class Segment {
  const new({
    required this.index,
    required this.startSec,
    required this.endSec,
    required this.text,
  });

  factory fromJson(Map<String, dynamic> json, [int index = 0]) {
    return Segment(
      index: json['index'] as int? ?? index,
      startSec: (json['startSec'] as num).toDouble(),
      endSec: (json['endSec'] as num).toDouble(),
      text: json['text'] as String? ?? '',
    );
  }

  final int index;
  final double startSec;
  final double endSec;
  final String text;
}

class TacticEvent {
  const new({
    required this.stage,
    required this.quote,
    required this.atSec,
    required this.confidence,
    required this.source,
    this.explanationHi,
  });

  factory fromJson(
    Map<String, dynamic> json, {
    EventSource source = EventSource.llm,
    double defaultAtSec = 0,
  }) {
    final stageStr = json['stage'] as String? ?? '';
    final stage = Stage.fromString(stageStr);
    if (stage == null) {
      throw FormatException('Unknown stage: $stageStr');
    }
    return TacticEvent(
      stage: stage,
      quote: json['quote'] as String? ?? '',
      atSec: (json['atSec'] as num?)?.toDouble() ?? defaultAtSec,
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      source: source,
      explanationHi: json['explanation_hi'] as String?,
    );
  }

  final Stage stage;
  final String quote;
  final double atSec;
  final double confidence;
  final EventSource source;
  final String? explanationHi;

  TacticEvent copyWith({
    Stage? stage,
    String? quote,
    double? atSec,
    double? confidence,
    EventSource? source,
    String? explanationHi,
  }) {
    return TacticEvent(
      stage: stage ?? this.stage,
      quote: quote ?? this.quote,
      atSec: atSec ?? this.atSec,
      confidence: confidence ?? this.confidence,
      source: source ?? this.source,
      explanationHi: explanationHi ?? this.explanationHi,
    );
  }
}

class Entities {
  const new({
    this.claimedAgency,
    this.claimedName,
    this.caseNo,
    this.amountAsked,
    this.phones = const [],
    this.upiIds = const [],
    this.accounts = const [],
  });

  factory fromJson(Map<String, dynamic> json) {
    return Entities(
      claimedAgency: json['claimed_agency'] as String?,
      claimedName: json['claimed_name'] as String?,
      caseNo: json['case_no'] as String?,
      amountAsked: json['amount_asked'] as String?,
      phones: (json['phones'] as List<dynamic>?)?.cast<String>() ?? const [],
      upiIds: (json['upi_ids'] as List<dynamic>?)?.cast<String>() ?? const [],
      accounts:
          (json['accounts'] as List<dynamic>?)?.cast<String>() ?? const [],
    );
  }

  final String? claimedAgency;
  final String? claimedName;
  final String? caseNo;
  final String? amountAsked;
  final List<String> phones;
  final List<String> upiIds;
  final List<String> accounts;

  Entities copyWith({
    String? claimedAgency,
    String? claimedName,
    String? caseNo,
    String? amountAsked,
    List<String>? phones,
    List<String>? upiIds,
    List<String>? accounts,
  }) {
    return Entities(
      claimedAgency: claimedAgency ?? this.claimedAgency,
      claimedName: claimedName ?? this.claimedName,
      caseNo: caseNo ?? this.caseNo,
      amountAsked: amountAsked ?? this.amountAsked,
      phones: phones ?? this.phones,
      upiIds: upiIds ?? this.upiIds,
      accounts: accounts ?? this.accounts,
    );
  }
}

class RiskResult {
  const new({
    required this.score,
    required this.level,
    required this.stagesSeen,
  });

  final int score;
  final RiskLevel level;
  final Set<Stage> stagesSeen;
}

class Verdict {
  const new({
    required this.level,
    required this.score,
    required this.scamType,
    required this.evidence,
    required this.entities,
    required this.summaryHi,
    this.basicCheckOnly = false,
    this.partialAudio = false,
  });

  final RiskLevel level;
  final int score;
  final ScamType scamType;
  final List<TacticEvent> evidence;
  final Entities entities;
  final String summaryHi;
  final bool basicCheckOnly;
  final bool partialAudio;
}

class Answers {
  const new({
    this.paid = false,
    this.sharedCredentials = false,
    this.remoteApp = false,
  });

  factory fromJson(Map<String, dynamic> json) {
    return Answers(
      paid: json['paid'] as bool? ?? false,
      sharedCredentials: json['shared_credentials'] as bool? ?? false,
      remoteApp: json['remote_app'] as bool? ?? false,
    );
  }

  final bool paid;
  final bool sharedCredentials;
  final bool remoteApp;
}

class AudioChunk {
  const new({
    required this.index,
    required this.bytes,
    required this.startSec,
    required this.durationSec,
    this.filename,
  });

  final int index;
  final Uint8List bytes;
  final double startSec;
  final double durationSec;
  final String? filename;
}

class LlmAnalysis {
  const new({
    required this.scamType,
    required this.events,
    required this.entities,
    required this.summaryHi,
  });

  factory fromJson(Map<String, dynamic> json) {
    final rawEvents = json['events'] as List<dynamic>? ?? const [];
    final events = <TacticEvent>[];
    for (final item in rawEvents) {
      if (item is Map<String, dynamic>) {
        try {
          events.add(TacticEvent.fromJson(item));
        } on FormatException {
          // Drop malformed event per tolerant parsing requirement
        }
      }
    }

    final rawEntities = json['entities'] as Map<String, dynamic>?;
    final entities = rawEntities != null
        ? Entities.fromJson(rawEntities)
        : const Entities();

    return LlmAnalysis(
      scamType: ScamType.fromJson(json['scam_type'] as String?),
      events: events,
      entities: entities,
      summaryHi: json['summary_hi'] as String? ?? '',
    );
  }

  final ScamType scamType;
  final List<TacticEvent> events;
  final Entities entities;
  final String summaryHi;
}

class DemoScript {
  const new({
    required this.id,
    required this.kind,
    required this.title,
    required this.segments,
    this.llm,
    this.expected,
  });

  factory fromJson(Map<String, dynamic> json) {
    final rawSegments = json['segments'] as List<dynamic>? ?? const [];
    final segments = <Segment>[];
    for (var i = 0; i < rawSegments.length; i++) {
      final s = rawSegments[i];
      if (s is Map<String, dynamic>) {
        segments.add(Segment.fromJson(s, i));
      }
    }

    final rawLlm = json['llm'] as Map<String, dynamic>?;
    final llm = rawLlm != null ? LlmAnalysis.fromJson(rawLlm) : null;

    return DemoScript(
      id: json['id'] as String? ?? '',
      kind: json['kind'] as String? ?? '',
      title: json['title'] as String? ?? '',
      segments: segments,
      llm: llm,
      expected: json['expected'] as Map<String, dynamic>?,
    );
  }

  final String id;
  final String kind;
  final String title;
  final List<Segment> segments;
  final LlmAnalysis? llm;
  final Map<String, dynamic>? expected;
}
