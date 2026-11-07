import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scamshield/services/guardian_store.dart';
import 'package:scamshield/state/providers.dart';
import 'package:scamshield/ui/strings.dart';

class SettingsState {
  const new({this.language = AppLanguage.hiLat});

  final AppLanguage language;

  SettingsState copyWith({AppLanguage? language}) {
    return SettingsState(language: language ?? this.language);
  }
}

class SettingsController extends Notifier<SettingsState> {
  new({GuardianStore? store}) : _injectedStore = store;

  final GuardianStore? _injectedStore;

  GuardianStore get _store {
    final injected = _injectedStore;
    if (injected != null) return injected;
    return ref.read(guardianStoreProvider);
  }

  @override
  SettingsState build() {
    try {
      final store = _store;
      final langStr = store.getLanguage();
      final lang = langStr == 'hi_dev' ? AppLanguage.hiDev : AppLanguage.hiLat;
      return SettingsState(language: lang);
    } on Object {
      return const SettingsState();
    }
  }

  Future<void> setLanguage(AppLanguage language) async {
    state = state.copyWith(language: language);
    try {
      final store = _store;
      await store.setLanguage(
        language == AppLanguage.hiDev ? 'hi_dev' : 'hi_lat',
      );
    } on Object {
      // Standalone mode
    }
  }

  Future<void> toggleLanguage() async {
    final newLang = state.language == AppLanguage.hiLat
        ? AppLanguage.hiDev
        : AppLanguage.hiLat;
    await setLanguage(newLang);
  }
}
