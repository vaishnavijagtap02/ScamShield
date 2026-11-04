import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:scamshield/core/result.dart';
import 'package:scamshield/engine/wav.dart';
import 'package:scamshield/sources/upload_source.dart';

void main() {
  group('UploadSource', () {
    test('splits WAV bytes into 25s chunks', () {
      // 61 seconds of 16kHz mono 16-bit PCM = 61 * 32000 = 1,952,000 bytes
      final pcmBytes = Uint8List(61 * 32000);
      final wavBytes = wavFromPcm16(pcmBytes);

      final chunks = UploadSource.process(
        bytes: wavBytes,
        filename: 'recording.wav',
      );

      expect(chunks.length, equals(3));
      expect(chunks[0].startSec, equals(0.0));
      expect(chunks[0].durationSec, equals(25.0));
      expect(chunks[1].startSec, equals(25.0));
      expect(chunks[1].durationSec, equals(25.0));
      expect(chunks[2].startSec, equals(50.0));
      expect(chunks[2].durationSec, closeTo(11.0, 0.01));
    });

    test('MP3 <= 30s returns single AudioChunk with original filename', () {
      final dummyBytes = Uint8List(1000);
      final chunks = UploadSource.process(
        bytes: dummyBytes,
        filename: 'voice_call.mp3',
        durationSec: 22,
      );

      expect(chunks.length, equals(1));
      expect(chunks.first.filename, equals('voice_call.mp3'));
      expect(chunks.first.durationSec, equals(22.0));
    });

    test('M4A > 30s throws AudioFormatException', () {
      final dummyBytes = Uint8List(1000);
      expect(
        () => UploadSource.process(
          bytes: dummyBytes,
          filename: 'long_call.m4a',
          durationSec: 35,
        ),
        throwsA(isA<AudioFormatException>()),
      );
    });

    test('unsupported file extension throws AudioFormatException', () {
      final dummyBytes = Uint8List(1000);
      expect(
        () => UploadSource.process(bytes: dummyBytes, filename: 'notes.pdf'),
        throwsA(isA<AudioFormatException>()),
      );
    });
  });
}
