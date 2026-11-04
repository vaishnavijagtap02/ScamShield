import 'package:flutter_test/flutter_test.dart';
import 'package:scamshield/core/config.dart';

void main() {
  test('Config.validate returns missing keys when env is empty', () {
    final missing = Config.validate();
    expect(missing, contains('SARVAM_API_KEY'));
    expect(missing, contains('LLM_BASE_URL'));
    expect(missing, contains('LLM_API_KEY'));
    expect(missing, contains('LLM_MODEL'));
    expect(missing, contains('TELEGRAM_BOT_TOKEN'));
    expect(missing, contains('TELEGRAM_BOT_USERNAME'));
  });
}
