import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scamshield/app.dart';

void main() {
  testWidgets('Renders placeholder home', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: ScamShieldApp()));
    expect(find.text('ScamShield Placeholder Home'), findsOneWidget);
  });
}
