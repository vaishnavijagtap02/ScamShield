import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:scamshield/engine/models.dart';
import 'package:scamshield/services/alert_service.dart';
import 'package:scamshield/state/providers.dart';
import 'package:scamshield/ui/strings.dart';
import 'package:scamshield/ui/theme/tokens.dart';
import 'package:scamshield/ui/widgets/big_button.dart';
import 'package:scamshield/ui/widgets/evidence_row.dart';
import 'package:scamshield/ui/widgets/level_banner.dart';
import 'package:scamshield/ui/widgets/responsive_layout.dart';
import 'package:scamshield/ui/widgets/stage_track.dart';
import 'package:scamshield/ui/widgets/status_line.dart';

class VerdictScreen extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<VerdictScreen> createState() => _VerdictScreenState();
}

class _VerdictScreenState extends ConsumerState<VerdictScreen> {
  bool _isSendingAlert = false;
  bool? _manualAlertSent;

  Future<void> _replayTts(Verdict verdict) async {
    final tts = ref.read(ttsServiceProvider);
    await tts.speakWarning(verdict.summaryHi);
  }

  Future<void> _sendAlertToFamily(Verdict verdict) async {
    setState(() => _isSendingAlert = true);

    final store = ref.read(guardianStoreProvider);
    final alertService = ref.read(alertServiceProvider);
    final guardians = store.getGuardians();

    if (guardians.isEmpty) {
      if (mounted) {
        await context.push('/guardians');
      }
      setState(() => _isSendingAlert = false);
      return;
    }

    final alertText = AlertTextBuilder.build(
      verdict: verdict,
      answers: const Answers(),
      userName: store.getUserName(),
    );

    try {
      final results = await alertService.sendAlert(
        text: alertText,
        guardians: guardians,
      );
      final anySuccess = results.values.any((s) => s);
      setState(() {
        _isSendingAlert = false;
        _manualAlertSent = anySuccess;
      });
    } on Object catch (_) {
      setState(() {
        _isSendingAlert = false;
        _manualAlertSent = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsControllerProvider);
    final s = S(settings.language);

    final analysisState = ref.watch(analysisControllerProvider);
    final verdict = analysisState.verdict;

    if (verdict == null) {
      return ResponsiveLayout(
        appBar: AppBar(title: Text(s.verdictTitle)),
        child: Center(
          child: BigButton(label: 'Home', onPressed: () => context.go('/')),
        ),
      );
    }

    final guardianState = ref.watch(guardianControllerProvider);
    final guardians = guardianState.guardians;

    // Collect timestamps of detected stages
    final seenStages = <Stage>{};
    final stageTimes = <Stage, double>{};
    for (final ev in verdict.evidence) {
      seenStages.add(ev.stage);
      if (!stageTimes.containsKey(ev.stage) ||
          ev.atSec < stageTimes[ev.stage]!) {
        stageTimes[ev.stage] = ev.atSec;
      }
    }

    final alertSent = _manualAlertSent ?? analysisState.alertSent;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          ref.read(analysisControllerProvider.notifier).reset();
          context.go('/');
        }
      },
      child: ResponsiveLayout(
        appBar: AppBar(
          title: Text(s.verdictTitle),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            tooltip: 'Home',
            onPressed: () {
              ref.read(analysisControllerProvider.notifier).reset();
              context.go('/');
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.volume_up_rounded, size: 28),
              tooltip: s.replayVoice,
              onPressed: () => _replayTts(verdict),
            ),
          ],
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenPadding,
              vertical: AppSpacing.s16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Level Banner
                LevelBanner(
                  level: verdict.level,
                  customSubtitle: verdict.summaryHi,
                ),
                const SizedBox(height: AppSpacing.s16),

                // Chips row (ScamType + basicCheckOnly)
                Wrap(
                  spacing: AppSpacing.s8,
                  runSpacing: AppSpacing.s8,
                  children: [
                    if (verdict.scamType != ScamType.none &&
                        verdict.scamType != ScamType.unknown)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.elevatedSurface,
                          borderRadius: AppRadius.border8,
                          border: Border.all(
                            color: AppColors.accent.withValues(alpha: 0.5),
                          ),
                        ),
                        child: Text(
                          s.scamTypeName(verdict.scamType),
                          style: AppTypography.label.copyWith(
                            color: AppColors.accent,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    if (verdict.basicCheckOnly)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.medTint,
                          borderRadius: AppRadius.border8,
                          border: Border.all(
                            color: AppColors.medStrong.withValues(alpha: 0.5),
                          ),
                        ),
                        child: Text(
                          s.labelBasicCheck,
                          style: AppTypography.caption.copyWith(
                            color: AppColors.medInk,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.s16),

                // Signature Playbook Track
                StageTrack(seenStages: seenStages, stageTimes: stageTimes),
                const SizedBox(height: AppSpacing.s24),

                // Evidence Section
                Text(
                  s.evidenceTitle,
                  style: AppTypography.h2.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: AppSpacing.s12),

                if (verdict.evidence.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.s16,
                    ),
                    child: Text(
                      s.noEvidenceFound,
                      style: AppTypography.body.copyWith(
                        color: AppColors.inkMuted,
                      ),
                    ),
                  )
                else
                  ...verdict.evidence.map((ev) => EvidenceRow(event: ev)),

                const SizedBox(height: AppSpacing.s24),

                // Primary button: Aage: kya karein?
                BigButton(
                  label: s.whatNextBtn,
                  onPressed: () => context.push('/questions'),
                ),
                const SizedBox(height: AppSpacing.s12),

                // Family Alert Button / Status
                if (alertSent == true) ...[
                  StatusLine(
                    message: s.alertSentSuccess(
                      guardians.isNotEmpty ? guardians.first.name : 'Family',
                    ),
                    isSuccess: true,
                  ),
                ] else if (alertSent == false) ...[
                  StatusLine(
                    message: s.alertFailed,
                    isError: true,
                    onRetry: () => _sendAlertToFamily(verdict),
                  ),
                ] else ...[
                  BigButton(
                    label: s.sendFamilyBtn,
                    variant: BigButtonVariant.secondary,
                    enabled: !_isSendingAlert,
                    onPressed: () => _sendAlertToFamily(verdict),
                  ),
                ],
                const SizedBox(height: AppSpacing.s24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
