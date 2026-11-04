import 'dart:math';

import 'package:scamshield/engine/models.dart';

String normalize(String text) {
  return text
      .toLowerCase()
      .replaceAll(RegExp(r'[^\p{L}\p{M}\p{N}\s]', unicode: true), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

class Lexicon {
  const new _();

  static final RegExp _authorityRegex = _buildRegex(const [
    'cbi',
    'ed',
    'enforcement directorate',
    'police',
    'crime branch',
    'cyber cell',
    'customs',
    'ncb',
    'narcotics bureau',
    'trai',
    'rbi',
    'reserve bank',
    'inspector',
    'officer',
    'dcp',
    'court',
    'judge',
    'fedex courier',
    'सीबीआई',
    'पुलिस',
    'अधिकारी',
    'इंस्पेक्टर',
    'कस्टम्स',
    'अदालत',
  ]);

  static final RegExp _fearRegex = _buildRegex(const [
    'arrest',
    'warrant',
    'fir',
    'money laundering',
    'drugs?',
    'narcotics?',
    'parcel',
    'aadhaar',
    'illegal',
    'jail',
    'giraftar',
    'case darj',
    'case registered',
    'khilaaf',
    'गिरफ्तार',
    'गिरफ़्तार',
    'वारंट',
    'जेल',
    'ड्रग्स',
    'केस दर्ज',
    'खिलाफ',
    'अवैध',
  ]);

  static final RegExp _urgencyRegex = _buildRegex(const [
    'abhi',
    'turant',
    'immediately',
    'right now',
    'jaldi',
    r'(\d+|ek|do|teen) ghante',
    r'within \d+ (hours?|minutes?)',
    'aaj hi',
    'isi waqt',
    'अभी',
    'तुरंत',
    'जल्दी',
    'घंटे में',
  ]);

  static final RegExp _secrecyRegex = _buildRegex(const [
    r'kisi ko (bhi )?(mat|na|nahi) bata\w*',
    'don t tell',
    'do not tell',
    'confidential',
    'secret',
    r'(phone|call) (mat|na) kaat\w*',
    r'camera on rakh\w*',
    'akele',
    'alone',
    r'किसी को (भी )?(मत|ना|नहीं) बता[\p{L}\p{M}]*',
    r'कॉल (मत|ना) काट[\p{L}\p{M}]*',
    'गोपनीय',
  ]);

  static final RegExp _extractionRegex = _buildRegex(const [
    'otp',
    'pin',
    'transfer',
    'rtgs',
    'neft',
    'upi',
    'account number',
    'safe account',
    'rbi account',
    'verification (fee|amount|charge)',
    'refundable',
    'anydesk',
    'teamviewer',
    'screen share',
    'quick support',
    r'(paise|paisa|rupaye) bhej\w*',
    r'पैसे भेज[\p{L}\p{M}]*',
    'ट्रांसफर',
    'खाते में',
  ]);

  static final List<RegExp> _negationGuards = [
    RegExp(
      r'(otp|pin)\s.{0,25}(share mat|mat (bata|share)\w*|na (bata|share)\w*|never share|do not share|don t share)',
      unicode: true,
      caseSensitive: false,
    ),
    RegExp(
      '(kabhi|never|nahi).{0,12}(otp|pin)',
      unicode: true,
      caseSensitive: false,
    ),
    RegExp(
      r'(otp|pin).{0,12}nahi maang\w*',
      unicode: true,
      caseSensitive: false,
    ),
  ];

  static RegExp _buildRegex(List<String> terms) {
    final pattern = terms
        .map((t) => '(?<![\\p{L}\\p{M}])$t(?![\\p{L}\\p{M}])')
        .join('|');
    return RegExp(pattern, unicode: true, caseSensitive: false);
  }

  /// Scans a single [Segment] and returns matching [TacticEvent]s.
  /// Each matching stage yields at most ONE event.
  static List<TacticEvent> scan(Segment segment) {
    final norm = normalize(segment.text);
    if (norm.isEmpty) return const [];

    final events = <TacticEvent>[];

    // Check authority
    final authMatch = _authorityRegex.firstMatch(norm);
    if (authMatch != null) {
      events.add(
        TacticEvent(
          stage: Stage.authority,
          quote: _expandQuote(segment.text, authMatch.group(0)!),
          atSec: segment.startSec,
          confidence: 0.5,
          source: EventSource.lexicon,
        ),
      );
    }

    // Check fear
    final fearMatch = _fearRegex.firstMatch(norm);
    if (fearMatch != null) {
      events.add(
        TacticEvent(
          stage: Stage.fear,
          quote: _expandQuote(segment.text, fearMatch.group(0)!),
          atSec: segment.startSec,
          confidence: 0.5,
          source: EventSource.lexicon,
        ),
      );
    }

    // Check urgency
    final urgMatch = _urgencyRegex.firstMatch(norm);
    if (urgMatch != null) {
      events.add(
        TacticEvent(
          stage: Stage.urgency,
          quote: _expandQuote(segment.text, urgMatch.group(0)!),
          atSec: segment.startSec,
          confidence: 0.5,
          source: EventSource.lexicon,
        ),
      );
    }

    // Check secrecy
    final secMatch = _secrecyRegex.firstMatch(norm);
    if (secMatch != null) {
      events.add(
        TacticEvent(
          stage: Stage.secrecy,
          quote: _expandQuote(segment.text, secMatch.group(0)!),
          atSec: segment.startSec,
          confidence: 0.5,
          source: EventSource.lexicon,
        ),
      );
    }

    // Check extraction (with negation guard)
    final extMatch = _extractionRegex.firstMatch(norm);
    if (extMatch != null) {
      final isNegated = _negationGuards.any((g) => g.hasMatch(norm));
      if (!isNegated) {
        events.add(
          TacticEvent(
            stage: Stage.extraction,
            quote: _expandQuote(segment.text, extMatch.group(0)!),
            atSec: segment.startSec,
            confidence: 0.5,
            source: EventSource.lexicon,
          ),
        );
      }
    }

    return events;
  }

  /// Expands matched substring to surrounding <= 8 words from original text.
  static String _expandQuote(String originalText, String matchedNorm) {
    final words = originalText.trim().split(RegExp(r'\s+'));
    if (words.length <= 8) return words.join(' ');

    // Find the word index that matches or contains the first word of the match
    final firstMatchWord = matchedNorm.split(RegExp(r'\s+')).first;
    var matchIndex = -1;
    for (var i = 0; i < words.length; i++) {
      final normWord = normalize(words[i]);
      if (normWord.contains(firstMatchWord) ||
          firstMatchWord.contains(normWord)) {
        matchIndex = i;
        break;
      }
    }

    if (matchIndex == -1) {
      return words.take(8).join(' ');
    }

    final start = max(0, matchIndex - 3);
    final end = min(words.length, start + 8);
    final adjustedStart = max(0, end - 8);

    return words.sublist(adjustedStart, end).join(' ');
  }
}
