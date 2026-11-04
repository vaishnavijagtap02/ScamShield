class Config {
  const new _();

  static const String sarvamApiKey = String.fromEnvironment('SARVAM_API_KEY');
  static const String sttMode = String.fromEnvironment(
    'STT_MODE',
    defaultValue: 'codemix',
  );
  static const String llmBaseUrl = String.fromEnvironment('LLM_BASE_URL');
  static const String llmApiKey = String.fromEnvironment('LLM_API_KEY');
  static const String llmModel = String.fromEnvironment('LLM_MODEL');
  static const String telegramBotToken = String.fromEnvironment(
    'TELEGRAM_BOT_TOKEN',
  );
  static const String telegramBotUsername = String.fromEnvironment(
    'TELEGRAM_BOT_USERNAME',
  );
  static const bool demoOnly = bool.fromEnvironment('DEMO_ONLY');

  /// Returns list of missing required environment configuration keys.
  static List<String> validate() {
    final missing = <String>[];
    if (sarvamApiKey.isEmpty) missing.add('SARVAM_API_KEY');
    if (llmBaseUrl.isEmpty) missing.add('LLM_BASE_URL');
    if (llmApiKey.isEmpty) missing.add('LLM_API_KEY');
    if (llmModel.isEmpty) missing.add('LLM_MODEL');
    if (telegramBotToken.isEmpty) missing.add('TELEGRAM_BOT_TOKEN');
    if (telegramBotUsername.isEmpty) missing.add('TELEGRAM_BOT_USERNAME');
    return missing;
  }
}
