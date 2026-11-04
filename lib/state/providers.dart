import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scamshield/services/alert_service.dart';
import 'package:scamshield/services/guardian_store.dart';
import 'package:scamshield/services/llm_service.dart';
import 'package:scamshield/services/stt_service.dart';
import 'package:scamshield/services/tts_service.dart';
import 'package:scamshield/state/analysis_controller.dart';
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
  throw UnimplementedError(
    'sttServiceProvider must be overridden or configured',
  );
});

final llmServiceProvider = Provider<LlmService>((ref) {
  throw UnimplementedError(
    'llmServiceProvider must be overridden or configured',
  );
});

final alertServiceProvider = Provider<AlertService>((ref) {
  throw UnimplementedError(
    'alertServiceProvider must be overridden or configured',
  );
});

final ttsServiceProvider = Provider<TtsService>((ref) {
  return FlutterTtsService();
});

final analysisControllerProvider =
    NotifierProvider<AnalysisController, AnalysisState>(AnalysisController.new);
