import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scamshield/app.dart';
import 'package:scamshield/services/guardian_store.dart';
import 'package:scamshield/state/providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Renders ScamShield Home screen', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          guardianStoreProvider.overrideWithValue(GuardianStore(prefs)),
        ],
        child: const ScamShieldApp(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('ScamShield'), findsOneWidget);
    expect(find.text('Recording check karein'), findsOneWidget);
    expect(find.text('Live Guard'), findsOneWidget);
    expect(find.text('Demo'), findsOneWidget);
  });
}
