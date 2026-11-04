import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:scamshield/core/result.dart';
import 'package:scamshield/engine/models.dart';

class WavHeader {
  const new({
    required this.audioFormat,
    required this.numChannels,
    required this.sampleRate,
    required this.byteRate,
    required this.blockAlign,
    required this.bitsPerSample,
    required this.dataOffset,
    required this.dataSize,
  });

  /// Parses a WAV file header and locates the `fmt ` and `data` chunks.
  /// Throws [AudioFormatException] on invalid or unsupported formats.
  factory parse(Uint8List bytes) {
    if (bytes.length < 12) {
      throw const AudioFormatException('File too short to be a valid WAV');
    }

    final byteData = ByteData.sublistView(bytes);

    final riffTag = ascii.decode(bytes.sublist(0, 4));
    final waveTag = ascii.decode(bytes.sublist(8, 12));

    if (riffTag != 'RIFF' || waveTag != 'WAVE') {
      throw const AudioFormatException('Not a RIFF/WAVE file');
    }

    int? audioFormat;
    int? numChannels;
    int? sampleRate;
    int? byteRate;
    int? blockAlign;
    int? bitsPerSample;
    int? dataOffset;
    int? dataSize;

    var offset = 12;
    while (offset + 8 <= bytes.length) {
      final chunkId = ascii.decode(bytes.sublist(offset, offset + 4));
      final chunkSize = byteData.getUint32(offset + 4, Endian.little);
      final chunkDataOffset = offset + 8;

      if (chunkId == 'fmt ') {
        if (chunkSize < 16) {
          throw const AudioFormatException('Corrupted fmt chunk');
        }
        audioFormat = byteData.getUint16(chunkDataOffset, Endian.little);
        numChannels = byteData.getUint16(chunkDataOffset + 2, Endian.little);
        sampleRate = byteData.getUint32(chunkDataOffset + 4, Endian.little);
        byteRate = byteData.getUint32(chunkDataOffset + 8, Endian.little);
        blockAlign = byteData.getUint16(chunkDataOffset + 12, Endian.little);
        bitsPerSample = byteData.getUint16(chunkDataOffset + 14, Endian.little);
      } else if (chunkId == 'data') {
        dataOffset = chunkDataOffset;
        dataSize = math.min(chunkSize, bytes.length - chunkDataOffset);
      }

      // Word alignment: if chunk size is odd, skip 1 padding byte
      final padding = chunkSize.isOdd ? 1 : 0;
      offset += 8 + chunkSize + padding;
    }

    if (audioFormat == null ||
        numChannels == null ||
        sampleRate == null ||
        byteRate == null ||
        blockAlign == null ||
        bitsPerSample == null ||
        dataOffset == null ||
        dataSize == null) {
      throw const AudioFormatException('Missing required fmt or data chunk');
    }

    if (audioFormat != 1) {
      throw AudioFormatException(
        'Unsupported audio format: $audioFormat (only PCM16 is supported)',
      );
    }

    if (numChannels != 1) {
      throw AudioFormatException(
        'Unsupported channels: $numChannels (only mono is supported)',
      );
    }

    if (sampleRate != 16000) {
      throw AudioFormatException(
        'Unsupported sample rate: $sampleRate (only 16 kHz is supported)',
      );
    }

    if (bitsPerSample != 16) {
      throw AudioFormatException(
        'Unsupported bits per sample: $bitsPerSample (only 16-bit is supported)',
      );
    }

    return WavHeader(
      audioFormat: audioFormat,
      numChannels: numChannels,
      sampleRate: sampleRate,
      byteRate: byteRate,
      blockAlign: blockAlign,
      bitsPerSample: bitsPerSample,
      dataOffset: dataOffset,
      dataSize: dataSize,
    );
  }

  final int audioFormat;
  final int numChannels;
  final int sampleRate;
  final int byteRate;
  final int blockAlign;
  final int bitsPerSample;
  final int dataOffset;
  final int dataSize;

  double get durationSec => byteRate > 0 ? dataSize / byteRate : 0.0;
}

/// Encapsulates raw PCM16 samples with a standard 44-byte WAV header.
Uint8List wavFromPcm16(
  Uint8List pcmBytes, {
  int sampleRate = 16000,
  int numChannels = 1,
}) {
  final byteRate = sampleRate * numChannels * 2;
  final blockAlign = numChannels * 2;
  const bitsPerSample = 16;
  final totalDataLen = pcmBytes.length;
  final totalFileLen = totalDataLen + 36;

  final header = ByteData(44)
    ..setUint8(0, 0x52) // 'R'
    ..setUint8(1, 0x49) // 'I'
    ..setUint8(2, 0x46) // 'F'
    ..setUint8(3, 0x46) // 'F'
    ..setUint32(4, totalFileLen, Endian.little)
    ..setUint8(8, 0x57) // 'W'
    ..setUint8(9, 0x41) // 'A'
    ..setUint8(10, 0x56) // 'V'
    ..setUint8(11, 0x45) // 'E'
    ..setUint8(12, 0x66) // 'f'
    ..setUint8(13, 0x6D) // 'm'
    ..setUint8(14, 0x74) // 't'
    ..setUint8(15, 0x20) // ' '
    ..setUint32(16, 16, Endian.little) // Subchunk1Size (16 for PCM)
    ..setUint16(20, 1, Endian.little) // AudioFormat (1 for PCM)
    ..setUint16(22, numChannels, Endian.little)
    ..setUint32(24, sampleRate, Endian.little)
    ..setUint32(28, byteRate, Endian.little)
    ..setUint16(32, blockAlign, Endian.little)
    ..setUint16(34, bitsPerSample, Endian.little)
    ..setUint8(36, 0x64) // 'd'
    ..setUint8(37, 0x61) // 'a'
    ..setUint8(38, 0x74) // 't'
    ..setUint8(39, 0x61) // 'a'
    ..setUint32(40, totalDataLen, Endian.little);

  final builder = BytesBuilder(copy: false)
    ..add(header.buffer.asUint8List())
    ..add(pcmBytes);

  return builder.toBytes();
}

class WavSplitter {
  const new _();

  /// Splits WAV bytes into a list of [AudioChunk]s of up to [chunkDurationSec] seconds.
  static List<AudioChunk> split(
    Uint8List wavBytes, {
    double chunkDurationSec = 25,
  }) {
    final header = WavHeader.parse(wavBytes);
    final bytesPerSec = header.byteRate;
    final maxChunkBytes = (chunkDurationSec * bytesPerSec).round();
    final alignedChunkBytes =
        maxChunkBytes - (maxChunkBytes % header.blockAlign);

    final chunks = <AudioChunk>[];
    var currentOffset = header.dataOffset;
    final endOffset = header.dataOffset + header.dataSize;
    var index = 0;

    while (currentOffset < endOffset) {
      final remaining = endOffset - currentOffset;
      final currentChunkBytes = math.min(remaining, alignedChunkBytes);
      final pcmSlice = wavBytes.sublist(
        currentOffset,
        currentOffset + currentChunkBytes,
      );

      final startSec = (currentOffset - header.dataOffset) / bytesPerSec;
      final durationSec = pcmSlice.length / bytesPerSec;

      final chunkWav = wavFromPcm16(
        pcmSlice,
        sampleRate: header.sampleRate,
        numChannels: header.numChannels,
      );

      chunks.add(
        AudioChunk(
          index: index++,
          bytes: chunkWav,
          startSec: startSec,
          durationSec: durationSec,
        ),
      );

      currentOffset += currentChunkBytes;
    }

    return chunks;
  }
}
