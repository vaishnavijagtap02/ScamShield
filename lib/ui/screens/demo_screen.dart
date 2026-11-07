import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:scamshield/engine/models.dart';
import 'package:scamshield/state/providers.dart';
import 'package:scamshield/ui/strings.dart';
import 'package:scamshield/ui/theme/tokens.dart';
import 'package:scamshield/ui/widgets/section_card.dart';

class DemoScreen extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<DemoScreen> createState() => _DemoScreenState();
}

class _DemoScreenState extends ConsumerState<DemoScreen> {
  List<DemoScript> _scripts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    unawaited(_loadScripts());
  }

  Future<void> _loadScripts() async {
    try {
      final jsonStr = await rootBundle.loadString('assets/demo/scripts.json');
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      final rawList = map['scripts'] as List<dynamic>? ?? [];
      final scripts = rawList
          .map((s) => DemoScript.fromJson(s as Map<String, dynamic>))
          .toList();
      setState(() {
        _scripts = scripts;
        _isLoading = false;
      });
    } on Object {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _runDemo(DemoScript script) async {
    final controller = ref.read(analysisControllerProvider.notifier);
    await context.push('/analysing');
    await controller.analyzeDemo(script);
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsControllerProvider);
    final s = S(settings.language);

    return Scaffold(
      appBar: AppBar(title: Text(s.demoScreenTitle)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenPadding,
            vertical: AppSpacing.s12,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                s.demoSubtitle,
                style: AppTypography.body.copyWith(color: AppColors.inkMuted),
              ),
              const SizedBox(height: AppSpacing.s16),

              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: AppColors.ink),
                      )
                    : _scripts.isEmpty
                    ? const Center(
                        child: Text(
                          'Demo scripts not found.',
                          style: AppTypography.body,
                        ),
                      )
                    : ListView.separated(
                        itemCount: _scripts.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: AppSpacing.s12),
                        itemBuilder: (context, index) {
                          final script = _scripts[index];
                          final isScam = script.kind.toLowerCase() == 'scam';
                          final isSuspicious =
                              script.kind.toLowerCase() == 'suspicious';

                          final (tagBg, tagFg, tagLabel) = isScam
                              ? (
                                  AppColors.highStrong,
                                  AppColors.onHigh,
                                  s.tagScam,
                                )
                              : isSuspicious
                              ? (
                                  AppColors.medTint,
                                  AppColors.medInk,
                                  s.tagSuspicious,
                                )
                              : (
                                  AppColors.lowTint,
                                  AppColors.lowStrong,
                                  s.tagReal,
                                );

                          return SectionCard(
                            onTap: () => _runDemo(script),
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.s16,
                              vertical: AppSpacing.s12,
                            ),
                            child: SizedBox(
                              height: 48,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      script.title,
                                      style: AppTypography.bodyStrong,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.s12),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: tagBg,
                                      borderRadius: AppRadius.border8,
                                    ),
                                    child: Text(
                                      tagLabel,
                                      style: AppTypography.caption.copyWith(
                                        color: tagFg,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.s8),
                                  const Icon(
                                    Icons.play_arrow_rounded,
                                    color: AppColors.ink,
                                    size: 24,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
