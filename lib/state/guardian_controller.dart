import 'dart:async';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scamshield/services/alert_service.dart';
import 'package:scamshield/services/guardian_store.dart';
import 'package:scamshield/state/providers.dart';

class GuardianState {
  const new({
    this.guardians = const [],
    this.autoAlert = true,
    this.userName = '',
    this.pairingCode,
    this.pairingUrl,
    this.isPolling = false,
    this.countdown = 120,
    this.pairingSuccessName,
    this.pairingTimedOut = false,
    this.lastError,
  });

  final List<Guardian> guardians;
  final bool autoAlert;
  final String userName;
  final String? pairingCode;
  final String? pairingUrl;
  final bool isPolling;
  final int countdown;
  final String? pairingSuccessName;
  final bool pairingTimedOut;
  final String? lastError;

  GuardianState copyWith({
    List<Guardian>? guardians,
    bool? autoAlert,
    String? userName,
    String? pairingCode,
    String? pairingUrl,
    bool? isPolling,
    int? countdown,
    String? pairingSuccessName,
    bool? pairingTimedOut,
    String? lastError,
  }) {
    return GuardianState(
      guardians: guardians ?? this.guardians,
      autoAlert: autoAlert ?? this.autoAlert,
      userName: userName ?? this.userName,
      pairingCode: pairingCode ?? this.pairingCode,
      pairingUrl: pairingUrl ?? this.pairingUrl,
      isPolling: isPolling ?? this.isPolling,
      countdown: countdown ?? this.countdown,
      pairingSuccessName: pairingSuccessName ?? this.pairingSuccessName,
      pairingTimedOut: pairingTimedOut ?? this.pairingTimedOut,
      lastError: lastError ?? this.lastError,
    );
  }
}

class GuardianController extends Notifier<GuardianState> {
  new({GuardianStore? store, AlertService? alertService})
    : _injectedStore = store,
      _injectedAlert = alertService;

  final GuardianStore? _injectedStore;
  final AlertService? _injectedAlert;

  Timer? _countdownTimer;
  Timer? _pollingTimer;

  GuardianStore get _store {
    final injected = _injectedStore;
    if (injected != null) return injected;
    return ref.read(guardianStoreProvider);
  }

  AlertService get _alert {
    final injected = _injectedAlert;
    if (injected != null) return injected;
    return ref.read(alertServiceProvider);
  }

  @override
  GuardianState build() {
    ref.onDispose(() {
      _countdownTimer?.cancel();
      _pollingTimer?.cancel();
    });

    try {
      final store = _store;
      return GuardianState(
        guardians: store.getGuardians(),
        autoAlert: store.getAutoAlert(),
        userName: store.getUserName() ?? '',
      );
    } on Object {
      return const GuardianState();
    }
  }

  void load() {
    try {
      final store = _store;
      state = state.copyWith(
        guardians: store.getGuardians(),
        autoAlert: store.getAutoAlert(),
        userName: store.getUserName() ?? '',
      );
    } on Object {
      // Ignore if store not available
    }
  }

  Future<void> removeGuardian(int chatId) async {
    try {
      await _store.removeGuardian(chatId);
      load();
    } on Object {
      // Standalone mode
    }
  }

  Future<void> setAutoAlert({required bool enabled}) async {
    try {
      await _store.setAutoAlert(enabled: enabled);
      state = state.copyWith(autoAlert: enabled);
    } on Object {
      state = state.copyWith(autoAlert: enabled);
    }
  }

  Future<void> setUserName(String name) async {
    try {
      await _store.setUserName(name);
      state = state.copyWith(userName: name);
    } on Object {
      state = state.copyWith(userName: name);
    }
  }

  String _generatePairingCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final random = Random();
    return List.generate(10, (_) => chars[random.nextInt(chars.length)]).join();
  }

  void startPairing() {
    _countdownTimer?.cancel();
    _pollingTimer?.cancel();

    final code = _generatePairingCode();
    String url;
    try {
      url = _alert.getPairingUrl(code);
    } on Object {
      url = 'https://t.me/scamshield_bot?start=$code';
    }

    state = state.copyWith(
      pairingCode: code,
      pairingUrl: url,
      isPolling: true,
      countdown: 120,
    );

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.countdown <= 1) {
        stopPairing(timedOut: true);
      } else {
        state = state.copyWith(countdown: state.countdown - 1);
      }
    });

    _pollingTimer = Timer.periodic(const Duration(seconds: 2), (timer) async {
      try {
        final guardian = await _alert.pollForPairing(code);
        if (guardian != null) {
          await _store.saveGuardian(guardian);
          stopPairing(successName: guardian.name);
          load();
        }
      } on Object {
        // Polling failure, will retry next tick
      }
    });
  }

  void stopPairing({String? successName, bool timedOut = false}) {
    _countdownTimer?.cancel();
    _pollingTimer?.cancel();
    _countdownTimer = null;
    _pollingTimer = null;

    state = state.copyWith(
      isPolling: false,
      pairingTimedOut: timedOut,
      pairingSuccessName: successName,
    );
  }
}
