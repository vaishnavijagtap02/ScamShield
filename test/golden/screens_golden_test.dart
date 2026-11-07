import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scamshield/engine/models.dart';
import 'package:scamshield/services/guardian_store.dart';
import 'package:scamshield/state/analysis_controller.dart';
import 'package:scamshield/state/guardian_controller.dart';
import 'package:scamshield/state/providers.dart';
import 'package:scamshield/state/settings_controller.dart';
import 'package:scamshield/ui/screens/analysing_screen.dart';
import 'package:scamshield/ui/screens/complaint_screen.dart';
import 'package:scamshield/ui/screens/home_screen.dart';
import 'package:scamshield/ui/screens/questions_screen.dart';
import 'package:scamshield/ui/screens/verdict_screen.dart';
import 'package:scamshield/ui/theme/app_theme.dart';

class FakeAnalysisController extends AnalysisController {
  new(this._initialState);
  final AnalysisState _initialState;

  @override
  AnalysisState build() => _initialState;
}

class FakeSettingsController extends SettingsController {
  @override
  SettingsState build() => const SettingsState();
}

class FakeGuardianController extends GuardianController {
  @override
  GuardianState build() =>
      const GuardianState(guardians: [Guardian(name: 'Rohan', chatId: 12345)]);
}

void main() {
  Widget buildTestApp({
    required Widget child,
    AnalysisState? analysisState,
    double textScale = 1.0,
  }) {
    return ProviderScope(
      overrides: [
        settingsControllerProvider.overrideWith(FakeSettingsController.new),
        guardianControllerProvider.overrideWith(FakeGuardianController.new),
        if (analysisState != null)
          analysisControllerProvider.overrideWith(
            () => FakeAnalysisController(analysisState),
          ),
      ],
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        home: MediaQuery(
          data: MediaQueryData(
            size: const Size(412, 915),
            textScaler: TextScaler.linear(textScale),
          ),
          child: child,
        ),
      ),
    );
  }

  group('Screen golden tests', () {
    testWidgets('Home screen golden at 1.0x', (tester) async {
      tester.view.physicalSize = const Size(412, 915);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestApp(child: const HomeScreen()));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(HomeScreen),
        matchesGoldenFile('goldens/home_screen_1.0x.png'),
      );
    });

    testWidgets('Home screen golden at 1.3x', (tester) async {
      tester.view.physicalSize = const Size(412, 915);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        buildTestApp(child: const HomeScreen(), textScale: 1.3),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(HomeScreen),
        matchesGoldenFile('goldens/home_screen_1.3x.png'),
      );
    });

    testWidgets('Analysing screen golden at 1.0x', (tester) async {
      tester.view.physicalSize = const Size(412, 915);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      const state = AnalysisState(
        phase: AnalysisPhase.running,
        piecesTotal: 5,
        piecesDone: 3,
        risk: RiskResult(
          score: 85,
          level: RiskLevel.high,
          stagesSeen: {Stage.authority, Stage.urgency, Stage.fear},
        ),
        segments: [
          Segment(
            index: 0,
            text: 'Main Mumbai Crime Branch se DCP bol raha hoon.',
            startSec: 2,
            endSec: 6,
          ),
          Segment(
            index: 1,
            text: 'Aapke khilaaf arrest warrant nikla hai.',
            startSec: 7,
            endSec: 13,
          ),
          Segment(
            index: 2,
            text: 'Agla aadha ghanta bahut zaroori hai turant paise bhejo.',
            startSec: 14,
            endSec: 23,
          ),
        ],
        events: [
          TacticEvent(
            stage: Stage.authority,
            quote: 'Crime Branch se DCP bol raha hoon',
            atSec: 4,
            confidence: 0.9,
            source: EventSource.lexicon,
          ),
          TacticEvent(
            stage: Stage.fear,
            quote: 'arrest warrant nikla hai',
            atSec: 12,
            confidence: 0.9,
            source: EventSource.lexicon,
          ),
          TacticEvent(
            stage: Stage.urgency,
            quote: 'turant paise bhejo',
            atSec: 22,
            confidence: 0.9,
            source: EventSource.lexicon,
          ),
        ],
      );

      await tester.pumpWidget(
        buildTestApp(child: const AnalysingScreen(), analysisState: state),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(AnalysingScreen),
        matchesGoldenFile('goldens/analysing_screen_1.0x.png'),
      );
    });

    testWidgets('Verdict screen golden at 1.0x (HIGH)', (tester) async {
      tester.view.physicalSize = const Size(412, 915);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      const state = AnalysisState(
        phase: AnalysisPhase.done,
        risk: RiskResult(
          score: 100,
          level: RiskLevel.high,
          stagesSeen: {
            Stage.authority,
            Stage.fear,
            Stage.urgency,
            Stage.extraction,
          },
        ),
        verdict: Verdict(
          level: RiskLevel.high,
          score: 100,
          scamType: ScamType.digitalArrest,
          summaryHi: 'Farzi police ban kar digital arrest ki dhamki di aur paise transfer karne ka dabav banaya.',
          evidence: [
            TacticEvent(
              stage: Stage.authority,
              quote: 'Mumbai Crime Branch se bol rahe hain',
              atSec: 4,
              confidence: 0.95,
              source: EventSource.llm,
              explanationHi: 'Police identity impersonation',
            ),
            TacticEvent(
              stage: Stage.fear,
              quote: 'Arrest warrant jaari ho chuka hai',
              atSec: 12,
              confidence: 0.95,
              source: EventSource.llm,
              explanationHi: 'Legal intimidation and fear creation',
            ),
            TacticEvent(
              stage: Stage.extraction,
              quote: 'Account mein verification ke liye paise bhejein',
              atSec: 35,
              confidence: 0.95,
              source: EventSource.llm,
              explanationHi: 'Demand for bank fund transfer',
            ),
          ],
          entities: Entities(
            claimedAgency: 'Mumbai Crime Branch',
            claimedName: 'DCP',
          ),
        ),
      );

      await tester.pumpWidget(
        buildTestApp(child: const VerdictScreen(), analysisState: state),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(VerdictScreen),
        matchesGoldenFile('goldens/verdict_screen_1.0x.png'),
      );
    });

    testWidgets('Questions screen golden at 1.0x', (tester) async {
      tester.view.physicalSize = const Size(412, 915);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestApp(child: const QuestionsScreen()));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(QuestionsScreen),
        matchesGoldenFile('goldens/questions_screen_1.0x.png'),
      );
    });

    testWidgets('Complaint screen golden at 1.0x', (tester) async {
      tester.view.physicalSize = const Size(412, 915);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      const state = AnalysisState(
        verdict: Verdict(
          level: RiskLevel.high,
          score: 100,
          scamType: ScamType.digitalArrest,
          summaryHi: 'Farzi police ban kar digital arrest ki dhamki di.',
          evidence: [
            TacticEvent(
              stage: Stage.authority,
              quote: 'Main CBI officer bol raha hoon',
              atSec: 4,
              confidence: 0.95,
              source: EventSource.llm,
            ),
          ],
          entities: Entities(claimedAgency: 'CBI', claimedName: 'Inspector'),
        ),
      );

      await tester.pumpWidget(
        buildTestApp(child: const ComplaintScreen(), analysisState: state),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(ComplaintScreen),
        matchesGoldenFile('goldens/complaint_screen_1.0x.png'),
      );
    });
  });
}
