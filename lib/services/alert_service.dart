import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:scamshield/engine/models.dart';
import 'package:scamshield/services/guardian_store.dart';

class AlertTextBuilder {
  const new _();

  static String _formatTime(double sec) {
    final totalSec = sec.floor();
    final m = (totalSec ~/ 60).toString().padLeft(2, '0');
    final s = (totalSec % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  static String _scamTypeHi(ScamType type) {
    return switch (type) {
      ScamType.digitalArrest => 'Digital Arrest',
      ScamType.kycBank => 'KYC / Bank Fraud',
      ScamType.courierParcel => 'Courier / Parcel Scam',
      ScamType.traiSim => 'TRAI / SIM Block Scam',
      ScamType.investment => 'Investment Scam',
      ScamType.loanApp => 'Loan App Fraud',
      ScamType.sextortion => 'Sextortion Scam',
      ScamType.familyEmergency => 'Family Emergency Scam',
      ScamType.none => 'Koi fraud nahi',
      ScamType.unknown => 'Anjaan call',
    };
  }

  static String _levelWord(RiskLevel level) {
    return switch (level) {
      RiskLevel.high => 'KHATRA',
      RiskLevel.medium => 'SAVDHAAN',
      RiskLevel.low => 'SURAKSHIT',
    };
  }

  /// Builds a plain-text Telegram alert message guaranteed to be <= 700 chars.
  static String build({
    required Verdict verdict,
    required Answers answers,
    String? userName,
  }) {
    final name = userName != null && userName.trim().isNotEmpty
        ? userName.trim()
        : 'Aapke parivaar ke sadasya';
    final levelWord = _levelWord(verdict.level);
    final scamTypeHi = _scamTypeHi(verdict.scamType);

    final sortedEvidence = List<TacticEvent>.from(verdict.evidence)
      ..sort((a, b) => b.confidence.compareTo(a.confidence));
    final topEvidence = sortedEvidence.take(3).toList();

    final actionAdvice = answers.paid
        ? 'Paise bhej diye gaye hain — abhi call karein aur 1930 pe report karwayein.'
        : 'Please abhi unhe call karein.';

    String renderMessage(List<String> quoteTexts) {
      final buffer = StringBuffer()
        ..writeln(
          'ScamShield: $name ne ek call check ki — $levelWord ($scamTypeHi).',
        )
        ..writeln(verdict.summaryHi)
        ..writeln('Saboot:');
      for (var i = 0; i < topEvidence.length; i++) {
        final ev = topEvidence[i];
        final quote = i < quoteTexts.length ? quoteTexts[i] : ev.quote;
        buffer.writeln('[${_formatTime(ev.atSec)}] "$quote"');
      }
      buffer.write(actionAdvice);
      return buffer.toString().trim();
    }

    final quotes = topEvidence.map((e) => e.quote).toList();
    var result = renderMessage(quotes);

    if (result.length > 700) {
      for (var i = 0; i < quotes.length; i++) {
        if (result.length <= 700) break;
        final excess = result.length - 700;
        final q = quotes[i];
        if (q.length > 20) {
          final maxLen = (q.length - excess - 4).clamp(10, q.length);
          quotes[i] = '${q.substring(0, maxLen)}...';
          result = renderMessage(quotes);
        }
      }
      if (result.length > 700) {
        result = result.substring(0, 700);
      }
    }

    return result;
  }
}

abstract class AlertService {
  Future<Guardian?> pollForPairing(String code);
  Future<Map<int, bool>> sendAlert({
    required String text,
    required List<Guardian> guardians,
  });
  String getPairingUrl(String code);
}

class TelegramAlertService implements AlertService {
  new({
    required this.botToken,
    required this.botUsername,
    http.Client? client,
    this.timeout = const Duration(seconds: 10),
  }) : _client = client ?? http.Client();

  final String botToken;
  final String botUsername;
  final Duration timeout;
  final http.Client _client;

  int _lastOffset = 0;
  int get lastOffset => _lastOffset;

  @override
  String getPairingUrl(String code) => 'https://t.me/$botUsername?start=$code';

  @override
  Future<Guardian?> pollForPairing(String code) async {
    final uri = Uri.parse(
      'https://api.telegram.org/bot$botToken/getUpdates?offset=$_lastOffset&timeout=0',
    );

    try {
      final response = await _client.get(uri).timeout(timeout);
      if (response.statusCode != 200) {
        return null;
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final ok = json['ok'] as bool? ?? false;
      if (!ok) return null;

      final updates = json['result'] as List<dynamic>? ?? [];
      for (final update in updates) {
        if (update is! Map<String, dynamic>) continue;
        final updateId = (update['update_id'] as num?)?.toInt() ?? 0;
        if (updateId >= _lastOffset) {
          _lastOffset = updateId + 1;
        }

        final message = update['message'] as Map<String, dynamic>?;
        if (message == null) continue;

        final text = message['text'] as String? ?? '';
        if (text.trim() == '/start $code') {
          final from = message['from'] as Map<String, dynamic>? ?? {};
          final chat = message['chat'] as Map<String, dynamic>? ?? {};
          final name = from['first_name'] as String? ?? 'Guardian';
          final chatId = (chat['id'] as num?)?.toInt() ?? 0;
          return Guardian(name: name, chatId: chatId, addedAt: DateTime.now());
        }
      }
    } on Exception {
      // Network or timeout during polling -> return null
    }

    return null;
  }

  @override
  Future<Map<int, bool>> sendAlert({
    required String text,
    required List<Guardian> guardians,
  }) async {
    final results = <int, bool>{};
    final uri = Uri.parse('https://api.telegram.org/bot$botToken/sendMessage');

    for (final guardian in guardians) {
      try {
        final payload = {'chat_id': guardian.chatId, 'text': text};
        // NO parse_mode per SECURITY.md §6 and TESTING.md §5
        final response = await _client
            .post(
              uri,
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode(payload),
            )
            .timeout(timeout);

        results[guardian.chatId] = response.statusCode == 200;
      } on Exception {
        results[guardian.chatId] = false;
      }
    }

    return results;
  }
}
