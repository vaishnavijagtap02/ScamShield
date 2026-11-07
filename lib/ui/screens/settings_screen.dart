import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scamshield/state/providers.dart';
import 'package:scamshield/ui/strings.dart';
import 'package:scamshield/ui/theme/tokens.dart';
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

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsControllerProvider);
    final s = S(settings.language);

    final guardianState = ref.watch(guardianControllerProvider);

    return Scaffold(
      appBar: AppBar(title: Text(s.settingsTitle)),
      body: SafeArea(
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
                    Text(s.languageSetting, style: AppTypography.h2),
                    const SizedBox(height: AppSpacing.s12),
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
                                    ? AppColors.ink
                                    : AppColors.surface,
                                side: const BorderSide(
                                  color: AppColors.ink,
                                  width: 1.5,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: AppRadius.border12,
                                ),
                              ),
                              child: Text(
                                'Hinglish (English)',
                                style: AppTypography.bodyStrong.copyWith(
                                  color: settings.language == AppLanguage.hiLat
                                      ? AppColors.surface
                                      : AppColors.ink,
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
                                    ? AppColors.ink
                                    : AppColors.surface,
                                side: const BorderSide(
                                  color: AppColors.ink,
                                  width: 1.5,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: AppRadius.border12,
                                ),
                              ),
                              child: Text(
                                'हिन्दी (Devanagari)',
                                style: AppTypography.bodyStrong.copyWith(
                                  color: settings.language == AppLanguage.hiDev
                                      ? AppColors.surface
                                      : AppColors.ink,
                                ),
                              ),
                            ),
                          ),
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
                    Text(s.userNameSetting, style: AppTypography.h2),
                    const SizedBox(height: AppSpacing.s8),
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        hintText: s.userNameHint,
                        filled: true,
                        fillColor: AppColors.paper,
                        border: OutlineInputBorder(
                          borderRadius: AppRadius.border8,
                          borderSide: const BorderSide(color: AppColors.line),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: AppRadius.border8,
                          borderSide: const BorderSide(
                            color: AppColors.ink,
                            width: 2,
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
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(s.autoAlertSetting, style: AppTypography.h2),
                          const SizedBox(height: 4),
                          Text(s.autoAlertDesc, style: AppTypography.caption),
                        ],
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
              const SizedBox(height: AppSpacing.s16),

              // Font Notice
              SectionCard(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.accessibility_new_rounded,
                      color: AppColors.ink,
                      size: 24,
                    ),
                    const SizedBox(width: AppSpacing.s12),
                    Expanded(
                      child: Text(s.fontNotice, style: AppTypography.body),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.s24),

              // App Version
              Center(
                child: Text(s.appVersionText, style: AppTypography.caption),
              ),
              const SizedBox(height: AppSpacing.s16),
            ],
          ),
        ),
      ),
    );
  }
}
