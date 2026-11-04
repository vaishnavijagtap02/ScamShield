import 'dart:typed_data';

import 'package:scamshield/core/result.dart';
import 'package:scamshield/engine/models.dart';
import 'package:scamshield/engine/wav.dart';

class UploadSource {
  const new _();

  static List<AudioChunk> process({
    required Uint8List bytes,
    required String filename,
    double? durationSec,
  }) {
    final lowerName = filename.toLowerCase();
    if (lowerName.endsWith('.wav')) {
      return WavSplitter.split(bytes);
    }

    final isSupportedNonWav =
        lowerName.endsWith('.mp3') ||
        lowerName.endsWith('.m4a') ||
        lowerName.endsWith('.ogg');

    if (!isSupportedNonWav) {
      throw AudioFormatException('Unsupported file format: $filename');
    }

    final duration = durationSec ?? 0.0;
    if (duration > 30.0) {
      throw const AudioFormatException(
        'Non-WAV files must be 30 seconds or shorter',
      );
    }

    return [
      AudioChunk(
        index: 0,
        bytes: bytes,
        startSec: 0,
        durationSec: duration,
        filename: filename,
      ),
    ];
  }
}
