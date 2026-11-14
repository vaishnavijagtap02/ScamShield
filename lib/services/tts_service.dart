import 'package:flutter_tts/flutter_tts.dart';

abstract class TtsService {
  Future<void> speakWarning(String text);
  Future<void> stop();
}

class FlutterTtsService implements TtsService {
  new({FlutterTts? tts}) : _tts = tts ?? FlutterTts();

  final FlutterTts _tts;

  @override
  Future<void> speakWarning(String text) async {
    try {
      await _tts.setLanguage('hi-IN');
      await _tts.setSpeechRate(0.45);
      await _tts.speak(text);
    } on Object {
      // Per ARCHITECTURE §7: TTS language missing -> silent, skip voice
    }
  }

  @override
  Future<void> stop() async {
    try {
      await _tts.stop();
    } on Object {
      // Ignore stop errors
    }
  }
}
