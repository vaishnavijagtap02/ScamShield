import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:scamshield/core/config.dart';
import 'package:scamshield/state/providers.dart';
import 'package:scamshield/ui/strings.dart';
import 'package:scamshield/ui/theme/tokens.dart';
import 'package:scamshield/ui/widgets/big_button.dart';
import 'package:scamshield/ui/widgets/section_card.dart';
import 'package:scamshield/ui/widgets/status_line.dart';

class GuardiansScreen extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<GuardiansScreen> createState() => _GuardiansScreenState();
}

class _GuardiansScreenState extends ConsumerState<GuardiansScreen> {
  bool _showingPairing = false;
  bool _linkCopied = false;

  void _startPairing() {
    setState(() {
      _showingPairing = true;
      _linkCopied = false;
    });
    ref.read(guardianControllerProvider.notifier).startPairing();
  }

  void _closePairing() {
    ref.read(guardianControllerProvider.notifier).stopPairing();
    setState(() => _showingPairing = false);
  }

  static String _formatCountdown(int sec) {
    final m = sec ~/ 60;
    final s = (sec % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsControllerProvider);
    final s = S(settings.language);

    final guardianState = ref.watch(guardianControllerProvider);
    final guardians = guardianState.guardians;

    return Scaffold(
      appBar: AppBar(title: Text(s.guardiansTitle)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenPadding,
            vertical: AppSpacing.s16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Auto Alert Switch Row
              SectionCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.s16,
                  vertical: 8,
                ),
                child: SizedBox(
                  height: 56,
                  child: Row(
                    children: [
                      const Icon(
                        Icons.notifications_active_outlined,
                        color: AppColors.ink,
                        size: 24,
                      ),
                      const SizedBox(width: AppSpacing.s12),
                      Expanded(
                        child: Text(
                          s.autoAlertSwitch,
                          style: AppTypography.bodyStrong.copyWith(
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Switch(
                        value: guardianState.autoAlert,
                        activeThumbColor: AppColors.ink,
                        onChanged: (val) async {
                          await ref
                              .read(guardianControllerProvider.notifier)
                              .setAutoAlert(enabled: val);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.s16),

              // If pairing modal/view is active
              if (_showingPairing) ...[
                Expanded(
                  child: SingleChildScrollView(
                    child: SectionCard(
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(s.addGuardianBtn, style: AppTypography.h2),
                              IconButton(
                                icon: const Icon(Icons.close_rounded),
                                onPressed: _closePairing,
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.s12),

                          if (guardianState.pairingSuccessName != null) ...[
                            StatusLine(
                              message: s.guardianJoined(
                                guardianState.pairingSuccessName!,
                              ),
                              isSuccess: true,
                            ),
                            const SizedBox(height: AppSpacing.s16),
                            BigButton(label: 'Done', onPressed: _closePairing),
                          ] else if (guardianState.pairingTimedOut) ...[
                            StatusLine(
                              message: s.pairingTimeout,
                              isError: true,
                              onRetry: _startPairing,
                              retryLabel: 'Dobara koshish karein',
                            ),
                          ] else ...[
                            Text(
                              s.scanInstruction(
                                Config.telegramBotUsername.isNotEmpty
                                    ? Config.telegramBotUsername
                                    : 'scamshield_bot',
                              ),
                              style: AppTypography.body,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: AppSpacing.s16),

                            // QR code
                            if (guardianState.pairingUrl != null)
                              Container(
                                padding: const EdgeInsets.all(AppSpacing.s12),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: AppRadius.border12,
                                  border: Border.all(
                                    color: AppColors.line,
                                    width: 1.5,
                                  ),
                                ),
                                child: QrImageView(
                                  data: guardianState.pairingUrl!,
                                  size: 220,
                                  backgroundColor: AppColors.surface,
                                ),
                              ),
                            const SizedBox(height: AppSpacing.s12),

                            // Selectable Link
                            if (guardianState.pairingUrl != null) ...[
                              InkWell(
                                onTap: () async {
                                  await Clipboard.setData(
                                    ClipboardData(
                                      text: guardianState.pairingUrl!,
                                    ),
                                  );
                                  setState(() => _linkCopied = true);
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.paper,
                                    borderRadius: AppRadius.border8,
                                    border: Border.all(color: AppColors.line),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.copy_rounded,
                                        size: 16,
                                        color: AppColors.inkMuted,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        _linkCopied
                                            ? s.linkCopied
                                            : guardianState.pairingUrl!,
                                        style: AppTypography.caption.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                            const SizedBox(height: AppSpacing.s16),

                            // Countdown status
                            Text(
                              '${s.waitingCountdown} ${_formatCountdown(guardianState.countdown)}',
                              style: AppTypography.caption.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.ink,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ] else ...[
                // List of Guardians
                Expanded(
                  child: guardians.isEmpty
                      ? Center(
                          child: Text(
                            s.noGuardians,
                            style: AppTypography.body.copyWith(
                              color: AppColors.inkMuted,
                            ),
                          ),
                        )
                      : ListView.separated(
                          itemCount: guardians.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: AppSpacing.s12),
                          itemBuilder: (context, index) {
                            final g = guardians[index];
                            return SectionCard(
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.person_outline_rounded,
                                    size: 28,
                                    color: AppColors.ink,
                                  ),
                                  const SizedBox(width: AppSpacing.s12),
                                  Expanded(
                                    child: Text(
                                      g.name,
                                      style: AppTypography.bodyStrong,
                                    ),
                                  ),
                                  IconButton(
                                    tooltip: s.removeBtn,
                                    icon: const Icon(
                                      Icons.delete_outline_rounded,
                                      color: AppColors.highStrong,
                                      size: 24,
                                    ),
                                    onPressed: () async {
                                      await ref
                                          .read(
                                            guardianControllerProvider.notifier,
                                          )
                                          .removeGuardian(g.chatId);
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
                const SizedBox(height: AppSpacing.s16),

                // Button: Naya guardian jodein
                BigButton(
                  label: s.addGuardianBtn,
                  icon: Icons.person_add_outlined,
                  onPressed: _startPairing,
                ),
                const SizedBox(height: AppSpacing.s12),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
