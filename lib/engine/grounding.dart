import 'package:scamshield/engine/lexicon.dart';
import 'package:scamshield/engine/models.dart';

class GroundingResult {
  const new({required this.events, required this.entities});

  final List<TacticEvent> events;
  final Entities entities;
}

class Grounding {
  const new _();

  static GroundingResult filter({
    required List<TacticEvent> events,
    required Entities entities,
    required List<Segment> segments,
  }) {
    if (segments.isEmpty) {
      return const GroundingResult(events: [], entities: Entities());
    }

    final transcriptJoined = segments.map((s) => s.text).join(' ');
    final normTranscriptJoined = normalize(transcriptJoined);
    final lowerTranscript = transcriptJoined.toLowerCase();
    final digitsTranscript = transcriptJoined.replaceAll(RegExp(r'\D'), '');

    // 1. Filter events
    final filteredEvents = <TacticEvent>[];
    for (final event in events) {
      final normQuote = normalize(event.quote);
      if (normQuote.isEmpty) continue;

      final words = normQuote.split(' ').where((w) => w.isNotEmpty).toList();
      if (words.length < 3) continue;

      if (!normTranscriptJoined.contains(normQuote)) continue;

      // Re-derive atSec from segments
      var atSec = segments.first.startSec;
      var found = false;

      // Check single segment first
      for (final s in segments) {
        if (normalize(s.text).contains(normQuote)) {
          atSec = s.startSec;
          found = true;
          break;
        }
      }

      // Check sliding window of 2 adjacent segments
      if (!found && segments.length >= 2) {
        for (var i = 0; i < segments.length - 1; i++) {
          final joined = '${segments[i].text} ${segments[i + 1].text}';
          if (normalize(joined).contains(normQuote)) {
            atSec = segments[i].startSec;
            found = true;
            break;
          }
        }
      }

      filteredEvents.add(
        event.copyWith(
          atSec: atSec,
          confidence: event.confidence.clamp(0.0, 1.0),
        ),
      );
    }

    // 2. Filter entities
    final filteredPhones = entities.phones.where((p) {
      final digits = p.replaceAll(RegExp(r'\D'), '');
      return digits.isNotEmpty && digitsTranscript.contains(digits);
    }).toList();

    final filteredAccounts = entities.accounts.where((a) {
      final digits = a.replaceAll(RegExp(r'\D'), '');
      return digits.isNotEmpty && digitsTranscript.contains(digits);
    }).toList();

    final filteredUpiIds = entities.upiIds.where((u) {
      final lower = u.toLowerCase().trim();
      return lower.isNotEmpty && lowerTranscript.contains(lower);
    }).toList();

    String? filterTextField(String? field) {
      if (field == null) return null;
      final lower = field.toLowerCase().trim();
      if (lower.isEmpty) return null;
      return lowerTranscript.contains(lower) ? field : null;
    }

    final filteredEntities = Entities(
      claimedAgency: filterTextField(entities.claimedAgency),
      claimedName: filterTextField(entities.claimedName),
      caseNo: filterTextField(entities.caseNo),
      amountAsked: filterTextField(entities.amountAsked),
      phones: filteredPhones,
      upiIds: filteredUpiIds,
      accounts: filteredAccounts,
    );

    return GroundingResult(events: filteredEvents, entities: filteredEntities);
  }
}
