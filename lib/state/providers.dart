import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scamshield/core/config.dart';
import 'package:scamshield/services/alert_service.dart';
import 'package:scamshield/services/guardian_store.dart';
import 'package:scamshield/services/llm_service.dart';
import 'package:scamshield/services/stt_service.dart';
import 'package:scamshield/services/tts_service.dart';
import 'package:scamshield/state/analysis_controller.dart';
import 'package:scamshield/state/guardian_controller.dart';
import 'package:scamshield/state/settings_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'sharedPreferencesProvider must be overridden in ProviderScope',
  );
});

final guardianStoreProvider = Provider<GuardianStore>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return GuardianStore(prefs);
});

final sttServiceProvider = Provider<SttService>((ref) {
  return SarvamSttService(apiKey: Config.sarvamApiKey);
});

final llmServiceProvider = Provider<LlmService>((ref) {
  return OpenAiCompatibleLlmService(
    baseUrl: Config.llmBaseUrl,
    apiKey: Config.llmApiKey,
    model: Config.llmModel,
  );
});

final alertServiceProvider = Provider<AlertService>((ref) {
  return TelegramAlertService(
    botToken: Config.telegramBotToken,
    botUsername: Config.telegramBotUsername,
  );
});

final ttsServiceProvider = Provider<TtsService>((ref) {
  return FlutterTtsService();
});

final analysisControllerProvider =
    NotifierProvider<AnalysisController, AnalysisState>(AnalysisController.new);

final guardianControllerProvider =
    NotifierProvider<GuardianController, GuardianState>(GuardianController.new);

final settingsControllerProvider =
    NotifierProvider<SettingsController, SettingsState>(SettingsController.new);
