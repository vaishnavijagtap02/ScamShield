import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:scamshield/core/config.dart';
import 'package:scamshield/state/providers.dart';
import 'package:scamshield/ui/strings.dart';
import 'package:scamshield/ui/theme/tokens.dart';
import 'package:scamshield/ui/widgets/big_button.dart';
import 'package:scamshield/ui/widgets/responsive_layout.dart';
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

  void _nextFact(int total) {
    setState(() {
      _factIndex = (_factIndex + 1) % total;
    });
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

    return ResponsiveLayout(
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenPadding,
            vertical: AppSpacing.s16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Bar with Brand Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.accent, Color(0xFF00B0FF)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: AppRadius.border12,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.accent.withValues(alpha: 0.35),
                              blurRadius: 12,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.shield_rounded,
                          color: Color(0xFF0A0D14),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.s12),
                      Text(
                        s.homeTitle,
                        style: AppTypography.display.copyWith(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
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
                            backgroundColor: AppColors.elevatedSurface,
                            foregroundColor: AppColors.ink,
                            side: const BorderSide(color: AppColors.line),
                            shape: RoundedRectangleBorder(
                              borderRadius: AppRadius.border12,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            minimumSize: const Size(56, 44),
                          ),
                          child: Text(
                            s.langToggle,
                            style: AppTypography.label.copyWith(
                              fontSize: 16,
                              color: AppColors.accent,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.s8),
                      // Settings Button
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.elevatedSurface,
                          borderRadius: AppRadius.border12,
                          border: Border.all(color: AppColors.line),
                        ),
                        child: IconButton(
                          tooltip: 'Settings',
                          icon: const Icon(
                            Icons.settings_outlined,
                            size: 24,
                            color: AppColors.ink,
                          ),
                          onPressed: () => unawaited(context.push('/settings')),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.s20),

              // Missing Keys Banner (if demo only)
              if (hasMissingKeys) ...[
                Container(
                  padding: const EdgeInsets.all(AppSpacing.s12),
                  decoration: BoxDecoration(
                    color: AppColors.medTint,
                    borderRadius: AppRadius.border12,
                    border: Border.all(
                      color: AppColors.medStrong.withValues(alpha: 0.5),
                    ),
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

              // Guardian Status Card
              if (guardians.isNotEmpty)
                InkWell(
                  onTap: () => unawaited(context.push('/guardians')),
                  borderRadius: AppRadius.border12,
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
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withValues(alpha: 0.15),
                          borderRadius: AppRadius.border12,
                        ),
                        child: const Icon(
                          Icons.security_rounded,
                          color: AppColors.accent,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.s12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              s.linkGuardianCard,
                              style: AppTypography.bodyStrong.copyWith(
                                fontSize: 17,
                                height: 1.3,
                              ),
                            ),
                          ],
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

              // Action Cards Section
              Text(
                'FRAUD DETECTION MODES',
                style: AppTypography.caption.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  fontSize: 12,
                  color: AppColors.inkMuted,
                ),
              ),
              const SizedBox(height: AppSpacing.s12),

              // Primary: Recording check
              BigButton(
                label: s.checkRecordingBtn,
                subtitle: s.checkRecordingSub,
                icon: Icons.audio_file_rounded,
                onPressed: () => unawaited(context.push('/upload')),
              ),
              const SizedBox(height: AppSpacing.buttonGap),

              // Secondary: Live Guard
              BigButton(
                label: s.liveGuardBtn,
                subtitle: s.liveGuardSub,
                icon: Icons.mic_rounded,
                variant: BigButtonVariant.secondary,
                onPressed: () => unawaited(context.push('/live')),
              ),
              const SizedBox(height: AppSpacing.buttonGap),

              // Secondary: Demo
              BigButton(
                label: s.demoBtn,
                subtitle: s.demoSub,
                icon: Icons.play_circle_fill_rounded,
                variant: BigButtonVariant.secondary,
                onPressed: () => unawaited(context.push('/demo')),
              ),
              const SizedBox(height: AppSpacing.s24),

              // Fact Card (Did you know?)
              SectionCard(
                onTap: () => _nextFact(facts.length),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppColors.accent.withValues(alpha: 0.15),
                                borderRadius: AppRadius.border8,
                              ),
                              child: const Icon(
                                Icons.lightbulb_rounded,
                                color: AppColors.accent,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.s8),
                            Text(
                              s.isHindi
                                  ? 'क्या आप जानते हैं?'
                                  : 'Did you know?',
                              style: AppTypography.caption.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.accent,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                        const Icon(
                          Icons.refresh_rounded,
                          size: 16,
                          color: AppColors.inkMuted,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.s12),
                    Text(
                      currentFact,
                      style: AppTypography.body.copyWith(
                        fontSize: 17,
                        color: AppColors.ink,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.s20),
            ],
          ),
        ),
      ),
    );
  }
}
