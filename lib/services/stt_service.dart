import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:scamshield/core/result.dart';
import 'package:scamshield/engine/models.dart';

abstract class SttService {
  Future<List<Segment>> transcribe(AudioChunk chunk);
}

class SarvamSttService implements SttService {
  new({
    required this.apiKey,
    http.Client? client,
    this.mode = 'codemix',
    this.timeout = const Duration(seconds: 20),
    this.retryDelay = const Duration(milliseconds: 800),
    this.baseUrl = 'https://api.sarvam.ai/speech-to-text',
  }) : _client = client ?? http.Client();

  final String apiKey;
  final http.Client _client;
  final String mode;
  final Duration timeout;
  final Duration retryDelay;
  final String baseUrl;

  http.MultipartRequest _buildRequest(AudioChunk chunk) {
    final request = http.MultipartRequest('POST', Uri.parse(baseUrl));
    request.headers['api-subscription-key'] = apiKey;
    request.fields['model'] = 'saaras:v3';
    request.fields['mode'] = mode;
    request.fields['language_code'] = 'unknown';
    request.fields['with_timestamps'] = 'true';
    request.files.add(
      http.MultipartFile.fromBytes(
        'file',
        chunk.bytes,
        filename: chunk.filename ?? 'chunk_${chunk.index}.wav',
      ),
    );
    return request;
  }

  Future<http.Response> _executeWithRetry(AudioChunk chunk) async {
    http.Response? response;
    try {
      final req1 = _buildRequest(chunk);
      final streamed1 = await _client.send(req1).timeout(timeout);
      response = await http.Response.fromStream(streamed1);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return response;
      }
      if (response.statusCode >= 400 && response.statusCode < 500) {
        // 4xx: no retry -> throw SttException
        throw SttException(
          'STT client error: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on SttException {
      rethrow;
    } on Exception {
      // 5xx or timeout or network error -> proceed to retry
    }

    if (retryDelay > Duration.zero) {
      await Future<void>.delayed(retryDelay);
    }

    try {
      final req2 = _buildRequest(chunk);
      final streamed2 = await _client.send(req2).timeout(timeout);
      final retryResponse = await http.Response.fromStream(streamed2);
      if (retryResponse.statusCode >= 200 && retryResponse.statusCode < 300) {
        return retryResponse;
      }
      throw SttException(
        'STT server error: ${retryResponse.statusCode}',
        statusCode: retryResponse.statusCode,
      );
    } on SttException {
      rethrow;
    } on Exception catch (e) {
      throw SttException(
        'STT request failed: $e',
        statusCode: response?.statusCode,
      );
    }
  }

  @override
  Future<List<Segment>> transcribe(AudioChunk chunk) async {
    final response = await _executeWithRetry(chunk);
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final transcript = json['transcript'] as String? ?? '';
    final timestamps = json['timestamps'] as Map<String, dynamic>?;

    if (timestamps != null) {
      final words = (timestamps['words'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList();
      final startTimes =
          (timestamps['start_time_seconds'] as List<dynamic>? ?? [])
              .map((e) => (e as num).toDouble())
              .toList();
      final endTimes = (timestamps['end_time_seconds'] as List<dynamic>? ?? [])
          .map((e) => (e as num).toDouble())
          .toList();

      if (words.isNotEmpty &&
          words.length == startTimes.length &&
          words.length == endTimes.length) {
        final segments = <Segment>[];
        for (var i = 0; i < words.length; i++) {
          segments.add(
            Segment(
              index: i,
              text: words[i],
              startSec: chunk.startSec + startTimes[i],
              endSec: chunk.startSec + endTimes[i],
            ),
          );
        }
        return segments;
      }
    }

    return [
      Segment(
        index: 0,
        text: transcript,
        startSec: chunk.startSec,
        endSec: chunk.startSec + chunk.durationSec,
      ),
    ];
  }
}
