import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scamshield/ui/theme/app_theme.dart';
import 'package:scamshield/ui/theme/tokens.dart';
import 'package:scamshield/ui/widgets/big_button.dart';

void main() {
  testWidgets('BigButton golden test - all variants', (tester) async {
    tester.view.physicalSize = const Size(412, 915);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          backgroundColor: AppColors.paper,
          body: Padding(
            padding: const EdgeInsets.all(AppSpacing.s24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                BigButton(
                  label: 'Recording check karein',
                  subtitle: 'Call recording ya voice note',
                  icon: Icons.mic_rounded,
                  onPressed: () {},
                ),
                const SizedBox(height: AppSpacing.s16),
                BigButton(
                  label: 'Live Guard',
                  subtitle: 'Speaker pe chal rahi call suno',
                  icon: Icons.phone_in_talk_rounded,
                  variant: BigButtonVariant.secondary,
                  onPressed: () {},
                ),
                const SizedBox(height: AppSpacing.s16),
                BigButton(
                  label: '1930 pe call karein',
                  subtitle: 'National Cyber Crime Helpline',
                  icon: Icons.call,
                  variant: BigButtonVariant.danger,
                  onPressed: () {},
                ),
                const SizedBox(height: AppSpacing.s16),
                BigButton(
                  label: 'Disabled Button',
                  enabled: false,
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    await expectLater(
      find.byType(Scaffold),
      matchesGoldenFile('goldens/big_buttons.png'),
    );
  });
}
