import 'package:scamshield/engine/models.dart';

class DemoSource {
  new({
    required this.script,
    this.interval = const Duration(milliseconds: 1200),
  });

  final DemoScript script;
  final Duration interval;

  Stream<Segment> streamSegments() async* {
    for (final segment in script.segments) {
      if (interval > Duration.zero) {
        await Future<void>.delayed(interval);
      }
      yield segment;
    }
  }

  LlmAnalysis? get cannedLlm => script.llm;
}
