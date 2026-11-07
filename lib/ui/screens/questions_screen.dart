import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:scamshield/engine/models.dart';
import 'package:scamshield/state/providers.dart';
import 'package:scamshield/ui/strings.dart';
import 'package:scamshield/ui/theme/tokens.dart';
import 'package:scamshield/ui/widgets/big_button.dart';
import 'package:scamshield/ui/widgets/section_card.dart';

class QuestionsScreen extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<QuestionsScreen> createState() => _QuestionsScreenState();
}

class _QuestionsScreenState extends ConsumerState<QuestionsScreen> {
  bool? _paid;
  bool? _sharedCredentials;
  bool? _remoteApp;

  Widget _buildQuestionRow({
    required String question,
    required bool? value,
    required ValueChanged<bool> onChanged,
    required S s,
  }) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(question, style: AppTypography.bodyStrong),
          const SizedBox(height: AppSpacing.s12),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 56,
                  child: OutlinedButton(
                    onPressed: () => onChanged(true),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: value == true
                          ? AppColors.ink
                          : AppColors.surface,
                      foregroundColor: value == true
                          ? AppColors.surface
                          : AppColors.ink,
                      side: const BorderSide(color: AppColors.ink, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.border12,
                      ),
                    ),
                    child: Text(
                      s.yesBtn,
                      style: AppTypography.bodyStrong.copyWith(
                        color: value == true
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
                    onPressed: () => onChanged(false),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: value == false
                          ? AppColors.ink
                          : AppColors.surface,
                      foregroundColor: value == false
                          ? AppColors.surface
                          : AppColors.ink,
                      side: const BorderSide(color: AppColors.ink, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.border12,
                      ),
                    ),
                    child: Text(
                      s.noBtn,
                      style: AppTypography.bodyStrong.copyWith(
                        color: value == false
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsControllerProvider);
    final s = S(settings.language);

    final allAnswered =
        _paid != null && _sharedCredentials != null && _remoteApp != null;

    return Scaffold(
      appBar: AppBar(title: Text(s.questionsTitle)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenPadding,
            vertical: AppSpacing.s16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ListView(
                  children: [
                    _buildQuestionRow(
                      question: s.qPaid,
                      value: _paid,
                      onChanged: (val) => setState(() => _paid = val),
                      s: s,
                    ),
                    const SizedBox(height: AppSpacing.s16),
                    _buildQuestionRow(
                      question: s.qCreds,
                      value: _sharedCredentials,
                      onChanged: (val) =>
                          setState(() => _sharedCredentials = val),
                      s: s,
                    ),
                    const SizedBox(height: AppSpacing.s16),
                    _buildQuestionRow(
                      question: s.qRemote,
                      value: _remoteApp,
                      onChanged: (val) => setState(() => _remoteApp = val),
                      s: s,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.s16),
              BigButton(
                label: s.showPlanBtn,
                enabled: allAnswered,
                onPressed: allAnswered
                    ? () async {
                        final answers = Answers(
                          paid: _paid!,
                          sharedCredentials: _sharedCredentials!,
                          remoteApp: _remoteApp!,
                        );
                        await context.push('/plan', extra: answers);
                      }
                    : null,
              ),
              const SizedBox(height: AppSpacing.s12),
            ],
          ),
        ),
      ),
    );
  }
}
