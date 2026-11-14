import 'package:flutter/material.dart';
import 'package:scamshield/ui/strings.dart';
import 'package:scamshield/ui/theme/tokens.dart';
import 'package:url_launcher/url_launcher.dart';

/// Responsive wrapper that adapts between mobile, tablet, and wide desktop viewports.
/// On desktop (> 1024px), provides a dual-column luxury dashboard layout with a
/// companion brand/telephony panel on the left and the active view in a framed container.
class ResponsiveLayout extends StatelessWidget {
  const new({
    required this.child,
    super.key,
    this.maxWidth = 640,
    this.showCompanion = true,
    this.appBar,
    this.floatingActionButton,
    this.bottomNavigationBar,
  });

  final Widget child;
  final double maxWidth;
  final bool showCompanion;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;

  static bool isDesktop(BuildContext context) {
    return MediaQuery.sizeOf(context).width >= AppSpacing.desktop;
  }

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width >= AppSpacing.mobile && width < AppSpacing.desktop;
  }

  static bool isMobile(BuildContext context) {
    return MediaQuery.sizeOf(context).width < AppSpacing.mobile;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 1024;
        final isMid = constraints.maxWidth >= 640 && !isWide;

        if (isWide && showCompanion) {
          return Scaffold(
            backgroundColor: AppColors.paper,
            body: SafeArea(
              child: Row(
                children: [
                  // Left companion dashboard panel
                  const SizedBox(width: 380, child: _DesktopCompanionPanel()),
                  Container(width: 1, color: AppColors.line),
                  // Main interactive view
                  Expanded(
                    child: Scaffold(
                      backgroundColor: Colors.transparent,
                      appBar: appBar,
                      floatingActionButton: floatingActionButton,
                      bottomNavigationBar: bottomNavigationBar,
                      body: Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: maxWidth),
                          child: child,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (isMid) {
          return Scaffold(
            backgroundColor: AppColors.paper,
            appBar: appBar,
            floatingActionButton: floatingActionButton,
            bottomNavigationBar: bottomNavigationBar,
            body: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: child,
              ),
            ),
          );
        }

        // Mobile default
        return Scaffold(
          backgroundColor: AppColors.paper,
          appBar: appBar,
          floatingActionButton: floatingActionButton,
          bottomNavigationBar: bottomNavigationBar,
          body: child,
        );
      },
    );
  }
}

class _DesktopCompanionPanel extends StatelessWidget {
  const new();

  Future<void> _dial1930() async {
    final uri = Uri.parse('tel:1930');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _openCyberPortal() async {
    final uri = Uri.parse('https://cybercrime.gov.in');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    const s = S(AppLanguage.hiLat);

    return Container(
      color: AppColors.cardSurface,
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Brand Header
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
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
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.shield_rounded,
                  color: Color(0xFF0A0D14),
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s.appName,
                    style: AppTypography.h1.copyWith(
                      letterSpacing: -0.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    'Beyond Hack 2.0 Security Core',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.accent,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 28),

          // Live Protection Badge
          Container(
            padding: const EdgeInsets.all(AppSpacing.s16),
            decoration: BoxDecoration(
              color: AppColors.elevatedSurface,
              borderRadius: AppRadius.border16,
              border: Border.all(color: AppColors.line),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: AppColors.accent,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: AppColors.accent, blurRadius: 8),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Live Guard Protection Active',
                      style: AppTypography.label.copyWith(
                        color: AppColors.ink,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'Continuous multi-stage tactic detection with zero data persistence. All voice analysis is private and runs purely in memory.',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.inkMuted,
                    fontSize: 14,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Emergency Quick Action: 1930 Helpline
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _dial1930,
              borderRadius: AppRadius.border16,
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.s16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.highStrong.withValues(alpha: 0.15),
                      AppColors.elevatedSurface,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: AppRadius.border16,
                  border: Border.all(
                    color: AppColors.highStrong.withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.highStrong.withValues(alpha: 0.2),
                        borderRadius: AppRadius.border12,
                      ),
                      child: const Icon(
                        Icons.phone_in_talk_rounded,
                        color: AppColors.highStrong,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'National Cyber Helpline',
                            style: AppTypography.caption.copyWith(
                              color: AppColors.inkMuted,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            'Dial 1930 (Toll Free)',
                            style: AppTypography.bodyStrong.copyWith(
                              color: AppColors.highStrong,
                              fontSize: 17,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Portal link
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _openCyberPortal,
              borderRadius: AppRadius.border16,
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.s16),
                decoration: BoxDecoration(
                  color: AppColors.elevatedSurface,
                  borderRadius: AppRadius.border16,
                  border: Border.all(color: AppColors.line),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.line.withValues(alpha: 0.5),
                        borderRadius: AppRadius.border12,
                      ),
                      child: const Icon(
                        Icons.public_rounded,
                        color: AppColors.ink,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Official Cyber Portal',
                            style: AppTypography.caption.copyWith(
                              color: AppColors.inkMuted,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            'cybercrime.gov.in',
                            style: AppTypography.bodyStrong.copyWith(
                              color: AppColors.ink,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_outward_rounded,
                      color: AppColors.inkMuted,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
          ),

          const Spacer(),

          // Footer info
          Container(
            padding: const EdgeInsets.all(AppSpacing.s12),
            decoration: BoxDecoration(
              color: AppColors.paper,
              borderRadius: AppRadius.border12,
              border: Border.all(color: AppColors.line),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.lock_outline_rounded,
                  size: 16,
                  color: AppColors.accent,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'End-to-end local inference & memory-only processing.',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.inkMuted,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
