import 'dart:async';
import 'dart:typed_data';

import 'package:record/record.dart';
import 'package:scamshield/core/result.dart';
import 'package:scamshield/engine/models.dart';
import 'package:scamshield/engine/wav.dart';

class MicSource {
  new({
    AudioRecorder? recorder,
    this.chunkDurationSec = 6.0,
    this.sampleRate = 16000,
    this.numChannels = 1,
  }) : _recorder = recorder ?? AudioRecorder();

  final AudioRecorder _recorder;
  final double chunkDurationSec;
  final int sampleRate;
  final int numChannels;

  StreamSubscription<Uint8List>? _recordSub;
  StreamController<AudioChunk>? _chunkController;
  final List<int> _buffer = [];
  double _currentStartSec = 0;
  int _chunkIndex = 0;

  int get _bytesPerChunk =>
      (chunkDurationSec * sampleRate * numChannels * 2).round();

  Future<Stream<AudioChunk>> startStream() async {
    final hasPermission = await _recorder.hasPermission();
    if (!hasPermission) {
      throw const AudioFormatException('Microphone permission not granted');
    }

    _chunkController = StreamController<AudioChunk>();
    _buffer.clear();
    _currentStartSec = 0;
    _chunkIndex = 0;

    const recordConfig = RecordConfig(
      encoder: AudioEncoder.pcm16bits,
      sampleRate: 16000,
      numChannels: 1,
    );

    final rawStream = await _recorder.startStream(recordConfig);

    _recordSub = rawStream.listen(
      (chunk) {
        _buffer.addAll(chunk);
        final targetBytes = _bytesPerChunk;
        while (_buffer.length >= targetBytes) {
          final pcmSlice = Uint8List.fromList(_buffer.sublist(0, targetBytes));
          _buffer.removeRange(0, targetBytes);

          final wavBytes = wavFromPcm16(
            pcmSlice,
            sampleRate: sampleRate,
            numChannels: numChannels,
          );

          _chunkController?.add(
            AudioChunk(
              index: _chunkIndex++,
              bytes: wavBytes,
              startSec: _currentStartSec,
              durationSec: chunkDurationSec,
              filename: 'mic_chunk_$_chunkIndex.wav',
            ),
          );

          _currentStartSec += chunkDurationSec;
        }
      },
      onError: (Object error) {
        _chunkController?.addError(error);
      },
      onDone: () {
        _flushRemaining();
        unawaited(_chunkController?.close());
      },
    );

    return _chunkController!.stream;
  }

  void _flushRemaining() {
    if (_buffer.isNotEmpty &&
        _chunkController != null &&
        !_chunkController!.isClosed) {
      final pcmSlice = Uint8List.fromList(_buffer);
      _buffer.clear();
      final duration = pcmSlice.length / (sampleRate * numChannels * 2);
      final wavBytes = wavFromPcm16(
        pcmSlice,
        sampleRate: sampleRate,
        numChannels: numChannels,
      );
      _chunkController!.add(
        AudioChunk(
          index: _chunkIndex++,
          bytes: wavBytes,
          startSec: _currentStartSec,
          durationSec: duration,
          filename: 'mic_chunk_$_chunkIndex.wav',
        ),
      );
      _currentStartSec += duration;
    }
  }

  Future<void> stop() async {
    await _recordSub?.cancel();
    _recordSub = null;
    await _recorder.stop();
    _flushRemaining();
    await _chunkController?.close();
    _chunkController = null;
  }

  Future<void> dispose() async {
    await stop();
    await _recorder.dispose();
  }
}
