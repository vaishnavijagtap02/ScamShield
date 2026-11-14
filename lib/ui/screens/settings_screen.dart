import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scamshield/state/providers.dart';
import 'package:scamshield/ui/strings.dart';
import 'package:scamshield/ui/theme/tokens.dart';
import 'package:scamshield/ui/widgets/responsive_layout.dart';
import 'package:scamshield/ui/widgets/section_card.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    final initialName = ref.read(guardianControllerProvider).userName;
    _nameController = TextEditingController(text: initialName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Widget _buildLanguagePill({
    required AppLanguage targetLang,
    required AppLanguage currentLang,
    required VoidCallback onTap,
  }) {
    final isSelected = targetLang == currentLang;

    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        backgroundColor: isSelected
            ? AppColors.accent.withValues(alpha: 0.15)
            : AppColors.elevatedSurface,
        side: BorderSide(
          color: isSelected ? AppColors.accent : AppColors.line,
          width: isSelected ? 1.5 : 1,
        ),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.border12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            targetLang.nativeName,
            style: AppTypography.bodyStrong.copyWith(
              color: isSelected ? AppColors.accent : AppColors.ink,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              fontSize: 16,
            ),
          ),
          Text(
            targetLang.displayName,
            style: AppTypography.caption.copyWith(
              color: isSelected ? AppColors.accent : AppColors.inkMuted,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsControllerProvider);
    final s = S(settings.language);

    final guardianState = ref.watch(guardianControllerProvider);

    return ResponsiveLayout(
      appBar: AppBar(title: Text(s.settingsTitle)),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenPadding,
            vertical: AppSpacing.s16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Language Selection Card
              SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          s.languageSetting,
                          style: AppTypography.h2.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withValues(alpha: 0.15),
                            borderRadius: AppRadius.border8,
                          ),
                          child: Text(
                            settings.language.nativeName,
                            style: AppTypography.caption.copyWith(
                              color: AppColors.accent,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.s16),

                    // Primary Bilingual Buttons (matches tests)
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 56,
                            child: OutlinedButton(
                              onPressed: () async {
                                await ref
                                    .read(settingsControllerProvider.notifier)
                                    .setLanguage(AppLanguage.hiLat);
                              },
                              style: OutlinedButton.styleFrom(
                                backgroundColor:
                                    settings.language == AppLanguage.hiLat
                                    ? AppColors.accent.withValues(alpha: 0.15)
                                    : AppColors.elevatedSurface,
                                side: BorderSide(
                                  color: settings.language == AppLanguage.hiLat
                                      ? AppColors.accent
                                      : AppColors.line,
                                  width: settings.language == AppLanguage.hiLat
                                      ? 1.5
                                      : 1,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: AppRadius.border12,
                                ),
                              ),
                              child: Text(
                                'Hinglish (English)',
                                style: AppTypography.bodyStrong.copyWith(
                                  color: settings.language == AppLanguage.hiLat
                                      ? AppColors.accent
                                      : AppColors.ink,
                                  fontWeight:
                                      settings.language == AppLanguage.hiLat
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.s12),
                        Expanded(
                          child: SizedBox(
                            height: 56,
                            child: OutlinedButton(
                              onPressed: () async {
                                await ref
                                    .read(settingsControllerProvider.notifier)
                                    .setLanguage(AppLanguage.hiDev);
                              },
                              style: OutlinedButton.styleFrom(
                                backgroundColor:
                                    settings.language == AppLanguage.hiDev
                                    ? AppColors.accent.withValues(alpha: 0.15)
                                    : AppColors.elevatedSurface,
                                side: BorderSide(
                                  color: settings.language == AppLanguage.hiDev
                                      ? AppColors.accent
                                      : AppColors.line,
                                  width: settings.language == AppLanguage.hiDev
                                      ? 1.5
                                      : 1,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: AppRadius.border12,
                                ),
                              ),
                              child: Text(
                                'हिन्दी (Devanagari)',
                                style: AppTypography.bodyStrong.copyWith(
                                  color: settings.language == AppLanguage.hiDev
                                      ? AppColors.accent
                                      : AppColors.ink,
                                  fontWeight:
                                      settings.language == AppLanguage.hiDev
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.s16),

                    Text(
                      'More Indian Languages',
                      style: AppTypography.caption.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.inkMuted,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s12),

                    // Multi-language Grid for regional languages
                    GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: AppSpacing.s12,
                      mainAxisSpacing: AppSpacing.s12,
                      childAspectRatio: 2.2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _buildLanguagePill(
                          targetLang: AppLanguage.en,
                          currentLang: settings.language,
                          onTap: () async {
                            await ref
                                .read(settingsControllerProvider.notifier)
                                .setLanguage(AppLanguage.en);
                          },
                        ),
                        _buildLanguagePill(
                          targetLang: AppLanguage.mr,
                          currentLang: settings.language,
                          onTap: () async {
                            await ref
                                .read(settingsControllerProvider.notifier)
                                .setLanguage(AppLanguage.mr);
                          },
                        ),
                        _buildLanguagePill(
                          targetLang: AppLanguage.gu,
                          currentLang: settings.language,
                          onTap: () async {
                            await ref
                                .read(settingsControllerProvider.notifier)
                                .setLanguage(AppLanguage.gu);
                          },
                        ),
                        _buildLanguagePill(
                          targetLang: AppLanguage.bn,
                          currentLang: settings.language,
                          onTap: () async {
                            await ref
                                .read(settingsControllerProvider.notifier)
                                .setLanguage(AppLanguage.bn);
                          },
                        ),
                        _buildLanguagePill(
                          targetLang: AppLanguage.ta,
                          currentLang: settings.language,
                          onTap: () async {
                            await ref
                                .read(settingsControllerProvider.notifier)
                                .setLanguage(AppLanguage.ta);
                          },
                        ),
                        _buildLanguagePill(
                          targetLang: AppLanguage.te,
                          currentLang: settings.language,
                          onTap: () async {
                            await ref
                                .read(settingsControllerProvider.notifier)
                                .setLanguage(AppLanguage.te);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.s16),

              // User Name for Alert
              SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.userNameSetting,
                      style: AppTypography.h2.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s12),
                    TextField(
                      controller: _nameController,
                      style: AppTypography.body.copyWith(color: AppColors.ink),
                      decoration: InputDecoration(
                        hintText: s.userNameHint,
                        filled: true,
                        fillColor: AppColors.elevatedSurface,
                        border: OutlineInputBorder(
                          borderRadius: AppRadius.border12,
                          borderSide: const BorderSide(color: AppColors.line),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: AppRadius.border12,
                          borderSide: const BorderSide(
                            color: AppColors.accent,
                            width: 1.5,
                          ),
                        ),
                      ),
                      onChanged: (val) {
                        unawaited(
                          ref
                              .read(guardianControllerProvider.notifier)
                              .setUserName(val),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.s16),

              // Auto Alert Toggle
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
                        Icons.crisis_alert_rounded,
                        color: AppColors.accent,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.s12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            s.autoAlertSetting,
                            style: AppTypography.bodyStrong.copyWith(
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            s.autoAlertDesc,
                            style: AppTypography.caption.copyWith(
                              color: AppColors.inkMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: guardianState.autoAlert,
                      activeThumbColor: AppColors.accent,
                      onChanged: (val) async {
                        await ref
                            .read(guardianControllerProvider.notifier)
                            .setAutoAlert(enabled: val);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.s16),

              // Font Notice
              SectionCard(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.elevatedSurface,
                        borderRadius: AppRadius.border8,
                      ),
                      child: const Icon(
                        Icons.accessibility_new_rounded,
                        color: AppColors.inkMuted,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.s12),
                    Expanded(
                      child: Text(
                        s.fontNotice,
                        style: AppTypography.caption.copyWith(
                          color: AppColors.inkMuted,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.s24),

              // App Version
              Center(
                child: Text(
                  s.appVersionText,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.inkMuted.withValues(alpha: 0.6),
                    fontSize: 13,
                  ),
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
