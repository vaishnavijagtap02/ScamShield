import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:scamshield/engine/models.dart';
import 'package:scamshield/sources/mic_source.dart';
import 'package:scamshield/state/providers.dart';
import 'package:scamshield/ui/strings.dart';
import 'package:scamshield/ui/theme/tokens.dart';
import 'package:scamshield/ui/widgets/big_button.dart';
import 'package:scamshield/ui/widgets/level_banner.dart';
import 'package:scamshield/ui/widgets/responsive_layout.dart';
import 'package:scamshield/ui/widgets/risk_meter.dart';
import 'package:scamshield/ui/widgets/section_card.dart';
import 'package:scamshield/ui/widgets/stage_track.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class LiveGuardScreen extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<LiveGuardScreen> createState() => _LiveGuardScreenState();
}

class _LiveGuardScreenState extends ConsumerState<LiveGuardScreen> {
  Timer? _timer;
  int _secondsElapsed = 0;
  bool _permissionDenied = false;
  bool _isStopping = false;

  @override
  void initState() {
    super.initState();
    unawaited(_startLive());
  }

  Future<void> _startLive() async {
    setState(() => _permissionDenied = false);

    try {
      await WakelockPlus.enable();
    } on Object {
      // Wakelock fallback
    }

    try {
      final controller = ref.read(analysisControllerProvider.notifier);
      await controller.startLive(micSource: MicSource());

      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) {
          setState(() => _secondsElapsed++);
        }
      });
    } on Object {
      setState(() => _permissionDenied = true);
    }
  }

  Future<void> _stopLive() async {
    if (_isStopping) return;
    setState(() => _isStopping = true);

    _timer?.cancel();
    try {
      await WakelockPlus.disable();
    } on Object {
      // Wakelock fallback
    }

    final controller = ref.read(analysisControllerProvider.notifier);
    await controller.stopLive();

    if (mounted) {
      context.go('/verdict');
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    try {
      unawaited(WakelockPlus.disable());
    } on Object {
      // Ignore
    }
    super.dispose();
  }

  static String _formatTime(int sec) {
    final m = (sec ~/ 60).toString().padLeft(2, '0');
    final s = (sec % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsControllerProvider);
    final s = S(settings.language);

    final analysisState = ref.watch(analysisControllerProvider);
    final risk = analysisState.risk;
    final lastSegments = analysisState.segments.length > 3
        ? analysisState.segments.sublist(analysisState.segments.length - 3)
        : analysisState.segments;

    // Collect timestamps of detected stages
    final stageTimes = <Stage, double>{};
    for (final ev in analysisState.events) {
      if (!stageTimes.containsKey(ev.stage) ||
          ev.atSec < stageTimes[ev.stage]!) {
        stageTimes[ev.stage] = ev.atSec;
      }
    }

    return ResponsiveLayout(
      appBar: AppBar(title: Text(s.liveGuardBtn)),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenPadding,
            vertical: AppSpacing.s12,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_permissionDenied) ...[
                SectionCard(
                  child: Column(
                    children: [
                      const Icon(
                        Icons.mic_off_rounded,
                        color: AppColors.highStrong,
                        size: 36,
                      ),
                      const SizedBox(height: AppSpacing.s8),
                      Text(
                        s.errMicPermission,
                        style: AppTypography.body.copyWith(
                          color: AppColors.highStrong,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.s16),
                      BigButton(label: 'Retry', onPressed: _startLive),
                    ],
                  ),
                ),
                const Spacer(),
              ] else ...[
                // Instruction card
                SectionCard(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withValues(alpha: 0.15),
                          borderRadius: AppRadius.border8,
                        ),
                        child: const Icon(
                          Icons.volume_up_rounded,
                          color: AppColors.accent,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.s12),
                      Expanded(
                        child: Text(
                          s.liveInstruction,
                          style: AppTypography.bodyStrong.copyWith(
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.s12),

                // Listening indicator: glowing emerald dot + timer
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: AppColors.accent,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.accent,
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.s8),
                      Text(
                        '${s.liveListening} · ${_formatTime(_secondsElapsed)}',
                        style: AppTypography.bodyStrong.copyWith(
                          color: AppColors.accent,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.s12),

                // On HIGH: Banner slides in
                if (risk.level == RiskLevel.high) ...[
                  const LevelBanner(level: RiskLevel.high),
                  const SizedBox(height: AppSpacing.s16),
                ],

                // Playbook Track
                StageTrack(seenStages: risk.stagesSeen, stageTimes: stageTimes),
                const SizedBox(height: AppSpacing.s16),

                // Risk Meter
                RiskMeter(score: risk.score, level: risk.level),
                const SizedBox(height: AppSpacing.s16),

                // Last 3 transcript lines
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.s16),
                    decoration: BoxDecoration(
                      color: AppColors.cardSurface,
                      borderRadius: AppRadius.border16,
                      border: Border.all(color: AppColors.line),
                    ),
                    child: lastSegments.isEmpty
                        ? Center(
                            child: Text(
                              s.listeningStatus,
                              style: AppTypography.caption.copyWith(
                                color: AppColors.inkMuted,
                              ),
                            ),
                          )
                        : ListView.separated(
                            itemCount: lastSegments.length,
                            separatorBuilder: (context, index) =>
                                const Divider(color: AppColors.line),
                            itemBuilder: (context, index) {
                              final seg = lastSegments[index];
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4,
                                ),
                                child: Text(
                                  seg.text,
                                  style: AppTypography.body.copyWith(
                                    color: AppColors.ink,
                                    fontSize: 16,
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ),
                const SizedBox(height: AppSpacing.s16),

                // Stop & Show Result Button
                BigButton(
                  label: s.stopAndShowResult,
                  enabled: !_isStopping,
                  onPressed: _stopLive,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
