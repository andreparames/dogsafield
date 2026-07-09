import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dogsafield/features/field_map/presentation/feedback_dialog.dart';

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
    await tester.pumpWidget(
      const MaterialApp(home: FeedbackDialogHost()),
    );
    await tester.tap(find.text('Open Feedback'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'hello');
    await tester.pump();

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('shows success snackbar after submitting', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: FeedbackDialogHost()),
    );
    await tester.tap(find.text('Open Feedback'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'hello');
    await tester.pump();

    await tester.tap(find.text('Send'));
    await tester.pumpAndSettle();

    expect(find.text('Thanks for your feedback!'), findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);
  });
}
