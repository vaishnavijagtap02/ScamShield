import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:scamshield/engine/models.dart';
import 'package:scamshield/state/providers.dart';
import 'package:scamshield/ui/strings.dart';
import 'package:scamshield/ui/theme/tokens.dart';
import 'package:scamshield/ui/widgets/big_button.dart';
import 'package:scamshield/ui/widgets/responsive_layout.dart';
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
    required int stepNumber,
    required String question,
    required bool? value,
    required ValueChanged<bool> onChanged,
    required S s,
  }) {
    return SectionCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s16,
        vertical: AppSpacing.s12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.elevatedSurface,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: value != null ? AppColors.accent : AppColors.line,
                  ),
                ),
                child: Text(
                  '$stepNumber',
                  style: AppTypography.caption.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    color: value != null
                        ? AppColors.accent
                        : AppColors.inkMuted,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.s8),
              Expanded(
                child: Text(
                  question,
                  style: AppTypography.bodyStrong.copyWith(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s12),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: OutlinedButton(
                    onPressed: () => onChanged(true),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: value == true
                          ? AppColors.highStrong.withValues(alpha: 0.2)
                          : AppColors.elevatedSurface,
                      foregroundColor: value == true
                          ? AppColors.highStrong
                          : AppColors.ink,
                      side: BorderSide(
                        color: value == true
                            ? AppColors.highStrong
                            : AppColors.line,
                        width: value == true ? 1.5 : 1,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.border12,
                      ),
                    ),
                    child: Text(
                      s.yesBtn,
                      style: AppTypography.bodyStrong.copyWith(
                        color: value == true
                            ? AppColors.highStrong
                            : AppColors.ink,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.s12),
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: OutlinedButton(
                    onPressed: () => onChanged(false),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: value == false
                          ? AppColors.accent.withValues(alpha: 0.15)
                          : AppColors.elevatedSurface,
                      foregroundColor: value == false
                          ? AppColors.accent
                          : AppColors.ink,
                      side: BorderSide(
                        color: value == false
                            ? AppColors.accent
                            : AppColors.line,
                        width: value == false ? 1.5 : 1,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.border12,
                      ),
                    ),
                    child: Text(
                      s.noBtn,
                      style: AppTypography.bodyStrong.copyWith(
                        color: value == false
                            ? AppColors.accent
                            : AppColors.ink,
                        fontWeight: FontWeight.w700,
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

    final answeredCount =
        (_paid != null ? 1 : 0) +
        (_sharedCredentials != null ? 1 : 0) +
        (_remoteApp != null ? 1 : 0);

    return ResponsiveLayout(
      appBar: AppBar(title: Text(s.questionsTitle)),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenPadding,
            vertical: AppSpacing.s16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Progress indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'SECURITY ASSESSMENT',
                    style: AppTypography.caption.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                      fontSize: 12,
                      color: AppColors.inkMuted,
                    ),
                  ),
                  Text(
                    '$answeredCount / 3 Answered',
                    style: AppTypography.caption.copyWith(
                      fontWeight: FontWeight.w700,
                      color: allAnswered
                          ? AppColors.accent
                          : AppColors.inkMuted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.s12),

              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    _buildQuestionRow(
                      stepNumber: 1,
                      question: s.qPaid,
                      value: _paid,
                      onChanged: (val) => setState(() => _paid = val),
                      s: s,
                    ),
                    const SizedBox(height: AppSpacing.s12),
                    _buildQuestionRow(
                      stepNumber: 2,
                      question: s.qCreds,
                      value: _sharedCredentials,
                      onChanged: (val) =>
                          setState(() => _sharedCredentials = val),
                      s: s,
                    ),
                    const SizedBox(height: AppSpacing.s12),
                    _buildQuestionRow(
                      stepNumber: 3,
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
