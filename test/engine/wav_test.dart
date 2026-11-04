import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:scamshield/core/result.dart';
import 'package:scamshield/engine/wav.dart';

void main() {
  group('WAV utils', () {
    test('builds synthetic 61 s WAV and splits into 25s, 25s, 11s chunks', () {
      // 16000 Hz, 1 channel, 16-bit (2 bytes per sample) -> 32000 bytes/sec
      const sampleRate = 16000;
      const numChannels = 1;
      const bytesPerSec = sampleRate * numChannels * 2; // 32000
      const totalSec = 61;
      final pcmBytes = Uint8List(totalSec * bytesPerSec);

      final wavBytes = wavFromPcm16(pcmBytes);

      // Parse full wav
      final header = WavHeader.parse(wavBytes);
      expect(header.sampleRate, 16000);
      expect(header.numChannels, 1);
      expect(header.bitsPerSample, 16);
      expect(header.durationSec, closeTo(61.0, 0.01));

      // Split into 25s chunks
      final chunks = WavSplitter.split(wavBytes);
      expect(chunks.length, 3);

      expect(chunks[0].index, 0);
      expect(chunks[0].startSec, 0.0);
      expect(chunks[0].durationSec, closeTo(25.0, 0.01));

      expect(chunks[1].index, 1);
      expect(chunks[1].startSec, closeTo(25.0, 0.01));
      expect(chunks[1].durationSec, closeTo(25.0, 0.01));

      expect(chunks[2].index, 2);
      expect(chunks[2].startSec, closeTo(50.0, 0.01));
      expect(chunks[2].durationSec, closeTo(11.0, 0.01));

      // Each chunk re-parses as valid WAV
      for (final chunk in chunks) {
        final chunkHeader = WavHeader.parse(chunk.bytes);
        expect(chunkHeader.sampleRate, 16000);
        expect(chunkHeader.numChannels, 1);
        expect(chunkHeader.bitsPerSample, 16);
        expect(chunkHeader.durationSec, closeTo(chunk.durationSec, 0.01));
      }
    });

    test('parses WAV with extra LIST chunk between fmt and data', () {
      const sampleRate = 16000;
      const numChannels = 1;
      final pcm = Uint8List(32000); // 1 sec

      // Build custom WAV with LIST chunk
      final riffSize = 4 + 24 + 16 + 8 + pcm.length;
      final bdata = ByteData(4)..setUint32(0, riffSize, Endian.little);
      final fmtSize = ByteData(4)..setUint32(0, 16, Endian.little);
      final fmtData = ByteData(16)
        ..setUint16(0, 1, Endian.little) // PCM
        ..setUint16(2, numChannels, Endian.little) // Mono
        ..setUint32(4, sampleRate, Endian.little) // 16 kHz
        ..setUint32(8, sampleRate * numChannels * 2, Endian.little) // byteRate
        ..setUint16(12, numChannels * 2, Endian.little) // blockAlign
        ..setUint16(14, 16, Endian.little); // bitsPerSample
      final listSize = ByteData(4)..setUint32(0, 8, Endian.little);
      final dataSize = ByteData(4)..setUint32(0, pcm.length, Endian.little);

      final bb = BytesBuilder()
        ..add(Uint8List.fromList('RIFF'.codeUnits))
        ..add(bdata.buffer.asUint8List())
        ..add(Uint8List.fromList('WAVE'.codeUnits))
        ..add(Uint8List.fromList('fmt '.codeUnits))
        ..add(fmtSize.buffer.asUint8List())
        ..add(fmtData.buffer.asUint8List())
        ..add(Uint8List.fromList('LIST'.codeUnits))
        ..add(listSize.buffer.asUint8List())
        ..add(Uint8List.fromList('INFOtest'.codeUnits))
        ..add(Uint8List.fromList('data'.codeUnits))
        ..add(dataSize.buffer.asUint8List())
        ..add(pcm);

      final fullWav = bb.toBytes();

      final header = WavHeader.parse(fullWav);
      expect(header.sampleRate, 16000);
      expect(header.numChannels, 1);
      expect(header.durationSec, closeTo(1.0, 0.01));
    });

    test('rejects non-PCM format with AudioFormatException', () {
      final pcm = Uint8List(1600);
      final validWav = wavFromPcm16(pcm);

      // Mutate format tag at offset 20 to 6 (A-law)
      final mutated = Uint8List.fromList(validWav);
      ByteData.view(mutated.buffer).setUint16(20, 6, Endian.little);

      expect(
        () => WavHeader.parse(mutated),
        throwsA(isA<AudioFormatException>()),
      );
    });

    test('rejects non-mono (stereo) with AudioFormatException', () {
      final pcm = Uint8List(1600);
      final validWav = wavFromPcm16(pcm);

      // Mutate channels at offset 22 to 2 (stereo)
      final mutated = Uint8List.fromList(validWav);
      ByteData.view(mutated.buffer).setUint16(22, 2, Endian.little);

      expect(
        () => WavHeader.parse(mutated),
        throwsA(isA<AudioFormatException>()),
      );
    });

    test('rejects non-16 kHz sample rate with AudioFormatException', () {
      final pcm = Uint8List(1600);
      final validWav = wavFromPcm16(pcm);

      // Mutate sample rate at offset 24 to 44100
      final mutated = Uint8List.fromList(validWav);
      ByteData.view(mutated.buffer).setUint32(24, 44100, Endian.little);

      expect(
        () => WavHeader.parse(mutated),
        throwsA(isA<AudioFormatException>()),
      );
    });
  });
}
