import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:scamshield/engine/models.dart';
import 'package:scamshield/state/analysis_controller.dart';
import 'package:scamshield/state/providers.dart';
import 'package:scamshield/ui/strings.dart';
import 'package:scamshield/ui/theme/tokens.dart';
import 'package:scamshield/ui/widgets/big_button.dart';
import 'package:scamshield/ui/widgets/risk_meter.dart';
import 'package:scamshield/ui/widgets/section_card.dart';
import 'package:scamshield/ui/widgets/stage_track.dart';

class AnalysingScreen extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<AnalysingScreen> createState() => _AnalysingScreenState();
}

class _AnalysingScreenState extends ConsumerState<AnalysingScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsControllerProvider);
    final s = S(settings.language);

    final state = ref.watch(analysisControllerProvider);

    // Auto-navigate to /verdict on completion
    ref.listen<AnalysisState>(analysisControllerProvider, (prev, next) {
      if (next.phase == AnalysisPhase.done && next.verdict != null) {
        context.go('/verdict');
      }
      if (next.segments.length != (prev?.segments.length ?? 0)) {
        _scrollToBottom();
      }
    });

    final isError = state.phase == AnalysisPhase.error;

    // Collect timestamps of detected stages
    final stageTimes = <Stage, double>{};
    for (final ev in state.events) {
      if (!stageTimes.containsKey(ev.stage) ||
          ev.atSec < stageTimes[ev.stage]!) {
        stageTimes[ev.stage] = ev.atSec;
      }
    }

    final progressFraction = state.piecesTotal > 0
        ? (state.piecesDone / state.piecesTotal).clamp(0.0, 1.0)
        : 0.1;

    return Scaffold(
      appBar: AppBar(
        title: Text(s.analysingTitle),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenPadding,
            vertical: AppSpacing.s12,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Playbook Track
              StageTrack(
                seenStages: state.risk.stagesSeen,
                stageTimes: stageTimes,
              ),
              const SizedBox(height: AppSpacing.s16),

              // Risk Meter
              RiskMeter(score: state.risk.score, level: state.risk.level),
              const SizedBox(height: AppSpacing.s16),

              // Progress bar + caption
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ClipRRect(
                    borderRadius: AppRadius.border8,
                    child: LinearProgressIndicator(
                      value: progressFraction,
                      minHeight: 8,
                      backgroundColor: AppColors.line,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.ink,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s8),
                  Text(
                    state.piecesTotal > 0
                        ? s.piecesProgress(state.piecesDone, state.piecesTotal)
                        : s.listeningStatus,
                    style: AppTypography.caption.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.s12),

              // Partial audio notice
              if (state.partialAudio) ...[
                Container(
                  padding: const EdgeInsets.all(AppSpacing.s8),
                  decoration: BoxDecoration(
                    color: AppColors.medTint,
                    borderRadius: AppRadius.border8,
                    border: Border.all(color: AppColors.medStrong),
                  ),
                  child: Text(
                    s.notePartialAudio,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.medInk,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.s8),
              ],

              // Error State
              if (isError) ...[
                SectionCard(
                  child: Column(
                    children: [
                      const Icon(
                        Icons.signal_wifi_off_rounded,
                        color: AppColors.highStrong,
                        size: 36,
                      ),
                      const SizedBox(height: AppSpacing.s8),
                      Text(
                        state.errorKey == 'errNoNetwork'
                            ? s.errNoNetwork
                            : (state.errorKey ?? 'Error occurred'),
                        style: AppTypography.bodyStrong.copyWith(
                          color: AppColors.highStrong,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.s16),
                      BigButton(
                        label: s.runDemoBtn,
                        onPressed: () {
                          ref.read(analysisControllerProvider.notifier).reset();
                          context.go('/demo');
                        },
                      ),
                    ],
                  ),
                ),
                const Spacer(),
              ] else ...[
                // Transcript Stream View
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: AppRadius.border12,
                      border: Border.all(color: AppColors.line, width: 1.5),
                    ),
                    padding: const EdgeInsets.all(AppSpacing.s12),
                    child: state.segments.isEmpty
                        ? Center(
                            child: Text(
                              s.listeningStatus,
                              style: AppTypography.body.copyWith(
                                color: AppColors.inkMuted,
                              ),
                            ),
                          )
                        : ListView.separated(
                            controller: _scrollController,
                            itemCount: state.segments.length,
                            separatorBuilder: (context, index) =>
                                const Divider(),
                            itemBuilder: (context, index) {
                              final seg = state.segments[index];
                              final matchedQuotes = state.events
                                  .map((e) => e.quote.toLowerCase())
                                  .toList();

                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4,
                                ),
                                child: Text(
                                  seg.text,
                                  style: AppTypography.body.copyWith(
                                    backgroundColor:
                                        matchedQuotes.any(
                                          (q) => seg.text
                                              .toLowerCase()
                                              .contains(q),
                                        )
                                        ? AppColors.highlight
                                        : Colors.transparent,
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ),
                const SizedBox(height: AppSpacing.s16),

                // Stop button
                BigButton(
                  label: s.stopBtn,
                  variant: BigButtonVariant.secondary,
                  onPressed: () {
                    ref.read(analysisControllerProvider.notifier).reset();
                    context.go('/');
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
