import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:scamshield/core/result.dart';
import 'package:scamshield/engine/models.dart';
import 'package:scamshield/services/stt_service.dart';

void main() {
  group('SarvamSttService', () {
    final dummyWavBytes = Uint8List(100);
    final testChunk = AudioChunk(
      index: 1,
      bytes: dummyWavBytes,
      startSec: 10,
      durationSec: 15,
    );

    test(
      'parses sarvam_sample.json with timestamps into List<Segment>',
      () async {
        final sampleJson = File('test/fixtures/sarvam_sample.json')
            .readAsStringSync();

        final mockClient = MockClient((request) async {
          expect(request.url.toString(), contains('speech-to-text'));
          expect(request.headers['api-subscription-key'], equals('test-key'));
          return http.Response(sampleJson, 200);
        });

        final service = SarvamSttService(
          apiKey: 'test-key',
          client: mockClient,
          retryDelay: Duration.zero,
        );

        final segments = await service.transcribe(testChunk);
        expect(segments.length, equals(2));
        // First segment: chunk.startSec (10) + 0.0 = 10.0
        expect(segments[0].startSec, equals(10.0));
        expect(segments[0].endSec, closeTo(13.1, 0.01));
        expect(segments[0].text, contains('Inspector Sharma'));

        // Second segment: chunk.startSec (10) + 3.2 = 13.2
        expect(segments[1].startSec, closeTo(13.2, 0.01));
        expect(segments[1].endSec, closeTo(15.9, 0.01));
        expect(segments[1].text, contains('parcel'));
      },
    );

    test('handles timestamps: null by returning single Segment', () async {
      final responseBody = jsonEncode({
        'request_id': 'req_null_ts',
        'transcript': 'This is full transcript without timestamps.',
        'language_code': 'hi-IN',
        'timestamps': null,
      });

      final mockClient = MockClient((request) async {
        return http.Response(responseBody, 200);
      });

      final service = SarvamSttService(
        apiKey: 'test-key',
        client: mockClient,
        retryDelay: Duration.zero,
      );

      final segments = await service.transcribe(testChunk);
      expect(segments.length, equals(1));
      expect(
        segments[0].text,
        equals('This is full transcript without timestamps.'),
      );
      expect(segments[0].startSec, equals(10.0));
      expect(segments[0].endSec, equals(25.0)); // 10.0 + 15.0
    });

    test('retries on 500 error once and succeeds if retry is 200', () async {
      var callCount = 0;
      final mockClient = MockClient((request) async {
        callCount++;
        if (callCount == 1) {
          return http.Response('Server Error', 500);
        }
        return http.Response(
          jsonEncode({
            'transcript': 'Recovered after retry',
            'timestamps': null,
          }),
          200,
        );
      });

      final service = SarvamSttService(
        apiKey: 'test-key',
        client: mockClient,
        retryDelay: Duration.zero,
      );

      final segments = await service.transcribe(testChunk);
      expect(callCount, equals(2));
      expect(segments.single.text, equals('Recovered after retry'));
    });

    test('fails without retry on 4xx and throws SttException', () async {
      var callCount = 0;
      final mockClient = MockClient((request) async {
        callCount++;
        return http.Response('Unauthorized', 401);
      });

      final service = SarvamSttService(
        apiKey: 'test-key',
        client: mockClient,
        retryDelay: Duration.zero,
      );

      await expectLater(
        service.transcribe(testChunk),
        throwsA(
          isA<SttException>().having((e) => e.statusCode, 'statusCode', 401),
        ),
      );
      expect(callCount, equals(1));
    });

    test('throws SttException after 5xx retry failure', () async {
      var callCount = 0;
      final mockClient = MockClient((request) async {
        callCount++;
        return http.Response('Service Unavailable', 503);
      });

      final service = SarvamSttService(
        apiKey: 'test-key',
        client: mockClient,
        retryDelay: Duration.zero,
      );

      await expectLater(
        service.transcribe(testChunk),
        throwsA(
          isA<SttException>().having((e) => e.statusCode, 'statusCode', 503),
        ),
      );
      expect(callCount, equals(2));
    });
  });
}
