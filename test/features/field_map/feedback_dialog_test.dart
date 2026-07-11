import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dogsafield/features/field_map/presentation/feedback_dialog.dart';
import 'package:dogsafield/i18n/strings.g.dart';

class FeedbackDialogHost extends StatefulWidget {
  const FeedbackDialogHost({super.key});

  @override
  State<FeedbackDialogHost> createState() => _FeedbackDialogHostState();
}

class _FeedbackDialogHostState extends State<FeedbackDialogHost> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Test')),
      body: ElevatedButton(
        onPressed: () => showDialog(
          context: context,
          builder: (_) => const FeedbackDialog(onSubmit: _dummySubmit),
        ),
        child: const Text('Open Feedback'),
      ),
    );
  }

  static Future<void> _dummySubmit(String message) async {}
}

void main() {
  testWidgets('does not crash when dismissed after typing', (tester) async {
    LocaleSettings.setLocaleSync(AppLocale.en);
    await tester.pumpWidget(
      TranslationProvider(child: MaterialApp(home: const FeedbackDialogHost())),
    );
    await tester.tap(find.text('Open Feedback'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'hello');
    await tester.pump();

    await tester.tap(find.text(t.feedback.cancel));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('shows success snackbar after submitting', (tester) async {
    LocaleSettings.setLocaleSync(AppLocale.en);
    await tester.pumpWidget(
      TranslationProvider(child: MaterialApp(home: const FeedbackDialogHost())),
    );
    await tester.tap(find.text('Open Feedback'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'hello');
    await tester.pump();

    await tester.tap(find.text(t.feedback.send));
    await tester.pumpAndSettle();

    expect(find.text(t.feedback.success), findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);
  });
}
