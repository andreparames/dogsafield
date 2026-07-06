import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dogsafield/app.dart';

void main() {
  testWidgets('App renders welcome screen on launch', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: DogsAfieldApp()));
    await tester.pumpAndSettle();

    expect(find.text('Dogs Afield'), findsOneWidget);
    expect(find.text('Continue with Google'), findsOneWidget);
  });
}
