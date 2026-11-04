import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class Guardian {
  const new({required this.name, required this.chatId, this.addedAt});

  factory fromJson(Map<String, dynamic> json) {
    return Guardian(
      name: json['name'] as String? ?? '',
      chatId: (json['chat_id'] as num?)?.toInt() ?? 0,
      addedAt: json['added_at'] != null
          ? DateTime.tryParse(json['added_at'] as String)
          : null,
    );
  }

  final String name;
  final int chatId;
  final DateTime? addedAt;

  Map<String, dynamic> toJson() => {
    'name': name,
    'chat_id': chatId,
    if (addedAt != null) 'added_at': addedAt!.toIso8601String(),
  };
}

class GuardianStore {
  const new(this._prefs);

  final SharedPreferences _prefs;

  static const _keyGuardians = 'scamshield_guardians';
  static const _keyAutoAlert = 'scamshield_auto_alert';
  static const _keyUserName = 'scamshield_user_name';
  static const _keyLanguage = 'scamshield_language';

  List<Guardian> getGuardians() {
    final raw = _prefs.getStringList(_keyGuardians) ?? [];
    final guardians = <Guardian>[];
    for (final str in raw) {
      try {
        final map = jsonDecode(str) as Map<String, dynamic>;
        guardians.add(Guardian.fromJson(map));
      } on Exception {
        // Skip corrupted entries
      }
    }
    return guardians;
  }

  Future<void> saveGuardian(Guardian guardian) async {
    final current =
        getGuardians().where((g) => g.chatId != guardian.chatId).toList()
          ..add(guardian);
    final strings = current.map((g) => jsonEncode(g.toJson())).toList();
    await _prefs.setStringList(_keyGuardians, strings);
  }

  Future<void> removeGuardian(int chatId) async {
    final current = getGuardians().where((g) => g.chatId != chatId).toList();
    final strings = current.map((g) => jsonEncode(g.toJson())).toList();
    await _prefs.setStringList(_keyGuardians, strings);
  }

  bool getAutoAlert() => _prefs.getBool(_keyAutoAlert) ?? true;

  Future<void> setAutoAlert({required bool enabled}) async {
    await _prefs.setBool(_keyAutoAlert, enabled);
  }

  String? getUserName() => _prefs.getString(_keyUserName);

  Future<void> setUserName(String name) async {
    await _prefs.setString(_keyUserName, name);
  }

  String getLanguage() => _prefs.getString(_keyLanguage) ?? 'hi';

  Future<void> setLanguage(String lang) async {
    await _prefs.setString(_keyLanguage, lang);
  }
}
