import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scamshield/engine/models.dart';
import 'package:scamshield/ui/theme/app_theme.dart';
import 'package:scamshield/ui/widgets/big_button.dart';
import 'package:scamshield/ui/widgets/evidence_row.dart';
import 'package:scamshield/ui/widgets/level_banner.dart';
import 'package:scamshield/ui/widgets/risk_meter.dart';
import 'package:scamshield/ui/widgets/section_card.dart';
import 'package:scamshield/ui/widgets/stage_stamp.dart';
import 'package:scamshield/ui/widgets/stage_track.dart';
import 'package:scamshield/ui/widgets/status_line.dart';

void main() {
  Widget wrapWidget(Widget child) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      home: Scaffold(body: Center(child: child)),
    );
  }

  group('BigButton tests', () {
    testWidgets('renders label and handles tap', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        wrapWidget(BigButton(label: 'Tap Me', onPressed: () => tapped = true)),
      );

      expect(find.text('Tap Me'), findsOneWidget);
      await tester.tap(find.text('Tap Me'));
      expect(tapped, isTrue);
    });

    testWidgets('disabled state does not fire tap', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        wrapWidget(
          BigButton(
            label: 'Disabled',
            enabled: false,
            onPressed: () => tapped = true,
          ),
        ),
      );

      await tester.tap(find.text('Disabled'));
      expect(tapped, isFalse);
    });
  });

  group('StageStamp and StageTrack tests', () {
    testWidgets('StageStamp shows seen state with timestamp', (tester) async {
      await tester.pumpWidget(
        wrapWidget(
          const StageStamp(
            stage: Stage.authority,
            displayName: 'Adhikari',
            seen: true,
            atSec: 12.5,
          ),
        ),
      );

      expect(find.text('Adhikari'), findsOneWidget);
      expect(find.text('00:12'), findsOneWidget);
    });

    testWidgets('StageStamp shows unseen state with placeholder', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrapWidget(const StageStamp(stage: Stage.fear, displayName: 'Darr')),
      );

      expect(find.text('Darr'), findsOneWidget);
      expect(find.text('--:--'), findsOneWidget);
    });

    testWidgets('StageTrack renders all 5 canonical stages', (tester) async {
      await tester.pumpWidget(
        wrapWidget(
          const StageTrack(
            seenStages: {Stage.authority, Stage.urgency},
            stageTimes: {Stage.authority: 5.0, Stage.urgency: 25.0},
          ),
        ),
      );

      expect(find.text('Adhikari'), findsOneWidget);
      expect(find.text('Darr'), findsOneWidget);
      expect(find.text('Jaldi'), findsOneWidget);
      expect(find.text('Chhupao'), findsOneWidget);
      expect(find.text('Paisa / OTP'), findsOneWidget);
      expect(find.text('00:05'), findsOneWidget);
      expect(find.text('00:25'), findsOneWidget);
    });
  });

  group('RiskMeter tests', () {
    testWidgets('renders score and zone labels', (tester) async {
      await tester.pumpWidget(
        wrapWidget(const RiskMeter(score: 85, level: RiskLevel.high)),
      );

      expect(find.text('85 / 100'), findsOneWidget);
      expect(find.text('Theek'), findsOneWidget);
      expect(find.text('Savdhan'), findsOneWidget);
      expect(find.text('Khatra'), findsOneWidget);
    });
  });

  group('LevelBanner tests', () {
    testWidgets('renders HIGH level with KHATRA title', (tester) async {
      await tester.pumpWidget(
        wrapWidget(const LevelBanner(level: RiskLevel.high)),
      );

      expect(find.text('KHATRA'), findsOneWidget);
      expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
    });

    testWidgets('renders LOW level with THEEK LAGTA HAI title', (tester) async {
      await tester.pumpWidget(
        wrapWidget(const LevelBanner(level: RiskLevel.low)),
      );

      expect(find.text('THEEK LAGTA HAI'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_outline_rounded), findsOneWidget);
    });
  });

  group('EvidenceRow tests', () {
    testWidgets('renders quote and timestamp', (tester) async {
      const event = TacticEvent(
        stage: Stage.authority,
        quote: 'Main CBI officer bol raha hoon',
        atSec: 14.2,
        confidence: 0.95,
        source: EventSource.llm,
        explanationHi: 'Fake police identity claim',
      );

      await tester.pumpWidget(wrapWidget(const EvidenceRow(event: event)));

      expect(find.text('00:14'), findsOneWidget);
      expect(find.text('· Adhikari'), findsOneWidget);
      expect(find.text('"Main CBI officer bol raha hoon"'), findsOneWidget);
      expect(find.text('Fake police identity claim'), findsOneWidget);
    });
  });

  group('SectionCard and StatusLine tests', () {
    testWidgets('SectionCard handles tap callback', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        wrapWidget(
          SectionCard(
            onTap: () => tapped = true,
            child: const Text('Card Content'),
          ),
        ),
      );

      expect(find.text('Card Content'), findsOneWidget);
      await tester.tap(find.text('Card Content'));
      expect(tapped, isTrue);
    });

    testWidgets('StatusLine renders success message and icon', (tester) async {
      await tester.pumpWidget(
        wrapWidget(const StatusLine(message: 'Alert sent ✓', isSuccess: true)),
      );

      expect(find.text('Alert sent ✓'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_outline_rounded), findsOneWidget);
    });
  });
}
