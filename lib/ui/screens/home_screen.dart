import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:scamshield/core/config.dart';
import 'package:scamshield/state/providers.dart';
import 'package:scamshield/ui/strings.dart';
import 'package:scamshield/ui/theme/tokens.dart';
import 'package:scamshield/ui/widgets/big_button.dart';
import 'package:scamshield/ui/widgets/section_card.dart';
import 'package:scamshield/ui/widgets/status_line.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const new({super.key, this.initialFactIndex = 0});

  final int initialFactIndex;

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _factIndex = 0;

  @override
  void initState() {
    super.initState();
    _factIndex = widget.initialFactIndex;
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsControllerProvider);
    final s = S(settings.language);

    final guardianState = ref.watch(guardianControllerProvider);
    final guardians = guardianState.guardians;

    final missingKeys = Config.validate();
    final hasMissingKeys = missingKeys.isNotEmpty;

    final facts = s.didYouKnowFacts;
    final currentFact = facts[_factIndex % facts.length];

    return Scaffold(
      backgroundColor: AppColors.paper,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenPadding,
            vertical: AppSpacing.s16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    s.homeTitle,
                    style: AppTypography.display.copyWith(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Row(
                    children: [
                      // Language Toggle
                      Semantics(
                        button: true,
                        label: 'Change language',
                        child: OutlinedButton(
                          onPressed: () {
                            unawaited(
                              ref
                                  .read(settingsControllerProvider.notifier)
                                  .toggleLanguage(),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            backgroundColor: AppColors.surface,
                            foregroundColor: AppColors.ink,
                            side: const BorderSide(
                              color: AppColors.ink,
                              width: 1.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: AppRadius.border8,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            minimumSize: const Size(56, 44),
                          ),
                          child: Text(
                            s.langToggle,
                            style: AppTypography.label.copyWith(fontSize: 16),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.s8),
                      // Settings Button
                      IconButton(
                        tooltip: 'Settings',
                        icon: const Icon(Icons.settings_outlined, size: 28),
                        onPressed: () => unawaited(context.push('/settings')),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.s16),

              // Missing Keys Banner (if demo only)
              if (hasMissingKeys) ...[
                Container(
                  padding: const EdgeInsets.all(AppSpacing.s12),
                  decoration: BoxDecoration(
                    color: AppColors.medTint,
                    borderRadius: AppRadius.border8,
                    border: Border.all(color: AppColors.medStrong),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline_rounded,
                        color: AppColors.medStrong,
                        size: 20,
                      ),
                      const SizedBox(width: AppSpacing.s8),
                      Expanded(
                        child: Text(
                          s.demoOnlyBanner,
                          style: AppTypography.caption.copyWith(
                            color: AppColors.medInk,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.s16),
              ],

              // Guardian Status
              if (guardians.isNotEmpty)
                InkWell(
                  onTap: () => unawaited(context.push('/guardians')),
                  borderRadius: AppRadius.border8,
                  child: StatusLine(
                    message: '${s.guardianLinkedPrefix}${guardians.first.name}',
                    isSuccess: true,
                  ),
                )
              else
                SectionCard(
                  onTap: () => unawaited(context.push('/guardians')),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.shield_outlined,
                        color: AppColors.ink,
                        size: 28,
                      ),
                      const SizedBox(width: AppSpacing.s12),
                      Expanded(
                        child: Text(
                          s.linkGuardianCard,
                          style: AppTypography.bodyStrong.copyWith(
                            fontSize: 18,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: AppColors.inkMuted,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: AppSpacing.s24),

              // Primary: Recording check
              BigButton(
                label: s.checkRecordingBtn,
                subtitle: s.checkRecordingSub,
                icon: Icons.audio_file_outlined,
                onPressed: () => unawaited(context.push('/upload')),
              ),
              const SizedBox(height: AppSpacing.buttonGap),

              // Secondary: Live Guard
              BigButton(
                label: s.liveGuardBtn,
                subtitle: s.liveGuardSub,
                icon: Icons.mic_none_outlined,
                variant: BigButtonVariant.secondary,
                onPressed: () => unawaited(context.push('/live')),
              ),
              const SizedBox(height: AppSpacing.buttonGap),

              // Secondary: Demo
              BigButton(
                label: s.demoBtn,
                subtitle: s.demoSub,
                icon: Icons.play_circle_outline_rounded,
                variant: BigButtonVariant.secondary,
                onPressed: () => unawaited(context.push('/demo')),
              ),
              const SizedBox(height: AppSpacing.s32),

              // Fact Card (Did you know?)
              SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.lightbulb_outline_rounded,
                          color: AppColors.medStrong,
                          size: 22,
                        ),
                        const SizedBox(width: AppSpacing.s8),
                        Text(
                          s.isHindi ? 'क्या आप जानते हैं?' : 'Did you know?',
                          style: AppTypography.caption.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.inkMuted,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.s8),
                    Text(
                      currentFact,
                      style: AppTypography.body.copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.s16),
            ],
          ),
        ),
      ),
    );
  }
}
