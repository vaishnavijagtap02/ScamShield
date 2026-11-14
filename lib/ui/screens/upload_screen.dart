import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:scamshield/core/result.dart';
import 'package:scamshield/state/providers.dart';
import 'package:scamshield/ui/strings.dart';
import 'package:scamshield/ui/theme/tokens.dart';
import 'package:scamshield/ui/widgets/big_button.dart';
import 'package:scamshield/ui/widgets/responsive_layout.dart';
import 'package:scamshield/ui/widgets/section_card.dart';

class UploadScreen extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends ConsumerState<UploadScreen> {
  bool _isPicking = false;
  String? _errorMessage;

  Future<void> _pickAndAnalyze() async {
    setState(() {
      _isPicking = true;
      _errorMessage = null;
    });

    try {
      final file = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: ['wav', 'mp3', 'm4a', 'ogg'],
      );

      if (file == null) {
        setState(() => _isPicking = false);
        return;
      }

      final bytes = await file.xFile.readAsBytes();

      if (bytes.isEmpty) {
        setState(() {
          _isPicking = false;
          _errorMessage = S(ref.read(settingsControllerProvider).language)
              .errPickingFile;
        });
        return;
      }

      final ext = (file.extension ?? '').toLowerCase();
      if (!['wav', 'mp3', 'm4a', 'ogg'].contains(ext)) {
        setState(() {
          _isPicking = false;
          _errorMessage = S(ref.read(settingsControllerProvider).language)
              .errUnsupportedFile;
        });
        return;
      }

      final controller = ref.read(analysisControllerProvider.notifier);

      if (mounted) {
        unawaited(context.push('/analysing'));
      }

      unawaited(controller.analyzeUpload(bytes: bytes, filename: file.name));
    } on AudioFormatException catch (e) {
      setState(() {
        _isPicking = false;
        _errorMessage = e.message;
      });
    } on Object catch (_) {
      setState(() {
        _isPicking = false;
        _errorMessage = S(ref.read(settingsControllerProvider).language)
            .errPickingFile;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsControllerProvider);
    final s = S(settings.language);

    return ResponsiveLayout(
      appBar: AppBar(title: Text(s.uploadTitle)),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenPadding,
            vertical: AppSpacing.s16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Hero upload drop zone
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _isPicking ? null : _pickAndAnalyze,
                  borderRadius: AppRadius.border20,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.s24,
                      vertical: AppSpacing.s32,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.cardSurface,
                      borderRadius: AppRadius.border20,
                      border: Border.all(
                        color: AppColors.accent.withValues(alpha: 0.4),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accent.withValues(alpha: 0.08),
                          blurRadius: 24,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: AppColors.accent.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.cloud_upload_rounded,
                            size: 36,
                            color: AppColors.accent,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.s12),
                        Text(
                          s.uploadSupportedNote,
                          style: AppTypography.caption.copyWith(
                            color: AppColors.inkMuted,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.s24),

              if (_errorMessage != null) ...[
                SectionCard(
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        color: AppColors.highStrong,
                        size: 28,
                      ),
                      const SizedBox(width: AppSpacing.s12),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: AppTypography.body.copyWith(
                            color: AppColors.highStrong,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.s24),
              ],

              BigButton(
                label: _isPicking ? s.listeningStatus : s.chooseFileBtn,
                icon: Icons.upload_file_rounded,
                enabled: !_isPicking,
                onPressed: _pickAndAnalyze,
              ),
              const Spacer(),

              // Privacy Caption Card
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
                        Icons.lock_outline_rounded,
                        color: AppColors.accent,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.s12),
                    Expanded(
                      child: Text(
                        s.privacyCaption,
                        style: AppTypography.caption.copyWith(
                          color: AppColors.inkMuted,
                          fontSize: 14,
                          height: 1.4,
                        ),
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
