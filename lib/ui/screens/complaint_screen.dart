import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scamshield/engine/complaint_service.dart';
import 'package:scamshield/engine/models.dart';
import 'package:scamshield/state/providers.dart';
import 'package:scamshield/ui/strings.dart';
import 'package:scamshield/ui/theme/tokens.dart';
import 'package:scamshield/ui/widgets/big_button.dart';
import 'package:scamshield/ui/widgets/section_card.dart';
import 'package:scamshield/ui/widgets/status_line.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class ComplaintScreen extends ConsumerStatefulWidget {
  const new({super.key, this.answers});

  final Answers? answers;

  @override
  ConsumerState<ComplaintScreen> createState() => _ComplaintScreenState();
}

class _ComplaintScreenState extends ConsumerState<ComplaintScreen> {
  bool _copied = false;

  Future<void> _copyToClipboard(String text) async {
    try {
      await Clipboard.setData(ClipboardData(text: text));
    } on Object {
      // Host platform clipboard fallback in test environments
    }
    setState(() => _copied = true);
  }

  Future<void> _shareComplaint(String text) async {
    await SharePlus.instance.share(
      ShareParams(text: text, subject: 'Cybercrime Complaint Draft'),
    );
  }

  Future<void> _openCybercrimePortal() async {
    final uri = Uri.parse('https://cybercrime.gov.in');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsControllerProvider);
    final s = S(settings.language);

    final analysisState = ref.watch(analysisControllerProvider);
    final verdict = analysisState.verdict;
    final answers = widget.answers ?? const Answers();

    final complaintText = verdict != null
        ? ComplaintService.build(verdict, answers, DateTime.now())
        : 'Complaint draft generation unavailable.';

    return Scaffold(
      appBar: AppBar(title: Text(s.complaintTitle)),
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
                child: SectionCard(
                  child: SingleChildScrollView(
                    child: SelectableText(
                      complaintText,
                      style: AppTypography.body.copyWith(
                        fontFamily: AppTypography.fontFamily,
                        height: 1.6,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.s16),

              if (_copied) ...[
                StatusLine(message: s.copySuccess, isSuccess: true),
                const SizedBox(height: AppSpacing.s12),
              ],

              BigButton(
                label: s.copyBtn,
                icon: Icons.copy_rounded,
                onPressed: () => _copyToClipboard(complaintText),
              ),
              const SizedBox(height: AppSpacing.s8),

              BigButton(
                label: s.shareBtn,
                icon: Icons.share_rounded,
                variant: BigButtonVariant.secondary,
                onPressed: () => _shareComplaint(complaintText),
              ),
              const SizedBox(height: AppSpacing.s8),

              BigButton(
                label: s.openPortalBtn,
                icon: Icons.open_in_browser_rounded,
                variant: BigButtonVariant.secondary,
                onPressed: _openCybercrimePortal,
              ),
              const SizedBox(height: AppSpacing.s12),
            ],
          ),
        ),
      ),
    );
  }
}
