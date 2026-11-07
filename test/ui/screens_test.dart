import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scamshield/engine/models.dart';
import 'package:scamshield/services/alert_service.dart';
import 'package:scamshield/services/guardian_store.dart';
import 'package:scamshield/state/analysis_controller.dart';
import 'package:scamshield/state/providers.dart';
import 'package:scamshield/ui/screens/complaint_screen.dart';
import 'package:scamshield/ui/screens/guardians_screen.dart';
import 'package:scamshield/ui/screens/home_screen.dart';
import 'package:scamshield/ui/screens/questions_screen.dart';
import 'package:scamshield/ui/screens/settings_screen.dart';
import 'package:scamshield/ui/screens/upload_screen.dart';
import 'package:scamshield/ui/screens/verdict_screen.dart';
import 'package:scamshield/ui/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TestAlertService implements AlertService {
  @override
  String getPairingUrl(String code) => 'https://t.me/test_bot?start=$code';

  @override
  Future<Guardian?> pollForPairing(String code) async =>
      Guardian(name: 'Rohan', chatId: 12345, addedAt: DateTime.now());

  @override
  Future<Map<int, bool>> sendAlert({
    required String text,
    required List<Guardian> guardians,
  }) async => {for (final g in guardians) g.chatId: true};
}

class FakeAnalysisController extends AnalysisController {
  new(this._initialState);
  final AnalysisState _initialState;

  @override
  AnalysisState build() => _initialState;
}

void main() {
  late SharedPreferences prefs;

  setUp(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          return null;
        });
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  Widget pumpScreen(Widget screen, {AnalysisController? controller}) {
    return ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        guardianStoreProvider.overrideWithValue(GuardianStore(prefs)),
        alertServiceProvider.overrideWithValue(TestAlertService()),
        if (controller != null)
          analysisControllerProvider.overrideWith(() => controller),
      ],
      child: MaterialApp(theme: AppTheme.lightTheme, home: screen),
    );
  }

  testWidgets('HomeScreen displays title, buttons and guardian prompt', (
    tester,
  ) async {
    await tester.pumpWidget(pumpScreen(const HomeScreen()));
    await tester.pumpAndSettle();

    expect(find.text('ScamShield'), findsOneWidget);
    expect(find.text('Recording check karein'), findsOneWidget);
    expect(find.text('Live Guard'), findsOneWidget);
    expect(find.text('Demo'), findsOneWidget);
    expect(
      find.text('Family ko jodein: scam pe unhe turant pata chalega'),
      findsOneWidget,
    );
  });

  testWidgets('UploadScreen displays file picking UI and privacy disclaimer', (
    tester,
  ) async {
    await tester.pumpWidget(pumpScreen(const UploadScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Recording chunein'), findsOneWidget);
    expect(find.text('File chunein'), findsOneWidget);
    expect(
      find.text(
        'Audio sirf likhne (transcription) ke liye bheja jaata hai. Phone pe ya kahin aur save nahi hota.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('QuestionsScreen allows answering and enables Plan button', (
    tester,
  ) async {
    await tester.pumpWidget(pumpScreen(const QuestionsScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Kuch sawaal'), findsOneWidget);
    expect(find.text('Kya aapne paise bheje?'), findsOneWidget);
    expect(find.text('Kya OTP ya bank details share ki?'), findsOneWidget);
    expect(
      find.text('Kya koi screen-sharing app download ki?'),
      findsOneWidget,
    );

    // Answer questions (tap Haan for all 3)
    final haanButtons = find.text('Haan');
    expect(haanButtons, findsNWidgets(3));

    await tester.tap(haanButtons.at(0));
    await tester.pump();
    await tester.tap(haanButtons.at(1));
    await tester.pump();
    await tester.tap(haanButtons.at(2));
    await tester.pumpAndSettle();

    final planBtn = find.text('Plan dikhao');
    expect(planBtn, findsOneWidget);
  });

  testWidgets('VerdictScreen displays level banner, summary and evidence', (
    tester,
  ) async {
    const verdict = Verdict(
      level: RiskLevel.high,
      score: 95,
      scamType: ScamType.digitalArrest,
      evidence: [
        TacticEvent(
          stage: Stage.authority,
          quote: 'Main CBI se Inspector bol raha hoon',
          atSec: 4.5,
          confidence: 0.9,
          source: EventSource.llm,
        ),
      ],
      entities: Entities(claimedAgency: 'CBI', claimedName: 'Inspector'),
      summaryHi: 'Yeh call ek digital arrest scam hai.',
    );

    final controller = FakeAnalysisController(
      const AnalysisState(phase: AnalysisPhase.done, verdict: verdict),
    );

    await tester.pumpWidget(
      pumpScreen(const VerdictScreen(), controller: controller),
    );
    await tester.pumpAndSettle();

    expect(find.text('Nateeja'), findsOneWidget);
    expect(find.text('KHATRA'), findsOneWidget);
    expect(find.text('Digital Arrest'), findsOneWidget);
    expect(find.text('Yeh call ek digital arrest scam hai.'), findsOneWidget);
    expect(find.text('Saboot (Evidence)'), findsOneWidget);
    expect(find.text('"Main CBI se Inspector bol raha hoon"'), findsOneWidget);
    expect(find.text('Aage: kya karein?'), findsOneWidget);
    expect(find.text('Family ko bhejo'), findsOneWidget);
  });

  testWidgets('ComplaintScreen builds draft with copy and share buttons', (
    tester,
  ) async {
    const verdict = Verdict(
      level: RiskLevel.high,
      score: 90,
      scamType: ScamType.digitalArrest,
      evidence: [
        TacticEvent(
          stage: Stage.authority,
          quote: 'Arrest warrant issue ho chuka hai',
          atSec: 10,
          confidence: 0.9,
          source: EventSource.lexicon,
        ),
      ],
      entities: Entities(claimedAgency: 'CBI'),
      summaryHi: 'Digital arrest call.',
    );

    final controller = FakeAnalysisController(
      const AnalysisState(phase: AnalysisPhase.done, verdict: verdict),
    );

    await tester.pumpWidget(
      pumpScreen(
        const ComplaintScreen(
          answers: Answers(paid: true, sharedCredentials: true),
        ),
        controller: controller,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Shikayat draft'), findsOneWidget);
    expect(find.text('Copy karein'), findsOneWidget);
    expect(find.text('Share karein'), findsOneWidget);
    expect(find.text('cybercrime.gov.in kholein'), findsOneWidget);

    // Tap copy
    await tester.tap(find.text('Copy karein'));
    await tester.pumpAndSettle();
    expect(find.text('Copy ho gaya ✓'), findsOneWidget);
  });

  testWidgets('GuardiansScreen renders empty state and add guardian button', (
    tester,
  ) async {
    await tester.pumpWidget(pumpScreen(const GuardiansScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Guardians'), findsOneWidget);
    expect(find.text('Abhi koi guardian nahi juda hai.'), findsOneWidget);
    expect(find.text('Naya guardian jodein'), findsOneWidget);
    expect(find.text('Khatra hone pe apne-aap alert bhejo'), findsOneWidget);
  });

  testWidgets('SettingsScreen allows switching language and auto-alert', (
    tester,
  ) async {
    await tester.pumpWidget(pumpScreen(const SettingsScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Bhasha / Language'), findsOneWidget);
    expect(find.text('Hinglish (English)'), findsOneWidget);
    expect(find.text('हिन्दी (Devanagari)'), findsOneWidget);
    expect(find.text('ScamShield v1.0.0 (Beyond Hack 2.0)'), findsOneWidget);

    // Tap Hindi toggle
    await tester.tap(find.text('हिन्दी (Devanagari)'));
    await tester.pumpAndSettle();

    expect(find.text('भाषा / Language'), findsOneWidget);
  });
}
